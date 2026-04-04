# 검증 패턴 (Zod)

> `package.json`에 `zod` 의존성이 있는 프로젝트에만 적용한다.
> React Hook Form과 함께 사용할 때 `@hookform/resolvers` 필요.

---

## 적용 판단

| 조건 | Zod 사용 | 대안 |
|------|----------|------|
| 폼 필드 3개 이상 + 검증 규칙 있음 | ✅ | — |
| 폼 필드 1-2개, 단순 required | ❌ | RHF `register({ required })` |
| Server Action 입력 검증 | ✅ | — |
| API 응답 런타임 검증 | ✅ | — |
| 내부 함수 간 타입 보장 | ❌ | TypeScript 타입만으로 충분 |

---

## 스키마 파일 위치

```
src/
└── schemas/
    ├── {domain}.ts      # 도메인별 스키마 + 타입
    └── index.ts         # 배럴 export
```

한 도메인의 스키마가 많아지면 폴더로 분리한다:

```
src/schemas/order/
├── create.ts
├── update.ts
└── index.ts
```

---

## 핵심 규칙

### 1. 타입은 스키마에서 도출한다

타입과 스키마를 따로 정의하면 둘이 어긋날 때 런타임 에러가 발생한다.
`z.infer`로 스키마에서 타입을 도출하면 단일 진실 공급원이 보장된다.

```typescript
// ✅ 스키마에서 타입 도출 — 항상 동기화됨
import { z } from 'zod';

export const createOrderSchema = z.object({
  productName: z.string().min(1, '상품명은 필수입니다'),
  quantity: z.number().min(1, '최소 1개 이상'),
  memo: z.string().optional(),
});

export type CreateOrderInput = z.infer<typeof createOrderSchema>;
```

```typescript
// ❌ 금지: 타입과 스키마 따로 정의
interface CreateOrderInput {
  productName: string;
  quantity: number;
  memo?: string;
}

const createOrderSchema = z.object({
  productName: z.string(),
  quantity: z.number(),
  // memo 빠뜨림 — 타입과 불일치하지만 컴파일 에러 없음
});
```

### 2. React Hook Form 연동

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { createOrderSchema, type CreateOrderInput } from '@/schemas/order';

function OrderForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CreateOrderInput>({
    resolver: zodResolver(createOrderSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('productName')} />
      {errors.productName && (
        <p role="alert">{errors.productName.message}</p>
      )}
    </form>
  );
}
```

### 3. Server Action 입력 검증 (App Router)

Server Action은 클라이언트에서 직접 호출 가능하므로 입력을 반드시 검증한다.
클라이언트 폼 검증만으로는 부족하다 — 브라우저 우회가 가능하기 때문이다.

```typescript
'use server';

import { createOrderSchema } from '@/schemas/order';

export async function createOrder(formData: FormData) {
  const raw = Object.fromEntries(formData);
  const parsed = createOrderSchema.safeParse(raw);

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors };
  }

  // parsed.data는 타입 안전함
  await db.order.create({ data: parsed.data });
}
```

### 4. API 응답 검증 — 시스템 경계에서만

외부 API 응답처럼 TypeScript가 보장하지 못하는 데이터만 런타임 검증한다.
내부 함수 간 전달에는 타입만으로 충분하다.

```typescript
// ✅ 외부 API 응답 검증 — 신뢰할 수 없는 데이터
const externalResponseSchema = z.object({
  id: z.string(),
  status: z.enum(['active', 'inactive']),
});

export async function fetchExternalData() {
  const res = await fetch('https://external-api.com/data');
  const json = await res.json();
  return externalResponseSchema.parse(json); // 형태 불일치 시 즉시 에러
}
```

```typescript
// ❌ 과잉: 내부 함수 반환값까지 Zod로 검증
function calculateTotal(items: OrderItem[]): number {
  const total = items.reduce((sum, item) => sum + item.price, 0);
  return z.number().parse(total); // 불필요 — TypeScript가 이미 보장
}
```

---

## 스키마 작성 패턴

### 에러 메시지는 한글로

```typescript
const schema = z.object({
  email: z.string().email('올바른 이메일 형식이 아닙니다'),
  age: z.number().min(0, '나이는 0 이상이어야 합니다'),
});
```

### 공통 스키마 재사용

```typescript
// schemas/common.ts
export const paginationSchema = z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(20),
});

export const dateRangeSchema = z.object({
  startDate: z.string().date(),
  endDate: z.string().date(),
});

// schemas/order.ts — 공통 스키마 합성
import { paginationSchema, dateRangeSchema } from './common';

export const orderListParamsSchema = paginationSchema.merge(dateRangeSchema).extend({
  status: z.enum(['pending', 'active', 'completed']).optional(),
});
```

### update 스키마는 create에서 파생

```typescript
export const createOrderSchema = z.object({
  productName: z.string().min(1),
  quantity: z.number().min(1),
});

// 모든 필드를 optional로 — 부분 업데이트
export const updateOrderSchema = createOrderSchema.partial();

export type CreateOrderInput = z.infer<typeof createOrderSchema>;
export type UpdateOrderInput = z.infer<typeof updateOrderSchema>;
```

---

## 금지 패턴

| 금지 | 이유 | 대안 |
|------|------|------|
| 타입과 스키마 별도 정의 | 불일치 발생 | `z.infer` 사용 |
| 내부 함수 반환값 Zod 검증 | 과잉 검증 | TypeScript 타입 |
| 에러 메시지 미작성 | 사용자에게 기술적 메시지 노출 | 한글 메시지 명시 |
| 스키마 인라인 정의 (컴포넌트 안) | 재사용 불가, 렌더링마다 재생성 | `schemas/` 파일로 분리 |

---

## 체크리스트

- [ ] 스키마 파일이 `src/schemas/`에 있는가?
- [ ] 타입이 `z.infer`로 도출되었는가?
- [ ] Server Action 입력에 `safeParse` 검증이 있는가?
- [ ] 에러 메시지가 한글로 작성되었는가?
- [ ] 배럴 `index.ts`가 업데이트되었는가?

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `../core/coding-standards.md` | 기본 TypeScript 표준 |
| `../core/state-and-server-state.md` | RHF 사용 규칙 |
| `../core/nextjs-app-router.md` | Server Action 인증 패턴 |

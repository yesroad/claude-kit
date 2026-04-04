# TypeScript 도구 생태계 & 스택

> 2026년 4월 기준

---

## 1. 실전 tsconfig.json 설정

TypeScript 6.0부터 `strict`가 기본값 `true`로 변경되었습니다.

```json
{
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist",

    "target": "es2022",
    "module": "nodenext",
    // "module": "esnext",  // 번들러(Vite, webpack) 사용 시

    "strict": true,
    "noUncheckedIndexedAccess": true,       // arr[0]이 T | undefined
    "exactOptionalPropertyTypes": true,     // undefined와 없음을 구분

    "moduleResolution": "nodenext",
    // "moduleResolution": "bundler",        // Vite/webpack 프로젝트
    "esModuleInterop": true,
    "verbatimModuleSyntax": true,           // import type 강제

    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    "skipLibCheck": true,
    "isolatedModules": true,

    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**TypeScript 6.0 주요 변경 기본값 (2026년 3월)**

| 옵션 | 기존 기본값 | 변경된 기본값 |
|------|------------|--------------|
| `strict` | `false` | `true` |
| `module` | `commonjs` | `esnext` |
| `target` | `es3` | `es2025` |
| `types` | 모든 `@types` | `[]` (빈 배열) |

---

## 2. 린트 & 포맷

```bash
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

```js
// eslint.config.js (Flat Config 방식, 2025년 표준)
import tseslint from "typescript-eslint";

export default tseslint.config(tseslint.configs.recommended, {
  rules: {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
  },
});
```

---

## 3. 런타임 검증 — Zod

TypeScript 타입은 컴파일 타임에만 존재합니다. API 응답, form 입력 등 런타임 데이터는 별도 검증이 필요합니다.

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.number(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "user", "guest"]),
});

// 스키마에서 타입 자동 추출
type User = z.infer<typeof UserSchema>;

// 런타임 검증
const result = UserSchema.safeParse(apiResponse);
if (result.success) {
  console.log(result.data.name); // 타입 안전
} else {
  console.error(result.error.issues);
}
```

---

## 4. 타입 안전 API — tRPC

서버-클라이언트 간 타입을 자동으로 공유합니다.

```typescript
// 서버
const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => getUserById(input.id)),
});

// 클라이언트 — 타입 자동 추론
const user = await trpc.getUser.query({ id: 1 });
// user.name ← 자동완성 + 타입 안전
```

---

## 5. 모노레포 + 공유 타입 관리

### 5.1 Turborepo 기반 타입 공유 구조

```
apps/
├── web/     # Next.js 프론트엔드
├── api/     # Express/Hono 백엔드
└── mobile/  # React Native
packages/
├── types/   # 공유 타입 패키지 ← 핵심
│   ├── src/
│   │   ├── user.ts
│   │   ├── order.ts
│   │   └── index.ts   # 배럴 export
│   ├── package.json
│   └── tsconfig.json
├── ui/      # 공유 컴포넌트
└── utils/   # 공유 유틸
```

```json
// packages/types/package.json
{
  "name": "@myapp/types",
  "exports": {
    ".": { "types": "./src/index.ts" }
  }
}
```

### 5.2 배럴 Export 주의사항

```typescript
// ✅ 타입만 있는 패키지는 배럴 OK
export type { User, UserId } from './user';
export type { Order, OrderId } from './order';

// ❌ 런타임 코드가 있는 경우 배럴은 tree-shaking 방해
import { parseUser } from '@myapp/utils/parseUser'; // 직접 경로 권장
```

---

## 6. 타입 테스트

### 6.1 Vitest expectTypeOf (현재 가장 많이 쓰임)

```typescript
import { expectTypeOf, test } from 'vitest';

test('fetchUser 반환 타입 검증', () => {
  expectTypeOf(fetchUser).toBeFunction();
  expectTypeOf(fetchUser).returns.resolves.toEqualTypeOf<User>();
});

test('제네릭 함수 타입 추론 검증', () => {
  expectTypeOf(firstItem([1, 2, 3])).toEqualTypeOf<number | undefined>();
  expectTypeOf(firstItem(['a', 'b'])).toEqualTypeOf<string | undefined>();
});
```

### 6.2 tsd — 타입 정의 파일 전용 테스트

```typescript
// src/utils.test-d.ts
import { expectType, expectError } from 'tsd';
import { createUserId, createOrderId, getOrder } from './index';

const userId = createUserId('abc');
const orderId = createOrderId('xyz');

expectType<UserId>(userId);
expectError(getOrder(userId)); // UserId → OrderId 불가 확인
```

---

## 7. 현업 스택 조합

| 카테고리 | 스택 |
|---------|------|
| **풀스택 웹** | Next.js 15 + TypeScript + Zod + tRPC + Prisma + Turborepo |
| **프론트엔드 단독** | React + TypeScript + Zod + TanStack Query + Zustand/Jotai |
| **백엔드 단독** | Node.js + Hono/Express + TypeScript + Zod + Prisma/DrizzleORM + neverthrow |
| **테스트** | Vitest + Testing Library + expectTypeOf |
| **공통 도구** | ESLint + typescript-eslint + Prettier + tsx |

---

## 8. 자주 논쟁되는 주제

| 주제 | 현재 커뮤니티 다수 의견 |
|------|------------------------|
| interface vs type | 팀에서 통일이 핵심. 객체는 interface, 나머지는 type 선호 |
| enum vs const 객체 | `const` + `as const` 선호 증가. enum은 번들 크기·erasableSyntax 문제 |
| try/catch vs Result 타입 | 대형 프로젝트일수록 Result 타입(neverthrow) 선호 증가 |
| 배럴 export | 타입 전용 패키지는 OK, 런타임 코드는 직접 경로 선호 |
| any vs unknown | unknown 강제가 현재 표준. strict 모드 기본값화로 자연스럽게 정착 |
| Zod vs Valibot | Zod가 압도적 점유율. Valibot은 번들 크기 민감한 경우 |

---

## 9. 2026년 실무 트렌드

- **TypeScript 직접 실행**: Node.js 22+, Deno, Bun이 TS를 별도 컴파일 없이 실행. `--erasableSyntaxOnly` 옵션이 중요해지고, `enum`·`namespace`를 피하는 스타일이 늘어남
- **타입 추론 최대 활용**: 불필요한 타입 어노테이션을 줄이고 함수 반환 타입에만 명시하는 방향
- **`satisfies` 적극 활용**: TypeScript 4.9 도입 이후 실무 활용 증가
- **Zod + tRPC 조합 표준화**: 프론트-백엔드 타입을 한 번에 관리하는 풀스택 패턴
- **TypeScript 7.0 (Go 기반)**: 기존 대비 10배 빠른 컴파일 속도를 목표로 논의 중. 6.0에서 deprecated된 옵션을 미리 정리해두는 것이 권장됨

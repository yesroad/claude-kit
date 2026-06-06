---
paths:
  - "**/*.{ts,tsx}"
  - "**/types/**"
---

# TypeScript 타입 패턴 — 심화

## 2. Brand Types — 실수 방지의 핵심

```typescript
// ❌ 타입은 통과, 런타임은 폭발
function getOrder(orderId: string) { ... }
const userId = "user-123";
getOrder(userId); // 버그!

// ✅ Brand Type으로 컴파일 타임에 차단
type Brand<T, B> = T & { readonly __brand: B };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

function createUserId(id: string): UserId {
  return id as UserId; // 생성 함수만 캐스팅 허용
}

function getOrder(orderId: OrderId) { ... }

const userId = createUserId("user-123");
getOrder(userId); // ❌ 컴파일 에러! UserId는 OrderId에 할당 불가
```

Zod와 함께 쓰면 런타임 검증까지 한 번에:

```typescript
import { z } from 'zod';

const UserIdSchema = z.string().uuid().brand<'UserId'>();
const OrderIdSchema = z.string().uuid().brand<'OrderId'>();

type UserId = z.infer<typeof UserIdSchema>;
type OrderId = z.infer<typeof OrderIdSchema>;

const userId = UserIdSchema.parse(req.params.id); // 타입 + 검증 동시
```

실무 적용 사례:

```typescript
type Money = Brand<number, 'Money'>;
type Email = Brand<string, 'Email'>;
type Percentage = Brand<number, 'Percentage'>;

function applyDiscount(price: Money, discount: Percentage): Money {
  return (price * (1 - discount / 100)) as Money;
}

applyDiscount(20 as Percentage, 50000 as Money); // ❌ 컴파일 에러 — 순서 실수 방지
```

---

## 3. 심화 타입 패턴

### 3.1 Conditional Types — API 응답 자동 타이핑

```typescript
type ApiResponse<T extends 'user' | 'order' | 'product'> = {
  user: { id: string; name: string; email: string };
  order: { id: string; total: number; items: string[] };
  product: { id: string; price: number; stock: number };
}[T];

async function fetchData<T extends 'user' | 'order' | 'product'>(
  type: T
): Promise<ApiResponse<T>> {
  const res = await fetch(`/api/${type}`);
  return res.json();
}

const user = await fetchData('user');
// user.email ← 자동완성 동작. user.total은 에러
```

### 3.2 Mapped Types — 한 타입에서 여러 타입 파생

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

// getter/setter 자동 생성
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};
type Setters<T> = {
  [K in keyof T as `set${Capitalize<string & K>}`]: (val: T[K]) => void;
};

type UserStore = Getters<User> & Setters<User>;
// → getName(): string, setName(val: string): void 등 자동 생성

// 이벤트 핸들러 타입 자동 생성
type EventHandlers<T> = {
  [K in keyof T as `on${Capitalize<string & K>}Change`]?: (val: T[K]) => void;
};
type UserFormHandlers = EventHandlers<Pick<User, 'name' | 'email'>>;
// → onNameChange?: (val: string) => void
```

### 3.3 Template Literal Types — 이벤트/경로 타입 안전성

```typescript
// HTTP 메서드 + 경로 조합 (토스에서도 사용)
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiPath = '/users' | '/orders' | '/products';
type Endpoint = `${HttpMethod} ${ApiPath}`;
// → 'GET /users' | 'POST /users' | ... (12가지)

// CSS 단위 안전 처리
type CSSUnit = 'px' | 'rem' | 'em' | '%' | 'vh' | 'vw';
type CSSValue = `${number}${CSSUnit}`;

function setWidth(value: CSSValue) { ... }
setWidth('100%');   // ✅
setWidth('100abc'); // ❌ 컴파일 에러

// 이벤트 이름 패턴
type EntityEvent<T extends string> =
  | `${T}:created`
  | `${T}:updated`
  | `${T}:deleted`;

type UserEvent = EntityEvent<'user'>;
// 'user:created' | 'user:updated' | 'user:deleted'
```

### 3.4 infer — 타입 안에서 타입 추출

```typescript
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type A = UnwrapPromise<Promise<string>>; // string

type ElementType<T> = T extends (infer E)[] ? E : never;
type C = ElementType<string[]>; // string

// 실무 예: API 훅 반환 타입에서 data만 추출
type ExtractData<T> = T extends { data: infer D } ? D : never;
type UseQueryResult<T> = { data: T | undefined; isLoading: boolean; error: Error | null };
type UserData = ExtractData<UseQueryResult<User>>; // User | undefined
```

### 3.5 satisfies 연산자 — 타입 추론 유지하면서 검증

```typescript
type Config = {
  env: 'dev' | 'prod' | 'staging';
  port: number;
  features: Record<string, boolean>;
};

// ❌ as: 세부 타입 정보 소실
const config1 = { env: 'dev', port: 3000, features: { darkMode: true } } as Config;
// config1.env 타입: 'dev' | 'prod' | 'staging' (너무 넓음)

// ✅ satisfies: 검증은 하되 추론은 유지
const config2 = { env: 'dev', port: 3000, features: { darkMode: true } } satisfies Config;
// config2.env 타입: 'dev' (리터럴 타입 유지!)
// config2.features.darkMode ← 자동완성 동작

// 객체 유효성 검증에도 유용
const routes = {
  home: '/',
  login: '/login',
  invalid: 123, // ❌ 컴파일 에러!
} satisfies Record<string, string>;
```

---

기초 패턴: ts-type-patterns-basics.md

# TypeScript 타입 패턴

> 기본 패턴부터 심화 패턴까지 — 2026년 4월 기준

---

## 1. 기본 타입 패턴

### 1.1 Union Type + Discriminated Union

프론트엔드 상태 관리의 핵심 패턴입니다.

```typescript
// ❌ 이런 방식은 타입 안전하지 않음
interface ApiState {
  isLoading: boolean;
  data?: User;
  error?: string;
}

// ✅ Discriminated Union — 상태가 명확하게 구분됨
type ApiState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

function renderUser(state: ApiState<User>) {
  if (state.status === 'loading') return <Spinner />;
  if (state.status === 'error') return <p>{state.error}</p>;
  if (state.status === 'success') return <p>{state.data.name}</p>; // data 타입 확정
  return null;
}
```

### 1.2 Utility Types 실전 활용

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
  createdAt: Date;
}

type UserUpdateForm = Partial<User>;                        // 모든 필드 선택적
type PublicUser = Omit<User, "password">;                  // password 제외
type UserPreview = Pick<User, "id" | "name">;              // 특정 필드만
type ReadonlyUser = Readonly<User>;                        // 읽기 전용
type UserMap = Record<number, PublicUser>;                 // 객체 타입
type CreateUserInput =
  Required<Pick<User, "id" | "email">> &
  Partial<Omit<User, "id" | "email">>;                    // id/email 필수, 나머지 선택
```

### 1.3 Generic 함수

```typescript
// 타입 안전한 API fetch 래퍼
async function apiFetch<TResponse>(
  url: string,
  options?: RequestInit,
): Promise<TResponse> {
  const response = await fetch(url, options);
  if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
  return response.json() as TResponse;
}

const user = await apiFetch<User>("/api/users/1"); // user 타입: User

// 배열 제네릭
function firstItem<TItem>(arr: TItem[]): TItem | undefined {
  return arr[0];
}
const first = firstItem([1, 2, 3]); // number | undefined
```

### 1.4 Enum vs const 객체

```typescript
// 문자열 enum (런타임에서도 값이 명확)
enum UserRole {
  Admin = "ADMIN",
  User = "USER",
  Guest = "GUEST",
}

// 최근 트렌드: const 객체 + as const 방식 (enum 대체)
// → 번들 크기 절감, erasableSyntax 이슈 없음
const STATUS = {
  Idle: "idle",
  Loading: "loading",
  Success: "success",
  Error: "error",
} as const;
type Status = (typeof STATUS)[keyof typeof STATUS];
// 'idle' | 'loading' | 'success' | 'error'
```

### 1.5 타입 가드 (Type Guard)

```typescript
interface Cat { meow(): void; }
interface Dog { bark(): void; }

// 사용자 정의 타입 가드 (is 키워드)
function isCat(animal: Cat | Dog): animal is Cat {
  return "meow" in animal;
}

function handleAnimal(animal: Cat | Dog) {
  if (isCat(animal)) {
    animal.meow(); // Cat으로 좁혀짐
  } else {
    animal.bark(); // Dog으로 좁혀짐
  }
}
```

### 1.6 interface vs type

```typescript
// interface: 객체 구조 정의, 상속/확장이 필요할 때
interface Animal { name: string; }
interface Dog extends Animal { breed: string; }

// type: 유니온, 인터섹션, 튜플, 복잡한 변환
type ID = string | number;
type Nullable<T> = T | null;
type Pair = [string, number];
```

> 실제로는 대부분 둘 다 쓸 수 있음. **팀에서 하나로 통일하는 게 더 중요.**

---

## 2. Brand Types — 실수 방지의 핵심

`UserId`와 `OrderId`가 둘 다 `string`이면 TypeScript는 구분하지 못합니다.

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

TypeScript 4.9+, `as const`의 진화형.

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

## 4. 현업에서 자주 저지르는 실수

```typescript
// ❌ any 남발 → ✅ unknown 사용
function process(data: unknown) {
  if (typeof data === 'string') {
    console.log(data.toUpperCase()); // 사용 전 타입 확인 강제
  }
}

// ❌ 박싱된 객체 타입
function greet(name: String): String { ... }
// ✅ 소문자 원시 타입
function greet(name: string): string { ... }

// ❌ 콜백 반환 타입 any → ✅ void
function execute(cb: () => void) { cb(); }

// ❌ 중복 오버로드
interface Logger {
  log(msg: string): void;
  log(msg: string, level: string): void;
}
// ✅ 선택적 파라미터
interface Logger {
  log(msg: string, level?: string): void;
}
```

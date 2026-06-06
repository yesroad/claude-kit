---
paths:
  - "**/*.{ts,tsx}"
  - "**/types/**"
---

# TypeScript 타입 패턴 — 기초

## 1. 기본 타입 패턴

### 1.1 Union Type + Discriminated Union

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

심화 패턴: ts-type-patterns-advanced.md

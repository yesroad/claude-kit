# TypeScript 네이밍 & 프로젝트 구조

> 2026년 4월 기준

---

## 1. 네이밍 컨벤션

### 1.1 케이싱 규칙

| 대상 | 케이싱 | 예시 |
|------|--------|------|
| 변수, 함수 | camelCase | `getUserData`, `userName` |
| 클래스, 인터페이스, 타입, enum | PascalCase | `UserProfile`, `HttpStatusCode` |
| 전역 상수 | UPPER_SNAKE_CASE | `MAX_RETRY_ATTEMPTS`, `API_BASE_URL` |
| 파일명 | camelCase | `userService.ts`, `authTypes.ts` |
| React 컴포넌트 파일 | PascalCase | `UserProfile.tsx`, `LoginForm.tsx` |

```typescript
// ✅ 올바른 예
const userName = "john";
function getUserData() {}
const MAX_RETRY = 3;
class DatabaseConnection {}
interface UserProfile {}
type ResponseStatus = "success" | "error";
enum HttpStatusCode {
  OK = 200,
  NotFound = 404,
}

// ❌ 피해야 할 예
const UserName = "john";       // 변수에 PascalCase 금지
function get_user_data() {}    // snake_case 금지
```

### 1.2 타입 네이밍 규칙

**규칙 1: 복수형 금지 — 항상 단수로**

유니온 타입은 "여러 가능성 중 하나"를 뜻하므로 단수가 맞습니다.

```typescript
// ❌ 잘못된 예
type Routes = "/user" | "/admin" | "/home";

// ✅ 올바른 예
type Route = "/user" | "/admin" | "/home";

// 배열 타입만 예외적으로 복수 허용
type Routes = Route[];
```

**규칙 2: 타입과 값의 케이싱을 다르게**

```typescript
const route = "/user";         // 런타임 값: camelCase
type Route = "/user" | "/admin"; // 타입 레벨: PascalCase
```

**규칙 3: 제네릭 타입 파라미터 — Total TypeScript 스타일 (Matt Pocock)**

```typescript
// 단일 타입 파라미터
type Response<T> = { data: T; status: number };

// 여러 파라미터: T 접두사로 의미 명확하게
// ❌ 읽기 어려움
type Pair<T, U> = [T, U];

// ✅ 의미가 명확함
type Pair<TFirst, TSecond> = [TFirst, TSecond];
type ApiResponse<TData, TError> =
  | { success: true; data: TData }
  | { success: false; error: TError };
```

> 팀 컨벤션에 따라 단순 `T`, `U` 방식도 통용됨.

**규칙 4: I/T 접두사 붙이지 않기**

```typescript
// ❌ 구시대적 방식
interface IUser { ... }
type TConfig = { ... }

// ✅ 현대적 방식
interface User { ... }
type Config = { ... }
```

---

## 2. 프로젝트 폴더 구조

### 2.1 소규모 프로젝트 (1~5명)

```
src/
├── components/   # UI 컴포넌트
├── pages/        # 라우팅 단위 페이지
├── hooks/        # 커스텀 훅
├── utils/        # 유틸리티 함수
├── services/     # API 호출
├── types/        # 공용 타입 정의
│   ├── user.ts
│   ├── api.ts
│   └── common.ts
├── App.tsx
└── index.tsx
```

### 2.2 중규모 이상 (5명+): Feature-Based 구조

기능(Feature) 단위로 묶어 응집도를 높이는 방식이 현재 가장 권장됩니다.

```
src/
├── features/
│   ├── user/
│   │   ├── types.ts
│   │   ├── UserProfile.tsx
│   │   ├── useUser.ts
│   │   └── userService.ts
│   ├── product/
│   │   ├── types.ts
│   │   ├── ProductList.tsx
│   │   └── productService.ts
│   └── auth/
│       ├── types.ts
│       ├── LoginForm.tsx
│       └── authService.ts
├── shared/
│   ├── components/   # 공통 UI 컴포넌트
│   ├── hooks/        # 공통 훅
│   ├── utils/        # 공통 유틸
│   └── types/        # 전역 공용 타입
│       ├── api.ts
│       └── common.ts
├── App.tsx
└── index.tsx
```

### 2.3 Node.js / Express + TypeScript 구조

```
src/
├── controllers/    # 요청/응답 처리
├── services/       # 비즈니스 로직
├── repositories/   # DB 접근 레이어
├── models/         # DB 모델
├── middlewares/
├── routes/
├── types/
│   ├── express.d.ts  # Express 타입 확장
│   └── models.ts
├── utils/
└── index.ts
```

---

## 3. 타입 위치 결정 원칙

**원칙 1: 한 곳에서만 쓰는 타입은 해당 파일 안에**

```typescript
// UserProfile.tsx — 이 파일에서만 쓰이므로 파일 안에 정의
interface UserProfileProps {
  user: { id: number; name: string };
  onEdit: () => void;
}

export const UserProfile = ({ user, onEdit }: UserProfileProps) => { ... };
```

**원칙 2: 여러 파일에서 쓰는 타입은 공용 types 파일로**

```typescript
// types/user.ts
export interface User {
  id: number;
  name: string;
  email: string;
  role: "admin" | "user" | "guest";
}
```

**원칙 3: API 응답 타입은 서비스/API 레이어 근처에**

```typescript
// services/userService.ts
interface RawUserResponse {
  user_id: number;
  user_name: string;
}

interface NormalizedUser {
  id: number;
  name: string;
}

function normalizeUser(raw: RawUserResponse): NormalizedUser {
  return { id: raw.user_id, name: raw.user_name };
}
```

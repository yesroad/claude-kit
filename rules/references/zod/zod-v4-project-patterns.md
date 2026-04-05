# Zod v4 프로젝트 구조 & 스키마 패턴

## 폴더 구조

### 소규모 프로젝트 (Next.js App Router 기준)

```
src/
├── app/
│   ├── (auth)/
│   │   └── login/
│   │       └── page.tsx
│   └── api/
│       └── users/
│           └── route.ts
├── schemas/               ← 스키마 전용 폴더
│   ├── index.ts           ← 전체 re-export
│   ├── user.schema.ts
│   ├── auth.schema.ts
│   └── common.schema.ts   ← 공통 재사용 스키마
├── lib/
└── types/
    └── index.ts           ← z.infer<> 타입 export
```

### 중·대규모 프로젝트 (도메인 기반 구조)

```
src/
├── features/
│   ├── auth/
│   │   ├── schemas/
│   │   │   ├── login.schema.ts
│   │   │   └── register.schema.ts
│   │   ├── actions/
│   │   │   └── auth.action.ts
│   │   └── components/
│   │       └── LoginForm.tsx
│   ├── users/
│   │   ├── schemas/
│   │   │   ├── user.schema.ts
│   │   │   └── profile.schema.ts
│   │   └── ...
│   └── products/
│       └── schemas/
│           └── product.schema.ts
├── shared/
│   └── schemas/
│       ├── common.schema.ts   ← pagination, id, date 등 공통
│       └── env.schema.ts      ← 환경변수 검증
└── types/
    └── index.ts
```

### tRPC 프로젝트 구조

```
src/
├── server/
│   ├── routers/
│   │   ├── user.router.ts
│   │   └── post.router.ts
│   ├── schemas/           ← 서버 스키마 (input/output 검증)
│   │   ├── user.schema.ts
│   │   └── post.schema.ts
│   └── trpc.ts
├── shared/
│   └── schemas/           ← 클라이언트-서버 공유 스키마
│       └── common.schema.ts
└── client/
    └── ...
```

---

## 스키마 파일 기본 구조

```typescript
// user.schema.ts
import * as z from "zod";

// 1. 기본 스키마 정의
export const UserSchema = z.object({
  id: z.uuidv4(),
  name: z.string().min(2).max(50),
  email: z.email(),
  age: z.int().min(0).max(150).optional(),
  role: z.enum(["admin", "user", "guest"]),
  createdAt: z.iso.datetime(),
});

// 2. 파생 스키마 (기본 스키마 재활용)
export const CreateUserSchema = UserSchema.omit({
  id: true,
  createdAt: true,
});

export const UpdateUserSchema = CreateUserSchema.partial();

export const UserIdSchema = UserSchema.pick({ id: true });

// 3. 타입 export (스키마와 같은 파일에)
export type User = z.infer<typeof UserSchema>;
export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;
```

---

## 공통 스키마 (재사용 컴포넌트)

```typescript
// shared/schemas/common.schema.ts
import * as z from "zod";

export const PaginationSchema = z.object({
  page: z.int().min(1).default(1),
  limit: z.int().min(1).max(100).default(20),
});

export const SortSchema = z.object({
  sortBy: z.string().optional(),
  order: z.enum(["asc", "desc"]).default("asc"),
});

export const DateRangeSchema = z.object({
  from: z.iso.date().optional(),
  to: z.iso.date().optional(),
}).refine(
  (data) => !data.from || !data.to || data.from <= data.to,
  { error: "종료일은 시작일 이후여야 합니다", path: ["to"] }
);

export const IdSchema = z.uuidv4();
export type Id = z.infer<typeof IdSchema>;
```

---

## 환경변수 검증 (필수 패턴)

```typescript
// shared/schemas/env.schema.ts
import * as z from "zod";

const EnvSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]),
  DATABASE_URL: z.url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NEXTAUTH_URL: z.url(),
  API_KEY: z.string().min(1),
  PORT: z.stringbool().optional(), // v4 신규: "true"/"false" 파싱
});

export const env = EnvSchema.parse(process.env);
// 서버 시작 시점에 즉시 검증됨 → 런타임 오류 조기 발견
```

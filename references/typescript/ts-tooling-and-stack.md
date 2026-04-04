# TypeScript 도구 생태계 & 스택

## 1. 실전 tsconfig.json 설정

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


# Zod v4 실전 패턴

## 폼 검증 (React Hook Form + Zod)

```typescript
// LoginForm.tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";

const LoginSchema = z.object({
  email: z.email({ error: "올바른 이메일 형식이 아닙니다" }),
  password: z.string().min(8, { error: "비밀번호는 8자 이상이어야 합니다" }),
});

type LoginForm = z.infer<typeof LoginSchema>;

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<LoginForm>({
    resolver: zodResolver(LoginSchema),
  });

  const onSubmit = (data: LoginForm) => {
    // data는 완전히 타입 안전
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("email")} />
      {errors.email && <span>{errors.email.message}</span>}
      <input type="password" {...register("password")} />
      {errors.password && <span>{errors.password.message}</span>}
    </form>
  );
}
```

---

## Next.js Server Actions + Zod

```typescript
// actions/user.action.ts
"use server";
import * as z from "zod";

const CreateUserSchema = z.object({
  name: z.string().min(2),
  email: z.email(),
});

export async function createUser(formData: FormData) {
  const result = CreateUserSchema.safeParse({
    name: formData.get("name"),
    email: formData.get("email"),
  });

  if (!result.success) {
    return {
      errors: z.flattenError(result.error).fieldErrors,
    };
  }

  // result.data는 타입 안전
  await db.user.create({ data: result.data });
  return { success: true };
}
```

---

## API 라우트 검증 (Next.js App Router)

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from "next/server";
import * as z from "zod";
import { UserSchema } from "@/schemas/user.schema";

const QuerySchema = z.object({
  page: z.string().transform(Number).pipe(z.int().min(1)).default("1"),
  search: z.string().optional(),
});

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const query = QuerySchema.safeParse(Object.fromEntries(searchParams));

  if (!query.success) {
    return NextResponse.json(
      { errors: z.flattenError(query.error).fieldErrors },
      { status: 400 }
    );
  }

  // query.data.page는 number 타입으로 안전하게 사용
  const users = await fetchUsers(query.data);
  return NextResponse.json(users);
}
```

---

## tRPC 라우터 + Zod

```typescript
// server/routers/user.router.ts
import { initTRPC } from "@trpc/server";
import * as z from "zod";
import { UserSchema, CreateUserSchema } from "@/schemas/user.schema";

const t = initTRPC.create();

export const userRouter = t.router({
  getById: t.procedure
    .input(z.uuidv4())
    .output(UserSchema)
    .query(async ({ input }) => {
      return await db.user.findUnique({ where: { id: input } });
    }),

  create: t.procedure
    .input(CreateUserSchema)
    .output(UserSchema)
    .mutation(async ({ input }) => {
      return await db.user.create({ data: input });
    }),
});
```

---

## 변환(Transform) + 파이프 패턴

```typescript
// 입력: string → 출력: number (API 쿼리 파라미터 처리)
const NumericStringSchema = z.string()
  .transform(Number)
  .pipe(z.int().min(0));

// v4 신규: overwrite() — 타입 변경 없이 값 변환
const TrimmedString = z.string()
  .overwrite(val => val.trim()) // 여전히 string 타입
  .min(1);

// stringbool (환경변수, 폼 체크박스 처리)
const EnabledSchema = z.stringbool();
// "true", "1", "yes", "on", "y", "enabled"   → true
// "false", "0", "no", "off", "n", "disabled" → false
```

---

## Discriminated Union (복잡한 타입 분기)

```typescript
const ApiResponseSchema = z.discriminatedUnion("status", [
  z.object({
    status: z.literal("success"),
    data: UserSchema,
  }),
  z.object({
    status: z.literal("error"),
    code: z.literal([400, 401, 403, 404, 500]), // v4: 배열로 여러 리터럴
    message: z.string(),
  }),
]);

type ApiResponse = z.infer<typeof ApiResponseSchema>;
```

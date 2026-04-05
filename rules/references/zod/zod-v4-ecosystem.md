# Zod v4 생태계 & 마이그레이션

## 생태계 핵심 라이브러리

| 목적 | 라이브러리 | 설명 |
|------|-----------|------|
| API | tRPC | End-to-end 타입 안전 API (Zod 기본 추천) |
| 폼 검증 | React Hook Form + `@hookform/resolvers/zod` | 가장 대중적인 조합 |
| 폼 (Next.js) | Conform | Server Actions와 최적화된 통합 |
| Prisma 연동 | prisma-zod-generator | Prisma 스키마에서 Zod 스키마 자동 생성 |
| OpenAPI | zod-openapi / orval | Zod ↔ OpenAPI 양방향 변환 |
| 환경변수 | zod-config | 다중 소스 환경변수 타입 안전 로딩 |
| 목 데이터 | zod-schema-faker | 스키마에서 Mock 데이터 자동 생성 |
| NestJS | nestjs-zod | DTO, 직렬화, OpenAPI 통합 |
| 에러 메시지 | zod-validation-error | 사용자 친화적 에러 메시지 (v4에서 내장화 진행) |
| ESLint | eslint-plugin-zod-x | Zod 사용 모범 사례 강제 |

---

## v3 → v4 핵심 Breaking Changes

```typescript
// ❌ v3 에러 커스텀 방식 (deprecated)
z.string({ message: "에러" })
z.string({ required_error: "...", invalid_type_error: "..." })
z.string({ errorMap: (issue, ctx) => ({ message: "..." }) })

// ✅ v4 통합 방식
z.string({ error: "에러" })
z.string({ error: (issue) => issue.input === undefined ? "필수" : "문자열이어야 함" })

// ❌ v3: .refine() 후 .min() 체인 불가
z.string().refine(v => v.includes("@")).min(5) // 오류

// ✅ v4: refinement가 스키마 내부에 저장되어 자유롭게 체인 가능
z.string().refine(v => v.includes("@")).min(5) // 정상 동작
```

---

## Standard Schema 지원

---

## 권장 사항 요약

| 권장 사항 | 설명 |
|-----------|------|
| 스키마 폴더 분리 | `schemas/` 폴더에 모아서 관리 — 컴포넌트/라우터 파일 안에 직접 정의 금지 |
| 타입 파생 | `z.infer<>`로 타입 파생 — 별도 interface/type 수동 정의 최소화 |
| safeParse 기본 사용 | try-catch 대신 discriminated union으로 에러 처리 |
| 폼 에러 처리 | `z.flattenError()` — 폼 필드 에러 매핑에 활용 |
| 환경변수 검증 | 앱 시작 시 즉시 검증 — `env.schema.ts` 패턴 필수 |
| 스키마 재사용 | `.pick()`, `.omit()`, `.partial()`, `.extend()`로 파생 스키마 생성 |
| 번들 크기 최적화 | 번들 크기가 중요한 경우 `zod/mini` 사용 고려 (1.88kb) |
| JSON Schema 변환 | `.meta()` + `z.toJSONSchema()` 활용 (v4 내장) |

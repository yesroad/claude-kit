---
paths:
  - "app/**/*.{ts,tsx}"
  - "src/app/**/*.{ts,tsx}"
---

# Next.js App Router 규칙

> App Router (Next.js 13+) 프로젝트 전용 규칙
> Pages Router 프로젝트에서는 적용하지 않는다

---

## 적용 조건 확인

`app/`(또는 `src/app/`) 디렉토리가 있고 `package.json`의 Next.js가 13+ 인 프로젝트에 적용한다.

---

## Suspense 경계 전략

데이터 로딩이 필요한 컴포넌트를 Suspense로 격리하면 나머지 UI를 먼저 렌더링할 수 있다.

최상위에서 `await fetchSlowData()`하면 전체 UI가 블로킹된다. await를 하위 컴포넌트로 내리고 Suspense로 격리한다.

```typescript
export default function Page() {
  return (
    <main>
      <Header /> {/* 즉시 렌더링 */}
      <Suspense fallback={<Skeleton />}>
        <SlowDataComponent /> {/* 내부에서 await fetchSlowData() → 독립 로딩 */}
      </Suspense>
    </main>
  );
}
```

---

## Server Actions 인증

Server Action은 클라이언트에서 직접 호출 가능하므로 **각 Action 내부에서** 인증을 반드시 검증한다.
미들웨어나 레이아웃의 인증 처리에 의존하지 않는다.

인증 없이 바로 처리하면 누구나 호출 가능하다. Action 내부에서 인증 + 권한을 직접 검증한다.

```typescript
'use server';
export async function updateUserProfile(data: FormData) {
  const session = await getServerSession();
  if (!session?.user) throw new Error('인증이 필요합니다');
  if (!canUpdateProfile(session.user, data)) throw new Error('권한이 없습니다');
  await db.user.update({ ... });
}
```

---

## RSC Props 직렬화 최소화

RSC(서버 컴포넌트)에서 클라이언트 컴포넌트로 전달하는 props는 직렬화 비용이 발생한다.
클라이언트에서 사용하지 않는 필드는 전달하지 않는다.

```typescript
export async function UserCard() {
  const user = await db.user.findFirst(); // id, name, email, password, internalMeta, ...

  // ❌ <UserCardClient user={user} />  → 전체 객체 전달, 민감 정보 노출 가능성
  // ✅ 필요한 필드만 선택해서 전달
  return <UserCardClient userId={user.id} displayName={user.name} />;
}
```

---

## Component Composition으로 병렬 데이터 패칭

한 컴포넌트에서 연속 `await`하면 순차 실행(A + B)된다. 독립적인 데이터 패칭은 **컴포넌트 분리**로 병렬 실행(max(A, B))한다.

```typescript
export default function Page() {
  return (
    <Layout>
      <Suspense fallback={<ProfileSkeleton />}>
        <UserProfile />  {/* 독립적으로 fetchUserProfile 실행 */}
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <UserPosts />    {/* 독립적으로 fetchUserPosts 실행 */}
      </Suspense>
    </Layout>
  );
}
```

---

## React.cache()로 요청 중복 제거

동일한 요청 내에서 같은 데이터를 여러 컴포넌트가 필요로 할 때 `React.cache()`로 중복을 제거한다.

```typescript
// data/user.ts - cache로 감싸면 동일 요청 내 중복 호출 시 캐시 반환
import { cache } from 'react';

export const getUser = cache(async (userId: string) => {
  return await db.user.findUnique({ where: { id: userId } });
});

// 여러 컴포넌트가 같은 userId로 getUser()를 호출해도 DB는 1회만 조회된다.
// (첫 호출만 DB, 이후는 캐시 반환 - props 드릴링 없이 중복 제거)
```

---

## after()로 비차단 사이드 이펙트

로깅, 분석, 알림 등 응답에 영향을 주지 않는 작업은 `after()`로 응답 후에 실행한다.

```typescript
import { after } from 'next/server';

export async function POST(req: Request) {
  const data = await req.json();
  await db.event.create({ data }); // 핵심 처리

  // ❌ await sendAnalyticsEvent(data) → 로깅 때문에 응답 지연
  // ✅ after()로 응답 후 비동기 실행
  after(async () => {
    await sendAnalyticsEvent(data);
  });

  return Response.json({ success: true }); // 즉시 응답
}
```

---

## `use cache` + PPR 전략 (Next.js 16+)

컴포넌트 단위로 캐시 생명주기를 제어한다. 페이지 단위 SSR/SSG 구분 시대에서 컴포넌트 단위 캐시 전략으로 이동.

```tsx
// ✅ 컴포넌트 레벨 캐싱 + 온디맨드 무효화 + PPR
import { revalidateTag } from 'next/cache'

async function BlogPosts() {
  'use cache'
  cacheLife('hours')   // 1시간 캐시
  cacheTag('posts')    // 태그 기반 무효화
  const posts = await db.post.findMany()
  return <PostList posts={posts} />
}

export async function createPostAction(formData: FormData) {
  'use server'
  await db.post.create({ data: parsed.data })
  revalidateTag('posts')  // 'posts' 태그 캐시 전체 무효화
}

// PPR: 정적 shell + 동적 스트리밍 혼합
export default function Page() {
  return (
    <>
      <StaticHeader />  {/* 빌드 시 prerender */}
      <BlogPosts />     {/* use cache - 정적 shell 포함 */}
      <Suspense fallback={<Skeleton />}>
        <UserPersonalized />  {/* 요청 시 스트리밍 */}
      </Suspense>
    </>
  )
}
```

**cacheLife 프리셋:**
| 프리셋 | 기간 | 용도 |
|--------|------|------|
| `'seconds'` | 0~1분 | 실시간성 필요 |
| `'minutes'` | 1~10분 | 자주 변하는 데이터 |
| `'hours'` | 1시간 | 일반 컨텐츠 |
| `'days'` | 1일 | 정적에 가까운 데이터 |

---

## useEffectEvent - Effect 의존성 버그 해결 (React 19.2+)

Effect 내부에서 항상 최신 값을 참조해야 하지만, 의존성 배열에 포함하면 불필요한 재실행이 발생할 때 사용.

`[roomId, theme]`처럼 theme을 의존성에 넣으면 theme 변경마다 불필요하게 재연결된다. `useEffectEvent`로 분리.

```tsx
import { useEffectEvent } from 'react'

function ChatRoom({ roomId, theme }) {
  const onConnected = useEffectEvent(() => {
    showNotification('연결됨', theme) // 항상 최신 theme 참조
  })

  useEffect(() => {
    const conn = connect(roomId)
    conn.on('connected', onConnected)
    return () => conn.disconnect()
  }, [roomId]) // roomId만 의존성 ✅ (theme 변경 시 재연결 없음)
}
```

---

## `<Activity />` - UI 상태 보존 (React 19.2+)

탭, 모달 등을 숨길 때 상태(입력값, 스크롤 위치 등)를 보존한다. `hidden` 모드에서 effects는 언마운트되지만 상태는 유지.

```tsx
import { Activity } from 'react'

function TabLayout({ activeTab }: { activeTab: string }) {
  return (
    <>
      <Activity mode={activeTab === 'home' ? 'visible' : 'hidden'}>
        <HomePage /> {/* 탭 전환 시 입력값·스크롤 등 상태 유지 */}
      </Activity>
      <Activity mode={activeTab === 'profile' ? 'visible' : 'hidden'}>
        <ProfilePage />
      </Activity>
    </>
  )
}
```

---

## React Compiler - 점진적 도입 (Next.js 15.3.1+)

수동 메모이제이션(`useMemo`, `useCallback`, `React.memo`)을 빌드 타임에 자동화. 단, 전체 코드베이스에 한 번에 적용하지 않는다.

```tsx
// next.config.ts
const nextConfig = { experimental: { reactCompiler: true } }

// 점진적 도입: 컴포넌트 단위 opt-in / opt-out
function SafeComponent() { 'use memo' }            // opt-in
function ProblematicComponent() { 'use no memo' }  // opt-out (문제 시 즉시 제외)
```

**알려진 이슈 (2026.04 기준):** Rules of React 위반 코드는 무한 렌더 루프를 유발할 수 있으므로 기존 프로젝트는 ESLint로 먼저 정리 후 도입한다. `exhaustive-deps` 충돌·`try/finally` 최적화 미지원도 확인.

---

## Next.js 16 비직관적 동작 - 코드 전 확인 필수

> Next.js 16은 LLM 훈련 데이터의 Next.js와 다르다. 아래 항목은 추측으로 작성하지 말고 먼저 확인한다.

- **코드 작성 전 공식 문서 확인:** 새 API·옵션·동작 변경이 의심되면 추측하지 말고 `node_modules/next/dist/docs/` 하위 `.mdx`를 먼저 읽는다.
- **느린 클라이언트 네비게이션:** `<Suspense>`만으로 해결되지 않을 수 있다. API명·설정 방식은 버전마다 다르므로 `instant-navigation.mdx` 가이드를 읽고 적용한다.
- **deprecated 경고:** Next.js 16에서는 경고가 실제 동작 변경으로 이어진다. 무시하지 말고 즉시 수정한다.

```bash
ls node_modules/next/dist/docs/01-app/                                 # 변경사항 확인
cat node_modules/next/dist/docs/01-app/02-guides/instant-navigation.mdx # 네비게이션 가이드
```

---

## 체크리스트

App Router 코드 작성 시:

- [ ] Server Component vs Client Component 구분이 명확하고, Suspense로 느린 컴포넌트를 격리했는가?
- [ ] 독립적인 데이터 패칭은 컴포넌트 분리로 병렬화했는가?
- [ ] Server Action 내부에 인증·권한 검증이 있는가?
- [ ] RSC props에 불필요한 필드가 포함되지 않았는가?
- [ ] 동일 요청 내 반복 호출은 React.cache()로 중복 제거하고, 사이드 이펙트는 after()로 분리했는가?
- [ ] 캐시가 필요한 Server Component에 `use cache` + `cacheLife`/`cacheTag`를 적용했는가?
- [ ] `useEffectEvent`로 해결 가능한 Effect 의존성 버그가 없고, React Compiler 도입 시 문제 컴포넌트에 `"use no memo"`를 적용했는가?
- [ ] Next.js 16 신규 API·`deprecated` 경고는 `node_modules/next/dist/docs/`를 먼저 읽고 처리했는가?

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `react-conventions.md` | 공통 React/Next.js 컨벤션 |
| `state-and-server-state.md` | 상태 관리 경계 |

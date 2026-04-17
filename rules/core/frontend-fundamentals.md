# Frontend Fundamentals — 좋은 코드의 4가지 기준

> 출처: [Frontend Fundamentals](https://frontend-fundamentals.com)
>
> **핵심 목표**: "변경하기 쉬운 코드"
> 4가지 기준은 서로 상충할 수 있다. 예를 들어 응집도를 높이면 가독성이 떨어질 수 있고,
> 중복을 허용하면 결합도는 낮아지지만 응집도가 떨어진다.
> 어떤 기준을 우선할지는 "현재 코드에서 가장 변경이 잦은 부분이 무엇인가"로 판단한다.

---

## 1. 가독성 (Readability)

한 번에 고려하는 맥락이 적고 위에서 아래로 자연스럽게 이어지는 코드.

### 맥락 줄이기

**같이 실행되지 않는 코드 분리**

```tsx
// ❌ viewer/admin 분기가 코드 곳곳에 산재
function SubmitButton({ role }: { role: 'viewer' | 'admin' }) {
  return role === 'admin' ? <AdminButton /> : <ViewerButton />;
}

// ✅ 권한별로 완전 분리 — 각 컴포넌트가 하나의 맥락만 다룸
function ViewerSubmitButton() { ... }
function AdminSubmitButton() { ... }
```

**구현 상세 추상화**

```tsx
// ❌ 페이지가 인증 확인·리다이렉트 로직을 직접 노출
export default function DashboardPage() {
  const session = useSession();
  if (!session) { redirect('/login'); return null; }
  return <Dashboard />;
}

// ✅ AuthGuard로 추상화 — 페이지는 핵심 렌더링만 담당
export default function DashboardPage() {
  return (
    <AuthGuard>
      <Dashboard />
    </AuthGuard>
  );
}
```

**로직 종류에 따라 Hook 쪼개기**

```typescript
// ❌ usePageState()가 모든 파라미터를 한 번에 관리
// → Hook이 커질수록 이해 어렵고, 어느 파라미터가 바뀌어도 모든 구독 컴포넌트 리렌더링
function usePageState() {
  // cardId, statementId, dateFrom, dateTo, statusList 전부 관리
}

// ✅ 파라미터별 독립 Hook으로 분리 → 명확한 이름, 좁은 영향 범위, 성능 향상
function useCardIdQueryParam() { ... }
function useStatementIdQueryParam() { ... }
function useDateRangeQueryParam() { ... }
```

### 이름 붙이기

**복잡한 조건에 이름 붙이기**

```typescript
// ❌ filter, some, &&가 중첩된 익명 조건
const result = items.filter(item =>
  categories.some(c => c.id === item.categoryId) &&
  item.price >= minPrice && item.price <= maxPrice
);

// ✅ 의도를 담은 이름으로 분리 — 이름이 필요한 때: 로직 복잡, 재사용, 단위 테스트 필요
const isSameCategory = (item: Item) => categories.some(c => c.id === item.categoryId);
const isPriceInRange = (item: Item) => item.price >= minPrice && item.price <= maxPrice;
const result = items.filter(item => isSameCategory(item) && isPriceInRange(item));
```

**매직 넘버에 이름 붙이기**

```typescript
// ❌ 300이 애니메이션 대기인지, API 지연인지, 테스트 코드인지 모름
await delay(300);

// ✅ 의도 명확화
const ANIMATION_DELAY_MS = 300;
await delay(ANIMATION_DELAY_MS);
```

### 위에서 아래로 읽히게 하기

**시점 이동 줄이기** — 버튼 비활성화 이유를 알기 위해 3단계를 거슬러 올라가는 구조 지양

```typescript
// ✅ 인라인 객체로 조건을 한눈에
const canInvite = { viewer: false, admin: true }[role] ?? false;
```

**삼항 연산자 단순하게 하기**

```typescript
// ❌ 중첩 삼항 — 구조 파악 어려움
const label = A && B ? "BOTH" : A || B ? (A ? "A" : "B") : "NONE";

// ✅ IIFE + if문으로 순차 기술
const label = (() => {
  if (A && B) return "BOTH";
  if (A) return "A";
  if (B) return "B";
  return "NONE";
})();
```

**왼쪽에서 오른쪽으로 읽히게 하기**

```typescript
// ❌ a를 두 번 확인해야 인지 부담 증가
a >= b && a <= c

// ✅ 수학 부등식 b ≤ a ≤ c 처럼 자연스럽게
b <= a && a <= c
```

---

## 2. 예측 가능성 (Predictability)

함수/컴포넌트의 동작을 이름, 파라미터, 반환 값만 보고도 예측할 수 있는 정도.

### 이름 겹치지 않게 관리하기

```typescript
// ❌ 외부 라이브러리와 같은 이름 — 내부에 토큰 주입 로직이 숨겨져 있어도 구분 불가
import http from './http';

// ✅ 기능을 명시하는 고유한 이름 → 이름만 보고 인증 요청임을 파악 가능
import httpService from './httpService';
httpService.getWithAuth(url);
```

**규칙**: 커스텀 모듈이 외부 라이브러리(axios, http, fetch 등)와 동일한 이름을 사용하면 안 된다.

### 같은 종류의 함수는 반환 타입 통일하기

```typescript
// ❌ API 관련 Hook 반환 타입 불일치 → 사용법을 매번 확인해야 함
function useUser() { return useQuery(...) }           // Query 객체
function useServerTime() { return useQuery(...).data } // data만

// ✅ API 관련 Hook은 일관되게 Query 객체 반환
function useUser() { return useQuery(...) }
function useServerTime() { return useQuery(...) }

// ❌ 유효성 검사 함수 반환 타입 불일치 → 조건문 오동작 위험
function checkIsNameValid(name: string): boolean { ... }
function checkIsAgeValid(age: number): { ok: boolean; reason?: string } { ... }

// ✅ Discriminated Union으로 통일
type ValidationResult = { ok: true } | { ok: false; reason: string };
function checkIsNameValid(name: string): ValidationResult { ... }
function checkIsAgeValid(age: number): ValidationResult { ... }
```

### 숨은 로직 드러내기

```typescript
// ❌ fetchBalance 내부에서 암묵적으로 로깅 실행 → 원치 않는 곳에서 사이드이펙트 발생
async function fetchBalance(userId: string) {
  const balance = await api.get(`/balance/${userId}`);
  logging.log("balance_fetched"); // 이름으로 예측 불가능한 숨은 동작
  return balance;
}

// ✅ 함수가 이름 그대로만 동작 — 로깅은 호출부에서 명시적으로
async function fetchBalance(userId: string) {
  return api.get(`/balance/${userId}`);
}
const balance = await fetchBalance(userId);
logging.log("balance_fetched");
```

---

## 3. 응집도 (Cohesion)

수정되어야 할 코드가 항상 함께 수정되는 정도.
응집도를 높이면 추상화가 필요해 가독성이 다소 떨어질 수 있으므로, 위험도에 따라 우선순위를 조절한다.

### 함께 수정되는 파일을 같은 디렉토리에 두기

```
// ❌ 종류별 분류만 — 의존 관계 파악 어렵고 기능 삭제 시 관련 파일이 남겨짐
src/
├── components/  (모든 컴포넌트)
├── hooks/       (모든 훅)
└── constants/   (모든 상수)

// ✅ 도메인별 하위 디렉토리 — 비정상적인 cross-domain import가 눈에 띔
src/
├── components/  (전체 공유)
├── hooks/       (전체 공유)
└── domains/
    ├── payment/
    │   ├── components/
    │   └── hooks/
    └── order/
        ├── components/
        └── hooks/
```

> `nextjs-scaffold` 스킬의 App Router 폴더 구조 패턴과 동일 원칙.

### 매직 넘버 없애기 (응집도 관점)

매직 넘버는 "함께 수정되어야 할 코드가 흩어져 있다"는 신호.
애니메이션 변경 시 `delay` 값을 함께 수정하지 않으면 서비스가 조용히 깨진다.

```typescript
// ✅ 상수화로 응집 — 상수 변경 시 사용처가 자동으로 따라옴
const ANIMATION_DELAY_MS = 300;
await delay(ANIMATION_DELAY_MS);
```

### 폼의 응집도 선택하기

| 방식 | 특징 | 적합한 상황 |
|------|------|------------|
| **필드 단위 응집** | 각 필드가 독립적인 검증 로직 보유 | 필드별 비동기 검증, 재사용 필요, 독립적 유지보수 |
| **폼 전체 단위 응집** | 모든 검증을 Zod 스키마 한 곳에서 관리 | 결제·배송처럼 모든 필드가 하나의 비즈니스 로직, 필드 간 의존성 있을 때 |

---

## 4. 결합도 (Coupling)

코드를 수정했을 때의 영향 범위. 결합도가 낮을수록 안전하게 변경 가능.

### 책임을 하나씩 관리하기

```typescript
// ❌ usePageState()가 모든 쿼리 파라미터 담당
// → 수정 시 이 Hook을 사용하는 모든 컴포넌트에 영향
function usePageState() { /* cardId, statementId, dateFrom... */ }

// ✅ 파라미터별 단일 책임 Hook → 수정 영향 범위 최소화
function useCardIdQueryParam() { ... }
function useStatementIdQueryParam() { ... }
```

### 중복 코드 허용하기

"중복 코드는 항상 나쁘다"는 통념을 재검토한다.
여러 페이지에서 비슷해 보이는 로직을 무조건 공통화하면, 페이지마다 로깅·UI·동작이 달라질 때 공통 Hook이 복잡한 파라미터를 받게 되고 수정 시 모든 사용처를 테스트해야 한다.

| 공통화 필요 | 중복 허용 (공통화 금지) |
|-----------|----------------------|
| 로깅·동작·UI가 동일하고 앞으로도 동일할 것이 확실 | 페이지/컴포넌트마다 동작이 달라질 여지가 있음 |
| 비즈니스 정책이 완전히 동일 | 단지 코드가 유사해 보일 때 |

> `coding-standards.md`의 DRY와 차이: DRY는 "중복 제거"가 목표지만, 결합도 관점에서는
> 무분별한 공통화가 더 위험할 수 있다. 판단 기준은 **"앞으로도 동일하게 변경될 것인가"**.

### Props Drilling 해소하기

Props Drilling은 부모-자식 간 불필요한 결합의 신호. prop 이름이 바뀌면 중간 컴포넌트 전체를 수정해야 한다.

```tsx
// ✅ 1순위: 조합(Composition) 패턴 — children으로 직접 구성
function Layout({ children }: { children: React.ReactNode }) {
  return <div className="layout">{children}</div>;
}
// userId를 Layout을 통해 drilling하지 않아도 됨
<Layout><UserProfile userId={userId} /></Layout>

// ✅ 2순위: Context API — 트리가 깊고 조합으로 해결 안 될 때만 (최후 수단)
const UserContext = createContext<User | null>(null);
```

**주의**: 모든 prop을 Context API로 옮기지 않는다. 컴포넌트의 역할과 의도를 담은 props는 명시적으로 유지하는 것이 오히려 좋다.

---

## 4가지 기준 간 트레이드오프

| 높이면 | 낮아질 수 있음 | 예시 |
|--------|--------------|------|
| 응집도 | 가독성 | 도메인 폴더 안에 파일이 많아지면 탐색 어려워짐 |
| 응집도 | 결합도 (때로는 증가) | 관련 파일을 한 곳에 모으면 내부 의존성이 생김 |
| 중복 허용 (결합도 낮춤) | 응집도 | 같은 로직이 여러 곳에 흩어짐 |

**판단 원칙**: 지금 가장 자주 변경되는 부분의 기준을 우선한다.

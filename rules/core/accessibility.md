# 접근성(Accessibility) 규칙

> WCAG 2.1 AA 기준 — React/Next.js 코드에 적용되는 공통 접근성 규칙

---

## 핵심 원칙

| 원칙 | 설명 | 기준 |
|------|------|------|
| **지각 가능** | 색상 대비, 텍스트 대안 | 대비 4.5:1 이상 |
| **운용 가능** | 키보드 접근, 터치 타깃 | 최소 44×44px |
| **이해 가능** | 오류 안내, 명확한 라벨 | 오류 시 텍스트 설명 |
| **견고성** | 보조기술 호환 | ARIA 올바른 사용 |

---

## 필수 패턴

### 색상 대비

```tsx
// ✅ 필수: 텍스트는 배경 대비 4.5:1 이상
// 큰 텍스트(18px+ 또는 14px+ 볼드)는 3:1 이상
className="text-gray-900 bg-white"  // 대비 21:1

// ❌ 금지: 대비 미달
className="text-gray-400 bg-white"  // 대비 ~2.5:1
```

### 버튼/인터랙티브 요소

```tsx
// ✅ 필수: aria-label (텍스트 없는 아이콘 버튼)
<button aria-label="장바구니에 추가">
  <CartIcon />
</button>

// ✅ 필수: 터치 타깃 최소 크기
className="min-h-[44px] min-w-[44px]"

// ✅ 필수: 포커스 인디케이터
className="focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-500"
```

### 폼 요소

```tsx
// ✅ 필수: label과 input 연결
<label htmlFor="email">이메일</label>
<input id="email" type="email" aria-required="true" />

// ✅ 필수: 오류 메시지 연결
<input
  id="email"
  aria-invalid={!!error}
  aria-describedby={error ? "email-error" : undefined}
/>
{error && <p id="email-error" role="alert">{error}</p>}

// ❌ 금지: placeholder만 사용 (label 대체 불가)
<input placeholder="이메일 입력" />
```

### 이미지

```tsx
// ✅ 필수: 의미 있는 이미지에 alt
<img src="/product.jpg" alt="레드 버튼 다운 재킷 — 앞면" />

// ✅ 필수: 장식용 이미지는 빈 alt
<img src="/decoration.svg" alt="" aria-hidden="true" />

// Next.js Image
<Image src="/product.jpg" alt="상품 이미지" width={300} height={300} />
```

### 모달/다이얼로그

```tsx
// ✅ 필수: role과 aria-modal
<div role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <h2 id="modal-title">확인</h2>
  {/* ... */}
</div>

// ✅ 필수: 포커스 트랩 (모달 안에서 Tab 순환)
// ✅ 필수: ESC로 닫기
// ✅ 필수: 열린 요소로 포커스 복귀
```

### 동적 콘텐츠

```tsx
// ✅ 로딩 상태 알림
<div aria-live="polite" aria-atomic="true">
  {isLoading ? "로딩 중..." : data?.message}
</div>

// ✅ 오류 즉시 알림
<div role="alert">
  {error && `오류: ${error.message}`}
</div>
```

### 애니메이션

```tsx
// ✅ 필수: 움직임 민감 사용자 배려
<motion.div className="motion-reduce:animate-none transition-none">

// CSS
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; }
}
```

---

## 금지 패턴

| 패턴 | 이유 | 대안 |
|------|------|------|
| `<div onClick={...}>` | 키보드 접근 불가 | `<button>` 사용 |
| `<a href="#">` | 의미 없는 링크 | `<button>` 사용 |
| `aria-label` 없는 아이콘 버튼 | 스크린리더 미지원 | `aria-label` 추가 |
| 색상만으로 상태 표현 | 색각 이상자 미지원 | 아이콘/텍스트 병행 |
| `tabIndex={0}` 남발 | 포커스 순서 혼란 | 자연스러운 DOM 순서 |
| `outline: none` 전역 적용 | 포커스 인디케이터 제거 | `focus-visible` 활용 |

---

## Code Reviewer 체크리스트

코드 리뷰 시 아래 항목을 확인한다:

- [ ] 아이콘 버튼에 `aria-label` 있는가?
- [ ] 이미지에 의미 있는 `alt` 텍스트가 있는가?
- [ ] 폼 `input`에 대응하는 `label`이 있는가?
- [ ] 오류 메시지가 `role="alert"` 또는 `aria-describedby`로 연결되었는가?
- [ ] 인터랙티브 요소가 44×44px 이상인가?
- [ ] 포커스 인디케이터가 제거되지 않았는가?
- [ ] `<div onClick>` 대신 시맨틱 요소를 사용했는가?
- [ ] 애니메이션에 `prefers-reduced-motion` 처리가 있는가?

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `coding-standards.md` | 기본 React 패턴 |
| `react-conventions.md` | 컴포넌트 작성 규칙 |
| [WCAG 2.1](https://www.w3.org/TR/WCAG21/) | 공식 기준 |

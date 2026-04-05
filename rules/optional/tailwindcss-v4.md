# TailwindCSS v4 패턴

> `tailwindcss@^4` 의존성이 있는 프로젝트에만 적용한다.
> v3 프로젝트에는 적용하지 않는다 — `tailwind.config.js` 기반 설정이 유효하다.

---

## v3 → v4 핵심 변경사항

| 항목 | v3 | v4 |
|------|----|----|
| 설정 파일 | `tailwind.config.js` | 없음 |
| 설정 위치 | JS 파일 | CSS 파일 (`@theme`) |
| 커스텀 값 | `theme.extend` | `@theme` 블록 |
| 다크모드 | `class` 전략 | CSS `prefers-color-scheme` 또는 `data-` |
| Import | `@tailwind base/components/utilities` | `@import "tailwindcss"` |

---

## 설정 패턴

```css
/* ✅ v4: app/globals.css */
@import "tailwindcss";

@theme {
  --color-brand: oklch(55% 0.2 250);
  --color-brand-foreground: oklch(98% 0.01 250);
  --font-sans: "Pretendard", sans-serif;
  --radius: 0.5rem;
}
```

```css
/* ❌ v3 방식 — v4에서는 동작하지 않음 */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## 플러그인 / 커스텀 유틸리티

```css
/* ✅ v4: CSS에서 직접 정의 */
@utility container {
  margin-inline: auto;
  padding-inline: 1rem;
  max-width: 80rem;
}

/* v3: tailwind.config.js의 plugins 배열에 정의 */
```

---

## 다크모드

```css
/* ✅ v4 기본: prefers-color-scheme 자동 감지 */
@import "tailwindcss";

/* 수동 토글이 필요하면 variant 커스터마이징 */
@variant dark (&:where([data-theme=dark] *));
```

```tsx
/* 클래스 기반 다크모드 적용 예시 */
<html data-theme={theme}>
```

---

## 체크리스트

- [ ] `tailwind.config.js` 대신 CSS `@theme` 블록으로 설정했는가?
- [ ] `@tailwind` 지시문 대신 `@import "tailwindcss"` 사용했는가?
- [ ] 커스텀 유틸리티가 `@utility`로 정의됐는가?
- [ ] 다크모드 전략이 `@variant dark`로 명시됐는가?

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `nextjs-app-router.md` | App Router 전용 규칙 |
| `react-conventions.md` | 공통 컨벤션 |

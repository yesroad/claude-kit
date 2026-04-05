# 정책(Policy) 정의

> 이 문서는 코드베이스 전체에서 반복되는 "기존 정책을 임의로 변경하지 않는다"의 기준을 정의한다.

---

## 정책이란?

**정책(Policy)**은 비즈니스 규칙이 코드로 구현된 것으로, 임의로 변경하면 사용자 경험이나 데이터 무결성에 영향을 주는 로직이다.

단순 텍스트/스타일/변수명과 달리, 정책은 변경 전 **영향 분석과 사용자 확인**이 필수다.

---

## 정책 유형 분류

| 유형 | 설명 | 예시 |
|------|------|------|
| **날짜/기간 계산** | 날짜 범위, 오프셋, 포맷 | `addDate(today, { days: -14 })` |
| **가격/할인 계산** | 할인율, 세금, 반올림 방식 | `Math.floor(price * discountRate)` |
| **상태 전이** | 주문/결제 상태 흐름 | `pending → active → completed` |
| **필터 기본값** | 초기 선택값, 기본 정렬 | `defaultStatus: 'active'` |
| **disabled 조건** | 버튼/입력 비활성화 기준 | `isDisabled={!isValid || isLoading}` |
| **권한 규칙** | 역할별 접근 제어 | `canEdit = role === 'admin'` |

---

## 정책 탐색 명령어

새 기능 구현 전, 유사한 기존 정책을 반드시 탐색한다:

```bash
# 날짜/기간 계산 탐색
rg "(addDate|subDate|startOf|endOf|format)" src/ --type ts

# disabled 조건 탐색
rg "(disabled|isDisabled|readonly)" src/ --type tsx

# 계산/변환 로직 탐색
rg "(calculate|compute|transform)" src/ --type ts

# 기본값 탐색
rg "(defaultValue|initialValue|initialState)" src/ --type ts
```

---

## 정책 변경 프로세스

정책 변경이 필요할 때는 아래 프로세스를 따른다:

```
1. 탐색   → rg 명령어로 기존 구현 위치 확인
2. 확인   → 사용자에게 "이 정책을 변경해도 될까요?" 질문
3. 테스트 → 변경 전 기존 동작을 테스트로 캡처 (회귀 방지)
4. 변경   → 테스트가 통과하도록 정책 수정
```

**참조**: `@unit-test-conventions.md` — 정책 보호 테스트 작성법

---

## 정책이 아닌 것

아래 항목은 정책이 아니므로 사용자 확인 없이 수정 가능하다:

| 항목 | 이유 |
|------|------|
| 텍스트/라벨 | 사용자 경험에 영향 없음 |
| 색상/스타일 | 기능 무관 |
| 변수명/함수명 | 동작 변경 없음 |
| 주석/타입 선언 | 런타임 무관 |
| Import 순서 | 동작 변경 없음 |

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `../../workflows/thinking/model.md` | 기존 로직 탐색 원칙 |
| `unit-test-conventions.md` | 정책 보호 테스트 작성 |
| `@../../commands/done.md` | 완료 시 정책 영향 판단 |

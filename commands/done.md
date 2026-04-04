---
name: done
description: 작업 완료 후 검증 → 테스트 → 커밋 → PR 생성까지 전체 플로우 수행.
---

# /done - 작업 완료 및 PR 생성

구현 완료 후 사용합니다. 검증 → 테스트 → 커밋 → PR 생성 → 정리까지 전체 플로우를 수행합니다.

**참조 규칙**:

- `@../commands/test.md` (전체 테스트 실행)
- `@../skills/test-unit/SKILL.md` (단위 테스트)
- `@../skills/test-integration/SKILL.md` (통합 테스트)
- `@../skills/test-e2e/SKILL.md` (E2E 테스트)
- `@../skills/commit-helper/SKILL.md` (커밋 메시지 생성)
- `@../skills/code-quality/SKILL.md` (린트/포맷/타입 체크)
- `@../instructions/validation/release-readiness-gate.md` (출시 품질 게이트)

## 사용법

```
/done
```

---

## 완료 조건 (빠른 참조)

> 모든 항목이 체크되어야 완료로 간주한다.

- [ ] 변경 내용 분석 완료 (정책 영향 여부 판단 포함)
- [ ] 테스트 전략 결정 및 실행/스킵 완료 (사유 명시)
- [ ] Prettier / ESLint / 타입 체크 통과
- [ ] 출시 품질 게이트 점검 PASS
- [ ] 이번 작업 파일만 선별하여 커밋 생성
- [ ] PR 생성 및 URL 출력

---

## 수행 작업

### 1. 변경 내용 분석

```bash
git status
git diff --staged
git diff
```

**분석 항목:**

- 변경된 파일 목록
- 주요 변경 내용 요약
- 정책 영향 여부 판단 (아래 기준표 참조)

---

### 2. 테스트 실행

> `/test` 커맨드로 단위 → 통합 → E2E 순서로 전체 테스트를 실행한다.

`@../commands/test.md` 참조

#### 실행

```
/test
```

**스킵 조건** (`--skip-test` 옵션):
- UI only 변경 (텍스트·스타일·레이아웃만)
- 스킵 시 사유 명시 필수

**정책 정의 참조**: `@../rules/core/policy-definitions.md`

---

### 4. 코드 검증

`code-quality` 스킬을 실행하여 포맷 → 린트 → 타입 체크를 순서대로 수행한다.

> `@../skills/code-quality/SKILL.md` 규칙에 따라 실행

- Prettier: 자동 포맷 적용
- ESLint: `--fix`로 자동 수정
- 타입 체크: 오류 목록 출력 및 수동 수정 안내

**모두 PASS 후 다음 단계 진행.**

---

### 4-1. 출시 품질 게이트 검토 (필수)

> **출시 게이트 체크리스트**: `@../instructions/validation/release-readiness-gate.md` 참조 (5개 게이트 전체)

**하나라도 FAIL이면 커밋/PR 진행 금지.**

---

### 5. 커밋 생성

#### ⚠️ 중요: 이번 작업에서 수정한 파일만 커밋

```bash
# ❌ 절대 금지
git add .
git add -A

# ✅ 올바른 방법
git add {수정한 파일 경로}
```

**커밋 전 확인:**

```bash
git diff --staged --name-only

# 불필요한 파일 포함 시
git reset HEAD {제외할 파일}
```

**커밋 메시지**: `commit-helper` 스킬로 생성한다.

> `@../skills/commit-helper/SKILL.md` 규칙에 따라 커밋 메시지를 생성하고 커밋한다.

---

### 6. PR 생성 (GitHub)

> PR 제목 형식, 섹션 작성 기준, 금지 사항: `@../rules/core/pr-guide.md`

`pr-guide.md`의 템플릿과 규칙에 따라 PR을 생성한다.

```bash
git push -u origin {현재브랜치}
gh pr create --title "{type}: {제목}" --body "{pr-guide.md 템플릿에 따라 작성}"
```

---

### 7. 정리

작업 중 생성한 임시 파일이나 스크린샷이 있으면 정리한다.

---

### 8. 최종 요약 출력

```markdown
## ✅ 작업 완료

### 검증 결과

- [x] Prettier
- [x] lint
- [x] 타입 체크
- [x] 테스트 {통과/스킵}

### 커밋

- {커밋 해시}: {커밋 메시지}

### PR

- URL: {PR URL}
- 상태: Open

### 다음 단계

1. 코드 리뷰 반영
2. 머지
```

---

## 옵션

| 옵션           | 설명                            | 사용 예시            |
| -------------- | ------------------------------- | -------------------- |
| `--skip-test`  | 테스트 스킵 (정책 무관 확인 후) | `/done --skip-test`  |
| `--force-test` | 정책 무관이어도 테스트 강제실행 | `/done --force-test` |
| `--draft`      | Draft PR로 생성                 | `/done --draft`      |

---

## 완료 조건

- [ ] 변경 내용 분석 완료
- [ ] 테스트 전략 판단됨
- [ ] 테스트 실행/스킵 완료 (사유 명시)
- [ ] Prettier/lint/타입 체크 통과
- [ ] 커밋 생성됨
- [ ] PR 생성됨 (URL 출력)
- [ ] 최종 요약 출력됨

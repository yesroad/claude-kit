---
name: done
description: 작업 완료 후 검증 → 커밋 → PR 생성까지 전체 플로우 수행.
---

# /done - 작업 완료 및 PR 생성

구현 완료 후 사용합니다. 검증 → 커밋 → PR 생성 → 정리까지 전체 플로우를 수행합니다.

**참조 규칙**:

- `@../skills/commit-helper/SKILL.md` (커밋 메시지 생성)
- `@../skills/code-quality/SKILL.md` (린트/포맷/타입 체크)
- `@../skills/test-unit/SKILL.md` (단위 테스트)
- `@../skills/test-integration/SKILL.md` (통합 테스트)
- `@../skills/test-e2e/SKILL.md` (E2E 테스트)
- `@../workflows/quality-gates/release-gate.md` (출시 품질 게이트)

## 사용법

```
/done
/done --no-review   # code-reviewer 스킵 (작은 수정 시)
/done --draft       # Draft PR로 생성
/done --no-test     # 테스트 스킵
/done --skip-e2e    # 단위 + 통합만 실행
/done --unit-only   # 단위 테스트만 실행
```

---

## 완료 조건 (빠른 참조)

> 모든 항목이 체크되어야 완료로 간주한다.

- [ ] 변경 내용 분석 완료 (정책 영향 여부 판단 포함)
- [ ] Prettier / ESLint / 타입 체크 통과
- [ ] 출시 품질 게이트 점검 PASS
- [ ] 이번 작업 파일만 선별하여 커밋 생성
- [ ] PR 생성 및 URL 출력

---

## 진행 상황 추적

실행 시작 시 아래 항목을 TaskCreate로 등록한다. 각 단계 시작 시 `in_progress`, 완료 시 `completed`로 TaskUpdate한다.

- 변경 내용 분석
- 코드 검증 (quality)
- 테스트
- 코드 리뷰
- Safety Gate
- 커밋 생성
- PR 생성
- 정리 & 메모리
- 최종 요약

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

### 2. 코드 검증

`code-quality` 스킬을 실행하여 포맷 → 린트 → 타입 체크를 순서대로 수행한다.

> `@../skills/code-quality/SKILL.md` 규칙에 따라 실행

- Prettier: 자동 포맷 적용
- ESLint: `--fix`로 자동 수정
- 타입 체크: 오류 목록 출력 및 수동 수정 안내

**모두 PASS 후 다음 단계 진행.**

---

### 3. 테스트

명시적 옵션이 없으면 사용자에게 확인:

> "테스트를 실행할까요? (y/n)"

- `y` 또는 옵션 없이 진행 시: test-unit → test-integration → test-e2e 순차 실행
- `n` 응답 시: `⏭️ 테스트 스킵` 출력 후 4단계 진행
- `--no-test` 옵션 시: 묻지 않고 스킵
- `--skip-e2e` 옵션 시: 묻지 않고 unit + integration만 실행
- `--unit-only` 옵션 시: 묻지 않고 unit만 실행

```typescript
// test-unit 스킬 실행
Task(
  subagent_type = "general-purpose",
  prompt = `@../skills/test-unit/SKILL.md 실행`
)

// test-integration 스킬 실행 (--unit-only가 아닌 경우)
Task(
  subagent_type = "general-purpose",
  prompt = `@../skills/test-integration/SKILL.md 실행`
)

// test-e2e 스킬 실행 (--unit-only, --skip-e2e가 아닌 경우)
Task(
  subagent_type = "general-purpose",
  prompt = `@../skills/test-e2e/SKILL.md 실행`
)
```

실패 시: 커밋/PR 진행 금지 — 사용자에게 보고 후 중단.

---

### 4. 코드 리뷰 (`--no-review` 옵션 시 스킵)

`$ARGUMENTS`에 `--no-review`가 없으면 항상 실행한다.

`code-reviewer` 에이전트를 호출하여 변경된 파일을 검토한다.

```typescript
Task(
  subagent_type = "code-reviewer",
  model = "sonnet",
  prompt = `
    git diff로 변경사항 확인 후 코드 리뷰:
    - 보안 취약점
    - 타입 안전성
    - 상태 관리 경계
    - 코드 품질
  `
)
```

**치명적 이슈 발견 시 커밋/PR 진행 금지 — 사용자에게 보고 후 중단.**

---

### 5. 출시 품질 게이트 검토 (필수)

> **출시 게이트 체크리스트**: `@../workflows/quality-gates/release-gate.md` 참조 (5개 게이트 전체)

**하나라도 FAIL이면 커밋/PR 진행 금지.**

---

### Safety Gate (커밋 직전 필수)

> **tsc 또는 lint FAIL 시 커밋 절대 금지 — 에러 복구 루프(필수 0.65) 실행 후 재시도**

커밋 전 아래 항목을 명시적으로 PASS/FAIL 판정:

| 항목 | 체크 방법 | 결과 |
|------|----------|------|
| `tsc --noEmit` | 타입 에러 없음 | PASS / FAIL |
| `lint` | lint 오류 없음 | PASS / FAIL |
| 변경 파일에 `TODO`/`FIXME` 없음 | grep 확인 | PASS / FAIL |
| 변경 파일에 `console.log` 없음 | guard-check.sh 결과 | PASS / FAIL |
| 3단계 테스트 PASS 확인 (스킵 시 SKIP) | 해당 테스트 실행 | PASS / SKIP |

→ 하나라도 FAIL이면 커밋 중단, 에러 복구 루프 진입
→ 전체 PASS이면 커밋 진행

---

### 6. 커밋 생성

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

### 7. PR 생성 (GitHub)

> PR 제목 형식, 섹션 작성 기준, 금지 사항: `@../instructions/git/pr-guide.md`

`pr-guide.md`의 템플릿과 규칙에 따라 PR을 생성한다.

```bash
git push -u origin {현재브랜치}
gh pr create --title "{type}: {제목}" --body "{pr-guide.md 템플릿에 따라 작성}"
```

---

### 8. 정리

작업 중 생성한 임시 파일이나 스크린샷이 있으면 정리한다.

---

### 9. 메모리 저장 (Basic Memory MCP 설치 시)

이번 작업에서 아래 중 하나라도 해당하면 `write_note`로 저장한다:

- 같은 오류가 2회 이상 반복됨
- 특정 파일/패턴에서 예상 밖 동작 발견
- 프로젝트 특이사항 발견

해당 없으면 스킵.

저장 형식:
- 제목: `{프로젝트명}/{YYYY-MM-DD}-{주제}`
- 내용: 현상/원인/해결책

---

### 10. 최종 요약 출력

```markdown
## ✅ 작업 완료

### 검증 결과

- [x] Prettier
- [x] lint
- [x] 타입 체크
- [x] 테스트 (단위/통합/E2E — 스킵 시 표기)
- [x] 코드 리뷰 (--no-review 시 스킵)

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

| 옵션          | 설명                              | 사용 예시             |
| ------------- | --------------------------------- | --------------------- |
| `--no-review` | code-reviewer 스킵 (작은 수정 시) | `/done --no-review`   |
| `--draft`     | Draft PR로 생성                   | `/done --draft`       |
| `--no-test`   | 테스트 전체 스킵                  | `/done --no-test`     |
| `--skip-e2e`  | 단위 + 통합만 실행                | `/done --skip-e2e`    |
| `--unit-only` | 단위 테스트만 실행                | `/done --unit-only`   |

---

## 완료 조건

- [ ] 변경 내용 분석 완료
- [ ] Prettier/lint/타입 체크 통과
- [ ] 테스트 통과 (스킵 시 표기)
- [ ] 코드 리뷰 완료 (`--no-review` 시 스킵)
- [ ] 커밋 생성됨
- [ ] PR 생성됨 (URL 출력)
- [ ] 최종 요약 출력됨

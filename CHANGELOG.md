# Changelog

이 프로젝트는 [Semantic Versioning](https://semver.org/lang/ko/)을 따릅니다.

---

## [1.3.0] - 2026-06-06

### Changed

- **rules 로딩 방식 전면 개편**: `.claude/rules/`가 Claude Code의 `paths` frontmatter 자동발견으로 **조건부 로드**되도록 전환. 매 세션 전량 로드(약 2,800줄+) → 핵심 철학 rule만 항상 로드 + 나머지는 일치 파일 작업 시 로드.
  - `commands/setup.md`: rules 전체 복사(`cp -r`) → **선택 복사**(`FRONTEND`/`STYLING`/`ZOD`/`TS` 플래그로 미해당 rule prune). 생성 CLAUDE.md의 rule `@참조` 제거 — `workflows/` 가이드(model·required-patterns·anti-patterns·pr-guide)만 `@참조`
  - `skills/directive-generator/SKILL.md`: rule을 `@참조`하지 않고 `paths` 자동발견에 위임하도록 명시(이중 로드 방지)
  - `commands/update-cc-kit.md`: `rules/optional`·`rules/references` 신규 파일 자동 복사 제외(선택 상태 존중)
- **rule 전반 `paths` frontmatter 부여**: 조건부 rule(nextjs-app-router, unit-test-conventions, state-and-server-state, accessibility, emotion, tailwindcss-v4, validation-patterns, references 전체)에 `paths` 추가. 항상-로드 철학 rule(policies, coding-standards, frontend-fundamentals, react-conventions, react-hooks-patterns)은 생략
- **rule 분량 축소(trim)**: 중복·장황한 코드 예시 정리(규칙·표·예시 1개씩은 보존). coding-standards 312→238, react-conventions 319→243, frontend-fundamentals 294→251, nextjs-app-router 397→284, state-and-server-state 411→308, validation-patterns 234→196, unit-test-conventions 222→191
- **`commands/setup.md` Q7(MCP)**: context7·chrome-devtools 옵션 추가, 진행 상황 추적(TaskCreate) 블록 제거

### Added

- **`rules/references/typescript/ts-type-patterns-basics.md`**·**`ts-type-patterns-advanced.md`**: 기존 `ts-type-patterns.md`(333줄)를 기초/심화로 분할

### Removed

- **`rules/references/typescript/ts-type-patterns.md`**: 위 2개로 분할되며 제거. coding-standards와 중복되던 "현업 실수" 섹션 삭제

> 일부 rule(coding-standards 238, react-conventions 243, frontend-fundamentals 251, nextjs-app-router 284, state-and-server-state 308)은 200줄 권장을 초과한다. 규칙·표·예시 보존이 우선이며, nextjs-app-router·state-and-server-state는 `paths`로 조건부 로드된다.

---

## [1.2.0] - 2026-05-21

### Changed

- **`/start` 커맨드**: ExitPlanMode 승인 후 즉시 구현 단계 자동 진입 — 계획 대비 검증·재작업 루프·완료 안내 포함 (기존 `/work` 역할 통합)
- **`/setup` 커맨드**: Stage 4(알림 설정) `setup-notifier.md` 직접 참조 방식으로 명확화, Stage 5(CLAUDE.md 생성) `directive-generator/SKILL.md` 직접 참조 방식으로 명확화, python3 에러 메시지 수정, quick_ref 예시 갱신
- **워크플로우**: `/start` → `/done` 2단계 사이클로 변경
- **Commands 수**: 8개 → 7개

### Removed

- **`/work` 커맨드**: `/start` 승인 후 자동 구현 진입으로 대체됨

---

## [1.1.1] - 2026-04-17

### Added

- **`rules/core/frontend-fundamentals.md`**: Frontend Fundamentals 4가지 설계 원칙 — 가독성/예측 가능성/응집도/결합도, 트레이드오프 포함

### Changed

- **`rules/core/coding-standards.md`**: Code Smell 중복 코드 항목에 결합도 관점 단서 추가 (`frontend-fundamentals.md` 참조 연결)
- **`skills/refactor/SKILL.md`**: 중복 코드 리팩토링 판단 기준 보정 — "동작·UI가 완전히 동일할 때"만 공통화 조건 명시
- **`skills/code-level-review/SKILL.md`**: 모드 A에 FF 설계 원칙 점검 항목(예측가능성·결합도) 추가

---

## [1.1.0] - 2026-04-05

### Added

- **`/work` 커맨드 신규**: 계획 기반 구현 + 계획 대비 검증 + FAIL 시 재작업 루프
- **`plansDirectory` 설정**: `/setup` 시 settings.json에 추가, Plan Mode 계획 파일을 프로젝트 로컬(`.claude/plans/`)에 저장

### Changed

- **`/start` 커맨드**: Plan Mode 자동 진입(`EnterPlanMode`), 계획만 수행하고 구현은 `/work`로 분리
- **워크플로우**: `/start` → `/work` → `/done` 3단계 사이클로 변경
- **Commands 수**: 7개 → 8개

---

## [1.0.0] - 2026-04-05

### 포함 항목

- **Agents** (5개): explorer, code-reviewer, nextjs-reviewer, lint-fixer, git-operator
- **Skills** (15개): bug-fix, code-quality, commit-helper, component-creator, directive-generator, docs-creator, migration-helper, nextjs-scaffold, code-level-review, pr-responder, refactor, test-unit, test-integration, test-e2e, web-design
- **Commands** (7개): /setup, /start, /done, /commit, /test, /setup-notifier, /update-cc-kit
- **Rules**: core 8개 + optional 2개 + references 8개
- **Workflows**: coordination(4), quality-gates(3), thinking(1), git(1)
- **Hooks**: guard-check.sh (8패턴), notify.sh, hooks.json
- **Scripts**: verify-install.sh

### 주요 설계

- CLAUDE.md 25줄 유지 (워크플로우 원칙 준수)
- `/done` 파이프라인: quality → test(확인) → review → Safety Gate → commit → PR
- TaskCreate 진행 상황 추적: 커맨드 6개 + 독립 스킬 6개
- guard-check.sh 8패턴: any, @ts-ignore, 자격증명, useState+fetch, console.log, eslint-disable, as any, useEffect([])
- 에이전트 모델 분리: haiku(탐색·git·lint) / sonnet(리뷰) / opus(Plan)
- 스킬 트리거 기반 on-demand 컨텍스트 로딩

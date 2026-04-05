# Changelog

이 프로젝트는 [Semantic Versioning](https://semver.org/lang/ko/)을 따릅니다.

---

## [1.1.0] - 2026-04-05

### 추가

- `agents/nextjs-reviewer.md` — Next.js 16 + React 19.2 레벨 진단 전문가 (주니어/미들/시니어)
- `commands/test.md` — `/test` 커맨드: 단위 → 통합 → E2E 순차 실행
- `commands/update-cc-kit.md` — `/update-cc-kit` 커맨드: manifest 기반 플러그인 파일 최신화
- `skills/web-design/references/ux-patterns.md` — UX 패턴 참조 문서
- `skills/nextjs-coding-convention/references/` — 3개 참조 파일 (axios-react-query, code-examples, level-rubric)
- Basic Memory MCP 3-트리거 패턴 정의: `/start` 읽기 → 에러 복구 읽기 → `/done` 쓰기

### 변경

- `rules/` 하위 `references/` 경로 재구성: `references/typescript/`, `references/zod/` → `rules/references/typescript/`, `rules/references/zod/`
- `rules/core/thinking-model.md` → `instructions/workflow-patterns/thinking-model.md`로 이동
- `rules/core/pr-guide.md` → `instructions/git/pr-guide.md`로 이동
- `/setup` 인터뷰 Q6 추가 (검증 라이브러리 Zod), MCP 서버 선택이 Q6 → Q7로 변경
- `required-behaviors.md` 필수 0.65에 Basic Memory 유사 에러 검색 단계 추가
- `required-behaviors.md` 필수 0.7을 3-트리거 표로 재구성 (읽기/읽기/쓰기)
- `commands/start.md`에 Basic Memory 조회 섹션 추가 (조건부)
- `commands/done.md` 8단계에 Basic Memory 저장 단계 추가

### 제거

- `vue-conventions.md` — Vue 미사용으로 제거

---

## [1.0.2] - 2026-03-22

### 변경

- 프로젝트명 `claude-kit` → `cc-kit` 전체 리네임

### 추가

- `.mcp.json` shadcn MCP 서버 추가 (`npx shadcn@latest mcp`, API 키 불필요)
- `setup.md` Q6 인터뷰에 shadcn 옵션 추가 (번호 5, SELECTED_MCP 키: `shadcn`)

---

## [1.0.1] - 2026-03-21

### 수정

- `done.md` 출시 품질 게이트 항목 수 불일치 수정 (SSOT 정합성)
- `commit.md` Co-Authored-By 모델명 하드코딩 제거
- `.claude/commands/setup.md` 누락 파일 추가
- `.claude/hooks/hooks.json` 누락 파일 추가
- `README.md` 디렉토리 구조 빈 줄 제거

### 개선

- `CLAUDE.md` 네임스페이스 맥락 주석 추가
- `coordination-guide.md` Agent Teams 플랫폼 주의사항 추가 및 TODO 내부 노트 제거
- `unit-test-conventions.md` vitest 지원 추가
- `setup.md` Q1 "기타" 옵션 구체화 및 python3 검증 추가
- `release-readiness-gate.md` 각 게이트에 PASS/FAIL 예시 추가

### 추가

- `vue-conventions.md` Vue 3 + Composition API 컨벤션 스텁
- `error-recovery.md` 워크플로우 에러 복구 가이드
- `CHANGELOG.md` 변경 이력 관리

---

## [1.0.0] - 초기 릴리스

### 포함 항목

- Rules: 10개 핵심 코딩 규칙 (thinking-model, coding-standards 등)
- Agents: 5개 전문화 서브에이전트 (explore, code-reviewer 등)
- Skills: 12개 자동 트리거 스킬 (commit-helper, bug-fix 등)
- Commands: 6개 슬래시 커맨드 (/setup, /start, /done, /commit, /quality, /setup-notifier)
- Instructions: 멀티에이전트 협업 + 검증 규칙 + 워크플로우 패턴
- MCP 서버 템플릿: Figma, Supabase, Playwright, Atlassian

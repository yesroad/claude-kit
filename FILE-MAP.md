# claude-front 파일 맵

> 버전 1.0.0. 소스 한 벌(`~/.claude-front`)을 각 프로젝트의 `.claude/`가 심링크한다.
> rule은 `paths` frontmatter로 관련 파일 작업 시에만 로드된다.

---

## rules/ — 코딩 규칙

- **core/ (9, 대부분 항상 로드)**
  policies · coding-standards · frontend-fundamentals · react-conventions · react-hooks-patterns · accessibility · nextjs-app-router · state-and-server-state · unit-test-conventions
- **optional/ (3, 스택에 맞는 것만 심링크)**
  emotion · tailwindcss-v4 · validation-patterns
- **references/ (9)**
  typescript 6종 · zod 3종

## agents/ — 서브에이전트 (4)
explorer(탐색) · code-reviewer(리뷰) · lint-fixer(린트) · git-operator(git)

## skills/ — 자동 트리거 스킬 (15)
bug-fix · refactor · component-creator · web-design · nextjs-scaffold · test-unit · test-integration · test-e2e · code-level-review · code-quality · migration-helper · commit-helper · pr-responder · docs-creator · directive-generator

## commands/ — 슬래시 커맨드 (6)
start(작업 시작) · done(완료→PR) · commit · test · setup(셋업) · setup-notifier(알림)

## workflows/ — 작업 방식 가이드 (10)
coordination/(roster · guide · evaluation · done-process) · quality-gates/(required-patterns · anti-patterns · release-gate) · thinking/model · git/pr-guide · README

## hooks/ (5) + scripts/ (2)
- hooks: notify · guard-check(품질) · guard-pretool(위험 Bash 차단) · auto-pull(세션 시작 시 git pull) · hooks.json
- scripts: install-notifier · verify-install(심링크·설치 검증)

## .claude-plugin/ — 메타데이터 (2)
plugin.json · marketplace.json (version 1.0.0)

---

총 **87개** 파일 (`git ls-files` 기준). `.claude/`는 위 소스를 가리키는 심링크라 별도 카운트 없음.

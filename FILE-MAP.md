# claude-front 파일 맵

> 버전 1.0.0. 소스 한 벌(`~/.claude-front`)을 각 프로젝트의 `.claude/`가 심링크한다.
> rule은 `paths` frontmatter로 관련 파일 작업 시에만 로드된다.

---

## rules/ - 코딩 규칙

### core/ (대부분 항상 로드)

| 파일                     | 설명                                                |
| ------------------------ | --------------------------------------------------- |
| `policies`               | 정책(날짜·가격·상태전이 등) 변경 4단계 프로세스      |
| `coding-standards`       | TypeScript 표준 (KISS/DRY, 네이밍, 불변성, 에러 처리) |
| `frontend-fundamentals`  | FF 4원칙 (가독성·예측가능성·응집도·결합도)           |
| `react-conventions`      | React/Next.js 컨벤션 (import 순서·Props·명명)        |
| `react-hooks-patterns`   | Hook 성능 패턴 (useMemo·useState·useRef)             |
| `accessibility`          | WCAG 2.1 AA (색 대비·터치 타깃·aria)                 |
| `nextjs-app-router`      | App Router 전용 (Suspense·Server Actions·RSC)        |
| `state-and-server-state` | 상태 경계 (TanStack Query·Zustand·폼·로컬)           |
| `unit-test-conventions`  | 순수 함수 단위 테스트 규칙 (정상·경계·에러·정책)     |

### optional/ (스택에 맞는 것만 심링크)

| 파일                  | 설명                  |
| --------------------- | --------------------- |
| `emotion`             | Emotion 스타일링 규칙 |
| `tailwindcss-v4`      | Tailwind v4 규칙      |
| `validation-patterns` | Zod 검증 패턴         |

### references/

| 그룹       | 파일                                                                                       |
| ---------- | ------------------------------------------------------------------------------------------ |
| typescript | ts-react-nextjs · ts-type-patterns-basics · ts-type-patterns-advanced · ts-error-handling · ts-naming-and-structure · ts-tooling-and-stack |
| zod        | zod-v4-ecosystem · zod-v4-project-patterns · zod-v4-real-world                              |

---

## agents/ - 서브에이전트

| 에이전트        | 모델·effort   | 설명                  |
| --------------- | ------------- | --------------------- |
| `explorer`      | haiku · low   | 코드베이스 탐색       |
| `code-reviewer` | sonnet · high | git diff 기반 리뷰    |
| `lint-fixer`    | haiku · low   | 린트/타입 오류 수정   |
| `git-operator`  | haiku · low   | 커밋·브랜치 관리      |

---

## skills/ - 자동 트리거 스킬

| 스킬                  | 설명                                  |
| --------------------- | ------------------------------------- |
| `bug-fix`             | 버그 분석·수정 (2-3 해결 옵션 제시)   |
| `refactor`            | 정책 보호 리팩토링                    |
| `component-creator`   | 단일 컴포넌트·훅 생성                  |
| `web-design`          | Next.js + Tailwind UI 구현            |
| `nextjs-scaffold`     | 도메인 전체(service+query+view) 스캐폴딩 |
| `test-unit`           | 컴포넌트·함수·훅 단위 테스트           |
| `test-integration`    | Route Handler·Server Action 통합 테스트 |
| `test-e2e`            | Playwright E2E 테스트                  |
| `code-level-review`   | 코드 레벨 진단 (주니어/미들/시니어)   |
| `code-quality`        | 린트·포맷·타입체크                     |
| `migration-helper`    | 라이브러리 버전 마이그레이션          |
| `commit-helper`       | 커밋 메시지 생성                      |
| `pr-responder`        | PR 리뷰 코멘트 대응                    |
| `docs-creator`        | AI 코딩 도구 문서 작성                |
| `directive-generator` | CLAUDE.md·AGENTS.md 생성              |

---

## commands/ - 슬래시 커맨드

| 커맨드            | 설명                          |
| ----------------- | ----------------------------- |
| `/start`          | 작업 시작 (분석→계획→구현·검증) |
| `/done`           | 작업 완료 (검증→커밋→PR)       |
| `/commit`         | git 플로우 자동화             |
| `/test`           | 단위→통합→E2E 테스트           |
| `/setup`          | 프로젝트 셋업 (1회)           |
| `/setup-notifier` | macOS 알림 환경 설정          |

---

## workflows/ - 작업 방식 가이드

| 그룹            | 파일                                          | 설명                          |
| --------------- | --------------------------------------------- | ----------------------------- |
| `coordination/` | roster · guide · evaluation · done-process    | 에이전트 카탈로그·실행 패턴·평가 |
| `quality-gates/`| required-patterns · anti-patterns · release-gate | 필수 행동·금지 패턴·출시 게이트 |
| `thinking/`     | model                                         | 사고 모델·복잡도 판단         |
| `git/`          | pr-guide                                      | PR 작성 가이드                |
| (root)          | README                                        | workflows 인덱스              |

---

## hooks/ + scripts/

| 파일                  | 설명                                  |
| --------------------- | ------------------------------------- |
| `notify.sh`           | 크로스 플랫폼 완료 알림               |
| `guard-check.sh`      | 코드 품질 린트 (PostToolUse, 경고)    |
| `guard-pretool.sh`    | 위험 Bash 차단 (PreToolUse, `exit 2`) |
| `auto-pull.sh`        | 세션 시작 시 소스 git pull (throttle 12h) |
| `hooks.json`          | 훅 이벤트 설정                        |
| `install-notifier.sh` | 알림 의존성 설치                      |
| `verify-install.sh`   | 심링크·설치 검증                      |

---

## .claude-plugin/ - 메타데이터

| 파일               | 설명                              |
| ------------------ | --------------------------------- |
| `plugin.json`      | 플러그인 메타 (name·version 1.0.0) |
| `marketplace.json` | 마켓플레이스 등록 정보            |

---

전체 파일 목록은 `git ls-files` 기준. `.claude/`는 위 소스를 가리키는 심링크라 별도 카운트 없음.

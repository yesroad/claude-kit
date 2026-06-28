# claude-front

프론트엔드(Next.js·React) 개발을 위한 개인 Claude Code 하네스.

---

## 설치

```
/plugin marketplace add yesroad/claude-front   # 1. 마켓플레이스 추가
/plugin install claude-front@yesroad           # 2. 설치 후 Claude Code 재시작
/setup                                         # 3. 프로젝트에서 셋업
```

`/setup`은 기술 스택을 몇 가지 물어본 뒤, 소스를 `~/.claude-front`에 두고 프로젝트의 `.claude/`가
그 소스를 **심링크**하도록 연결하고 맞춤 `CLAUDE.md`를 만듭니다. 새 프로젝트마다 `/setup` 한 번이면 됩니다.

> **업데이트** — `cd ~/.claude-front && git pull` 한 번이면 이 머신의 모든 프로젝트에 반영됩니다.
> 세션 시작 시 자동 pull도 돌기 때문에 보통은 신경 쓸 필요가 없습니다.

> **선택** — `brew install terminal-notifier gh` (완료 알림·PR 생성에 사용)

---

## 커맨드

| 커맨드     | 설명                                       |
| ---------- | ------------------------------------------ |
| `/start`   | 작업 시작 — 분석 → 계획 → 승인 → 구현·검증 |
| `/done`    | 작업 완료 — 검증 → 커밋 → PR               |
| `/commit`  | 커밋 메시지 생성 후 커밋                   |
| `/test`    | 단위 → 통합 → E2E 테스트 실행              |
| `/setup`   | 프로젝트 셋업 (프로젝트당 1회)             |

---

## 스킬 — 키워드만 말하면 자동 실행

| 스킬                  | 설명                          |
| --------------------- | ----------------------------- |
| `bug-fix`             | 버그 분석·수정                |
| `refactor`            | 리팩토링·구조 개선            |
| `component-creator`   | React 컴포넌트·훅 생성        |
| `web-design`          | Next.js + Tailwind UI 구현    |
| `nextjs-scaffold`     | 도메인·서비스 레이어 스캐폴딩 |
| `test-unit`           | 단위 테스트 생성              |
| `test-integration`    | 통합 테스트 생성              |
| `test-e2e`            | E2E(Playwright) 테스트 생성   |
| `code-level-review`   | 코드 리뷰·컨벤션 진단         |
| `code-quality`        | 린트·포맷·타입체크            |
| `migration-helper`    | 버전 업그레이드·마이그레이션  |
| `commit-helper`       | 커밋 메시지 생성              |
| `pr-responder`        | PR 리뷰 코멘트 대응           |
| `docs-creator`        | AI 코딩 도구 문서 작성        |
| `directive-generator` | CLAUDE.md·AGENTS.md 생성      |

---

## 구성

- **`rules/`** — 프레임워크별 코딩 규칙 (관련 파일 작업 시 조건부 자동 로드)
- **`agents/`** — 탐색·리뷰·린트·git 서브에이전트
- **`skills/`** — 위 자동 트리거 스킬
- **`workflows/`** — 복잡도 판단·품질 게이트·협업 가이드
- **`hooks/`** — 코드 품질 검사·위험 명령 차단·완료 알림

전체 파일 설명은 [FILE-MAP.md](./FILE-MAP.md)를 참고하세요.

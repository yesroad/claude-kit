# cc-kit

프론트엔드 개발을 위한 Claude Code 플러그인.
설치하고 `/setup` 한 번이면, 프로젝트에 맞는 **코딩 규칙 · 서브에이전트 · 자동 스킬 · 슬래시 커맨드**가 준비됩니다.

---

## 설치

```
/plugin marketplace add yesroad/cc-kit   # 1. 마켓플레이스 추가
/plugin install cc-kit@yesroad           # 2. 설치 후 Claude Code 재시작
/setup                                    # 3. 프로젝트에서 기술 스택 설정
```

`/setup`은 프레임워크·스타일링 등 몇 가지를 물어본 뒤, 프로젝트에 맞춘 `.claude/`와 `CLAUDE.md`를 자동 생성합니다. 이후 `/start`, `/done` 등을 네임스페이스 없이 바로 쓸 수 있습니다.

> **선택**: `brew install terminal-notifier gh` — 작업 완료 알림과 PR 생성에 사용합니다.

---

## 커맨드

| 커맨드           | 설명                                       |
| ---------------- | ------------------------------------------ |
| `/start`         | 작업 시작 — 분석 → 계획 → 승인 → 구현·검증 |
| `/done`          | 작업 완료 — 검증 → 커밋 → PR               |
| `/commit`        | 커밋 메시지 생성 후 커밋                   |
| `/test`          | 단위 → 통합 → E2E 테스트 실행              |
| `/setup`         | 프로젝트 초기 설정 (최초 1회)              |
| `/update-cc-kit` | 플러그인 최신화                            |

---

## 스킬 — 키워드만 말하면 자동 실행

| 이럴 때 말하면…           | 실행되는 스킬                               |
| ------------------------- | ------------------------------------------- |
| "버그", "에러"            | `bug-fix`                                   |
| "리팩토링", "구조 개선"   | `refactor`                                  |
| "컴포넌트 만들어"         | `component-creator`                         |
| "UI·화면 만들어"          | `web-design` (Next.js + Tailwind)           |
| "도메인·서비스 추가"      | `nextjs-scaffold` (Next.js)                 |
| "테스트 작성"             | `test-unit` · `test-integration` · `test-e2e` |
| "코드 리뷰", "컨벤션"     | `code-level-review`                         |
| "린트", "타입체크"        | `code-quality`                              |
| "업그레이드", "마이그레이션" | `migration-helper`                       |
| "커밋 메시지"             | `commit-helper`                             |
| "리뷰 반영"               | `pr-responder`                              |
| "문서·CLAUDE.md 작성"     | `docs-creator` · `directive-generator`      |

---

## 개발 사이클

```
/setup   → 최초 1회: 기술 스택 설정
/start   → 분석 → 계획 → 승인 → 구현 + 검증
            (구현 중 스킬 자동 활용: 컴포넌트·버그·테스트 …)
/done    → 검증 → 커밋 → PR
```

---

## MCP 서버 (선택)

`/setup`에서 고른 서버만 `.mcp.json`에 추가됩니다.

| 서버              | 용도                       | API 키 |
| ----------------- | -------------------------- | :----: |
| Figma             | 디자인 파일 읽기           |  필요  |
| Supabase          | DB·마이그레이션            |  필요  |
| Playwright        | 브라우저 자동화·E2E        |   —    |
| Atlassian         | Jira·Confluence 연동       |  필요  |
| shadcn            | shadcn/ui 컴포넌트         |   —    |
| context7          | 라이브러리 최신 문서       |   —    |
| chrome-devtools   | 브라우저 제어·성능 분석    |   —    |
| Basic Memory      | 세션 간 프로젝트 메모리    |   —    |

---

<details>
<summary><b>구성 자세히 보기</b></summary>

- **`rules/`** — 프레임워크별 코딩 규칙 (관련 파일 작업 시 조건부 자동 로드)
- **`agents/`** — 탐색·리뷰·린트·git 전문 서브에이전트
- **`skills/`** — 위 자동 트리거 스킬 15개
- **`workflows/`** — 복잡도 판단·품질 게이트·협업 가이드
- **`hooks/`** — 코드 품질 검사, 위험 명령 차단, 완료 알림

전체 파일 설명은 [FILE-MAP.md](./FILE-MAP.md)를 참고하세요.

</details>

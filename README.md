# ai-rules-kit

범용 AI 코딩 툴킷 — Claude Code, Cursor, OpenCode, Codex에서 동일한 규칙·에이전트·스킬을 사용합니다.

---

## 지원 툴

| 툴          | 설치 옵션    | 설치 경로                      |
| ----------- | ------------ | ------------------------------ |
| Claude Code | `--claude`   | `.claude/`                     |
| Cursor      | `--cursor`   | `.cursor/`                     |
| OpenCode    | `--opencode` | `.opencode/` + `AGENTS.md`     |
| Codex       | `--codex`    | `.codex/` + `.codex/AGENTS.md` |

---

## 설치

### 방법 1 — 원격

프로젝트 루트에서 한 줄로 실행합니다. 레포를 `~/.config/ai-rules-kit/`에 자동으로 clone합니다.

```bash
# Claude Code
curl -fsSL https://raw.githubusercontent.com/yesroad/ai-rules-kit/main/install.sh \
  | bash -s -- --claude .

# Cursor
curl -fsSL https://raw.githubusercontent.com/yesroad/ai-rules-kit/main/install.sh \
  | bash -s -- --cursor .

# Codex
curl -fsSL https://raw.githubusercontent.com/yesroad/ai-rules-kit/main/install.sh \
  | bash -s -- --codex .

# OpenCode
curl -fsSL https://raw.githubusercontent.com/yesroad/ai-rules-kit/main/install.sh \
  | bash -s -- --opencode .

# 전체 (4개 모두)
curl -fsSL https://raw.githubusercontent.com/yesroad/ai-rules-kit/main/install.sh \
  | bash -s -- --all .
```

두 번째 실행부터는 `git pull`로 업데이트 후 설치합니다.

### 방법 2 — 로컬

```bash
git clone https://github.com/yesroad/ai-rules-kit.git
cd ai-rules-kit

# 단일 툴
./install.sh --claude   /path/to/your-project
./install.sh --cursor   /path/to/your-project
./install.sh --opencode /path/to/your-project
./install.sh --codex    /path/to/your-project

# 전체 (4개 모두)
./install.sh --all /path/to/your-project
```

설치 시 툴별로 필요한 파일만 복사됩니다. OpenCode, Codex는 `AGENTS.md`가 함께 생성되어 어떤 파일을 언제 참조할지 안내합니다.

---

## 디렉토리 구조

```
src/
├── rules/core/             # 코딩 규칙
│   ├── thinking-model.md           # 통합 사고 모델 (READ→REACT→ANALYZE→...)
│   ├── coding-standards.md         # TypeScript 표준, 에러 처리, React 패턴
│   ├── react-nextjs-conventions.md # React/Next.js 컨벤션, Import 순서
│   ├── react-hooks-patterns.md     # Hook 성능 패턴 (useMemo, useRef 등)
│   ├── nextjs-app-router.md        # App Router 전용 규칙
│   ├── state-and-server-state.md   # TanStack Query v5 + Jotai 상태 경계
│   └── unit-test-conventions.md    # 순수 함수 유닛 테스트 규칙
│
├── agents/                 # 전문화된 서브에이전트
│   ├── explore.md                  # 코드베이스 탐색 (haiku 모델)
│   ├── lint-fixer.md               # 린트/타입 오류 자동 수정
│   ├── git-operator.md             # git 상태 확인, 커밋, PR 관리
│   ├── implementation-executor.md  # 계획 기반 코드 구현
│   └── code-reviewer.md            # 코드 품질·규칙 준수 검토
│
├── skills/                 # 복잡한 다단계 작업 스킬
│   ├── commit-helper/      # 커밋 메시지 자동 생성 (Conventional Commits)
│   ├── code-quality/       # 린트·포맷·타입체크 통합 실행
│   ├── refactor/           # 코드 리팩토링 분석 및 실행
│   ├── bug-fix/            # 버그 분석·수정 (3가지 옵션 제시)
│   ├── docs-creator/       # CLAUDE.md·SKILL.md 문서 작성
│   └── agents-generator/   # 프로젝트 분석 후 AGENTS.md 생성
│
├── commands/               # 슬래시 커맨드
│   ├── start.md            # 작업 시작: 분석 → 계획 → 확인
│   ├── done.md             # 작업 완료: 검증 → 커밋 → PR
│   └── setup-notifier.md   # 초기 환경 설정 (macOS terminal-notifier)
│
├── instructions/           # 작업 방식·검증 가이드
│   ├── multi-agent/        # 멀티 에이전트 협업 패턴
│   └── workflow-patterns/  # 복잡도별 작업 단계
│
├── hooks/                  # 이벤트 훅 (Claude, Cursor, Codex용)
│   └── notify.sh           # macOS 알림 (terminal-notifier)
│
└── plugins/                # OpenCode 전용 플러그인
    └── notify.js           # permission.asked 이벤트 알림
```

---

## 툴별 복사 매트릭스

각 툴에 맞는 파일만 복사되며, 비호환 필드는 자동으로 변환됩니다.

| 디렉토리        | Claude  | Cursor  | OpenCode |  Codex  |
| --------------- | :-----: | :-----: | :------: | :-----: |
| `hooks/`        |   ✅    |   ✅    |    ❌    |   ✅    |
| `plugins/`      |   ❌    |   ❌    |    ✅    |   ❌    |
| `agents/`       | ✅ 원본 | ✅ 원본 | ✅ 변환  | ✅ 변환 |
| `rules/`        |   ✅    |   ✅    |    ✅    |   ✅    |
| `skills/`       |   ✅    |   ✅    |    ✅    |   ✅    |
| `commands/`     |   ✅    |   ✅    |    ✅    |   ✅    |
| `settings.json` |   ✅    |   ❌    |    ❌    |   ❌    |

> **agents/ 변환 내용**
>
> - OpenCode: `tools:`, `model:`, `@../` 라인 제거 (파싱 에러 방지)
> - Codex: `tools:`, `model:` 라인 제거

---

## 주요 기능

### 멀티 에이전트 병렬 실행

독립적인 작업을 동시에 여러 에이전트에 위임해 속도를 높입니다.

```
복잡도별 모델 라우팅:
- LOW  → haiku  (빠르고 저렴)
- MED  → sonnet (균형)
- HIGH → opus   (최고 품질)
```

### Skills & Commands

| 스킬 / 커맨드       | 설명                                       |
| ------------------- | ------------------------------------------ |
| `/commit-helper`    | staged 변경사항 기반 커밋 메시지 자동 생성 |
| `/code-quality`     | 린트·포맷·타입체크 통합 실행               |
| `/refactor`         | 코드 리팩토링 분석 및 단계별 실행          |
| `/bug-fix`          | 버그 원인 분석 후 3가지 해결 옵션 제시     |
| `/docs-creator`     | CLAUDE.md·SKILL.md 문서 작성               |
| `/agents-generator` | 프로젝트 분석 후 AGENTS.md 자동 생성       |
| `/start`            | 작업 시작 — 분석 → 계획 수립 → 구현 확인   |
| `/done`             | 작업 완료 — 검증 → 테스트 → 커밋 → PR      |

### 통합 사고 모델

모든 코드 작성 시 자동으로 적용되는 절차:

```
READ → REACT → ANALYZE → RESTRUCTURE → STRUCTURE → REFLECT
```

- **LOW** (1파일, 명확한 수정): READ → REACT
- **MEDIUM** (2~5파일, 기존 패턴): READ → ANALYZE → STRUCTURE → REFLECT
- **HIGH** (5파일+, 새 아키텍처): 전체 6단계 + Plan 에이전트

---

## 기술 스택 가정

이 규칙들은 아래 스택을 사용하는 프론트엔드 프로젝트에 최적화되어 있습니다:

- **React** + **TypeScript**
- **Next.js** (Pages Router / App Router 자동 감지)
- **TanStack Query v5** (서버 상태)
- **Jotai** (전역 UI 상태)
- **Emotion** (스타일링)
- **ESLint** + **Prettier** + **TypeScript**

다른 스택을 사용하는 경우 `src/rules/core/` 파일을 수정하여 적용하세요.

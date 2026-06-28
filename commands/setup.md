---
name: setup
description: claude-front를 현재 프로젝트에 설치합니다. 프로젝트 기술 스택을 입력받아 맞춤형 CLAUDE.md와 .claude/ 설정을 생성합니다.
---

현재 프로젝트에 claude-front를 설치합니다.

---

## 0단계: 프로젝트 탐색

인터뷰 전에 프로젝트를 탐색하여 기술 스택을 자동 감지합니다.

```bash
# package.json 읽기
cat package.json 2>/dev/null || true

# 라우터 감지 (Next.js인 경우)
ls app/ src/app/ 2>/dev/null | head -1 || true
ls pages/ src/pages/ 2>/dev/null | head -1 || true

# 스타일링 설정 파일 감지
ls tailwind.config.* 2>/dev/null || true
```

감지 결과를 아래 매핑표에 따라 자동 확정합니다:

| 감지 조건 | 자동 확정 |
|-----------|-----------|
| `dependencies`에 `next` 있음 | Q1 → Next.js |
| `dependencies`에 `react` 있음 (next 없음) | Q1 → React |
| `app/` 또는 `src/app/` 디렉토리 있음 | Q2 → App Router |
| `pages/` 또는 `src/pages/` 디렉토리 있음 | Q2 → Pages Router |
| `dependencies`에 `tailwindcss` 있음 | Q3 → TailwindCSS |
| `tailwindcss` 버전이 `^4` 또는 `>=4` | Q3-version → v4 |
| `tailwindcss` 버전이 `^3` 또는 `>=3 <4` | Q3-version → v3 |
| `dependencies`에 `@emotion/react` 또는 `@emotion/styled` 있음 | Q3 → Emotion |
| `dependencies`에 `@tanstack/react-query` 있음 | Q4 → TanStack Query |
| `dependencies`에 `swr` 있음 | Q4 → SWR |
| `dependencies`에 `jotai` 있음 | Q5 → Jotai |
| `dependencies`에 `zustand` 있음 | Q5 → Zustand |
| `dependencies`에 `@reduxjs/toolkit` 있음 | Q5 → Redux Toolkit |
| `dependencies`에 `zod` 있음 | Q6 → Zod |
| `dependencies`에 `yup` 있음 | Q6 → Yup |

---

## 1단계: 프로젝트 기술 스택 인터뷰

### 감지 결과 확인 → 미감지만 질문

0단계 감지 결과가 있으면 사용자에게 확인을 받는다.

**진행 방식 (순서대로 엄격히 지킨다):**

**STEP A. 감지 결과만 보여주고 Y/n을 받는다** — 이 메시지에 다른 질문을 추가하지 않는다:
   ```
   📋 감지된 기술 스택:
   - 프레임워크: Next.js (App Router)
   - 스타일링: TailwindCSS v4
   - 서버 상태: TanStack Query
   - 전역 상태: Zustand
   - 폼 검증: Zod

   이대로 진행할까요? (Y/n)
   ```

**STEP B. Y/n 응답을 받은 후** 다음 중 하나를 실행한다:
- `Y` 또는 엔터 → 감지 항목 확정. 미감지 항목(Q1~Q6 중 감지 안 된 것)을 순서대로 **하나씩** 질문
- `n` → 감지 결과 무시. Q1~Q6을 순서대로 **하나씩** 질문
- 감지된 항목이 하나도 없으면 → Q1~Q6을 순서대로 **하나씩** 질문

질문 후 대답을 받으면 다음 질문으로 넘어간다. Q1~Q6이 모두 확정되면 Q7, Q8을 순서대로 **하나씩** 질문한다.

> **⚠️ Q7(MCP)과 Q8(Basic Memory)는 항상 묻는 항목이다.** 감지 여부와 무관하게 반드시 포함한다.
>
> **⚠️ 질문은 반드시 하나씩 순서대로 한다. 여러 질문을 한 번에 보내지 않는다.**
> 모든 답변을 받은 뒤 2단계로 넘어간다.

아래는 **미감지 시 질문할 내용**입니다:

---

**Q1. 프레임워크**

1. Next.js
2. React (CRA / Vite)
3. 기타 (Node.js, Python, Go 등 — 프론트엔드 전용 rules 제외)

> **참고**: Vue는 지원하지 않습니다. Vue 프로젝트는 Q1 = 기타로 선택하세요.

---

**Q2. 라우터** (Q1 = Next.js일 때만 질문)

1. App Router
2. Pages Router

---

**Q3. 스타일링**

1. TailwindCSS
2. Emotion
3. CSS Modules
4. 기타

**Q3-1. TailwindCSS 버전** (Q3 = TailwindCSS일 때만, 미감지 시 질문)

1. v4 (`tailwind.config.js` 없음, CSS `@theme` 기반)
2. v3 (`tailwind.config.js` 기반)

---

**Q4. 서버 상태 관리**

1. TanStack Query
2. SWR
3. 없음

---

**Q5. 전역 UI 상태 관리**

1. Jotai
2. Zustand
3. Redux Toolkit
4. 없음

---

**Q6. 폼 검증 라이브러리**

1. Zod
2. Yup
3. 없음

---

**Q7. MCP 서버** (복수 선택 가능)

| 번호 | 서버          | 용도                                               |
| ---- | ------------- | -------------------------------------------------- |
| 1    | Figma         | 피그마 디자인 파일 읽기 (API 키 필요)              |
| 2    | Supabase      | DB 쿼리, 마이그레이션, Edge Function (API 키 필요) |
| 3    | Playwright    | 브라우저 자동화, E2E 테스트 (설정 불필요)          |
| 4    | Atlassian     | Jira·Confluence 연동 (API 키 필요)                 |
| 5    | shadcn        | shadcn/ui 컴포넌트 검색 및 설치 (설정 불필요)      |
| 6    | context7      | 라이브러리 공식 최신 문서 검색 (설정 불필요)       |
| 7    | chrome-devtools | Chrome 브라우저 직접 제어, 성능 분석 (설정 불필요) |
| 8    | 없음          |                                                    |

예시: "1 3" → Figma + Playwright 설치

---

**Q8. Basic Memory** — 세션이 끊겨도 프로젝트 컨텍스트를 기억합니다. 사용하시겠어요?

1. 예
2. 아니오

> Basic Memory는 로컬에서만 실행되며 별도 API 키가 필요 없습니다.

---

## 2단계: 파일 설치

답변을 받은 후 아래 스크립트를 실행합니다.

Q7 답변을 기반으로 스크립트 실행 전에 `SELECTED_MCP` 변수를 설정합니다:

| Q7 선택              | SELECTED_MCP 값         |
| -------------------- | ----------------------- |
| 1 (Figma)            | `Figma`                 |
| 2 (Supabase)         | `supabase`              |
| 3 (Playwright)       | `playwright`            |
| 4 (Atlassian)        | `Atlassian`             |
| 5 (shadcn)           | `shadcn`                |
| 6 (context7)         | `context7`              |
| 7 (chrome-devtools)  | `chrome-devtools`       |
| 복수 선택 "1 3"      | `Figma,playwright`      |
| 8 또는 엔터          | (빈 문자열, 설치 안 함) |

Q8 답변을 기반으로 `INSTALL_BASIC_MEMORY` 변수를 설정합니다:

| Q8 선택  | INSTALL_BASIC_MEMORY 값 |
| -------- | ----------------------- |
| 1 (예)   | `y`                     |
| 2 또는 엔터 | (빈 문자열)          |

설치 스크립트를 실행합니다. (인터뷰 답변 Q1~Q6은 **rule 설치를 결정하지 않는다** — 모든 rule이 심링크로 존재하고 각 파일의 `paths` frontmatter가 로딩을 제어한다. 인터뷰는 5단계 CLAUDE.md 생성·quick_ref·MCP 선택에만 쓰인다.)

```bash
#!/bin/bash
set -e

command -v python3 >/dev/null 2>&1 || { echo "❌ python3가 필요합니다. (settings.json 주입·MCP 설정에 사용)"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ git이 필요합니다."; exit 1; }

# ── 소스 준비: 고정 경로에 git clone(첫 1회) 후 pull ───────────────────────────
# 프로젝트 .claude/ 는 이 한 벌의 소스를 심링크한다 → `git pull` 한 번이면 모든 프로젝트가 자동 최신.
FRONT_HOME="${CLAUDE_FRONT_HOME:-$HOME/.claude-front}"
REPO_URL="https://github.com/yesroad/claude-front.git"

if [ ! -d "$FRONT_HOME/.git" ]; then
  echo "첫 설치 — $FRONT_HOME 에 클론합니다..."
  git clone --depth 1 "$REPO_URL" "$FRONT_HOME"
else
  git -C "$FRONT_HOME" pull --ff-only 2>/dev/null || echo "⚠️  pull 실패(오프라인/충돌) — 기존 상태로 진행합니다."
fi

[ -d "$FRONT_HOME/rules" ] || { echo "❌ 소스가 올바르지 않습니다: $FRONT_HOME"; exit 1; }

# ── 심링크: .claude/ 가 고정 소스를 가리킨다 (디렉토리 통째 → 소스 변경 자동 반영) ──
mkdir -p .claude
for dir in rules workflows agents skills commands hooks scripts; do
  [ -e "$FRONT_HOME/$dir" ] || continue
  rm -rf ".claude/$dir"                      # 기존 심링크/구 복사본 제거(개인용 — 백업 불필요)
  ln -s "$FRONT_HOME/$dir" ".claude/$dir"     # 절대경로 심링크
done
echo "🔗 .claude/ → $FRONT_HOME 심링크 완료"

# 심링크라 hooks 실행권한은 소스 파일 그대로 사용된다 (chmod 불필요)

# settings.json에 harness hooks 주입 (없으면 생성, 있으면 머지)
python3 - <<'PYEOF'
import json, os

settings_path = ".claude/settings.json"
settings = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)

hooks = settings.setdefault("hooks", {})

# PreToolUse 훅 (guard-pretool, 위험 Bash 차단) — 이미 있으면 건드리지 않음
if "PreToolUse" not in hooks:
    hooks["PreToolUse"] = [{
        "matcher": "Bash",
        "hooks": [{"type": "command",
                   "command": "bash \"./.claude/hooks/guard-pretool.sh\"",
                   "timeout": 5}]
    }]

# PostToolUse 훅 (guard-check) — 이미 있으면 건드리지 않음
if "PostToolUse" not in hooks:
    hooks["PostToolUse"] = [{
        "matcher": "Write|Edit",
        "hooks": [{"type": "command",
                   "command": "bash \"./.claude/hooks/guard-check.sh\"",
                   "timeout": 10}]
    }]

# Stop 훅 (완료 알림) — 이미 있으면 건드리지 않음
if "Stop" not in hooks:
    hooks["Stop"] = [{
        "matcher": "",
        "hooks": [{"type": "command",
                   "command": "NOTIFIER_TITLE='claude-front' NOTIFIER_MESSAGE='응답 완료 — /done으로 검증하세요' bash \"./.claude/hooks/notify.sh\"",
                   "timeout": 5}]
    }]

# planMode 기본값 설정 — 이미 설정한 경우 덮어쓰지 않음
if "planMode" not in settings:
    settings["planMode"] = True

# Plan Mode 계획 파일을 프로젝트 로컬에 저장
if "plansDirectory" not in settings:
    settings["plansDirectory"] = "./.claude/plans"

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")

print("📋 settings.json harness hooks 주입 완료")
PYEOF

# ── 전역 ~/.claude/settings.json 에 SessionStart 자동 pull 훅 주입 (멱등) ──────────
# pull은 FRONT_HOME 한 곳을 갱신하므로 프로젝트마다가 아니라 전역 1개면 충분하다.
# 세션 시작/재개 때 auto-pull.sh가 throttle(기본 12h)로 백그라운드 pull → 모든 프로젝트 자동 최신.
FRONT_HOME="$FRONT_HOME" python3 - <<'PYEOF'
import json, os

front_home = os.environ["FRONT_HOME"]
gpath = os.path.expanduser("~/.claude/settings.json")
os.makedirs(os.path.dirname(gpath), exist_ok=True)

settings = {}
if os.path.exists(gpath):
    with open(gpath) as f:
        try:
            settings = json.load(f)
        except Exception:
            settings = {}

hooks = settings.setdefault("hooks", {})
ss = hooks.setdefault("SessionStart", [])

cmd = f'bash "{front_home}/hooks/auto-pull.sh"'
already = any(
    any(h.get("command") == cmd for h in entry.get("hooks", []))
    for entry in ss
)
if not already:
    ss.append({
        "matcher": "startup|resume",
        "hooks": [{"type": "command", "command": cmd, "timeout": 10}],
    })
    with open(gpath, "w") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("📋 전역 SessionStart 자동 pull 훅 등록 완료")
else:
    print("📋 전역 SessionStart 자동 pull 훅 이미 등록됨")
PYEOF

# .mcp.json: Q7 선택 서버만 추가 (없으면 새로 생성, 있으면 선택 항목만 머지)
# SELECTED_MCP: Q7 답변 기반으로 Claude가 설정 — 쉼표 구분 서버 키 목록
# 예) SELECTED_MCP="Figma,playwright" 또는 SELECTED_MCP="" (없음)
# 서버 키 매핑: 1=Figma, 2=supabase, 3=playwright, 4=Atlassian, 5=shadcn
if [ -n "$SELECTED_MCP" ] && [ -f "$FRONT_HOME/.mcp.json" ]; then
  MCP_TEMPLATE="$FRONT_HOME/.mcp.json" MCP_SELECTED="$SELECTED_MCP" python3 - <<'PYEOF'
import json, os

template_path = os.environ["MCP_TEMPLATE"]
selected_keys = [k.strip() for k in os.environ.get("MCP_SELECTED", "").split(",") if k.strip()]

with open(template_path) as f:
    template = json.load(f)

template_servers = template.get("mcpServers", {})

# 선택된 서버만 필터
selected_servers = {k: v for k, v in template_servers.items() if k in selected_keys}
if not selected_servers:
    print("📋 선택된 MCP 서버 없음 — .mcp.json 생성 안 함")
    exit(0)

# 기존 .mcp.json 로드 또는 빈 구조 생성
if os.path.exists(".mcp.json"):
    with open(".mcp.json") as f:
        existing = json.load(f)
else:
    existing = {}

existing_servers = existing.setdefault("mcpServers", {})

added = []
for name, config in selected_servers.items():
    if name not in existing_servers:
        existing_servers[name] = config
        added.append(name)

with open(".mcp.json", "w") as f:
    json.dump(existing, f, indent=2, ensure_ascii=False)
    f.write("\n")

if added:
    print(f"📋 .mcp.json 완료 — 추가된 서버: {', '.join(added)}")
else:
    print("📋 .mcp.json 변경 없음 (선택 서버가 이미 존재)")
PYEOF
fi

# Basic Memory MCP: Q8 y/n 기반으로 Claude가 설정
# INSTALL_BASIC_MEMORY="y" 또는 "" (설치 안 함)
if [ "$INSTALL_BASIC_MEMORY" = "y" ] && [ -f "$FRONT_HOME/.mcp.json" ]; then
  MCP_TEMPLATE="$FRONT_HOME/.mcp.json" python3 - <<'PYEOF'
import json, os

template_path = os.environ["MCP_TEMPLATE"]
with open(template_path) as f:
    template = json.load(f)

basic_memory_config = template.get("mcpServers", {}).get("basic-memory")
if not basic_memory_config:
    print("❌ basic-memory 설정을 찾을 수 없습니다")
    exit(0)

if os.path.exists(".mcp.json"):
    with open(".mcp.json") as f:
        existing = json.load(f)
else:
    existing = {}

existing_servers = existing.setdefault("mcpServers", {})

if "basic-memory" not in existing_servers:
    existing_servers["basic-memory"] = basic_memory_config
    with open(".mcp.json", "w") as f:
        json.dump(existing, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("📋 .mcp.json Basic Memory 추가 완료")
else:
    print("📋 .mcp.json Basic Memory 이미 존재 — 건드리지 않음")
PYEOF
fi

# manifest.json 기록 (.claude/manifest.json — 심링크 모드 메타)
FRONT_HOME="$FRONT_HOME" python3 - <<'PYEOF'
import json, os
from datetime import date

front_home = os.environ["FRONT_HOME"]

# plugin.json에서 버전 읽기 (.claude-plugin/ 우선)
version = "unknown"
for cand in (os.path.join(front_home, ".claude-plugin", "plugin.json"),
             os.path.join(front_home, "plugin.json")):
    if os.path.exists(cand):
        with open(cand) as f:
            version = json.load(f).get("version", "unknown")
        break

manifest_path = ".claude/manifest.json"
manifest = {}
if os.path.exists(manifest_path):
    with open(manifest_path) as f:
        manifest = json.load(f)

manifest["claude-front"] = {
    "version": version,
    "installedAt": str(date.today()),
    "mode": "symlink",
    "frontHome": front_home,
}

with open(manifest_path, "w") as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"📋 manifest.json 기록 완료 (symlink → {front_home})")
PYEOF

# .mcp.json 보안 안내
if [ -f ".mcp.json" ]; then
  if ! grep -qx ".mcp.json" .gitignore 2>/dev/null; then
    echo ".mcp.json" >> .gitignore
    echo "🔒 .mcp.json을 .gitignore에 추가했습니다 — API 키 평문 커밋을 방지합니다."
  fi
fi

echo "✅ .claude/ 설치 완료"
```

## 3단계: 기존 CLAUDE.md 백업

기존 `CLAUDE.md`가 있으면 `.claude/CLAUDE.back.md`로 백업합니다:

```bash
[ -f CLAUDE.md ] && cp CLAUDE.md .claude/CLAUDE.back.md && echo "✅ 기존 CLAUDE.md → .claude/CLAUDE.back.md 백업 완료"
```

## 4단계: 알림 설정

`.claude/commands/setup-notifier.md`를 읽고 해당 지침대로 알림 설정을 실행합니다.

## 5단계: CLAUDE.md 생성

`.claude/skills/directive-generator/SKILL.md`를 읽고 해당 지침대로 CLAUDE.md를 생성합니다.

호출 시 아래 컨텍스트를 함께 전달합니다:

**기술 스택 (인터뷰 답변 요약):**

- 프레임워크: {Q1 답변} ({Q2 답변, Next.js인 경우})
- 스타일링: {Q3 답변}
- 서버 상태: {Q4 답변}
- 전역 상태: {Q5 답변}

**CLAUDE.md에 포함할 @참조 (항상 로드되는 workflows 가이드만):**

| 파일                   | 위치                       | 포함 조건 |
| ---------------------- | -------------------------- | --------- |
| `model.md`             | `workflows/thinking/`      | 항상      |
| `required-patterns.md` | `workflows/quality-gates/` | 항상      |
| `anti-patterns.md`     | `workflows/quality-gates/` | 항상      |
| `pr-guide.md`          | `workflows/git/`           | 항상      |

> **rules는 `@참조`하지 않는다.** `.claude/rules/`는 Claude Code가 자동 발견하여 로드한다
> (`paths` frontmatter 없으면 시작 시 항상, 있으면 일치 파일 작업 시). 모든 rule이 심링크로 존재하며
> 어떤 rule이 로드되는지는 각 파일의 `paths` frontmatter가 제어한다 — 무관한 rule은 해당 경로를
> 작업할 때만 로드되므로 컨텍스트 낭비가 없다. directive-generator는 rule을 CLAUDE.md에 `@참조`로
> 주입하지 않는다 — 자동발견과의 **이중 로드를 막기 위함**이다.

**포함할 스킬 quick_ref (결정표 기반):**

| 스킬                       | 포함 조건                                        |
| -------------------------- | ------------------------------------------------ |
| `commit-helper`            | 항상                                             |
| `pr-responder`             | 항상                                             |
| `code-quality`             | 항상                                             |
| `refactor`                 | 항상                                             |
| `bug-fix`                  | 항상                                             |
| `migration-helper`         | 항상                                             |
| `docs-creator`             | 항상                                             |
| `directive-generator`      | 항상                                             |
| `test-e2e`                 | 항상                                             |
| `test-unit`                | Q1 = Next.js 또는 React                          |
| `test-integration`         | Q1 = Next.js 또는 React                          |
| `code-level-review`        | Q1 = Next.js 또는 React                          |
| `nextjs-scaffold`          | Q1 = Next.js                                     |
| `component-creator`        | Q1 = Next.js 또는 React                          |
| `web-design`               | Q1 = Next.js 또는 React **AND** Q3 = TailwindCSS |

directive-generator가 생성한 CLAUDE.md에 `<quick_ref>` 섹션이 없으면 아래 결정표에 따라 추가합니다.

**예시: Q1=Next.js, Q3=TailwindCSS인 경우**

```markdown
<quick_ref>
| 상황 | 커맨드/스킬 |
|------|------------|
| 작업 시작·계획·구현 | /start |
| 작업 완료+PR | /done |
| 커밋 | /commit |
| UI 구현 | web-design 스킬 |
| 컴포넌트 생성 | component-creator 스킬 |
| 도메인 스캐폴딩 | nextjs-scaffold 스킬 |
| 버그 수정 | bug-fix 스킬 |
| 리팩토링 | refactor 스킬 |
| 단위 테스트 | test-unit 스킬 |
| 통합 테스트 | test-integration 스킬 |
| E2E 테스트 | test-e2e 스킬 |
| 코드 컨벤션 | code-level-review 스킬 |
| 에이전트 선택 | @.claude/workflows/coordination/roster.md |
| 복잡도 판단 | @.claude/workflows/thinking/model.md |
</quick_ref>
```

**예시: Q1=React, Q3=Emotion인 경우** (`web-design` 제외, `nextjs-scaffold` 제외)

```markdown
<quick_ref>
| 상황 | 커맨드/스킬 |
|------|------------|
| 작업 시작·계획·구현 | /start |
| 작업 완료+PR | /done |
| 커밋 | /commit |
| 컴포넌트 생성 | component-creator 스킬 |
| 버그 수정 | bug-fix 스킬 |
| 리팩토링 | refactor 스킬 |
| 단위 테스트 | test-unit 스킬 |
| 통합 테스트 | test-integration 스킬 |
| E2E 테스트 | test-e2e 스킬 |
| 코드 컨벤션 | code-level-review 스킬 |
| 에이전트 선택 | @.claude/workflows/coordination/roster.md |
| 복잡도 판단 | @.claude/workflows/thinking/model.md |
</quick_ref>
```

## 6단계: 설치 완료 보고

설치된 항목, 백업 여부, 생성된 CLAUDE.md 내용을 사용자에게 보여주고 아래 형식으로 안내합니다:

```
✅ claude-front 설치 완료

📁 설치된 항목:
  .claude/rules/        — 코딩 규칙 (소스 심링크 · paths 조건부 로드)
  .claude/agents/       — 전문화된 서브에이전트
  .claude/skills/       — 자동 트리거 스킬
  .claude/commands/     — 슬래시 커맨드
  .claude/workflows/ — 작업 방식 가이드
  .claude/hooks/        — 알림 훅
  .claude/rules/references/ — 라이브러리 레퍼런스 문서 (TypeScript·Zod)
  CLAUDE.md             — 프로젝트 루트 지시문 (새로 생성)

📋 사용 가능한 커맨드:
  /start          — 작업 시작 (Plan Mode → 분석 → 계획 생성 → 승인 → 구현 + 검증)
  /done           — 작업 완료 (검증 → 커밋 → PR 생성)
  /commit         — 커밋 플로우 자동화
  /test           — 단위 → 통합 → E2E 테스트 순차 실행
  /setup-notifier — macOS 알림 환경 설정 (최초 1회)

💡 자주 쓰는 스킬 (키워드로 자동 트리거):
  bug-fix               — "버그", "오류", "에러"
  refactor              — "리팩토링", "구조 개선"
  component-creator     — "컴포넌트 만들어", "훅 만들어"
  test-unit             — "단위 테스트", "유닛 테스트"
  test-e2e              — "e2e 테스트", "playwright"
  migration-helper      — "업그레이드", "마이그레이션"
  web-design            — "UI 만들어", "화면 구현"  (Next.js + Tailwind)
  code-level-review        — "코드 리뷰", "컨벤션 확인"
```

> CLAUDE.md가 백업된 경우: `.claude/CLAUDE.back.md`에서 이전 내용을 확인할 수 있습니다.
>
> 📌 `.claude/`의 rules·agents·skills·commands·workflows·hooks는 `$HOME/.claude-front`(고정 클론)를
> 가리키는 **심링크**입니다. `cd ~/.claude-front && git pull` 한 번이면 이 머신의 모든 프로젝트가 자동
> 최신이 되고, 세션 시작 시에도 자동 pull(기본 12h 간격)이 돌아 보통은 신경 쓸 필요가 없습니다.
> **새 프로젝트에서만 `/setup`을 한 번** 더 실행하세요.

# Claude Kit

<instructions>
@.claude/rules/core/thinking-model.md
@.claude/instructions/validation/required-behaviors.md
@.claude/instructions/validation/forbidden-patterns.md
</instructions>

<quick_ref>

> 이 CLAUDE.md는 플러그인 개발용입니다. 설치된 프로젝트에서는 `/start` 형식을 사용합니다.

| 상황          | 참조                                                           |
| ------------- | -------------------------------------------------------------- |
| 작업 시작     | /start                                                         |
| 작업 완료+PR  | /done                                                          |
| 커밋          | /commit                                                        |
| 에이전트 선택 | @.claude/instructions/multi-agent/agent-roster.md              |
| 복잡도 판단   | @.claude/instructions/workflow-patterns/sequential-thinking.md |

</quick_ref>

<tech_stack>
Claude Kit은 .claude/ 보일러플레이트 시스템 (코드 없음).
주요 의존성: terminal-notifier, gh CLI
</tech_stack>

<dev_rules>

## 파일 작업 규칙 — 양방향 동기화 필수

이 레포는 동일한 파일이 두 곳에 존재한다:

| 경로 | 역할 |
|------|------|
| `skills/`, `agents/`, `commands/`, `rules/`, `hooks/`, `instructions/`, `scripts/` | **배포 원본** (git 추적, 실제 소스) |
| `.claude/skills/`, `.claude/agents/` 등 | **로컬 설치본** (gitignore, Claude Code가 실제 읽는 위치) |

**파일을 생성하거나 수정할 때는 반드시 두 곳 모두 동일하게 적용한다.**

```
# 예: web-design 스킬 수정 시
skills/web-design/SKILL.md          ← 항상 함께 수정
.claude/skills/web-design/SKILL.md  ← 항상 함께 수정
```

한 곳만 수정하면 로컬 동작과 배포 내용이 달라진다.

</dev_rules>

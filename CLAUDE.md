# Claude Kit

<tech_stack>
cc-kit은 Claude Code용 AI 코딩 워크플로우 플러그인입니다.
주요 구성: rules, agents, skills, commands, workflows
주요 의존성: terminal-notifier, gh CLI
</tech_stack>

<dev_rules>

## 구조 변경 시 문서 동기화 필수

스킬·커맨드·에이전트·워크플로·룰을 추가·수정·삭제할 때:

1. `Grep "변경 대상명"` → 모든 참조 위치 파악
2. 아래 문서에서 해당 항목 업데이트:

| 문서                                 | 업데이트 내용                        |
| ------------------------------------ | ------------------------------------ |
| `commands/setup.md`                  | 결정표, quick_ref 예시               |
| `workflows/coordination/roster.md`   | 에이전트/스킬 카탈로그, 연결 흐름    |
| `README.md`                          | 목록 테이블, 디렉토리 구조           |
| `FILE-MAP.md`                        | 섹션별 항목, 흐름 다이어그램         |
| `scripts/verify-install.sh`          | 파일 수·이름 배열                    |
| `CHANGELOG.md`                       | 버전·변경 이력 추가                  |

## 릴리즈 시 버전 동기화 필수

버전을 올릴 때 아래를 **한 커밋에서 함께** 갱신한다(과거 버전 5중 불일치 재발 방지):

- `.claude-plugin/plugin.json` → `version`
- `.claude-plugin/marketplace.json` → `metadata.version` + `plugins[0].version` (2곳)
- `CHANGELOG.md` → 새 버전 항목
- `FILE-MAP.md` → 헤더 버전 + `plugin.json` 설명 버전

## 매니페스트·훅·모델 규약

- **매니페스트**: `.claude-plugin/`만 canonical(루트 `plugin.json`/`marketplace.json` 금지). skills/commands/agents/hooks는 자동발견되므로 배열 명시 불필요.
- **훅**: 차단이 필요한 검사는 `PreToolUse`(`exit 2`). `PostToolUse`는 도구 실행 후라 차단 불가(경고만, `exit 1`은 비블로킹).
- **모델**: 별칭(`haiku`/`sonnet`/`opus`)을 쓴다 — 최신 세대를 자동 추적하므로 풀ID 핀 금지. 깊이/비용은 `effort`(frontmatter 또는 `/effort`)로 조절. 단일 진실 공급원은 `workflows/coordination/guide.md`.
- **SKILL.md frontmatter**: `name`·`description`·`user-invocable` 필수, `allowed-tools` 권장, `metadata.version`은 따옴표 문자열(`"1.0.0"`).

</dev_rules>

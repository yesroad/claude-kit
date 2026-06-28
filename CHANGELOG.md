# Changelog

이 프로젝트는 [Semantic Versioning](https://semver.org/lang/ko/)을 따릅니다.

---

## [1.0.0] - 2026-06-28

`claude-front` 첫 릴리즈 - 프론트엔드(Next.js·React) 개발용 Claude Code 워크플로우 플러그인.

- **설치** - `/setup`이 소스를 `~/.claude-front`(`CLAUDE_FRONT_HOME`)에 git clone하고 프로젝트 `.claude/`가 이를 **심링크**한다. `git pull` 한 번이면 그 머신의 모든 프로젝트가 자동 반영되고, 세션 시작 시 `hooks/auto-pull.sh`(전역 SessionStart)가 throttle(기본 12h)로 자동 pull한다.
- **rules** - 전부 심링크 + 각 파일 `paths` frontmatter로 관련 작업 시에만 조건부 로드(컨텍스트 절감).
- **agents 4 · skills 15 · commands 6 · workflows 10** - 탐색·리뷰·테스트·스캐폴딩·문서 등 워크플로우 전반. 모델 별칭(`haiku`/`sonnet`/`opus`) + `effort` 2축 라우팅.
- **hooks** - 코드 품질 검사(`guard-check`), 위험 명령 사전 차단(`guard-pretool`, `exit 2`), 완료 알림(`notify`).

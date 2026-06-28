#!/bin/bash
# claude-front 자동 업데이트 — Claude Code SessionStart 훅에서 호출.
# 고정 클론(FRONT_HOME)을 throttle(기본 12h)로 백그라운드 pull 한다.
# 심링크된 모든 프로젝트가 이 한 곳을 보므로, pull 한 번이면 전부 최신이 된다.
# 오프라인·충돌·미설치 시에는 조용히 통과한다(세션 시작을 막지 않음).

FRONT_HOME="${CLAUDE_FRONT_HOME:-$HOME/.claude-front}"

# git 클론이 아니면 아무것도 하지 않는다.
[ -d "$FRONT_HOME/.git" ] || exit 0

# 마지막 pull 시각 스탬프는 .git 안에 둔다 → 워킹트리를 더럽히지 않고 클론과 함께 정리된다.
STAMP="$FRONT_HOME/.git/.claude-front-last-pull"
THROTTLE="${CLAUDE_FRONT_PULL_INTERVAL:-43200}"   # 초 단위, 기본 12h

NOW=$(date +%s)
LAST=$(cat "$STAMP" 2>/dev/null || echo 0)

if [ $((NOW - LAST)) -gt "$THROTTLE" ]; then
  # 백그라운드 + ff-only + quiet: 세션 시작을 막지 않고, 로컬 변경이 있으면 건너뛴다.
  ( git -C "$FRONT_HOME" pull --ff-only --quiet 2>/dev/null && date +%s > "$STAMP" ) &
fi

exit 0

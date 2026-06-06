#!/bin/bash
# guard-pretool.sh — PreToolUse 위험 Bash 차단 훅
# PreToolUse는 도구 실행 '전'에 동작하며 exit 2로 실제 차단이 가능하다(PostToolUse는 사후라 불가).
# Claude Code가 이벤트 JSON을 STDIN으로 전달 → jq로 command를 추출한다(없으면 원시 grep 폴백).
# 목적: 에이전트의 자동 실행에서 광역 삭제/강제 푸시/하드 리셋 등 파괴적 명령을 사전 차단.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  # jq 미설치 — 전체 입력을 대상으로 보수적으로 검사
  CMD="$INPUT"
fi
[ -z "$CMD" ] && exit 0

# 위험 패턴: 광역 rm -rf(/, ~, $HOME, *, .) / 강제 푸시 / 하드 리셋 / 포크밤 / 디스크 덮어쓰기
if printf '%s' "$CMD" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)[[:space:]]+(/([[:space:]]|$|\*)|~([[:space:]/]|$)|\$HOME|\*([[:space:]]|$)|\.([[:space:]]|$))|git[[:space:]]+push[[:space:]].*(--force([[:space:]]|=)|[[:space:]]-f([[:space:]]|$))|git[[:space:]]+reset[[:space:]]+--hard|:\(\)[[:space:]]*\{[[:space:]]*:|mkfs|[[:space:]]dd[[:space:]]+if='; then
  echo "🛡️  PreToolUse 차단: 위험한 명령 패턴이 감지되었습니다." >&2
  echo "   명령: $CMD" >&2
  echo "   의도적이라면 셸에서 직접 실행하세요(이 가드는 에이전트 자동 실행만 차단합니다)." >&2
  exit 2
fi

exit 0

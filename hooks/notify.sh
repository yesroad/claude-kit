#!/bin/bash
# AI 코딩 에이전트 - 사용자 입력 필요 시 알림
# Claude Code / Cursor / OpenCode 훅에서 자동 호출됨
#
# 환경변수:
#   NOTIFIER_TITLE   - 알림 제목 (기본값: AI Agent)
#   NOTIFIER_MESSAGE - 알림 메시지
#   CLAUDE_NOTIFICATION_TITLE - Claude Code 전용 메시지 (하위 호환)

TITLE="${NOTIFIER_TITLE:-AI Agent}"
MESSAGE="${NOTIFIER_MESSAGE:-${CLAUDE_NOTIFICATION_TITLE:-확인이 필요합니다}}"

case "$(uname -s)" in
  Darwin*)
    # macOS: terminal-notifier 배너 알림 (macOS 15 Sequoia 호환)
    NOTIFIER=$(command -v terminal-notifier || echo "/opt/homebrew/bin/terminal-notifier")
    if [ -x "$NOTIFIER" ]; then
      "$NOTIFIER" -title "$TITLE" -message "$MESSAGE" -sound Glass
    else
      # terminal-notifier 미설치 시 osascript 폴백
      # 값을 argv로 바인딩(문자열 보간 금지) — AppleScript 인젝션 방지
      osascript - "$TITLE" "$MESSAGE" <<'OSA' 2>/dev/null
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name "Glass"
end run
OSA
    fi
    ;;
  Linux*)
    # Linux: notify-send (libnotify) 사용
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$TITLE" "$MESSAGE" 2>/dev/null
    fi
    ;;
esac

# 터미널 벨 소리 (모든 플랫폼 공통 — 터미널 포커스 없을 때 추가 알림)
printf '\a'

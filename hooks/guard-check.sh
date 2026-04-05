#!/bin/bash
# guard-check.sh — PostToolUse 코드 품질 가드레일
# Write/Edit 후 자동 실행. 위반 감지 시 exit 2 (경고, 블로킹 없음)

# 수정된 파일 경로는 환경 변수 또는 stdin으로 전달됨
# TOOL_INPUT_FILE_PATH (Claude Code PostToolUse 환경 변수)
FILE="${TOOL_INPUT_FILE_PATH:-}"

# 코드 파일(.ts/.tsx/.js/.jsx)만 검사
if [ -z "$FILE" ]; then
  exit 0
fi

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# 파일이 존재하지 않으면 건너뜀
[ -f "$FILE" ] || exit 0

VIOLATIONS=""

# 1. any 타입 사용
if grep -qE ": any[^A-Za-z]|<any[^A-Za-z>]" "$FILE" 2>/dev/null; then
  VIOLATIONS="${VIOLATIONS}\n  ⚠️  any 타입 사용 감지 — 구체적인 타입으로 교체하세요"
fi

# 2. TypeScript 오류 억제
if grep -qE "@ts-ignore|@ts-expect-error" "$FILE" 2>/dev/null; then
  VIOLATIONS="${VIOLATIONS}\n  ⚠️  @ts-ignore/@ts-expect-error 감지 — 타입 오류를 직접 수정하세요"
fi

# 3. 하드코딩 자격증명
if grep -qE 'API_KEY\s*=\s*"|SECRET\s*=\s*"|TOKEN\s*=\s*"' "$FILE" 2>/dev/null; then
  VIOLATIONS="${VIOLATIONS}\n  ⚠️  하드코딩 자격증명 감지 — 환경 변수(process.env)로 이동하세요"
fi

# 4. useState로 서버 상태 관리
if grep -q "useState" "$FILE" 2>/dev/null && grep -qE "fetch\(|axios\." "$FILE" 2>/dev/null; then
  VIOLATIONS="${VIOLATIONS}\n  ⚠️  useState + fetch/axios 조합 감지 — TanStack Query 사용을 권장합니다"
fi

# 5. console.log 잔류
if grep -q "console\.log(" "$FILE" 2>/dev/null; then
  VIOLATIONS="${VIOLATIONS}\n  ⚠️  console.log() 감지 — 디버그 로그를 제거하세요"
fi

if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "🛡️  Guard Check: $FILE"
  echo -e "$VIOLATIONS"
  echo ""
  exit 2
fi

exit 0

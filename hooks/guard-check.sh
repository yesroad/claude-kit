#!/bin/bash
# guard-check.sh — PostToolUse 코드 품질 best-effort 린트 (차단 아님)
# Write/Edit 후 자동 실행. 위반 감지 시 exit 2로 '경고'만 출력한다.
# 주의: PostToolUse는 도구 실행 '후'라 차단할 수 없다(차단이 필요하면 PreToolUse).
# 정밀 검사는 ESLint/tsc/gitleaks 같은 AST·전용 도구에 위임하고, 이 훅은 빠른 휴리스틱 보조다.

FILE="${TOOL_INPUT_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac
[ -f "$FILE" ] || exit 0

# 라인 주석(// , * , /*)으로 시작하는 줄은 오탐을 줄이기 위해 제외(완전한 AST 분석은 아님)
CODE=$(grep -vE '^[[:space:]]*(//|\*|/\*)' "$FILE" 2>/dev/null)

VIOLATIONS=""
add() { VIOLATIONS="${VIOLATIONS}\n  ⚠️  $1"; }

# 1. any 타입
printf '%s' "$CODE" | grep -qE ':[[:space:]]*any\b|<any[,> ]' && add "any 타입 — 구체적인 타입으로 교체하세요"
# 2. TypeScript 오류 억제
printf '%s' "$CODE" | grep -qE '@ts-ignore|@ts-expect-error' && add "@ts-ignore/@ts-expect-error — 타입 오류를 직접 수정하세요"
# 3. as any 단언 (이중 공백 포함)
printf '%s' "$CODE" | grep -qE '\bas[[:space:]]+any\b' && add "as any 단언 — 구체적인 타입으로 단언하세요"
# 4. 하드코딩 자격증명 — 따옴표 종류 무관(' " \`)
printf '%s' "$CODE" | grep -qE "(API_KEY|SECRET|TOKEN|PASSWORD|PASSWD)[[:space:]]*[:=][[:space:]]*['\"\`][^'\"\`]{6,}" && add "하드코딩 자격증명(KEY/SECRET/TOKEN) — process.env로 이동하세요"
# 4b. 실제 키 형태(prefix) 직접 탐지
printf '%s' "$CODE" | grep -qE "(sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|sbp_[A-Za-z0-9]{20,}|AKIA[A-Z0-9]{16}|ATATT[A-Za-z0-9_-]{16,})" && add "실제 API 키 형태 감지 — 즉시 제거하고 env로 이동하세요"
# 5. useState로 서버 상태 관리
{ printf '%s' "$CODE" | grep -q "useState" && printf '%s' "$CODE" | grep -qE 'fetch\(|axios\.'; } && add "useState + fetch/axios — TanStack Query 사용을 권장합니다"
# 6. console.log 잔류
printf '%s' "$CODE" | grep -qE 'console\.log\(' && add "console.log() — 디버그 로그를 제거하세요"
# 7. eslint-disable 잔류
printf '%s' "$CODE" | grep -qE 'eslint-disable' && add "eslint-disable — 규칙 비활성화 대신 코드를 수정하세요"
# 8. useEffect 빈 의존성 배열
printf '%s' "$CODE" | grep -qE 'useEffect\(.*,[[:space:]]*\[[[:space:]]*\][[:space:]]*\)' && add "useEffect([], []) 빈 의존성 배열 — 의도적인지 확인하세요"

if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "🛡️  Guard Check (best-effort 경고 · 차단 아님): $FILE"
  echo -e "$VIOLATIONS"
  echo ""
  exit 2
fi

exit 0

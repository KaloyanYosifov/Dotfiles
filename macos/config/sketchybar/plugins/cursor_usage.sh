#!/bin/bash
# Fetches Cursor API usage summary and prints: <plan_pct> <ondemand_pct>
# Requires ~/.cursor_session_cookie containing the full cookie string.

COOKIE_FILE="$HOME/.cursor_session_cookie"

if [ ! -f "$COOKIE_FILE" ]; then
  echo "0 0"
  exit 0
fi

COOKIE="$(cat "$COOKIE_FILE")"

curl -sf 'https://cursor.com/api/usage-summary' \
  -H 'accept: */*' \
  -H 'referer: https://cursor.com/dashboard/usage' \
  -b "$COOKIE" | \
python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    iu = d.get('individualUsage', {})
    plan_pct = iu.get('plan', {}).get('apiPercentUsed', 0) or 0
    od_pct = iu.get('onDemand', {}).get('apiPercentUsed', 0) or 0
    print(plan_pct, od_pct)
except:
    print(0, 0)
" 2>/dev/null || echo "0 0"

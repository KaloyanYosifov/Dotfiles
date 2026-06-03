#!/bin/bash
# Fetches Claude API usage and prints: <five_hour_pct> <seven_day_pct>
# Both numbers are already percentages (0-100).
#
# claude.ai sits behind Cloudflare, which blocks curl's default "curl/x"
# User-Agent (HTTP 403). Sending a browser User-Agent gets plain curl through.
# Config lives in ~/.claude_session.json:
#   {
#     "cookie": "sessionKey=...; lastActiveOrg=00f5a584-...",
#     "org_id": "00f5a584-fd53-4a78-beb8-c8def0029744"
#   }

CONFIG_FILE="$HOME/.claude_session.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "0 0"
  exit 0
fi

# Pull cookie + org_id out of the JSON config (shlex.quote keeps the cookie's
# special chars safe through eval).
eval "$(python3 -c "
import json, shlex
try:
    d = json.load(open('$CONFIG_FILE'))
    print('COOKIE=' + shlex.quote(d.get('cookie', '')))
    print('ORG_ID=' + shlex.quote(d.get('org_id', '')))
except Exception:
    print('COOKIE='); print('ORG_ID=')
" 2>/dev/null)"

if [ -z "$COOKIE" ] || [ -z "$ORG_ID" ]; then
  echo "0 0"
  exit 0
fi

curl -sf "https://claude.ai/api/organizations/$ORG_ID/usage" \
  -H 'anthropic-client-platform: web_claude_ai' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36' \
  -b "$COOKIE" | \
python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    five = (d.get('five_hour') or {}).get('utilization', 0) or 0
    week = (d.get('seven_day') or {}).get('utilization', 0) or 0
    print(five, week)
except:
    print(0, 0)
" 2>/dev/null || echo "0 0"

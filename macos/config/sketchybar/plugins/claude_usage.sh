#!/bin/bash
# Fetches Claude API usage and prints:
#   <five_hour_pct> <five_hour_mins_to_reset> <seven_day_pct> <seven_day_mins_to_reset>
# The percentages are already 0-100; the minutes count down to resets_at.
#
# claude.ai sits behind Cloudflare, which blocks curl's default "curl/x"
# User-Agent (HTTP 403). Sending a browser User-Agent gets plain curl through.
#
# macOS system curl uses LibreSSL/SecureTransport, whose TLS fingerprint
# Cloudflare challenges. The Homebrew curl (OpenSSL) passes, so prefer it when
# present (brew install curl) and fall back to system curl otherwise.
#
# Config lives in ~/.claude_session.json:
#   {
#     "cookie": "sessionKey=...; lastActiveOrg=00f5a584-...",
#     "org_id": "00f5a584-fd53-4a78-beb8-c8def0029744"
#   }

# sketchybar runs under launchd with a minimal PATH; make sure brew-installed
# python3/curl are reachable.
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/curl/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

CONFIG_FILE="$HOME/.claude_session.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "0 0 0 0"
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
  echo "0 0 0 0"
  exit 0
fi

# Prefer Homebrew's OpenSSL curl; fall back to system curl.
CURL="curl"
if [ -x /opt/homebrew/opt/curl/bin/curl ]; then
  CURL="/opt/homebrew/opt/curl/bin/curl"
fi

"$CURL" -sf "https://claude.ai/api/organizations/$ORG_ID/usage" \
  -H 'anthropic-client-platform: web_claude_ai' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36' \
  -b "$COOKIE" | \
python3 -c "
import json, sys
from datetime import datetime, timezone

def mins_left(o):
    r = (o or {}).get('resets_at')
    if not r:
        return 0
    try:
        dt = datetime.fromisoformat(r)
        return max(0, int((dt - datetime.now(timezone.utc)).total_seconds() // 60))
    except Exception:
        return 0

try:
    d = json.load(sys.stdin)
    fh = d.get('five_hour') or {}
    sd = d.get('seven_day') or {}
    five = fh.get('utilization', 0) or 0
    week = sd.get('utilization', 0) or 0
    print(five, mins_left(fh), week, mins_left(sd))
except:
    print(0, 0, 0, 0)
" 2>/dev/null || echo '0 0 0 0'

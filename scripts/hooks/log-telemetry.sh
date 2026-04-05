#!/usr/bin/env bash
# Log telemetry after a skill runs.
# Called by Claude Code as a PostToolUse hook for the Skill tool.
# Receives hook event JSON on stdin.
#
# Handles BOTH local logging (append to telemetry.jsonl) and
# remote sync (Supabase). Skills do NOT need to log themselves.

CONFIG_DIR="$HOME/.curious-stack"
CONFIG_FILE="$CONFIG_DIR/config.json"
TELEMETRY_FILE="$CONFIG_DIR/telemetry.jsonl"

mkdir -p "$CONFIG_DIR"

# Read hook input
INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('skill', ''))
" 2>/dev/null || echo "")

[ -n "$SKILL_NAME" ] || exit 0

# ── Local logging ────────────────────────────────────────────────────
# Append a minimal event. The tool_output has the full analysis but we
# only log metadata — never the actual text.

python3 -c "
import json, sys, datetime

skill = '$SKILL_NAME'
now = datetime.datetime.now(datetime.timezone.utc).isoformat()

event = {
    'event': 'skill.run',
    'skill': skill,
    'timestamp': now,
    'harness': 'claude-code'
}

with open('$TELEMETRY_FILE', 'a') as f:
    f.write(json.dumps(event) + '\n')
" 2>/dev/null || true

# ── Remote sync ──────────────────────────────────────────────────────

[ -f "$CONFIG_FILE" ] || exit 0

ENDPOINT=$(python3 -c "
import json
c = json.load(open('$CONFIG_FILE'))
if c.get('telemetry', False):
    print(c.get('telemetry_endpoint', ''))
else:
    print('')
" 2>/dev/null || echo "")

[ -n "$ENDPOINT" ] || exit 0

# Send the event we just wrote (fire-and-forget)
LAST_EVENT=$(tail -1 "$TELEMETRY_FILE" 2>/dev/null)
if [ -n "$LAST_EVENT" ]; then
  curl -s -X POST "$ENDPOINT" -H "Content-Type: application/json" -d "$LAST_EVENT" &>/dev/null &
fi

exit 0

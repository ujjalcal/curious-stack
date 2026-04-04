#!/usr/bin/env bash
# Log telemetry after a skill runs.
# Called by Claude Code as a PostToolUse hook for the Skill tool.
# Receives hook event JSON on stdin.

CONFIG_DIR="$HOME/.curious-stack"
CONFIG_FILE="$CONFIG_DIR/config.json"
TELEMETRY_FILE="$CONFIG_DIR/telemetry.jsonl"

# Check if telemetry is enabled
if [ -f "$CONFIG_FILE" ]; then
  ENABLED=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('telemetry', False))" 2>/dev/null || echo "False")
  if [ "$ENABLED" != "True" ]; then
    exit 0
  fi
else
  # No config = telemetry off (opt-in)
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract skill name from tool_input
SKILL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
inp = data.get('tool_input', {})
# Skill tool passes skill name as 'skill' parameter
print(inp.get('skill', 'unknown'))
" 2>/dev/null || echo "unknown")

# Skip non-curious-stack skills
KNOWN_SKILLS="ai-slop-detector upgrade-skills create-skill improve-skill eval-skill usage-dashboard"
MATCH=false
for s in $KNOWN_SKILLS; do
  if [ "$SKILL_NAME" = "$s" ]; then
    MATCH=true
    break
  fi
done
[ "$MATCH" = "true" ] || exit 0

# Extract session ID from hook input
SESSION_ID=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('session_id', 'unknown')[:8])
" 2>/dev/null || echo "unknown")

# Build and append telemetry event
python3 -c "
import json, datetime
event = {
    'event': 'skill.run',
    'skill': '$SKILL_NAME',
    'timestamp': datetime.datetime.utcnow().isoformat() + 'Z',
    'session_id': '$SESSION_ID'
}
with open('$TELEMETRY_FILE', 'a') as f:
    f.write(json.dumps(event) + '\n')
" 2>/dev/null || true

# Remote sync (fire-and-forget)
if [ -f "$CONFIG_FILE" ]; then
  ENDPOINT=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('telemetry_endpoint', ''))" 2>/dev/null || echo "")
  if [ -n "$ENDPOINT" ]; then
    # Read last line we just wrote
    LAST_EVENT=$(tail -1 "$TELEMETRY_FILE" 2>/dev/null)
    if [ -n "$LAST_EVENT" ]; then
      curl -s -X POST "$ENDPOINT" -H "Content-Type: application/json" -d "$LAST_EVENT" &>/dev/null &
    fi
  fi
fi

exit 0

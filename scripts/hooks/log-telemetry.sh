#!/usr/bin/env bash
# Sync telemetry to remote after a skill runs.
# Called by Claude Code as a PostToolUse hook for the Skill tool.
# Receives hook event JSON on stdin.
#
# Local telemetry (enriched events with verdict/lengths) is written
# by each skill's SKILL.md instructions. This hook only handles
# remote sync to Supabase.

CONFIG_DIR="$HOME/.curious-stack"
CONFIG_FILE="$CONFIG_DIR/config.json"
TELEMETRY_FILE="$CONFIG_DIR/telemetry.jsonl"

# Check if telemetry is enabled + endpoint exists
if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi

ENDPOINT=$(python3 -c "
import json
c = json.load(open('$CONFIG_FILE'))
if c.get('telemetry', False):
    print(c.get('telemetry_endpoint', ''))
else:
    print('')
" 2>/dev/null || echo "")

[ -n "$ENDPOINT" ] || exit 0
[ -f "$TELEMETRY_FILE" ] || exit 0

# Read hook input to check if this is a known skill
INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('skill', ''))
" 2>/dev/null || echo "")

KNOWN_SKILLS="ai-slop-detector upgrade-skills create-skill improve-skill eval-skill usage-dashboard"
MATCH=false
for s in $KNOWN_SKILLS; do
  [ "$SKILL_NAME" = "$s" ] && MATCH=true && break
done
[ "$MATCH" = "true" ] || exit 0

# Sync the most recent event for this skill (fire-and-forget)
# The skill appends enriched events; we send the last one
LAST_EVENT=$(grep "\"skill\":\"$SKILL_NAME\"" "$TELEMETRY_FILE" 2>/dev/null | tail -1)
if [ -n "$LAST_EVENT" ]; then
  curl -s -X POST "$ENDPOINT" -H "Content-Type: application/json" -d "$LAST_EVENT" &>/dev/null &
fi

exit 0

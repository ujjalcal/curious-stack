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

INPUT=$(cat)

# Single python3 call: parse input, write local event, return endpoint + event JSON
RESULT=$(echo "$INPUT" | python3 -c "
import json, sys, datetime, os

data = json.load(sys.stdin)
skill = data.get('tool_input', {}).get('skill', '')
if not skill:
    sys.exit(0)

now = datetime.datetime.now(datetime.timezone.utc).isoformat()
event = {'event': 'skill.run', 'skill': skill, 'timestamp': now, 'harness': 'claude-code'}
event_json = json.dumps(event)

telemetry_file = os.path.join(os.path.expanduser('~'), '.curious-stack', 'telemetry.jsonl')
with open(telemetry_file, 'a') as f:
    f.write(event_json + '\n')

config_file = os.path.join(os.path.expanduser('~'), '.curious-stack', 'config.json')
endpoint = ''
if os.path.isfile(config_file):
    try:
        c = json.load(open(config_file))
        if c.get('telemetry', False):
            endpoint = c.get('telemetry_endpoint', '')
    except Exception:
        pass

print(endpoint)
print(event_json)
" 2>/dev/null) || exit 0

ENDPOINT=$(echo "$RESULT" | head -1)
EVENT_JSON=$(echo "$RESULT" | tail -1)

[ -n "$ENDPOINT" ] || exit 0
[ -n "$EVENT_JSON" ] || exit 0

curl -s -X POST "$ENDPOINT" -H "Content-Type: application/json" -d "$EVENT_JSON" &>/dev/null &

exit 0

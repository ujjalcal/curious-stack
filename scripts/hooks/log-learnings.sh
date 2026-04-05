#!/usr/bin/env bash
# Log per-project learnings after a skill runs.
# Called by Claude Code as a PostToolUse hook for the Skill tool.
# Copies the latest telemetry entry to a project-specific learnings file.

CONFIG_DIR="$HOME/.curious-stack"
TELEMETRY_FILE="$CONFIG_DIR/telemetry.jsonl"
PROJECTS_DIR="$CONFIG_DIR/projects"

# Determine project slug from git repo name or cwd
PROJECT_SLUG=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || basename "$PWD")
[ -z "$PROJECT_SLUG" ] && exit 0

# Read hook input to check if this is a known skill
INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('skill', ''))
" 2>/dev/null || echo "")

KNOWN_SKILLS="ai-slop-detector feed-scanner"
MATCH=false
for s in $KNOWN_SKILLS; do
  [ "$SKILL_NAME" = "$s" ] && MATCH=true && break
done
[ "$MATCH" = "true" ] || exit 0

# Wait briefly for the skill's telemetry append to complete
sleep 1

# Find the latest telemetry entry for this skill
[ -f "$TELEMETRY_FILE" ] || exit 0
LATEST=$(grep "\"skill\":\"$SKILL_NAME\"" "$TELEMETRY_FILE" 2>/dev/null | tail -1)
[ -n "$LATEST" ] || exit 0

# Append to project-specific learnings
mkdir -p "$PROJECTS_DIR/$PROJECT_SLUG"
echo "$LATEST" >> "$PROJECTS_DIR/$PROJECT_SLUG/learnings.jsonl"

exit 0

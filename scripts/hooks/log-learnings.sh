#!/usr/bin/env bash
# Log per-project learnings after a skill runs.
# Called by Claude Code as a PostToolUse hook for the Skill tool.
# Copies the latest telemetry entry to a project-specific learnings file.
#
# Note: stdin may be consumed by an earlier hook (log-telemetry.sh),
# so this hook reads from telemetry.jsonl instead of stdin.

CONFIG_DIR="$HOME/.curious-stack"
TELEMETRY_FILE="$CONFIG_DIR/telemetry.jsonl"
PROJECTS_DIR="$CONFIG_DIR/projects"

# Determine project slug from git repo name or cwd
PROJECT_SLUG=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || basename "$PWD")
[ -z "$PROJECT_SLUG" ] && exit 0

# Sanitize: allow only alphanumeric, hyphens, underscores, dots
PROJECT_SLUG=$(echo "$PROJECT_SLUG" | tr -cd 'a-zA-Z0-9._-')
[ -z "$PROJECT_SLUG" ] && exit 0

# Wait briefly for the telemetry hook to finish writing
sleep 1

# Read the latest telemetry entry (written by log-telemetry.sh)
[ -f "$TELEMETRY_FILE" ] || exit 0
LATEST=$(tail -1 "$TELEMETRY_FILE" 2>/dev/null)
[ -n "$LATEST" ] || exit 0

# Check if it's a known user skill
SKILL_NAME=$(echo "$LATEST" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('skill', ''))
" 2>/dev/null || echo "")

KNOWN_SKILLS="ai-slop-detector claim-checker jargon-detector structure-critic tone-audit originality-score llm-ready full-review feed-scanner"
MATCH=false
for s in $KNOWN_SKILLS; do
  [ "$SKILL_NAME" = "$s" ] && MATCH=true && break
done
[ "$MATCH" = "true" ] || exit 0

# Append to project-specific learnings
mkdir -p "$PROJECTS_DIR/$PROJECT_SLUG"
echo "$LATEST" >> "$PROJECTS_DIR/$PROJECT_SLUG/learnings.jsonl"

exit 0

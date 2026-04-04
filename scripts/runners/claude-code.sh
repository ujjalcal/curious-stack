#!/usr/bin/env bash
set -euo pipefail

# Runner: invoke a skill via Claude Code CLI.
# Usage: claude-code.sh <prompt_file> <input_text>

PROMPT_FILE="$1"
INPUT="$2"

PROMPT=$(cat "$PROMPT_FILE")

claude -p "${PROMPT}

---

Analyze this text:

${INPUT}" 2>/dev/null

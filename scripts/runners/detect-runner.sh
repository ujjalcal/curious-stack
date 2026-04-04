#!/usr/bin/env bash
set -euo pipefail

# Detect available LLM runner.
# Prints the runner name to stdout. Exits 1 if nothing found.

if command -v claude &>/dev/null; then
  echo "claude-code"
elif command -v codex &>/dev/null; then
  echo "codex"
elif [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  echo "api-anthropic"
elif [ -n "${OPENAI_API_KEY:-}" ]; then
  echo "api-openai"
else
  echo "none"
  exit 1
fi

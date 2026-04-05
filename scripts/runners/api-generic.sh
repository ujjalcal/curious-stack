#!/usr/bin/env bash
set -euo pipefail

# Runner: invoke a skill via direct API call.
# Usage: api-generic.sh <prompt_file> <input_text>
#
# Environment:
#   ANTHROPIC_API_KEY or OPENAI_API_KEY — required
#   EVAL_MODEL — optional (default: claude-sonnet-4-20250514)

PROMPT_FILE="$1"
INPUT="$2"
PROMPT=$(cat "$PROMPT_FILE")

MODEL="${EVAL_MODEL:-claude-sonnet-4-20250514}"

FULL_PROMPT="${PROMPT}

---

Analyze this text:

${INPUT}"

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  # Anthropic API — pass prompt via env var to avoid shell injection
  PAYLOAD=$(FULL_PROMPT="$FULL_PROMPT" MODEL="$MODEL" python3 -c "
import json, os
print(json.dumps({
    'model': os.environ['MODEL'],
    'max_tokens': 1024,
    'messages': [{'role': 'user', 'content': os.environ['FULL_PROMPT']}]
}))
")

  RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$PAYLOAD")

  echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for block in data.get('content', []):
    if block.get('type') == 'text':
        print(block['text'])
"

elif [ -n "${OPENAI_API_KEY:-}" ]; then
  # OpenAI-compatible API
  OPENAI_BASE="${OPENAI_BASE_URL:-https://api.openai.com/v1}"
  OAI_MODEL="${EVAL_MODEL:-gpt-4o}"

  PAYLOAD=$(FULL_PROMPT="$FULL_PROMPT" MODEL="$OAI_MODEL" python3 -c "
import json, os
print(json.dumps({
    'model': os.environ['MODEL'],
    'max_tokens': 1024,
    'messages': [{'role': 'user', 'content': os.environ['FULL_PROMPT']}]
}))
")

  RESPONSE=$(curl -s "$OPENAI_BASE/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

  echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data['choices'][0]['message']['content'])
"

else
  echo "ERROR: No API key found. Set ANTHROPIC_API_KEY or OPENAI_API_KEY." >&2
  exit 1
fi

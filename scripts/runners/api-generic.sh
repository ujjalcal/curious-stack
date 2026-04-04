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

# Build JSON payload safely via python3, passing all values through env vars
# to avoid shell injection from filenames or prompt content.
build_payload() {
  local model="$1"
  SKILL_PROMPT_FILE="$PROMPT_FILE" SKILL_INPUT="$INPUT" SKILL_MODEL="$model" \
    python3 -c "
import json, os
prompt = open(os.environ['SKILL_PROMPT_FILE']).read()
full = prompt + '\n\n---\n\nAnalyze this text:\n\n' + os.environ['SKILL_INPUT']
print(json.dumps({
    'model': os.environ['SKILL_MODEL'],
    'max_tokens': 1024,
    'messages': [{'role': 'user', 'content': full}]
}))
"
}

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  MODEL="${EVAL_MODEL:-claude-sonnet-4-20250514}"

  RESPONSE=$(build_payload "$MODEL" | curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d @-)

  echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for block in data.get('content', []):
    if block.get('type') == 'text':
        print(block['text'])
"

elif [ -n "${OPENAI_API_KEY:-}" ]; then
  OPENAI_BASE="${OPENAI_BASE_URL:-https://api.openai.com/v1}"
  OAI_MODEL="${EVAL_MODEL:-gpt-4o}"

  RESPONSE=$(build_payload "$OAI_MODEL" | curl -s "$OPENAI_BASE/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d @-)

  echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data['choices'][0]['message']['content'])
"

else
  echo "ERROR: No API key found. Set ANTHROPIC_API_KEY or OPENAI_API_KEY." >&2
  exit 1
fi

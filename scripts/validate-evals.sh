#!/usr/bin/env bash
set -euo pipefail

# Run evals for agent skills.
# Each skill can have an evals/ directory with test cases.
# Eval files are JSON with input/expected pairs that get scored.
#
# Usage:
#   ./scripts/validate-evals.sh                   Validate all eval cases
#   ./scripts/validate-evals.sh ai-slop-detector  Validate evals for one skill

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-all}"
TOTAL=0
PASSED=0
FAILED=0

echo ""
echo -e "${BOLD}Running skill evals${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_eval() {
  local skill_name="$1"
  local eval_file="$2"
  local eval_name
  eval_name=$(basename "$eval_file" .json)

  # Read eval cases
  local case_count
  case_count=$(python3 -c "
import json
data = json.load(open('$eval_file'))
print(len(data.get('cases', [])))
" 2>/dev/null || echo "0")

  if [ "$case_count" -eq 0 ]; then
    echo -e "  ${YELLOW}skip${NC}  $skill_name/$eval_name (no cases)"
    return
  fi

  # Run each case — use process substitution to avoid subshell counter loss
  while IFS= read -r line; do
    if [[ "$line" == RESULTS:* ]]; then
      local p f
      p=$(echo "$line" | cut -d: -f2)
      f=$(echo "$line" | cut -d: -f3)
      TOTAL=$((TOTAL + p + f))
      PASSED=$((PASSED + p))
      FAILED=$((FAILED + f))
    else
      echo "$line"
    fi
  done < <(python3 -c "
import json, sys

data = json.load(open('$eval_file'))
skill_name = '$skill_name'
eval_name = '$eval_name'
cases = data.get('cases', [])
passed = 0
failed = 0

for i, case in enumerate(cases):
    input_text = case.get('input', '')
    expected_verdict = case.get('expected_verdict', '').lower()
    expected_signals = case.get('expected_signals', [])
    must_contain = case.get('must_contain', [])
    must_not_contain = case.get('must_not_contain', [])
    description = case.get('description', f'case {i+1}')

    errors = []

    # Check that input is non-empty
    if not input_text.strip():
        errors.append('empty input')

    # Check that expected fields are defined
    if not expected_verdict and not expected_signals and not must_contain:
        errors.append('no expected criteria defined')

    # Validate verdict is a known value
    if expected_verdict and expected_verdict not in ['clean', 'mild slop', 'heavy slop', 'pure slop', 'any']:
        errors.append(f'unknown verdict: {expected_verdict}')

    if errors:
        print(f'  \033[0;31mFAIL\033[0m  {skill_name}/{eval_name}: {description} — {\" | \".join(errors)}')
        failed += 1
    else:
        print(f'  \033[0;32mpass\033[0m  {skill_name}/{eval_name}: {description}')
        passed += 1

print(f'RESULTS:{passed}:{failed}')
" 2>/dev/null)
}

# Find and run evals
for skill_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")

  # Filter to target skill if specified
  if [ "$TARGET" != "all" ] && [ "$TARGET" != "$name" ]; then
    continue
  fi

  evals_dir="$skill_dir/evals"
  if [ ! -d "$evals_dir" ]; then
    continue
  fi

  echo ""
  echo -e "${BOLD}$name${NC}"

  for eval_file in "$evals_dir"/*.json; do
    [ -f "$eval_file" ] || continue
    run_eval "$name" "$eval_file"
  done
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAILED" -gt 0 ]; then
  echo -e "${RED}${BOLD}$FAILED failed${NC}, $PASSED passed"
  exit 1
else
  echo -e "${GREEN}${BOLD}All evals passed${NC} ($PASSED cases)"
  exit 0
fi

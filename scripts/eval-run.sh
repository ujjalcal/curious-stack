#!/usr/bin/env bash
set -euo pipefail

# Live eval runner for agent skills.
# Runs skill prompts against test inputs, judges output, reports results.
#
# Usage:
#   eval-run.sh <skill-name>                    Run evals for one skill
#   eval-run.sh                                 Run evals for all skills
#   eval-run.sh <skill-name> --dry-run          Show what would run
#   eval-run.sh <skill-name> --runs 5           Override runs per case
#   eval-run.sh <skill-name> --runner api       Force a specific runner
#   eval-run.sh <skill-name> --no-judge         Skip LLM-as-judge (Tier 3)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
RUNNERS_DIR="$SCRIPTS_DIR/runners"

# Defaults
TARGET="${1:-all}"
DRY_RUN=false
RUNS_OVERRIDE=""
RUNNER_OVERRIDE="auto"
JUDGE_RUNNER="auto"

# Parse args
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --runs) RUNS_OVERRIDE="$2"; shift 2 ;;
    --runner) RUNNER_OVERRIDE="$2"; shift 2 ;;
    --no-judge) JUDGE_RUNNER="skip"; shift ;;
    *) shift ;;
  esac
done

# Detect runner
RUNNER="$RUNNER_OVERRIDE"
if [ "$RUNNER" = "auto" ]; then
  RUNNER=$("$RUNNERS_DIR/detect-runner.sh" 2>/dev/null || echo "none")
fi

if [ "$RUNNER" = "none" ] && [ "$DRY_RUN" = "false" ]; then
  echo -e "${RED}No LLM runner available.${NC}"
  echo "Install Claude Code CLI, Codex CLI, or set ANTHROPIC_API_KEY / OPENAI_API_KEY."
  exit 1
fi

# Pick runner script
case "$RUNNER" in
  claude-code) RUNNER_SCRIPT="$RUNNERS_DIR/claude-code.sh" ;;
  api-*) RUNNER_SCRIPT="$RUNNERS_DIR/api-generic.sh" ;;
  *) RUNNER_SCRIPT="" ;;
esac

echo ""
echo -e "${BOLD}Live Skill Evals${NC}"
echo -e "Runner: ${GREEN}$RUNNER${NC}  Judge: ${GREEN}$JUDGE_RUNNER${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_CASES=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_FLAKY=0

run_skill_evals() {
  local skill_name="$1"
  local skill_dir="$REPO_ROOT/skills/$skill_name"
  local prompt_file="$skill_dir/prompt.md"
  local manifest="$skill_dir/manifest.json"
  local evals_dir="$skill_dir/evals"
  local results_dir="$evals_dir/results"

  if [ ! -d "$evals_dir" ]; then
    return
  fi

  # Get skill description for judge
  local skill_desc=""
  if [ -f "$manifest" ]; then
    skill_desc=$(python3 -c "import json; print(json.load(open('$manifest')).get('description', ''))" 2>/dev/null || echo "")
  fi

  echo ""
  echo -e "${BOLD}$skill_name${NC}"

  mkdir -p "$results_dir"

  local skill_results="[]"

  for eval_file in "$evals_dir"/*.json; do
    [ -f "$eval_file" ] || continue
    [ "$(basename "$eval_file")" = "results" ] && continue

    # Read config
    local runs_per_case
    runs_per_case=$(python3 -c "
import json
data = json.load(open('$eval_file'))
print(data.get('config', {}).get('runs_per_case', 3))
" 2>/dev/null || echo "3")

    local pass_threshold
    pass_threshold=$(python3 -c "
import json
data = json.load(open('$eval_file'))
print(data.get('config', {}).get('pass_threshold', 0.67))
" 2>/dev/null || echo "0.67")

    # Override runs if specified
    if [ -n "$RUNS_OVERRIDE" ]; then
      runs_per_case="$RUNS_OVERRIDE"
    fi

    # Get cases
    local case_count
    case_count=$(python3 -c "
import json
data = json.load(open('$eval_file'))
print(len(data.get('cases', [])))
" 2>/dev/null || echo "0")

    for case_idx in $(seq 0 $((case_count - 1))); do
      local case_json
      case_json=$(python3 -c "
import json
data = json.load(open('$eval_file'))
print(json.dumps(data['cases'][$case_idx]))
" 2>/dev/null)

      local case_id
      case_id=$(echo "$case_json" | python3 -c "import json,sys; c=json.load(sys.stdin); print(c.get('id', c.get('description', 'case-$case_idx')))")

      local case_input
      case_input=$(echo "$case_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('input', ''))")

      if [ "$DRY_RUN" = "true" ]; then
        echo -e "  ${YELLOW}dry${NC}   $case_id  (${runs_per_case} runs)"
        TOTAL_CASES=$((TOTAL_CASES + 1))
        continue
      fi

      # Run N times
      local run_passes=0
      local run_total=0
      local run_scores=""
      local last_output=""

      for run_num in $(seq 1 "$runs_per_case"); do
        run_total=$((run_total + 1))

        # Execute skill
        local output_file
        output_file=$(mktemp)

        if ! "$RUNNER_SCRIPT" "$prompt_file" "$case_input" > "$output_file" 2>/dev/null; then
          echo "ERROR" > "$output_file"
        fi

        last_output=$(cat "$output_file")

        # Judge output
        local judge_result
        judge_result=$(python3 "$SCRIPTS_DIR/eval-judge.py" \
          "$output_file" \
          "$case_json" \
          --skill-description "$skill_desc" \
          --judge-runner "$JUDGE_RUNNER" 2>/dev/null || echo '{"scoring":{"passed":false,"score":0}}')

        local run_passed
        run_passed=$(echo "$judge_result" | python3 -c "import json,sys; print(json.load(sys.stdin)['scoring']['passed'])" 2>/dev/null || echo "False")

        local run_score
        run_score=$(echo "$judge_result" | python3 -c "import json,sys; print(json.load(sys.stdin)['scoring']['score'])" 2>/dev/null || echo "0")

        if [ "$run_passed" = "True" ]; then
          run_passes=$((run_passes + 1))
        fi
        run_scores="$run_scores $run_score"

        # Save run output
        cp "$output_file" "$results_dir/${case_id}-run${run_num}.txt" 2>/dev/null || true
        rm -f "$output_file"
      done

      # Compute case result
      local pass_ratio
      pass_ratio=$(python3 -c "print(round($run_passes / $run_total, 2))")

      local case_passed
      case_passed=$(python3 -c "print('yes' if $run_passes / $run_total >= $pass_threshold else 'no')")

      local avg_score
      avg_score=$(python3 -c "scores = [$run_scores]; print(round(sum(scores)/len(scores), 2) if scores else 0)")

      TOTAL_CASES=$((TOTAL_CASES + 1))

      if [ "$case_passed" = "yes" ]; then
        if [ "$run_passes" -lt "$run_total" ]; then
          echo -e "  ${GREEN}PASS${NC}  $case_id  ${run_passes}/${run_total}  score=${avg_score} ${YELLOW}(flaky)${NC}"
          TOTAL_PASSED=$((TOTAL_PASSED + 1))
          TOTAL_FLAKY=$((TOTAL_FLAKY + 1))
        else
          echo -e "  ${GREEN}PASS${NC}  $case_id  ${run_passes}/${run_total}  score=${avg_score}"
          TOTAL_PASSED=$((TOTAL_PASSED + 1))
        fi
      else
        echo -e "  ${RED}FAIL${NC}  $case_id  ${run_passes}/${run_total}  score=${avg_score}"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
      fi

      # Append to skill results
      skill_results=$(echo "$skill_results" | python3 -c "
import json, sys
results = json.load(sys.stdin)
results.append({
    'case_id': '$case_id',
    'runs': $run_total,
    'passes': $run_passes,
    'pass_ratio': $pass_ratio,
    'avg_score': $avg_score,
    'passed': '$case_passed' == 'yes',
    'flaky': $run_passes > 0 and $run_passes < $run_total,
})
print(json.dumps(results))
")
    done
  done

  # Save results
  if [ "$DRY_RUN" = "false" ] && [ "$skill_results" != "[]" ]; then
    echo "$skill_results" | python3 -c "
import json, sys
from datetime import datetime
results = json.load(sys.stdin)
output = {
    'skill': '$skill_name',
    'runner': '$RUNNER',
    'timestamp': datetime.utcnow().isoformat() + 'Z',
    'cases': results,
    'summary': {
        'total': len(results),
        'passed': sum(1 for r in results if r['passed']),
        'failed': sum(1 for r in results if not r['passed']),
        'flaky': sum(1 for r in results if r.get('flaky')),
        'avg_score': round(sum(r['avg_score'] for r in results) / len(results), 2) if results else 0,
    }
}
print(json.dumps(output, indent=2))
" > "$results_dir/latest.json"
  fi
}

# Run evals
for skill_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")

  if [ "$TARGET" != "all" ] && [ "$TARGET" != "$name" ]; then
    continue
  fi

  if [ -d "$skill_dir/evals" ] && ls "$skill_dir/evals"/*.json &>/dev/null; then
    run_skill_evals "$name"
  fi
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = "true" ]; then
  echo -e "${BOLD}Dry run:${NC} $TOTAL_CASES case(s) would run"
elif [ "$TOTAL_FAILED" -gt 0 ]; then
  echo -e "${RED}${BOLD}$TOTAL_FAILED failed${NC}, $TOTAL_PASSED passed"
  [ "$TOTAL_FLAKY" -gt 0 ] && echo -e "  ${YELLOW}$TOTAL_FLAKY flaky${NC}"
  exit 1
elif [ "$TOTAL_CASES" -gt 0 ]; then
  echo -e "${GREEN}${BOLD}All $TOTAL_PASSED case(s) passed${NC}"
  [ "$TOTAL_FLAKY" -gt 0 ] && echo -e "  ${YELLOW}$TOTAL_FLAKY flaky${NC}"
else
  echo "No eval cases found."
fi
echo ""

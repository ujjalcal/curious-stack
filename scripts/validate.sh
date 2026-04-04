#!/usr/bin/env bash
set -euo pipefail

# Validate all skills in the registry.
# Checks: manifest structure, SKILL.md quality, registry consistency, eval coverage.
# Quality criteria defined in references/skill-writing-guide.md.
# Exit 1 on any failure — designed to run as a pre-commit hook or in CI.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$REPO_ROOT/registry.json"
ERRORS=0
WARNINGS=0

pass() { echo -e "  ${GREEN}pass${NC}  $*"; }
fail() { echo -e "  ${RED}FAIL${NC}  $*"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}warn${NC}  $*"; WARNINGS=$((WARNINGS + 1)); }

echo ""
echo -e "${BOLD}Validating agent-skills${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Registry checks ───────────────────────────────────────────────

echo ""
echo -e "${BOLD}Registry${NC}"

if [ ! -f "$REGISTRY" ]; then
  fail "registry.json not found"
else
  # Valid JSON?
  if python3 -c "import json; json.load(open('$REGISTRY'))" 2>/dev/null; then
    pass "registry.json is valid JSON"
  else
    fail "registry.json is not valid JSON"
  fi

  # Every skill in registry has a directory?
  for skill_name in $(python3 -c "
import json
data = json.load(open('$REGISTRY'))
for s in data.get('skills', []):
    print(s['name'])
" 2>/dev/null); do
    skill_dir="$REPO_ROOT/skills/$skill_name"
    if [ -d "$skill_dir" ]; then
      pass "registry entry '$skill_name' has matching directory"
    else
      fail "registry entry '$skill_name' has no directory at skills/$skill_name/"
    fi
  done

  # Every skill directory is in the registry?
  for skill_dir in "$REPO_ROOT"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    if python3 -c "
import json, sys
data = json.load(open('$REGISTRY'))
if not any(s['name'] == '$name' for s in data.get('skills', [])):
    sys.exit(1)
" 2>/dev/null; then
      pass "directory '$name' is registered"
    else
      fail "directory 'skills/$name/' exists but is not in registry.json"
    fi
  done
fi

# ── 2. Per-skill checks ──────────────────────────────────────────────

for skill_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")

  echo ""
  echo -e "${BOLD}Skill: $name${NC}"

  manifest="$skill_dir/manifest.json"
  prompt="$skill_dir/SKILL.md"
  evals_dir="$skill_dir/evals"

  # manifest.json exists and is valid JSON?
  if [ ! -f "$manifest" ]; then
    fail "manifest.json missing"
  elif ! python3 -c "import json; json.load(open('$manifest'))" 2>/dev/null; then
    fail "manifest.json is not valid JSON"
  else
    pass "manifest.json valid"

    # Required fields present?
    python3 -c "
import json, sys
m = json.load(open('$manifest'))
required = ['name', 'version', 'description', 'author', 'harnesses', 'entry']
missing = [f for f in required if f not in m]
if missing:
    print('MISSING:' + ','.join(missing))
    sys.exit(1)
" 2>/dev/null && pass "manifest has all required fields" || fail "manifest missing required fields: $(python3 -c "
import json
m = json.load(open('$manifest'))
required = ['name', 'version', 'description', 'author', 'harnesses', 'entry']
print(', '.join(f for f in required if f not in m))
" 2>/dev/null)"

    # Name matches directory?
    manifest_name=$(python3 -c "import json; print(json.load(open('$manifest'))['name'])" 2>/dev/null || echo "")
    if [ "$manifest_name" = "$name" ]; then
      pass "manifest name matches directory"
    else
      fail "manifest name '$manifest_name' does not match directory '$name'"
    fi

    # Version is semver?
    if python3 -c "
import json, re, sys
v = json.load(open('$manifest')).get('version', '')
if not re.match(r'^\d+\.\d+\.\d+$', v):
    sys.exit(1)
" 2>/dev/null; then
      pass "version is valid semver"
    else
      fail "version is not valid semver (expected X.Y.Z)"
    fi

    # Description under 200 chars?
    desc_len=$(python3 -c "import json; print(len(json.load(open('$manifest')).get('description', '')))" 2>/dev/null || echo "0")
    if [ "$desc_len" -le 200 ]; then
      pass "description length ok ($desc_len chars)"
    else
      warn "description is $desc_len chars (keep under 200)"
    fi
  fi

  # SKILL.md exists and has content?
  if [ ! -f "$prompt" ]; then
    fail "SKILL.md missing"
  else
    line_count=$(wc -l < "$prompt")
    if [ "$line_count" -gt 5 ]; then
      pass "SKILL.md has content ($line_count lines)"
    else
      fail "SKILL.md is too short ($line_count lines — is it a stub?)"
    fi

    # Has YAML frontmatter?
    if head -1 "$prompt" | grep -q '^---'; then
      pass "SKILL.md has YAML frontmatter"
      # Check for required frontmatter fields (name, description)
      if head -20 "$prompt" | grep -q '^name:'; then
        pass "frontmatter has name field"
      else
        fail "SKILL.md frontmatter missing 'name' field"
      fi
      if head -20 "$prompt" | grep -q '^description:'; then
        pass "frontmatter has description field"
      else
        fail "SKILL.md frontmatter missing 'description' field"
      fi
    else
      fail "SKILL.md missing YAML frontmatter (see references/skill-writing-guide.md)"
    fi

    # Has a heading?
    if grep -q '^# ' "$prompt"; then
      pass "SKILL.md has a heading"
    else
      warn "SKILL.md has no heading"
    fi

    # Has a steps/process section?
    if grep -qi '^\(##\|###\).*\(step\|process\|workflow\|how\|rules\|format\)' "$prompt"; then
      pass "SKILL.md has structured sections"
    else
      warn "SKILL.md may lack structured sections (Steps, Rules, Format)"
    fi

    # Frontmatter name matches manifest name?
    if [ -f "$manifest" ]; then
      fm_name=$(head -20 "$prompt" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//')
      mf_name=$(python3 -c "import json; print(json.load(open('$manifest'))['name'])" 2>/dev/null || echo "")
      if [ -n "$fm_name" ] && [ -n "$mf_name" ]; then
        if [ "$fm_name" = "$mf_name" ]; then
          pass "SKILL.md frontmatter name matches manifest"
        else
          fail "SKILL.md frontmatter name '$fm_name' != manifest name '$mf_name'"
        fi
      fi

      # Frontmatter description matches manifest description?
      fm_desc=$(head -20 "$prompt" | grep '^description:' | head -1 | sed 's/^description:[[:space:]]*//')
      mf_desc=$(python3 -c "import json; print(json.load(open('$manifest'))['description'])" 2>/dev/null || echo "")
      if [ -n "$fm_desc" ] && [ -n "$mf_desc" ]; then
        if [ "$fm_desc" = "$mf_desc" ]; then
          pass "SKILL.md frontmatter description matches manifest"
        else
          warn "SKILL.md frontmatter description differs from manifest"
        fi
      fi
    fi

    # Referenced files exist?
    ref_files=$(grep -oE '`(references/[^`]+|scripts/[^`]+|evals/[^`]+)`' "$prompt" 2>/dev/null | tr -d '`' | sort -u || true)
    if [ -n "$ref_files" ]; then
      while IFS= read -r ref; do
        # Skip template paths like skills/<name>/evals/ or results/latest.json
        if echo "$ref" | grep -qE '<|results/latest'; then
          continue
        fi
        if [ -e "$REPO_ROOT/$ref" ]; then
          pass "referenced file exists: $ref"
        else
          fail "referenced file missing: $ref"
        fi
      done <<< "$ref_files"
    fi

    # No inline telemetry instructions (should be in infra, not skills)?
    # Skip usage-dashboard — reading telemetry is its purpose.
    if [ "$name" != "usage-dashboard" ]; then
      if grep -qi 'telemetry-ingest\|telemetry_endpoint\|POST.*telemetry' "$prompt" 2>/dev/null; then
        fail "SKILL.md contains inline telemetry instructions (move to infra)"
      fi
    fi
  fi

  # Manifest description matches registry description?
  if [ -f "$manifest" ] && [ -f "$REGISTRY" ]; then
    mf_desc=$(python3 -c "import json; print(json.load(open('$manifest'))['description'])" 2>/dev/null || echo "")
    reg_desc=$(python3 -c "
import json
data = json.load(open('$REGISTRY'))
s = next((x for x in data.get('skills', []) if x['name'] == '$name'), None)
print(s['description'] if s else '')
" 2>/dev/null || echo "")
    if [ -n "$mf_desc" ] && [ -n "$reg_desc" ]; then
      if [ "$mf_desc" = "$reg_desc" ]; then
        pass "manifest description matches registry"
      else
        warn "manifest description differs from registry.json"
      fi
    fi
  fi

  # Evals exist?
  if [ -d "$evals_dir" ] && [ "$(ls -A "$evals_dir" 2>/dev/null)" ]; then
    eval_count=$(find "$evals_dir" -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.md' | wc -l)
    pass "has $eval_count eval(s)"
  else
    warn "no evals found — add evals/ with test cases"
  fi
done

# ── Summary ───────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}${BOLD}$ERRORS error(s)${NC}, $WARNINGS warning(s)"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e "${GREEN}${BOLD}All checks passed${NC} with $WARNINGS warning(s)"
  exit 0
else
  echo -e "${GREEN}${BOLD}All checks passed${NC}"
  exit 0
fi

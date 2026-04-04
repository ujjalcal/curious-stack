#!/usr/bin/env bash
set -euo pipefail

# curious-stack — install agent skills into any AI coding harness
#
# Remote one-liner:
#   curl -sL https://raw.githubusercontent.com/ujjalcal/curious-stack/main/scripts/install.sh | bash -s -- <skill-name>
#
# Local usage:
#   ./scripts/install.sh <skill-name>              Install a skill
#   ./scripts/install.sh --list                    List available skills
#   ./scripts/install.sh --search <query>          Search skills by name/tag
#   ./scripts/install.sh --info <skill-name>       Show skill details
#   ./scripts/install.sh --installed               Show installed skills
#   ./scripts/install.sh --update                  Update all installed skills
#   ./scripts/install.sh --uninstall <skill-name>  Remove an installed skill
#   ./scripts/install.sh --harness <name>          Target harness (default: auto-detect)

REGISTRY_URL="https://raw.githubusercontent.com/ujjalcal/curious-stack/main/registry.json"
REGISTRY_REPO="https://github.com/ujjalcal/curious-stack.git"

# Defaults
HARNESS=""
SKILLS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/curious-stack"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC} $*"; }
ok()    { echo -e "${GREEN}[ok]${NC} $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $*"; }
err()   { echo -e "${RED}[error]${NC} $*" >&2; }

# ── Harness Detection ─────────────────────────────────────────────────────

detect_harness() {
  if [ -n "$HARNESS" ]; then
    echo "$HARNESS"
    return
  fi

  # Claude Code
  if [ -d ".claude" ] || command -v claude &>/dev/null; then
    echo "claude-code"
    return
  fi

  # Codex
  if [ -f "codex.yaml" ] || [ -f "codex.yml" ] || command -v codex &>/dev/null; then
    echo "codex"
    return
  fi

  # Cursor
  if [ -d ".cursor" ]; then
    echo "cursor"
    return
  fi

  # Aider
  if [ -f ".aider.conf.yml" ] || command -v aider &>/dev/null; then
    echo "aider"
    return
  fi

  echo "generic"
}

get_install_dir() {
  local harness="$1"
  case "$harness" in
    claude-code)  echo ".claude/skills" ;;
    codex)        echo ".codex/skills" ;;
    cursor)       echo ".cursor/skills" ;;
    aider)        echo ".aider/skills" ;;
    generic)      echo ".curious-stack" ;;
  esac
}

# ── Registry & Repo ─────────────────────────────────────────────────────

fetch_registry() {
  if [ -f "$SKILLS_CACHE/registry.json" ]; then
    local age
    age=$(( $(date +%s) - $(stat -c %Y "$SKILLS_CACHE/registry.json" 2>/dev/null || echo 0) ))
    if [ "$age" -lt 3600 ]; then
      cat "$SKILLS_CACHE/registry.json"
      return
    fi
  fi

  mkdir -p "$SKILLS_CACHE"

  if command -v curl &>/dev/null; then
    curl -sL "$REGISTRY_URL" -o "$SKILLS_CACHE/registry.json" 2>/dev/null || true
  elif command -v wget &>/dev/null; then
    wget -qO "$SKILLS_CACHE/registry.json" "$REGISTRY_URL" 2>/dev/null || true
  fi

  if [ -f "$SKILLS_CACHE/registry.json" ]; then
    cat "$SKILLS_CACHE/registry.json"
  else
    err "Could not fetch registry. Check your internet connection."
    exit 1
  fi
}

ensure_repo() {
  if [ ! -d "$SKILLS_CACHE/repo" ]; then
    info "Cloning skills repository..."
    git clone --depth 1 "$REGISTRY_REPO" "$SKILLS_CACHE/repo" 2>/dev/null
  else
    info "Updating skills repository..."
    git -C "$SKILLS_CACHE/repo" pull --rebase 2>/dev/null || true
  fi
}

# ── Commands ──────────────────────────────────────────────────────────

list_skills() {
  local registry
  registry=$(fetch_registry)

  echo ""
  echo -e "${BOLD}Available Agent Skills${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  echo "$registry" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data['skills']:
    tags = ', '.join(s.get('tags', []))
    harnesses = ', '.join(s.get('harnesses', []))
    print(f\"  \033[1m{s['name']}\033[0m v{s['version']}\")
    print(f\"    {s['description']}\")
    print(f\"    Tags: {tags}  |  Harnesses: {harnesses}\")
    print()
" 2>/dev/null || echo "$registry" | grep -o '"name":"[^"]*"' | sed 's/"name":"//;s/"//' 

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Install: ${GREEN}curl -sL https://raw.githubusercontent.com/ujjalcal/curious-stack/main/scripts/install.sh | bash -s -- <skill-name>${NC}"
}

search_skills() {
  local query="$1"
  local registry
  registry=$(fetch_registry)

  echo "$registry" | python3 -c "
import json, sys
query = '$query'.lower()
data = json.load(sys.stdin)
matches = [s for s in data['skills']
           if query in s['name'].lower()
           or query in s['description'].lower()
           or query in ' '.join(s.get('tags', [])).lower()]
if not matches:
    print('No skills found matching: $query')
    sys.exit(0)
print(f'Found {len(matches)} skill(s):')
print()
for s in matches:
    tags = ', '.join(s.get('tags', []))
    print(f\"  \033[1m{s['name']}\033[0m - {s['description']}\")
    print(f\"    Tags: {tags}\")
    print()
"
}

show_info() {
  local skill_name="$1"
  local registry
  registry=$(fetch_registry)

  echo "$registry" | python3 -c "
import json, sys
name = '$skill_name'
data = json.load(sys.stdin)
skill = next((s for s in data['skills'] if s['name'] == name), None)
if not skill:
    print(f'Skill not found: {name}')
    sys.exit(1)
print()
print(f\"\033[1m{skill['name']}\033[0m v{skill['version']}\")
print(f\"  Author:      {skill['author']}\")
print(f\"  Description: {skill['description']}\")
print(f\"  Tags:        {', '.join(skill.get('tags', []))}\")
print(f\"  Harnesses:   {', '.join(skill.get('harnesses', []))}\")
print(f\"  Path:        {skill['path']}\")
print()
"
}

installed_skills() {
  local harness
  harness=$(detect_harness)
  local install_dir
  install_dir=$(get_install_dir "$harness")

  echo ""
  echo -e "${BOLD}Installed Skills${NC} (harness: $harness)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ ! -d "$install_dir" ]; then
    echo "  No skills installed yet."
    echo ""
    echo -e "  Install one: ${GREEN}./scripts/install.sh <skill-name>${NC}"
    return
  fi

  local count=0
  for skill_dir in "$install_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name=$(basename "$skill_dir")

    if [ -f "$skill_dir/manifest.json" ]; then
      local version description
      version=$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['version'])" 2>/dev/null || echo "?")
      description=$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['description'])" 2>/dev/null || echo "")
      echo -e "  ${BOLD}$name${NC} v$version"
      echo "    $description"
      echo "    Location: $skill_dir"
    else
      echo -e "  ${BOLD}$name${NC}"
      echo "    Location: $skill_dir"
    fi
    echo ""
    count=$((count + 1))
  done

  if [ "$count" -eq 0 ]; then
    echo "  No skills installed yet."
  else
    echo "  $count skill(s) installed."
  fi
  echo ""
}

upgrade_skills() {
  local harness
  harness=$(detect_harness)
  local install_dir
  install_dir=$(get_install_dir "$harness")

  # Force-refresh the registry cache
  rm -f "$SKILLS_CACHE/registry.json"
  local registry
  registry=$(fetch_registry)

  # Refresh the repo
  ensure_repo

  echo ""
  echo -e "${BOLD}Upgrade Report${NC} (harness: $harness)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local new_skills
  new_skills=$(echo "$registry" | python3 -c "
import json, sys, os
data = json.load(sys.stdin)
install_dir = '$install_dir'
for s in data['skills']:
    dest = os.path.join(install_dir, s['name'])
    if not os.path.isdir(dest):
        print(s['name'])
" 2>/dev/null || echo "")

  if [ -n "$new_skills" ]; then
    echo -e "  ${BLUE}New skills available:${NC}"
    while IFS= read -r skill; do
      local desc
      desc=$(echo "$registry" | python3 -c "
import json, sys
data = json.load(sys.stdin)
s = next((x for x in data['skills'] if x['name'] == '$skill'), None)
print(s['description'] if s else '')
" 2>/dev/null || echo "")
      echo -e "    ${GREEN}+${NC} ${BOLD}$skill${NC} — $desc"
    done <<< "$new_skills"
    echo ""
  fi

  if [ ! -d "$install_dir" ]; then
    if [ -z "$new_skills" ]; then
      info "No skills installed and no new skills available."
    fi
    echo ""
    return
  fi

  local upgraded=0
  local up_to_date=0

  for skill_dir in "$install_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name=$(basename "$skill_dir")

    local installed_ver="0.0.0"
    if [ -f "$skill_dir/manifest.json" ]; then
      installed_ver=$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json')).get('version', '0.0.0'))" 2>/dev/null || echo "0.0.0")
    fi

    local registry_ver
    registry_ver=$(echo "$registry" | python3 -c "
import json, sys
data = json.load(sys.stdin)
s = next((x for x in data['skills'] if x['name'] == '$name'), None)
print(s['version'] if s else 'NOT_FOUND')
" 2>/dev/null || echo "NOT_FOUND")

    if [ "$registry_ver" = "NOT_FOUND" ]; then
      warn "$name — not in registry (may have been removed)"
      continue
    fi

    local needs_update
    needs_update=$(python3 -c "
from packaging.version import Version
try:
    print('yes' if Version('$registry_ver') > Version('$installed_ver') else 'no')
except:
    print('yes' if '$registry_ver' != '$installed_ver' else 'no')
" 2>/dev/null || echo "$([ "$registry_ver" != "$installed_ver" ] && echo yes || echo no)")

    if [ "$needs_update" = "yes" ]; then
      info "$name: $installed_ver -> $registry_ver"
      local src="$SKILLS_CACHE/repo/skills/$name"
      if [ -d "$src" ]; then
        cp -r "$src"/* "$skill_dir"/
        ok "$name upgraded to v$registry_ver"
        upgraded=$((upgraded + 1))
      else
        warn "$name: source not found in repo"
      fi
    else
      up_to_date=$((up_to_date + 1))
    fi
  done

  if [ "$up_to_date" -gt 0 ] && [ "$upgraded" -eq 0 ]; then
    echo -e "  ${GREEN}All $up_to_date installed skill(s) are up to date.${NC}"
  elif [ "$upgraded" -gt 0 ]; then
    echo ""
    ok "$upgraded skill(s) upgraded. $up_to_date already up to date."
  fi
  echo ""
}

install_skill() {
  local skill_name="$1"
  local harness
  harness=$(detect_harness)
  local install_dir
  install_dir=$(get_install_dir "$harness")

  info "Detected harness: $harness"
  info "Install directory: $install_dir/"

  local registry
  registry=$(fetch_registry)

  local skill_path
  skill_path=$(echo "$registry" | python3 -c "
import json, sys
data = json.load(sys.stdin)
skill = next((s for s in data['skills'] if s['name'] == '$skill_name'), None)
if not skill:
    print('NOT_FOUND')
else:
    print(skill['path'])
")

  if [ "$skill_path" = "NOT_FOUND" ]; then
    err "Skill '$skill_name' not found in registry."
    echo ""
    list_skills
    exit 1
  fi

  ensure_repo

  local src="$SKILLS_CACHE/repo/$skill_path"
  local dest="$install_dir/$skill_name"

  if [ ! -d "$src" ]; then
    err "Skill directory not found at: $src"
    exit 1
  fi

  mkdir -p "$dest"
  cp -r "$src"/* "$dest"/

  # Post-install hooks are not executed for security reasons.
  # A malicious manifest could contain arbitrary commands.
  # Skills should document any manual setup steps in their SKILL.md.

  case "$harness" in
    claude-code)
      integrate_claude_code "$skill_name" "$dest"
      ;;
    codex)
      integrate_codex "$skill_name" "$dest"
      ;;
    *)
      info "Skill files copied to: $dest"
      info "Add a reference to the skill prompt in your agent's configuration."
      ;;
  esac

  echo ""
  ok "Skill '$skill_name' installed!"
  echo ""
  echo -e "  ${BOLD}Location:${NC}  $dest"
  echo -e "  ${BOLD}Harness:${NC}   $harness"
  echo -e "  ${BOLD}Prompt:${NC}    $dest/SKILL.md"
  echo ""
  echo -e "  Uninstall: ${YELLOW}./scripts/install.sh --uninstall $skill_name${NC}"
}

integrate_claude_code() {
  local skill_name="$1"
  local dest="$2"

  if [ -f "CLAUDE.md" ]; then
    if ! grep -q "$skill_name" "CLAUDE.md" 2>/dev/null; then
      {
        echo ""
        echo "## Skill: $skill_name"
        echo "When relevant, follow the instructions in \`.claude/skills/$skill_name/SKILL.md\`"
      } >> CLAUDE.md
      info "Added skill reference to CLAUDE.md"
    fi
  else
    {
      echo "# Project Instructions"
      echo ""
      echo "## Skill: $skill_name"
      echo "When relevant, follow the instructions in \`.claude/skills/$skill_name/SKILL.md\`"
    } > CLAUDE.md
    info "Created CLAUDE.md with skill reference"
  fi
}

integrate_codex() {
  local skill_name="$1"
  local dest="$2"

  if [ -f "AGENTS.md" ]; then
    if ! grep -q "$skill_name" "AGENTS.md" 2>/dev/null; then
      {
        echo ""
        echo "## Skill: $skill_name"
        echo "When relevant, follow the instructions in \`.codex/skills/$skill_name/SKILL.md\`"
      } >> AGENTS.md
      info "Added skill reference to AGENTS.md"
    fi
  else
    {
      echo "# Agent Instructions"
      echo ""
      echo "## Skill: $skill_name"
      echo "When relevant, follow the instructions in \`.codex/skills/$skill_name/SKILL.md\`"
    } > AGENTS.md
    info "Created AGENTS.md with skill reference"
  fi
}

uninstall_skill() {
  local skill_name="$1"
  local harness
  harness=$(detect_harness)
  local install_dir
  install_dir=$(get_install_dir "$harness")
  local dest="$install_dir/$skill_name"

  if [ ! -d "$dest" ]; then
    err "Skill '$skill_name' is not installed (looked in $dest)."
    exit 1
  fi

  # Validate skill name to prevent path traversal
  if [[ ! "$skill_name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    err "Invalid skill name: $skill_name"
    exit 1
  fi

  rm -rf "$dest"
  ok "Skill '$skill_name' uninstalled from $install_dir/."
  echo ""
  warn "Note: References in CLAUDE.md / AGENTS.md were not removed — clean up manually if needed."
}

# ── Main ──────────────────────────────────────────────────────────────

if [ $# -eq 0 ]; then
  echo ""
  echo -e "${BOLD}curious-stack${NC} — install agent skills into any AI coding harness"
  echo ""
  echo "Usage:"
  echo "  install.sh <skill-name>              Install a skill (auto-detects harness)"
  echo "  install.sh --list                    List all available skills"
  echo "  install.sh --search <query>          Search skills by name or tag"
  echo "  install.sh --info <skill-name>       Show skill details"
  echo "  install.sh --installed               Show installed skills"
  echo "  install.sh --upgrade                 Upgrade skills + check for new ones"
  echo "  install.sh --uninstall <skill-name>  Remove a skill"
  echo "  install.sh --harness <name>          Override harness (claude-code|codex|cursor|aider|generic)"
  echo ""
  echo "Remote install (no clone needed):"
  echo -e "  ${GREEN}curl -sL https://raw.githubusercontent.com/ujjalcal/curious-stack/main/scripts/install.sh | bash -s -- <skill-name>${NC}"
  echo ""
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --list|-l)
      list_skills
      exit 0
      ;;
    --search|-s)
      search_skills "$2"
      exit 0
      ;;
    --info|-i)
      show_info "$2"
      exit 0
      ;;
    --installed)
      installed_skills
      exit 0
      ;;
    --update|--upgrade)
      upgrade_skills
      exit 0
      ;;
    --uninstall|-u)
      uninstall_skill "$2"
      exit 0
      ;;
    --harness)
      HARNESS="$2"
      shift 2
      ;;
    -*)
      err "Unknown option: $1"
      exit 1
      ;;
    *)
      install_skill "$1"
      exit 0
      ;;
  esac
done

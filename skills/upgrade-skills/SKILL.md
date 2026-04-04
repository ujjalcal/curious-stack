---
name: upgrade-skills
description: Pull the latest agent-skills and show what changed
user-invocable: true
---

# Upgrade Skills

When the user runs `/upgrade-skills` or asks to upgrade agent-skills, follow this process:

## Steps

1. **Detect install locations.** Check both:
   - **Global**: `~/.claude/skills/agent-skills/` (or `~/.codex/skills/agent-skills/`)
   - **Project-local**: `.claude/skills/agent-skills/` (or `.codex/skills/agent-skills/`)
   
   Report which installs exist.

2. **Check current version.** Read `registry.json` in each install location and note the current skill count and any version markers.

3. **Pull latest.** For each install location that is a git repo:
   ```bash
   cd <install-path> && git pull origin main
   ```
   If it's not a git repo (vendored copy), pull from the global install or re-clone:
   ```bash
   git clone --depth 1 https://github.com/ujjalcal/curious-stack.git /tmp/agent-skills-update
   cp -Rf /tmp/agent-skills-update/skills/* <install-path>/skills/
   cp /tmp/agent-skills-update/registry.json <install-path>/registry.json
   rm -rf /tmp/agent-skills-update
   ```

4. **Sync dual installs.** If both global and project-local exist, sync the newer one to the older one so they match.

5. **Run setup.** Execute `./setup` in the updated location to re-register everything.

6. **Show what changed.** Compare before and after:
   - New skills added
   - Skills with version bumps
   - Skills removed (if any)
   
   Format:
   ```
   Upgraded agent-skills.
   
   New skills:
     + skill-name — description
   
   Updated:
     ~ skill-name v1.0.0 → v1.1.0
   
   All X skills up to date.
   ```

## Rules
- Never delete user modifications to CLAUDE.md or AGENTS.md
- If git pull fails (dirty working tree), stash changes first, pull, then pop
- If network fails, retry once, then report the error clearly
- Always run setup after upgrading so new skills are registered

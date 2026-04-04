---
name: upgrade-skills
description: Pull the latest curious-stack and show what changed
user-invocable: true
---

# Upgrade Skills

Upgrade curious-stack to the latest version. Silent and resilient — never expose git internals to the user.

## Process

1. **Find the install.** Check in order, use the first that exists:
   - `~/.claude/skills/curious-stack/`
   - `~/.codex/skills/curious-stack/`
   - `.claude/skills/curious-stack/`
   - `.codex/skills/curious-stack/`

   If none found, tell the user to install first and stop.

2. **Save current version.** Read `registry.json` from the install and note the version and skill list. Do this silently — do not print the raw JSON.

3. **Replace with latest.** Always use fresh clone — never attempt git pull, rebase, or merge. This avoids all branch/conflict issues:
   ```bash
   git clone --depth 1 https://github.com/ujjalcal/curious-stack.git /tmp/curious-stack-upgrade 2>/dev/null
   ```
   If clone fails, retry once. If still fails, say "Network error — try again later." and stop.

   Then swap:
   ```bash
   rsync -a --delete --exclude='.git' /tmp/curious-stack-upgrade/ <install-path>/
   rm -rf /tmp/curious-stack-upgrade
   ```

4. **Run setup silently.** Execute `./setup` in the install path. Pass the same flags the user originally used (check `~/.curious-stack/config.json` for harness and telemetry settings). Do not show setup output to the user.

5. **Show only what changed.** Compare old version/skills to new. Print a clean summary:

   ```
   curious-stack upgraded: v1.1.0 → v1.2.0

   New:
     + skill-name — description

   Updated:
     ~ skill-name v1.0.0 → v1.1.0

   Removed:
     - skill-name

   All X skills installed.
   ```

   If already on latest: `curious-stack is up to date (vX.Y.Z, N skills).`

## Rules

- **Never show git commands, errors, or output to the user.** All git operations are internal.
- **Never attempt git pull, rebase, stash, or merge.** Always fresh clone + rsync. This is slower by 2 seconds but eliminates all conflict scenarios.
- **Never delete user modifications** to CLAUDE.md, AGENTS.md, or `~/.curious-stack/config.json`.
- If anything goes wrong, say what failed in one sentence. Do not show stack traces or command output.

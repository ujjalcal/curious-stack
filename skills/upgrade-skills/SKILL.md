---
name: upgrade-skills
description: "Self-updater — upgrade curious-stack to latest. Detects global vs vendored install, syncs both, shows what changed."
user-invocable: true
---

# Upgrade Skills

Upgrade curious-stack to the latest version. Show what changed, get confirmation before applying.

## Process

1. **Find the install.** Check in order, use the first that exists:
   - `~/.claude/skills/curious-stack/`
   - `~/.codex/skills/curious-stack/`
   - `.claude/skills/curious-stack/`
   - `.codex/skills/curious-stack/`

   If none found, tell the user to install first and stop.

2. **Save current version.** Read `registry.json` from the install and note the version and skill list. Do this silently — do not print the raw JSON.

3. **Fetch latest.** Clone to a temp directory — never attempt git pull, rebase, or merge:
   ```bash
   git clone --depth 1 https://github.com/ujjalcal/curious-stack.git /tmp/curious-stack-upgrade 2>/dev/null
   ```
   If clone fails, retry once. If still fails, say "Network error — try again later." and stop.

4. **Compare versions.** Read `registry.json` from the clone. If the version matches, clean up and say `curious-stack is up to date (vX.Y.Z, N skills).` and stop.

5. **Show what changed before applying.** This is mandatory — never skip this step.

   Show the user a summary of what will change:
   ```
   curious-stack upgrade available: v1.1.0 → v1.2.0

   New skills:
     + skill-name — description

   Updated skills:
     ~ skill-name v1.0.0 → v1.1.0

   Removed skills:
     - skill-name

   Changed files:
   ```

   Then run a diff between the current install and the clone to show changed scripts and hooks:
   ```bash
   diff -rq <install-path>/ /tmp/curious-stack-upgrade/ --exclude='.git' --exclude='node_modules' | head -30
   ```

   For any changed `.sh` file in `scripts/` or `scripts/hooks/`, show the actual diff so the user can see what code will run on their machine:
   ```bash
   diff -u <install-path>/scripts/hooks/log-telemetry.sh /tmp/curious-stack-upgrade/scripts/hooks/log-telemetry.sh
   ```

   **Always show hook and script diffs.** These files execute automatically — the user must see what changed before they run.

6. **Ask for confirmation.** Say:
   ```
   Apply this upgrade? The above scripts will run on your machine after every skill invocation.
   ```
   Wait for the user to confirm. If they say no, clean up the temp directory and stop.

7. **Apply.** Only after confirmation:
   ```bash
   rsync -a --delete --exclude='.git' /tmp/curious-stack-upgrade/ <install-path>/
   rm -rf /tmp/curious-stack-upgrade
   ```

8. **Run setup.** Execute `./setup` in the install path. Pass the same flags the user originally used (check `~/.curious-stack/config.json` for harness and telemetry settings). Show setup output so the user can verify what was registered.

9. **Confirm completion.**
   ```
   curious-stack upgraded: v1.1.0 → v1.2.0
   All X skills installed.
   ```

## Rules

- **Never apply without showing what changed first.** The diff step is not optional.
- **Never apply without user confirmation.** Ask and wait.
- **Always show script/hook diffs.** These are executable code that runs automatically.
- **Never attempt git pull, rebase, stash, or merge.** Always fresh clone + rsync.
- **Never delete user modifications** to CLAUDE.md, AGENTS.md, or `~/.curious-stack/config.json`.
- **Never show raw git errors to the user.** If something fails, say what failed in one sentence.
- Show setup output — don't hide what's being registered on the user's machine.

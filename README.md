# Agent Skills

Downloadable skills for AI coding agents. Works with **Claude Code**, **Codex**, **Cursor**, **Aider**, and anything that reads markdown prompts.

Each skill is a focused prompt that teaches your agent a specific capability. Install in 30 seconds. Upgrade with one command.

---

## Install (30 seconds)

**Claude Code (global):**
```bash
git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.claude/skills/agent-skills && cd ~/.claude/skills/agent-skills && ./setup
```

Then tell Claude: *"Add an agent-skills section to CLAUDE.md listing available skills: /ai-slop-detector, /upgrade-skills"*

**Add to your project** (so teammates get it):
```bash
cp -Rf ~/.claude/skills/agent-skills .claude/skills/agent-skills && rm -rf .claude/skills/agent-skills/.git && cd .claude/skills/agent-skills && ./setup
```

**Codex:**
```bash
git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.codex/skills/agent-skills && cd ~/.codex/skills/agent-skills && ./setup --host codex
```

**Cursor:**
```bash
git clone --depth 1 https://github.com/ujjalcal/agent-skills.git .cursor/skills/agent-skills
```
Then add skill references to `.cursorrules`.

**Any other agent** — clone the repo, point your agent at the `skills/*/prompt.md` files.

---

## Upgrade

```
/upgrade-skills
```

Detects your install type (global vs project-local), pulls the latest, syncs both copies if you have dual installs, and shows what changed — new skills, version bumps, everything.

Or from the command line:

```bash
cd ~/.claude/skills/agent-skills && git pull && ./setup
```

---

## Skills

| Skill | What it does |
|---|---|
| **ai-slop-detector** | Analyze pasted text for hollow, AI-generated writing. Returns a tight verdict with the most damning issues — no padding, no softening. |
| **upgrade-skills** | Self-updater — upgrade agent-skills to latest. Detects global vs vendored install, syncs both, shows what changed. |

*More coming. After you upgrade, new skills just appear.*

---

## Quick Start

1. **Install** — run the one-liner above (30 seconds)
2. **Use a skill** — paste text and say "check this for AI slop"
3. **Upgrade** — run `/upgrade-skills` whenever you want the latest

That's it. No config files, no build steps, no dependencies beyond git.

---

## How Skills Work

Each skill is a directory with two files:

```
skills/my-skill/
├── manifest.json    # Name, version, description, tags
└── prompt.md        # The actual instructions your agent follows
```

Your agent reads `prompt.md` when you invoke the skill. The manifest is metadata for the registry and installer.

---

## Adding a Skill

1. Create `skills/your-skill-name/manifest.json`:
```json
{
  "name": "your-skill-name",
  "version": "1.0.0",
  "description": "What it does in one sentence",
  "author": "your-github-username",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
  "entry": "prompt.md",
  "tags": ["relevant", "tags"]
}
```

2. Create `skills/your-skill-name/prompt.md` with clear agent instructions.

3. Add an entry to `registry.json`.

4. Submit a PR.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guidelines.

---

## Platform Reference

| Harness | Install path | Config file |
|---|---|---|
| Claude Code | `~/.claude/skills/agent-skills/` or `.claude/skills/agent-skills/` | `CLAUDE.md` |
| Codex | `~/.codex/skills/agent-skills/` or `.codex/skills/agent-skills/` | `AGENTS.md` |
| Cursor | `.cursor/skills/agent-skills/` | `.cursorrules` |
| Aider | `.aider/skills/agent-skills/` | `.aider.conf.yml` |
| Generic | `.agent-skills/` | Your agent's system prompt |

---

## CLI Installer (alternative)

If you prefer a per-skill installer instead of cloning the whole repo:

```bash
curl -sL https://raw.githubusercontent.com/ujjalcal/agent-skills/main/scripts/install.sh | bash -s -- ai-slop-detector
```

```
install.sh <skill-name>              Install one skill
install.sh --list                    List available skills
install.sh --search <query>          Search by name or tag
install.sh --info <skill-name>       Show details
install.sh --installed               Show what's installed
install.sh --upgrade                 Upgrade installed skills + check for new ones
install.sh --uninstall <skill-name>  Remove a skill
install.sh --harness <name>          Override harness detection
```

---

## License

MIT — free forever.

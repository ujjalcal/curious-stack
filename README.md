# Agent Skills Marketplace

A growing collection of reusable agent skills for **Claude Code**, **Codex**, **Cursor**, **Aider**, **Claude Cowork**, and any AI agent harness.

Each skill is a self-contained prompt + manifest. Install it, point your agent at it, and go.

> Inspired by [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) and [garrytan/gstack](https://github.com/garrytan/gstack).

---

## Available Skills

| Skill | Description |
|---|---|
| [ai-slop-detector](skills/ai-slop-detector/) | Analyze text for hollow, AI-generated writing patterns |

*More skills are added regularly. Run `--upgrade` to check for new ones.*

---

## Install a Skill

### One-liner (no clone needed)

```bash
curl -sL https://raw.githubusercontent.com/ujjalcal/agent-skills/main/scripts/install.sh | bash -s -- ai-slop-detector
```

This will:
1. Auto-detect your harness (Claude Code, Codex, Cursor, etc.)
2. Download the skill to the right directory
3. Wire it into your agent's config (CLAUDE.md, AGENTS.md, etc.)

### From a local clone

```bash
git clone https://github.com/ujjalcal/agent-skills.git
cd agent-skills
./scripts/install.sh ai-slop-detector
```

### Specify your harness explicitly

```bash
./scripts/install.sh ai-slop-detector --harness codex
```

---

## CLI Reference

```
install.sh <skill-name>              Install a skill (auto-detects harness)
install.sh --list                    List all available skills
install.sh --search <query>          Search skills by name or tag
install.sh --info <skill-name>       Show skill details
install.sh --installed               Show what's installed locally
install.sh --upgrade                 Check for new skills + version updates
install.sh --uninstall <skill-name>  Remove a skill
install.sh --harness <name>          Override harness detection
```

### Where skills get installed

| Harness | Install path |
|---|---|
| Claude Code | `.claude/skills/<skill-name>/` |
| Codex | `.codex/skills/<skill-name>/` |
| Cursor | `.cursor/skills/<skill-name>/` |
| Aider | `.aider/skills/<skill-name>/` |
| Generic | `.agent-skills/<skill-name>/` |

### Upgrade

Run this periodically to pull version updates for installed skills and see newly added skills:

```bash
./scripts/install.sh --upgrade
```

### Uninstall

```bash
./scripts/install.sh --uninstall ai-slop-detector
```

---

## Manual Setup (copy-paste)

If you prefer not to use the installer, just copy the skill folder and add a reference.

### Claude Code

```bash
mkdir -p .claude/skills
cp -r skills/ai-slop-detector .claude/skills/
```

Add to your `CLAUDE.md`:
```markdown
## Skill: ai-slop-detector
When asked to check text for AI slop, follow the instructions in `.claude/skills/ai-slop-detector/prompt.md`
```

### Codex (OpenAI)

```bash
mkdir -p .codex/skills
cp -r skills/ai-slop-detector .codex/skills/
```

Add to your `AGENTS.md`:
```markdown
## Skill: ai-slop-detector
When asked to analyze text for AI slop, follow the instructions in `.codex/skills/ai-slop-detector/prompt.md`
```

### Claude Cowork / Claude Web

Copy the contents of `skills/ai-slop-detector/prompt.md` and paste directly into your **Project Instructions** or **Custom Instructions**.

### Cursor

```bash
mkdir -p .cursor/skills
cp -r skills/ai-slop-detector .cursor/skills/
```

Add to `.cursorrules`:
```markdown
## Skill: ai-slop-detector
When asked to check text for AI slop, follow `.cursor/skills/ai-slop-detector/prompt.md`
```

### Aider

```bash
mkdir -p .aider/skills
cp -r skills/ai-slop-detector .aider/skills/
```

Add to `.aider.conf.yml`:
```yaml
read:
  - .aider/skills/ai-slop-detector/prompt.md
```

---

## Adding a New Skill

Create a directory under `skills/` with two files:

```
skills/your-skill-name/
├── manifest.json    # Metadata
└── prompt.md        # The skill instructions
```

**manifest.json:**
```json
{
  "name": "your-skill-name",
  "version": "1.0.0",
  "description": "One-sentence description",
  "author": "your-github-username",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "generic"],
  "entry": "prompt.md",
  "tags": ["relevant", "tags"]
}
```

**prompt.md:** Write clear, specific instructions for the agent. See `skills/ai-slop-detector/prompt.md` for an example.

Then add an entry to `registry.json` and submit a PR.

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## Skill Manifest Schema

See [skill-manifest.schema.json](skill-manifest.schema.json) for the full JSON Schema.

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Lowercase, hyphens only (`my-skill`) |
| `version` | Yes | Semver (`1.0.0`) |
| `description` | Yes | One sentence |
| `author` | Yes | GitHub username |
| `harnesses` | Yes | Array: `claude-code`, `codex`, `cursor`, `aider`, `generic` |
| `entry` | Yes | Prompt file path (`prompt.md`) |
| `license` | No | Default: MIT |
| `tags` | No | Searchable tags |
| `dependencies` | No | Other skill names this depends on |
| `hooks` | No | `pre-install`, `post-install`, `pre-uninstall` shell commands |
| `config` | No | User-configurable options with defaults |

## License

MIT

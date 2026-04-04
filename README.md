# Agent Skills

Skills that make AI coding agents smarter. Copy one line, paste it into your agent, done.

## Get Started

Pick your agent and paste the install command:

**Claude Code:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.claude/skills/agent-skills && cd ~/.claude/skills/agent-skills && ./setup` then add an "Agent Skills" section to CLAUDE.md listing the available skills: /ai-slop-detector, /upgrade-skills, /create-skill

**Codex:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.codex/skills/agent-skills && cd ~/.codex/skills/agent-skills && ./setup --host codex` then add an "Agent Skills" section to AGENTS.md listing the available skills: /ai-slop-detector, /upgrade-skills, /create-skill

**Cursor / Windsurf / Other:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git .agent-skills` then read the skills in `.agent-skills/skills/*/prompt.md` and follow them when asked.

That's it. Your agent handles the rest.

## Skills

| Skill | What it does |
|---|---|
| **/ai-slop-detector** | Paste any text and it tells you if it reads like hollow AI writing. Gets specific — quotes the worst offenders, names the pattern, gives you one fix. |
| **/upgrade-skills** | Updates your skills to the latest version. Finds new skills, upgrades old ones, keeps everything in sync. |
| **/create-skill** | Helps you write a new skill from scratch. Describe what you want, and it builds the prompt, manifest, and registry entry for you. |

## Upgrade

Just say:
> /upgrade-skills

Your agent pulls the latest skills automatically. New skills just appear.

## Create Your Own Skill

Just say:
> /create-skill

Describe what you want your skill to do. Your agent writes the prompt, creates the files, and wires it all up. Then submit a PR to share it with everyone.

## Share a Skill

Made something useful? We want it here. Run `/create-skill`, push your branch, and open a PR.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

<details>
<summary>Technical details (for contributors and the curious)</summary>

### How skills work

Each skill is a folder with two files:

```
skills/my-skill/
├── manifest.json    # Name, version, description, tags
└── prompt.md        # Instructions your agent follows
```

### Manifest format

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "What it does",
  "author": "github-username",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
  "entry": "prompt.md",
  "tags": ["relevant", "tags"]
}
```

Full schema: [skill-manifest.schema.json](skill-manifest.schema.json)

### Install paths by platform

| Harness | Path | Config |
|---|---|---|
| Claude Code | `~/.claude/skills/agent-skills/` | `CLAUDE.md` |
| Codex | `~/.codex/skills/agent-skills/` | `AGENTS.md` |
| Cursor | `.agent-skills/` | `.cursorrules` |
| Aider | `.agent-skills/` | `.aider.conf.yml` |

### CLI installer (alternative)

```bash
curl -sL https://raw.githubusercontent.com/ujjalcal/agent-skills/main/scripts/install.sh | bash -s -- ai-slop-detector
```

```
install.sh <skill-name>              Install one skill
install.sh --list                    List available skills
install.sh --search <query>          Search by name or tag
install.sh --installed               Show installed skills
install.sh --upgrade                 Upgrade + check for new skills
install.sh --uninstall <skill-name>  Remove a skill
```

</details>

## License

MIT — free forever.

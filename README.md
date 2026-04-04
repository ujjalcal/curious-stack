# Agent Skills

Skills that make AI coding agents smarter. Paste one line, your agent does the rest.

## Get Started

Copy the block for your agent. Paste it into a new chat. That's it.

**Claude Code:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git ~/.claude/skills/curious-stack && cd ~/.claude/skills/curious-stack && ./setup` then add an "Agent Skills" section to CLAUDE.md listing the available skills: /ai-slop-detector, /upgrade-skills

**Codex:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git ~/.codex/skills/curious-stack && cd ~/.codex/skills/curious-stack && ./setup --host codex` then add an "Agent Skills" section to AGENTS.md listing the available skills: /ai-slop-detector, /upgrade-skills

**Cursor / Windsurf / Other:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git .curious-stack` then read the skills in `.curious-stack/skills/*/SKILL.md` and follow them when asked.

Want to build or improve skills? Run `./setup --dev` to also install developer tools (create-skill, improve-skill, eval-skill, usage-dashboard).

## Skills

### User Skills

| Skill | What it does |
|---|---|
| **/ai-slop-detector** | Paste any text and it tells you if it reads like hollow AI writing. Gets specific — quotes the worst offenders, names the pattern, gives you one fix. |
| **/upgrade-skills** | Say "/upgrade-skills" and your agent pulls the latest. New skills just appear. |

### Developer Skills

Installed with `./setup --dev`. For building and improving skills.

| Skill | What it does |
|---|---|
| **/create-skill** | Say "/create-skill" and describe what you want. Walks you through an interview, then builds the skill, manifest, and test cases. |
| **/improve-skill** | Say "/improve-skill" and pick a skill. It reviews usage logs and evals, then suggests concrete improvements. |
| **/eval-skill** | Say "/eval-skill" and pick a skill. It runs every test case, judges the output (three-tier: deterministic, fuzzy, LLM), and reports pass/fail with scores. |
| **/usage-dashboard** | Say "/usage-dashboard" to see how you're using skills — frequency, trends, outcome patterns. |

## How Skills Work

Each skill lives in `skills/<name>/` with three files:

- **SKILL.md** — Instructions the agent follows (with YAML frontmatter for auto-discovery)
- **manifest.json** — Metadata: name, version, author, supported harnesses
- **evals/samples.json** — Test cases for quality assurance

Skills are tested with a three-tier judgment engine: deterministic checks (regex, substrings), fuzzy matching (token overlap), and optional LLM-as-judge scoring. See [skill-writing-guide.md](references/skill-writing-guide.md) for authoring details.

## Uninstall

**Claude Code:** `rm -rf ~/.claude/skills/curious-stack` and remove the skill references from `CLAUDE.md`.

**Codex:** `rm -rf ~/.codex/skills/curious-stack` and remove the skill references from `AGENTS.md`.

**Cursor / Windsurf / Other:** `rm -rf .curious-stack`

## Privacy

Skills collect anonymous usage data (which skill, when, verdict category, input length — never the actual text). This helps improve skills based on how people really use them.

**Opt out anytime:** `./setup --no-telemetry` or set `"telemetry": false` in `~/.curious-stack/config.json`

Full details: [TELEMETRY.md](evals/TELEMETRY.md)

## Want to share a skill?

Run `/create-skill`, push your branch, open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT

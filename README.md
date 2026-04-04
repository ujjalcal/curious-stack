# Agent Skills

Skills that make AI coding agents smarter. Paste one line, your agent does the rest.

## Get Started

Copy the block for your agent. Paste it into a new chat. That's it.

**Claude Code:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.claude/skills/agent-skills && cd ~/.claude/skills/agent-skills && ./setup` then add an "Agent Skills" section to CLAUDE.md listing the available skills: /ai-slop-detector, /upgrade-skills, /create-skill, /improve-skill

**Codex:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git ~/.codex/skills/agent-skills && cd ~/.codex/skills/agent-skills && ./setup --host codex` then add an "Agent Skills" section to AGENTS.md listing the available skills: /ai-slop-detector, /upgrade-skills, /create-skill, /improve-skill

**Cursor / Windsurf / Other:**
> Install agent-skills: run `git clone --depth 1 https://github.com/ujjalcal/agent-skills.git .agent-skills` then read the skills in `.agent-skills/skills/*/prompt.md` and follow them when asked.

## Skills

| Skill | What it does |
|---|---|
| **/ai-slop-detector** | Paste any text and it tells you if it reads like hollow AI writing. Gets specific — quotes the worst offenders, names the pattern, gives you one fix. |
| **/upgrade-skills** | Say "/upgrade-skills" and your agent pulls the latest. New skills just appear. |
| **/create-skill** | Say "/create-skill" and describe what you want. Your agent builds the whole thing for you. |
| **/improve-skill** | Say "/improve-skill" and pick a skill. It reviews usage logs and evals, then suggests concrete improvements. |

## Want to share a skill?

Run `/create-skill`, push your branch, open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT

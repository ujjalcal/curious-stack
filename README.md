# curious-stack

```
/ai-slop-detector
```

Paste any LinkedIn post, PR description, or technical doc. Get this back:

```
VERDICT: Pure Slop

TOP ISSUES:
1. Hollow opener — "In a world where AI is reshaping everything..."
   says nothing. Signals the agent wrote the first sentence.
2. Observation-Without-Consequence — "Organizations that adapt will
   thrive" — adapt how? thrive how? Consequence never lands.
3. Synthetic specificity — "40% productivity gains" with no methodology,
   no timeframe, no source. Numbers as decoration.

ONE FIX: Delete the first paragraph. Start with your second concrete
example and work backwards to the argument.
```

Four seconds. That's what a skill does.

> Prompts are ephemeral. Skills compound.

A skill is a markdown file with instructions, decision criteria, and an
output contract. Reusable. Versionable. Works across Claude Code, Cursor,
Codex CLI, Gemini CLI. `curious-stack` is a playground to use them and
build your own.

---

## The stack

| Skill | What it does |
|-------|-------------|
| `/ai-slop-detector` | Detects hollow AI writing — genre, verdict, quoted evidence, one fix |
| `/feed-scanner` | Paste multiple posts, get a ranked verdict table. Batch slop detection. |
| `/upgrade-skills` | Pull the latest curious-stack. New skills just appear. |
| `/create-skill` | Describe what you want. Walks you through an interview, builds the skill, manifest, and test cases. |
| `/improve-skill` | Pick a skill. Reviews usage logs and evals, suggests concrete improvements. |
| `/eval-skill` | Pick a skill. Runs every test case, judges output (deterministic, fuzzy, LLM), reports pass/fail. |
| `/usage-dashboard` | See how skills are being used — frequency, trends, outcome patterns. |

The first two install by default. The rest install with `./setup --dev`.

**Read the SKILL.md before you run it.** The file is the point — not just
the slash command.

---

## Build your own

A skill is a markdown file with structure and intent. That's it.

`curious-stack` is a playground for learning the pattern. Each skill is a
worked example — read a few and the structure becomes obvious fast.

To scaffold a new one:

```
/create-skill
```

Describe what you want in plain English. Then add the judgment — what
should the agent notice, what should it flag, what's the output contract.

The interesting skills encode domain knowledge that doesn't exist anywhere
else. Your instincts about your field, made reusable.

---

## Install

**Claude Code:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git ~/.claude/skills/curious-stack && cd ~/.claude/skills/curious-stack && ./setup` then add an "Agent Skills" section to CLAUDE.md listing the available skills: /ai-slop-detector, /upgrade-skills

**Codex:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git ~/.codex/skills/curious-stack && cd ~/.codex/skills/curious-stack && ./setup --host codex` then add an "Agent Skills" section to AGENTS.md listing the available skills: /ai-slop-detector, /upgrade-skills

**Cursor / Windsurf / Other:**
> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git .curious-stack` then read the skills in `.curious-stack/skills/*/SKILL.md` and follow them when asked.

Skills are auto-discovered from `~/.claude/skills/`. No import declarations needed.

---

## Privacy

Your content stays local. Skills run inside your agent session.
Nothing is sent anywhere except your AI provider's API — which is already
part of your setup.

Anonymous telemetry is **opt-in** (off by default). Setup asks on first run.
Collects only: skill name, verdict category, input length. Never the actual text.

Disable anytime: `./setup --no-telemetry`

Full details: [TELEMETRY.md](evals/TELEMETRY.md)

---

## Troubleshooting

**Skill not showing up?**
Run `cd ~/.claude/skills/curious-stack && ./setup` to re-register.

**Getting generic output?**
Invoke with the exact slash command — `/ai-slop-detector`. Don't describe
what you want. Just invoke.

**Skill not triggering automatically?**
Tighten the `description` field in SKILL.md frontmatter. The description
is what tells the agent when to load the skill.

**Upgrade stuck or conflicting?**
Run `/upgrade-skills` — it does a clean re-clone, no git conflicts possible.

---

## Uninstall

**Claude Code:** `rm -rf ~/.claude/skills/curious-stack` and remove skill references from `CLAUDE.md`.

**Codex:** `rm -rf ~/.codex/skills/curious-stack` and remove skill references from `AGENTS.md`.

**Cursor / Windsurf / Other:** `rm -rf .curious-stack`

---

## Contributing

Run `/create-skill`, push your branch, open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT

---

*Built by [@ujjalcal](https://github.com/ujjalcal)*

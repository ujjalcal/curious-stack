# curious-stack

> Prompts are ephemeral. Skills compound.

---

## The shift

Three phases. Same arc as every programming abstraction before it.

**Prompt engineering (2022–2023)** — ephemeral, lives in your clipboard,
can't be versioned or shared.

**Tool use / function calling (2023–2024)** — atomic. Executes and returns.
No judgment encoded.

**Skill engineering (2025–present)** — a bundle: instructions, workflow
guidance, decision criteria, reference context. Loaded dynamically when
relevant. Reusable. Versionable. Shareable across Claude Code, Cursor,
Codex CLI, Gemini CLI, and a dozen others.

Prompts are expressions. Skills are functions. You wouldn't build a
codebase out of one-liners in a REPL.

Skills are the next programming language. `curious-stack` is a working
demonstration of that — and a playground to build your own.

---

## See it work

```
/ai-slop-detector
```

**Input:** paste any LinkedIn post, PR description, or technical doc.

**Output:**

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

---

## The stack

| Skill | What it does |
|-------|-------------|
| `/ai-slop-detector` | Detects hollow AI writing — verdict, quoted evidence, one fix |
| `/upgrade-skills` | Pull the latest curious-stack. New skills just appear. |

**Developer tools** (install with `./setup --dev`):

| Skill | What it does |
|-------|-------------|
| `/create-skill` | Describe what you want. Walks you through an interview, builds the skill, manifest, and test cases. |
| `/improve-skill` | Pick a skill. Reviews usage logs and evals, suggests concrete improvements. |
| `/eval-skill` | Pick a skill. Runs every test case, judges output (deterministic, fuzzy, LLM), reports pass/fail. |
| `/usage-dashboard` | See how skills are being used — frequency, trends, outcome patterns. |

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

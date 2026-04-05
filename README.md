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
output contract. Reusable. Versionable. `curious-stack` is a playground
to use them and build your own.

---

## Content quality suite

Each skill encodes a different expert judgment about writing.

| Skill | Question it answers |
|-------|-------------|
| `/ai-slop-detector` | Is this hollow? — Detects AI-generated writing patterns |
| `/llm-ready` | Will AI cite this? — Checks if your content is citable by ChatGPT, Perplexity, Gemini, or invisible |
| `/claim-checker` | Is this backed up? — Finds stats without sources, causal claims without mechanisms |
| `/jargon-detector` | Would an outsider understand this? — Finds undefined acronyms, in-group assumptions |
| `/structure-critic` | Does the argument hold together? — Finds buried ledes, thesis drift, section imbalance |
| `/tone-audit` | What does this actually sound like? — Detects condescension, defensiveness, tone shifts |
| `/originality-score` | Has this been said before? — Detects commodity takes, consensus restatements |

Paste text. Get a verdict. Each skill quotes the evidence and gives one fix.

| Utility | What it does |
|-------|-------------|
| `/full-review` | Smart router — picks the 2-3 most relevant axes, returns a combined report card. |
| `/feed-scanner` | Batch-analyze multiple posts. Ranked verdict table. |
| `/upgrade-skills` | Pull the latest curious-stack. |

---

## Build your own

Run `./setup --dev` to install the skill builder tools:
`/create-skill`, `/improve-skill`, `/eval-skill`, `/auto-eval`, `/usage-dashboard`

A skill is a markdown file with structure and intent. Read a few SKILL.md
files in `skills/` — the pattern becomes obvious fast.

---

## Install

> Install curious-stack: run `git clone --depth 1 https://github.com/ujjalcal/curious-stack.git ~/.claude/skills/curious-stack && cd ~/.claude/skills/curious-stack && ./setup` then add a "curious-stack" section to CLAUDE.md listing the available skills: /llm-ready, /ai-slop-detector, /claim-checker, /jargon-detector, /structure-critic, /tone-audit, /originality-score, /full-review, /feed-scanner, /upgrade-skills

Skills are auto-discovered from `~/.claude/skills/`. No import declarations needed.

---

## Privacy

Your content stays local. Skills run inside your agent session.
Nothing is sent anywhere except your AI provider's API — which is already
part of your setup.

Anonymous telemetry is **opt-in** (off by default). Setup asks on first run.
Collects only: skill name, timestamp, harness type. Never the actual text.

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

`rm -rf ~/.claude/skills/curious-stack` and remove skill references from `CLAUDE.md`.

**Cursor / Windsurf / Other:** `rm -rf .curious-stack`

---

## Contributing

Run `/create-skill`, push your branch, open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT

---

*Built by [@ujjalcal](https://github.com/ujjalcal)*

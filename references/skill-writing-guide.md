# Skill Writing Guide

Shared best practices for writing, evaluating, and improving agent skills. Referenced by `/create-skill`, `/improve-skill`, `/eval-skill`, and the validation scripts.

## Skill Anatomy

```
skill-name/
├── SKILL.md           # Required — instructions with YAML frontmatter
├── manifest.json      # Required — metadata (name, version, tags)
├── evals/
│   └── samples.json   # Required — test cases
├── scripts/           # Optional — executable code for deterministic tasks
├── references/        # Optional — docs loaded into context as needed
└── assets/            # Optional — templates, icons, fonts
```

## SKILL.md Structure

Every skill needs YAML frontmatter and a markdown body.

### Frontmatter (required)

```yaml
---
name: skill-name
description: What it does and when to trigger. Be pushy — see Description section below.
user-invocable: true
argument-hint: "<optional: what the user passes>"
---
```

### Body (required sections)

```markdown
# Skill Name

<One sentence: what this does.>

## Steps

1. <Specific action>
2. <Next step>

## Output Format

<Exact template of what the response looks like.>

## Rules
- <Constraints, edge cases, things to never do>
```

## Writing Principles

### Be specific
Vague instructions produce vague results. "Analyze the code" is bad. "Read every changed file and check for SQL injection in string concatenation" is good.

### Explain why, not just what
LLMs respond better to reasoning than rigid rules. Instead of "ALWAYS use snake_case", write "Use snake_case because the project convention is Python-style naming and mixing conventions confuses contributors." If you find yourself writing ALWAYS or NEVER in all caps, reframe it as reasoning.

### Use imperative form
"Check each file" not "You should check each file" or "The agent will check each file."

### Include a concrete output format
The user should know exactly what they'll get back. Use a template or example in the Output Format section.

### Keep it focused
- SKILL.md body: under 500 lines ideal
- If approaching 500 lines, split domain-specific details into `references/` files
- SKILL.md stays in context whenever the skill triggers; reference files load on demand

### Progressive disclosure
Three-level loading:
1. **Metadata** (name + description) — always in context (~100 words)
2. **SKILL.md body** — in context when skill triggers
3. **Bundled resources** — loaded as needed (scripts execute without loading into context)

For multi-domain skills, organize by variant:
```
cloud-deploy/
├── SKILL.md (workflow + selection logic)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

### Draft then revise
Write a draft, then re-read with fresh eyes. Look for:
- Instructions that aren't pulling their weight — remove them
- Contradictions between rules
- Things that are too rigid or too vague
- Steps that could be combined or split

## Description Field

The `description` in frontmatter is the primary trigger mechanism. Claude decides whether to consult a skill based on this field.

**Make it slightly pushy.** Include both what the skill does AND specific contexts where Claude should use it — even if the user doesn't explicitly name the skill.

Bad: `Format data as CSV`
Good: `Format data as CSV. Use whenever the user mentions spreadsheets, data export, tabular data, or wants to convert between data formats, even if they don't explicitly ask for CSV.`

Bad: `Review pull requests`
Good: `Review pull requests for code quality, security, and correctness. Use when the user shares a PR link, asks for code review, mentions reviewing changes, or wants feedback on a diff.`

Claude tends to under-trigger skills. A slightly pushy description compensates for this.

## Writing Test Cases

### Minimum coverage
Every skill needs at least 3 test cases:
- **Clear-cut** — should definitely trigger the skill's main behavior
- **Edge case** — ambiguous or borderline input
- **Negative** — input where the skill should NOT trigger or should give a neutral result

### Make inputs realistic
Test inputs should read like something a real user would type — with file paths, personal context, casual speech, abbreviations, and typos.

Bad: `"Format this data"`
Bad: `"Extract text from PDF"`
Good: `"ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage"`

### Eval case schema

```json
{
  "id": "short-id",
  "description": "what this tests",
  "input": "realistic user prompt",
  "expected_verdict": "expected output category",
  "verdict_tolerance": 1,
  "expected_signals": ["signal names to detect"],
  "signal_match_threshold": 0.5,
  "must_contain": ["phrase that must appear"],
  "must_not_contain": ["phrase that must not appear"],
  "output_regex": "^VERDICT:",
  "rubric": "Plain English: what a good output looks like"
}
```

All fields except `id`, `description`, and `input` are optional.

### Three-tier judgment

**Tier 1 — Deterministic (free, instant):**
- `must_contain` / `must_not_contain` — substring match
- `output_regex` — regex match
- `expected_verdict` + `verdict_tolerance` — ordinal comparison
- Hard fail = score 0 regardless of other tiers

**Tier 2 — Fuzzy structural (free, instant):**
- Extract signals from output, fuzzy-match against `expected_signals`
- Score = fraction matched vs `signal_match_threshold`

**Tier 3 — LLM-as-judge (costs tokens, optional):**
- Only runs when `rubric` field is present
- Scores output 1-5 against the rubric
- Be honest, not generous in self-scoring

**Final score:** 0 if any Tier 1 fails, else weighted: 0.4 x verdict + 0.3 x signals + 0.3 x judge

### Non-determinism handling

LLM output varies between runs. Handle this with:
- `runs_per_case`: run each case N times (default: 3)
- `pass_threshold`: fraction of runs that must pass (default: 0.67)
- `verdict_tolerance`: allow +/-1 on ordinal scale (e.g., "heavy slop" when expected "pure slop" is OK with tolerance 1)

## Iteration Principles

### Don't overfit
You're building something used many times across many prompts. If a fix only works for one test case but breaks others, it's the wrong fix. Generalize.

### Diagnose before fixing
When a test fails, ask:
- Is the skill prompt unclear or too vague?
- Is the eval case wrong or too strict?
- Is the input genuinely ambiguous?

### Look for patterns
- Cases that consistently fail → skill instructions are wrong
- Flaky cases (sometimes pass, sometimes fail) → skill is ambiguous at that boundary
- Low judge scores with passing deterministic checks → structurally correct but semantically poor
- All test cases write similar helper scripts → bundle that script in `scripts/`

### Remove what doesn't help
After iterating, re-read the skill and cut instructions that aren't pulling their weight. Three clear lines beat ten vague ones.

## manifest.json Schema

```json
{
  "name": "skill-name",
  "version": "1.0.0",
  "description": "one sentence",
  "author": "github-username",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
  "entry": "SKILL.md",
  "tags": ["3-5", "relevant", "tags"]
}
```

## Naming Conventions

- Lowercase, hyphens only: `code-reviewer`, `api-tester`, `tone-checker`
- Short and obvious: `check-accessibility` not `comprehensive-web-accessibility-audit-tool`
- The name becomes the slash command: `/code-reviewer`

## Versioning

- Patch (1.0.0 → 1.0.1): bug fixes, wording improvements
- Minor (1.0.0 → 1.1.0): new capabilities, new output sections
- Major (1.0.0 → 2.0.0): breaking changes to output format or behavior

## Validation Checklist

Used by `scripts/validate.sh`:

- [ ] `SKILL.md` exists and has content (>10 lines)
- [ ] `SKILL.md` has YAML frontmatter with `name` and `description`
- [ ] `SKILL.md` starts with a heading
- [ ] `SKILL.md` has structured sections (Steps, Rules, Format, or similar)
- [ ] `manifest.json` exists with required fields (name, version, description, entry)
- [ ] `manifest.json` entry field points to `SKILL.md`
- [ ] Skill is registered in `registry.json`
- [ ] `evals/samples.json` exists with at least 1 test case
- [ ] Each eval case has `id`, `description`, `input`
- [ ] Skill name matches across manifest, registry, and directory name

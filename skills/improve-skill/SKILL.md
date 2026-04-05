---
name: improve-skill
description: "Analyze a skill's usage log and evals to suggest concrete improvements to its prompt."
user-invocable: true
argument-hint: "<skill-name>"
---

# Improve Skill

When the user runs `/improve-skill` or asks to improve an existing skill, follow this process.

**Before starting**, read `references/skill-writing-guide.md` in the curious-stack repo root. It defines the quality bar, writing principles, and eval format. All changes must conform to it.

## Step 1: Pick the Skill

Ask which skill to improve, or detect from context. Read:
1. `skills/<name>/SKILL.md` — the current skill
2. `skills/<name>/evals/samples.json` — test cases
3. `skills/<name>/evals/results/latest.json` — live eval results (if they exist)
4. `skills/<name>/usage.md` — usage log (if it exists)

## Step 2: Analyze

Look for problems across these sources:

**From the skill (apply writing guide criteria):**
- Vague instructions the agent could misinterpret
- Missing edge cases or output format gaps
- Steps too broad ("analyze the code") vs specific ("check each function for unused parameters")
- Rules that contradict each other
- Description not pushy enough for good triggering
- Over 500 lines without using `references/` for overflow
- Instructions that explain what but not why

**From eval results** (if `evals/results/latest.json` exists):
- Consistently failing cases → skill instructions are wrong
- Flaky cases → skill is ambiguous at that boundary
- Low Tier 3 (judge) scores with passing Tier 1 → structurally correct but semantically poor
- Which tier fails most: Tier 1 (format), Tier 2 (signals), Tier 3 (quality)

**From usage log / evals:**
- Patterns in how the skill is used vs how it was designed
- Gaps in test coverage (input types not tested)
- Repeated issues across runs → bundle a script in `scripts/`

## Step 3: Suggest Changes

Present improvements as concrete diffs — not vague advice.

```
## Improvement Report: <skill-name>

### Issues Found
1. <specific problem> — <evidence from usage/evals>
2. <specific problem> — <evidence>

### Suggested Changes

**SKILL.md:**
- Line X: Change "<old>" to "<new>" because <reason>
- Add new section: <what and why>

**New eval cases:**
- <description of missing test case>

### Before/After
<show the key change in context>
```

## Step 4: Apply and Verify (with permission)

Ask: "Want me to apply these changes?"

If yes:
1. Update `SKILL.md` (follow writing guide principles)
2. Add new eval cases to `evals/`
3. Bump version in `manifest.json` and `registry.json` (see versioning rules in the guide)
4. Run `./scripts/validate.sh` — must pass
5. Run evals: execute each test case, self-judge using the three-tier system from the writing guide
6. Report: `Eval Results: X/Y passed`
7. If any fail after changes, fix and re-run
8. After fixing, re-read the skill with fresh eyes — cut what isn't pulling its weight
9. Only present improvement as done after all evals pass

## Rules
- Never rewrite a skill from scratch. Improve incrementally.
- Every suggestion must cite evidence (an eval failure, a vague line, a usage pattern).
- Follow all writing principles in `references/skill-writing-guide.md`.
- If the skill has no evals, offer to add them first.
- Don't overfit fixes to specific test cases. Generalize.


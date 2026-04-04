# Improve Skill

When the user runs `/improve-skill` or asks to improve an existing skill, follow this process:

## Step 1: Pick the skill

Ask which skill to improve, or detect it from context. Read three things:
1. `skills/<name>/prompt.md` — the current prompt
2. `skills/<name>/usage.md` — the usage log (if it exists)
3. `skills/<name>/evals/` — the test cases (if they exist)

## Step 2: Analyze

Look for these problems:

**From the prompt:**
- Vague instructions the agent could misinterpret
- Missing edge cases or output format gaps
- Steps that are too broad ("analyze the code") vs specific ("check each function for unused parameters")
- Rules that contradict each other

**From the usage log:**
- Patterns in how the skill is actually used vs how it was designed
- Cases where the output wasn't what the user wanted
- Repeated notes about the same issue

**From the evals:**
- Gaps in test coverage (input types not tested)
- Cases where the expected output seems wrong
- Missing edge cases (empty input, very long input, mixed signals)

## Step 3: Suggest changes

Present improvements as a concrete diff — not vague advice. Format:

```
## Improvement Report: <skill-name>

### Issues Found
1. <specific problem> — <evidence from usage/evals>
2. <specific problem> — <evidence>

### Suggested Changes

**prompt.md:**
- Line X: Change "<old>" to "<new>" because <reason>
- Add new section: <what and why>

**New eval cases:**
- <description of missing test case>
- <description of missing test case>

### Before/After
<show the key change in context>
```

## Step 4: Apply (with permission)

Ask: "Want me to apply these changes?"

If yes:
1. Update `prompt.md`
2. Add new eval cases to `evals/`
3. Bump the patch version in `manifest.json` and `registry.json`
4. Run `./scripts/validate.sh` to confirm everything passes
5. Run `./scripts/eval.sh <skill-name>` to confirm evals pass

## Rules
- Never rewrite a skill from scratch. Improve incrementally.
- Every suggestion must cite evidence (a usage log entry, a missing eval case, a vague line in the prompt).
- If the skill has no usage log or evals, say so and offer to add them first.
- Bump patch version (1.0.0 → 1.0.1) for improvements, minor (1.0.0 → 1.1.0) for new capabilities.

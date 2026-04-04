---
name: eval-skill
description: Run eval cases against a skill and report pass/fail with scores
user-invocable: true
argument-hint: "<skill-name>"
---

# Eval Skill

When the user runs `/eval-skill` or asks to evaluate/test a skill, follow this process:

## Step 1: Pick the skill

Ask which skill to evaluate, or detect it from context. Read:
1. `skills/<name>/SKILL.md` — the skill prompt
2. `skills/<name>/evals/*.json` — the eval cases

If no eval cases exist, say so and offer to create some first (use the `/create-skill` pattern for generating eval cases).

## Step 2: Run each eval case

For each case in the evals JSON:

1. Read the `input` field
2. Execute the skill yourself — follow the instructions in `SKILL.md` as if the user pasted the input
3. Produce your full output for that input
4. Then immediately judge your own output against the case criteria:

**Tier 1 — Deterministic checks:**
- Does your output match `output_regex` (if set)?
- Does your output contain everything in `must_contain`?
- Does your output avoid everything in `must_not_contain`?
- Does your verdict match `expected_verdict` within `verdict_tolerance`?
  - Verdict scale: clean=0, mild slop=1, heavy slop=2, pure slop=3
  - Tolerance of 1 means ±1 level is OK

**Tier 2 — Signal matching:**
- Did you detect the signals listed in `expected_signals`?
- Score = fraction detected vs `signal_match_threshold`

**Tier 3 — Rubric self-check:**
- If a `rubric` field exists, honestly assess: does your output meet that criteria?
- Score yourself 1-5 (be honest, not generous)

## Step 3: Report results

After running ALL cases, produce this report:

```
## Eval Results: <skill-name>

| Case | Verdict | Expected | T1 | T2 | T3 | Score | Result |
|---|---|---|---|---|---|---|---|
| <id> | <your verdict> | <expected> | pass/fail | 0.XX | N/5 | 0.XX | PASS/FAIL |

**Summary:** X/Y passed, Z flaky
**Overall score:** 0.XX

### Failures
- <case-id>: <what went wrong and why>

### Observations
- <anything interesting about the skill's behavior>
- <edge cases that need more coverage>
```

## Step 4: Save results

Write results to `skills/<name>/evals/results/latest.json` in this format:

```json
{
  "skill": "<name>",
  "runner": "self-eval",
  "timestamp": "<ISO date>",
  "cases": [
    {
      "case_id": "<id>",
      "passed": true/false,
      "your_verdict": "<what you said>",
      "expected_verdict": "<what was expected>",
      "tier1_passed": true/false,
      "tier2_score": 0.XX,
      "tier3_score": N,
      "avg_score": 0.XX,
      "notes": "<any observations>"
    }
  ],
  "summary": {
    "total": N,
    "passed": N,
    "failed": N,
    "avg_score": 0.XX
  }
}
```

## Rules
- Actually execute the skill on each input. Don't just check the case structure.
- Be honest in self-scoring. If your output is borderline, say so.
- If a case fails, explain WHY — is the skill prompt unclear? Is the eval case wrong? Is the input ambiguous?
- Run ALL cases. Don't stop at the first failure.
- If the skill has no evals, offer to generate them from the prompt.

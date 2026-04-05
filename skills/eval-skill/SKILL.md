---
name: eval-skill
description: "Run evals on a skill — tests it against sample inputs, judges output quality, reports pass/fail with scores."
user-invocable: true
argument-hint: "<skill-name>"
---

# Eval Skill

When the user runs `/eval-skill` or asks to evaluate/test a skill, follow this process.

**Before starting**, read `references/skill-writing-guide.md` in the curious-stack repo root for the eval case schema, three-tier judgment system, and test writing guidelines.

## Step 1: Pick the Skill

Ask which skill to evaluate, or detect from context. Read:
1. `skills/<name>/SKILL.md` — the skill instructions
2. `skills/<name>/evals/samples.json` — the eval cases

If no eval cases exist, say so and offer to create some (minimum 3: one clear-cut, one edge case, one negative — see writing guide for details).

## Step 2: Run Each Eval Case

For each case in the evals JSON:

1. Read the `input` field
2. Execute the skill yourself — follow the instructions in `SKILL.md` as if the user pasted the input
3. Produce your full output
4. Judge your own output using the three-tier system from the writing guide:

**Tier 1 — Deterministic checks:**
- `output_regex` match (if set)
- `must_contain` — all substrings present
- `must_not_contain` — no forbidden substrings
- `expected_verdict` within `verdict_tolerance` on ordinal scale

**Tier 2 — Signal matching:**
- Signals detected vs `expected_signals`
- Score = fraction matched vs `signal_match_threshold`

**Tier 3 — Rubric self-check (if `rubric` field exists):**
- Score yourself 1-5 honestly against the rubric
- Be honest, not generous

**Scoring:** 0 if any Tier 1 fails, else 0.4 x verdict + 0.3 x signals + 0.3 x judge

## Step 3: Report Results

After running ALL cases:

```
## Eval Results: <skill-name>

| Case | Verdict | Expected | T1 | T2 | T3 | Score | Result |
|---|---|---|---|---|---|---|---|
| <id> | <your verdict> | <expected> | pass/fail | 0.XX | N/5 | 0.XX | PASS/FAIL |

**Summary:** X/Y passed, Z flaky
**Overall score:** 0.XX

### Failures
- <case-id>: <what went wrong and why — diagnose per the iteration principles in the writing guide>

### Observations
- <anything interesting about the skill's behavior>
- <edge cases that need more coverage>
```

## Step 4: Save Results

Write to `skills/<name>/evals/results/latest.json`:

```json
{
  "skill": "<name>",
  "runner": "self-eval",
  "timestamp": "<ISO date>",
  "cases": [
    {
      "case_id": "<id>",
      "passed": true,
      "your_verdict": "<what you said>",
      "expected_verdict": "<what was expected>",
      "tier1_passed": true,
      "tier2_score": 0.85,
      "tier3_score": 4,
      "avg_score": 0.82,
      "notes": "<observations>"
    }
  ],
  "summary": {
    "total": 3,
    "passed": 2,
    "failed": 1,
    "avg_score": 0.75
  }
}
```

## Rules
- Actually execute the skill on each input. Don't just check case structure.
- Be honest in self-scoring. If borderline, say so.
- If a case fails, diagnose WHY — is the skill unclear? Is the eval case wrong? Is the input ambiguous?
- Run ALL cases. Don't stop at first failure.
- If the skill has no evals, offer to generate them following the writing guide.


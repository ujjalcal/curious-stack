---
name: auto-eval
description: Generate eval cases from real usage data. Reads telemetry and learnings to find boundary verdicts, re-runs, and outliers — then drafts test cases.
user-invocable: true
argument-hint: "<skill-name>"
---

# Auto-Eval

Generate eval test cases from real usage patterns. Reads telemetry and per-project learnings to find inputs where the skill was uncertain, inconsistent, or operating at a boundary — then drafts eval cases for human review.

## When to use

- After running a skill many times and wanting to codify what you've learned
- When eval coverage feels thin and you want data-driven test cases
- Before publishing a skill (ensures evals cover real-world patterns)

## Process

### Step 1: Pick the skill

If the user specifies a skill name, use it. Otherwise, list skills that have telemetry data and ask.

### Step 2: Gather usage data

Read from two sources:

1. **Global telemetry**: `~/.curious-stack/telemetry.jsonl` — all runs across projects
2. **Project learnings**: `~/.curious-stack/projects/*/learnings.jsonl` — per-project history

Filter to entries matching the target skill. If no data exists, say "No usage data for this skill yet. Run it a few times first." and stop.

### Step 3: Identify candidate cases

Look for these patterns in the data — each is a signal that the skill's behavior at that input is worth testing:

**Boundary verdicts** — Verdicts that sit at a transition:
- Multiple Mild Slop verdicts (the Clean/Mild boundary is the hardest call)
- Verdicts that differ across runs on similar input lengths or genres

**Genre outliers** — Inputs from underrepresented genres:
- If 90% of runs are `linkedin` but 2 are `technical`, those 2 are worth testing
- If a genre has never been tested in existing evals, flag it

**Length extremes** — Unusually short or long inputs:
- Inputs under 100 chars (can the skill even work?)
- Inputs over 3000 chars (does it lose focus?)

**High signal counts** — Runs where signals_detected > 3:
- These are complex inputs that stress the skill's prioritization

### Step 4: Draft eval cases

For each candidate, generate an eval case in the format of `skills/<skill-name>/evals/samples.json`:

```json
{
  "id": "<descriptive-kebab-case-id>",
  "description": "<why this case matters — what boundary it tests>",
  "input": "<reconstructed representative input — NOT the actual user text>",
  "expected_verdict": "<verdict from usage data>",
  "verdict_tolerance": 1,
  "expected_signals": ["<top signals from similar runs>"],
  "signal_match_threshold": 0.5,
  "output_regex": "^GENRE:.*\nVERDICT:",
  "rubric": "<plain English description of what a good analysis looks like for this input>"
}
```

**Critical: never use actual user input text.** Reconstruct a representative example that captures the same patterns without copying private content. The eval case should test the same boundary without leaking the original.

### Step 5: Present for review

Show the candidates in a numbered list:

```
Auto-generated eval cases for ai-slop-detector (from N runs):

1. [boundary-mild-linkedin] — Tests Clean/Mild boundary for linkedin genre
   Verdict: mild slop | Genre: linkedin | Signals: buzzword-density
   "After 10 years building payment APIs at Stripe..."

2. [outlier-technical-short] — Tests short technical input (87 chars)
   Verdict: clean | Genre: technical | Signals: none
   "SQLite handles 100k writes/sec. Most startups don't need Postgres."

3. [high-signal-marketing] — Tests input with 5+ detected signals
   Verdict: pure slop | Genre: marketing | Signals: hollow-opener, enumeration, synthetic-specificity
   "In today's rapidly evolving AI landscape, 5 ways..."

Add these to evals/samples.json? [y/N, or pick numbers]
```

### Step 6: Apply

If the user approves (all or specific numbers), merge the new cases into `skills/<skill-name>/evals/samples.json`. Preserve existing cases. Validate the resulting JSON is well-formed.

## Rules

- **Never include actual user text** in eval cases. Always reconstruct representative examples.
- Present candidates ranked by coverage value (boundary cases first, length extremes last).
- If existing evals already cover a pattern, skip it — don't duplicate.
- Read existing `skills/<skill-name>/evals/samples.json` first to understand what's already tested.
- Maximum 5 candidates per run — quality over quantity.
- If fewer than 5 usage events exist, say "Not enough data yet" and suggest running the skill more.


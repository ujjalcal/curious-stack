---
name: create-skill
description: Build a new agent skill from a plain description, with test cases and iterative improvement. Use this whenever the user wants to create, draft, or prototype a new skill.
user-invocable: true
---

# Create Skill

When the user runs `/create-skill` or asks to create a new agent skill, guide them through a structured process: understand intent → write the skill → test it → iterate until it works.

## Step 1: Capture Intent

Start by understanding what the user wants. If the conversation already contains a workflow they want to capture (e.g., "turn this into a skill"), extract answers from context first.

Ask whatever you need to understand:
- What should this skill enable Claude to do?
- When should it trigger? (what user phrases or contexts)
- What's the expected output format?
- Any edge cases or things it should never do?

Proactively ask about input/output formats, example files, success criteria. Don't start writing until you have a clear picture. If the user's description is too vague, ask one clarifying question — only one.

## Step 2: Generate the Skill

### 2a. Pick a name

- Lowercase, hyphens only (e.g., `code-reviewer`, `api-tester`, `tone-checker`)
- Short and obvious
- Confirm: "I'll call this **my-skill-name** — good?"

### 2b. Write `SKILL.md`

This is the heart of the skill. It needs YAML frontmatter and clear instructions.

```markdown
---
name: skill-name
description: What this skill does and when to trigger it. Be specific and slightly pushy — include contexts where Claude should use this even if the user doesn't explicitly name the skill.
user-invocable: true
argument-hint: "<optional: what the user passes>"
---

# Skill Name

<One sentence: what this does.>

## Steps

1. <Specific action — not "analyze the code" but "read every changed file and check for X">
2. <Next step>

## Output Format

<Exact template of what the response looks like.>

## Rules
- <Constraints, edge cases, things to never do>
```

**Writing quality bar:**
- Be specific. Vague instructions produce vague results.
- Include a concrete output format — the user should know exactly what they'll get.
- Explain *why* things matter, not just what to do. LLMs respond better to reasoning than rigid rules.
- Prefer imperative form: "Check each file" not "You should check each file."
- Keep it under 500 lines. If longer, use bundled reference files in a `references/` directory.
- Start with a draft, then re-read it with fresh eyes and improve before presenting.

**Description field matters:** The description is the primary trigger mechanism. Make it slightly "pushy" — include both what the skill does AND contexts where it should activate. Example: instead of "Format data as CSV" write "Format data as CSV. Use whenever the user mentions spreadsheets, data export, tabular data, or wants to convert between data formats."

### 2c. Write `manifest.json`

```json
{
  "name": "<skill-name>",
  "version": "1.0.0",
  "description": "<one sentence>",
  "author": "<ask the user or use their git username>",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
  "entry": "SKILL.md",
  "tags": ["<3-5 relevant tags>"]
}
```

## Step 3: Create the Files

1. Create directory: `skills/<skill-name>/`
2. Write `skills/<skill-name>/SKILL.md`
3. Write `skills/<skill-name>/manifest.json`
4. Add entry to `registry.json`
5. Create symlink: `ln -s skills/<skill-name> ~/.claude/skills/<skill-name>` (if in Claude Code)

## Step 4: Write Test Cases

Every skill ships with test cases. Create `skills/<skill-name>/evals/samples.json`.

Come up with 2-3 realistic test prompts — the kind of thing a real user would actually say. Share them with the user: "Here are a few test cases I'd like to try. Do these look right, or do you want to add more?"

```json
{
  "description": "Test cases for <skill-name>",
  "config": { "runs_per_case": 3, "pass_threshold": 0.67 },
  "cases": [
    {
      "id": "<short-id>",
      "description": "<what this tests>",
      "input": "<realistic user prompt — not abstract, but specific with details>",
      "expected_verdict": "<expected output category if applicable>",
      "verdict_tolerance": 1,
      "must_contain": ["<phrase that must appear>"],
      "output_regex": "<structural pattern>",
      "rubric": "<plain English: what a good output looks like>"
    }
  ]
}
```

Include at least:
- One clear-cut case (should definitely trigger the skill's main behavior)
- One edge case (ambiguous or borderline input)
- One negative case (input where the skill should give a neutral result)

Make test inputs realistic — include file paths, personal context, casual speech, abbreviations. Not "Format this data" but "ok so my boss sent me this xlsx and wants me to add a profit margin column, revenue is in C and costs in D i think."

## Step 5: Run and Iterate

**Do not present the skill as done until evals pass.**

1. Run each test case: execute the skill prompt against each input, produce output, then self-judge against the case criteria
2. Report results: `Eval Results: X/Y passed`
3. If any case fails, diagnose why:
   - Is the skill prompt unclear or too vague?
   - Is the eval case wrong or too strict?
   - Is the input genuinely ambiguous?
4. Fix the skill or the eval case and re-run
5. After fixing, re-read the skill with fresh eyes — look for instructions that aren't pulling their weight, contradictions, or things that are too rigid

**Iteration mindset:** You're building something that will be used many times across many different prompts. Don't overfit to the test cases. If a fix only works for one test case but would break others, it's the wrong fix. Generalize from the feedback.

## Step 6: Show Summary

```
Created skill: <skill-name>

Files:
  skills/<skill-name>/SKILL.md
  skills/<skill-name>/manifest.json
  skills/<skill-name>/evals/samples.json
  registry.json (updated)

Evals: X/X passed

To try it: /<skill-name>
To share it: commit and submit a PR
```

## Skill Structure Reference

```
skill-name/
├── SKILL.md           # Required — main instructions with YAML frontmatter
├── manifest.json      # Required — metadata
├── evals/
��   └── samples.json   # Required — test cases
├── scripts/           # Optional — executable code for deterministic tasks
├── references/        # Optional — docs loaded into context as needed
└── assets/            # Optional — templates, icons, fonts
```

**Progressive disclosure:** SKILL.md body is loaded whenever the skill triggers. Keep it focused. Reference files are loaded on demand — use them for domain-specific details (e.g., `references/aws.md`, `references/gcp.md`).

## Rules
- Always capture intent first. Never guess what the skill should do.
- The SKILL.md must be actionable — steps an agent can follow, not vague advice.
- Every skill must have a defined output format.
- Keep names short. `check-accessibility` not `comprehensive-web-accessibility-audit-tool`.
- Default to all harnesses unless the skill is truly platform-specific.
- Explain *why* in the skill instructions — reasoning beats rigid MUSTs.
- If you find yourself writing ALWAYS or NEVER in all caps, reframe as reasoning instead.

## Telemetry

After completing, log telemetry per `~/.agent-skills/config.json` settings. See the telemetry instructions in the skill's prompt for details.

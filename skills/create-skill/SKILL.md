---
name: create-skill
description: Build a new agent skill from a plain description, with test cases and iterative improvement. Use this whenever the user wants to create, draft, or prototype a new skill.
user-invocable: true
---

# Create Skill

When the user runs `/create-skill` or asks to create a new agent skill, guide them through: understand intent, write the skill, test it, iterate until it works.

**Before writing anything**, read `references/skill-writing-guide.md` in the agent-skills repo root. It defines the skill structure, writing principles, eval format, and quality bar. Follow it.

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
- Follow naming conventions from the writing guide
- Confirm: "I'll call this **my-skill-name** — good?"

### 2b. Write `SKILL.md`
Follow the SKILL.md structure and writing principles from `references/skill-writing-guide.md`. Key points:
- YAML frontmatter with pushy description (see guide's Description Field section)
- Specific steps, concrete output format, clear rules
- Explain *why*, use imperative form, keep under 500 lines
- Draft first, then revise with fresh eyes

### 2c. Write `manifest.json`
Follow the manifest schema from the writing guide.

## Step 3: Create the Files

1. Create directory: `skills/<skill-name>/`
2. Write `skills/<skill-name>/SKILL.md`
3. Write `skills/<skill-name>/manifest.json`
4. Add entry to `registry.json`
5. Create symlink: `ln -s skills/<skill-name> ~/.claude/skills/<skill-name>` (if in Claude Code)

## Step 4: Write Test Cases

Create `skills/<skill-name>/evals/samples.json` following the eval case schema and test writing guidelines in the writing guide.

Come up with 2-3 realistic test prompts — the kind of thing a real user would actually say. Share them: "Here are a few test cases I'd like to try. Do these look right, or do you want to add more?"

Minimum coverage: one clear-cut, one edge case, one negative.

## Step 5: Run and Iterate

**Do not present the skill as done until evals pass.**

1. Run each test case: execute the skill prompt against each input, produce output, then self-judge using the three-tier judgment system from the writing guide
2. Report results: `Eval Results: X/Y passed`
3. If any case fails, diagnose why (see Iteration Principles in the guide)
4. Fix the skill or the eval case and re-run
5. After fixing, re-read the skill with fresh eyes — cut what isn't pulling its weight

**Iteration mindset:** Don't overfit to test cases. Generalize from feedback.

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

## Rules
- Always capture intent first. Never guess what the skill should do.
- Follow all writing principles in `references/skill-writing-guide.md`.
- Every skill must have evals. No exceptions.
- Default to all harnesses unless the skill is truly platform-specific.

## Telemetry

After completing, log telemetry per `~/.agent-skills/config.json` settings.

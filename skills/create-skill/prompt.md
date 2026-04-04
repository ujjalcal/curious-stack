# Create Skill

When the user runs `/create-skill` or asks to create a new agent skill, walk them through it conversationally, then generate everything.

## Step 1: Ask what the skill should do

Ask the user one question:

> What should this skill do? Describe it however you want — a sentence, a paragraph, bullet points, an example of it in action.

Wait for their answer. Don't proceed until they've described it.

## Step 2: Generate the skill

From their description, create three things:

### 2a. Pick a name

- Lowercase, hyphens only (e.g., `code-reviewer`, `api-tester`, `tone-checker`)
- Short and obvious
- Confirm with the user: "I'll call this **my-skill-name** — good?"

### 2b. Write `prompt.md`

This is the heart of the skill. Write it as clear instructions an AI agent will follow. Use this structure:

```markdown
# Skill Name

<One sentence: what this skill does and when to use it.>

## Steps

1. <First thing the agent should do>
2. <Next thing>
3. <...>

## Output Format

<Exactly what the response should look like. Use a template/example.>

## Rules
- <Constraints, edge cases, things to never do>
```

**Quality bar:**
- Be specific. "Analyze the code" is bad. "Read every changed file and check for SQL injection in string concatenation" is good.
- Include a concrete output format. The user should know exactly what they'll get back.
- Include rules that prevent the agent from going off-track.
- Keep it under 200 lines. A focused skill beats a bloated one.

### 2c. Write `manifest.json`

```json
{
  "name": "<skill-name>",
  "version": "1.0.0",
  "description": "<one sentence>",
  "author": "<ask the user or use their git username>",
  "license": "MIT",
  "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
  "entry": "prompt.md",
  "tags": ["<3-5 relevant tags>"]
}
```

## Step 3: Create the files

1. Create the directory: `skills/<skill-name>/`
2. Write `skills/<skill-name>/manifest.json`
3. Write `skills/<skill-name>/prompt.md`
4. Add an entry to `registry.json`:
   ```json
   {
     "name": "<skill-name>",
     "version": "1.0.0",
     "description": "<same one sentence>",
     "author": "<author>",
     "tags": ["<tags>"],
     "harnesses": ["claude-code", "codex", "cursor", "aider", "generic"],
     "path": "skills/<skill-name>"
   }
   ```

## Step 4: Generate eval cases

Every skill must ship with evals. Create `skills/<skill-name>/evals/samples.json` with at least 3 test cases:

```json
{
  "description": "Test cases for <skill-name>",
  "config": { "runs_per_case": 3, "pass_threshold": 0.67 },
  "cases": [
    {
      "id": "<short-id>",
      "description": "<what this tests>",
      "input": "<sample input>",
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
- One negative case (input where the skill should NOT trigger / should give a neutral result)

## Step 5: Run evals before accepting

**Do not present the skill as done until evals pass.**

1. Run `./scripts/validate.sh` — must pass with no errors
2. Run each eval case yourself: execute the skill prompt against each input, judge your own output against the case criteria
3. Report results to the user:
   ```
   Eval Results: X/Y passed
   - case-id: PASS/FAIL (brief note)
   ```
4. If any case fails, fix the prompt or the eval case and re-run
5. Only after all evals pass, present the skill as ready

## Step 6: Show the user what was created

Print a summary:

```
Created skill: <skill-name>

Files:
  skills/<skill-name>/manifest.json
  skills/<skill-name>/prompt.md
  skills/<skill-name>/evals/samples.json
  registry.json (updated)

Evals: X/X passed

To try it: /<skill-name>
To share it: commit and submit a PR
```

## Rules
- Always ask what the skill should do first. Never guess.
- The prompt.md must be actionable — steps an agent can follow, not vague advice.
- Every skill must have a defined output format.
- Keep names short. `check-accessibility` not `comprehensive-web-accessibility-audit-tool`.
- Default to all harnesses unless the skill is truly platform-specific.
- If the user's description is too vague, ask one clarifying question. Only one.

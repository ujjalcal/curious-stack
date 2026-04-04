# Contributing a Skill

## Quick Steps

1. Fork this repo
2. Create `skills/your-skill-name/` with `manifest.json` and `prompt.md`
3. Add an entry to `registry.json`
4. Submit a PR

## Skill Guidelines

**prompt.md** — This is the actual skill. Write it as instructions an AI agent will follow.

- Be specific. Vague prompts produce vague results.
- Structure with clear steps, rules, and output format.
- Include examples of good output.
- Don't assume a specific agent — write for any capable LLM.

**manifest.json** — Metadata about the skill.

- `name`: lowercase, hyphens only. Must match the directory name.
- `version`: start at `1.0.0`, bump on changes.
- `harnesses`: list every harness the skill works with. Most skills work with all — use `["claude-code", "codex", "cursor", "aider", "generic"]`.
- `tags`: help people find your skill. Be specific.

## Quality Bar

Before submitting, check:

- [ ] Does the skill do one thing well?
- [ ] Is the prompt clear enough that a different LLM would follow it correctly?
- [ ] Does it include a defined output format?
- [ ] Would you actually use this skill?

## Versioning

When you update an existing skill:

1. Bump the `version` in `manifest.json`
2. Update the `version` in `registry.json`
3. Users running `--upgrade` will automatically get the new version

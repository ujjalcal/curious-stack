# Contributing a Skill

## The easy way

Just say `/create-skill` in your agent. Describe what you want. It builds everything for you — the prompt, the manifest, the registry entry. Then push and open a PR.

## Quality bar

Before submitting, ask yourself:

- Does the skill do one thing well?
- Is the prompt specific enough that any LLM would follow it correctly?
- Does it include a defined output format?
- Would you actually use this skill?

## Updating an existing skill

Bump the `version` in both `manifest.json` and `registry.json`. Users running `/upgrade-skills` get it automatically.

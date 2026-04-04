# Telemetry

Agent-skills collects anonymous usage data to understand how skills are used and improve them.

## What we collect

- **Skill name** — which skill was used (e.g., "ai-slop-detector")
- **Skill version** — which version
- **Timestamp** — when it was used
- **Harness** — which agent (claude-code, codex, etc.)
- **Output category** — the verdict/result type (e.g., "pure slop"), not the actual content
- **Input/output length** — character counts, not the text itself
- **Duration** — how long the skill took
- **Signal count** — how many patterns were detected, not which ones

## What we NEVER collect

- The actual input text
- The actual output text
- Your name, email, IP, or any identifying information
- File paths, repo names, or project details
- Anything from your codebase

## Where it's stored

Locally at `~/.agent-skills/telemetry.jsonl` — one JSON line per event.

If remote sync is enabled, events are pushed to the configured endpoint. The endpoint URL is visible in `~/.agent-skills/config.json`.

## Opt out

Set `telemetry: false` in `~/.agent-skills/config.json`:

```json
{
  "telemetry": false
}
```

Or run setup with `--no-telemetry`:

```bash
./setup --no-telemetry
```

When telemetry is off, no events are logged anywhere — not locally, not remotely.

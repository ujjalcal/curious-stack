# Telemetry

curious-stack collects anonymous usage data to understand how skills are used and improve them.

## What we collect

- **Skill name** — which skill was used (e.g., "ai-slop-detector")
- **Timestamp** — when it was used
- **Harness** — which agent (claude-code, codex, etc.)

That's it. No verdicts, no lengths, no durations, no signal counts.

## What we NEVER collect

- The actual input text
- The actual output text
- Your name, email, IP, or any identifying information
- File paths, repo names, or project details
- Anything from your codebase

## Where it's stored

Locally at `~/.curious-stack/telemetry.jsonl` — one JSON line per event.

If remote sync is enabled, events are pushed to the configured endpoint. The endpoint URL is visible in `~/.curious-stack/config.json`.

## Opt out

Set `telemetry: false` in `~/.curious-stack/config.json`:

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

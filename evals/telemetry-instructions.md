# Telemetry Instructions (included in every skill)

After completing a skill run, log an anonymous telemetry event **if telemetry is enabled**.

## Check if telemetry is enabled

Read `~/.agent-skills/config.json`. If the file doesn't exist or `telemetry` is not `false`, telemetry is ON by default.

## Log the event

Append one JSON line to `~/.agent-skills/telemetry.jsonl`:

```json
{"event":"skill.run","skill":"<skill-name>","version":"<version>","timestamp":"<ISO 8601>","harness":"<detected>","outcome":{"category":"<output category>","input_length":<chars>,"output_length":<chars>,"signals_detected":<count>},"session_id":"<random>"}
```

**Rules:**
- NEVER log the actual input or output text
- `category` = the verdict or result type (e.g., "pure slop", "pass", "fail")
- `input_length` / `output_length` = character counts only
- `signals_detected` = count of patterns found, not which ones
- `session_id` = a random 8-character hex string, same for all events in one conversation, different across conversations
- If `~/.agent-skills/config.json` has `"telemetry": false`, skip logging entirely

## Remote sync

If `~/.agent-skills/config.json` has a `telemetry_endpoint` URL, also POST the event there:

```bash
curl -s -X POST "<endpoint>" -H "Content-Type: application/json" -d '<event json>' &>/dev/null &
```

If no endpoint is configured, events stay local only.

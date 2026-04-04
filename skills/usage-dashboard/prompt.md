# Usage Dashboard

When the user runs `/usage-dashboard` or asks about skill usage, read the telemetry log and show insights.

## Step 1: Read telemetry data

Read `~/.agent-skills/telemetry.jsonl`. Each line is a JSON event. If the file doesn't exist or is empty, say "No usage data yet. Use some skills and come back!"

## Step 2: Analyze and present

Show a dashboard with these sections:

```
## Skill Usage Dashboard

### Overview
- Total skill runs: <count>
- Skills used: <list>
- Active since: <first event date>
- Last used: <most recent event date>

### By Skill
| Skill | Runs | Last Used | Most Common Outcome |
|---|---|---|---|
| ai-slop-detector | 42 | 2 hours ago | pure slop (45%) |
| create-skill | 5 | yesterday | — |

### Trends
- Most used skill: <name> (<count> runs)
- Busiest day: <date> (<count> runs)
- Average input length: <chars> characters
- Average signals detected: <count>

### Outcome Distribution (for skills with categories)
| Outcome | Count | % |
|---|---|---|
| pure slop | 19 | 45% |
| heavy slop | 10 | 24% |
| mild slop | 8 | 19% |
| clean | 5 | 12% |

### Insights
- <Observation about usage patterns>
- <Skill improvement suggestion based on data>
- <Any anomalies or interesting patterns>
```

## Step 3: Suggest improvements

Based on the data, suggest:
- Skills that might need improvement (high usage but poor outcomes)
- Missing skills (gaps in what users seem to be trying to do)
- Eval cases that should be added based on real-world input lengths and outcome distributions

## Rules
- Only read from `~/.agent-skills/telemetry.jsonl` — never from any other location
- If telemetry is disabled (`config.json` has `telemetry: false`), tell the user telemetry is off and offer to enable it
- Present data visually — tables and percentages, not raw JSON
- Highlight actionable insights, not just numbers

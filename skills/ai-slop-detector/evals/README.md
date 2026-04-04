# Evals for ai-slop-detector

Each JSON file contains test cases with:

- `input` — text to analyze
- `expected_verdict` — Clean / Mild Slop / Heavy Slop / Pure Slop
- `expected_signals` — patterns that should be detected
- `must_contain` — quoted phrases the analysis should reference

Run: `./scripts/eval.sh ai-slop-detector`

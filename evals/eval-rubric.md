# Eval Judge

You are evaluating the output of an AI agent skill. Score the output on a 1-5 scale.

## Input

- **Skill purpose**: {skill_description}
- **Input given to skill**: {input}
- **Skill output**: {output}
- **Rubric**: {rubric}

## Scoring

| Score | Meaning |
|---|---|
| 1 | Completely wrong — misses the point, wrong format, or harmful |
| 2 | Partially correct — gets some things right but major issues |
| 3 | Acceptable — meets basic criteria but notable gaps |
| 4 | Good — meets criteria with only minor issues |
| 5 | Excellent — nails the criteria, specific, well-structured |

## Response Format

Respond with exactly two lines:

```
SCORE: <number 1-5>
REASON: <one sentence explaining the score>
```

Nothing else. No preamble, no extra commentary.

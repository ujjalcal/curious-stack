---
name: feed-scanner
description: Batch-analyze multiple posts for AI slop. Paste a feed, get a ranked verdict table.
user-invocable: true
argument-hint: "<paste multiple posts or a feed>"
---

# Feed Scanner

Batch-analyze multiple posts or articles for AI slop. Returns a ranked summary table instead of separate per-post analyses.

## Before Analysis

**Skip this section if the user says "fresh", "no learnings", or "clean slate".**

Check if `~/.curious-stack/projects/{slug}/learnings.jsonl` exists (slug = git repo name or cwd basename). If so, read the last 20 entries silently. Use them to calibrate genre detection and signal priorities for this project. Do not mention that you read them.

## When to use

- User pastes multiple LinkedIn posts, tweets, or articles
- User pastes a screenshot of a feed (read the text from it)
- User says "scan my feed" or "check these posts"

## Process

1. **Split the input into individual posts.** Look for clear boundaries: author names, timestamps, "---" separators, or obvious topic shifts. If ambiguous, ask.

2. **Analyze each post** using the same criteria as `/ai-slop-detector`:
   - Detect genre (linkedin, technical, marketing, political, personal-essay, general)
   - Identify hard and soft slop signals
   - Determine verdict (Clean / Mild Slop / Heavy Slop / Pure Slop)
   - Note the single most damning signal

3. **Return a ranked summary table**, sorted worst-to-best:

```
FEED SCAN: <N> posts analyzed

| # | Author / Title | Genre | Verdict | Top Signal | One-Line Reason |
|---|---------------|-------|---------|------------|-----------------|
| 1 | @name or "Title..." | linkedin | Pure Slop | Enumeration as substance | Generic 5-point list, no examples |
| 2 | @name or "Title..." | technical | Mild Slop | Buzzword density | Real content but "transformative" closer |
| 3 | @name or "Title..." | personal-essay | Clean | — | First-person friction, specific numbers |

WORST: [Author] — [one quoted phrase that exemplifies the worst slop]
BEST: [Author] — [one sentence on why it's authentic]
```

4. **Keep it tight.** No per-post deep analysis unless the user asks for one. The table is the product.

## Rules

- Sort worst-to-best (Pure Slop first, Clean last)
- Always include the top signal column — it's the most useful part
- If a post is too short to analyze (<50 chars), skip it with a note
- If you can't identify the author, use the first 5 words as the title
- Do not pad. No "Here's my analysis of your feed..." preamble. Start with the table.

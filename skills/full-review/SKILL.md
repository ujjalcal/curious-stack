---
name: full-review
description: Paste text, get a focused content review. Picks the 2-3 most relevant quality axes based on what the text actually needs — not a sequential dump of all skills.
user-invocable: true
argument-hint: "<paste text to review>"
---

# Full Review

You are a content review router. Given pasted text, you pick the 2-3 most relevant quality axes, run those analyses, and return a combined report card.

You do NOT run all 6 skills. You do NOT run them sequentially. You read the text, identify what matters most, and focus there.

## Step 1: Triage

Read the text once. Determine:

- **Genre** (linkedin, technical, marketing, essay, email, general)
- **Length** (short <300 words, medium 300-1000, long 1000+)
- **What the text is trying to do** (persuade, inform, sell, reflect, announce)

## Step 2: Pick axes

Based on the triage, pick exactly 2-3 axes from this list. Never all 6. Never just 1.

| Axis | Skill logic | Pick when... |
|------|-------------|--------------|
| **Substance** | ai-slop-detector | Text has polished structure but might be hollow. LinkedIn, marketing, announcements. Always pick for linkedin genre. |
| **Evidence** | claim-checker | Text makes factual claims, cites stats, names trends, or asserts causation. Skip for personal essays, skip for pure opinion. |
| **Accessibility** | jargon-detector | Text uses acronyms, technical terms, or in-group language. Pick for investor updates, cross-functional docs, public-facing content. Skip for internal technical docs aimed at specialists. |
| **Structure** | structure-critic | Text is 500+ words and attempts an argument or narrative. Skip for short posts. Skip for lists. |
| **Tone** | tone-audit | Text is addressed to someone (email, feedback, announcement) or has stakes (investor update, public statement). Pick when the "how it sounds" matters as much as "what it says." |
| **Originality** | originality-score | Text is thought leadership, opinion, or commentary. Pick for linkedin, blog posts, essays. Skip for docs, emails, announcements. |

### Routing heuristics

- **LinkedIn post**: Substance + Originality + (Evidence if stats present, Tone if addressed to someone)
- **Technical blog**: Substance + Accessibility + (Structure if long)
- **Essay / long-form**: Structure + Originality + Tone
- **Email / Slack**: Tone + (Accessibility if cross-team)
- **Marketing**: Substance + Evidence + (Accessibility if public)
- **Investor update**: Evidence + Accessibility + Tone
- **Internal doc**: Accessibility + Structure

These are defaults. Override if the text clearly needs something else. The routing should feel obvious — if someone reads your picks, they should nod.

## Step 3: Analyze

For each picked axis, run the full analysis using the detection criteria and output format from that skill's SKILL.md. Read the skill file if needed — don't guess or abbreviate the criteria. Each axis should produce its standard output format, just tighter (hit highlights, skip padding).

## Output Format

```
GENRE: <genre>
AXES SELECTED: <2-3 axis names>
WHY: <one sentence explaining the pick — what about this text made these axes matter>

---

<AXIS 1 NAME>
<Full analysis for this axis — same format as the individual skill>

---

<AXIS 2 NAME>
<Full analysis for this axis>

---

<AXIS 3 NAME (if applicable)>
<Full analysis for this axis>

---

REPORT CARD:
<axis 1>: <verdict>
<axis 2>: <verdict>
<axis 3>: <verdict>

BIGGEST PROBLEM: <one sentence — the single most important thing to fix across all axes>
AXES SKIPPED: <list the 3-4 axes you didn't run and one word why — e.g., "Structure (too short)", "Evidence (opinion piece)">
```

## Rules

- **Never run all 6.** If you think all 6 are needed, you're not triaging. Pick the 3 that matter most.
- **Never run just 1.** That's what the individual skill commands are for. Full review means cross-cutting.
- **Explain your routing.** The WHY line is mandatory. The user should understand your judgment.
- **Don't duplicate findings.** If the same quote is flagged by two axes, mention it once and note it hits both.
- **Keep it tight.** Each axis analysis should be shorter than the standalone skill output — hit the highlights, skip the padding. The report card at the end is the payoff.


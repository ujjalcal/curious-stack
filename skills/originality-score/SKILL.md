---
name: originality-score
description: Check if this has been said a thousand times. Detects commodity takes, consensus restatements, and writing that adds nothing new.
user-invocable: true
argument-hint: "<paste text to score>"
---

# Originality Score

Analyze pasted text for originality. The question isn't "is this well-written?" or "is this slop?" — it's "does this add anything new?" Good writing that restates consensus is still a commodity. The test: could any expert in this field have written this, or did it require THIS author's specific experience?

## What counts as unoriginal

### Hard flags

**Consensus restatement**
- "AI is changing everything" — yes, everyone knows
- "The future of work is evolving" — unfalsifiable, adds nothing
- Opening with a claim nobody would disagree with

**Template arguments**
- Problem → solution → CTA with no surprising turn
- "X things I learned from Y" where each lesson is predictable
- "Here's what most people get wrong about Z" followed by what most people already know

**Substitutable author**
- Remove the byline — could this be written by any of 100 people in the field?
- No personal experience, no unique data, no contrarian position
- The "median take" — exactly what you'd predict someone in this role would say

### Soft flags

**Predictable framing**
- Industry trend → why it matters → what to do about it
- "In my N years of experience..." followed by widely-known advice
- Listicle structure with generic entries

**Missing unique angle**
- The author has specific experience (mentioned in bio/intro) that never appears in the argument
- Real data exists (the author's company, projects, users) but the piece uses industry stats instead
- First-person moments that could be specific but stay generic

### Counter-signals (marks of originality)

- A claim that someone in the author's field would push back on
- Specific data from the author's own experience (not industry reports)
- A framing that recontextualizes a familiar topic
- "I was wrong about..." — changing one's mind is inherently original
- Connecting two domains that don't usually talk to each other

## Output Format

```
GENRE: [linkedin / technical / marketing / essay / general / etc.]
ORIGINALITY: [High / Medium / Low / Commodity]

NOVEL CLAIMS: <count>
CONSENSUS RESTATEMENTS: <count>
UNIQUE ANGLE: <detected or "Not detected">

COMMODITY SIGNALS:
1. "<quoted claim or structure>" — <why it's a commodity take>
2. "<quoted claim or structure>" — <why it's a commodity take>

WHAT'S MISSING: <what the author's unique experience could add but doesn't.
If you can infer their background from the text, name what specific story
or data point would make this irreplaceable.>

ONE FIX: <single edit to inject originality — be specific about what to add, not what to remove>
```

## Calibration

- **LinkedIn posts**: High bar — the platform is flooded with commodity takes. Originality is the only differentiator.
- **Technical docs**: Low bar — docs should be clear, not original. Only flag if the doc could be auto-generated.
- **Blog posts / essays**: Standard bar — the piece should justify its existence. Why publish this vs linking to an existing article?
- **Marketing**: Low bar — marketing is allowed to restate value props. Only flag if it's indistinguishable from competitors.

## Tone

- This is the most subjective skill. Be honest but not cruel.
- "This is a commodity take" is a judgment, not an insult — explain what would make it original.
- The "WHAT'S MISSING" section is the most valuable part. Make it specific and actionable.

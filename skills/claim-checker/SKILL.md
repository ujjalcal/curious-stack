---
name: claim-checker
description: Detect unsupported claims in any text. Spots stats without sources, causal claims without mechanisms, and authority assertions without credentials.
user-invocable: true
argument-hint: "<paste text to check>"
---

# Claim Checker

Analyze pasted text for claims presented as facts without evidence. This is pattern-checking, not fact-checking — you're not verifying truth, you're flagging where the author asks you to trust them without earning it.

## What counts as an unsupported claim

### Hard flags (high confidence)

**Stats without sources**
- "73% of enterprises have adopted AI" — no link, no study, no date
- "Studies show..." without naming the study
- Round numbers that smell fabricated ("exactly 10x improvement")

**Causal claims without mechanism**
- "AI increases productivity by 40%" — how? measured how? over what timeframe?
- "This approach reduces churn" — what's the mechanism connecting approach to outcome?
- Post hoc reasoning ("We launched X, revenue went up, therefore X caused it")

**Universal claims**
- "Every successful founder..." — every? name three.
- "The best teams always..." — always? what about the exceptions?
- "Nobody has ever..." — strong negative universal, almost certainly wrong

**Authority without credentials**
- "Experts agree..." — which experts?
- "Industry leaders say..." — name them
- "It's well known that..." — well known by whom?

### Soft flags (worth noting but not damning)

**Anecdote as data**
- "I've seen this work at three companies" — that's an anecdote, not evidence
- "In my experience..." followed by a universal claim

**Weasel words**
- "Some say...", "Many believe...", "It's widely accepted..." — passive attribution to unnamed sources

**Precision theater**
- Overly specific numbers without context ("37.2% improvement") — false precision suggests fabrication
- Multiple decimal places on inherently imprecise measurements

### Not flags (don't penalize these)

- Clearly marked opinions ("I think...", "In my view...")
- Hypotheticals ("If we assume...")
- Commonly accepted facts (gravity exists, water boils at 100C)
- Claims with inline citations or links

## Output Format

```
GENRE: [same genre detection as ai-slop-detector]
CLAIMS FOUND: <total count>
UNSUPPORTED: <count>

1. "<quoted claim>" — <why it's unsupported: missing source / no mechanism / universal without evidence>
2. "<quoted claim>" — <why it's unsupported>
3. "<quoted claim>" — <why it's unsupported>

SUPPORTED: <count> (specific, sourced, or clearly opinion)

TRUST SCORE: [High / Medium / Low / Very Low]
— High: <2 unsupported claims, mostly sourced
— Medium: 2-3 unsupported, some sourced
— Low: More unsupported than supported
— Very Low: Majority unsupported, pattern suggests fabrication
```

## Calibration

- **LinkedIn posts**: Lower bar — short form means fewer citations expected. Flag only egregious unsupported stats.
- **Blog posts / articles**: Standard bar — claims should have some support, even if informal.
- **Research summaries / reports**: High bar — every stat should have a source. Flag aggressively.
- **Opinion pieces**: Only flag claims presented as facts, not clearly-labeled opinions.

## Tone

- Be specific. Quote the claim. Name the gap.
- Don't say "this lacks evidence" — say "this claims 40% improvement with no timeframe, no baseline, and no methodology."
- Don't moralize. The author might have evidence they didn't include. You're flagging the gap, not the intent.

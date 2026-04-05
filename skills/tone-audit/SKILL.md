---
name: tone-audit
description: Find the gap between how you think you sound and how you actually sound. Detects inadvertent condescension, defensive writing, and tone shifts.
user-invocable: true
argument-hint: "<paste text to audit>"
---

# Tone Audit

Analyze the tone of pasted text. The question: does the writer sound the way they think they sound? Most tone problems aren't about word choice — they're about the gap between intended and actual impression.

## What counts as a tone problem

### Hard flags

**Inadvertent condescension**
- "Simply put..." — implies the reader couldn't handle the complex version
- "It's important to understand..." — implies they don't understand
- "Let me be clear..." — implies they're confused
- "As I've explained before..." — implies they should already know

**Defensive writing**
- Preemptively rebutting critics who haven't spoken ("Some may disagree, but...")
- Credential front-loading ("With 15 years of experience, I can say...")
- Over-qualifying every statement as if expecting attack

**Performative humility**
- "I'm no expert, but..." followed by 2000 words of confident expertise
- "This is just my opinion..." followed by stated-as-fact claims
- "I could be wrong, but..." — then never engaging with how they could be wrong

### Soft flags

**Tone shifts**
- Professional → casual → aggressive within one piece
- Formal opening that dissolves into slang by paragraph 4
- Sudden shift to second person ("You need to understand...")

**Passive aggression**
- "Interesting approach..." (meaning: bad approach)
- "As previously communicated..." (meaning: I already told you this)
- "Per my last email..." — hostility wearing a suit

**Confidence/hedging imbalance**
- Hedges on easy claims, assertive on controversial ones (backwards)
- Clustering all hedges in one section (signals the writer is uncomfortable with that part)
- No hedges at all on uncertain claims (false confidence)

### Not flags

- Intentionally casual tone in casual context
- Strong opinions clearly labeled as opinions
- Technical directness in technical writing
- Humor that lands

## Output Format

```
GENRE: [linkedin / technical / marketing / email / general / etc.]
INTENDED TONE (likely): <what the writer probably thinks they sound like>
ACTUAL TONE: <what they actually sound like to a reader>

EVIDENCE:
1. "<quoted phrase>" (¶N) — <what it signals and why>
2. "<quoted phrase>" (¶N) — <what it signals and why>
3. "<quoted phrase>" (¶N) — <what it signals and why>

TONE SHIFTS:
- ¶N-N: <tone label>
- ¶N-N: <tone label> (<what changed and why it's jarring>)

ONE FIX: <single edit to close the gap between intended and actual tone>
```

## Calibration

- **LinkedIn posts**: Watch for performative humility and credential stacking — the platform incentivizes both
- **Emails / Slack**: Watch for passive aggression and inadvertent condescension — high stakes, low words
- **Blog posts**: Watch for defensive writing — authors anticipate comments
- **Technical docs**: Watch for condescension — "simply", "just", "obviously" are the culprits

## Tone

Ironic: a tone audit must get its own tone right.
- Be observational, not judgmental. "This reads as defensive" not "you're being defensive."
- Quote the evidence. Don't psychoanalyze the author.
- Acknowledge that tone is subjective — flag the pattern, let the writer decide.
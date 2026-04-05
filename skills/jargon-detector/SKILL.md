---
name: jargon-detector
description: Check if a smart outsider could understand this text. Finds undefined acronyms, in-group assumptions, and abstraction without examples.
user-invocable: true
argument-hint: "<paste text to check>"
---

# Jargon Detector

Analyze pasted text for accessibility. The question isn't "is this well-written?" — it's "could a smart person outside the author's bubble follow this?"

## What counts as jargon

### Hard flags

**Undefined acronyms**
- TAM, ARR, PLG, ICP, MQL on first use with no expansion
- Industry acronyms that feel obvious to insiders but aren't

**In-group assumptions**
- "As we all know, the shift to..." — who is "we"?
- "Obviously, the problem with X is..." — obvious to whom?
- References to frameworks, models, or concepts without context ("the 70/20/10 model")

**Abstraction ladders**
- Concept → concept → concept with no concrete example
- "We need to leverage our platform to drive ecosystem growth" — three abstractions, zero specifics
- Entire paragraphs with no proper nouns, no numbers, no examples

### Soft flags

**Premature framework language**
- "Our north star metric" — just say what the metric is
- "Value proposition" — say what the product does
- "Stakeholder alignment" — say who needs to agree on what

**Audience mismatch**
- PhD-level explanation in a blog post
- Casual tone in a formal proposal
- Technical depth beyond what the stated audience needs

**Metaphor as explanation**
- "land-and-expand" — it's a metaphor, not an explanation
- "flywheel effect" — what specifically spins?
- Using the metaphor as if it IS the concept

### Not flags

- Technical terms in technical docs for technical audiences (appropriate jargon)
- Acronyms defined on first use
- Industry terms with inline explanations

## Output Format

```
GENRE: [linkedin / technical / marketing / general / etc.]
AUDIENCE: <who this text assumes the reader is — be specific>
ACCESSIBILITY: [High / Medium / Low / Very Low]

JARGON HOTSPOTS:
1. "<quoted term or phrase>" (¶N) — <what's unclear and why. What should it say instead?>
2. "<quoted term or phrase>" (¶N) — <what's unclear>
3. "<quoted term or phrase>" (¶N) — <what's unclear>

CLEAR SECTIONS: <which parts are most accessible, and why>

ONE FIX: <single highest-leverage edit to make this accessible to outsiders>
```

## Calibration

- **LinkedIn posts**: Medium bar — assumes broad audience, jargon is a bigger sin
- **Technical docs**: Low bar — appropriate jargon is fine, but undefined acronyms still count
- **Investor updates**: High bar — investors span industries, jargon alienates
- **Internal memos**: Low bar — shared context is expected. Only flag truly opaque passages.

## Tone

- Don't be pedantic. "API" doesn't need to be spelled out in a technical blog.
- Focus on passages where an intelligent outsider would lose the thread.
- Quote the jargon. Don't say "there's too much jargon" — say "ICP alignment in ¶3 is undefined and blocks comprehension."

## After Analysis

Append one line to `~/.curious-stack/telemetry.jsonl` (create if missing):

```json
{"event":"skill.run","skill":"jargon-detector","version":"1.0.0","timestamp":"<ISO 8601 now>","harness":"claude-code","outcome":{"category":"<accessibility lowercase>","genre":"<genre>","input_length":<chars>,"output_length":<chars>,"signals_detected":<jargon hotspot count>}}
```

Do not read any config files. Do not make any network requests. Just append.

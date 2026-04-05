---
name: structure-critic
description: Check if an argument holds together. Finds buried ledes, thesis drift, missing transitions, and section imbalance in longer writing.
user-invocable: true
argument-hint: "<paste text to analyze>"
---

# Structure Critic

Analyze the structure of longer writing (500+ words). Not grammar, not style — logic and flow. Does the argument build? Does the conclusion follow from the evidence? Is the most important thing in the right place?

For short text (<500 words), say "Too short for structural analysis. Try /ai-slop-detector or /tone-audit instead."

## What counts as a structural problem

### Hard flags

**Buried lede**
- The actual point appears in paragraph 4+ instead of the first two
- The reader has to wade through setup to find what matters
- "But here's the thing..." appearing late = the real piece starts there

**Thesis drift**
- Opens about X, closes about Y with no bridge
- The introduction promises one argument, the body delivers another
- Multiple competing theses that never merge

**Circular argument**
- Conclusion restates the opening without advancing it
- "Therefore, as I said at the start..." — if you're back where you started, nothing happened

### Soft flags

**Missing transitions**
- Paragraph N doesn't follow from paragraph N-1
- Topic changes without signaling ("Another thing to consider...")
- Reader has to infer the connection

**Section imbalance**
- 2000 words of context, 200 words of argument
- Extensive setup for a thin payoff
- Multiple long sections followed by a rushed conclusion

**Tangent without return**
- Digression that adds color but doesn't connect back
- Anecdote that entertains but doesn't support the thesis

### Not flags

- Non-linear structure that's intentional and works (narrative, Q&A format)
- Short pieces where structure is inherently simple
- Lists and enumerations (structure is explicit by design)

## Output Format

```
GENRE: [linkedin / technical / marketing / essay / general / etc.]
STRUCTURE: [Strong / Adequate / Weak / Broken]

THESIS: "<what the piece claims to be about>" (stated in ¶N)
ACTUAL ARGUMENT: "<what the piece is actually about>" (emerges in ¶N)
DIAGNOSIS: <one sentence on the structural problem, or "Thesis and argument align.">

FLOW BREAKS:
1. ¶N→¶N+1: <what breaks and why>
2. ¶N→¶N+1: <what breaks and why>

BALANCE: <% setup, % argument, % conclusion. Note if inverted.>

ONE FIX: <single structural edit — where to cut, what to move, what to merge>
```

## Calibration

- **LinkedIn posts**: Skip — too short for structural analysis
- **Blog posts / articles**: Standard bar — thesis should be clear by ¶2
- **Essays / long-form**: High bar — every paragraph should build on the previous one
- **Technical docs**: Structure is about hierarchy (H1→H2→H3), not narrative flow

## Tone

- Be architectural, not editorial. You're critiquing the blueprint, not the bricks.
- "Your lede is buried" is more useful than "this could be restructured."
- Quote the thesis and the actual argument — show the drift, don't just name it.
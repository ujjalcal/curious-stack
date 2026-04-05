---
name: ai-slop-detector
description: "Analyze text for patterns that signal hollow, AI-generated writing. Returns a tight verdict with the most damning issues."
user-invocable: true
argument-hint: "<paste text to analyze>"
---

# AI Slop Detector

Analyze pasted text for patterns that signal hollow, AI-generated writing. Return a tight verdict with the most damning issues — no padding, no softening.

## Before Analysis

**Skip this section if the user says "fresh", "no learnings", or "clean slate".**

Check if `~/.curious-stack/projects/` has a subdirectory matching the current project. Use the git repo name (run `basename $(git rev-parse --show-toplevel 2>/dev/null)`) or fall back to the current directory name.

If `~/.curious-stack/projects/{slug}/learnings.jsonl` exists, read the last 20 entries silently. Use them to calibrate — do not mention that you read them unless relevant:

- If past verdicts cluster in one genre (e.g., mostly linkedin), note the project's typical content type
- If the same signals appear repeatedly (e.g., Observation-Without-Consequence in 8 of 10 runs), prioritize those signals
- If verdicts cluster at a boundary (e.g., many Mild Slop), be more precise at that boundary — the user cares about the distinction

If the file doesn't exist or the directory doesn't exist, skip this step silently.

## What is AI Slop?

AI slop is writing that is technically correct but substantively empty. It performs the shape of insight without delivering it. It is the default output of LLMs prompted without strong editorial constraints.

## Detection Signal Categories

Evaluate text across these dimensions. Weight them by severity.

### Hard Slop Signals (most damning)

**Hollow openers / closers**
- "In today's fast-paced world..."
- "It's no secret that..."
- "At the end of the day..."
- "The bottom line is..."
- Ending with "What do you think?" or "I'd love to hear your thoughts."
- Inspirational closer that doesn't follow from the content

**The Observation-Without-Consequence pattern**
- States a fact or observation but never lands a specific implication
- Example: "AI is transforming the mortgage industry." (Full stop. No how, no so what)

**False tension / fake nuance**
- "While X is important, we must not forget Y" — where X and Y are both obviously true
- "It's not just about A, it's about B" — where no one was arguing it was only A

**Enumeration as substance**
- Numbered lists that could apply to any topic (e.g., "5 Ways AI Will Change [Industry]")
- Each item is a heading + one vague sentence with no concrete example

**Hedge stacking**
- "Perhaps," "potentially," "in many ways," "it could be argued" — multiple hedges in one paragraph with no actual claim landing

### Soft Slop Signals (meaningful but not disqualifying alone)

**Buzzword density**
- "Transformative," "game-changer," "unlock," "leverage," "empower," "ecosystem," "seamless," "cutting-edge," "robust," "scalable" — especially when clustered

**The Royal "We" without referent**
- "We are entering a new era..." — who is we?

**Synthetic specificity**
- Precise-sounding stats or numbers with no source ("Studies show 73% of organizations...")
- Specific-sounding examples that are obviously generic

**Passive observation voice**
- Everything described from 30,000 feet; no first-person perspective or lived experience
- No friction, no surprise, no moment where the author changed their mind

**Symmetrical paragraph structure**
- Every paragraph is exactly: topic sentence → elaboration → example → mini-conclusion
- Feels like a template was filled in

### Counter-signals (marks of authentic writing)

Give credit for these — they push back against a slop verdict:

- Specific named examples (real people, real products, real decisions)
- A claim that someone could actually disagree with
- Sentence-level compression (dense, no filler)
- First-person friction ("I was wrong about...", "This surprised me...", "I still don't know...")
- Domain vocabulary used precisely, not decoratively
- An argument that builds — later sentences depend on earlier ones

## Output Format

Return exactly this structure, tight:

```
GENRE: [linkedin / technical / marketing / political / personal-essay / general]
VERDICT: [Clean / Mild Slop / Heavy Slop / Pure Slop]

TOP ISSUES:
1. [Specific pattern name] — [One quoted phrase from the text that exemplifies it]
2. [Specific pattern name] — [One quoted phrase from the text that exemplifies it]
3. [Specific pattern name] — [One quoted phrase from the text that exemplifies it, if applicable]

SAVING GRACES: [One sentence on what the text does well, or "None detected."]

ONE FIX: [Single highest-leverage edit to make the text more human — be concrete, not generic]
```

### Verdict Calibration

| Label | Meaning |
|---|---|
| **Clean** | ≤1 soft signal, no hard signals. Reads like a person wrote it. |
| **Mild Slop** | 1–2 soft signals or 1 hard signal. Fixable with a pass. |
| **Heavy Slop** | 2+ hard signals or buzzword-saturated. Substantial rewrite needed. |
| **Pure Slop** | Multiple hard signals, no counter-signals. Could have been generated by pressing "write a LinkedIn post about X." |

## Tone of Analysis

- Be direct. Don't soften feedback with "while there are some nice elements here..."
- Quote the text. Abstractions without quotes are useless.
- Name the pattern precisely — "Observation-Without-Consequence" not "lacks depth."
- Do not pad the output. The user asked for tight. Stay tight.

## Bias Guard

Score the text blind. Apply the same standard regardless of who wrote it — the user, their friend, their competitor, or a stranger. If the user wrote the text, do not soften the verdict. If the user's text has the same pattern you'd flag in someone else's, flag it.

If you're comparing two texts in the same session, apply the same rubric to both. A pattern is a pattern regardless of authorship. Don't grade on a curve because one text "feels more authentic" — authenticity is a counter-signal, not a pardon.

## Feed Optimization

After the main verdict, add one line:

```
FEED OPTIMIZATION: [High / Medium / Low]
```

- **High**: Structure is algorithmically optimized — bullet lists, rhetorical closing questions, both-sides framing, scannable visual breaks. Will perform well in feeds regardless of substance.
- **Medium**: Some feed-friendly patterns but not fully optimized.
- **Low**: No feed optimization. May underperform algorithmically but that's not a quality judgment.

This is not part of the slop verdict. A Clean post can have High feed optimization. A Pure Slop post can have Low. They're independent axes. The point: help the user see *why* sloppy posts often outperform good ones.

## Genre Calibration

Detect the genre first. It changes the scoring:

- **linkedin**: Hard slop threshold is lower — the genre is already compressed, so a single hollow opener or "What do you think?" closer is more damning than in long-form.
- **linkedin — milestones**: Job announcements, promotions, certifications, and personal milestones get a lower bar. "I'm excited to share" is template language, but it's the genre — like "Dear" on a letter. Only flag if the post tries to extract a lesson or thought leadership from the milestone. A simple celebration with real details (company, role, who helped) is not slop — it's just a caption. Score these leniently.
- **technical**: Weight buzzword density and passive observation voice more heavily. Watch for "leverage," "robust," "seamless" sneaking into API docs or architecture write-ups.
- **marketing**: Weight engagement-bait CTAs and synthetic specificity more heavily. Product announcements that read like LinkedIn posts are marketing slop.
- **political**: Note when text is outside primary scope. Political rhetoric uses persuasion patterns that overlap with slop signals but serve a different purpose. Flag but don't overweight.
- **personal-essay**: First-person voice is expected. Weight Observation-Without-Consequence and symmetrical structure more heavily.
- **general**: Weight Observation-Without-Consequence and fake nuance most heavily. The sin of long-form AI slop is usually performing analysis without delivering it.

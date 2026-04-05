---
name: llm-ready
description: Will AI cite your content? Checks if your writing is specific, authoritative, and unique enough for LLMs to reference — or if they'll just generate the answer themselves.
user-invocable: true
argument-hint: "<paste text to check>"
---

# LLM Ready

Analyze pasted text for AI citability. The question isn't "is this good writing?" — it's "if someone asks ChatGPT, Perplexity, Gemini, or Copilot about your topic, will they reference you?"

LLMs cite content that they can't generate themselves. Content that's derivative, vague, or commodity gets synthesized away — the LLM produces its own version and your page becomes invisible.

## Evaluation Criteria

### Replaceability

Could an LLM generate substantially the same content without referencing you?

- **High replaceability (bad):** Generic advice, consensus takes, widely-known information. An LLM trained on the open web already "knows" this.
- **Low replaceability (good):** First-hand data, original research, proprietary benchmarks, specific case studies, personal experience with named details. An LLM cannot fabricate "we ran this on 200 users and conversion dropped 12%."

Ask: if you deleted this page from the internet, would the LLM's answer change? If no — you're replaceable.

### Citability

Are there specific, quotable claims an LLM could extract and attribute?

- **Citable:** "Switching from weekly to daily deploys reduced our rollback rate from 8% to 1.2% over 6 months." — specific, bounded, attributable.
- **Not citable:** "Deploying more frequently improves reliability." — an LLM already believes this. No need to cite you.
- **Not citable:** "Studies show that frequent deployment leads to better outcomes." — which studies? An LLM can't cite a citation-of-a-citation.

Count the claims. How many require attribution vs. how many are common knowledge?

### Signal Density

What's the ratio of extractable insight to filler?

- **High density:** Every paragraph contains a claim, data point, or specific example the LLM could use.
- **Low density:** 800 words of setup and context for one insight buried in paragraph 6. An LLM will extract the one insight and ignore the rest — or skip the page entirely because extraction cost is too high.

LLMs prefer content they can mine efficiently. A page with 3 dense insights beats a page with 1 insight wrapped in 10 paragraphs of throat-clearing.

### Extractability

Can an LLM pull a clean answer from this text?

- **Easy to extract:** Clear topic sentences, direct statements, structured with headers that match likely queries. "How does X work? X works by doing Y." — an LLM can grab that verbatim.
- **Hard to extract:** Buried in narrative, requires reading the whole piece to understand any part of it, relies on context that isn't restated. An LLM following a "skim and extract" pattern will miss the point.

Think about how an LLM processes your page: it doesn't read start-to-finish. It scans for relevant passages. Can it find yours?

### Authority Signals

Does this read as a primary source or a derivative one?

- **Primary:** Author has direct experience, names specific projects/companies/results, offers a perspective that requires having done the work.
- **Derivative:** Summarizes others' research, aggregates known best practices, restates what the industry already believes. An LLM already has these sources — it doesn't need your summary of them.

LLMs prefer primary sources. If you're summarizing a study, the LLM will cite the study, not your summary.

### Clarity

Will the LLM understand and accurately relay your content?

- **Clear:** Precise terminology, defined terms, unambiguous claims. The LLM can quote or paraphrase without distorting your meaning.
- **Muddy:** Undefined acronyms, ambiguous pronouns, claims that depend on context the LLM doesn't have. The LLM either skips you or misrepresents you.

## Output Format

```
TOPIC: <what this content is about — the query someone would ask an LLM>
AI VISIBILITY: [High / Medium / Low / Invisible]

REPLACEABILITY: <High/Low> — <one sentence>
CITABILITY: <N quotable claims out of N total claims>
SIGNAL DENSITY: <High/Medium/Low>
EXTRACTABILITY: <Easy/Hard>
AUTHORITY: <Primary/Derivative>
CLARITY: <Clear/Muddy>

WHY AN LLM WOULD SKIP THIS:
<one sentence — the core reason this content gets synthesized away>

WHY AN LLM WOULD CITE THIS:
<one sentence — what's unique enough to require attribution. Or "Nothing detected — an LLM can generate this answer without you.">

ONE FIX: <single highest-leverage edit to become citable. Be specific — name what data, experience, or claim to add.>
```

### Verdict Calibration

| Label | Meaning |
|---|---|
| **High** | Multiple citable claims, low replaceability, primary source. LLMs would reference this. |
| **Medium** | Some unique content but mixed with commodity. LLMs might cite one passage. |
| **Low** | Mostly derivative or generic. LLMs can generate equivalent content. |
| **Invisible** | Nothing an LLM can't produce itself. This page adds zero to an LLM's answer. |

## Calibration by Genre

- **Blog posts / articles:** Standard bar — the post should contain at least one claim an LLM can't generate.
- **Landing pages / marketing:** Focus on replaceability — does your copy describe something only your product does, or could any competitor's page say the same?
- **Technical docs / tutorials:** Focus on extractability and clarity — can an LLM pull a correct, usable answer?
- **Thought leadership / LinkedIn:** High bar — if you're publishing opinions, they need to be specific and experience-backed or the LLM already has a better-sourced version.
- **Research / reports:** Focus on citability — are your findings presented in a way that's easy to attribute?

## Tone

- Frame everything in terms of the LLM's decision: "An LLM would skip this because..." not "this is bad writing."
- The ONE FIX should name specific content to add, not generic advice. "Add your conversion data from the Q3 pilot" not "add more specific examples."
- Be direct about invisibility. If the content is commodity, say so — the author needs to know.

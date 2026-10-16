---
name: html-artifact
description: >
  Build one self-contained HTML page for a human to read: a report, explainer, design doc
  view, plan, diagram, deck, dashboard, mockup, or working prototype. Use when the user
  asks for an "HTML report", "render this as HTML", "visualize this", or when the content
  holds a comparison, a sequence, a hierarchy, metrics, or a state model that Markdown
  cannot carry. Not for application UI work.
license: MIT
allowed-tools: Bash(open *) Bash(xdg-open *) Bash(start *)
---

# HTML Artifact

One self-contained HTML file that makes the subject easier to read, compare, or drive. Care that fits the subject, no house look. Do not reuse a palette or card system from an earlier artifact.

## 1. Is HTML the deliverable?

- Markdown is enough for a short explanation, a note, a list, or a document a human edits often. Say so, write Markdown.
- Build HTML when the user asked for it, or when the content holds a comparison, a sequence, a hierarchy, a metric set, or a state model.
- Never wrap plain paragraphs in cards, gradients, and a hero. That adds nothing.

## 2. Settle before code

**Authority order**, a later rank never overrules an earlier one: what the user said, the project's design system (`AGENTS.md`, `DESIGN.md`, a tokens file, an existing component), the subject and audience, your own taste.

**Five answers:**

- Audience and job: who reads this, what must they understand or do?
- Form: document, deck, interface, diagram, or data view.
- Register: workmanlike (reports, plans, design docs, status) or editorial (a landing page, a deck, a demo someone keeps). Workmanlike is the default: real hierarchy, chosen spacing, chosen palette, no towering hero.
- Fidelity: keep the user's structure and wording, or synthesize.
- Interaction: what gains from disclosure, filtering, sequencing, or motion. Nothing is the common answer.

Then write a three-line design plan before code: 4 to 6 named colours, the type faces and their roles, the layout idea in one sentence. Trace every decision back to it.

## 3. Archetype

| Job | Shape |
|---|---|
| Report, explainer, plan, status, incident, research synthesis | Section 4 |
| Deck | Section 4, presentation rules |
| Architecture, flow, sequence, state, hierarchy, matrix, chart | [diagram.md](diagram.md) |
| Mockup, wireframe, working flow | Section 5 |

## 4. Report

The reader reads it once. The first screen carries the answer.

Spine: frame (title plus one sentence on why now), TL;DR (the verdict or finding), context, substance (one question per section), visuals where the content holds a relationship or magnitude, surprises (what a reader assumes wrongly), what is next, sources (file, commit, URL, thread, enough to verify alone).

- Separate observation, interpretation, recommendation, and uncertainty. A recommendation never wears the visual weight of a measured fact.
- A comparison keeps like-for-like attributes aligned so the eye compares without memory.
- A plan keeps the user's scope, order, and vocabulary. Add owners, dependencies, risks, completion conditions. Do not inflate it into a strategy.
- A report reorganizes. It never summarizes away a commitment. Check every source claim against the page before you report.
- A number, an eyebrow, a divider, or `01 / 02 / 03` earns its place only when it states something true. Long prose stays prose. Not every paragraph is a card.

**Deck:** one idea per screen. Arrow-key navigation, a visible progress mark, a link per slide. A build or transition controls the order of an explanation, never decorates. Narrow screens get a scrolling fallback. A request that blends document and deck gets the mode the audience will use, not two half-working ones.

## 5. Prototype

Model one product decision. Pick the fidelity:

- **Mockup**: polished, responsive, mostly static. The question is hierarchy, layout, type, colour.
- **Wireframe**: deliberately unfinished, so the review is about structure, not shade.
- **Prototype**: a working flow with real states. The question is navigation, input, feedback, recovery.

Scope the smallest flow that answers the question, with realistic, consistent names, dates, and statuses. List reachable states before you build (loading, empty, error, success, disabled, narrow, plus the brief's own) and implement the ones the scenario reaches. Name the omitted states in the handoff. Remove dead buttons. Where an action belongs to the real system, state the boundary. A dialog has an accessible name, contains focus, closes on `Escape`, returns focus to its trigger. In mockup and wireframe mode, keep the semantic structure and the focus styles even when a control does nothing.

## 6. Build contract

- One `.html` file. CSS and JavaScript inline. No build step. Tailwind and Mermaid from CDN when needed, nothing else external. A real fallback font stack, so the page reads offline.
- Real content from the first draft. No lorem ipsum, no invented statistic, no control that does nothing (a mockup or wireframe states its static boundary instead).
- Semantic HTML: `<pre><code>` for code, `<table>` for data, inline `<svg>` for diagrams. Never a screenshot of text. Every value, label, and code line is selectable.
- Design tokens in `:root`, consumed everywhere. Light and dark: `prefers-color-scheme`, and a `data-theme` attribute on the root that beats the media query in both directions. The dark theme is designed, not inverted.
- Type: a display face and a body face, a data face when numerals stack. Measure capped near 65 characters. One type scale. `tabular-nums` on numeric columns.
- Layout: spacing by `gap` on the group, not per-element margins. One column below about 700px. Broad content in its own `overflow-x: auto` region. The body never scrolls sideways.
- Copy: name things as the reader knows them, not as the backend does. Active verbs. An error names the failure and the fix.
- Interface pages (dashboard, tool): rollup first, state carried by a pill or stripe beside the figure, status colours apart from the accent hue, anything clickable looks clickable.
- Safe DOM: `textContent` and `createElement`. Never assign data to `innerHTML`.
- Keyboard: visible focus on every control. `prefers-reduced-motion` replaces motion with an immediate state change. Contrast to WCAG AA. Meaning never in colour alone.
- `@media print`: hide controls, expand disclosures, `overflow: visible`.
- Avoid the machine costumes unless asked: cream paper with a serif and terracotta, near-black with acid green, a purple-to-blue gradient hero, Inter or Space Grotesk by default, emoji as section markers, centre alignment plus `rounded-lg` plus an accent bar on every card.

## 7. Visuals and the glance gate

Recommend a diagram or chart when the content holds a sequence, a hierarchy, a distribution, a magnitude, or a relationship. The failure mode is a large tangled picture. Resist drawing everything at once.

Every visual reads in one look:

- 12 elements or fewer. Split at about 15.
- One direction per diagram.
- A label on every box and every arrow.
- Size each box from its label, or use `<foreignObject>` so text wraps.
- Three colours at most, each with a meaning.
- When a visual fails: bound it, split it into zoom levels, or move detail behind a disclosure. If it still fails, label it "too dense to read at a glance, detail below". Never ship a dense picture as an overview.

[diagram.md](diagram.md) has the grammar table, renderer choice, sizing numbers, and chart rules.

## 8. Quiz

Add an interactive quiz when the artifact teaches: explainer, report, plan, design doc, walkthrough, research synthesis. Skip it for a diagram, dashboard, tool, mockup, wireframe. The user's "no quiz" wins. Contract in [quiz.md](quiz.md).

## 9. Write, verify, hand over

Write to `docs/<slug>.html` in the project. Do not commit unless asked.

Verify: open the file at a wide and a narrow width, exercise every control, read the console, run the glance gate on every visual, check for clipped text, overlap, weak contrast, dead controls, sideways scroll, placeholder copy, invented numbers. Inspect the computed foreground and background on every tinted surface. If browser tooling is unavailable, name the checks that did not run. Never report an unverified page as verified.

Open it when the platform allows (`open`, `xdg-open`, `start`). Report the absolute path as a `file://` URL, the archetype, and the two or three visual decisions you made.

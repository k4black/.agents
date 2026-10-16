---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This command is _informed_ by the project's domain model and built on a shared design vocabulary:

- Use this architecture vocabulary exactly in every suggestion: **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality** — and these principles: the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real". Don't drift into "component," "service," "API," or "boundary."
- The domain language in the Terminology section of AGENTS.md/CLAUDE.md gives names to good seams; locked Decisions in `docs/design/` record choices this command should not re-litigate.

## Process

### 1. Explore

**Scope before you scan — YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction — a module, a subsystem, a pain point — take it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log --oneline`) to find the codebase's hot spots — the files and areas that keep coming up — and let those paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read the project's Terminology section (AGENTS.md/CLAUDE.md) and any `docs/design/` decisions for the area you're touching first.

Then spawn a sub-agent to walk the codebase — a read-only exploration agent if your harness has one. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an HTML report

Build and deliver the page with the `html-artifact` skill (report archetype). It owns the build contract, the glance gate, and the output path.

Each candidate gets a **before/after visualisation**: a Mermaid graph for call flow and dependencies, hand-built boxes when the "after" must read as one thick deep module, a cross-section of layers for layered shallowness, a mass diagram (interface rectangle versus implementation rectangle) for a wide interface. Mix the patterns. Use the project glossary for domain nouns, and these architecture terms exactly: module, interface, implementation, deep, shallow, seam, adapter, leverage, locality. Never "component", "service", "layer", "boundary" for those.

For each candidate, render a card with:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram** — side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use the Terminology section's vocabulary for the domain, and the architecture vocabulary above for the architecture.** If Terminology defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**Decision conflicts**: if a candidate contradicts a locked Decision in `docs/design/`, only surface it when the friction is real enough to warrant reopening that doc. Mark it clearly in the card (a warning callout: _"contradicts docs/design/2026-01-10-x.md — but worth reopening because…"_). Don't list every theoretical refactor a past decision forbids.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, run the `grill-me` skill to walk the decision tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize — run the `/domain-modeling` skill to keep the domain model current as you go:

- **Naming a deepened module after a concept not in Terminology?** Add the term (create the section lazily).
- **Sharpening a fuzzy term during the conversation?** Update Terminology right there.
- **User rejects the candidate with a load-bearing reason?** Offer to record it as a locked Decision in a short dated `docs/design/` doc, framed as: _"Want me to record this so future architecture reviews don't re-suggest it?"_ Only when a future explorer would actually need the reason — skip ephemeral ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** Design it twice: sketch two alternative interfaces with parallel sub-agents and compare before committing to one.

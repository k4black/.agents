---
name: ste100
description: >
  Write or audit technical prose against ASD-STE100 Simplified Technical English, so a
  tired, non-native reader understands it on the first pass. Load it when you write a
  design doc, a tech spec, a handoff, a README, a runbook, agent instructions, a
  postmortem, or a long PR or commit body, and when the user says "STE", "simplified
  technical english", or asks to make text clearer or shorter.
license: MIT
argument-hint: "[audit] [text or path]"
---

# Simplified Technical English

The reader is tired, under time pressure, and reads English as a second language. A sentence that needs a second pass is a defect. Target: about 90% of the standard. Domain terms stay: `idempotent`, `backpressure`, `webhook` are technical nouns. Certified conformance needs the official dictionary, which this skill does not carry.

## Two jobs

- **Rewrite** (default): produce the compliant text first, complete and ready to paste. Then list the changes in three lines maximum. Flag what you cannot fix because the source is ambiguous. Ask, do not guess.
- **Audit** (`audit` in the argument): report violations without changing the text. For each: location, the quoted span, the replacement.

## Pass 1: classify

| Aspect | Procedural | Descriptive |
| --- | --- | --- |
| Job | Tell the reader what to do | Explain what something is or does |
| Verb form | Imperative: "Restart the pod." | Simple present, past, or future |
| Sentence limit | **20 words** | **25 words** |
| Unit | One instruction per sentence | One topic per paragraph, six sentences maximum |

A quickstart is procedural. An architecture overview is descriptive. A note inside a procedure is descriptive.

## Pass 2: freeze the vocabulary

One concept, one word, for the whole document. When the word changes, the reader assumes the meaning changed. Pick one per row before you write:

- check / verify / confirm / validate / ensure → "make sure that"
- config / configuration / settings / options → one
- run / execute / invoke / launch / trigger → one
- show / display / render / present → one
- delete / remove / drop / destroy → one word per distinct meaning
- error / issue / problem / failure → `error` for the message, `failure` for the operation that stopped

When the project glossary (the Terminology section) already names a concept, use that name.

## Pass 3: write

**Verbs.** Allowed forms: infinitive, imperative, simple present, simple past, simple future, past participle as adjective ("the cached response"). No compound tense: "has been running" hides when it started. No `-ing` as a verb or trailing clause: ", allowing you to skip the restart" hides a fact. Promote it to its own sentence.

**Modals.**

| Allowed | Meaning |
| --- | --- |
| `can` | Ability or permission |
| `will` | A future fact |
| `must` | An obligation |

| Rejected | Write instead |
| --- | --- |
| `should` | `must`, or state the condition and the consequence |
| `may` / `might` / `could` | `can`, or name the condition |
| `would` | Simple present or past |
| `need to` / `have to` | `must` |
| `it is recommended to` | `must`, or delete |

**Voice.** Active, with a named subject. Passive is allowed only when the agent is unknown or irrelevant.

**Sentences.** One idea each. Put the condition first: "If the pool is full, the request waits." Keep a multi-word noun to three words. Break a longer chain with `of`, `in`, `for`. Repeat the noun instead of `it`, `this`, `that` when more than one referent is possible. Never delete a fact, an article, or the word `that` to fit a limit. Split the sentence instead. Never invent a number to replace a vague adjective. Drop the adjective.

**Warnings.** A warning comes before the step it protects, as its own sentence.

**Delete on sight.**

| Instead of | Write |
| --- | --- |
| in order to | to |
| due to the fact that | because |
| in the event that | if |
| prior to / subsequent to | before / after |
| utilize / leverage | use |
| perform a validation of | validate |
| is able to / allows you to | can / you can |
| e.g. / i.e. / etc. | for example / that is / name the items |
| and/or | one, or "X, Y, or both" |
| simply, just, easily, seamlessly, gracefully | delete |
| robust, powerful, comprehensive, blazing fast | delete, or give the measurement |
| it is worth noting that, importantly | delete, state the fact |
| as needed, as appropriate | name the condition |
| handles X gracefully | say what it does: "retries twice, then stops" |

## Never rewrite

Code blocks, inline code, identifiers, commands, flags, paths, environment variables, config keys, endpoints, product names, and quoted error or log lines. Reproduce them exactly. A reader who copies a "corrected" command gets a new error.

## Self-check before you deliver

| Search for | Fix |
| --- | --- |
| `'ll` `'re` `'ve` `n't` `it's` | Expand the contraction |
| `has been` `have been` `is being` | Simple tense |
| `should` `would` `may` `might` `could` | The modal table |
| `, making` `, allowing` `, enabling` `, ensuring` | A new sentence with a subject |
| `;` | Two sentences |
| `if` or `when` after the command | Move the condition to the front |
| `e.g.` `i.e.` `etc.` | Expand it |

Then count the three longest sentences against the 20/25 limit, each paragraph against six sentences, and search for the words you rejected in pass 2. A rewrite that grows more than 20% added content that was not there. Say why.

## Audit report format

Three levels. Thirty equal findings get none fixed.

- **Blocking**: more than one possible reading, or hidden information. Passive in a postmortem, an ambiguous pronoun in a runbook step, two names for one concept.
- **Important**: one reading, but extra work. A nominalization, a compound tense, a four-noun chain, an over-budget sentence.
- **Minor**: mechanical, batch them. A contraction, a Latin abbreviation, a semicolon, a bloat phrase.

```
**L12: passive hides the agent**
- Now:   The schema was changed and the consumers were not notified.
- Write: The platform team changed the schema. The team did not notify the consumers.

**L31: two names for one concept**
- `tenant` (L4, L18) and `workspace` (L31, L44). Use `tenant`, because the code uses `tenant`.

Minor: L7, L22, L40 semicolon → two sentences. L15 `e.g.` → "for example".
```

End with a terminology table when pass 2 found drift: concept, names found, use.

## Worked example

Before:

> If you're seeing elevated latency after a deploy, it's worth checking whether the connection pool is saturated — this is often caused by long-running queries holding connections, which can prevent new requests from acquiring one. You should also verify that `pool_max` hasn't been left at the default (10).

After, classified as procedural:

> Latency increases when long queries hold every connection in the pool. New requests then wait for a free connection.
>
> 1. Make sure that the pool is not saturated. Compare the active connections against `pool_max`.
> 2. Make sure that `pool_max` is not at the default of `10`.

## Out of scope

Marketing pages, launch posts, brand writing. STE removes persuasion by design. Say so, and offer it for the documentation the page links to.

ASD-STE100 is a trademark of ASD. The specification is free at asd-ste100.org. This skill is not an official ASD document.

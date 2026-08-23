---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
argument-hint: "Plan, design, or topic to grill"
---

Interview me relentlessly about this plan until we reach a shared understanding.
Map it as a **design tree**: every decision branches into the decisions that hang
off it. Work the tree in **rounds**, and do not enact anything until I confirm.

## Facts vs decisions

Two kinds of information. Never confuse them:

- **Facts** are things you find by exploring: existing patterns, current
  implementations, real constraints. Never ask me for a fact. Go look it up and
  cite what you found. A grilling session where you answer your own questions is
  not grilling; without my answers there is no shared understanding.
- **Decisions** are things only I can decide: architecture, feature scope,
  trade-offs, priorities. Never settle these yourself. Put each to me and wait.

## The frontier

The **frontier** is every decision whose prerequisites are already settled: the
questions you can ask now without guessing at answers you have not heard yet. A
question whose answer depends on another question still open belongs to a later
round.

Each round you settle answers, the tree reshapes: settled decisions push the
frontier outward and unblock questions that depended on them. Re-derive the
frontier after every round. Drop questions the answers just settled. Re-frame the
ones whose options changed. Never re-ask something already answered, and never ask
two questions that collect the same decision twice.

## Fact-finding does not block the round

When a frontier question needs a fact from the environment, dispatch a sub-agent
to find it. Do not block the whole round on it: a running exploration is an
unsettled prerequisite, so only the questions downstream of it wait for the report.
Ask the rest of the frontier now.

## Asking a round

Serve the frontier through the harness's structured question tool:
`AskUserQuestion` in Claude Code, the `question` tool in OpenCode, otherwise a
short numbered list in a single message.

A round is **at most 4** questions from the frontier that share **one topic**
(security, CI setup, data model, deployment). Mixing topics forces me to
context-switch mid-answer. If the frontier holds more than one topic or more than
4 questions, serve the rest in later rounds. A single blocking fork on its own is
a fine round.

For each question, give the options as real alternatives with their consequences,
and mark your Recommended answer.

## Done

The session is done when the frontier is empty: every branch of the design tree
visited, nothing left silently assumed. Then summarize the locked decisions and
ask me to confirm. **Do not enact the plan (no code, no files, no state-changing
commands) until I explicitly confirm we have reached a shared understanding.**

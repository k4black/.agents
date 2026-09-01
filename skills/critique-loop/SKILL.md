---
name: critique-loop
description: >-
  Cross-model adversarial review with Codex, OpenCode, or Pi CLI. Runs a single-round critique on
  a plan, an implementation diff, or an existing PR diff, returning text output directly without
  writing artifact files. Two flows: full flow (plan -> 1-pass review -> approve -> implement ->
  1-pass review -> done) and review-only flow (existing diff -> 1-pass review -> fix -> done).
license: MIT
compatibility: >-
  Requires one authenticated agent CLI: Codex (`codex`), OpenCode (`opencode`), or Pi (`pi`).
  Run from inside a git repository on a feature branch.
allowed-tools: Bash(codex exec *) Bash(opencode run *) Bash(pi *) Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git rev-parse *) Bash(git branch --show-current)
argument-hint: "Task to drive, or empty to review the current diff"
---

Cross-model critique loop: Driver leads planning and implementation; an independent harness and model (the **navigator**) provides a single-pass adversarial review.

Two flows:
- **Full flow** — Plan -> Navigator reviews plan (1 pass) -> Address asks -> User approves -> Implement -> Navigator reviews diff (1 pass) -> Fix actionable asks -> Done.
- **Review-only flow** — Navigator reviews an existing diff (1 pass) -> Fix actionable asks -> Done.

All reviews return directly as standard text in stdout. No `.critique-loop/` scratchpads or artifact files are written to disk.

## Harness Invocation Cheat Sheet

Select the desired harness and model. When using OpenRouter, models **must** include the prefix: `openrouter/<provider>/<model>` (e.g. `openrouter/anthropic/claude-3.7-sonnet`, `openrouter/google/gemini-2.5-pro`, `openrouter/z-ai/glm-5.3-flash`).

### 1. Codex CLI (`codex`)
- **Default / One-shot:**
  ```bash
  codex exec [-m <model>] "<PROMPT>" < /dev/null
  ```
  *(Note: `< /dev/null` is mandatory to prevent stdin blocking).*

### 2. OpenCode CLI (`opencode`)
- **Default / One-shot:**
  ```bash
  opencode run [-m <provider/model>] [--variant high] "<PROMPT>"
  ```
  *(e.g. `opencode run -m openrouter/anthropic/claude-3.7-sonnet --variant high "<PROMPT>"`).*

### 3. Pi CLI (`pi`)
- **Default / Ephemeral Print:**
  ```bash
  pi -p [--model <model>] [--thinking high] --no-session "<PROMPT>"
  ```
  *(e.g. `pi -p --model openrouter/google/gemini-2.5-pro:high --no-session "<PROMPT>"`).*

---

## Phase 1: Draft the plan

**Step 1 — Understand task & context:**
Explore relevant codebase files and constraints. Keep plan minimal and actionable.

**Step 2 — Draft the plan text:**
Structure the plan:
- **Task**: 1-2 sentence goal.
- **Context**: Existing patterns and constraints.
- **Approach**: Numbered concrete implementation steps with `path/to/file:line` targets.
- **Verification**: Exact test/lint commands to run.
- **Open questions**: Unresolved business logic or tradeoffs.

---

## Phase 2: Navigator reviews the plan (1 pass)

**Step 3 — Run navigator review:**
Pass the plan in the prompt to the selected harness:

```
You are the navigator in an adversarial pair-programming session. The driver wrote a plan.

Plan:
<PLAN_TEXT>

Probe for:
- Missing edge cases and error paths
- Risky assumptions or unstated dependencies
- Scope mismatch with the task
- Simpler alternatives
- Verification steps that do not prove correctness

Output format:
1. One-sentence overall assessment.
2. Numbered asks: problem, rationale, proposed solution, file:line citations.
3. Final line: exactly `VERDICT: APPROVE`, `VERDICT: CHANGES_REQUESTED`, or `VERDICT: BLOCK`.

Do not edit files. Review only.
```

**Step 4 — Triage asks:**
- **Resolve directly**: edge cases, clearer steps, missing unit tests, simpler code-level alternatives.
- **Surface to user**: product decisions, ambiguous requirements, scope changes, architectural tradeoffs.
- If `VERDICT: BLOCK`: summarize the blocker to the user and wait for direction.

**Step 5 — User approval gate:**
Present to the user:
- Summary of the updated plan and key decisions.
- Addressed navigator feedback.
- Open questions (if any).
- Ask user for approval before implementing.

---

## Phase 3: Implement the plan

**Step 6 — Record baseline SHA:**
```bash
PLAN_SHA=$(git rev-parse HEAD)
```

**Step 7 — Implement:**
- Implement the approved plan.
- Keep diff minimal and follow repo conventions.
- Commit changes using Conventional Commits.
- Run tests and lint to ensure everything passes.

---

## Phase 4: Navigator reviews the diff (1 pass)

**Step 8 — Run code review:**
Get diff with `git diff ${PLAN_SHA}..HEAD` and invoke the selected harness:

```
The plan is implemented. Review the git diff.

Diff:
<GIT_DIFF_OUTPUT>

Probe for:
- Logic bugs, regressions, missed edge cases
- Inadequate test coverage
- Scope creep or leftover temporary code
- Over-engineering or unnecessary complexity

Output format:
1. One-sentence overall assessment.
2. Numbered asks with file:line references.
3. Final line: exactly `VERDICT: APPROVE`, `VERDICT: CHANGES_REQUESTED`, or `VERDICT: BLOCK`.

Do not edit files. Review only.
```

**Step 9 — Address findings:**
- Fix valid bugs and missing tests immediately.
- Re-run test and lint suites.
- If an ask requires user product/architecture direction, summarize it.

**Step 10 — Final report:**
Present a concise summary to the user:
- Baseline SHA and final HEAD SHA.
- Applied review fixes.
- Test verification status.

---

## Review-only flow

For an existing diff without a prior plan:

1. **Identify diff range:**
```bash
DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
DEFAULT=${DEFAULT:-$(git branch -l main master --format='%(refname:short)' | head -1)}
BASE=$(git merge-base HEAD "origin/$DEFAULT" 2>/dev/null || git merge-base HEAD "$DEFAULT")
REVIEW_RANGE="${BASE}..HEAD"
DIFF_CONTENT=$(git diff ${REVIEW_RANGE})
```

2. **Run single review pass:**
Invoke the chosen harness (Codex, OpenCode, or Pi):
```
Review the diff in range ${REVIEW_RANGE}.

Diff:
<DIFF_CONTENT>

Probe for bugs, regressions, missed edge cases, missing tests, and unnecessary complexity.
Output numbered asks with file:line references, ending with `VERDICT: APPROVE | CHANGES_REQUESTED | BLOCK`.
Do not edit files.
```

3. **Address actionable findings:**
- Fix clear bugs and add missing tests.
- Re-run test suite.
- Present summary of findings and applied fixes to the user.

# .agents

Personal agentic setup: skills, global agent rules, hooks, and workflows — separated from
system dotfiles (which stays a pure shell/system config repo in `.dotfiles`).

**One command wires every agent harness on any machine, idempotently:**

```bash
./install.sh
```

Re-run it after you install a new agent CLI. `link-skills.sh` creates three root symlinks to `skills/`.
Add a new `skills/<name>/SKILL.md` without another installer run. Each agent discovers the skill through the existing links.

It installs no binaries: the homelab MacBook playbook does. It exits 1 when `claude`, `codex`,
`opencode`, `pi`, `jq` or `dart` is missing.

## What it wires

| Harness | Skills | Global rules |
|---|---|---|
| Claude Code | `~/.claude/skills` → `skills/` | `~/.claude/CLAUDE.md` → `GLOBAL-AGENTS.md` |
| Codex CLI | `~/.codex/skills` and `~/.agents/skills` → `skills/` | `~/.codex/AGENTS.md` → `GLOBAL-AGENTS.md` |
| OpenCode | reads `~/.claude/skills` + `~/.agents/skills` natively | `~/.config/opencode/AGENTS.md` → `GLOBAL-AGENTS.md` |
| Pi | reads `~/.agents/skills`; `~/.pi/agent/extensions/*` contains extensions | `~/.pi/agent/AGENTS.md` → `GLOBAL-AGENTS.md` |

`skills/hex` points to `../../hex/skills/hex`. It resolves when the `hex` repository is a sibling checkout.

### Skill discovery

Keep shared skills directly under `skills/<name>/SKILL.md`. Grouped collections are not portable across all four agents.

| Agent | Discovery below a skill root | Directory symlinks |
|---|---|---|
| Claude Code 2.1.308 | Immediate skill folders only. A local discovery probe skipped `group/<name>/SKILL.md`. | Individual skill folders and the root work. A linked collection did not work. |
| Codex | Recursive discovery. | Supported. |
| Pi 1.3.0 | Recursive discovery. Stops below a folder containing `SKILL.md`. | Supported. |
| OpenCode 2.1.2 | Recursive discovery, up to six directories. Stops below a folder containing `SKILL.md`. | Supported. |

Sources: [Claude Code](https://code.claude.com/docs/en/skills),
[Codex](https://developers.openai.com/codex/skills/),
[Pi](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md),
[OpenCode v2](https://opencode.ai/v2/docs/skills/).

Claude Code prevents a shared layout based on links to grouped collections.
The three root links serve Claude Code, Codex, Pi, and OpenCode without links for individual skills.
An existing session can require a skill reload or restart after an addition. No filesystem relink is necessary.

On first setup, the linker moves local skill entries into `skills/` when their names are available.
It removes old links from this setup. It backs up collisions and other remaining entries before replacing each directory.
Backups use `<path>.pre-agentic-tools.<timestamp>.<pid>.bak`. Existing correct root symlinks remain unchanged on later runs.
New skills installed through any shared root then appear through the other roots without another migration.

### Claude Code project instructions

`install.sh` enables the built-in `cc-plugin-agents-md` mod through Claude's CLI.
It sets `instructionFiles` to `claude-md-and-agents-md`, so project `AGENTS.md` files load alongside `CLAUDE.md` files.
Claude skips an `AGENTS.md` that a `CLAUDE.md` already imports or links to.
Projects that use only `AGENTS.md` require no `CLAUDE.md` wrapper.

The installer uses these commands, verified with Claude Code 2.1.308:

```bash
claude plugin enable cc-plugin-agents-md@builtin --scope user
claude plugin configure cc-plugin-agents-md@builtin --values-stdin <<'JSON'
{"instructionFiles":"claude-md-and-agents-md"}
JSON
```

Verified with a Sonnet CLI session in a temporary Git repository that contained `AGENTS.md` and no `CLAUDE.md`.
With all tools disabled, Sonnet returned a random marker from the loaded project instructions.

Keep the `~/.claude/CLAUDE.md` link for personal rules. Direct `AGENTS.md` support concerns project instructions.
For existing sessions, reload plugins or start a new session after configuration.
See [Claude's instruction-file documentation](https://code.claude.com/docs/en/memory#agentsmd) and the
[built-in mods overview](https://code.claude.com/docs/en/plugins/mods/overview).

Tool configuration is never manually-edited: Claude Code marketplaces/plugins go through the
`claude plugin` CLI, and the Dart/Flutter MCP server through `claude mcp add` /
`codex mcp add` — so a fresh machine gets the full setup in one run.

### FreeCAD MCP

`install.sh` registers the [freecad-mcp](https://github.com/neka-nat/freecad-mcp) server (`uvx freecad-mcp`) in Claude Code and Codex. It does this only when `/Applications/FreeCAD.app` and `uvx` exist. The FreeCAD side is manual, once per machine:

1. Copy the addon into the FreeCAD 1.1 user `Mod` directory:
   ```bash
   git clone --depth 1 --branch v0.1.27 https://github.com/neka-nat/freecad-mcp.git /tmp/freecad-mcp
   cp -R /tmp/freecad-mcp/addon/FreeCADMCP ~/Library/Application\ Support/FreeCAD/v1-1/Mod/
   ```
2. Restart FreeCAD.
3. Select the **MCP Addon** workbench. Click **Start RPC Server**. The server listens on `127.0.0.1:9875`.
4. Optional: in the **FreeCAD MCP** menu, check **Auto-Start Server**.

Codex asks for approval before each FreeCAD write tool. In `codex exec`, `approval_policy=never` rejects these tools. Use `--approve-for-me` instead.

The RPC server has no authentication. Keep **Remote Connections** off. The `execute_code` tool runs any Python in FreeCAD with your user permissions.

The Pi web-access extension is configured for headless search: `install.sh` sets
`"workflow": "none"` in `~/.pi/agent/web-search.json`, so `web_search` returns raw results and
never opens the curator browser tab. It only adds the key when absent — an explicit
`summary-review` or `auto-summary` choice is left alone.

Read-only commands (`ls`, `grep`, `find`, `git log/diff/…`, `gh pr view/…`) are pre-approved in
every repo: `permissions/claude-allow.json` is merged into user-level
`~/.claude/settings.json` (rules merge additively across scopes; project denies still win), and
`permissions/codex.rules` is an execpolicy file symlinked into `~/.codex/rules/` (additive —
codex's own "always allow" amendments stay in `default.rules`).
Deliberately excluded: test runners (project-level decision), `gh api` (can POST).

Everything is symlinked, so the harnesses track this repo live (edit a SKILL.md, it's live everywhere).

### Removed: RTK (Rust Token Killer)

RTK used to be wired in here — a `PreToolUse` hook rewriting Bash commands (`git status` →
`rtk git status`), a global-rules section telling other harnesses to prefix manually, and
`rtk`-variant permission rules. It's gone as of 2026-07-30, per
[Does "rtk" skill really cut agent tokens by 60–90%? We tested it](https://blog.jetbrains.com/ai/2026/07/rtk-claude-code-token-savings/):
the measured result was a **median +7.6% cost increase** at low reasoning effort (p=0.004) and
flat zero at high effort — not the advertised 60–90% savings. RTK compresses only ~20% of shell
output, while Claude Code already truncates long results and cached input dominates the bill.
Its own "tokens saved" counter measures compression ratio, not billing impact.

Don't re-add it without paired-invoice evidence.

### Unwired: ralph-orchestrator

Also 2026-07-30: ralph is no longer wired into any harness — the `ralph` MCP server, the
`ralph-orchestrator@ralph-orchestrator` plugin and its marketplace, and the
`~/.ralph/config.yml` + `~/.config/ralph/presets` symlinks are all removed. The MCP server
never connected (`ralph mcp` is a real subcommand on 2.10.1, but it failed health checks).

Unlike RTK this is a *pause, not a deletion*: `ralph/` stays in the repo with its config, five
hat-collection presets and project template, and the `install.sh` blocks are commented out
rather than removed. To re-enable, uncomment every block marked `ralph (disabled)` (including
the `ralph_supported()` helper) and re-run `./install.sh`. The `ralph` binary itself is
untouched.

## Layout

```
skills/            canonical skill tree — agentskills.io spec, one folder per skill
GLOBAL-AGENTS.md   single source of truth for global rules (orientation docs, language, git conventions)
ralph/             ralph-orchestrator config, presets (design-doc, implement[-plus], tdd[-plus]), project template — UNWIRED, kept for later
permissions/       pre-approved read-only commands: claude-allow.json (merged into
                   ~/.claude/settings.json) + codex.rules (execpolicy, symlinked)
install.sh         the idempotent bootstrap
```

## Skills

| Skill | Purpose |
|---|---|
| `agent-cli` | Flags to run Codex, OpenCode, Pi, and Claude Code non-interactively: model, reasoning, read-only sandbox, output, stdin traps. Technical reference, no routing advice |
| `anki-connect` | Create/find/update Anki flashcards via AnkiConnect |
| `apple-notes` | Read/reorganize Apple Notes without stripping hyperlinks |
| `apple-reminders` | Add/view/complete Apple Reminders |
| `babysit-pr` | Drive a PR to merge-ready: fix CI, resolve bot review threads (slop-free), draft human review replies |
| `cleanup-git` | Reclaim disk space by finding and safely removing merged git worktrees, merged branches, and scratch dirs without `--force` |
| `code-review` | Two-axis diff review — Standards (repo docs + Fowler smell baseline + simplify/dedup) and Spec (vs the design doc/issue) — in parallel sub-agents |
| `critique-loop` | Cross-model adversarial review (Codex/OpenCode/Pi navigator), single-pass critique on plans or code diffs |
| `design-doc` | Research → grill → write `docs/design/yyyy-MM-dd-<slug>.md` feature design doc, renders an interactive HTML view via `html-artifact` |
| `diagnosing-bugs` | Feedback-loop-first diagnosis for hard bugs: build a tight red-capable loop before any hypothesis |
| `domain-modeling` | Maintain the project's Terminology section (domain glossary) in AGENTS.md |
| `freecad-mcp` | Create and edit FreeCAD models through MCP, recover from execution failures, and export finished parts for printing |
| `github-project-setup` | Harden a GitHub repo to one target state: squash-only merges, protected default branch (ruleset), Dependabot, PR-title lint (user-triggered) |
| `grill-me` | Relentless interview to stress-test a plan until shared understanding |
| `handoff` | Compact the current conversation into a handoff doc for the next session |
| `hex` | Multi-round bounded, resumable agent loop runner using the `hex` CLI (linked from local `../hex`) |
| `html-artifact` | One self-contained HTML page for a human: report, plan, diagram, deck, mockup, or prototype. Glance gate on every visual, quiz when the page teaches |
| `improve-agents-md` | Create, audit, and maintain a project's AGENTS.md, and decide which areas require nested files (user-triggered) |
| `improve-codebase-architecture` | Scan for module-deepening opportunities, before/after candidate report built with `html-artifact`, grill through picks |
| `ponytail` | Lazy senior dev mode (upstream v5): smallest complete change, reuse before stdlib before deps; `review` (diff) and `audit` (repo) hunt over-engineering and test bloat |
| `prototype` | Throwaway prototype answering a design question: logic (single shareable HTML demo) or UI (radical variants behind a URL param) |
| `research` | Background agent researching a question against primary sources, one cited .md file |
| `resolving-merge-conflicts` | Resolve an in-progress merge/rebase from the primary sources of each conflict |
| `ste100` | Write or audit prose against ASD-STE100: 20/25-word budgets, three modals, active voice, one term per concept. Load for design docs, specs, handoffs, READMEs |
| `test-driven-dev` | Test-driven development: red-green loop, pre-agreed seams, vertical slices |
| `wayfinder` | Chart work too big for one session as a map of decision tickets (GitHub issues/Project or local `docs/plan/<slug>/`), resolved one per session (user-triggered) |

Skills follow the [Agent Skills spec](https://agentskills.io/specification) (`SKILL.md` + optional
`scripts/`, `references/`, `agents/openai.yaml` for Codex metadata), validated in CI
(`scripts/validate-skills.sh`).

## Shared project conventions

The skills and ralph presets interlock through a small set of per-project files — these are the
agreements to check when editing any skill:

| File (in the target project) | Owner / consumers |
|---|---|
| `docs/design/yyyy-MM-dd-<slug>.md` | Written by `design-doc` (skill or ralph preset); input to `implement`/`tdd` loops. **Decisions are locked** — implementers don't re-open them, changes go through the doc first. Also the home for standalone hard-to-reverse decisions (no separate ADR system). Monorepos: may live per sub-project (`<sub>/docs/design/`) |
| `AGENTS.md` | Project instructions follow the `improve-agents-md` structure and stay current as the project changes. The **Terminology** section holds the glossary. `domain-modeling` maintains that section for design and implementation skills. Global instructions come from `GLOBAL-AGENTS.md`. Nested project files add instructions only for areas that pass the skill's two gates. |
| `README.md`, `TODO.md` / `PROGRESS.md` | Orientation docs — read before exploring code, updated in place as part of any change (new service → README, progress → TODO/PROGRESS) |
| `docs/plan/<slug>/` (`map.md` + ticket files) | `wayfinder`'s local-markdown medium — used when the project doesn't run on GitHub issues/Projects. Tickets resolve via `grill-me`, `prototype`, `research` |
| `docs/<slug>.html` | Written by `html-artifact`. Never committed unless the user asks. Content owners (`design-doc`, `improve-codebase-architecture`, `prototype`) name the archetype; the build contract, the glance gate, and the quiz live in `html-artifact` |

Cross-skill agreements: skills are the single source of truth for method (orchestration tools and other
skills name-drop them, never copy); every external agent CLI call follows `agent-cli`; every HTML deliverable goes through `html-artifact` for the
build contract, so no skill keeps its own HTML rules; the Language rules in `GLOBAL-AGENTS.md`
set the 90% ASD-STE100 target, and `ste100` holds the practical subset of the standard; `grill-me` separates codebase **facts** (look up) from user
**decisions** (ask in single-topic rounds of mutually independent questions,
confirmation gate before acting); `test-driven-dev` seams are
pre-agreed with the user — headless loops substitute an approved design doc; reviews are
fail-closed with numbered concrete objections (`design-doc` review checklist, critique-loop
verdicts, ralph critics).

TODO: evaluate standalone `CONTEXT.md` files later, once the inline Terminology section
outgrows AGENTS.md — reference format:
[mattpocock/skills CONTEXT.md](https://github.com/mattpocock/skills/blob/main/CONTEXT.md).

Credits: `babysit-pr` and `critique-loop` are adapted from
[gzaripov/agent-skills](https://github.com/gzaripov/agent-skills) (MIT); `handoff`,
`improve-codebase-architecture`, `test-driven-dev` (upstream `tdd`), `code-review`,
`diagnosing-bugs`, `prototype`, `research`, `resolving-merge-conflicts`, and
`wayfinder` (full flow, tracker ecosystem swapped for per-project medium:
GitHub issues/Project or local markdown) from
[mattpocock/skills](https://github.com/mattpocock/skills) (MIT); `ponytail` from
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v5.3.1 (MIT) — the core
`SKILL.md` verbatim, plus `review`/`audit` kept lean-only (over-engineering and test bloat, the
v4 tags) because `code-review` owns correctness; upstream's hooks, band, MCP server and
`gain`/`debt`/`help` skills are not ported.

`html-artifact` condenses [plannotator/effective-html](https://github.com/plannotator/effective-html)
(MIT) into `SKILL.md` + `diagram.md` + `quiz.md`, with the glance gate and SVG sizing from
[f-labs-io/agent-html-skills](https://github.com/f-labs-io/agent-html-skills) (MIT) and
[memorysaver/agentic-engineering-patterns](https://github.com/memorysaver/agentic-engineering-patterns)
(MIT), and the HTML-versus-Markdown gate from `ClawEnable/html-artifact-best-practices` (Apache-2.0).
It replaced `design-doc-render`.

`ste100` condenses [alexander-danilenko/cortex-ai-skills](https://github.com/alexander-danilenko/cortex-ai-skills)
(`simple-english`) and [DotDebian/asd-ste100-skill](https://github.com/DotDebian/asd-ste100-skill)
(both MIT) into one file. ASD-STE100 is a trade mark of ASD. The standard is free at
[asd-ste100.org](https://www.asd-ste100.org).

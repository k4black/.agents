---
name: agent-cli
description: >
  How to run another agent CLI (Codex, OpenCode, Pi, Claude Code) from a script or a
  sub-agent: the non-interactive flag, model and reasoning selection, read-only sandbox,
  prompt and output handling, and the stdin traps. Load it before any `codex exec`,
  `opencode run`, `pi -p`, or `claude -p` call. Technical reference only: it does not
  decide which CLI or when to call one.
license: MIT
allowed-tools: Bash(codex exec *) Bash(codex review *) Bash(opencode run *) Bash(pi *) Bash(claude -p *)
---

# Agent CLI reference

Rules for every CLI:

- Use the non-interactive entry point. The bare command (`codex`, `opencode`, `pi`, `claude`) opens a TUI and hangs the caller.
- Redirect stdin from `/dev/null` unless you pipe the prompt. An open stdin makes Codex and Pi wait forever.
- Pass a long prompt through a file or a heredoc, never as a shell-quoted literal with backticks or `$`.
- For a review or idea generation, run read-only. The sub-agent reports, the caller edits.
- Set a timeout at the call site. macOS has no `timeout`: use `gtimeout` from coreutils, or the Bash tool's timeout parameter. A stuck CLI gives no error.
- Models and defaults change. Check `~/.codex/config.toml`, `~/.config/opencode/opencode.json`, `~/.pi/agent/settings.json` before you hard-code a model.

## Codex (`codex` 0.162)

```bash
codex exec -s read-only -m gpt-6-astra -c model_reasoning_effort=high \
  --ephemeral --color never -o /tmp/out.md "$(cat prompt.md)" < /dev/null
```

| Need | Flag |
|---|---|
| Non-interactive | `codex exec [PROMPT]`. `-` or no prompt reads stdin |
| Model | `-m <model>`. Default from `~/.codex/config.toml` (`model`) |
| Reasoning | `-c model_reasoning_effort=<low|medium|high|xhigh>` |
| Sandbox | `-s read-only` for review. `workspace-write` to edit. `danger-full-access` never from a script |
| Approvals | `read-only` needs none. For writes, `--approve-for-me` or `-c approval_policy=never` |
| Output | `-o <file>` writes the final message. `--json` streams JSONL events to stdout. `--color never` |
| Session | `--ephemeral` saves nothing. `codex exec resume --last` continues |
| Working dir | `-C <dir>`. `--worktree` runs in a fresh managed worktree. `--skip-git-repo-check` outside git |
| Structured | `--output-schema <json-schema-file>` |
| Image | `-i <file>` |

Built-in review: `codex review --uncommitted`, `--base <branch>`, or `--commit <sha>`, with an optional custom instruction string. Non-interactive, read-only.

Trap: `codex exec` with a prompt argument and a piped stdin appends stdin as a `<stdin>` block. Use one or the other.

## OpenCode (`opencode` 2.0)

```bash
opencode run --agent plan -m openrouter/z-ai/glm-5.3#high --format json \
  "$(cat prompt.md)" < /dev/null
```

| Need | Flag |
|---|---|
| Non-interactive | `opencode run [message]` |
| Model | `-m provider/model#variant`. OpenRouter models need the `openrouter/` prefix. Variant is the reasoning level (`#high`) |
| Read-only | `--agent plan`. The built-in plan agent has no edit or write tools |
| Writes | default agent `build`. `--auto` approves every permission not denied in config |
| Output | `--format json` for machine reading, `default` for text. `--thinking` prints thinking blocks |
| Session | `-s <id>` creates or continues, `-c` continues the last, `--fork` branches |
| Attach | `-f <file>` |
| Isolation | `--standalone` runs a private server instead of the background service |

Trap: `opencode run` talks to a background service. If the first call hangs, add `--standalone`.

## Pi (`pi` 1.1)

```bash
pi -p --no-session --model openrouter/openai/gpt-astra-latest:high \
  --tools read,grep,find,ls --mode text "$(cat prompt.md)" < /dev/null
```

| Need | Flag |
|---|---|
| Non-interactive | `-p` / `--print`. Without it Pi opens the TUI |
| Model | `--model provider/id[:thinking]`. Thinking levels: `off minimal low medium high xhigh max`. Or `--thinking <level>` |
| Read-only | `--tools read,grep,find,ls`. `--no-tools` for pure text generation |
| Output | `--mode text|json|rpc` |
| Session | `--no-session` for ephemeral. `-c` continues, `--session <id>` picks one |
| System prompt | `--system-prompt <text>`, `--append-system-prompt <text-or-file>` |
| Context | `--no-context-files` skips `AGENTS.md`/`CLAUDE.md`. `--no-extensions`, `--no-skills`, `--no-mcp` trim startup |
| Files | `@path` arguments attach files to the message |
| Models | `pi --list-models [search]` |

Trap: project-local extensions and skills load by default. `-na` ignores them for an untrusted repo.

## Claude Code (`claude` 2.1)

```bash
claude -p --permission-mode plan --model claude-opus-5-5 --effort high \
  --output-format json "$(cat prompt.md)" < /dev/null
```

| Need | Flag |
|---|---|
| Non-interactive | `-p` / `--print` |
| Model | `--model <id or alias>` |
| Effort | `--effort low|medium|high|xhigh|max` |
| Read-only | `--permission-mode plan`. Or `--tools Read,Grep,Glob` to whitelist |
| Writes | `--permission-mode acceptEdits` or `dontAsk`. `bypassPermissions` never from a script |
| Output | `--output-format text|json|stream-json`. `--json-schema <schema>` for structured output |
| Scope | `--add-dir <dir>`, `--max-turns <n>`, `--bare` skips hooks and user config |
| System prompt | `--append-system-prompt <text>` |

## Prompt for a review call

Give the sub-agent the diff or file list, the question, the output format, and the no-edit rule. Example tail:

```
Output numbered findings with file:line references.
End with `VERDICT: APPROVE | CHANGES_REQUESTED | BLOCK`.
Do not edit files.
```

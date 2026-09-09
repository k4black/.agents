#!/usr/bin/env bash
# PreToolUse guard hook: block destructive commands unless explicitly confirmed.
# Used by Claude Code PreToolUse hook, Pi coding agent extension, and OpenCode plugin.
# Input: JSON on stdin with tool_input.command (or raw argv if given).
# Output: Prints block reason to stderr and exits with status 2 if blocked;
#         exits with status 0 if allowed. Also prints JSON decision on stdout.

set -euo pipefail

TMUX_GUIDANCE="wipes ALL sessions on the default tmux socket. Kill ONE session by name: \`tmux kill-session -t <name>\`. To clear an isolated test server, scope it: \`tmux -L <name> kill-server\`."

# 1. Read input command (from CLI arguments or JSON on stdin)
COMMAND=""
if [ "$#" -gt 0 ]; then
  COMMAND="$*"
else
  INPUT="$(cat || true)"
  if [ -n "$INPUT" ]; then
    if command -v jq >/dev/null 2>&1; then
      COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
    else
      # Fallback JSON extractor when jq is missing
      COMMAND="$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//' || true)"
    fi
  fi
fi

[ -z "$COMMAND" ] && exit 0

# 2. Strip single/double quoted strings to avoid false positives (e.g. echo "git push -f", commit messages)
CLEANED="$(echo "$COMMAND" | sed -E 's/"([^"\\]|\\.)*"//g; s/'\''[^'\'']*'\''//g')"

block() {
  local reason="$1"
  echo "$reason" >&2
  printf '{"decision":"block","reason":"%s","continue":false}\n' "$reason"
  exit 2
}

# 3. Check for default socket tmux kill
if echo "$CLEANED" | grep -qE '\btmux\b([^;&|-]|-L\b[[:space:]]+|-S\b[[:space:]]+)*\bkill-server\b'; then
  block "Blocked: \`tmux kill-server\` on default socket $TMUX_GUIDANCE"
fi
if echo "$CLEANED" | grep -qE '\b(pkill|killall)\b[^;&|]*\btmux\b'; then
  block "Blocked: \`pkill/killall tmux\` $TMUX_GUIDANCE"
fi

# 4. Check for destructive command patterns
if echo "$CLEANED" | grep -qE '\bgh[[:space:]]+repo[[:space:]]+delete\b'; then
  block "Blocked: GitHub repository deletion detected (\`gh repo delete\`). Destructive operations require explicit user approval."
fi

if echo "$CLEANED" | grep -qE '\brm[[:space:]]+-[a-zA-Z0-9]*r[a-zA-Z0-9]*f[a-zA-Z0-9]*[[:space:]]+(/[[:space:]]*$|/[[:space:]]+|~[[:space:]]*$|~[[:space:]]+|\$HOME\b)'; then
  block "Blocked: recursive delete from root/home detected. Destructive operations require explicit user approval."
fi

if echo "$CLEANED" | grep -qE '\bDROP[[:space:]]+(DATABASE|TABLE)\b'; then
  block "Blocked: database/table deletion detected (\`DROP DATABASE/TABLE\`). Destructive operations require explicit user approval."
fi

if echo "$CLEANED" | grep -qE '\bgit[[:space:]]+push[[:space:]]+([^;&|]*[[:space:]]+)?(-f|--force)\b'; then
  block "Blocked: git force push detected (\`git push -f/--force\`). Destructive operations require explicit user approval."
fi

if echo "$CLEANED" | grep -qE '\bgit[[:space:]]+reset[[:space:]]+([^;&|]*[[:space:]]+)?--hard\b'; then
  block "Blocked: git hard reset detected (\`git reset --hard\`). Destructive operations require explicit user approval."
fi

if echo "$CLEANED" | grep -qE '\bterraform[[:space:]]+(apply|destroy)\b'; then
  block "Blocked: Terraform apply/destroy detected. Destructive operations require explicit user approval."
fi

exit 0

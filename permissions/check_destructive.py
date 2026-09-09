#!/usr/bin/env python3
"""PreToolUse guard hook: block destructive commands unless explicitly confirmed.

Used by Claude Code PreToolUse hook, Pi coding agent extension, and OpenCode plugin.
Input: JSON on stdin with tool_input.command (or raw argv if given).
Output: Prints block reason to stderr and exits with status 2 if blocked;
        exits with status 0 if allowed. Also prints JSON decision on stdout for tools
        that parse stdout.
"""

import json
import os
import re
import sys

# High-risk destructive command patterns
DESTRUCTIVE_PATTERNS = [
    ("gh repo delete", "GitHub repository deletion"),
    ("rm -rf /", "recursive delete from root"),
    ("rm -rf ~", "recursive delete from home"),
    ("rm -rf $HOME", "recursive delete from home"),
    ("DROP DATABASE", "database deletion"),
    ("DROP TABLE", "table deletion"),
    ("git push --force", "git force push"),
    ("git push -f", "git force push"),
    ("git reset --hard", "git hard reset"),
    ("terraform apply", "Terraform apply"),
    ("terraform destroy", "Terraform destroy"),
]

TMUX_GUIDANCE = (
    "wipes ALL sessions on the default tmux socket. Kill ONE session by name: "
    "`tmux kill-session -t <name>`. To clear an isolated test server, scope it: `tmux -L <name> kill-server`."
)


def tmux_danger(cleaned: str) -> str | None:
    """Return a block reason if the command does a server-wide tmux kill on the default socket."""
    if re.search(r"\btmux\b(?:(?![;&|]|-L\b|-S\b).)*\bkill-server\b", cleaned):
        return f"`tmux kill-server` on default socket {TMUX_GUIDANCE}"
    if re.search(r"\b(?:pkill|killall)\b[^;&|]*\btmux\b", cleaned):
        return f"`pkill/killall tmux` {TMUX_GUIDANCE}"
    return None


def strip_quotes(command: str) -> str:
    """Remove quoted strings and heredocs to avoid false positives."""
    # Remove heredocs
    command = re.sub(
        r"<<-?\s*['\"]?(\w+)['\"]?.*?\n\1",
        "",
        command,
        flags=re.DOTALL,
    )
    # Remove single-quoted strings
    command = re.sub(r"'[^']*'", '""', command)
    # Remove double-quoted strings
    command = re.sub(r'"(?:[^"\\]|\\.)*"', '""', command)
    return command


def check_command(command: str) -> str | None:
    cleaned = strip_quotes(command)

    danger = tmux_danger(cleaned)
    if danger:
        return f"Blocked: {danger}"

    for pattern, description in DESTRUCTIVE_PATTERNS:
        if pattern in cleaned:
            return f"Blocked: {description} detected (`{pattern}`). Destructive operations require explicit user approval."

    return None


def main():
    command = ""
    if len(sys.argv) > 1:
        command = " ".join(sys.argv[1:])
    else:
        try:
            raw = sys.stdin.read()
            if raw.strip():
                data = json.loads(raw)
                command = data.get("tool_input", {}).get("command", "")
        except Exception:
            pass

    if not command:
        sys.exit(0)

    reason = check_command(command)
    if reason:
        sys.stderr.write(f"{reason}\n")
        # Output JSON for tools expecting JSON response
        try:
            json.dump({"decision": "block", "reason": reason, "continue": False}, sys.stdout)
        except Exception:
            pass
        # Exit code 2 tells Claude Code to block tool execution and report stderr
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()

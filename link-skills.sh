#!/usr/bin/env bash
# Link each skill root once. New skills appear without another installer run.
# On first setup, merge local entries and back up entries that cannot be merged.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"

for dst in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.codex/skills"; do
  [ "$(readlink "$dst" || true)" = "$SRC" ] && continue
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    for entry in "$dst"/* "$dst"/.[!.]*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      target="$SRC/$(basename "$entry")"
      if [ -L "$entry" ]; then
        case "$(readlink "$entry")" in "$SRC"/* | */hex/skills/*) rm "$entry" ;; esac
      elif [ -e "$target" ] || [ -L "$target" ]; then
        echo "  kept $entry: $target already exists"
      else
        mv "$entry" "$SRC/"
        echo "  moved $entry -> $SRC/"
      fi
    done
    rmdir "$dst" 2>/dev/null || {
      backup="$dst.pre-agentic-tools.$(date +%Y%m%d%H%M%S).$$.bak"
      mv "$dst" "$backup"
      echo "  backed up $dst -> $backup"
    }
  elif [ -e "$dst" ] && [ ! -L "$dst" ]; then
    backup="$dst.pre-agentic-tools.$(date +%Y%m%d%H%M%S).$$.bak"
    mv "$dst" "$backup"
    echo "  backed up $dst -> $backup"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$SRC" "$dst"
  echo "linked $dst -> $SRC"
done

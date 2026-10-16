#!/bin/bash
# Two-way sync of ~/.claude/CLAUDE.md with global/claude/CLAUDE.md in this repo.
# Run by the com.khan.global-claude-sync LaunchAgent (on change + every 30 min).
# Only this one file is ever staged, committed or pushed; other work in the
# checkout is left alone.
set -uo pipefail
export PATH="/Users/$USER/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
REL="global/claude/CLAUDE.md"
LOCAL="$HOME/.claude/CLAUDE.md"
STATE="$HOME/.claude/.global-claude-sync"   # blob hash of the last synced version
LOCK="$HOME/.claude/.global-claude-sync.lock"

mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK"' EXIT
cd "$REPO" || exit 1

git fetch -q origin main || exit 1
remote=$(git rev-parse -q --verify "origin/main:$REL" 2>/dev/null || echo none)
last=$(cat "$STATE" 2>/dev/null || echo none)

if [ ! -f "$LOCAL" ]; then
  [ "$remote" = none ] && exit 0
  git show "origin/main:$REL" > "$LOCAL" && echo "$remote" > "$STATE"
  exit 0
fi
local_hash=$(git hash-object "$LOCAL")

if [ "$local_hash" = "$remote" ]; then
  echo "$remote" > "$STATE"
elif [ "$local_hash" != "$last" ]; then
  # Edited on this machine: publish it (wins over a parallel remote edit).
  cp "$LOCAL" "$REL"
  git add -- "$REL"
  git commit -q -m "chore(global-claude): sync CLAUDE.md from $(scutil --get ComputerName 2>/dev/null || hostname)" -- "$REL"
  if ! git push -q origin HEAD:main 2>/dev/null; then
    git pull -q --rebase --autostash origin main && git push -q origin HEAD:main || exit 1
  fi
  echo "$local_hash" > "$STATE"
elif [ "$remote" != "$last" ] && [ "$remote" != none ]; then
  # Edited on another machine, untouched here: take it.
  git show "origin/main:$REL" > "$LOCAL"
  git pull -q --rebase --autostash origin main || true
  echo "$remote" > "$STATE"
fi

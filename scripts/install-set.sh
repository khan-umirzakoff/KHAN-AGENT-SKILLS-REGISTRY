#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <set-name> <project-root>"
  echo "Example: $0 umami-analytics /home/khan/PROJECTS/umami-rewrite/umami"
  exit 1
fi
SET_NAME="$1"
PROJECT_ROOT="$2"
BANK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SET_FILE="$BANK_DIR/sets/$SET_NAME.txt"
DEST="$PROJECT_ROOT/.agents/skills"

if [ ! -f "$SET_FILE" ]; then
  echo "Set not found: $SET_FILE"
  exit 1
fi
mkdir -p "$DEST"
while IFS= read -r skill || [ -n "$skill" ]; do
  [ -z "$skill" ] && continue
  src="$(find "$BANK_DIR/curated" -mindepth 2 -maxdepth 2 -type d -name "$skill" | head -n 1)"
  if [ -z "$src" ]; then
    echo "Missing curated skill: $skill" >&2
    exit 1
  fi
  rm -rf "$DEST/$skill"
  cp -a "$src" "$DEST/$skill"
done < "$SET_FILE"
echo "Installed $(wc -l < "$SET_FILE") skills into $DEST"

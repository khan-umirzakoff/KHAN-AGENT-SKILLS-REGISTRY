#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <project-root>" >&2
  echo "Example: $0 /home/khan/PROJECTS/Yulduzcha_Bot" >&2
  exit 1
fi

BANK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$1" && pwd)"
CURATED_DESIGN="$BANK_DIR/curated/design"
SET_FILE="$BANK_DIR/sets/yulduzcha-landing.txt"

for command_name in find sort mktemp; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
done

"$BANK_DIR/scripts/update-registry-sources.sh"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
GENERATED_SET="$TEMP_DIR/yulduzcha-landing.txt"

{
  printf '%s\n' \
    frontend-design \
    ui-ux-pro-max \
    frontend-ui-engineering \
    vercel-react-best-practices \
    web-design-guidelines
  find "$CURATED_DESIGN" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
} > "$GENERATED_SET"

if [ ! -f "$SET_FILE" ] || ! cmp -s "$GENERATED_SET" "$SET_FILE"; then
  cp "$GENERATED_SET" "$SET_FILE"
fi

"$BANK_DIR/scripts/install-set.sh" yulduzcha-landing "$PROJECT_ROOT"

printf 'Installed all current Designer Skills and UI UX Pro Max.\n'
printf 'Installed set: %s\n' "$SET_FILE"
printf 'Project skills: %s/.agents/skills\n' "$PROJECT_ROOT"

#!/usr/bin/env bash
set -euo pipefail

BANK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_MAP="$BANK_DIR/curated/source-map.tsv"
DESIGNER_SOURCE="$BANK_DIR/sources/designer-skills"
CURATED_DESIGN="$BANK_DIR/curated/design"

for command_name in git rsync find sort mktemp; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
done

if [ ! -f "$SOURCE_MAP" ]; then
  echo "Curated source map not found: $SOURCE_MAP" >&2
  exit 1
fi

while read -r submodule_path; do
  [ -n "$submodule_path" ] || continue
  if [ -d "$BANK_DIR/$submodule_path" ]; then
    dirty="$(git -C "$BANK_DIR/$submodule_path" status --porcelain)"
    if [ -n "$dirty" ]; then
      echo "Refusing to update dirty source: $submodule_path" >&2
      printf '%s\n' "$dirty" >&2
      exit 1
    fi
  fi
done < <(git -C "$BANK_DIR" config --file .gitmodules --get-regexp path | awk '{print $2}')

git -C "$BANK_DIR" submodule sync --recursive
git -C "$BANK_DIR" submodule update --init --remote --checkout

while IFS=$'\t' read -r curated_target source_dir; do
  [ -n "$curated_target" ] || continue
  [[ "$curated_target" == \#* ]] && continue
  if [ "$source_dir" = "LOCAL" ]; then
    if [ ! -f "$BANK_DIR/curated/$curated_target/SKILL.md" ]; then
      echo "Local curated skill is missing: $curated_target" >&2
      exit 1
    fi
    continue
  fi
  if [ ! -f "$BANK_DIR/$source_dir/SKILL.md" ]; then
    echo "Mapped upstream skill is missing: $source_dir" >&2
    exit 1
  fi
done < "$SOURCE_MAP"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
FLAT_DESIGN="$TEMP_DIR/designer-skills"
mkdir -p "$FLAT_DESIGN"

designer_count=0
while IFS= read -r -d '' skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  if [ -e "$FLAT_DESIGN/$skill_name" ]; then
    echo "Duplicate Designer Skill name: $skill_name" >&2
    exit 1
  fi
  cp -a "$skill_dir" "$FLAT_DESIGN/$skill_name"
  designer_count=$((designer_count + 1))
done < <(find "$DESIGNER_SOURCE" -type f -name SKILL.md -print0 | sort -z)

if [ "$designer_count" -eq 0 ]; then
  echo "No Designer Skills found in: $DESIGNER_SOURCE" >&2
  exit 1
fi

mkdir -p "$CURATED_DESIGN"
rsync -a --delete "$FLAT_DESIGN/" "$CURATED_DESIGN/"

synced_count=0
local_count=0
while IFS=$'\t' read -r curated_target source_dir; do
  [ -n "$curated_target" ] || continue
  [[ "$curated_target" == \#* ]] && continue
  if [ "$source_dir" = "LOCAL" ]; then
    local_count=$((local_count + 1))
    continue
  fi
  mkdir -p "$BANK_DIR/curated/$curated_target"
  rsync -a --delete "$BANK_DIR/$source_dir/" "$BANK_DIR/curated/$curated_target/"
  synced_count=$((synced_count + 1))
done < "$SOURCE_MAP"

printf 'Updated %s Git source repositories.\n' \
  "$(git -C "$BANK_DIR" config --file .gitmodules --get-regexp path | wc -l)"
printf 'Synchronized %s mapped curated skills and %s Designer Skills.\n' \
  "$synced_count" "$designer_count"
printf 'Preserved %s local curated skill(s).\n' "$local_count"

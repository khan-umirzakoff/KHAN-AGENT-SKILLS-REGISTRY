#!/bin/bash
# One-time setup on a machine: keeps ~/.claude/CLAUDE.md in sync with this repo.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.khan.global-claude-sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
chmod +x "$DIR/sync.sh"
mkdir -p "$HOME/.claude" "$HOME/Library/LaunchAgents"
# A machine without the file starts from the repo version.
[ -f "$HOME/.claude/CLAUDE.md" ] || cp "$DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$DIR/sync.sh</string></array>
  <key>WatchPaths</key><array><string>$HOME/.claude/CLAUDE.md</string></array>
  <key>StartInterval</key><integer>1800</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$HOME/.claude/.global-claude-sync.log</string>
  <key>StandardErrorPath</key><string>$HOME/.claude/.global-claude-sync.log</string>
</dict></plist>
PL
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Installed $LABEL"

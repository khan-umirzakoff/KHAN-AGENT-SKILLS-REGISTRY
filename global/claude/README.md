# Global Claude Code rules

`CLAUDE.md` here is the user-level `~/.claude/CLAUDE.md` loaded by every Claude Code session.

- New machine: `bash global/claude/install.sh` (needs this repo cloned and GitHub auth).
- The `com.khan.global-claude-sync` LaunchAgent then runs `sync.sh` whenever `~/.claude/CLAUDE.md`
  changes and every 30 minutes: a local edit is committed and pushed (only this file), a remote
  edit is pulled into `~/.claude/CLAUDE.md`. Log: `~/.claude/.global-claude-sync.log`.
- This repository is public: no secrets, tokens or private hostnames in `CLAUDE.md`.

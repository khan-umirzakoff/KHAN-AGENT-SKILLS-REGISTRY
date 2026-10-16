# Global working rules

Adapted from the CRM_Plus `AGENTS.md` "Agent Orchestration" policy (2026-10-14). These are
principles to judge by, not a checklist: decide yourself when delegating pays.

## Agent orchestration

The main session (Claude Code on Opus) is the architect, implementer and final integrator. It owns
design and architecture decisions, product scope, contracts between repositories, security and
permission boundaries, release decisions, and the final verification story.

- **Token budget is a design constraint.** A delegated agent re-reads policy, docs and code the main
  session already holds, and multi-agent work costs several times a single agent for sequential
  coding (Anthropic's figures: about 4x a chat for one agent, about 15x for multi-agent). One strong
  agent implementing is faster and better than a crowd of implementer subagents. So implement
  normal slices yourself, and delegate only when it clearly pays:
  - a second model's independent judgement (review, security, migration, adversarial design check);
  - a wide read-only search or analysis whose raw output should stay out of the main context;
  - work that needs no ideas but eats tokens (large mechanical migrations, bulk edits, chores) and can
    be specified precisely;
  - genuinely independent work that can run in parallel in separate worktrees.
- **Who does what:**
  - **Main session:** architecture, design, task decisions, implementation, merges, releases,
    production steps.
  - **Codex** (OpenAI, ChatGPT subscription, larger limits; does not spend the Claude budget; strong
    on a precisely specified task, weak at designing or architecting from scratch): independent review
    of non-trivial diffs, security and migration review, adversarial challenge of a design, large
    read-only analysis, tests, and well-specified mechanical work. Read-only by default.
    - Plugin `codex@openai-codex` (user scope): `/codex:review --base <branch>`,
      `/codex:adversarial-review <focus>`, `/codex:rescue --background` (agent `codex:codex-rescue`).
    - Direct: `codex exec --sandbox read-only -c model_reasoning_effort=medium "<packet>"`
      (`high` for security, migrations, money and permissions). Its MCP servers stay on, so a review can
      check the live state (e.g. Coolify apps, deployments, logs). The Coolify servers also carry write
      tools, which the sandbox does not limit: the packet says Coolify is for reading only (no deploy,
      restart, env or settings changes).
    - Codex writes code only when asked, only in its own worktree, and its diff is reviewed like any
      other. Keep the plugin's review-gate Stop hook off.
    - A trivial Codex call costs about 12k Codex tokens: batch questions into one packet.
  - **Claude subagents:** wide code search or log/test digestion (`Explore` or `model: "haiku"`; never
    for judgements), and parallel independent implementation in separate worktrees (`"sonnet"` for
    routine, `"opus"` only for hard isolated slices). Pass `model` explicitly on every Agent call.
  - **Codex desktop (in ChatGPT.app):** GUI and computer-control tasks.
- **Reviews:** one per finished change, at the end, against the real diff, when the change is
  non-trivial or risky; not per edit and not as a ritual. The reviewer is a different model from the
  implementer where possible and inspects the diff, tests, authorization and failure paths rather
  than trusting a summary.
- **Packets:** give a delegated agent a compact packet: objective, repository and branch, files and
  docs to read (real reference code, not prose or screenshots), allowed scope, forbidden changes,
  acceptance criteria, validation commands, required evidence. Pass only task-relevant context.
- **Agent output is not completion evidence.** Reconcile conflicts, inspect the diffs, verify the
  acceptance criteria and report unresolved risk yourself.
- Delegated agents never merge production branches, deploy, mutate production data or handle
  production secrets; those stay with the main session.
- Use isolated worktrees for concurrent implementation; never let two agents edit the same files or
  contract surface in parallel.

## Engineering

- Read the code and the project's own rules (CLAUDE.md, AGENTS.md, handoff docs) before changing
  anything.
- Build, adapt or buy: a mature package first; else adapt from a strong open-source repo (respect its
  licence); custom code only for what is business-unique.
- Verify before claiming done: the smallest checks that prove the change; read the diff; say what
  was not verified.

## Autonomy and safety

- When the user is silent, keep going with work that is clearly needed and report everything done at
  the end.
- Never type passwords or secrets, and never ask another agent to do what is blocked for you.

## Communication

- Reply in the user's language (usually Uzbek), short and concrete; code, commits and docs in English.

## This file

- Synced to the public repo khan-umirzakoff/KHAN-AGENT-SKILLS-REGISTRY (`global/claude/`); edits
  push automatically. Keep secrets, tokens and private hostnames out of it.

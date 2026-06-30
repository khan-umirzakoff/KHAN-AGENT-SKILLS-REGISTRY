# SKILLS Bank

Central local skill bank for future projects.

## Structure

- `sources/` — clean, unmodified upstream repos.
- `curated/` — selected useful skills copied from sources, still unmodified.
- `sets/` — per-project skill lists.
- `scripts/install-set.sh` — copy a set into a project at `.agents/skills`.

## Current sources

- `sources/openai-skills` — OpenAI Codex skills catalog.
- `sources/anthropic-skills` — Anthropic public Agent Skills.
- `sources/addy-agent-skills` — Addy Osmani production engineering skills.

## Install into a project

```bash
/home/khan/PROJECTS/agent-skills-registry/scripts/install-set.sh umami-analytics /home/khan/PROJECTS/umami-rewrite/umami
```

## Rule

Do not put every skill into every project. Keep the central bank large, but install only a small project-specific subset into `.agents/skills`.

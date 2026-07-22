# SKILLS Bank

Central local skill bank for future projects.

Canonical path:

- `/home/khan/PROJECTS/AGENT-SKILLS-REGISTRY`
- `/home/khan/PROJECTS/agent-skills-registry` is a compatibility symlink.

## Structure

- `sources/` - clean upstream mirrors.
- `curated/` - selected useful skills copied from sources.
- `sets/` - per-project install lists.
- `scripts/install-set.sh` - copies a set into a project at `.agents/skills`.

## Current Sources

- `sources/addy-agent-skills` - Addy Osmani production engineering skills.
- `sources/anthropic-skills` - Anthropic public Agent Skills.
- `sources/vercel-agent-skills` - Vercel React, composition, and web UI guidance.
- `sources/designer-skills` - Owl Listener design collection with 9 focused plugins and 96 design skills.
- `sources/shadcn-ui` - official shadcn/ui skill, sparse checkout of `skills/shadcn`.
- `sources/openai-plugins` - current OpenAI Codex plugin examples, including `plugins/build-web-apps`.
- `sources/openai-skills` - legacy OpenAI skills catalog. This upstream repo marks itself deprecated; keep it only as a reference for old curated skills and prefer `sources/openai-plugins` for current Codex plugin examples.

## Frontend Trusted Link Pack Status

Installed or mirrored:

- Addy `frontend-ui-engineering`.
- shadcn/ui official `shadcn`.
- Vercel `react-best-practices`.
- Vercel `web-design-guidelines`.
- Vercel `composition-patterns`.
- Anthropic `frontend-design`.
- Anthropic `webapp-testing`.
- OpenAI Build Web Apps plugin source under `sources/openai-plugins/plugins/build-web-apps`.

Project-local Codex skills should live in:

```bash
<project-root>/.agents/skills/<skill-name>/SKILL.md
```

For Morefin this is:

```bash
/home/khan/PROJECTS/morefin-moliya/.agents/skills
```

## Install Into A Project

Install a predefined set:

```bash
/home/khan/PROJECTS/agent-skills-registry/scripts/install-set.sh morefin-frontend /home/khan/PROJECTS/morefin-moliya
```

Or copy a curated skill manually:

```bash
cp -a /home/khan/PROJECTS/agent-skills-registry/curated/frontend/shadcn \
  /home/khan/PROJECTS/morefin-moliya/.agents/skills/shadcn
```

## Rules

- Do not put every skill into every project.
- Prefer official/current sources first: shadcn, Vercel, Anthropic, Addy, OpenAI plugins.
- Avoid duplicate skill names in one project. For example, shadcn/ui official and OpenAI Build Web Apps both contain a `name: shadcn` skill; keep the official shadcn skill in project-local installs.
- Treat `openai/skills` as legacy/deprecated source material, not the current Codex plugin source.

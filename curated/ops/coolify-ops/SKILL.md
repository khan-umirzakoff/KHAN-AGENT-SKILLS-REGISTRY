---
name: coolify-ops
description: Use when operating Coolify-hosted applications, databases, environment variables, deployments, logs, scheduled tasks, native Coolify MCP, or REST API fallback. Especially useful for diagnosing CORS/env/deploy issues, safely changing runtime/build variables, and avoiding production database mistakes.
---

# Coolify Ops

Use this skill for Coolify-hosted systems when you need to inspect apps, change env vars, deploy/restart, read logs, run one-off scheduled tasks, or debug frontend/backend deployment issues.

## Safety Rules

- Identify the exact server, project, app UUID, branch, database, and environment before changing anything.
- Treat production data as read-only unless the user explicitly approves a production write.
- Do not print raw API tokens, passwords, database URLs, bot tokens, or secret env values. Redact them in summaries.
- Prefer reversible changes: env updates, redeploys, restarts, and temporary scheduled tasks that are deleted after use.
- After every env change, verify whether it is runtime-only, build-time-only, or both. Vite/Next static frontend env changes usually require a rebuild/deploy.
- Never leave temporary scheduled tasks enabled after a one-off command.

## Configured MCP Targets

- Use `coolify_uz_write` for the Uzbek Coolify instance.
- Use `coolify_de_write` for the Germany Coolify instance.
- Before any write action, confirm the target MCP, server, project, app or database UUID, branch, and environment.
- Do not assume similarly named resources in the two Coolify instances are interchangeable.

## Recommended Workflow

1. List or inspect the app and confirm UUID, name, fqdn, repo, branch, status, and database target.
2. Read current env keys and only reveal non-secret values needed for diagnosis, such as hostnames and CORS origins.
3. For CORS/API URL bugs, compare:
   - frontend origin in the browser,
   - frontend build API base URL,
   - backend public URL and scheme,
   - backend `CORS_ALLOWED_ORIGINS`,
   - backend `CSRF_TRUSTED_ORIGINS`,
   - backend allowed hosts.
4. Apply the smallest env change that fixes the mismatch.
5. Redeploy/restart the correct resources:
   - backend env read at runtime: restart may be enough;
   - frontend build-time env: force deploy/rebuild is required.
6. Verify with real HTTP checks:
   - CORS preflight: `OPTIONS` with `Origin` and `Access-Control-Request-Method`;
   - authenticated endpoint: `401` with `access-control-allow-origin` is a good CORS result;
   - app status and deployment status in Coolify;
   - browser hard refresh or incognito after frontend rebuild.

## Native MCP vs REST API

- Native Coolify MCP may be read-only depending on the token/server. Use it first for listing and inspection when available.
- If MCP cannot write but the user approved API access, use Coolify REST API for env/deploy/restart operations.
- Coolify self-hosted API commonly exposes:
  - `GET /api/v1/applications`
  - `GET /api/v1/applications/{uuid}`
  - `GET /api/v1/applications/{uuid}/envs`
  - `POST /api/v1/applications/{uuid}/envs`
  - `PATCH /api/v1/applications/{uuid}/envs`
  - `PATCH /api/v1/applications/{uuid}/envs/bulk`
  - `DELETE /api/v1/applications/{uuid}/envs/{env_uuid}`
  - `GET /api/v1/applications/{uuid}/logs`
  - `GET|POST /api/v1/applications/{uuid}/restart`
  - `GET /api/v1/deploy?uuid={uuid}&force=true`
  - `GET /api/v1/applications/{uuid}/scheduled-tasks`
  - `POST /api/v1/applications/{uuid}/scheduled-tasks`
  - `GET /api/v1/applications/{uuid}/scheduled-tasks/{task_uuid}/executions`
  - `DELETE /api/v1/applications/{uuid}/scheduled-tasks/{task_uuid}`
- Some self-hosted Coolify instances behind Cloudflare may reject API calls because the allowlist sees the proxy IP. If the user confirms the origin IP and DNS, a direct-origin HTTPS request with host resolution can be used while preserving the Host header and TLS.

## Env Update Notes

- `PATCH /applications/{uuid}/envs` updates by `key` and `value` on many Coolify versions; verify afterward that only one env row exists for the key.
- `POST /applications/{uuid}/envs` may also create or upsert depending on version. Always re-list envs after writing.
- For frontend apps built by Vite, check the deployed JS asset to confirm the new API URL is embedded.
- For Django/DRF CORS fixes, a healthy unauthenticated API response may still be `401`; the important check is that `access-control-allow-origin` matches the frontend origin.

## One-Off Commands

When you need to run a command inside an app container and no terminal tool is available:

1. Create a short scheduled task with the command and a temporary name.
2. Wait for execution and inspect `.../executions`.
3. Delete the scheduled task immediately.
4. Verify app logs and status.

Keep scheduled task commands under Coolify field limits. If the command is long, prefer a checked-in script or an existing package script.

## Final Report

Report only:

- what was changed,
- which resource was restarted/deployed,
- what verification passed,
- what remains unverified,
- whether production data was untouched.

---
name: verify-and-ship
description: Run the production readiness gate (preflight, typecheck, lint, test, build, migrate, RLS verify, deploy, smoke) for a task before marking it done or deploying. Use when a task reaches verification, when asked to ship/deploy/release a project, or to confirm a change is production-ready. Refuses to mark done on any failure.
allowed-tools: Read, Glob, Grep, Bash, Edit
---

# Verify and Ship

The executable Definition-of-Done gate. Reads command variables from
`ai-context/orchestration/definition_of_done.md` (per-project scaffolding). Obeys the permission
policy in `ai-context/global/enforcement_design.md` (the deploy/migrate steps are gated by
`.claude/allow-list.json` via the PreToolUse hook).

## Step order (do not reorder)

0. **PREFLIGHT** — assert required env/credentials present and (Supabase) project linked. Missing → `needs input`, stop.
1. **typecheck**  2. **lint**  3. **test**  4. **build**
5. **MIGRATE** (DB schema/RLS) — gated; runs **before** app deploy; **never auto-retried** (partial-apply risk). Destructive/expand-contract migration → set `BREAKING_MIGRATION: true` and stop for a human checkpoint.
6. **RLS_VERIFY** — assert policies active and anon is denied, **before** app deploy.
7. **deploy** — gated by an allow-list entry matching `op_class` + `TARGET_ENV`.
8. **smoke** — post-deploy, against the deployed URL.

A `DEFINED` step must pass. `TODO` off the floor → record `SKIPPED (TODO)` + a `tech-debt:` line.
`TODO` on the `REQUIRED_FLOOR` → fail the gate (`needs input`). If `SMOKE_CMD = TODO`, **DEPLOY
may not run** — deploy and smoke are coupled.

## Retry policy

- Default: **NO retry** (treat as deterministic).
- Retry (max 2; ~5s then ~15s) ONLY if the failure matches a transient pattern: timeout/exit124,
  `ETIMEDOUT`, `ECONNRESET`, `ECONNREFUSED`, `EAI_AGAIN`, `socket hang up`, `502`/`503`/`429`,
  `fetch failed`, `npm ERR! network`, `getaddrinfo`.
- Compile / type / lint / test-assertion failures fail fast. **MIGRATE is never retried.**
- Unknown failure ⇒ deterministic ⇒ no retry.

## Prod deploy gate

Autonomous prod deploy is allowed ONLY if: the identical commit passed smoke on staging in this
run; steps 1–4 passed with zero skips; smoke asserts real endpoints (below); and a verified
one-command rollback exists. On smoke failure: roll back to last known-good, mark task **FAILED**,
leave it in `active/`, never mark done.

## Smoke must assert (not just HTTP 200)

- Liveness: `GET /` (or `/api/health`) → 200 + real body (not an error page).
- Supabase apps also: auth round-trip (non-null JWT); RLS positive (owner reads own row); **RLS
  negative** (anon client SELECT on a protected table → 0 rows / denied — a non-empty anon read
  **fails smoke hard**). Use synthetic fixtures, never resident/PII data.

## Logging

Append each step's command + exit code + last N lines of stdout/stderr + duration to the task doc
or a linked artifact. **Redact** tokens, keys, and connection strings.

## Model tiering

This gate is mostly Tier 1–2 (run defined commands, report). On Claude Code, mechanical sub-steps
may run on Haiku 4.5; keep failure diagnosis / RLS reasoning on the main (Tier 3) model.

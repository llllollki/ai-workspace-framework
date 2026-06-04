# Skill: Verify and Ship — v1

> Codex-readable mirror of `.claude/skills/verify-and-ship/SKILL.md` (which Claude Code
> auto-invokes). Keep the two in sync. Codex: read and follow this file.

## Purpose

The executable Definition-of-Done gate: run preflight → typecheck → lint → test → build → migrate
→ RLS verify → deploy → smoke before marking a task done or deploying. Refuses to mark done on any
failure.

## When to Use

When a task reaches verification, when asked to ship/deploy/release, or to confirm a change is
production-ready.

## Inputs Required

- Per-project command variables and `REQUIRED_FLOOR` (`orchestration\definition_of_done.md`).
- Permission policy and allow-list semantics (`global\enforcement_design.md`).

## Steps (do not reorder)

0. **PREFLIGHT** — assert required env/credentials present and (Supabase) project linked; missing → `needs input`, stop.
1. typecheck  2. lint  3. test  4. build
5. **MIGRATE** — gated; before app deploy; **never auto-retried**. Destructive/expand-contract → `BREAKING_MIGRATION: true` + human checkpoint.
6. **RLS_VERIFY** — policies active and anon denied, before app deploy.
7. **deploy** — gated by allow-list entry matching `op_class` + `TARGET_ENV`.
8. **smoke** — post-deploy, against the deployed URL.

`DEFINED` must pass. `TODO` off the floor → `SKIPPED (TODO)` + `tech-debt:` line. `TODO` on
`REQUIRED_FLOOR` → fail (`needs input`). `SMOKE_CMD = TODO` ⇒ DEPLOY may not run.

## Retry policy

Default NO retry. Retry (max 2; ~5s/15s) only on transient patterns (timeout/exit124, ETIMEDOUT,
ECONNRESET, ECONNREFUSED, EAI_AGAIN, socket hang up, 502/503/429, fetch failed, npm ERR! network,
getaddrinfo). Compile/type/lint/test-assertion fail fast. MIGRATE never retried. Unknown ⇒ no retry.

## Prod deploy gate

Allowed only if: identical commit passed staging smoke this run; steps 1–4 passed with zero skips;
smoke asserts real endpoints; verified one-command rollback exists. On smoke failure: roll back,
mark task FAILED in `active/`, never mark done.

## Smoke assertions

Liveness 200 + real body; Supabase: auth round-trip (non-null JWT), RLS positive (owner reads own
row), RLS negative (anon SELECT on protected table → 0 rows/denied; non-empty anon read fails
hard). Synthetic fixtures only.

## Logging

Append command + exit code + last N lines stdout/stderr + duration to the task doc or a linked
artifact; redact secrets.

## Codex note

Codex has no `.claude/settings.json` or PreToolUse hook. Honor the allow-list policy in
`global\enforcement_design.md` as written policy: do not run a gated op (deploy/migrate/force-push/
secret change) without a matching, active, scoped allow-list entry, and never perform a
never-autonomous op.

<!-- v1. See orchestration\versioning_rules.md for when to create a v2. -->

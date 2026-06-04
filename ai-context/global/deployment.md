# Deployment Runbook

## Responsibility

How each project is built, migrated, deployed, verified, and rolled back. The executable gate is
the `verify-and-ship` skill (`skills\core\verify_and_ship_v1.md`); this file is the human/runtime
reference for the commands and ordering behind it. Deploy and migration steps are gated by the
permission policy in `global\enforcement_design.md` (`.claude\allow-list.json`).

## Environments

| Env | Purpose | Gating |
|---|---|---|
| `preview` | per-branch/PR preview | low-risk; allow-list entry may be `standing` |
| `staging` | pre-prod integration + smoke | required to pass before any prod deploy |
| `production` | live users | allow-list entry must be `once`-scoped with a non-past `expires`; never `standing` |

## Canonical deploy sequence (all projects)

Mirrors the skill. Do not reorder; migrations run **before** app deploy.

1. **PREFLIGHT** — required env/credentials present; cloud project linked. Missing → `needs input`, stop.
2. **build** (includes typecheck where the build runs it).
3. **MIGRATE** — DB schema/RLS. Gated. **Forward-only, idempotent, never auto-retried** (a
   partially-applied migration must be reconciled by a human). Destructive/expand-contract change
   → `BREAKING_MIGRATION: true` + human checkpoint between deploy and the contract step.
4. **RLS_VERIFY** — assert policies active and anon is denied, before app deploy.
5. **deploy** — gated by an allow-list entry matching `op_class` + `TARGET_ENV`.
6. **smoke** — post-deploy, against the deployed URL (liveness + auth + RLS-negative).

## Rollback

- **App and DB rollback are separate.** Rolling back the app does NOT revert the database.
- **App:** redeploy/promote the previous known-good release (e.g. Vercel "Instant Rollback" to the
  prior production deployment). Record the exact command/console step per project below.
- **DB:** prefer a forward-fix migration over a down-migration. A destructive migration that has
  already shipped with a deployed app has **no automatic rollback** — human checkpoint required.
  Capture the current migration version (and a PITR/backup checkpoint for destructive changes)
  **before** step 3 so rollback has a target.
- `verify-and-ship` must be safe to re-run after a partial failure (already-applied migrations are
  skipped; deploy creates a new immutable release; smoke is read-only on synthetic fixtures).

---

## alh-tracker

- **Stack:** React 18 + TypeScript + Vite + Tailwind + Zustand. **DB/Auth:** Supabase (Postgres +
  RLS). **Host:** Vercel (SPA rewrite in `vercel.json`).
- **PREFLIGHT:** `npm run verify:secrets` (asserts `SUPABASE_*` env); Supabase project must be
  linked. If not linked → `needs input` (no committed `supabase/config.toml` marker).
- **BUILD:** `npm run build` (`tsc && vite build`).
- **MIGRATE:** `supabase db push` — applies only unapplied versions from `supabase/migrations/`
  (19 files incl. RLS policies + RPCs). Never hand-run SQL; never auto-retry.
- **RLS_VERIFY:** _TODO_ — add a script: anon client `SELECT` on a protected table must return
  0 rows / permission denied.
- **DEPLOY:** _TODO_ — confirm exact Vercel CLI/flags (`vercel deploy` preview vs `vercel deploy --prod`).
- **SMOKE:** _TODO_ — `GET /` → 200 + real body; auth round-trip (non-null JWT); RLS-negative
  (anon read denied). Synthetic fixtures only — never resident/PII data.
- **ROLLBACK:** Vercel Instant Rollback to previous production deployment (document exact step);
  DB via forward-fix migration.

## AssistedLivingHelp

> **Path unconfirmed on this machine** (`c:\Projects\AssistedLivingHelp` is empty; a `c:\Projects\alh\`
> dir may be it). Do not invent commands — confirm `PROJECT_PATH` and toolchain first; until then
> the gate returns `needs input`.

- **Stack (expected):** Next.js-ish web + API, reads `facilities_ca.sqlite` (read-only data load).
- **MIGRATE:** N/A (SQLite is a read-only dataset, not migrated) — confirm.
- **BUILD / DEPLOY / SMOKE:** _TODO_ — `GET /api/health` → 200 + one route proving the SQLite
  dataset loaded (record count > 0).

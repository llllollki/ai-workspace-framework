# 0027 — Facility Owner Role Naming: Resolve Discrepancy (ADR 0011)

Status: done
Created: 2026-05-19
Owner role: AI agent (main)
Reviewers: n/a (architecture/design task — no application code changed)

## Goal

Resolve the role naming discrepancy between the Supabase `app_role` DB enum
(`facility_admin`) and the role model documented in all ADRs and project docs
(`owner`/`admin`). Produce ADR 0011 as a proposed architecture decision. No
application code or migrations are implemented in this task.

## Acceptance Criteria

- [x] Role naming discrepancy clearly resolved in an architecture decision document.
- [x] ADR 0011 created with status `proposed`.
- [x] CRM-provisioned owner role value specified (`owner`).
- [x] Legacy `facility_admin` handling specified (migrate rows to `owner`; enum cleanup deferred).
- [x] Required implementation impacts listed (schema migration, 2 RLS policy updates, AuthProvider, types/index.ts, seed.ts).
- [x] `ai_memory.md` updated to narrow blocker #5 from audit 0026.
- [x] `decisions/README.md` updated with ADR 0011 row.
- [x] `data_model.md` updated with legacy note and auditor documentation.
- [x] `execution_log.md` updated.
- [x] Changes mirrored to ai-workspace-framework.
- [x] No application code changed.

## Plan

- [x] Read AGENTS.md and workspace context files
- [x] Read audit 0026, ADRs 0006–0010, data_model.md, compliance_notes.md, features.md
- [x] Read Supabase migrations for actual schema (app_role enum, RLS policies)
- [x] Read src/types/index.ts and AuthProvider.tsx for application-layer role handling
- [x] Assess subagent policy (serial: design-sensitive single-decision task, no independent workstreams)
- [x] Draft and create ADR 0011
- [x] Create this task doc
- [x] Update decisions/README.md
- [x] Update data_model.md (legacy note + auditor doc)
- [x] Update ai_memory.md (narrow blocker #5)
- [x] Update execution_log.md
- [x] Mirror to ai-workspace-framework
- [x] Commit

## Subagent Policy Note

Serial: this is a design-sensitive ADR task where one decision thread spans schema state,
application code, RLS policies, and all documentation layers. No independent workstreams
exist; coordination overhead would exceed the work itself. All context was loaded in the
main agent.

## Key Findings

**Full layer picture discovered:**

| Layer | Role values |
|---|---|
| DB `app_role` enum | `facility_admin`, `caregiver`, `med_tech`, `family_member`, `auditor` |
| AuthProvider.tsx local `AppRole` | `facility_admin`, `caregiver`, `med_tech`, `family_member` |
| `mapToStoreRole()` function | `facility_admin` → `admin` (BUG: should be `owner`) |
| `src/types/index.ts Role` type | `owner`, `admin`, `caregiver`, `med_tech` |
| All ADRs and docs | `owner`, `admin`, `caregiver`, `med_tech` |

**Critical bug:** `mapToStoreRole()` maps `facility_admin` → `admin`. The `owner` value
in `src/types/index.ts` is unreachable from any Supabase DB session. All Supabase
facility owners currently present as `admin` in the application layer.

**Naming collision:** `src/types/index.ts` exports `AppRole = Role | 'family_member'` AND
`AuthProvider.tsx` also exports `AppRole` (the DB-facing type). Two exported types with
the same name and different values.

**DB enum legacy:** `facility_admin` in the DB was a placeholder that was never reconciled
with the `owner`/`admin` distinction used everywhere else.

## Decision Summary

ADR 0011 selects Option A: rename `facility_admin` → `owner` in the DB enum; add `admin`
as a new enum value. Existing `facility_admin` rows in `users` are migrated to `owner`.
All existing docs and ADRs use `owner`/`admin` already — DB becomes consistent with them.
No permanent mapping layer is needed. `mapToStoreRole()` becomes a passthrough or is removed.

## Outcome

ADR 0011 created at status `proposed`. Blocker #5 from audit 0026 is narrowed: the decision
has been made; implementation (schema migration + RLS update + code fix) is in task 0027
(schema + RLS migrations in backlog). No application code changed.

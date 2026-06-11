# 0027 — CRM Owner Provisioning: Schema and RLS Migrations

Status: active
Created: 2026-05-19
Activated: 2026-05-23
Owner role: AI agent (main)
Depends on: resolve blocker #5 (role naming), blocker #6 (users.created_by), blocker #10 (token_expired_passive enum value)
Blocks: 0028, 0029, 0030, 0031, 0032
Audit source: 0026

## Goal

Apply all Supabase schema migrations required before the CRM owner provisioning endpoint
can be implemented. This task covers new enums, new columns on existing tables, two new
tables (`provisioning_tokens`, `provisioning_events`), the `is_active_user_on_active_facility()`
RLS helper function, updated policies on all care-ops tables, and safe defaults for
existing rows. No application code is changed in this task.

## Plan

**Assessment (2026-05-23):** This task was created as a backlog item on 2026-05-19 but was
implemented the same day under the label "task 0030" (Phase 1 schema/RLS migrations). Full
inspection of the migration sequence confirms all acceptance criteria are already satisfied.
This task is being activated to formally verify, document the supersession, and close it.

**Subagent policy:** Proceeding serially. Steps are sequential (verify → run checks → close).
No independent workstreams warrant subagent delegation.

### Supersession analysis

All 0027 scope was implemented in two migrations:

**`20260101000007_adr0011_role_enum_provisioning_schema.sql` (task 0030, 2026-05-19):**
- Part A: `user_account_status`, `facility_provisioning_status`, `provisioning_event_type`
  enums created. `token_expired_passive` was deferred in this migration and added in
  migration 0010 (task 0028) — blocker #10 resolved.
- Part B: `facilities.provisioning_status NOT NULL DEFAULT 'active'`;
  `facilities.crm_facility_reference` with `UNIQUE` index;
  `users.account_status NOT NULL DEFAULT 'active'` — blocker #5 resolved (same migration
  renames `facility_admin` → `owner` per ADR 0011); blocker #6 resolved (ADR 0012 Decision 4:
  `users.created_by` nullable, no schema change needed).
- Part C: `provisioning_tokens` (RLS enabled, zero client policies);
  `provisioning_events` (RLS enabled, `REVOKE UPDATE, DELETE FROM authenticated`).
- Part G: Covered by `NOT NULL DEFAULT 'active'` — existing rows receive the default at
  `ALTER TABLE` time.

**`20260101000008_adr0010_rls_active_facility_gate.sql` (task 0030, 2026-05-19):**
- Part D: `is_active_user_on_active_facility()` — STABLE, SECURITY DEFINER.
- Part E: All 13 care-ops tables updated with the quarantine gate:
  `residents`, `care_log_entries`, `wellness_observations`, `follow_ups`,
  `shift_close_records`, `appointment_transports`, `resident_contacts`,
  `resident_preferences`, `allergies_triggers`, `room_checklists`,
  `family_resident_links`, `audit_events`, `handoff_summary`.
  Deferred tables (`shifts`, `routines`, `observed_care_tasks`) noted in migration header
  comments — apply gate when created.
- Part F: No write policies exist for `facilities` or `users` in the `authenticated` role →
  INSERT/UPDATE/DELETE implicitly blocked by RLS default-deny. `users_read_own` SELECT policy
  (migration 0005) preserved unchanged.

### Blockers resolved

| Blocker | Resolution |
|---|---|
| #5 — role naming (`facility_admin` vs `owner`) | RESOLVED: migration 0007 renames enum; ADR 0011 accepted |
| #6 — `users.created_by` | RESOLVED: ADR 0012 Decision 4 — nullable, provenance in ProvisioningEvent |
| #10 — `token_expired_passive` enum value | RESOLVED: migration 0010 adds value; sweep RPC added |

### SQL assertion coverage

`scripts/verify-provisioning/db-assertions.sql` (task 0040) covers all schema assertions
verifiable with a live DB: `pending_setup` quarantine, `active` access, zero-policy tables,
append-only enforcement, `crm_facility_reference` exclusion, tenant isolation. These remain
blocked on local Supabase — same blocker as tasks 0032 and 0060. No new assertion scripts
are required by this task.

### Checklist

- [x] All three new enums exist in schema (migrations 0007, 0010).
- [x] `facilities.provisioning_status` and `facilities.crm_facility_reference` (UNIQUE) exist.
- [x] `users.account_status` exists.
- [x] `provisioning_tokens` — RLS enabled, zero client-accessible policies.
- [x] `provisioning_events` — RLS enabled, UPDATE/DELETE revoked from `authenticated`.
- [x] `is_active_user_on_active_facility()` — STABLE, SECURITY DEFINER (migration 0008).
- [x] All 13 care-ops tables have quarantine gate in staff-scope USING clauses.
- [x] Existing facilities → `provisioning_status = 'active'` (via column DEFAULT).
- [x] Existing users → `account_status = 'active'` (via column DEFAULT).
- [x] Role naming resolved — ADR 0011 accepted; migration 0007 applied.
- [x] Migrations versioned — numbered sequence 0007/0008; IF NOT EXISTS guards where applicable.
- [x] No application source code changed by this task.

### Credential-dependent checks (blocked)

The following cannot be verified without a local Supabase instance:
- `pending_setup` care-ops quarantine (Scenario 1 DB state)
- `active` user + `active` facility access (Scenario 6 DB state)
- `provisioning_tokens` zero-policy enforcement (anon/authenticated deny)
- `provisioning_events` append-only enforcement (UPDATE/DELETE deny)
- `crm_facility_reference` column exclusion from client payloads
- Tenant isolation (cross-facility access denied)

Operator verification resources: `scripts/verify-provisioning/db-assertions.sql`,
`scripts/verify-provisioning/operator-handoff.md`.

## Notes

- `crm_facility_reference` column-level security cannot be enforced at the RLS layer in
  Postgres. Application layer enforces omission from all client-facing responses — verified
  in tasks 0038 and 0048 code inspection and secret scan.
- `provisioning_tokens` and `provisioning_events` have zero client-accessible policies.
  Default-deny applies to all `authenticated` and `anon` role access.
- `handoff_summary` included in Part E (migration 0008) per task 0027 Notes — consistent
  quarantine coverage despite not being in ADR 0010's original care-ops gate list.
- Deferred tables (`shifts`, `routines`, `observed_care_tasks`) noted in migration 0008
  header comments — quarantine gate must be applied when those tables are created.

## Outcome

Completed 2026-05-23. Task conclusively superseded — all schema and RLS work was
implemented in migrations 0007 and 0008 (task 0030, 2026-05-19) and subsequent
migrations 0009–0013. All 12 acceptance criteria verified against the actual migration
files. Blockers #5, #6, and #10 all resolved. SQL assertion scripts exist in
`scripts/verify-provisioning/db-assertions.sql`. Credential-dependent RLS policy checks
remain blocked on local Supabase — same status as tasks 0032 and 0060. No new migrations
or assertion scripts added.

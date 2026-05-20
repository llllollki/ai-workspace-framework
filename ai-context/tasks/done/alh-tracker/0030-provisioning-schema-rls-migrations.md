# Task 0030 — Phase 1 Schema/RLS Migrations and Role Cleanup Foundations

**Date:** 2026-05-19
**Status:** Done
**Type:** Schema migration / application code / security

---

## Objective

Implement all Phase 1 schema, RLS, and TypeScript changes needed before CRM owner provisioning
endpoint work can begin. Scope was defined by the task 0026 readiness audit against ADRs 0007,
0009, 0010, and 0011 (all accepted).

Out of scope: provisioning API endpoint, activation endpoint/page, CRM provisioning UI,
email sending, idempotency storage, `users.created_by` column, deep-link routing.

---

## Actions Taken

### Supabase Migrations

1. **`20260101000007_adr0011_role_enum_provisioning_schema.sql`** (new)
   - `ALTER TYPE app_role RENAME VALUE 'facility_admin' TO 'owner'` — propagates to all existing rows automatically; no data migration needed
   - `ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'admin'`
   - `CREATE TYPE user_account_status AS ENUM ('invited','password_pending','active','disabled')`
   - `CREATE TYPE facility_provisioning_status AS ENUM ('pending_setup','active','suspended','closed')`
   - `CREATE TYPE provisioning_event_type AS ENUM ('provisioned','token_resent','token_revoked','activated','activation_failed')`
   - `ALTER TABLE facilities ADD COLUMN provisioning_status facility_provisioning_status NOT NULL DEFAULT 'active'`
   - `ALTER TABLE facilities ADD COLUMN crm_facility_reference text` + UNIQUE index
   - `ALTER TABLE users ADD COLUMN account_status user_account_status NOT NULL DEFAULT 'active'`
   - `CREATE TABLE provisioning_tokens` (id, facility_id, user_id, token_hash, expires_at, used_at, created_at) — RLS enabled, zero client-accessible policies
   - `CREATE TABLE provisioning_events` (id, facility_id, user_id, event_type, actor_id, request_id, metadata, created_at) — RLS enabled, `REVOKE UPDATE, DELETE` from authenticated, zero client-accessible policies

2. **`20260101000008_adr0010_rls_active_facility_gate.sql`** (new)
   - `CREATE OR REPLACE FUNCTION is_active_user_on_active_facility() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER` — SECURITY DEFINER prevents circular RLS evaluation; STABLE enables PostgreSQL plan cache (one JOIN per statement, not per row)
   - Updated 13 care-ops table policies: `facilities`, `users`, `residents`, `care_log_entries`, `wellness_observations`, `follow_ups`, `appointment_transports`, `resident_contacts`, `resident_preferences`, `allergies_triggers`, `room_checklists`, `shift_close_records`, `handoff_summary`, `family_resident_links`, `audit_events`
   - Every updated policy pattern: `facility_id = current_facility_id() AND is_active_user_on_active_facility()`
   - `admin_manage_family_links`: `current_user_role() = 'facility_admin'` → `current_user_role() IN ('owner', 'admin')`
   - `audit_read_staff`: `'facility_admin'` → `'owner'`; `'admin'` added
   - `users_read_own` (migration 0005): intentionally NOT updated — disabled user must still read own row so UI can surface "account disabled" state
   - Deferred: `shifts`, `routines`, `observed_care_tasks` (tables not yet in schema) — noted in migration comments

### TypeScript / Application Code

3. **`src/lib/AuthProvider.tsx`**
   - Renamed exported type `AppRole` → `DbRole`; values updated: `'facility_admin'` → `'owner'`; `'admin'` added
   - `AuthUser.role: AppRole` → `AuthUser.role: DbRole`
   - `DEMO_AUTH_USER.role`: `'facility_admin'` → `'owner'`
   - `mapToStoreRole()`: added `'owner'` and `'admin'` branches; fallback `return 'owner'` → `return 'caregiver'` (prevents silent privilege escalation for unknown/future roles)
   - JSDoc updated to reference `owner` instead of `facility_admin`

4. **`src/types/index.ts`**
   - Removed unused `AnyRole` export (was `Role | 'family_member'`; no importers after `AppRole` rename)

5. **`src/data/seed.ts`**
   - `SEED_USERS[0]` (Maria Gonzalez, demo facility owner): `role: 'admin'` → `role: 'owner'`

### Reference Schema

6. **`db/schema.sql`**
   - `app_role` enum: `facility_admin` → `owner`, `admin` added
   - Provisioning enum types added
   - `facilities` table: `provisioning_status` and `crm_facility_reference` columns added
   - `users` table: `account_status` column added
   - `audit_read_admin` policy replaced with `audit_read_staff` (references `owner`/`admin`, includes active gate)
   - `provisioning_tokens` table, `provisioning_events` table, `is_active_user_on_active_facility()` function appended

---

## Files Changed

| File | Change |
|---|---|
| `supabase/migrations/20260101000007_adr0011_role_enum_provisioning_schema.sql` | New |
| `supabase/migrations/20260101000008_adr0010_rls_active_facility_gate.sql` | New |
| `db/schema.sql` | Role enum, provisioning columns/tables, RLS policy updates |
| `src/lib/AuthProvider.tsx` | DbRole rename, mapToStoreRole fix, DEMO_AUTH_USER role fix |
| `src/types/index.ts` | Removed dead AnyRole export |
| `src/data/seed.ts` | Demo user role: admin → owner |

---

## Security Properties

- `provisioning_tokens` and `provisioning_events` have zero client-accessible RLS policies. Service-role only.
- `is_active_user_on_active_facility()` is SECURITY DEFINER — prevents circular RLS evaluation on `users`/`facilities`.
- Quarantine gate enforced across all 13+ care-ops tables: both `account_status = 'active'` AND `provisioning_status = 'active'` required.
- `mapToStoreRole()` fallback is `'caregiver'` (not `'owner'`) — unknown/future roles do not receive elevated privileges.
- `facility_admin` enum value fully removed from DB and TypeScript layer. No dead values remain.

---

## Remaining Blockers Before Phase 2 (Provisioning Endpoint)

1. **Endpoint hosting model:** Vite SPA — not Next.js. Vercel API routes require framework migration. Supabase Edge Function recommended; Deno runtime must be verified. (ADR 0008 open TODO — task 0026 blocker #1)
2. **Idempotency storage mechanism:** In-process memory excluded for serverless. Options: Supabase `provisioning_idempotency_keys` table or Upstash Redis. (ADR 0008 open TODO — task 0026 blocker #2)
3. **Transactional email service:** No email service in codebase. Must select and configure before activation emails can be sent. (ADR 0007 open TODO — task 0026 blocker #3)
4. **`users.created_by` column:** ADR 0007 references this column; design decision still pending. (task 0026 blocker #6)

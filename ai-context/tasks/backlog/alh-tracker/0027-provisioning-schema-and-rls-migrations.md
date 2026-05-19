# 0027 — CRM Owner Provisioning: Schema and RLS Migrations

Status: backlog
Created: 2026-05-19
Depends on: resolve blocker #5 (role naming), blocker #6 (users.created_by), blocker #10 (token_expired_passive enum value)
Blocks: 0028, 0029, 0030, 0031, 0032
Audit source: 0026

## Goal

Apply all Supabase schema migrations required before the CRM owner provisioning endpoint
can be implemented. This task covers new enums, new columns on existing tables, two new
tables (`provisioning_tokens`, `provisioning_events`), the `is_active_user_on_active_facility()`
RLS helper function, updated policies on all care-ops tables, and safe defaults for
existing rows. No application code is changed in this task.

## Scope

### Part A: New Enums

```sql
CREATE TYPE user_account_status AS ENUM (
  'invited',
  'password_pending',
  'active',
  'disabled'
);

CREATE TYPE facility_provisioning_status AS ENUM (
  'pending_setup',
  'active',
  'suspended',
  'closed'
);

CREATE TYPE provisioning_event_type AS ENUM (
  'provisioned',
  'token_resent',
  'token_revoked',
  'activated',
  'activation_failed'
  -- 'token_expired_passive' deferred pending decision on background job (blocker #10)
);
```

### Part B: New Columns on Existing Tables

```sql
-- facilities table
ALTER TABLE facilities
  ADD COLUMN provisioning_status facility_provisioning_status
    NOT NULL DEFAULT 'active',
  ADD COLUMN crm_facility_reference text UNIQUE;

-- users table
ALTER TABLE users
  ADD COLUMN account_status user_account_status
    NOT NULL DEFAULT 'active';
  -- users.created_by: deferred pending blocker #6 decision
```

**Note — role naming discrepancy (blocker #5):** The actual `app_role` enum in the database
is `facility_admin, caregiver, med_tech, family_member, auditor`. ADR 0007 and data_model.md
say provisioned accounts receive `role = owner`. This must be resolved before Part B
or Part D touches `users.role`. Options: rename `facility_admin` → `owner` via a migration,
or update ADR 0007 and data_model.md to use `facility_admin`. Do not proceed with Parts C/D
until this decision is made and documented in an ADR update or addendum.

### Part C: New Tables

#### provisioning_tokens
```sql
CREATE TABLE provisioning_tokens (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id   uuid NOT NULL REFERENCES facilities(id),
  user_id       uuid NOT NULL REFERENCES users(id),
  token_hash    text NOT NULL UNIQUE,
  expires_at    timestamptz NOT NULL
                  DEFAULT (now() + INTERVAL '72 hours'),
  used_at       timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now()
);
-- RLS: enabled, zero client-accessible policies (default deny)
ALTER TABLE provisioning_tokens ENABLE ROW LEVEL SECURITY;
-- No policies created — service-role bypasses RLS; all reads/writes from service-role only
```

#### provisioning_events
```sql
CREATE TABLE provisioning_events (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id   uuid NOT NULL REFERENCES facilities(id),
  user_id       uuid NOT NULL,
  event_type    provisioning_event_type NOT NULL,
  actor_id      text,           -- opaque CRM actor ID (from X-CRM-Actor-Id header)
  request_id    text,           -- from X-Request-Id header
  metadata      jsonb,
  created_at    timestamptz NOT NULL DEFAULT now()
);
-- Append-only: revoke UPDATE and DELETE from application role (same pattern as audit_events)
ALTER TABLE provisioning_events ENABLE ROW LEVEL SECURITY;
-- No client-accessible policies
REVOKE UPDATE, DELETE ON provisioning_events FROM authenticated;
```

### Part D: RLS Helper Function

```sql
CREATE OR REPLACE FUNCTION is_active_user_on_active_facility()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM users u
    JOIN facilities f ON f.id = u.facility_id
    WHERE u.id = auth.uid()
      AND u.account_status = 'active'
      AND f.provisioning_status = 'active'
  );
$$;
```

### Part E: Update All Care-ops RLS Policies

All existing staff-scope USING clauses currently check only:
`facility_id = current_facility_id()`

Each must be updated to also require:
`AND is_active_user_on_active_facility()`

**Tables requiring policy updates (13 existing tables):**
- `residents`
- `care_log_entries`
- `wellness_observations`
- `follow_ups`
- `shift_close_records`
- `appointment_transports`
- `resident_contacts`
- `resident_preferences`
- `allergies_triggers`
- `room_checklists`
- `family_resident_links`
- `audit_events`
- `handoff_summary`

**Tables in ADR 0010 care-ops gate list that do NOT yet exist (deferred):**
- `shifts` — note in migration comment; apply gate when table is created
- `routines` — note in migration comment; apply gate when table is created
- `observed_care_tasks` — note in migration comment; apply gate when table is created

**Naming corrections for ADR 0010 reference (verified in audit 0026):**
- ADR 0010 "audit_trail" → actual table: `audit_events`
- ADR 0010 "family_access_consent" → actual table: `family_resident_links`
- ADR 0010 "shifts" → actual table: `shift_close_records` (different entity; apply gate to shift_close_records)

### Part F: facilities and users Table RLS Updates

Per ADR 0010 setup-safe access matrix:

```sql
-- facilities: service-role-only INSERT/UPDATE for provisioning columns
-- authenticated users may SELECT their own facility; may NOT write provisioning_status or crm_facility_reference
-- (column-level exclusion of crm_facility_reference must be enforced at application layer — no column-level RLS in Postgres)

-- users: INSERT restricted to service-role only (provisioning endpoint creates users)
-- Existing users_read_own policy (SELECT WHERE id = auth.uid()) remains
```

### Part G: Safe Defaults for Existing Rows

```sql
-- All existing facilities are already live — mark as active
UPDATE facilities SET provisioning_status = 'active' WHERE provisioning_status IS NULL;

-- All existing users are already active — mark as active
UPDATE users SET account_status = 'active' WHERE account_status IS NULL;
```

(These UPDATEs are only needed if columns are added WITHOUT DEFAULT. If columns are added
WITH DEFAULT as shown in Part B, existing rows are already populated correctly.)

## Acceptance Criteria

- [ ] All three new enums exist in schema.
- [ ] `facilities.provisioning_status` and `facilities.crm_facility_reference` (UNIQUE) exist.
- [ ] `users.account_status` exists.
- [ ] `provisioning_tokens` table exists with RLS enabled and zero client-accessible policies.
- [ ] `provisioning_events` table exists with RLS enabled, UPDATE/DELETE revoked from `authenticated`.
- [ ] `is_active_user_on_active_facility()` function exists (STABLE, SECURITY DEFINER).
- [ ] All 13 care-ops tables have `is_active_user_on_active_facility()` in their staff-scope USING clauses.
- [ ] All existing Facility rows have `provisioning_status = 'active'`.
- [ ] All existing User rows have `account_status = 'active'`.
- [ ] Role naming discrepancy resolved (blocker #5) and decision documented in ADR.
- [ ] Migration is idempotent or versioned such that re-running does not corrupt data.
- [ ] No application source code changed.

## Dependencies (blockers to resolve before implementation)

- **Blocker #5:** Role naming (`facility_admin` vs `owner`) — blocks Part D + Part E if `app_role` enum needs renaming
- **Blocker #6:** `users.created_by` column — can defer to addendum but must decide before activating provisioning endpoint
- **Blocker #10:** `token_expired_passive` enum value — determines final `provisioning_event_type` enum; can add later if excluded now

## Notes

- `crm_facility_reference` cannot be excluded at the RLS/column-level in Postgres. The application layer (provisioning endpoint response + repository select) must omit it from any client-facing payload.
- `provisioning_tokens` and `provisioning_events` must never appear in any client-side query. Zero policies + service-role-only access is the correct model.
- The `handoff_summary` table exists in schema but is not in ADR 0010's care-ops gate list — include it in the RLS policy update (Part E) to maintain consistent quarantine coverage.

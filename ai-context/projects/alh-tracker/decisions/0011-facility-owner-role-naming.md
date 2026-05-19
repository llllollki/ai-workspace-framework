# 0011 — Canonical Facility Staff Role Naming

**Date:** 2026-05-19
**Status:** proposed
**Supersedes:** n/a
**Superseded by:** n/a

## Context

A naming discrepancy was discovered during implementation readiness audit 0026. The
Supabase `app_role` enum in the current schema differs from the role model documented
in all ADRs, data_model.md, features.md, user_flows.md, and compliance_notes.md.

### Current state (schema — authoritative for database)

```sql
CREATE TYPE app_role AS ENUM (
  'facility_admin',   -- used in 2 existing RLS policies
  'caregiver',
  'med_tech',
  'family_member',    -- see § Family member note below
  'auditor'           -- see § Auditor note below
);
```

Existing RLS policies that reference `facility_admin`:
1. `family_resident_links` — `admin_manage_family_links` policy: `current_user_role() = 'facility_admin'`
2. `audit_events` — `audit_read_admin` policy: `current_user_role() IN ('facility_admin', 'auditor')`

### Current state (application layer)

`AuthProvider.tsx` defines a **local** `AppRole` type mirroring the DB values:
```typescript
export type AppRole = 'facility_admin' | 'caregiver' | 'med_tech' | 'family_member';
```

And a `mapToStoreRole()` function converts DB values to the application `Role` type:
```typescript
function mapToStoreRole(role: AppRole): Role {
  if (role === 'facility_admin') return 'admin';  // ← maps owner to admin (incorrect)
  if (role === 'caregiver')      return 'caregiver';
  if (role === 'med_tech')       return 'med_tech';
  return 'admin';  // fallback
}
```

**Critical bug in the mapping:** `facility_admin` → `admin` is incorrect. Facility owners
(operators) should have `role = 'owner'` in the application layer. The current mapping
means a facility owner logging in via Supabase receives `role: 'admin'` in the frontend
store — they can never receive `role: 'owner'`. The `owner` value in `src/types/index.ts`
is unreachable from any Supabase session in the current codebase.

`src/types/index.ts` defines the canonical application role type:
```typescript
export type Role = 'owner' | 'admin' | 'caregiver' | 'med_tech';
```

There is also a naming collision: `src/types/index.ts` exports `AppRole = Role | 'family_member'`,
while `AuthProvider.tsx` also exports its own `AppRole` (DB-facing type). Two exported
`AppRole` types with different values exist in different files.

### Current state (documentation)

All existing docs and all ADRs 0006–0010 use `owner` and `admin` as the canonical role names:
- `data_model.md` Role enum: `owner`, `admin`, `caregiver`, `med_tech`
- `compliance_notes.md` role permissions table: Owner, Admin, Caregiver, Med tech
- ADR 0006: "assigned the `owner` role"
- ADR 0007 Phase 1 Step 3b: `role = owner`
- ADR 0010: `user.role IN ('owner', 'admin')` in RLS policy conditions
- `features.md`, `user_flows.md`: reference "owner" and "admin" throughout

### The discrepancy in one sentence

`facility_admin` is an artifact in the DB enum that was never reconciled with the `owner`/`admin`
distinction that every other layer of the system uses. It conflates `owner` and `admin` into
a single value with no way to distinguish them at the DB layer.

---

## Options Considered

### Option A — Rename `facility_admin` → `owner`, add `admin` (recommended)

Change the DB `app_role` enum:
- Rename `facility_admin` → `owner`
- Add `admin` as a new enum value

Update all `users` rows currently holding `facility_admin` to `owner` (they are facility
operators — the correct role is `owner`).

Update the 2 RLS policies that reference `facility_admin` to reference `owner` or
`IN ('owner', 'admin')` as appropriate.

Remove the `mapToStoreRole()` mapping function (or simplify to a pass-through). The DB
role values will match the application role values directly.

**Pros:**
- DB schema matches business language and all existing documentation — no translation needed.
- `owner` role in the application layer is now reachable from Supabase DB data.
- CRM provisioning assigns `role = 'owner'` directly — no mapping, no ambiguity.
- Owner/admin distinction is enforceable at the DB and RLS layer.
- The naming collision between the two `AppRole` types is resolved by cleaning up `AuthProvider.tsx`.
- Aligns with the `mapToStoreRole()` bug fix: what the DB stores is what the app uses.

**Cons:**
- Requires a schema migration to rename the enum value in Postgres (ALTER TYPE ... RENAME VALUE).
- All existing `facility_admin` rows in `users` must be updated to `owner` in the same migration.
- Demo seed data and AuthProvider DEMO_AUTH_USER must be updated.

**Verdict:** Recommended. Migration is small and targeted. The resulting model is clean and unambiguous.

---

### Option B — Keep `facility_admin`, fix `mapToStoreRole()` to return `owner`

Update `mapToStoreRole()` to return `'owner'` instead of `'admin'` for `facility_admin`.
Add `admin` to the DB enum for future delegated admin users.
No DB enum rename required.

**Pros:**
- No schema migration for the existing `facility_admin` rows.
- Less disruptive to the schema.

**Cons:**
- Permanent split between the DB value (`facility_admin`) and the business/application
  value (`owner`). A future developer reading the schema must know this mapping exists.
- The `admin` DB value still needs to be added to the DB enum (same migration, just no rename).
- RLS policies still use `'facility_admin'` but ADR 0010 specs say `'owner'` — persistent
  mismatch between RLS code and ADR documentation.
- The naming collision in `AppRole` exports is not resolved.
- Continued cognitive overhead every time a developer reads a DB dump, RLS policy, or log.

**Verdict:** Rejected. The long-term cost of maintaining a permanent mapping between
`facility_admin` (DB) and `owner` (everywhere else) outweighs the short-term cost of
the migration. The migration is small (see Impact section).

---

### Option C — Collapse `owner` and `admin` into a single `facility_admin` value; update docs

Update all documentation to use `facility_admin` as the canonical name for all elevated
facility staff (owner + admin combined).

**Pros:**
- No DB migration needed.

**Cons:**
- Loses the owner/admin permission distinction that compliance_notes.md role permissions table
  already documents (Owner: manages user accounts; Admin: does not). Enforcing "owner-only"
  permissions at the DB/RLS layer becomes impossible with a single value.
- ADR 0007 and ADR 0010 both rely on an `owner` role with CRM provisioning authority.
  Collapsing to `facility_admin` undermines the CRM provisioning model.
- Future admin/house-manager users could not be distinguished from owners at the DB layer.
- Contradicts every existing ADR, user flow, and feature doc.

**Verdict:** Rejected. The owner/admin distinction is a documented and needed product concept.
Collapsing it sacrifices important access control granularity.

---

## Decision

**Selected: Option A — rename `facility_admin` → `owner` in the `app_role` DB enum, and add `admin` as a new enum value.**

The canonical `app_role` enum after migration:

```sql
CREATE TYPE app_role AS ENUM (
  'owner',         -- facility owner/operator (replaces 'facility_admin')
  'admin',         -- delegated facility admin / house manager (new value)
  'caregiver',     -- care logging and read access
  'med_tech',      -- observed-care-task logging; same event access as caregiver
  'family_member', -- see § Family member note (deferred scope)
  'auditor'        -- see § Auditor note (existing, document-only update)
);
```

---

## Canonical Role Model

### `owner`

The RCFE operator or licensed administrator who activated the facility account via the
CRM provisioning flow. Full facility tracker capability: resident management, user
management (create/deactivate caregivers and admins), family access approvals, facility
settings, billing authority, audit trail read, care operations.

CRM provisioning assigns `role = 'owner'` at provision time (ADR 0007 Phase 1 Step 3b).
There is exactly one owner per facility at MVP. The owner is the contact for ALH Tracker
commercial relationship.

Permissions per compliance_notes.md: all resident management, all care operations, grant
and revoke family access, manage user accounts (owner-exclusive), billing.

### `admin`

A delegated facility admin or house manager. Broad operational capability: resident
management, care operations, family access management. Does NOT have user account
management authority (cannot create or deactivate other users) or billing authority.
Not created via CRM provisioning — created by the owner within the tracker app after
the facility is active.

Permissions per compliance_notes.md: same as owner except user account management
and billing.

### `caregiver`

Can log shift events (care logs, wellness observations, follow-ups). Cannot edit
resident profiles or modify facility settings.

### `med_tech`

Same shift-logging access as caregiver, with observed-care-task scope. Read-only
access to resident profile safety, mobility, and contact sections relevant to
shift operations.

### `family_member` — deferred scope (see § Family member note)

### `auditor` — existing, undocumented (see § Auditor note)

---

## Legacy / Current Implementation Mapping

| DB enum (before migration) | DB enum (after migration) | Application `Role` type |
|---|---|---|
| `facility_admin` | `owner` | `owner` |
| — (not in DB) | `admin` (new) | `admin` |
| `caregiver` | `caregiver` | `caregiver` |
| `med_tech` | `med_tech` | `med_tech` |
| `family_member` | `family_member` (unchanged) | — (separate principal; ADR 0006) |
| `auditor` | `auditor` (unchanged) | — (not yet in `Role` type; see note) |

---

## Required Migration and Code Impacts

### Schema migration (required before task 0027 Part B / task 0028)

```sql
-- Step 1: Add new enum values
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'owner';
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'admin';
-- Note: In Postgres, enum values can be added but existing values cannot be renamed
-- directly. The standard approach is:
--   1. Create new enum values
--   2. Update existing rows to new values
--   3. Drop old enum value by recreating the type (Postgres 15 does not support DROP VALUE;
--      use CREATE TYPE app_role_new ... AS ENUM (...), ALTER TABLE ... ALTER COLUMN role TYPE
--      app_role_new USING ..., DROP TYPE app_role, ALTER TYPE app_role_new RENAME TO app_role)
--   OR use a simpler approach that works in Postgres 15:
--      ALTER TYPE app_role ADD VALUE 'owner' AFTER 'med_tech';
--      ALTER TYPE app_role ADD VALUE 'admin' AFTER 'owner';
--      UPDATE users SET role = 'owner' WHERE role = 'facility_admin';
--      -- Old 'facility_admin' value remains in enum but has zero rows; functionally inert.
--      -- Clean removal requires type recreation (deferred to a later cleanup migration).

-- Step 2: Update all existing rows
UPDATE users SET role = 'owner' WHERE role = 'facility_admin';
-- Verify: SELECT COUNT(*) FROM users WHERE role = 'facility_admin'; should be 0.
```

**Note:** Postgres 15 does not support `ALTER TYPE ... DROP VALUE`. The cleanest production
approach is to add new values, update rows, and leave the old value in the enum (functionally
dead after the UPDATE). A cleanup migration to remove `facility_admin` entirely via type
recreation can be done separately as a low-risk follow-up after confirming zero rows use it.

### RLS policy updates (required in task 0027 Part E)

Two existing policies must be updated:

1. `family_resident_links — admin_manage_family_links`:
   - Before: `current_user_role() = 'facility_admin'`
   - After: `current_user_role() IN ('owner', 'admin')`

2. `audit_events — audit_read_admin`:
   - Before: `current_user_role() IN ('facility_admin', 'auditor')`
   - After: `current_user_role() IN ('owner', 'admin', 'auditor')`

### Application code updates (required before Supabase integration)

**`AuthProvider.tsx`:**
- Rename local `AppRole` type to `DbRole` (or remove and import from a central location)
  to avoid the naming collision with `src/types/index.ts`'s `AppRole`.
- Update local DB-facing type: replace `'facility_admin'` with `'owner'`.
- Update DEMO_AUTH_USER: `role: 'facility_admin'` → `role: 'owner'`.
- Simplify or remove `mapToStoreRole()`: after migration, DB values match application
  values directly. The function can become a simple passthrough or be inlined.

**`src/types/index.ts`:**
- `AppRole = Role | 'family_member'` — this type name collides with AuthProvider's
  DB-facing `AppRole`. Consider renaming to `AnyRole` or removing it. The `'family_member'`
  value is for a separate principal (ADR 0006) and may not belong in the staff `Role` type
  union at all. Resolve at implementation time.

**`src/data/seed.ts`:**
- Demo seed user with `role: 'admin'` should be reviewed: if this is a facility owner
  in the demo scenario, the value should be updated to `'owner'`. If it represents a
  delegated admin (house manager), `'admin'` is correct.
- Add a demo user with `role: 'owner'` to represent the facility operator in demo mode.

---

## RLS Impact

ADR 0010 RLS policy conditions reference `user.role IN ('owner', 'admin')` throughout.
After the schema migration described above, those conditions are valid as written.
No changes to ADR 0010 are required — ADR 0010 was written against the intended post-
migration role model, not the current legacy `facility_admin` value.

The `is_active_user_on_active_facility()` helper function (ADR 0010) does not reference
any role value — it only checks `account_status` and `provisioning_status`. No change required.

`current_user_role()` function returns `app_role` type. After the enum includes `owner`,
calls to `current_user_role() = 'owner'` are valid at both the Postgres and application level.

---

## CRM Provisioning Impact

ADR 0007 Phase 1 Step 3b specifies:
> `role = owner` for the provisioned owner account

After the DB migration, `owner` is a valid `app_role` enum value. The provisioning endpoint
(task 0028) assigns `role = 'owner'` directly — no mapping layer required.

The `owner` role value is now consistent across:
- DB enum: `app_role.owner`
- Application `Role` type: `'owner'`
- ADR 0007 spec: `role = owner`
- ADR 0006 spec: "assigned the `owner` role"
- ADR 0010 RLS conditions: `'owner'`

---

## Family Approval Authority Impact

ADR 0006 and the compliance_notes.md role permissions table allow both owner and admin
to grant and revoke family access:
> "Grant family access: Yes (Owner), Yes (Admin)"

The `family_resident_links` RLS policy change (from `'facility_admin'` to `IN ('owner', 'admin')`)
preserves this behavior correctly — both owner and admin retain family access management authority.

No change to the documented family approval authority model.

---

## § Family Member Note (out of scope for this ADR)

`family_member` exists in the `app_role` DB enum. ADR 0006 states:
> "FamilyUser must NOT be added to [the `User`] table."

There is a tension between having `family_member` in the staff `app_role` enum and the
ADR 0006 requirement that family members are a separate principal (`FamilyUser`), not
a staff `User` record. No existing RLS policy grants `family_member` role access to any
care data table through the staff `users` table.

**This inconsistency is out of scope for ADR 0011** — resolving it requires a separate
design decision about whether `family_member` should be removed from `app_role`, or
whether a separate `family_users` table will coexist with a `family_member` entry in the
staff role enum for a different purpose. Leave `family_member` in the enum unchanged.
Track as a separate TODO.

---

## § Auditor Note (out of scope for this ADR — doc update only)

`auditor` exists in the `app_role` DB enum and is referenced in the `audit_events` read
policy. It represents an internal read-only access role for audit purposes. It is not
defined in `data_model.md`'s Role enum. `data_model.md` should be updated to document
`auditor` as an existing DB role. This is a documentation correction, not an architectural
decision. See implementation TODOs.

---

## Non-Goals

This ADR does not:
- Implement any schema migration or code change — those are task 0027 and task 0031.
- Define the `auditor` role's full permissions (a separate doc update is sufficient).
- Resolve the `family_member` enum value in `app_role` (separate design decision).
- Change the owner/admin permission model documented in compliance_notes.md.
- Affect the `FamilyUser` authentication model (Phase 2, ADR 0004, ADR 0006).
- Resolve any other blockers from audit 0026 (see tasks 0028–0032).

---

## Consequences

**Easier after migration:**
- DB schema matches business language in all docs and ADRs — no translation layer needed.
- `owner` role is reachable from real Supabase data (current bug fixed).
- CRM provisioning assigns `role = 'owner'` directly.
- Owner-only permissions (user account management) can be enforced at the RLS layer.
- `mapToStoreRole()` complexity removed from AuthProvider.
- ADR 0010 RLS policy specs are valid as written.

**Harder / risks:**
- Schema migration required before provisioning implementation can begin.
- Must verify zero `facility_admin` rows in `users` before treating `facility_admin` as
  deprecated in RLS policies (SELECT COUNT(*) check in migration).
- The `facility_admin` enum value cannot be dropped in Postgres 15 without type recreation —
  it will remain in the enum as a dead value until a cleanup migration is applied.
- Demo seed data must be reviewed for which user represents the owner vs. a delegated admin.

---

## Open Implementation TODOs

- **TODO — Schema migration:** Write migration to add `owner` and `admin` to `app_role` enum
  and UPDATE all `facility_admin` rows to `owner`. Include SELECT COUNT(*) assertion.
  Target: same migration file as task 0027 Part A (new enums).
- **TODO — RLS policy migration:** Update `admin_manage_family_links` and `audit_read_admin`
  policies (details above). Target: task 0027 Part E.
- **TODO — AuthProvider.tsx:** Rename local `AppRole` to `DbRole` or equivalent; update DEMO_AUTH_USER
  role; simplify `mapToStoreRole()`. Target: task 0031.
- **TODO — `src/types/index.ts`:** Resolve `AppRole` naming collision. Target: task 0031.
- **TODO — `src/data/seed.ts`:** Verify and update demo user roles (add an `owner` demo user
  if missing). Target: task 0031.
- **TODO — `data_model.md` Role enum:** Add `auditor` as a documented DB role (separate from
  the four primary staff roles); add note that `facility_admin` was the legacy DB value
  superseded by `owner` per this ADR. Target: companion doc update to this ADR.
- **TODO — `family_member` in `app_role`:** Investigate whether any `users` rows have
  `role = 'family_member'` in any Supabase environment. If so, document and plan migration
  as part of Phase 2 FamilyUser design. If not, leave as a dead enum value.
- **TODO — Cleanup migration:** After all provisioning and auth implementations are complete
  and `facility_admin` has zero rows in any environment, add a type-recreation migration to
  remove `facility_admin` from the `app_role` enum permanently.

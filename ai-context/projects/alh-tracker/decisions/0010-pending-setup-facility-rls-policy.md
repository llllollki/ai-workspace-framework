# 0010 — Pending Setup Facility RLS Policy

**Date:** 2026-05-19
**Status:** accepted
**Supersedes:** The "TODO — RLS policy for pending_setup facilities" in ADR 0009
Open Implementation TODOs
**Superseded by:** n/a

## Context

ADR 0009 (accepted 2026-05-19) defined the tracker `Facility` record creation
sequence and introduced `Facility.provisioning_status` with states:
`pending_setup`, `active`, `suspended`, `closed`. ADR 0009 explicitly deferred
the RLS policy design:

> "TODO — RLS policy for pending_setup facilities: The Row Level Security policy
> for tracker Facility records in `pending_setup` state must be designed before
> the provisioning endpoint is implemented. Owners in `invited` or
> `password_pending` state must have no access to care-operations tables.
> Activation-scoped access only."

ADR 0007 (accepted 2026-05-18) establishes the activation sequence on which the
RLS policy depends:

- The Supabase Auth user (`auth.users` entry) for an invited owner is created at
  activation time only — not at provisioning time.
- A Supabase session is issued to the owner only after `User.account_status = active`
  is set (step 8k of ADR 0007 Phase 2).
- `Facility.provisioning_status` transitions from `pending_setup` to `active` in
  the same atomic transaction as `User.account_status` transitioning to `active`
  (ADR 0009 owner activation sub-sequence).

The pending_setup state creates a security design question: what RLS policies
govern tracker Supabase tables during the provisioning lifecycle, from provisioning
call through owner activation?

### Constraints in scope

1. A `pending_setup` facility is a provisioning anchor only — it has no residents,
   no shifts, and no care data. This is by design (ADR 0009).
2. `invited` and `password_pending` users have no Supabase Auth session. The auth
   user is created at activation time (ADR 0007). RLS is session-based — no
   session means no client-side database access is possible for these states.
3. Despite constraint 2, RLS policies must be written defensively — they must not
   rely solely on the invariant that `invited`/`password_pending` users always lack
   a session. Edge cases (partial activation recovery, future flow additions) must
   not produce unauthorized access if the invariant is briefly violated.
4. The atomic activation invariant (ADR 0007 Phase 2 + ADR 0009): both
   `User.account_status = active` and `Facility.provisioning_status = active` are
   set in the same database transaction protected by a row-level write lock
   (SELECT FOR UPDATE on the ProvisioningToken row). By design, there is no window
   where a live client session exists for an `active` user on a `pending_setup`
   facility.
5. CRM users must never access tracker care data (ADR 0005). This constraint is
   enforced at the service layer (API key scope). It is separate from Supabase
   client RLS and is not the focus of this ADR.
6. FamilyUser authentication is a Phase 2 concern (ADR 0004, ADR 0006). FamilyUser
   RLS policies are out of scope for this ADR; implications for family access are
   documented in the Family Access Implications section.
7. No application code is implemented in this ADR — this is an architecture/design
   decision record only.

---

## Options Considered

### Option A — Quarantine model: `pending_setup` is a zero-client-access state (selected)

All care-operations tables require both `User.account_status = active` AND
`Facility.provisioning_status = active` before any client-side read or write is
permitted. A `pending_setup` facility's records are inaccessible from any client
Supabase session, regardless of user state.

All provisioning operations (creating the Facility, User, and ProvisioningToken
rows) run server-side using the service-role key. Service-role access bypasses
RLS. No client policy is needed for provisioning writes.

**How it works:**
- Every care-ops table RLS policy includes the combined active-status check
  (encapsulated in a `is_active_user_on_active_facility()` helper function).
- The `users` table has a narrow self-read policy: any authenticated user may
  read their own row (`id = auth.uid()`), regardless of `account_status`, to
  retrieve `facility_id`, `role`, and `account_status` for client-side routing.
- The `facilities` table has a narrow self-read policy: an authenticated user
  may read their facility row. Write access to setup fields (name, address,
  capacity, etc.) requires the combined active-status check. `provisioning_status`
  and `crm_facility_reference` are never client-writable.
- `ProvisioningToken` and `ProvisioningEvent` tables have zero client-accessible
  RLS policies — all access is service-role only.

**Pros:**
- Simplest mental model: active user + active facility = role-based access;
  anything else = no care-ops access.
- Defense in depth: even if an `invited` or `password_pending` user somehow
  obtained a session, they are blocked at the RLS layer.
- Clean activation semantics: the single atomic transaction (ADR 0009) is the
  gate. No partial-access states to maintain or audit.
- Prevents residents or care records from being created before a facility is
  operational. Aligns with ADR 0009's `pending_setup` description: "No residents,
  no shifts, no care data."
- `ProvisioningToken` and `ProvisioningEvent` are permanently locked from
  client access regardless of future policy changes.

**Cons:**
- Owners cannot pre-populate the resident roster before activation (all setup
  happens after the facility is `active`).
- If the atomic activation transaction fails between auth user creation (step 8g)
  and `account_status = active` (step 8h), the user would have an auth entry but
  no data access — this is safe behavior, and recovery is already a documented
  TODO (ADR 0007 partial activation recovery).

**Verdict:** Selected. Aligns with the quarantine intent stated in ADR 0009 for
the `pending_setup` state. The cons are acceptable — pre-activation roster setup
is not a stated product requirement.

---

### Option B — Limited setup mode: allow pre-activation writes to roster tables

Allow a facility owner with `account_status = active` (if somehow in that state
before activation completes) to create residents and configure routines before
`provisioning_status = active`. This would require a `setup_mode` RLS gate
covering `residents`, `routines`, and `resident_preferences`, while blocking shift
logging, care log entries, and all read-intensive tables.

**Verdict:** Not feasible under the current ADR 0007 activation model. The
Supabase Auth user is created at activation time only. There is no authenticated
session before `account_status = active`. Implementing this option would require
revisiting ADR 0007 to create the auth user earlier — which ADR 0007 rejected
(Option A) because it requires the CRM to hold the tracker service-role key.
Excluded.

---

### Option C — Thin provisioning-safe access: authenticated user can always read own profile and facility row

Same as Option A for all care-ops tables. Differs only in making explicit that
the `users` self-read and `facilities` self-read are always available to an
authenticated user, even on a `pending_setup` facility, so the app can route
correctly after login.

**Verdict:** This is Option A with explicit documentation of the narrow setup-safe
read policies. Incorporated into Option A rather than treated as a separate option.

---

## Decision

**Selected: Option A — Quarantine model.**

`pending_setup` is treated as a provisioning-only state with no client-side
care-ops access. The RLS layer enforces a two-condition gate on all
care-operations tables:

1. `User.account_status = 'active'` for the requesting user
2. `Facility.provisioning_status = 'active'` for the user's facility

Both conditions must be true for any client-initiated read or write to care-ops
tables. This gate is implemented as a reusable helper function
`is_active_user_on_active_facility()` (see Required Helper Functions section).

Provisioning-safe tables (`users`, `facilities`) have narrow scoped policies
documented in the Setup-Safe Table Access section.

`ProvisioningToken` and `ProvisioningEvent` have zero client-accessible RLS
policies. All access to these tables is service-role only.

### Answer to Q4: No separate `setup_incomplete` state

ADR 0009 already decided that `pending_setup → active` transitions atomically on
owner activation. Owner completion of post-activation facility setup (address,
ZIP, licensed capacity) is a user-experience concern, not an RLS/security concern.
A `setup_incomplete` intermediate state is not introduced. The `active` state
means the facility is authorized to receive care-ops data, regardless of whether
the owner has completed all setup fields.

### Answer to Q5: Resident setup before activation is blocked

No residents may be created while `Facility.provisioning_status = pending_setup`.
The `residents` table requires the combined active-status check. This aligns with
ADR 0009: "No residents, no shifts, no care data" in `pending_setup` state.

---

## Facility State Access Matrix

| `Facility.provisioning_status` | Care-ops tables | Facility setup fields | Own `users` row | `provisioning_tokens` | `provisioning_events` |
|---|---|---|---|---|---|
| `pending_setup` | BLOCKED — no client read or write | BLOCKED — client has no session in this state | BLOCKED — no session | Service-role only | Service-role only |
| `active` | Allowed per user role + `account_status = active` | Owner/admin: read + write. Caregiver/med_tech: read-only. | Allowed (own row) | Service-role only | Service-role only (owner read: future TODO) |
| `suspended` | Read-only (SELECT permitted; INSERT/UPDATE/DELETE blocked) — see Suspended/Closed section | Read-only | Allowed (own row) | Service-role only | Service-role only |
| `closed` | BLOCKED — no client access | BLOCKED | BLOCKED | Service-role only | Service-role only |

---

## User Account State Access Matrix

| `User.account_status` | Supabase Auth session | Care-ops table access | Facility setup fields | Own `users` row |
|---|---|---|---|---|
| `invited` | No session — `auth.users` entry not yet created (ADR 0007) | BLOCKED (no session) | BLOCKED | BLOCKED |
| `password_pending` | No session — `auth.users` created within server-side activation transaction; session not yet issued (ADR 0007 step 8k) | BLOCKED (no session; and even if a session existed, `account_status ≠ active` blocks at RLS layer) | BLOCKED | BLOCKED |
| `active` | Session issued after successful activation (ADR 0007 step 8k) | Allowed if `Facility.provisioning_status = active`; otherwise BLOCKED | Allowed (per role and provisioning_status) | Allowed |
| `disabled` | Session must be revoked immediately on disable action (see TODO) | BLOCKED (`account_status` check fails) | BLOCKED | BLOCKED |

---

## Care-Ops Table RLS Rule

All care-operations tables must enforce the following combined gate. Stated
conceptually; exact SQL must be defined during implementation.

**Access condition — applies to SELECT, INSERT, UPDATE, DELETE on all care-ops tables:**

```
Row is accessible when ALL of the following are true:
  1. row.facility_id = current_facility_id()
     [facility_id scoped to the authenticated user's facility]
  2. is_active_user_on_active_facility() = TRUE
     [user.account_status = 'active' AND facility.provisioning_status = 'active']
  3. Role-level permission for the specific operation applies
     [per compliance_notes.md role permissions table]
```

The `is_active_user_on_active_facility()` helper encapsulates condition 2 — both
the `account_status` and `provisioning_status` status checks — and must be used
alongside condition 1 (`facility_id = current_facility_id()`) in the USING clause
of every care-ops policy. All three conditions are required; omitting condition 1
(`facility_id = current_facility_id()`) would break tenant isolation — an active
user on one facility could access care-ops rows from another active facility.

### Care-ops tables this rule applies to

| Table | Notes |
|---|---|
| `residents` | All operations blocked until facility + user active. No residents in `pending_setup`. |
| `care_log_entries` | All operations blocked. |
| `observed_care_tasks` | All operations blocked. |
| `wellness_observations` | All operations blocked. See TODO below. |
| `follow_ups` | All operations blocked. |
| `room_checklists` | All operations blocked. |
| `appointment_transports` | All operations blocked. |
| `resident_contacts` | All operations blocked. |
| `resident_preferences` | All operations blocked. |
| `allergies_triggers` | All operations blocked. |
| `shifts` | All operations blocked. |
| `routines` | All operations blocked. |
| `audit_trail` | INSERT: blocked until facility + user active (no care-ops events occur in `pending_setup`). SELECT: owner/admin may read their facility's audit trail when `provisioning_status = active`. No UPDATE or DELETE (append-only — database-level enforcement required). |
| `family_access_consent` | All operations blocked; additionally requires `user.role IN ('owner', 'admin')` for INSERT/UPDATE (caregivers cannot grant family access). |

**TODO — `wellness_observations`:** This entity is referenced in product documentation
and the role permissions table in `compliance_notes.md` but is not explicitly defined
as a separate Supabase table in `data_model.md`. If it is a separate table, it must
be included in the above policy list. If it is part of `care_log_entries`, the
`care_log_entries` policy covers it. Implementer must clarify before applying
migrations.

---

## Setup-Safe Table Access

These tables have narrow, provisioning-safe RLS policies that apply regardless
of `Facility.provisioning_status`.

### `users` table

| Operation | Condition |
|---|---|
| SELECT own row | `id = auth.uid()` — allowed for any authenticated user regardless of `account_status` |
| SELECT other facility members | `facility_id = current_facility_id()` AND `is_active_user_on_active_facility()` AND role-level check |
| INSERT | Service-role only (provisioning endpoint). Owner creating caregivers/admins in-app requires `is_active_user_on_active_facility()`. |
| UPDATE own profile fields | `id = auth.uid()` AND `account_status = 'active'` |
| UPDATE other users' rows | Owner only; requires `is_active_user_on_active_facility()` |
| DELETE | No client DELETE. Deactivation sets `account_status = 'disabled'`. |

**Why self-read is always allowed:** The client app needs the authenticated user's
`facility_id`, `role`, and `account_status` to route to the correct screen
(e.g., show "setup pending" state, display role-appropriate navigation). This
narrow self-read returns only the requesting user's own row and reveals no other
user's or facility's data.

### `facilities` table

| Field group | SELECT | INSERT | UPDATE |
|---|---|---|---|
| Setup fields (`name`, `address`, `city`, `state`, `zip`, `capacity`, `license_number`, `alh_partner`, `alh_partner_tier`) | Owner/admin: `id = current_facility_id()`. No `provisioning_status` check required for SELECT. | Service-role only. | Owner/admin: `id = current_facility_id()` AND `is_active_user_on_active_facility()`. |
| `provisioning_status` | Owner/admin: `id = current_facility_id()` (readable for client-side state display). | Service-role only. | Service-role only — never client-writable. |
| `crm_facility_reference` | Never client-readable. Service-role only. | Service-role only. | Service-role only. |
| `id`, `created_at` | Owner/admin: `id = current_facility_id()`. | Service-role only. | Service-role only. |

**`provisioning_status` client read note:** The app may read `provisioning_status`
to display an appropriate state message (e.g., "Your facility is being set up").
It must never be writable by any client.

### `provisioning_tokens` table

Zero RLS policies granting client access. All access must use the service-role key.
RLS must be enabled on this table with no client-accessible policies, so the
default-deny behavior applies to all `authenticated` and `anon` role access.

Conceptual implementation:
```sql
ALTER TABLE provisioning_tokens ENABLE ROW LEVEL SECURITY;
-- No policies created → default deny for all non-service-role access.
```

### `provisioning_events` table

Zero client-write RLS policies (no INSERT, UPDATE, or DELETE from client sessions).
Append-only enforcement at the database level (same as `audit_trail`).

SELECT for owner/admin: deferred. During MVP, `provisioning_events` is backend-only.
See Open Implementation TODOs.

Conceptual implementation:
```sql
ALTER TABLE provisioning_events ENABLE ROW LEVEL SECURITY;
-- No policies during MVP → default deny for all non-service-role access.
```

---

## Activation Transaction Expectations

The RLS policy design depends on the following invariant established by ADR 0007
and ADR 0009:

**Invariant:** If `User.account_status = 'active'` for a given user, then
`Facility.provisioning_status = 'active'` for that user's facility — and vice
versa. Both transitions occur atomically within a single database transaction
protected by a row-level write lock on the `ProvisioningToken` row
(SELECT FOR UPDATE, spanning steps 8c–8i of ADR 0007 Phase 2).

**Implication for RLS:** By the invariant, there should be no live client session
where `User.account_status = 'active'` but `Facility.provisioning_status =
'pending_setup'`. However, the RLS policy must enforce both conditions
independently — not rely on the invariant as a single control.

**If the invariant is violated (edge case):** Both the `account_status = 'active'`
check and the `provisioning_status = 'active'` check must pass independently for
care-ops access. A partial failure (e.g., `account_status = 'active'` but
`provisioning_status = 'pending_setup'` due to a transaction error) results in
care-ops access being blocked — the correct safe behavior.

**Implementation requirement:** The activation endpoint must execute both the
`User.account_status = 'active'` update and the `Facility.provisioning_status =
'active'` update in a single atomic PostgreSQL transaction, with the row lock on
`ProvisioningToken` held through both updates. Application-level sequential
updates without a transaction are not sufficient and would expose a race window.

---

## Suspended and Closed Facility Notes

### `suspended` facilities

A `suspended` facility is a commercial suspension (billing lapse or admin action).
Per ADR 0009, "Tracking may continue in read-only mode per product policy."

**RLS design intent for `suspended`:**
- SELECT on care-ops tables: permitted for authenticated users with
  `account_status = 'active'` on a suspended facility (read-only continuity and
  data export access).
- INSERT / UPDATE / DELETE on care-ops tables: blocked when
  `Facility.provisioning_status = 'suspended'`.

**Note:** The `is_active_user_on_active_facility()` helper as specified (requiring
`provisioning_status = 'active'`) would block ALL access — including SELECT — for
suspended facilities. Implementing suspension read-only access requires a second
helper or a modified combined check. This is intentionally deferred.

**TODO:** Exact RLS behavior for `suspended` facilities is deferred to the
billing/suspension feature implementation task. The core provisioning RLS gate
(`pending_setup` blocker) is the immediate priority. This ADR establishes the
design intent (read-only for `suspended`); implementation detail is deferred.

### `closed` facilities

No client access of any kind. Terminal state. The `is_active_user_on_active_facility()`
helper (requiring `provisioning_status = 'active'`) naturally blocks all access
for `closed` facilities. No additional policy change is required.

---

## Family Access Implications

The `FamilyUser` authentication model is a Phase 2 concern (ADR 0004, ADR 0006).
The following constraints apply regardless of when Phase 2 is built:

1. **No `FamilyAccessConsent` may be created for a `pending_setup` or `closed`
   facility.** The `family_access_consent` table is a care-ops table and is
   blocked by the combined active-status gate.

2. **Any future FamilyUser RLS policy for resident data access must include a
   `Facility.provisioning_status = 'active'` check.** The FamilyAccessConsent
   validity check alone is not sufficient — the facility must also be active.

3. **No new family access grants during `suspended` state.** The INSERT block on
   care-ops tables during suspension prevents new `FamilyAccessConsent` records.

4. **Active `FamilyAccessConsent` records during suspension (TODO).** If a
   facility is suspended and has existing active grants, whether family members
   retain read access to the approved wellbeing view is a product policy question.
   **TODO: define behavior for active `FamilyAccessConsent` records when facility
   transitions to `suspended`.** Must be resolved before Phase 2 family access is
   built. See `ai_memory.md`.

5. **Family access must not expose provisioning data.** The FamilyUser access
   scope (per ADR 0004) is limited to the approved wellbeing view for granted
   residents. Provisioning state, CRM references, and facility setup details are
   not in the family access scope.

---

## Audit and Provisioning Event Implications

### `audit_trail`

The `audit_trail` table follows the care-ops gate: INSERT requires
`is_active_user_on_active_facility()`. This is correct — no care-ops events occur
in `pending_setup` state, so no audit entries should be writable either.

SELECT: owner and admin roles may read their facility's audit trail records when
`provisioning_status = 'active'`. No read access for `pending_setup` or `closed`
facilities.

Append-only enforcement: no UPDATE or DELETE from any client session. Database-level
enforcement required (revoke UPDATE and DELETE on `audit_trail` from the application
role). This requirement is already documented in `data_model.md` and
`compliance_notes.md` — this ADR reaffirms it.

### `provisioning_tokens`

All access is service-role only. RLS must be enabled with no client-accessible
policies — the default-deny applies to all `authenticated` and `anon` role requests.

**Non-negotiable:** This table must never be accessible via any client-side Supabase
query. A raw token in this table, if readable by a client, would allow account
takeover.

### `provisioning_events`

All writes are service-role only. During MVP, reads are also service-role only.

**Future (deferred TODO):** A narrow SELECT policy may be added for owner/admin to
read their facility's provisioning event log (account lifecycle visibility). This
is deferred and should be addressed when the provisioning audit feature is designed.
Until then, no client SELECT policy exists.

---

## Required Supabase Helper Functions and Policy Changes

The following helper functions and policy changes are required to implement this
ADR. These are conceptual specifications — exact SQL syntax, column names, and
type names must be verified against the actual Supabase schema at implementation
time.

### New helper: `is_active_user_on_active_facility()`

```sql
CREATE OR REPLACE FUNCTION is_active_user_on_active_facility()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM users u
    JOIN facilities f ON f.id = u.facility_id
    WHERE u.id = auth.uid()
      AND u.account_status = 'active'
      AND f.provisioning_status = 'active'
  );
$$;
```

**Usage:** Used in the USING clause for all care-ops table RLS policies alongside
`facility_id = current_facility_id()` and the applicable role check. Do not use
`is_active_user_on_active_facility()` alone — it does not enforce row-level
`facility_id` scoping and cannot substitute for the tenant isolation check.

**SECURITY DEFINER note:** This function queries `users` and `facilities` as the
function owner (with elevated read privileges) and returns only a boolean. This
prevents the `authenticated` role from needing direct SELECT grants on all columns
of those tables.

**STABLE note:** Marks the result as consistent within a single transaction,
allowing query planner caching. Required for RLS performance — the function is
called on every row evaluated.

**Performance TODO:** This function performs a JOIN on two tables per RLS evaluation.
Profile under realistic load before commercial launch. Candidate optimizations:
partial indexes on `users(id, account_status, facility_id)` and
`facilities(id, provisioning_status)`.

### New or updated helper: `current_facility_id()`

```sql
CREATE OR REPLACE FUNCTION current_facility_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT facility_id
  FROM users
  WHERE id = auth.uid();
$$;
```

**Usage:** Used in `USING (facility_id = current_facility_id())` for all facility-
scoped policies.

**Note:** An equivalent function may already exist in the current Supabase RLS
setup (the data model requires facility_id scoping from the authenticated session).
If one exists, verify it matches this specification and update rather than duplicate.

### Existing policies to extend

All existing care-ops table RLS policies must be extended to add the
`is_active_user_on_active_facility()` check alongside the existing
`facility_id = current_facility_id()` scope check.

The existing policies (from Phase 4 Supabase migration, commit `dbfe4d8` per
execution_log.md) likely include `facility_id` scope checks only. Each must be
reviewed and updated.

**TODO:** Review all Supabase migration files in `supabase/migrations/` to
enumerate existing policies before writing the new migration. Do not delete
existing policies — extend them.

### New table policies summary

| Table | Policy type | Condition |
|---|---|---|
| `provisioning_tokens` | Enable RLS; no policies (default deny) | — |
| `provisioning_events` | Enable RLS; no policies (default deny for MVP) | — |
| `facilities` | SELECT: owner/admin reads own facility | `id = current_facility_id()` |
| `facilities` | UPDATE setup fields | `id = current_facility_id()` AND `is_active_user_on_active_facility()` |
| `facilities` | INSERT/UPDATE on `provisioning_status`, `crm_facility_reference` | Service-role only (no client policy) |
| `users` | SELECT own row | `id = auth.uid()` (no provisioning_status check) |
| `users` | SELECT other facility users | `facility_id = current_facility_id()` AND `is_active_user_on_active_facility()` |
| All care-ops tables | SELECT / INSERT / UPDATE / DELETE | `facility_id = current_facility_id()` AND `is_active_user_on_active_facility()` AND role check |
| `audit_trail` | INSERT | `facility_id = current_facility_id()` AND `is_active_user_on_active_facility()` |
| `audit_trail` | SELECT | `facility_id = current_facility_id()` AND `is_active_user_on_active_facility()` AND role IN ('owner', 'admin') |
| `audit_trail` | UPDATE / DELETE | None — no client policy (default deny; enforce at database level) |

---

## Non-Goals

This ADR does not define or change:

- Specific SQL migration file syntax or column type definitions — those are
  implementation details verified against the actual schema.
- FamilyUser RLS policies — Phase 2 concern (ADR 0004, ADR 0006).
- Detailed RLS behavior for `suspended` facilities — deferred to the
  billing/suspension feature implementation task.
- Caregiver and admin account creation flows — within the tracker app, not via
  the provisioning API.
- The CRM authentication model — ADR 0005 TODO.
- Offline behavior and IndexedDB access — task 0008. Offline access is
  scoped to the device's IndexedDB queue and is separate from Supabase RLS.
- The native vs. PWA app delivery model — pending ADR candidate.
- HIPAA BAA posture, Title 22 compliance, or regulatory claims.
- Whether `audit_trail` read access for owners requires additional counsel review.

---

## Consequences

**Easier:**
- The security model is simple to reason about: `active` user + `active` facility
  = role-based access; anything else = no care-ops access.
- The atomic activation transaction (ADR 0007 + ADR 0009) means the quarantine
  state is exited in exactly one operation. The RLS gate is passed once.
- Care-ops data integrity is guaranteed: no residents, shifts, or care records can
  exist for a `pending_setup` facility — they can never be written by a client
  session.
- `ProvisioningToken` and `ProvisioningEvent` can never leak to a client session
  regardless of future policy additions — zero client policies, default deny.
- Defense in depth: even if a race or edge case produced a session for a non-active
  user, the RLS layer blocks independently of the application layer.

**Harder:**
- All existing care-ops table RLS policies must be updated to include the
  `account_status` and `provisioning_status` checks. Existing migrations must be
  reviewed and new migration files written.
- The `is_active_user_on_active_facility()` helper performs a cross-table JOIN on
  every RLS policy evaluation. Performance must be verified under production load.
- Suspension-mode read-only access requires a more complex policy set than the
  quarantine model — deferred but not forgotten. Must be designed before commercial
  launch if suspension is a supported product state.
- The `current_facility_id()` helper may need to be introduced or updated depending
  on what already exists in the schema.

---

## Open Implementation TODOs

- **TODO — Review and update existing RLS migrations:** Identify all existing
  care-ops table RLS policies in `supabase/migrations/` and update each to include
  `is_active_user_on_active_facility()`. Must be done before the provisioning
  endpoint is implemented and before real resident data is accepted.
- **TODO — Helper function migration:** Create `is_active_user_on_active_facility()`
  and `current_facility_id()` (or verify/update an equivalent) in a Supabase
  migration file. Verify `SECURITY DEFINER` and `STABLE` attributes are set
  correctly.
- **TODO — Performance profiling for RLS helpers:** Profile `is_active_user_on_active_facility()`
  under realistic concurrent load before commercial launch. Add partial indexes on
  `users(id, account_status, facility_id)` and `facilities(id, provisioning_status)`
  if needed.
- **TODO — `wellness_observations` table:** Confirm whether this is a separate
  Supabase table or part of `care_log_entries` before applying the care-ops
  policy list. Add to migrations if a separate table.
- **TODO — Suspension RLS policy:** Define exact RLS behavior for `suspended`
  facilities (read-only SELECT for active users; block all writes). Deferred to
  the billing/suspension feature implementation task. Must be designed before
  commercial launch if suspension is a supported state.
- **TODO — ProvisioningEvent SELECT for owner/admin:** Decide whether owners/admins
  should be able to read their provisioning event log through the app. If yes,
  add a narrow SELECT policy when the feature is designed.
- **TODO — Family access grants during suspension:** Define whether active
  `FamilyAccessConsent` records allow family reads when a facility is `suspended`.
  Must be resolved before Phase 2 family access is built.
- **TODO — Validate activation transaction atomicity:** Verify at implementation
  time that the activation endpoint wraps the `User.account_status = 'active'`
  and `Facility.provisioning_status = 'active'` updates in a single PostgreSQL
  transaction with the ProvisioningToken row lock before going to production.
- **TODO — `disabled` user session revocation:** Define the mechanism for
  immediately revoking all Supabase Auth sessions for a user when
  `account_status = 'disabled'`. Supabase provides `auth.admin.signOut(userId)`
  (server-side) — this must be called when a user is disabled, not deferred to
  session expiry.
- **TODO — `crm_facility_reference` column-level security:** If Supabase supports
  column-level security (CLS) or column exclusion in SELECT policies, apply it to
  `crm_facility_reference` on `facilities` to ensure it is never returned in client
  queries even if the row-level SELECT policy passes. If CLS is not available,
  the application layer must omit this column in all client-facing API responses.

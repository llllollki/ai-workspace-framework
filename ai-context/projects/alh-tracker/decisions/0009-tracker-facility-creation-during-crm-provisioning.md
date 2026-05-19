# 0009 — Tracker Facility Record Creation During CRM Provisioning

**Date:** 2026-05-19
**Status:** accepted
**Supersedes:** The "TODO — Facility record creation at provisioning" in ADR 0007 Section
— Open Implementation TODOs, and the facility association dependency note in ADR 0008
Section — Request Contract.
**Superseded by:** n/a

## Context

ADR 0007 (accepted 2026-05-18) selected the custom `provisioning_tokens` table as the
tracker-side provisioning mechanism. ADR 0007 Phase 1 Step 3a explicitly deferred a
critical sequencing question:

> "Creates or resolves the tracker `Facility` record. **TODO: whether the tracker Facility
> record is created at provisioning time or must pre-exist is unresolved — see Open
> Implementation TODOs.**"

ADR 0008 (accepted 2026-05-19) specified the CRM-to-tracker API authentication contract
and noted the same dependency:

> "Facility association (dependency on ADR 0007 TODO): This request body does not include
> a tracker Facility ID. How the provisioning endpoint associates the new `User` record
> with the correct tracker `Facility` depends on the resolution of ADR 0007's open TODO…
> This is outside ADR 0008's scope but must be resolved before the provisioning endpoint
> is implemented."

This ADR resolves that blocker.

### The problem

For the tracker provisioning endpoint (ADR 0007) to create a `User` row with
`facility_id = tracker_facility_id`, there must be a tracker `Facility` row with a known
ID. The question is who creates that row, when, and with what data.

### Constraints in scope

1. CRM must remain forward-write-only to tracker. CRM must not read tracker care data
   (ADR 0005 Section 3).
2. CRM may forward-write commercial onboarding data needed to bootstrap a tracker Facility.
   This is explicitly permitted by ADR 0005 Section 4: "CRM-to-tracker provisioning is a
   forward write."
3. The tracker `Facility` record at provisioning time contains no resident care data, no
   shift logs, no wellness observations, no audit-trail events — it is an empty commercial
   onboarding anchor only.
4. The tracker must not return the internal `Facility.id` (a UUIDv4 tracker-internal key)
   to the CRM. An opaque correlation reference suffices.
5. Allocated resident count (CRM's `allowedResidentCount`) must not be conflated with
   licensed capacity (`Facility.capacity`), subscription resident limit, or active
   resident count. These are four distinct concepts.
6. The provisioning flow must be idempotent: a retry for the same facility must not create
   a duplicate tracker `Facility` record.
7. No application code is implemented in this ADR — this is an architecture/design
   decision record only.

---

## Options Considered

### Option 1 — Tracker Facility must pre-exist before provisioning

A tracker `Facility` record is created separately, before the CRM provisioning call, by
some internal mechanism (e.g., a tracker admin interface used by ALH Tracker staff).

**How it would work:** Internal staff first creates the tracker Facility record through
a separate internal admin interface or direct database action. The tracker Facility ID is
then communicated to the CRM provisioning flow out-of-band. The provisioning API call
references this pre-existing Facility.

**Pros:**
- Tracker Facility data (name, address, license number, capacity) can be entered
  accurately before owner activation.
- Provisioning API call is simpler — just links User to an existing Facility.

**Cons:**
- Requires a separate internal admin interface or direct database action to create
  tracker Facilities. No such interface is defined or planned.
- Requires out-of-band coordination between the internal admin step and the CRM
  provisioning step — a manual handoff error surface.
- Increases onboarding friction for ALH Tracker internal staff (two-step process vs. one).
- How the pre-existing tracker Facility ID reaches the CRM provisioning call is undefined
  — the CRM cannot read tracker Facility records (ADR 0005 Section 3).
- Does not unblock the provisioning endpoint without significant additional design.

**Verdict:** Excluded. No defined mechanism for pre-creating tracker Facilities, and the
data flow from tracker-to-CRM violates ADR 0005.

---

### Option 2 — Tracker Facility is created by the provisioning API call (selected)

The same CRM provisioning API call that creates the `User` row and `ProvisioningToken`
also creates (or finds) the tracker `Facility` row. The CRM sends a defined set of
commercial onboarding fields. The tracker endpoint creates a `Facility` in a
`pending_setup` state, then creates the `User` row linked to it.

**How it would work:** CRM includes facility identification fields in the provisioning
request body. The tracker endpoint atomically:
1. Finds or creates a `Facility` row keyed by an opaque CRM facility reference.
2. Creates a `User` row linked to that Facility.
3. Creates a `ProvisioningToken` row.

**Pros:**
- Single provisioning API call handles Facility + User + Token atomically — no extra
  steps for internal staff.
- The CRM already has the commercial facility data (name, city, state, license placeholder)
  — forwarding it to bootstrap a tracker Facility is a natural forward write.
- Idempotent by design: a UNIQUE constraint on `Facility.crm_facility_reference` prevents
  duplicate Facility rows on retry.
- No new internal admin interface is required.
- Aligns with ADR 0005 Section 4's "forward write" principle for CRM-to-tracker
  provisioning.
- The pending tracker Facility has no residents, no care data, no shift logs — the
  CRM/tracker data boundary is fully respected.

**Cons:**
- The provisioning API request body must include facility fields. ADR 0008 request
  contract did not include these — requires an update.
- The tracker `Facility` is created with limited data (name, city, state, license
  placeholder). The owner must complete facility setup (address, ZIP, licensed capacity)
  after activation. A `provisioning_status` field is needed on `Facility` to distinguish
  pending from fully-operational facilities.
- If CRM sends incorrect facility data at provisioning time, the tracker Facility record
  starts with incorrect data. Owner corrects this at setup — no cascading care-data risk
  because the Facility has no residents or shifts yet.

**Verdict:** Selected. Single-step provisioning, idempotent, aligns with the ADR 0005
forward-write principle, no new admin interface required.

---

### Option 3 — Tracker Facility created at owner activation time

The CRM provisioning call creates only the `User` row and `ProvisioningToken`, without
a Facility. The tracker `Facility` is created when the owner clicks the activation link
and completes the activation flow.

**How it would work:** At activation time, the owner is asked to provide initial facility
details. The activation endpoint creates the Facility then, links the User to it, and
completes account activation.

**Pros:**
- Owner provides facility data directly — likely more accurate than CRM-forwarded data.
- No facility data needs to be sent in the CRM provisioning call.

**Cons:**
- The `User` row created at provisioning time has `facility_id = NULL` or requires a
  placeholder — a structural gap that complicates RLS and access control from day one.
- The `ProvisioningToken` row links to a `facility_id` (per ADR 0007 schema) — a NULL
  facility_id breaks this relationship.
- ProvisioningEvent records at provisioning time have no `facility_id` to record — a
  gap in the audit trail.
- If activation fails or the owner never activates, there is no Facility record at all,
  which makes cleanup and audit more complex than a pending Facility that is simply never
  activated.
- Owner activation flow becomes longer (facility data entry + password creation) —
  increased activation friction.

**Verdict:** Excluded. Structural integrity of ProvisioningToken and ProvisioningEvent
requires a Facility ID at provisioning time. Null facility_id is not safe.

---

### Option 4 — Phased approach: stub Facility at provisioning, expand at activation

The CRM provisioning call creates a minimal stub `Facility` (name and CRM reference
only, all other fields null/empty). The owner fills in the full facility profile during
the post-activation setup flow.

**Verdict:** This is effectively identical to Option 2 — the distinction between a
"stub" and a "pending_setup" Facility is a labeling choice, not a structural difference.
Option 2 subsumes this approach.

---

## Decision

**Selected: Option 2 — Tracker Facility is created by the provisioning API call.**

The tracker provisioning endpoint creates a tracker `Facility` record in `pending_setup`
state as part of the atomic provisioning action (along with the `User` row and
`ProvisioningToken`). The Facility is keyed by an opaque `crm_facility_reference` field
derived from the CRM's `X-CRM-Facility-Id` header for idempotency.

### Rationale

1. Option 2 is the only option that satisfies structural integrity: `ProvisioningToken`
   and `ProvisioningEvent` both reference `facility_id` and cannot safely hold a NULL.
2. The CRM already holds the commercial facility data (name, city, state, license
   placeholder) from CRM onboarding. Forwarding this to bootstrap a tracker Facility is
   an explicit example of the ADR 0005 forward-write pattern.
3. Idempotency is cleanly achieved via a UNIQUE constraint on
   `Facility.crm_facility_reference` — no separate idempotency mechanism is needed for
   Facility creation.
4. A single provisioning API call keeps internal staff onboarding simple: one action in
   the CRM creates Facility + User + Token atomically.
5. The pending Facility carries no resident care data, no shift logs, no care-operations
   entities — the CRM/tracker data boundary is fully respected.
6. Owner activation and facility setup remain separate concerns: the owner corrects and
   completes facility data (address, ZIP, licensed capacity) in the post-activation setup
   flow.

---

## Facility Creation and Provisioning Sequence

This section supersedes and replaces ADR 0007 Phase 1 Step 3a with a fully specified
Facility creation sub-sequence.

### Provisioning API call (CRM → tracker)

The CRM provisioning API call (`POST /api/provisioning/owner`, per ADR 0008) includes
the facility fields defined in the Allowed CRM-to-Tracker Facility Fields section below.

The tracker endpoint executes the following atomically (within a single database
transaction):

**Step 3a-i — Find or create tracker Facility:**
1. Look up a `Facility` row by `crm_facility_reference = X-CRM-Facility-Id` (from the
   request header).
2. If found: use the existing Facility. This is a retry of a previously provisioned
   facility — do not create a duplicate. Skip to Step 3a-ii.
3. If not found: create a new `Facility` row with:
   - `name` = `facility_name` from request body
   - `license_number` = `license_number` from request body (optional; may be null/empty)
   - `city` = `facility_city` from request body
   - `state` = `facility_state` from request body
   - `provisioning_status` = `pending_setup`
   - `crm_facility_reference` = `X-CRM-Facility-Id` (opaque CRM identifier; stored for
     correlation and idempotency; never returned to CRM as tracker's facility_id)
   - All other fields (`address`, `zip`, `capacity`, `alh_partner`, `alh_partner_tier`)
     are NULL or default — to be completed by the owner during facility setup.

**Step 3a-ii — Find or create tracker User:**
Proceed with ADR 0007 Phase 1 Step 3b–3h using the `facility_id` of the Facility found
or created in Step 3a-i.

**Step 3a-iii — ProvisioningEvent:**
The existing `provisioned` event type (ADR 0007) covers the full provisioning action
including Facility creation. No new `facility_created` event type is introduced at this
time. The `facility_id` field in the `ProvisioningEvent` row is set from the Facility
found or created in Step 3a-i.

### Owner activation (no Facility creation)

Owner activation (ADR 0007 Phase 2) does not create a new Facility record. The existing
Facility record (from Step 3a-i) is used. On successful activation:

1. `Facility.provisioning_status` transitions from `pending_setup` to `active`.
   This transition is part of the same activation transaction as `User.account_status`
   transitioning to `active` (ADR 0007 Phase 2 Step 8h).
2. The existing `activated` ProvisioningEvent (ADR 0007) captures this lifecycle change.
   No separate `facility_activated` event type is introduced at this time.

---

## Allowed CRM-to-Tracker Facility Fields

These are the only facility-related fields the CRM may include in the provisioning
request body. All other facility data is collected from the owner after activation.

### Request body additions (provisioning action only)

The following fields are added to the ADR 0008 request body for `action = "provision"`.
They are **not** sent for `action = "resend"` or `action = "revoke"`.

| Field | Type | Required | Notes |
|---|---|---|---|
| `facility_name` | string | Required | Facility's commercial name as recorded in the CRM. Owner may update after activation. Max 200 chars. |
| `facility_city` | string | Required | City. CA only at MVP. Max 100 chars. |
| `facility_state` | string | Required | State abbreviation (e.g., `"CA"`). MVP: always `"CA"`. |
| `license_number` | string | Optional | RCFE license number placeholder from CRM. May be empty/null if not yet recorded. Owner confirms at setup. Max 50 chars. |

**Note:** `X-CRM-Facility-Id` (from the request header, per ADR 0008) is used as the
`crm_facility_reference` for idempotency — it is not duplicated in the request body.

---

## Fields Explicitly Excluded from CRM-to-Tracker Payload

The following fields must never appear in any CRM provisioning request to the tracker,
regardless of what the CRM holds:

| Field / Concept | Reason for exclusion |
|---|---|
| `allocated_resident_count` / `allowedResidentCount` | CRM commercial concept. Not equal to licensed capacity, subscription resident limit, or active resident count. Not applicable to the tracker Facility record at this stage. See Resident Count section below. |
| Subscription tier, subscription start/renewal dates | Commercial metadata. Belongs in CRM only. |
| Payment credentials or payment provider references | Must not leave the CRM/payment provider boundary. |
| Tracker `Facility.id` (UUIDv4) | Does not exist at provisioning time; generated by tracker. Must not be returned to CRM. |
| Tracker `User.id` | Must not be returned to CRM (ADR 0007, ADR 0008). |
| Activation token or token hash | Must not leave the tracker backend. |
| Resident records, care log data, wellness data | Hard constraint — ADR 0005. |
| Facility address (street), ZIP code | Collected from owner at activation/setup, not from CRM. |
| `Facility.capacity` (licensed capacity) | Licensed CDSS-issued capacity — entered by owner at setup, not by CRM. |
| `alh_partner`, `alh_partner_tier` | ALH partner status — set by internal tracker admin if needed; not provisioned via CRM API. |
| `Facility.provisioning_status` | System-managed; never caller-specified. |

---

## Facility Status Lifecycle

A new `provisioning_status` field is added to the `Facility` entity. This field tracks
the facility's operational state through the provisioning lifecycle.

| Status | Description | Transitions |
|---|---|---|
| `pending_setup` | Facility created by provisioning API. Owner has not yet activated their account. No residents, no shifts, no care data. | → `active` on owner activation. → stays `pending_setup` if owner never activates, resend is triggered, or provisioning is revoked. |
| `active` | Owner has activated their account. Facility is operational. Owner completes facility setup (address, capacity, etc.) in the post-activation setup flow. | → `suspended` if account is suspended. |
| `suspended` | Commercial suspension (e.g., billing lapse, admin action). Tracking may continue in read-only mode per product policy. | → `active` on reinstatement. → `closed` on account closure. |
| `closed` | Account permanently closed. Historical records retained per retention policy. | Terminal state. |

**Implementation notes:**
- `pending_setup` is the initial state set by the provisioning endpoint.
- `active` is set by the activation endpoint (ADR 0007 Phase 2), in the same transaction
  that sets `User.account_status = active`.
- `suspended` and `closed` are set by an internal admin/billing action — outside the
  scope of this ADR.
- RLS behavior for `pending_setup` facilities: the owner account (`account_status =
  invited` or `password_pending`) must not have read or write access to care-operations
  data for the facility. Only provisioning-scoped access is needed before activation.
  **TODO: RLS policy for pending_setup state requires implementation-time design.**

---

## Idempotency and Duplicate Prevention

### Facility-level idempotency

A UNIQUE constraint on `Facility.crm_facility_reference` prevents duplicate tracker
Facility records for the same CRM facility.

**Idempotency behavior:**
1. CRM retries a provision request with the same `X-CRM-Facility-Id` and same
   `X-Idempotency-Key`: covered by ADR 0008 idempotency (return stored response).
2. CRM retries a provision request with the same `X-CRM-Facility-Id` but a new
   `X-Idempotency-Key` (e.g., after the first request succeeded but the CRM didn't
   receive the response): the endpoint looks up the existing Facility by
   `crm_facility_reference`. If found and in `pending_setup` state with an active
   `ProvisioningToken` for the same email, returns the existing `provisioning_reference`.
   If found and the owner is already `active`, returns `{ "status": "already_active" }`.
3. CRM sends a provision request for the same email but a different `X-CRM-Facility-Id`:
   treated as a new provisioning action for a different facility. A new Facility is
   created if the email is not already in `active` state for another facility. **TODO:
   whether one owner email may span multiple facilities is unresolved at this time.**

### User-level idempotency (from ADR 0007)

If a `User` row with `email = owner_email` and `account_status IN ('invited',
'password_pending')` already exists, the endpoint returns the existing
`provisioning_reference` without creating a duplicate User or ProvisioningToken.

---

## Relationship Among Resident Count Concepts

Four distinct resident count concepts exist in the ALH Tracker system. They must not be
conflated. This ADR establishes their definitions and responsibilities.

| Concept | Where it lives | Who sets it | Notes |
|---|---|---|---|
| **Licensed capacity** (`Facility.capacity`) | Tracker `Facility` entity | Facility owner (at setup), confirmed against CDSS license | CDSS-issued maximum resident count for the licensed facility. A care-operations field. Entered by owner during facility setup — not at provisioning time. |
| **Subscription resident limit** | CRM entity model (e.g., `CrmFacility.allowedResidentCount`) | ALH Tracker staff in CRM | Commercial subscriber limit configured as part of the subscription. A CRM commercial concept. **Never copied into the tracker Facility record.** |
| **Allocated resident count** | Synonym for subscription resident limit (see above) | ALH Tracker staff in CRM | The current CRM UI uses `allowedResidentCount` as the label. Whether to rename this or split it is a pending CRM design decision (ADR 0005). |
| **Active resident count** | Derived (computed from `Resident` table) | System-computed | The count of `Resident` records where `is_active = true` for a given facility. Computed at query time; not stored as a field. |

### Key rules

1. `Facility.capacity` is NOT set by the CRM provisioning call. It is NULL at
   provisioning time. The owner enters licensed capacity during post-activation facility
   setup.
2. The subscription resident limit (CRM's `allowedResidentCount`) is NOT stored in the
   tracker `Facility` entity. It is a CRM commercial concept. If the tracker needs to
   enforce a resident count limit, it does so through a separate mechanism (subscription
   configuration API or a dedicated subscription entity) — **TODO: resident count
   enforcement mechanism is unresolved and deferred to a future ADR or implementation
   task.**
3. Active resident count is always computed from live `Resident` data. It is never
   stored as a field.
4. None of these four concepts is interchangeable with any other.

---

## Audit and Event Requirements

| Event | Trigger | What is recorded |
|---|---|---|
| `provisioned` (existing) | CRM provisioning call — covers Facility creation, User creation, ProvisioningToken creation atomically | event_type, user_id, facility_id (new Facility's id), performed_by=crm_staff_id, performed_by_type=crm_staff, timestamp |
| `activated` (existing) | Owner completes activation — covers User.account_status → active AND Facility.provisioning_status → active | event_type, user_id, facility_id, performed_by=user_id, performed_by_type=owner, token_id, timestamp |
| `token_revoked` (existing) | CRM staff revokes invitation before activation | Facility.provisioning_status remains `pending_setup`. No new Facility-specific event required. |

**No new ProvisioningEvent types are added by this ADR.** The existing `provisioned` and
`activated` event types are sufficient to audit the Facility lifecycle at this stage.

**Future consideration:** If multi-facility lifecycle events (suspend, close, reopen) are
added, new event types should be added to the ProvisioningEvent ENUM at that time.

---

## Non-Goals

This ADR does not define or change:

- Facility setup flow after owner activation (resident add, shift configuration, caregiver
  accounts). That is covered in `user_flows.md` Flow 0 and Flow 1.
- The RLS policy for `pending_setup` facilities (implementation TODO).
- Whether one owner email can span multiple tracker Facilities (unresolved — see TODO
  above).
- The subscription resident limit enforcement mechanism in the tracker (deferred).
- Account closure or suspension behavior for `Facility.provisioning_status`.
- The CRM authentication model for ALH Tracker internal staff (ADR 0005 TODO).
- The native vs. PWA app delivery decision (pending ADR candidate).
- The transactional email service selection (ADR 0007 TODO).
- Caregiver and admin account creation (within tracker app, not via provisioning API).
- FamilyUser account activation (ADR 0006).
- HIPAA BAA posture, Title 22 compliance, or regulatory claims.

---

## Consequences

**Easier:**
- The provisioning endpoint is now fully specifiable: a single CRM API call atomically
  creates Facility + User + ProvisioningToken with a well-defined set of allowed fields.
- Idempotency is structurally enforced by the `crm_facility_reference` UNIQUE constraint
  — no separate idempotency table entry is needed for Facility creation.
- The CRM/tracker data boundary is fully maintained: the tracker never returns its
  internal Facility ID to the CRM; the CRM never reads tracker care data; the forwarded
  fields are commercial onboarding data only.
- Owner setup is decoupled from provisioning: the owner fills in address, capacity, and
  other operational fields after activation at their own pace.
- The four resident count concepts (licensed capacity, subscription resident limit,
  allocated resident count, active resident count) are now explicitly defined and
  separated. No implementation is required to conflate them.

**Harder:**
- The ADR 0008 request contract requires updating to include the facility fields
  (`facility_name`, `facility_city`, `facility_state`, `license_number`).
- The `Facility` entity requires two new fields: `provisioning_status` (enum) and
  `crm_facility_reference` (unique string). A schema migration is required.
- RLS policies for `pending_setup` facilities require implementation-time design — owner
  accounts in `invited`/`password_pending` state need access only to activation-scoped
  resources, not care-operations data.
- Orphaned `pending_setup` Facility records (created but never activated, revoked by CRM)
  accumulate over time. A cleanup policy is needed but is deferred.
- The `Facility.capacity` field remains NULL at provisioning time. Any system component
  that assumes capacity is always populated must be updated.

---

## Open Implementation TODOs

- **TODO — RLS policy for pending_setup facilities:** The Row Level Security policy for
  tracker Facility records in `pending_setup` state must be designed before the
  provisioning endpoint is implemented. Owners in `invited` or `password_pending` state
  must have no access to care-operations tables. Activation-scoped access only.
- **TODO — Orphaned Facility cleanup:** If a `pending_setup` Facility is never activated
  (owner never clicks the link; CRM revokes the invitation), the tracker Facility record
  remains in `pending_setup` indefinitely. A cleanup policy (e.g., mark as `abandoned`
  after N days of no activation, or soft-delete) is needed before production. Defer to
  implementation.
- **TODO — Multi-facility owner:** Whether one owner email address can be provisioned for
  multiple tracker Facilities is unresolved. The current idempotency model allows the
  same email to be provisioned for a different Facility (different `crm_facility_id`),
  but the business rule (can one owner manage two facilities?) is not decided.
- **TODO — Subscription resident limit enforcement:** The tracker does not currently have
  a mechanism to enforce the CRM's `allowedResidentCount` as a limit on active residents.
  If enforcement is needed, a subscription configuration API or entity is required — defer
  to a future ADR or implementation task.
- **TODO — `Facility.provisioning_status` migration:** The new `provisioning_status` enum
  must be added to the tracker Supabase schema as a migration. Existing Facility records
  (if any exist before this migration) should default to `active`. Migration file required.
- **TODO — `Facility.crm_facility_reference` migration:** The new
  `crm_facility_reference` column with a UNIQUE constraint must be added to the tracker
  Supabase schema. Existing Facility records should have this column set to NULL (nullable
  for facilities created outside the CRM provisioning flow, e.g., directly by internal
  admin or by owner self-signup if that is ever supported).
- **TODO — Provisioning API request body update:** The ADR 0008 request body schema must
  be updated to include the four facility fields defined in this ADR. This is a
  documentation update (ADR 0008 and any derived API spec) plus an implementation
  requirement for the tracker endpoint.
- **TODO — Owner self-signup path:** This ADR assumes all tracker Facility records are
  created via the CRM provisioning flow. Whether a facility owner can self-sign up (create
  a Facility and owner account directly, without CRM provisioning) is undefined. If a
  self-signup path is ever added, it must skip CRM-required fields and handle the
  `crm_facility_reference` column as NULL.
- **TODO — `Facility.provisioning_status` for non-provisioned facilities:** Facilities
  created outside the CRM flow (self-signup, admin action, seed data) should default to
  `active` unless there is a reason to put them in `pending_setup`. This must be defined
  in the schema migration default.
- **TODO — Retry payload conflict behavior:** Idempotency Scenario 2 (same
  `X-CRM-Facility-Id`, new `X-Idempotency-Key`) specifies that the endpoint reuses the
  existing Facility when found in `pending_setup` state. It does not specify what happens
  if the retry body includes conflicting field values (e.g., different `facility_name` or
  `facility_city`). Should the endpoint silently ignore the conflicting fields, log and
  alert, or return a 409 conflict? This behavior must be specified before the provisioning
  endpoint is implemented.
- **TODO — Re-provision when invited User is disabled:** Idempotency Scenario 2 covers
  the case where the Facility is in `pending_setup` and has an active ProvisioningToken
  for the same email. It does not cover the case where the Facility is in `pending_setup`
  but the associated User is in `disabled` state (i.e., the CRM revoked the invitation,
  then attempts to re-provision the same facility). Whether re-provisioning a
  previously-revoked facility is permitted, and what the endpoint returns if it is, must
  be specified before the provisioning endpoint is implemented.

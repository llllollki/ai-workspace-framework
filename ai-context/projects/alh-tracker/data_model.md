# alh-tracker — Data Model

This file defines the intended entity model for alh-tracker. It is a design reference, not an implementation spec. Column types, indexes, and database-specific constraints are defined during implementation (task 0005).

All entities that store care event data must support an audit trail: who created the record, when, for which resident, and in which shift. Edit history must be preserved via the AuditTrail entity. These are non-negotiable requirements.

### Security and Data Protection Notes

**Tenant isolation:** Every entity carries a `facility_id` foreign key. The production API must scope all queries by `facility_id` derived from the authenticated session — never from a client-supplied parameter. One facility's records must be unreachable by any other facility's authenticated users.

**Sensitive data categories:** AllergiesTriggers (life-safety), CareLogEntry (health observations), WellnessObservation (health observations), ResidentContact / hipaa_release_status (PII + privacy-sensitive), FollowUp / ObservedCareTask (potential incident and medication-adjacent notes). These categories may constitute Protected Health Information (PHI) for HIPAA-covered facilities — see `compliance_notes.md` for HIPAA-adjacent risk assessment.

**Encryption at rest:** The production database must have encryption at rest enabled. No application-level field encryption is required at MVP; database-level encryption is sufficient.

**AuditTrail integrity:** The AuditTrail table must be append-only at the database level. No UPDATE or DELETE should be permitted on AuditTrail rows. The `changed_by` User identity reference must be preserved even after that User account is deactivated.

**LocalStorage (prototype only):** The current prototype persists all state to browser localStorage via Zustand's persist middleware. This is not acceptable for real resident data. Production requires a server-side database with API authentication; localStorage must not be used as a primary data store for any sensitive entity.

---

## Entities

### Facility

The RCFE or small care home using alh-tracker.

| Field | Notes |
|---|---|
| id | Primary key |
| name | Facility name |
| license_number | RCFE license number (California CDSS) |
| address | Full address |
| city | City |
| state | State (MVP: CA only) |
| zip | ZIP code |
| capacity | Licensed capacity (CDSS-issued). This is a care-operations field. It is distinct from the CRM-managed "subscription resident limit" (the commercial subscriber limit configured by ALH Tracker staff) and the operational "active resident count" (count of currently active Resident records). All three may differ. The subscription resident limit lives in the CRM entity model, not in this table. |
| alh_partner | Boolean — whether this facility is an AssistedLivingHelp facility partner |
| alh_partner_tier | Optional — reflects ALH listing tier (Starter, Growth, Concierge) or null |
| created_at | Timestamp |

---

### User

A person with access to alh-tracker for a given facility.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| name | Display name |
| email | Login email |
| role | See Role enum below |
| account_status | See AccountStatus enum below — tracks lifecycle for owner accounts provisioned via CRM (per ADR 0006, proposed). May not be needed as a separate field if Supabase Auth email confirmation state is used instead — see TODO below. |
| is_active | Boolean |
| created_at | Timestamp |
| created_by | Foreign key → User (admin who created this account) |

#### Role Enum

| Role | Description |
|---|---|
| `owner` | Full access: facility setup, billing, reports, all logs, user management |
| `admin` | Similar to owner; typically a house manager role |
| `caregiver` | Can log shift events; cannot modify resident setup or billing |
| `med_tech` | Can log observed care tasks; same event-log access as caregiver |

Role granularity may be refined based on design partner feedback. See `ai_memory.md`.

#### AccountStatus Enum (proposed — ADR 0006)

Tracks the activation lifecycle for owner accounts provisioned via CRM.

| Status | Notes |
|---|---|
| `invited` | Account created by CRM provisioning action; owner has not yet clicked the activation deep link |
| `password_pending` | Owner clicked the deep link; activation flow in progress; password not yet set |
| `active` | Owner completed activation; account is fully active |
| `disabled` | Account disabled (account closure or ALH Tracker staff action) |

**Provisioning mechanism (ADR 0007 — accepted):** The custom `provisioning_tokens` table approach (Option B) has been selected as the provisioning mechanism. `account_status` is tracked in the tracker `User` table, not via Supabase Auth's email confirmation state. The Supabase Auth user (`auth.users` entry) is created at activation time only — not at provisioning time. See ADR 0007.

**CRM-to-tracker API authentication (ADR 0008 — accepted):** The CRM authenticates to the tracker provisioning endpoint using a rotating static API key (MVP), stored server-side only in Vercel environment variables. The tracker stores only the SHA-256 hash of valid keys. Phase 2 hardening path: short-lived HMAC-signed service JWT. The CRM must never receive the tracker Supabase service-role key. See ADR 0008.

**TODO:** Whether this lifecycle applies to all User records or only to owner accounts provisioned via CRM is unresolved. Caregiver and admin accounts created directly within the app may bypass this lifecycle and be created as immediately active.

---

### ProvisioningToken (specified — pending implementation; ADR 0007)

An activation token stored as part of the tracker-side provisioning flow. The custom `provisioning_tokens` table approach (Option B) was selected in ADR 0007 over the Supabase Auth invite API. The Supabase Auth user is not created at provisioning time — it is deferred to activation.

**Token security requirements (ADR 0006 + ADR 0007):**
- Opaque: 32 cryptographically random bytes encoded as lowercase hex (64 chars). Never base64url.
- Expiring: 72 hours from creation (`expires_at = created_at + 72h`). Can be set to `NOW()` for immediate invalidation (resend or revocation).
- One-time-use: `used_at` set atomically at successful activation; lookup always includes `AND used_at IS NULL`.
- Hashed storage: SHA-256 hash of the raw token stored in `token_hash`. The raw token is never stored server-side.
- URL: `https://[tracker-domain]/activate?t=[raw_token]`. No facility IDs, user IDs, resident IDs, or identifiable data in URL.
- Lookup: constant-time comparison to prevent timing attacks.

| Field | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| user_id | UUID FK | → User (the invited owner account) |
| facility_id | UUID FK | → Facility |
| token_hash | TEXT | SHA-256 hex digest of the raw token. Raw token never stored. |
| expires_at | TIMESTAMPTZ | Token invalid after this time. Set to NOW() + 72h at creation; set to NOW() to expire immediately (resend/revocation). |
| used_at | TIMESTAMPTZ | NULL until activation completes. Set atomically at successful activation. |
| created_at | TIMESTAMPTZ | Record creation time. |

**Access control:** This table must not be accessible via client-side Supabase queries. All reads and writes must go through tracker backend server-side functions with service-role access. RLS must deny all client-originated access.

**Resend behavior:** Previous active token is expired (`expires_at = NOW()`); a new token is generated. Rate limit: maximum 3 resends per 24 hours per owner account (TODO: exact implementation pending).

**Revocation behavior:** CRM staff action. Active token expired (`expires_at = NOW()`); `User.account_status` set to `disabled`.

---

### ProvisioningEvent (new — append-only audit table; ADR 0007)

Append-only record of all provisioning lifecycle events for CRM-initiated owner account provisioning. Separate from `AuditTrail` because provisioning is an account lifecycle concern, not a care-operations entity. Follows the same append-only constraint as `AuditTrail`: no UPDATE or DELETE permitted at the database level.

| Field | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_type | ENUM | `provisioned`, `token_resent`, `token_revoked`, `token_expired_passive`, `activated`, `activation_failed` |
| user_id | UUID FK | → User (the owner being provisioned) |
| facility_id | UUID FK | → Facility |
| performed_by | TEXT | CRM staff identifier (CRM-triggered events) or tracker user_id (owner activation). Opaque reference. |
| performed_by_type | ENUM | `crm_staff` or `owner` |
| token_id | UUID FK nullable | → ProvisioningToken.id. Null for passive events (e.g., `token_expired_passive`). |
| metadata | JSONB nullable | Additional context (e.g., failure reason for `activation_failed`). Must not contain PHI, care data, raw tokens, or facility care identifiers. |
| created_at | TIMESTAMPTZ | Event timestamp. Append-only — no updates or deletes permitted. |

**Access control:** Same database-level enforcement as `AuditTrail`: revoke UPDATE and DELETE on this table from the application user; use a write-only role for inserts.

---

### Resident

A person receiving care at the facility.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| display_name | Name shown in UI (privacy-aware display; may be first name or initials) |
| room | Room or unit identifier |
| is_active | Boolean — soft delete; records retained after resident departs |
| care_notes | Optional general care context visible to caregivers on shift |
| created_at | Timestamp |
| created_by | Foreign key → User |

**TODO — Resident identity expansion:** The following fields are documented as part of the resident identity profile but are not yet modeled on the `Resident` entity: `legal_name` (optional), `preferred_name`, `resident_phone` (optional), `move_in_date`, `approximate_age`. These require a data model update pending design review.

**TODO — DOB:** Date of birth is deferred pending data minimization review and counsel sign-off. DOB combined with name and care-facility association is PHI-adjacent regardless of covered-entity status.

**TODO — Archive / deactivate fields:** The deactivate/archive flow (see `user_flows.md` Flow 1c) requires fields not yet on the `Resident` entity: `deactivated_at` (timestamp), `deactivated_by` (Foreign key → User), `deactivation_reason` (optional free text), and corresponding `reactivated_at`/`reactivated_by` fields. These require a data model update.

**TODO — Resident status enum:** Whether `is_active` remains a boolean or is replaced with a status enum (`active`, `inactive`, `archived`) is pending design review.

---

### ResidentPreferences

Per-resident preference record. One record per resident. Upsert on save.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| food | Free text — dietary needs, restrictions, preferences |
| activity | Free text — preferred activities and routines |
| communication | Free text — communication style, language, hearing, approach |
| wake_time | Free text — e.g., "7:00 AM" |
| sleep_time | Free text — e.g., "9:00 PM" |
| personal_care | Free text — bathing, dressing, grooming preferences |
| general_notes | Free text — other preferences |
| updated_at | Timestamp |
| updated_by | Foreign key → User |

---

### AllergiesTriggers

Per-resident allergy and behavioral trigger record. One record per resident. Upsert on save.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| allergies | Free text — list of allergies with severity notes |
| sensitivities | Free text — food, environmental, product sensitivities |
| behavioral_triggers | Free text — situations or actions that cause distress |
| calming_support | Free text — what helps when the resident is distressed |
| updated_at | Timestamp |
| updated_by | Foreign key → User |

Allergies field is displayed as a warning banner on the resident profile and in the activity log. Strings containing "severe" or "anaphylaxis" trigger red styling; others trigger amber.

**TODO — Safety alerts expansion:** The following safety-related fields are documented in the resident profile field groups (see `features.md`) but are not yet modeled in the `AllergiesTriggers` entity or anywhere else: `fall_precaution_flag` (caregiver-noted indicator — not a clinical fall risk assessment), `wandering_precaution_flag` (caregiver-noted indicator — not a clinical elopement risk assessment), `swallowing_eating_assistance_context` (caregiver-noted eating and swallowing assistance context — not a clinical dysphagia assessment or diet order), `critical_safety_notes` (free text operational safety context). These fields require a data model update — either an extension of `AllergiesTriggers` or a new `ResidentSafetyAlerts` entity pending design review.

---

### RoomChecklist

Daily room check record per resident. One record per resident per calendar day. Upsert within the same day.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| check_date | YYYY-MM-DD string — the calendar date of the check |
| room_made_up | Boolean |
| sheets_changed | Boolean |
| note | Optional free text |
| completed_at | Timestamp — set when room_made_up is first checked |
| completed_by | Foreign key → User (null if not yet completed) |
| created_at | Timestamp |
| created_by | Foreign key → User |

Incomplete rooms (`room_made_up = false`) surface on the dashboard and in the handoff summary.

---

### AppointmentTransport

Per-resident transport record for a specific appointment. One record per appointment. Multiple records per resident allowed.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| appointment_label | Short description of the appointment (e.g., "Cardiology follow-up") |
| appointment_datetime | Timestamp |
| pickup_time | Timestamp — when transport is expected to pick up the resident |
| pickup_status | See PickupStatus enum below |
| transport_contact | Free text — transport provider name and phone |
| return_status | See ReturnStatus enum below |
| returned_at | Timestamp (null until returned) |
| note | Optional free text |
| created_at | Timestamp |
| created_by | Foreign key → User |

#### PickupStatus Enum

| Status | Notes |
|---|---|
| `not_scheduled` | No transport scheduled yet |
| `scheduled` | Pickup scheduled and confirmed |
| `waiting` | Resident is ready, waiting for pickup |
| `picked_up` | Resident has been picked up |
| `missed` | Transport arrived but resident could not attend, or transport did not arrive |
| `cancelled` | Appointment cancelled |

#### ReturnStatus Enum

| Status | Notes |
|---|---|
| `not_returned` | Resident has not yet returned |
| `returned_family` | Returned by family member or friend |
| `returned_transport` | Returned by transport service |
| `returned_other` | Returned by other means |
| `cancelled` | Cancelled — no return expected |

Dashboard surfaces: missed pickups today, upcoming pickups today, residents not yet returned (picked_up + not_returned). Handoff summary surfaces transport status per resident.

---

### ResidentContact (updated — no longer stub only)

Previously documented as a family-access stub. As of 2026-05-11, ResidentContact has been implemented in the live app as the main contact / HIPAA release status record per resident. One record per resident. Upsert on save.

Note: The FamilyAccessConsent stub remains deferred (Phase 2). The current ResidentContact implementation covers operational contact information only and does not implement family portal access.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| contact_name | Primary contact's display name |
| relationship | Relationship to resident (e.g., "Daughter", "Son", "Spouse", "Niece") |
| phone | Contact phone number |
| email | Contact email |
| hipaa_release_status | See HipaaReleaseStatus enum below |
| hipaa_note | Free text — facility-recorded note about release status |
| updated_at | Timestamp |
| updated_by | Foreign key → User |

#### HipaaReleaseStatus Enum

| Status | Notes |
|---|---|
| `unknown` | Status not recorded |
| `not_on_file` | Release not on file |
| `on_file` | Release on file at facility |
| `expired` | Release was on file but has expired |
| `not_required` | Not required or other situation |

This is an operational tracking field only. It records the status observed and noted by facility staff. It is not legal validation of a release. No compliance claims are made. Having a `ResidentContact` record with `hipaa_release_status = on_file` does not substitute for a `FamilyAccessConsent` grant — these are separate records with separate purposes.

**TODO — Multi-contact model:** The `ResidentContact` entity is currently defined as one record per resident (single main contact). The resident profile documentation (see `features.md`) describes a multi-contact model with multiple contacts per resident, each with a priority/order field, emergency contact flag, and emergency decision note. Changing to a one-to-many model requires a structural data model update. The emergency contact flag and emergency decision note fields are not yet modeled.

---

### ResidentMobility (TODO — Not Yet Implemented)

Caregiver-recorded operational mobility and assistance context per resident. Not a clinical assessment. One record per resident. Fields, implementation details, and entity name are pending data model design review.

Planned field groups (see `features.md` Mobility/Assistance section):
- Wheelchair use (notes)
- Walker / cane / assistive device (type and conditions)
- Transfer assistance level (e.g., Independent, Standby, One-person, Two-person)
- Standing assistance level
- Two-person assist flag
- Lift / mechanical lift note
- Fall precaution instructions (distinct from the safety alerts flag)

**TODO:** Schema, entity name, and relationship to `AllergiesTriggers` (which may absorb some safety-oriented fields) are unresolved.

---

### ResidentDailyCare (TODO — Not Yet Implemented)

Caregiver-recorded operational daily care and routine context per resident. Not a clinical care plan. One record per resident. Fields and implementation details are pending data model design and counsel review.

Planned field groups (see `features.md` Daily Care / Routine Context section):
- Bathing (preferences, assistance level)
- Dressing (preferences, assistance level)
- Toileting (routine, assistance needs)
- Continence context (caregiver-noted — not a clinical status or diagnosis)
- Diet preferences
- Hydration prompts
- Sleep routine
- Communication / language / hearing / vision notes

**TODO:** Some of these fields overlap with `ResidentPreferences` (which has `food`, `communication`, `wake_time`, `sleep_time`, `personal_care`, `general_notes` as free-text fields). Whether to extend `ResidentPreferences` with structured fields or create a separate `ResidentDailyCare` entity is an open design question. Counsel input on whether ADL (activities of daily living) fields increase PHI/privacy risk is also pending.

---

### Routine

A recurring expected event for a resident within a shift period (e.g., Breakfast, Morning Medications, Evening Walk).

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| category | See Log Category enum |
| label | Human-readable label (e.g., "Breakfast", "Morning Meds") |
| shift_period | Which shift(s) this routine appears in (`morning`, `evening`, `night`, `all`, or facility-configured label) |
| is_active | Boolean |
| created_at | Timestamp |
| created_by | Foreign key → User |

---

### Shift

A defined time block for a facility (e.g., 7am–3pm Morning, 3pm–11pm Evening, 11pm–7am Night).

Whether shift periods are fixed time windows or operator-configured is an open design question — see `ai_memory.md` and task 0003.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| shift_date | Date of the shift |
| shift_period | `morning`, `evening`, `night`, or a facility-configured label |
| started_at | Timestamp when the shift was opened |
| closed_at | Timestamp when the shift was closed (null if still open) |
| closed_by | Foreign key → User (null if not yet closed) |
| created_at | Timestamp |
| created_by | Foreign key → User (who opened the shift) |

---

### CareLogEntry

A single logged event for a resident during a shift.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| shift_id | Foreign key → Shift |
| resident_id | Foreign key → Resident |
| routine_id | Foreign key → Routine (null for ad-hoc entries) |
| category | See Log Category enum |
| status | See Status enum |
| note | Optional free-text note |
| logged_at | Timestamp of the observed event |
| created_at | Timestamp the record was written to the database |
| created_by | Foreign key → User |
| edited_at | Timestamp of last edit (null if never edited) |
| edited_by | Foreign key → User (null if never edited) |

#### Log Category Enum

| Category | Notes |
|---|---|
| `meal` | Meal intake observation |
| `hydration` | Fluid intake observation |
| `sleep` | Sleep quality or duration note |
| `pain_mood` | Pain, mood, or behavior observation |
| `activity` | Physical activity or exercise |
| `general` | Free-form general observation |
| `incident` | Fall, injury, or reportable incident |
| `observed_care_task` | Links to an ObservedCareTask record |

#### Status Enum

| Status | Notes |
|---|---|
| `done` | Completed normally |
| `partial` | Partially completed |
| `refused` | Resident declined |
| `skipped` | Skipped by caregiver this shift |
| `needs_followup` | Requires follow-up action |
| `unknown` | Caregiver could not determine |
| `not_applicable` | Not applicable this shift |

Not all statuses apply to all categories. Appropriate subset per category is a product/UX decision.

---

### ObservedCareTask

An observed care task record linked to a CareLogEntry. Used for medication and supplement observations in MVP.

**MVP boundary:** These are caregiver observations only. This entity does not represent a medication administration record (MAR). Do not model dose validation, prescribing, drug interaction checking, or pharmacy workflow at this stage. See `compliance_notes.md`.

| Field | Notes |
|---|---|
| id | Primary key |
| care_log_entry_id | Foreign key → CareLogEntry |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| task_label | Human label (e.g., "Morning Medications", "Evening Supplements") |
| observed_at | Timestamp |
| created_by | Foreign key → User |

---

### FollowUp

A follow-up item generated from a care log entry that requires attention in a future shift or by the owner/admin.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| shift_id | Foreign key → Shift (originating shift) |
| care_log_entry_id | Foreign key → CareLogEntry |
| resident_id | Foreign key → Resident |
| description | Text description of the follow-up |
| status | `open`, `resolved`, `escalated` |
| resolved_at | Timestamp (null if not yet resolved) |
| resolved_by | Foreign key → User (null if not yet resolved) |
| created_at | Timestamp |
| created_by | Foreign key → User |

---

### AuditTrail

Append-only record of all create and edit operations on CareLogEntry and ObservedCareTask records.

**This table must be append-only. No row in AuditTrail should ever be edited or deleted.**

Production requirement: the append-only constraint must be enforced at the database level (e.g., revoke UPDATE and DELETE privileges on this table from the application user; use a write-only database role for AuditTrail inserts). Application-level checks alone are not sufficient. The `changed_by` User identity must be preserved even after the referenced User is deactivated.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| entity_type | `care_log_entry`, `observed_care_task` — and see TODO below |
| entity_id | ID of the affected record |
| action | `created`, `edited`, `deleted` |
| changed_by | Foreign key → User |
| changed_at | Timestamp |
| previous_value | JSON snapshot of the record before the change (null for `created` actions) |

**TODO — AuditTrail scope expansion:** The current `entity_type` enum covers only `care_log_entry` and `observed_care_task`. Given the expansion of the resident profile to include safety alerts, mobility, daily care, and family access grants, the following entity types should be added to the `AuditTrail` scope as those entities are implemented:

- `resident` — profile create, deactivate/archive, reactivate
- `resident_preferences` — profile section edits
- `resident_contact` — contact add/edit/remove
- `allergies_triggers` — safety alert changes (life-safety-critical)
- `resident_mobility` — mobility/assistance changes (once entity exists)
- `resident_daily_care` — daily care context changes (once entity exists)
- `family_access_consent` — grant create and revoke (Phase 2)

This expansion is **required**, not optional. Profile changes to safety alerts, emergency contacts, and medication-adjacent notes require an immutable audit record. The `entity_type` enum must be updated when these entities are implemented.

---

## Family Access Stub

The family portal remains deferred from MVP. The architectural decisions governing family access are recorded in ADR 0004 (family access architecture, 2026-05-09) and task 0006. Key constraints: family access is always read-only; access requires explicit operator authorization; access defaults to summary level, not raw notes; all access events must be audited.

**ResidentContact is now a canonical implemented entity** — see the ResidentContact entry in the Entities section above. It covers operational contact information (name, relationship, phone, email) and a facility-recorded privacy release status field (`hipaa_release_status`). The ResidentContact entity is the single definition; there is no separate stub.

Having a ResidentContact record does not authorize family portal access. Authorization, if and when built, would be recorded in a FamilyAccessConsent record. The `hipaa_release_status` field on ResidentContact is an operational tracking field only — it records the status observed and noted by facility staff. It is not legal validation of a release and is not a substitute for a family portal consent grant.

**FamilyUser entity (ADR 0006 — proposed):** ADR 0006 defines `FamilyUser` as the family member's identity record in the Family Member App. A FamilyUser account may be created before the owner/admin approves access. The `FamilyAccessConsent` grant links to a `FamilyUser` record (not to a `ResidentContact` directly). A FamilyUser may or may not have a corresponding `ResidentContact` entry — these are separate records with separate purposes. See `FamilyUser` entity below and `user_flows.md` Flow 12.

### FamilyUser (identity record — proposed, ADR 0006)

The family member's account in the Family Member App. An identity record only — existence does not grant any resident data access.

**Critical constraints (ADR 0004 Section 7, ADR 0006 Section 7):**
- `FamilyUser` is NOT a record in the facility-facing `User` table. This is a hard constraint — adding a FamilyUser to the `User` table violates ADR 0004 Section 7.
- `FamilyUser` is NOT a `FamilyAccessConsent` record. Account existence does not create any authorization to view resident data.
- A `FamilyUser` with no active `FamilyAccessConsent` sees no resident wellbeing data, no care log summaries, no wellness observations, and receives no resident-related notifications.
- `FamilyUser` authenticates through a mechanism separate from the facility-facing `User` authentication.

| Field | Notes |
|---|---|
| id | Primary key |
| email | Required — family member's login email |
| full_name | Required |
| phone | Required |
| relationship_to_resident | Stated relationship (e.g., "Daughter"). Not legally verified. |
| address | Required — TODO: whether required for all accounts or only for identity/relationship context is unresolved |
| account_status | `pending` (account created; no active FamilyAccessConsent yet) / `active` (has at least one active grant) |
| preferred_notification_method | TODO: notification model is unresolved |
| occupation | Optional — TODO: whether needed at all or only for identity context is unresolved (per ADR 0006 Section 6). Must not be labeled to imply legal authority. |
| facility_association | Optional (if known at signup) — TODO: how a family member identifies the correct facility at self-signup (invitation code, facility search, or invitation-only model) is unresolved |
| emergency_contact_role | Optional (if applicable) — must not be labeled to imply legal authority, POA status, or clinical authority (per ADR 0006 Section 6 labeling guardrail) |
| privacy_release_status | Optional (if known or facility-confirmed) — operational tracking field only; not legal validation; must not imply HIPAA validation or consent verification (per ADR 0006 Section 6 labeling guardrail) |
| resident_access_request | TODO: only applicable if request-based access is allowed (per ADR 0006 Section 5). Not collected if family members cannot submit access requests independently. |
| created_at | Timestamp |

**TODO:** FamilyUser authentication model (separate Supabase Auth project/tenant, separate auth table, or other mechanism) is unresolved.

**TODO:** Whether FamilyUsers must be invited by owner/admin before they can create an account, or may self-register independently, is unresolved (ADR 0006).

**TODO:** Optional fields above (occupation, facility_association, emergency_contact_role, privacy_release_status, resident_access_request) are documented in ADR 0006 Section 6 as collection candidates — whether each is implemented and under what conditions is pending Phase 2 design review.

### FamilyAccessConsent (stub)

An explicit operator-granted access record allowing a specific family contact to view specific categories of resident care data. This record is the source of truth for whether a family contact has active access. Not yet implemented — blocked on counsel review of the consent model (task 0006).

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| family_user_id | Foreign key → FamilyUser (the family member being granted access — see FamilyUser entity above). A FamilyUser may or may not also be listed as a ResidentContact; those are separate records. (Per ADR 0006 — proposed.) |
| granted_by | Foreign key → User (must be `owner` or `admin` role — caregivers cannot grant family access) |
| granted_at | Timestamp |
| category_scope | JSON array — which log categories are shared (e.g., `["meal", "activity"]`). `incident` and `observed_care_task` categories require explicit opt-in; not included by default. |
| access_level | Enum: `summary` (default — status-level summary, no raw caregiver notes) or `full_notes` (raw caregiver note text visible — requires explicit selection; counsel review required before this level is built) |
| resident_autonomy_noted | Boolean nullable — null = operator did not record; true = operator noted resident expressed no objection or consented; false = operator noted resident declined or restricted. Records whether the operator considered resident preferences. Does not verify or constitute actual resident consent. |
| resident_autonomy_notes | Optional text — operator may record context (e.g., "Resident verbally agreed 2026-06-01" or "Resident expressed concerns — see facility notes") |
| revoked_at | Timestamp (null if still active) |
| revoked_by | Foreign key → User (null if still active) |

---

---

## CRM Entity Model (Separate Product Surface)

The internal CRM is a separate product surface from the facility tracker app. CRM entities are defined in `src/types/crm.ts` and are completely separate from the tracker app data model. CRM types must never import from `src/types/index.ts` (resident care types).

**Hard constraint:** CRM entities must not be added to the tracker app's Supabase database schema without explicit architecture review. CRM users must have no read access to tracker app care data tables (CareLogEntry, WellnessObservation, ObservedCareTask, FollowUp, etc.). See ADR 0005.

**Current implementation (task 0010 + task 0011):** All CRM data is session-only local state in a Zustand store (`src/store/useCrmStore.ts`) initialized from demo seed data. No Supabase schema changes have been made for CRM. A separate persistence task would be required before CRM data is stored in a database.

### CrmFacility

The primary CRM entity. Commercial facility customer record — not the same as the tracker app `Facility` entity.

| Field | Notes |
|---|---|
| `id` | CRM-generated ID (session UUID) |
| `facilityName` | Facility name |
| `city` | City |
| `state` | State (CA for MVP) |
| `rcfeLicensePlaceholder` | RCFE/license number placeholder — demo only, not validated |
| `allowedResidentCount` | CRM-managed integer. See **Allowable resident count** note below. |
| `onboardingStage` | See CrmOnboardingStage enum |
| `subscriptionStatus` | See CrmSubscriptionStatus enum (placeholder — no real billing) |
| `relationshipSource` | How this facility came into the CRM pipeline |
| `alhPartner` | Boolean — ALH facility partner |
| `ownerContact` | Embedded `CrmOwnerContact` (name, email, phone, preferredContact) |
| `subscriptionStartDate` | Placeholder date string or null |
| `subscriptionRenewalDate` | Placeholder date string or null |
| `trialEndDate` | Trial end date string or null |
| `nextFollowUpDate` | Next scheduled follow-up date or null |
| `internalPriority` | `normal` / `high` / `low` — internal ALH Tracker staff flag |
| `createdAt` | Timestamp |
| `updatedAt` | Timestamp |
| `onboardingChecklist` | Embedded `CrmOnboardingChecklist` (7 boolean fields) |
| `archived` | Boolean — soft delete; archived facilities excluded from pipeline counts |
| `archivedAt` | Timestamp or null — set when archived |

**Allowable resident count distinction (ADR 0005 open question):** The `allowedResidentCount` field is a single integer placeholder. It may represent: (a) licensed facility capacity (CDSS-issued), (b) subscription-tier resident limit (commercial), or (c) active resident count (operational). These may eventually become three separate tracked fields. The current implementation uses one integer and labels it clearly in the UI as "CRM config · not a live care-ops count" to prevent confusion with actual resident records in the tracker app.

### Supporting CRM Entities

| CRM Entity | `src/types/crm.ts` Interface | Notes |
|---|---|---|
| Communications log | `CrmCommunicationEntry` | Call, email, meeting, internal, or support entries per facility. Not to be confused with facility tracker app communications. |
| Support/admin notes | `CrmNote` | Internal notes by ALH Tracker staff. CRM-scoped only. Must not contain resident-identifiable health data. |
| Follow-ups | `CrmFollowUp` | CRM follow-up items (open/done/snoozed) per facility. Distinct from tracker app `FollowUp` (care-operations). |
| Onboarding checklist | `CrmOnboardingChecklist` | Embedded in `CrmFacility`. 7 boolean milestones. |

**TODO — Subscription persistence:** Subscription start/renewal/trial dates are stored on `CrmFacility` but are not editable through the CRM UI. A subscription management task would be needed to make these editable.

**TODO — CRM database schema:** When CRM persistence is implemented, the entity model above should inform the schema. The schema must be in a separate database or schema namespace from the tracker app to enforce the data boundary (ADR 0005). CRM users must not be granted any access to tracker app tables.

**CRM provisioning fields (ADR 0007 — proposed):** The following two fields should be added to `CrmFacility` when CRM persistence is implemented. These are the only provisioning-related fields stored in the CRM.

| Field | Notes |
|---|---|
| `provisioning_reference` | Opaque correlation ID returned by the tracker provisioning API after a successful provisioning call. Not a token, not a tracker user ID, not a care-data reference. For operational correlation only. |
| `provisioning_status` | Enum: `not_started`, `invited`, `activation_pending`, `active`, `revoked`. Managed by CRM; updated based on tracker provisioning API responses. |

**Hard constraint:** CRM must not store the activation token, token hash, tracker User ID, tracker Facility ID, resident IDs, or any resident care data in these or any other fields.

---

## Open Design Questions

See `ai_memory.md` for the current working list. Key unresolved items before task 0005 (finalized data model):

- **Shift model:** Fixed time windows or operator-configured? How are orphaned open shifts handled? (Task 0003)
- **Caregiver authentication:** Individual accounts or shared device PIN? How is individual identity preserved on shared tablets for audit trail purposes? (Task 0003)
- **Role granularity:** The four-role model above may need refinement based on design partner input. (Task 0002)
- **Retention policy:** How long are care log records retained? What happens to records when a resident is deactivated? (Task 0004 / counsel)
- **AuditTrail storage:** Same database in a separate table, or a dedicated append-only store? Trade-offs affect query patterns and integrity guarantees. (Task 0005)

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

**Note on contact identity in the grant:** The `FamilyAccessConsent` stub below uses `contact_id → ResidentContact` as the link between a grant and a specific contact. The relationship between "family user eligible for owner/admin selection in the grant UI" and a `ResidentContact` record is pending Phase 2 design — the grant may be initiated from an existing ResidentContact record or through a separate family user account association model. In either case, family users are not records in the facility-facing staff `User` table (per ADR 0004 and ADR 0005). See `user_flows.md` Flow 12 for the conceptual grant flow description.

### FamilyAccessConsent (stub)

An explicit operator-granted access record allowing a specific family contact to view specific categories of resident care data. This record is the source of truth for whether a family contact has active access. Not yet implemented — blocked on counsel review of the consent model (task 0006).

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| contact_id | Foreign key → ResidentContact (canonical entity — see Entities section) |
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

## CRM Entity Model (Stub — Separate Product Surface)

The internal CRM is a separate product surface from the facility tracker app. It has its own entity model, which is NOT defined in this document. The entities below are named stubs only — no fields, relationships, keys, or data types are defined here. All CRM schema decisions are TODO pending CRM design.

**Hard constraint:** CRM entities must not be added to the tracker app's database schema without explicit architecture review. CRM users must have no read access to tracker app care data tables (CareLogEntry, WellnessObservation, ObservedCareTask, FollowUp, etc.). See ADR 0005.

**TODO — CRM entity model:** Entity names listed for orientation only. Schemas are undefined.

| CRM Entity | Purpose |
|---|---|
| `CRMCustomer` | Commercial customer record for a facility; links to tracker app Facility via opaque reference. Relationship between CRMCustomer and the tracker Facility entity is a design question — TODO. |
| `CRMContact` | Facility owner or primary business contact for the customer account. Not to be confused with `ResidentContact` (which is a care-operations entity for a resident's family/emergency contact). |
| `OnboardingRecord` | Tracks onboarding milestones (agreement signed, instructions sent, first login, etc.). Onboarding status states and step ownership are unresolved. |
| `SubscriptionRecord` | Subscription tier, status, dates, and payment provider reference (opaque ID only — no card or bank details). Payment provider and local data fields are TODO. |
| `AdminNote` | Internal notes by ALH Tracker staff about a customer account. CRM-scoped only; never visible to facility users. Must not contain resident-identifiable health data. |
| `CommunicationLog` | Records of communications between ALH Tracker staff and facility owners. Definition of log structure (call, email, in-app, etc.) is unresolved. |

---

## Open Design Questions

See `ai_memory.md` for the current working list. Key unresolved items before task 0005 (finalized data model):

- **Shift model:** Fixed time windows or operator-configured? How are orphaned open shifts handled? (Task 0003)
- **Caregiver authentication:** Individual accounts or shared device PIN? How is individual identity preserved on shared tablets for audit trail purposes? (Task 0003)
- **Role granularity:** The four-role model above may need refinement based on design partner input. (Task 0002)
- **Retention policy:** How long are care log records retained? What happens to records when a resident is deactivated? (Task 0004 / counsel)
- **AuditTrail storage:** Same database in a separate table, or a dedicated append-only store? Trade-offs affect query patterns and integrity guarantees. (Task 0005)

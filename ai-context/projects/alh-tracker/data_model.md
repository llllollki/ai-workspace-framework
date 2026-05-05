# alh-tracker — Data Model

This file defines the intended entity model for alh-tracker. It is a design reference, not an implementation spec. Column types, indexes, and database-specific constraints are defined during implementation (task 0005).

All entities that store care event data must support an audit trail: who created the record, when, for which resident, and in which shift. Edit history must be preserved via the AuditTrail entity. These are non-negotiable requirements.

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
| capacity | Licensed capacity |
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

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| entity_type | `care_log_entry`, `observed_care_task` |
| entity_id | ID of the affected record |
| action | `created`, `edited`, `deleted` |
| changed_by | Foreign key → User |
| changed_at | Timestamp |
| previous_value | JSON snapshot of the record before the change (null for `created` actions) |

---

## Family Access Stub

The family portal is deferred from MVP, but the data model must anticipate it. The following entities are stubs — they define the association and consent model but are not yet populated in MVP.

See task 0006 for the full family access architecture decision.

### ResidentContact (stub)

An authorized external contact (typically a family member) for a resident.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| name | Contact name |
| relationship | Relationship to resident (e.g., "Daughter", "Son", "Legal Guardian") |
| email | Contact email (for future portal access) |
| phone | Contact phone |
| is_authorized_viewer | Boolean — whether this contact may view care summaries |
| created_at | Timestamp |
| created_by | Foreign key → User |

### FamilyAccessConsent (stub)

A record of explicit consent granted for a family contact to view resident care data.

| Field | Notes |
|---|---|
| id | Primary key |
| facility_id | Foreign key → Facility |
| resident_id | Foreign key → Resident |
| contact_id | Foreign key → ResidentContact |
| granted_by | Foreign key → User (owner or admin who granted access) |
| granted_at | Timestamp |
| scope | JSON — which log categories are shared (e.g., `["meal", "activity"]`) |
| revoked_at | Timestamp (null if still active) |
| revoked_by | Foreign key → User (null if still active) |

---

## Open Design Questions

See `ai_memory.md` for the current working list. Key unresolved items before task 0005 (finalized data model):

- **Shift model:** Fixed time windows or operator-configured? How are orphaned open shifts handled? (Task 0003)
- **Caregiver authentication:** Individual accounts or shared device PIN? How is individual identity preserved on shared tablets for audit trail purposes? (Task 0003)
- **Role granularity:** The four-role model above may need refinement based on design partner input. (Task 0002)
- **Retention policy:** How long are care log records retained? What happens to records when a resident is deactivated? (Task 0004 / counsel)
- **AuditTrail storage:** Same database in a separate table, or a dedicated append-only store? Trade-offs affect query patterns and integrity guarantees. (Task 0005)

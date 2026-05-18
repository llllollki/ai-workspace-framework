# alh-tracker — Features and Product Capabilities

## MVP Scope

The MVP is a shift log and handoff tool for California RCFE operators. The goal is to replace the paper binder.

### Included in MVP

1. **Resident and routine setup** — Owner/admin adds residents and configures their routine schedule per shift period. Required before any logging can happen. Unglamorous but must work well — failed onboarding kills adoption before the first shift.

2. **Resident roster** — Active residents visible to caregivers per shift. Simple and scannable.

3. **Shift log** — Caregivers log routine events and ad-hoc observations for residents during their shift. Logging must take under 10 seconds per event.

4. **Handoff summary** — Auto-generated from shift log data. Exceptions (missed, refused, pain notes, incidents, follow-ups) surface first. Normal events are summarized by category, not listed individually. Caregivers do not write handoffs from scratch.

5. **Routine and event tracking** — Core log categories:
   - Meals (intake observation)
   - Hydration
   - Sleep note
   - Pain / mood / behavior note
   - Activity / exercise
   - General note
   - Observed care tasks (meds/supplements as care-task observations only — see boundary below)
   - Incidents / falls (when relevant to handoff)

6. **Thin owner/admin review** — Owner sees a day-level summary: shifts logged, exception count, open follow-up items. Ability to drill into a shift or resident. Polished analytics dashboard is phase 2.

7. **Audit trail from day one** — Every care log entry records who logged it, when, for which resident, and in which shift. Edits preserve the prior state via AuditTrail. Non-negotiable.

### Medication and Supplement Boundary

For MVP, medication and supplement items are treated only as observed care tasks:

- "Caregiver noted medications given this shift" → logged as a care task with status
- No dose tracking, no medication schedule management, no administration record (MAR)
- No drug interaction checking, prescribing guidance, or clinical monitoring
- No MAR/eMAR compliance claims

The system may evolve toward MAR-adjacent workflows in a later phase — only after compliance and legal review confirms a safe, appropriate path. See `compliance_notes.md`.

---

## Resident Profile and Operational Checklist Scope

These features were added to the live MVP on 2026-05-11, expanding the resident profile from a simple care notes card into a full operational record.

### 1. Preferences

Per-resident preference record: food (dietary needs and restrictions), preferred activities, communication style, wake and sleep times, personal care preferences, and general notes. Editable by owner/admin on the resident profile page.

### 2. Main Contact / HIPAA Release Status

Per-resident main contact: name, relationship, phone, email. Includes a facility-recorded HIPAA/privacy release status field (Unknown / Not on file / On file / Expired / Not required / Other). This is an operational tracking field — it records the status observed by facility staff. It is not legal validation of a release. Editable by owner/admin on the resident profile page.

### 3. Allergies and Triggers

Per-resident allergy and behavioral trigger record: allergies (with severity notes), sensitivities, behavioral triggers, calming/support strategies. Displayed as a prominent warning banner on the resident profile header (visible across all tabs) and as an allergy banner in the Activity Log when that resident is selected. Severe allergies (containing "severe" or "anaphylaxis" in the text) are displayed in red; others in amber.

### 4. Room Made Up / Sheets

Daily room checklist per resident: two booleans (Room made up, Sheets changed) and an optional note. Stores one record per resident per calendar day. Editable inline on the resident Profile tab. Incomplete rooms (room not made up) surface on the dashboard as an operational alert and in the handoff summary under the relevant resident.

### 5. Transport Pickup for Appointment

Per-resident transport records: appointment label, appointment date/time, pickup time, pickup status (Not scheduled / Scheduled / Waiting / Picked up / Missed / Cancelled), transport contact, return status (Not returned yet / Returned by family or friend / Returned by transport / Returned other / Cancelled), returned-at timestamp, and note. Upcoming and missed transport appointments for today surface on the dashboard. Transport status surfaces in the handoff summary per resident. Quick status update buttons allow caregivers to mark pickups and returns without navigating a form.

---

## Resident Profile Management (Owner/Admin)

Facility owners and admins can add, view, update, deactivate/archive, and reactivate resident profiles in the tracker app.

### Owner/Admin Capabilities

- **Add resident:** Create a new resident record. A setup wizard guides owner/admin through the required profile sections before the resident is added to the active roster.
- **View resident profile:** View all profile sections for any resident in their facility.
- **Update profile sections:** Edit individual profile sections independently. Each section has its own edit form. Profile changes are preserved in the audit history.
- **Deactivate/archive resident:** Remove a resident from the active roster without hard-deleting their record. Deactivation preserves all historical shift logs, wellness observations, follow-ups, profile history, and audit trail. An optional reason is recorded at deactivation. Archived residents do not appear on the active shift roster.
- **Reactivate archived resident:** Owner or admin can restore an archived resident to the active roster if appropriate (e.g., temporary hospitalization resolved). Reactivation is audited.
- **No hard delete:** Resident records are not permanently deleted through normal facility operations. Soft delete (deactivate/archive) is the only removal path available to facility operators. Data disposition at account closure is governed by the ToS and counsel-confirmed retention policy.

Caregivers and med techs cannot add, deactivate, archive, or reactivate residents. These actions are restricted to owner and admin roles.

---

### Resident Profile Field Groups

Resident profiles are organized into the following functional sections. Each section is independently editable by owner or admin. Caregivers and med techs have read-only access to the profile sections relevant to their shift operations (safety alerts, mobility, contacts).

#### Identity / Basic Profile

| Field | Notes |
|---|---|
| Display name | Name shown in UI (privacy-aware; may be first name or initials) |
| Legal name | Optional — formal legal name if different from display name |
| Preferred name | What the resident prefers to be called day-to-day |
| Age / approximate age | Resident's current age or approximate age |
| Date of birth | **TODO** — deferred pending data minimization review and counsel sign-off; DOB combined with name and care-facility association is PHI-adjacent regardless of covered-entity status |
| Resident phone | Optional direct contact number for the resident |
| Room / unit | Room or unit identifier |
| Move-in date | Date the resident moved into the facility |
| Status | Active / Inactive / Archived — reflects active roster membership; soft delete only |

**TODO:** Legal name, preferred name, resident phone, and move-in date are not yet modeled as named fields on the `Resident` entity. These fields require a data model update pending design review.

#### Family / Emergency Contacts

Multiple contacts per resident. Each contact record includes:

| Field | Notes |
|---|---|
| Name | Contact's display name |
| Relationship | Relationship to resident (e.g., Daughter, Son, Spouse, Niece, Friend) |
| Phone | Contact phone number |
| Email | Contact email |
| Priority / order | Owner/admin-set contact priority for outreach ordering |
| Emergency contact flag | Designates this contact as an emergency contact |
| Emergency decision note | Facility-recorded operational note only (e.g., "Primary contact for medical decisions" or "Representative on file — see paper records"). This note does not validate or record legal authority. |
| Privacy / release status | Operational tracking field — records the status observed and noted by facility staff. Maps to the existing `hipaa_release_status` enum (`unknown`, `not_on_file`, `on_file`, `expired`, `not_required`). Not legal validation of a release. |

**Important:** Being listed as a family or emergency contact does not automatically grant app access. Family app access requires a separate, explicit family access grant (see Facility-Owner Managed Family Access Grants section below). A contact record with `hipaa_release_status = on_file` does not substitute for a family portal consent grant.

**TODO:** The current `ResidentContact` entity is defined as one record per resident (single main contact model). The multi-contact model above requires a structural change to a one-to-many relationship. Schema design is pending.

#### Safety Alerts

| Field | Notes |
|---|---|
| Allergies | Allergies with severity context; displayed as warning banner (red for severe/anaphylaxis, amber for others) |
| Sensitivities | Food, environmental, or product sensitivities |
| Behavioral triggers | Situations or actions that may cause distress |
| Calming / support strategies | What helps when the resident is distressed |
| Fall precaution flag | Caregiver-noted fall precaution indicator. Not a clinical fall risk assessment. |
| Wandering precaution flag | Caregiver-noted wandering precaution indicator. Not a clinical elopement risk assessment. |
| Swallowing / eating assistance context | Caregiver-noted eating and swallowing assistance context. Not a clinical dysphagia assessment or diet order. |
| Critical safety notes | Free text — caregiver-recorded critical operational safety context visible to all staff |

Safety alert data is life-safety-critical. Allergy and safety alerts are displayed as a prominent warning banner in the resident profile header and in the activity log, regardless of tab.

**TODO:** Fall precaution, wandering precaution, swallowing/eating assistance context, and critical safety notes are not yet modeled as named fields. The current `AllergiesTriggers` entity covers allergies, sensitivities, behavioral triggers, and calming strategies. A safety alerts expansion requires a data model update.

#### Mobility / Assistance

Caregiver-recorded operational assistance context. Not a clinical assessment.

| Field | Notes |
|---|---|
| Wheelchair use | Notes on wheelchair use (e.g., full-time, part-time, independent) |
| Walker / cane / assistive device | Type and conditions of use |
| Transfer assistance | Required assistance level for transfers (e.g., Independent, Standby, One-person, Two-person) |
| Standing assistance | Required assistance level for standing |
| Two-person assist flag | Whether tasks require two staff members |
| Lift / mechanical lift note | Whether a mechanical lift is required; model or context |
| Fall precaution instructions | Specific caregiver instructions for fall precautions (distinct from the safety alerts flag above) |

**TODO:** Mobility and assistance fields are not yet modeled as a named entity. A new entity (e.g., `ResidentMobility`) is needed; schema design is pending.

#### Daily Care / Routine Context

Caregiver-recorded operational routine context. Not a clinical care plan or ADL assessment.

| Field | Notes |
|---|---|
| Bathing | Preferences, schedule, assistance level |
| Dressing | Preferences, assistance level |
| Toileting | Routine, assistance needs |
| Continence | Caregiver-noted continence context; not a clinical status or diagnosis |
| Diet preferences | Food preferences, texture preferences, dislikes |
| Hydration prompts | Preferred fluids, caregiver frequency reminders |
| Sleep routine | Bedtime, wake time, nap habits |
| Communication / language / hearing / vision notes | Caregiver-noted communication approach, preferred language, hearing aids, vision aids |

**TODO:** The `ResidentPreferences` entity currently captures food, activity, communication, wake/sleep times, and personal care in free text. Structured daily care fields (bathing, dressing, toileting, continence, etc.) require a data model update pending design and counsel review.

#### Medication-Adjacent Operational Notes

Caregiver-recorded operational context related to medications and supplements. **This section captures caregiver-observed operational context only. It is not a medication administration record (MAR), electronic MAR (eMAR), or medication history. It does not capture medication names, dosages, schedules, routes, prescribers, or drug interactions. It does not constitute medication documentation under California Title 22 § 87465.** See `compliance_notes.md` for the full medication boundary language.

| Field | Notes |
|---|---|
| Medication-adjacent operational notes | Free text — caregiver-recorded operational context only (e.g., resident's general cooperation with care tasks). No medication names, dosages, or schedules. |

**TODO:** Whether medication-adjacent operational notes should be a standalone named field on `Resident` or a section within `ResidentPreferences.general_notes` is pending data model review and counsel input. The boundary between acceptable operational context and MAR-adjacent content must be confirmed with counsel before this field is implemented.

---

### Resident Setup and Edit Flows

See `user_flows.md` for detailed flow descriptions. Summary:

- **Setup wizard:** Step-by-step creation of a new resident profile. Owner/admin completes required fields and optionally fills additional sections before the resident appears on the active roster.
- **Section-by-section edit:** Owner/admin edits individual profile sections from the resident profile page. Saves are scoped to the section.
- **Deactivate/archive flow:** Owner/admin triggers deactivation, confirms with optional reason; resident is removed from the active roster. All historical data is preserved.
- **Reactivate flow:** Owner/admin restores a deactivated resident to the active roster. Audited.
- **Caregiver read flow:** Caregivers see a read-only safety/mobility/contact summary for each resident. No edit access.

### Audit Expectations for Profile Changes

Profile changes must generate audit records. The following events are in scope:

| Event | Notes |
|---|---|
| Resident profile created | New resident record created by owner/admin |
| Resident profile updated | Any profile section edited |
| Allergies / safety alerts updated | High-priority audit event — life-safety implications |
| Emergency / family contact changed | Contact records added, edited, or removed |
| Mobility / transfer assistance changed | Operational context relevant to shift safety |
| Medication-adjacent notes updated | **TODO:** confirm scope once field is modeled |
| Resident deactivated / archived | Archived by owner/admin; optional reason recorded |
| Resident reactivated | Reactivated by owner/admin |

**TODO:** The current `AuditTrail` entity covers `CareLogEntry` and `ObservedCareTask` only. Profile entity audit (Resident, ResidentPreferences, AllergiesTriggers, ResidentContact, and any new profile entities) must be added to the `AuditTrail` scope. This is a required expansion — profile changes to safety alerts and medication-adjacent notes require an immutable audit record. The `entity_type` enum must be updated accordingly when profile entities are implemented.

---

## UI Design Direction (as of 2026-05-11)

The prototype UI was redesigned (commit `221fe19`) around caregiver clarity principles. Key decisions:

- **Dashboard is "What needs attention today?"** — all alert types (transport, rooms, follow-ups, concerns) consolidated into one unified list with colored urgency dots. Secondary stats and Quick Access moved below. Green "all looking good" state when nothing needs attention.
- **Forms are step-numbered** — Activity Log and Wellness Observations use numbered steps (1. Who? / 2. What? / 3. How? / 4. Note) to make sequence legible with one visual scan.
- **Residents list shows per-resident alert badges** — allergy, open follow-up count, room not made up, transport attention — so caregivers can triage at a glance.
- **Handoff summary has a shift-level header** — stats (entries / exceptions / follow-ups) + a conditional "Shift alerts" amber block for missed pickups, not returned, incomplete rooms — before the per-resident detail.
- **Follow-ups priority filter removed** — resolved items shown at reduced opacity; all priorities always shown (less cognitive overhead on a list caregivers check once per shift).

These are UX decisions that can be revisited after design partner feedback. Nothing was removed — only reorganized.

---

## Production Security Prerequisites

The following controls are not features — they are security and privacy requirements that must be in place before any real resident data is stored. The production backend has migrated to Supabase (PostgreSQL + Auth + RLS) — the pre-Supabase localStorage architecture is superseded. A full production security posture assessment against this checklist is still needed before commercial launch.

**Prototype status (as of 2026-05-11):** The current public prototype at https://alh-tracker.vercel.app displays a fixed "Demo only — do not enter real resident data." amber banner at the bottom of every screen (implemented in `src/components/Layout.tsx`, commit `fa8577a`). This banner must remain visible until all production security controls below are in place and verified.

**Must be in place before real data:**

1. **Authentication** — Email + password login; named accounts for all users; no hardcoded seed users in production. Session tokens in httpOnly cookies, not localStorage.
2. **Session management** — Configurable timeout (8h caregiver, shorter for admin/owner); idle lock for shared tablets; immediate revocation on user deactivation.
3. **Role-based access control** — Server-side enforcement of the four-role model (owner, admin, caregiver, med_tech). Client-side role checks are UI only; never trusted server-side.
4. **Facility-level tenant isolation** — All API queries scoped by `facility_id` from the authenticated session. No cross-facility data access.
5. **Backend and database** — A managed server-side database (Supabase, Neon, or equivalent). Remove Zustand localStorage persistence for all sensitive entities.
6. **Encryption at rest** — Production database with encryption at rest enabled.
7. **HTTPS enforced** — All production traffic; HSTS header; no HTTP fallback.
8. **Audit trail in database** — Append-only AuditTrail table with database-level write constraints; not stored in localStorage.
9. **MFA for owner/admin** — TOTP (authenticator app) required for owner and admin roles at commercial launch.
10. **Data export** — Owner/admin self-service export (CSV or JSON). Export events logged in AuditTrail.
11. **Account closure process** — Documented data disposition per ToS draft Section 4; minimum notice period before deletion.
12. **In-app compliance notices** — Required before commercial launch: incident note disclaimer (logging in alh-tracker does not satisfy § 87211 reporting); observed care task boundary notice (not a MAR/eMAR).
13. **Counsel review** — ToS, BAA posture, retention policy, and account closure terms confirmed by qualified California compliance/privacy counsel.
14. **Backup and recovery** — Automated daily backups with point-in-time recovery; restore tested.
15. **Prototype "demo only" banner** — Visible notice on the current live prototype stating it is demo only and must not receive real resident data.

See `compliance_notes.md` — Security and Privacy Implementation Posture section for the full checklist with current status, data classification, and open counsel questions.

---

---

## Internal CRM (Separate Product Surface)

The internal CRM is a desktop-only tool for ALH Tracker business/admin staff. It is a separate product surface from the facility tracker app and the family member app. CRM users are ALH Tracker staff — not facility owners, caregivers, or family members. The CRM does not expose resident wellness/care logs. See ADR 0005 for the architectural decision.

The CRM MVP is implemented as a separate route tree (`/crm`) within the existing React/Vite app (consistent with the `/family` prototype pattern and ADR 0005). All CRM data is session-only demo state; no Supabase schema changes have been made for CRM. CRM types live in `src/types/crm.ts` (separate from `src/types/index.ts` — no resident care types imported into CRM files).

### CRM Capability Areas — Implemented (Task 0010 + Task 0011)

**Facility customer management — CRM Dashboard (`/crm`)**
- Pipeline summary counts by subscription status (active, trial, pending, paused, canceled) — excludes archived facilities
- Onboarding status counts (prospect, in progress, fully active) — excludes archived facilities
- Open follow-ups list (overdue highlighted) — filtered to active facilities only
- High-priority notes list — filtered to active facilities only
- All-facilities table with link to detail

**Facility list (`/crm/facilities`)**
- Facilities list with search (name, city, owner) and subscription status filter
- Add facility — opens create form modal with all required CRM fields
- Allowable resident count displayed per facility (labeled as CRM config field, not a live care-ops count)
- Archive toggle — shows archived facilities separately; archived facilities are not included in active list or dashboard counts

**Facility create (`/crm/facilities` → Add facility)**
- Form fields: facility name, city, state, RCFE/license placeholder, allowable resident count (required positive integer), owner name, owner email, owner phone, preferred contact, relationship source, subscription status (placeholder), onboarding stage, ALH partner flag, internal priority
- Required field validation; allowable resident count validated as a positive whole number
- Demo-safe placeholder language throughout; no real payment processing

**Facility update (`/crm/facilities/:id` → Edit facility)**
- Edit facility button opens the same form modal pre-populated with current values
- All facility profile fields are editable
- Allowable resident count validated as a positive integer on save
- Notes, follow-ups, and communication log entries are preserved during edit

**Archive facility (`/crm/facilities/:id` → Archive)**
- Confirmation dialog before archiving with explicit notice that CRM archiving does not affect resident care records
- Archived facilities: removed from active pipeline counts; shown only via "Show archived" toggle in facilities list; detail page shows archived banner; edit/archive actions disabled on archived records
- Archive is a soft operation (flag only); records and notes/follow-ups/communications are preserved

**Allowable resident count management**
- Editable via the facility edit form on any active facility
- Validated as a positive whole number
- Displayed with clear label: "CRM config · not a live care-ops count" to distinguish it from resident care data
- TODO (ADR 0005): this field may eventually split into three separate tracked fields — (a) licensed facility capacity (CDSS-issued), (b) subscription-tier resident limit (commercial), (c) active resident count (operational). Current implementation uses a single integer placeholder.

**Facility detail (`/crm/facilities/:id`)**
- Facility profile (name, city, state, license placeholder, allowable resident count, relationship source, subscription dates)
- Owner/operator contact (name, email, phone, preferred contact)
- Onboarding checklist (read-only display; editing via TODO)
- Follow-up management (add, mark done, overdue/today highlighting)
- Support/admin notes (add, edit, priority flag)
- Communication log (add entry by type: call, email, meeting, internal, support)

### CRM Capability Areas — Conceptual / TODO

**Facility records**
- TODO: define customer record lifecycle (active, suspended, churned) beyond the current archive pattern

**Onboarding tracking**
- TODO: onboarding status states and step ownership (staff vs. facility owner self-serve vs. hybrid) are unresolved
- TODO: onboarding checklist items not yet editable through the CRM UI

**Subscription and payment status**
- TODO: payment provider identity and which fields are stored locally vs. held by the provider are unresolved
- Subscription start/renewal/trial dates are stored but not yet editable through the CRM UI

**Communications log**
- "Communications log" definition (email threads, call logs, in-app messages) is partially resolved — current implementation supports: call, email, meeting, internal note, support entry types

**Support/admin notes**
- Internal notes by ALH Tracker staff — implemented. Must not contain resident-identifiable health data.

**TODO — CRM roles:** What roles exist within the CRM (sales, onboarding, support, billing, admin) is unresolved.
**TODO — CRM authentication:** CRM user auth model is pending CRM design (per ADR 0005). Route is currently unguarded in demo prototype mode.

**Onboarding tracking**
- Record onboarding status after facility owner signs the ALH Tracker agreement
- Track onboarding milestones: agreement signed, app install instructions sent, first login, first resident added
- TODO: onboarding status states and who owns each step (internal staff vs. facility owner self-serve vs. hybrid) are unresolved

**Subscription and payment status**
- Track subscription tier and status (active, trial, suspended, cancelled)
- Store subscription start date and renewal date
- Record payment status against subscription
- Do not store raw payment credentials (card numbers, bank account details) — payment provider boundary applies
- TODO: payment provider identity and which fields are stored locally vs. at the provider are unresolved

**Communications log**
- Record interactions between ALH Tracker business staff and facility owners
- TODO: "communications log" definition (email threads, call logs, in-app messages, or other channels) is unresolved

**Support/admin notes**
- Internal notes by ALH Tracker staff about a customer account
- Scoped to CRM users only; not visible to facility owners or caregivers
- Must not contain resident-identifiable health data

**TODO — CRM roles:** What roles exist within the CRM (e.g., sales, onboarding, support, billing, admin) is unresolved.

---

## Facility-Owner Managed Family Access Grants (Phase 2)

> **Phase 2 feature — not yet implemented.** Family access grants are a planned Phase 2 capability. Implementation is blocked on counsel review of the consent model, relationship verification requirements, and the Phase 2 family member app design. See `ai_memory.md` open questions, ADR 0004, and `compliance_notes.md` Family Access and Consent Posture section.

Facility owners and admins can grant specific family members read-only access to an approved wellbeing view for a specific resident. This grant is managed within the facility tracker app by the facility operator — it is not self-service for family members.

### Family User Eligibility

A family user becomes eligible to appear in the owner/admin's grant flow only after completing an invitation, verification, or approved onboarding process associated with the facility.

**TODO:** The exact mechanism by which a family user becomes associated with a facility for selection purposes (e.g., invitation by the owner from a contact record, email verification flow, separate family app onboarding) is unresolved and pending Phase 2 design and counsel review.

**Important — family users are not facility staff users:** Family users are not records in the facility-facing staff `User` table. The family member app is a planned separate Phase 2 mobile/tablet surface with its own authentication model (per ADR 0004 and ADR 0005). Family contacts listed in a resident's emergency contacts are not automatically eligible for family app access.

### Grant Flow (Conceptual — Phase 2)

1. Owner or admin navigates to a resident's profile or a family access management screen.
2. Owner or admin selects the family contact from the eligible users or contacts associated with this resident.
   - **TODO:** The exact UI mechanism (dropdown, list, search) for this selection depends on the family user eligibility model — pending Phase 2 design.
3. Owner or admin confirms the family member's relationship to the resident.
4. Owner or admin completes the resident autonomy step: the system prompts them to note whether they considered the resident's preferences before granting access (`resident_autonomy_noted` per ADR 0004). If the resident expressed concerns or declined, the system surfaces a warning.
5. Owner or admin confirms and submits the access grant. A `FamilyAccessConsent` record is created.
6. The family member receives notification or confirmation (delivery mechanism is TODO).

The grant is recorded in the `FamilyAccessConsent` entity (see `data_model.md`). The grant is resident-specific: a family user may be linked to more than one resident only through separate explicit grants.

### What Family Members Can Access (Approved Wellbeing View)

Family access is **read-only for all wellbeing data**. Family members with an active grant can:

- View an approved wellbeing summary for the specific resident they are granted access to. The scope is controlled by the `category_scope` field in the `FamilyAccessConsent` record — only categories explicitly included in the grant are visible.
- Receive approved notifications for that resident. **TODO:** Notification categories are unresolved.
- Communicate with the facility through approved messaging channels. **TODO:** Communication model (message types, direction, channels, content, moderation) is unresolved.

### What Family Members Cannot See

Family members must not have access to the following, regardless of any grant or scope setting:

| Data | Reason |
|---|---|
| Internal staff notes and raw caregiver notes | Operational content; may contain language families should not see or misinterpret |
| Incident notes (`incident` category) | Always internal; excluded from all default and non-explicit scopes |
| Observed care task notes (`observed_care_task` category) | Medication-adjacent; excluded unless explicitly opted in per ADR 0004 |
| Allergy and safety alert details | Safety-critical operational data; share verbally when needed; not in default family scope |
| Mobility / assistance fields | Not in default family access scope — **TODO:** confirm scope per counsel |
| Daily care / ADL context fields | Not in default family access scope — **TODO:** confirm scope per counsel |
| Medication-adjacent operational notes | Never in family access scope |
| Open operational follow-up descriptions | Internal operational items |
| Staff names or user IDs | Internal workforce data |
| Other residents' data | Grant is strictly resident-specific |
| Audit trail or edit history | Internal compliance records |

### Revocation

Owner or admin can revoke a family access grant at any time. Revocation must be available if:
- The family relationship changes or is disputed
- Consent or authorization changes, including if a resident expresses that they do not want family access
- The owner or admin determines access is no longer appropriate for any reason

Revocations are audited (`FamilyAccessConsent.revoked_at` and `revoked_by`).

### Family Access Audit Expectations

| Event | Notes |
|---|---|
| Family access grant created | Resident, contact identity, scope, access level, and `resident_autonomy_noted` recorded |
| Family access grant revoked | Revoking user and timestamp recorded; reason optional |
| Notification preferences changed | **TODO:** once notification model is defined |
| Family communication access changed | **TODO:** once communication model is defined |

**TODO:** The `AuditTrail` entity must include `family_access_consent` as an `entity_type` when Phase 2 is implemented.

### Role Permissions Summary

| Role | Can add / archive residents | Can edit profile sections | Can grant family access | Can revoke family access | Family access scope |
|---|---|---|---|---|---|
| Owner | Yes | Yes | Yes | Yes | N/A — manages grants |
| Admin | Yes | Yes | Yes | Yes | N/A — manages grants |
| Caregiver | No | No | No | No | N/A |
| Med tech | No | No | No | No | N/A |
| Family member | — | — | — | — | Read-only approved wellbeing view for granted resident(s) |
| Internal CRM / ALH Tracker admin staff | — | — | — | — | Separate surface — must not access resident care data |

---

## Explicitly Deferred (Not MVP)

- Family portal / family-facing summary product — now planned as a separate Phase 2 mobile/tablet app surface; see ADR 0005 and overview.md Product Surfaces. Not included in the facility tracker app codebase at MVP.
- Rich owner/admin analytics dashboard
- True MAR/eMAR compliance or pharmacy integration
- Clinical alerts, risk detection, or AI-generated clinical interpretation
- Diagnosis, medication safety guarantees, or clinical decision support
- Billing, payroll, or staffing workflows
- EHR integrations
- Wearable or device integrations
- Multi-state support (California only at MVP)

---

## Device Support

**Device policy (per ADR 0005):** The facility tracker app and family member app are mobile/tablet-first. Desktop users of these apps are directed to install/open the app on a phone or tablet. The internal CRM is desktop-only. This is a distribution policy — not a security control and not a compliance measure. Whether desktop is fully blocked or shown a soft redirect is TODO. Whether facility owner/admin roles need desktop access for administrative tasks is also TODO.

| Priority | Device | Primary use | Surface |
|---|---|---|---|
| 1 | Caregiver phone | Fastest shift logging | Facility tracker app |
| 2 | Shared tablet | Shift board, handoff review | Facility tracker app |
| 3 | Desktop | Directed to use phone/tablet (TODO: hard block vs. soft redirect) | Facility tracker app |
| 1 | Desktop | CRM customer and onboarding management | Internal CRM |
| 1 | Phone or tablet | Wellbeing view, resident updates | Family member app (Phase 2) |
| — | Desktop | Directed to use phone/tablet | Family member app (Phase 2) |

Responsive web/PWA-first for facility tracker and family apps. Offline behavior spec below (task 0008, 2026-05-09).

---

## Offline Behavior Specification

> Spec produced by task 0008. Requires Technical Architect confirmation before Phase 1 implementation. Design partner site visit (task 0002) should validate WiFi quality assumptions.

### Offline Detection

Two-signal detection: `navigator.onLine` fires immediately on network drop; periodic lightweight ping to `/api/ping` every 30 seconds. Two consecutive failed pings within 60 seconds triggers offline mode regardless of `navigator.onLine` value. Online mode restores when `navigator.onLine` is true AND a ping succeeds.

### Visual Offline State

Persistent amber banner: **"No connection — entries saved locally. Will sync automatically when connected."** Fixed at top of screen — always visible without scrolling. Each entry logged offline receives a pending-sync badge. On reconnect: banner updates to "Syncing [N] entries..." then "All synced" (green, 3 seconds). Sync error state requires active acknowledgment.

### Local Event Queue

IndexedDB-backed. Survives tab close/reopen, browser refresh, device sleep/wake. Queue capacity: 200 entries (full 8-hour shift, 20 residents). Each queued entry stores full payload plus local UUID, queued-at timestamp, and sync status. Queue is never cleared until server confirms the write (HTTP 200/201).

### Pre-Cached Data (Available Offline)

- Current shift's resident roster (names, rooms, is_active)
- Active routines for current shift period
- Today's open shift record (shift_id, shift_period, started_at)
- Current user's profile and role
- Previous shift's handoff summary (read-only, last synced)

Not cached: historical logs beyond current shift, analytics/reports, resident setup/routine configuration.

### Sync Strategy

Optimistic write: entry displayed immediately in local view; marked pending sync. On reconnect: queue flushed FIFO. Batch size: max 10 entries per request. The `logged_at` timestamp (caregiver-set at logging time) is preserved through sync; `created_at` is set server-side. Automatic sync — no manual trigger required. "Sync now" button available as fallback. Failed entries retried up to 3 times (2s, 8s, 30s backoff) before surfacing as sync error.

### Sync Conflict Resolution

**Policy: flag for review. Never auto-merge or auto-discard care observations.**

Two caregivers log the same routine for the same resident while offline: both entries are written to the server. A "Review needed" notice surfaces to the owner/admin in the shift review interface. Both entries are preserved in the AuditTrail. The resolution action is also audited.

Same caregiver logs same routine twice offline: surfaced as a duplicate warning to that caregiver on sync completion. Caregiver confirms or dismisses.

Caregivers are never blocked from logging because of a potential duplicate.

### PWA Requirements

- Service worker: required; scope is the entire app
- App shell (HTML/CSS/JS): cached via Cache API, stale-while-revalidate
- Shift data and event queue: IndexedDB only (not Cache API)
- Background Sync API: **not required** — compatibility is inconsistent on low-cost Android devices (target caregiver demographic). Foreground sync fires automatically on network restore; IndexedDB queue persists if app is closed.
- Install prompt: app is installable; prompt is opportunistic, not required

### Minimum Browser/OS Requirements

| Platform | Minimum |
|---|---|
| Android phone | Chrome 80+ on Android 9+ (2019+); Samsung Internet 12+ acceptable |
| iPhone | Safari on iOS 14+ (2020+) |
| Desktop | Chrome 80+, Firefox 75+, Edge 80+ (any 2020+ browser) |
| Not supported | IE11, legacy WebView |

Required browser capabilities: Service Worker API, IndexedDB, Cache API.

---

## Logging UX Principles

These principles govern every logging interaction in the product. The 10-second target is validated against real caregivers in real shifts — see task 0007.

- Routine event logging should take under 10 seconds, ideally 1–2 taps.
- Default to quick status buttons, not forms.
- Resident and shift context are pre-loaded — caregivers should not repeatedly select them.
- Common statuses: Done, Partial, Refused, Skipped, Needs Follow-up, Unknown, Not Applicable (use the appropriate subset per category).
- Notes are optional. Prompt for a note only on abnormal statuses.
- Normal events should be one tap where safe.
- Support batch logging where appropriate (e.g., "all residents ate breakfast" with exceptions noted).
- Observed care tasks should be slightly more deliberate than routine events — this is a product guard against accidental one-tap medication observations. Still simple, but not one tap.
- Provide a visible undo/correction path for one-tap actions.
- Show offline state visibly (e.g., "saved locally, will sync") — never silently lose work.
- Shift close and handoff generation must have a named, explicit flow.
- One-handed phone use must be considered in all touch target sizing.

### Example Logging Flow — Breakfast

Normal: Tap resident → Tap "Ate Well" → Done.

Exception: Tap "Partial" → Optional quick reason (Low appetite / Nausea / Sleeping / Refused / Away) → Optional note → Done.

### Handoff Auto-Generation

The handoff summary is generated from the shift log. Exceptions rise to the top automatically:

- Missed or refused events
- Pain notes
- Incidents or falls
- Follow-up items flagged during the shift
- Observed care tasks with non-Done status

Normal events are summarized by category (e.g., "All 8 residents — Breakfast: 7 Ate Well, 1 Partial — see follow-up").

Caregivers do not write the handoff from scratch.

---

## Recommended Implementation Phases

### Phase 0: Discovery and Setup (Before Any App Code)

- Lock business model and ALH relationship (task 0001)
- Find and engage first design partner (task 0002)
- Define shift model and caregiver authentication (task 0003)
- Conduct Title 22 documentation review (task 0004)
- Finalize MVP data model (task 0005)
- Resolve family access architecture stubs (task 0006)
- Define and validate logging UX with prototype (task 0007)
- Define device and offline behavior requirements (task 0008)

### Phase 1: MVP

- Resident and routine setup flow (owner/admin)
- Shift board with resident roster
- Routine event logging — normal and exception flows
- Observed care task logging
- Handoff summary auto-generation
- Shift close flow
- Thin owner/admin review
- Audit trail on all writes
- Responsive PWA with offline tolerance

### Phase 2: Visibility and Retention

- Family access portal (pending task 0006 architecture)
- Richer owner/admin analytics and export
- Follow-up resolution tracking
- Push/SMS notifications for follow-up items

### Phase 3: Compliance Path

- Evaluate MAR-adjacent workflow requirements
- Compliance/legal review before building
- Structured medication schedules and administration records (only if a compliant path is confirmed)
- Export formats aligned with RCFE documentation requirements

### Phase 4: Expansion

- Multi-state support
- Broader facility type support (adult family homes, board-and-care)
- EHR or pharmacy integration (only after compliance review)

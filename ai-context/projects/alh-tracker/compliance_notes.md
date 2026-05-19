# alh-tracker — Compliance Notes

This file documents the compliance and legal posture for alh-tracker. It is a product and design reference, not legal advice. Qualified counsel should review final workflows, data handling practices, consent language, Terms of Service, and any launch-blocking compliance decisions before they are finalized.

---

## What alh-tracker Is and Is Not

### What it is (MVP)

- A shift log and handoff tool for small RCFE operators.
- A care observation record system: who did what, when, for whom, in which shift.
- An operational productivity tool for caregivers, med techs, house managers, and owners.
- A product designed to not block a future path toward stronger documentation or MAR-adjacent workflows.

### What it is not (MVP)

- A medication administration record (MAR) or electronic MAR (eMAR) system.
- A clinical monitoring or clinical decision support system.
- A diagnosis, risk detection, or medical advice product.
- A regulatory compliance system or official RCFE documentation system under Title 22.
- A certified HIPAA Business Associate — BAA posture is an open question (see below).

This distinction must appear in the Terms of Service, product marketing copy, and where appropriate in-app language, before any facility uses the product with real resident data.

---

## California RCFE / Title 22 Context

California RCFE facilities are licensed and regulated by the California Department of Social Services (CDSS) under Title 22 of the California Code of Regulations (Division 6, Chapter 8).

**This section identifies relevant Title 22 areas for design awareness only. It does not interpret legal requirements. A qualified regulatory or legal reviewer must confirm applicability and scope before any compliance claims are made. See task 0004.**

### Relevant Documentation Categories

| Area | Relevance to alh-tracker |
|---|---|
| Incident reporting | RCFE operators must report certain incidents (falls, injuries, hospitalizations) to CDSS within defined timeframes. Logging an incident in alh-tracker does not satisfy CDSS incident reporting requirements. In-app language must not imply that it does. |
| Resident records | Title 22 specifies content and retention requirements for resident health and service records. alh-tracker care logs are not a substitute for required resident records. |
| Medication management | Title 22 has specific requirements for medication assistance and administration documentation. Observed care tasks in alh-tracker do not satisfy these requirements. This boundary must be explicit in the ToS and in-app UI. |
| Staffing and shift documentation | Shift logs have implications for CDSS compliance. alh-tracker shift logs may serve as useful supporting documentation but are not a substitute for any required staffing records. |

### Design Language Guidance

Do not use the following words or phrases in the product UI or marketing without counsel review and confirmed accuracy:

- "Compliant," "CDSS-compliant," "Title 22 compliant"
- "Regulatory record" or "official documentation"
- "Required documentation"
- "CDSS-approved"
- "Clinical record"

---

## Medication Boundary Language

The following language (or equivalent reviewed by counsel) should appear in the Terms of Service and where appropriate in the product UI:

> alh-tracker is a care observation and shift log tool. Observed care tasks, including medication-related observations, are caregiver observations only. They do not constitute a medication administration record (MAR), an electronic MAR (eMAR), or a clinical documentation system. alh-tracker does not provide dose validation, prescribing guidance, drug interaction checking, or medication safety assurance. Facilities remain responsible for maintaining any medication administration records required by applicable law or regulation.

---

## HIPAA Posture

Many small RCFE and adult family home operators are not themselves HIPAA-covered entities. However:

- If any residents receive Medicare or Medicaid, the facility may have compliance obligations that flow to software vendors handling their data.
- The product stores health-related information about identified individuals.
- A Business Associate Agreement (BAA) posture must be determined before commercial launch.
- This is an open question — see `ai_memory.md`.

Do not make HIPAA claims (positive or negative) in product marketing or ToS without counsel confirmation.

---

## Role Permissions Summary

This section defines the access boundaries for each role in the facility tracker app. Permissions are enforced server-side; client-side role checks are UI only and never trusted.

| Capability | Owner | Admin | Caregiver | Med tech | Family member | Internal CRM / ALH Tracker admin staff |
|---|---|---|---|---|---|---|
| Add / create residents | Yes | Yes | No | No | — | No |
| View resident profiles | Yes | Yes | Yes (read-only) | Yes (read-only) | No | No |
| Edit resident profile sections | Yes | Yes | No | No | — | No |
| Deactivate / archive residents | Yes | Yes | No | No | — | No |
| Reactivate archived residents | Yes | Yes | No | No | — | No |
| Log shift events (care logs, wellness) | Yes | Yes | Yes | Yes | — | No |
| Log observed care tasks | Yes | Yes | Yes | Yes | — | No |
| Grant family access | Yes | Yes | No | No | — | No |
| Revoke family access | Yes | Yes | No | No | — | No |
| Manage user accounts | Yes (owner) | No | No | No | — | No |
| View approved wellbeing view | — | — | — | — | Yes (granted residents only) | No |
| Receive approved notifications | — | — | — | — | Yes (TODO: scope TBD) | No |
| Communicate via approved messaging | — | — | — | — | Yes (TODO: model TBD) | No |
| Access resident care data through CRM | No | No | No | No | — | No — hard constraint per ADR 0005 |

**Notes:**
- Owner and admin have the same permissions for all resident management and family access functions. The owner role additionally covers billing and subscription management.
- Caregivers and med techs have read-only access to resident profile safety, mobility, and contact sections relevant to shift operations. They cannot edit any profile section.
- Family members have access only to the specific resident(s) they have been granted access to, at the scope defined by their `FamilyAccessConsent` record. Access is always read-only.
- Internal ALH Tracker CRM / admin staff are a separate principal class (see ADR 0005). They must not access resident-level care data under any circumstance unless a future explicit support-access policy is approved, reviewed, and enforced. Any such policy would require legal review and technical enforcement — it is not enabled by default.

---

## Data Handling Posture

| Practice | Status |
|---|---|
| Audit trail on all care log entries | Required from day one — non-negotiable |
| Role-based access control | Required from day one |
| Edit history preserved in AuditTrail | Required from day one — AuditTrail is append-only |
| Resident care data not sent to ad/analytics platforms | Required — no exceptions |
| Resident/family sharing requires explicit consent | Required — even though the family portal is deferred |
| Data boundary between alh-tracker and AssistedLivingHelp | Required — resident care data must not flow to the placement side |
| CRM data boundary | Required — resident care data must not flow to the internal ALH Tracker CRM. The CRM manages commercial/onboarding/payment/support metadata only. CRM provisioning of a facility owner's tracker app account is a forward write only — CRM staff gain no access to tracker app care data, resident records, or shift logs by performing this action (ADR 0006). CRM users are ALH Tracker business staff, not facility operators or family members. See ADR 0005 and ADR 0006. |
| Owner activation token security | Required — deep link tokens for owner account activation must be opaque (randomly generated, no embedded data), expiring (defined TTL), and one-time-use. The URL must not contain facility IDs, resident IDs, care data, family IDs, or any identifiable information. Token storage must hash the token value server-side; raw tokens must not be stored. See ADR 0006 and data_model.md ProvisioningToken entity. |
| Family app data boundary | Required — family member access to resident care data is governed by ADR 0004. Access is always read-only, category-scoped, and requires explicit operator authorization. See Family Access and Consent Posture section below. |
| Resident profile data (new field groups) | High sensitivity — mobility/assistance, daily care/ADL context, safety alerts, and medication-adjacent operational notes are PHI-adjacent and must not be stored in localStorage in production. These field groups are subject to the same security controls as existing sensitive entities. |
| Family access grants | Privacy-sensitive — `FamilyAccessConsent` records govern who can access resident data. These records must not be stored in localStorage in production and must be backed by server-side enforcement (row-level security or equivalent). |
| HIPAA BAA posture | Open — must be resolved before commercial launch |
| Retention policy for resident care records | Open — must be defined before launch (task 0004 / counsel) |

---

## Device Redirect Policy Note

The facility tracker app and family member app use a mobile/tablet-first distribution policy: desktop users are directed to install/open the app on a phone or tablet. This is a product distribution decision — it is **not** a security control, access restriction, or compliance measure. It must not be described as a privacy or compliance guardrail in any product documentation, marketing copy, or Terms of Service. Whether desktop access is a hard block or a soft redirect is a UX decision (TODO — see ADR 0005 and `ai_memory.md`). The device redirect does not affect the security controls required before real resident data may be stored (see Security and Privacy Implementation Posture section below).

---

## Privacy Language (Minimum Before Launch)

The following practices must be operational before any real resident data is stored under a commercial relationship:

- Notice at collection: what data is collected, why, and how it is used.
- Facility operator acknowledgment: resident data is tied to the specific facility's account. It is not pooled, aggregated, or used to train models without explicit consent.
- Account termination policy: what happens to resident care records if the facility cancels the service.
- California privacy law (CPPA/CCPA): if operators or family contacts are California residents, consumer rights handling (access, deletion, portability) must be operational at or before commercial launch.

---

## Family Access and Consent Posture

> **PRELIMINARY — NOT LEGAL ADVICE — PENDING COUNSEL REVIEW**
> This section was produced under task 0006 as a product architecture description. It has not been reviewed by qualified California compliance/privacy counsel. Do not treat any statement below as legal guidance. Counsel must review the consent model before any family-facing data access is built.

The family portal is deferred from MVP. When it is built in Phase 2, the following posture governs access:

**What family access is:**
- Read-only access to a filtered, summary-level view of resident care observations.
- Category-scoped: the facility operator selects which log categories a family contact may see.
- Explicitly authorized: access requires an operator action (FamilyAccessConsent record) — it is not on by default.
- Resident-specific: a family user may be linked to more than one resident only through separate explicit grants for each resident.
- Audited: all family access grant and revocation events are logged in the AuditTrail.

**What family access is not:**
- Not a full shift log view by default. Family contacts see summaries, not raw caregiver notes, unless the operator explicitly grants full-notes access (which requires separate counsel review before it is built).
- Not granted automatically by a family relationship. Being listed as a ResidentContact does not authorize data access.
- Not accessible to family contacts for incident notes or observed care task records unless explicitly opted in — these are excluded from default scopes.
- Not available to family members for mobility/assistance fields, daily care/ADL context, medication-adjacent operational notes, or allergy/safety alert details — these are not in the default family access scope. Whether any of these may ever be included in a custom scope is a counsel question (TODO).

**What family members must never see (regardless of grant or scope setting):**
- Internal staff notes and raw caregiver notes
- Incident notes (`incident` log category) — always internal
- Observed care task notes (`observed_care_task` category) — medication-adjacent; excluded unless explicitly opted in per ADR 0004
- Allergy and safety alert field details
- Mobility / assistance field details
- Daily care / ADL context field details
- Medication-adjacent operational notes — never in family scope
- Open operational follow-up descriptions
- Staff names or user IDs
- Any resident's data to which the family member does not hold an active grant
- Audit trail or edit history

**FamilyUser account creation (identity only — no data access):** Per ADR 0006, a family member may create a `FamilyUser` account in the Family Member App before the facility owner/admin has approved their access. Account creation creates an identity record only. A FamilyUser with no active `FamilyAccessConsent` record must not see any resident wellbeing data, care log summaries, wellness observations, or receive any resident-related notifications. The app presents a pending/no-access state after login. No data access is granted by account existence. This is not a compliance exposure if the enforcement layer (FamilyAccessConsent check) is correctly implemented.

**Family access grant flow (conceptual — Phase 2):** Owner or admin initiates the grant from the resident's profile or a family access management screen; selects the FamilyUser from pending requests or by proactive search; confirms the relationship; completes the resident autonomy step (`resident_autonomy_noted`); submits the grant. The grant creates a `FamilyAccessConsent` record. `FamilyUser` records are not records in the facility-facing staff `User` table (ADR 0004 Section 7). See `user_flows.md` Flows 12, 13, and 14, and `features.md` Facility-Owner Managed Family Access Grants section.

**Revocation:** Owner or admin can revoke a family access grant at any time — including if the family relationship changes, if consent or authorization changes, or if the resident expresses that they do not want family access. Revocations are audited.

**Notification scope:** Family members may receive approved notifications for their granted resident. **TODO:** Notification categories are unresolved and must be limited to approved wellbeing/communication events only — not incidents, regulatory events, or operational alerts.

**Communication model:** Family-to-facility messaging is planned to be available through approved channels. **TODO:** Message types, direction, channels, content scope, and moderation/audit requirements are unresolved. Communications must not conflict with ADR 0004's read-only constraint on care data — messaging is a separate data category from care log access. **This feature must not be designed or built before counsel review of content scope, data classification, and moderation requirements is complete.**

**Resident autonomy posture:**
- A competent RCFE resident has autonomy over their personal care information. The consent model requires the operator to note whether they considered the resident's preferences before granting family access (`resident_autonomy_noted` field on FamilyAccessConsent).
- The software records that the operator addressed the question — it cannot enforce or verify actual resident consent. That is the operator's responsibility.
- If the operator records that a resident declined or restricted access, the system surfaces a warning before completing the access grant.
- The product must not imply that a family contact's access right supersedes a competent resident's expressed preference.

**Resident profile data — privacy posture for new field groups:**

The expanded resident profile includes field groups with elevated privacy sensitivity. The following language posture applies to each group:

- **Safety alerts (fall precaution, wandering precaution, eating/swallowing assistance context):** These are caregiver-noted operational indicators — they are not clinical risk assessments, clinical diagnoses, or CDSS-reportable determinations. The in-app labels must use caregiver-operational language, not clinical terminology. Do not use "fall risk assessment," "elopement risk," "dysphagia," or similar clinical terms.
- **Mobility/assistance fields:** These are caregiver-recorded operational assistance context — not a clinical ADL assessment, occupational therapy assessment, or care plan. Do not use "ADL assessment," "functional status," or "care plan" language.
- **Daily care/routine context (bathing, dressing, toileting, continence):** These are caregiver-recorded operational routine notes — not clinical ADL assessments or diagnoses. "Continence context" is acceptable; "continence status," "continence assessment," or "diagnosis" is not.
- **Medication-adjacent operational notes:** See the Medication Boundary Language section above. Every instance of this field in the UI and documentation must include a disclaimer that it is not a MAR, eMAR, or medication record.
- **Emergency decision note on contacts:** This is a facility-recorded operational note only. It does not record, validate, or confirm legal authority. The note field must not be labeled "POA status," "legal guardian status," or any term implying the software validates legal or clinical authority.

These field groups are high-sensitivity data (PHI-adjacent) and must be subject to the same security, access control, and audit requirements as existing high-sensitivity entities.

**Open counsel questions for family access (Phase 2 pre-launch):**
- Does the FamilyAccessConsent model satisfy California privacy law (CPPA/CCPA) for family contacts as California residents?
- What notice must be given to residents at or before account creation about the possibility of family access?
- Can a resident actively revoke a family contact's access through the product — or only the operator can?
- What happens to FamilyAccessConsent records when a resident is transferred or deceased?
- Does sharing incident notes or observed care task notes with family create any independent regulatory or legal obligation for the vendor?
- What consent and disclosure language is required in the Terms of Service before any family portal access is granted?

**Pre-launch requirement:** Compliance / Privacy Counsel must review the consent model (task 0006 Outcome, Section 2), resident autonomy posture (Section 5), and the full-notes access level before any family-facing feature is built or any family contact is given access to resident care data.

---

## Open Compliance Questions

See `ai_memory.md` for the working list of unresolved items. Key items requiring resolution before commercial launch:

- HIPAA BAA posture for RCFE operators whose residents may be Medicare/Medicaid beneficiaries.
- Whether incident/fall log entries create any mandatory reporting obligations for the product vendor (preliminary desk research: obligation appears to rest with licensee; counsel must confirm — see task 0004 Section 6, Question 3).
- Counsel review and approval of Terms of Service and medication boundary language before any resident data is stored.
- Retention and deletion policy for resident care records — specifically: whether CareLogEntry and ObservedCareTask records constitute "resident records" (§ 87506, 3-year retention) or "medication records" (§ 87465, 1-year retention), and what the vendor's obligations are in each case.
- Account closure behavior: what happens to all record categories when a facility account closes.
- Family access consent model — counsel review required before Phase 2 family portal is built (see Family Access and Consent Posture section above).

---

## Security and Privacy Implementation Posture

> **IMPLEMENTATION PLANNING — NOT LEGAL ADVICE — PENDING COUNSEL AND SECURITY REVIEW**
> This section describes the current prototype security state and the controls required before any real resident data may be stored under a commercial relationship. It does not constitute a security certification, HIPAA compliance claim, or legal opinion. A qualified security reviewer and California privacy/compliance counsel must review the final implementation before commercial launch.

### Production Security State (updated 2026-05-16)

> **NOTE: The pre-Supabase prototype state table below has been superseded.** The production deployment at https://alh-tracker.vercel.app now uses Supabase (PostgreSQL + Auth + Row Level Security) as the backend. The localStorage prototype architecture is no longer the production model. See the app `README.md` and `docs/architecture.md` for the current backend architecture. A full production security posture assessment against the 15-item must-have checklist below is needed before any real resident data is accepted under a commercial relationship. Do not use the superseded table below as the current security state.

**Superseded pre-Supabase prototype state table (as of 2026-05-11 — historical reference only):**

| Control | Former Prototype State | Required for Real Data |
|---|---|---|
| Authentication | None — hardcoded seed user | Required — now Supabase Auth (email/password) in production |
| Authorization / RBAC | None — all routes open | Required — now RLS in production; server-side enforcement still needs verification |
| Data storage | Browser localStorage (plaintext) | Required — now Supabase PostgreSQL in production |
| Backend / API | None — static SPA | Required — now Supabase REST API in production |
| Tenant isolation | None — single hardcoded facility | Required — enforced via RLS in production; verify by test |
| Encryption at rest | None (localStorage is plaintext) | Required — Supabase encrypts at rest by default |
| Encryption in transit | HTTPS via Vercel (prototype only) | Required in production — HTTPS enforced |
| Audit trail persistence | localStorage — not integrity-protected | Must be append-only database table — current status: needs verification |
| Session timeout | None | Required — current status: needs verification |
| MFA | None | Required for owner/admin roles — current status: not yet implemented |
| Secrets management | None needed (no backend) | Required — Supabase credentials in Vercel env vars |
| Backup / recovery | None | Required — Supabase automated backups; PITR status needs verification |
| Data export | None | Required before commercial launch — current status: not yet implemented |
| Account closure / deletion | None | Required before commercial launch — current status: not yet implemented |

**The app must not be used with real resident names, care data, allergy records, contact information, or HIPAA-related notes until all "Required" controls above are verified operational.**

### Data Classification

| Data Category | Sensitivity | Rationale |
|---|---|---|
| Resident profile (name, room, care notes) | High | Identified individual in a care setting |
| Care log entries (meals, hydration, sleep, activity, general) | High | Shift-level health observations about identified individuals |
| Wellness observations (pain, mood, behavior) | High | Explicit health status observations |
| Allergies and triggers | High — safety-critical | Life-safety implications; exposure must be strictly controlled |
| Follow-ups and incident notes | High | May document falls, injuries, or reportable events |
| Observed care tasks | High | Medication-adjacent observations |
| Main contact / HIPAA release status | High | PII plus privacy-sensitive status field |
| Appointment / transport records | Medium-High | Schedule and movement PII for care recipients |
| Room checklist | Medium | Daily operational status; low sensitivity individually |
| Audit trail | High — compliance-critical | Integrity evidence; must be immutable |
| User / admin data (name, email, role) | Medium | Personnel PII; controls access to all above categories |

### Required Security Architecture for Production

**Authentication**
- Email + password login with secure credential storage (bcrypt or equivalent hashing; no plaintext passwords)
- Named individual accounts for all active caregivers, med techs, admins, and owners
- Session tokens in httpOnly, Secure, SameSite=Strict cookies — not localStorage
- Session expiry: 8 hours for caregivers; configurable shorter window for admin/owner; idle lock after 30 minutes
- MFA required for owner and admin roles before commercial launch; optional for caregiver at MVP

**Role-Based Access Control (RBAC)**
- Server-side enforcement — not client-side only
- Roles: owner (full access including billing and user management), admin (same as owner minus billing), caregiver (log events; read profiles; cannot modify resident setup), med_tech (same as caregiver scope)
- No caregiver may grant family access (FamilyAccessConsent — Phase 2)
- Role is validated server-side on every API call; client role claims are not trusted

**Facility-Level Tenant Isolation**
- Every API query must filter by `facility_id` derived from the authenticated session token
- `facility_id` is never accepted as a client-supplied query parameter without server validation against the session
- One facility's data must never be readable by another facility's authenticated users
- Test: a caregiver from Facility A must receive a 403 or empty result for any Facility B resource

**Audit Trail**
- AuditTrail must be stored in a database with write-once guarantees
- No UPDATE or DELETE permitted on AuditTrail rows — constraint enforced at database level
- Scope (minimum): CareLogEntry creates and edits, ObservedCareTask creates and edits
- Scope (recommended): ResidentPreferences, ResidentContact, AllergiesTriggers edits also audited
- AuditTrail rows must preserve `changed_by` User identity even after that User's account is deactivated — see counsel question on caregiver identity retention

**Session and Device Security**
- Shared tablet mode: per-session PIN switch with short idle timeout; prior session state must not be accessible after lock
- No session token stored in localStorage
- "Remember me" functionality (if offered) must use a separate, scoped, httpOnly refresh token — not a persistent session cookie with extended expiry

**Password and MFA Policy**
- Minimum password complexity: 12+ characters with at least one each uppercase, lowercase, digit
- Password hashing: bcrypt (cost factor 12) or argon2id
- MFA: TOTP (authenticator app) required for owner and admin at commercial launch
- Account lockout: after 10 consecutive failed login attempts; lockout reset by owner/admin only

**User Deactivation**
- Deactivating a User account must: revoke all active sessions immediately; prevent future login; preserve the User identity record and all `created_by` / `changed_by` AuditTrail references
- Deleted or deactivated caregiver identities must not be anonymized if doing so would break the AuditTrail integrity — pending counsel confirmation (see open questions below)

### Data Protection Requirements

**Encryption in Transit**
- HTTPS required for all production traffic (including API backend)
- TLS 1.2 minimum; TLS 1.3 preferred
- HSTS header on all production domains
- No HTTP fallback — HTTP requests redirect to HTTPS

**Encryption at Rest**
- Production database must have encryption at rest enabled (standard offering from managed database providers: Supabase, Neon, PlanetScale, Railway, etc.)
- No application-level field encryption required at MVP — database-level encryption at rest is sufficient
- If any backup files or exports contain resident care data, they must also be encrypted at rest

**LocalStorage Risk (Prototype → Production)**
- The current Zustand `persist` middleware writes all state to `localStorage` under key `alh-tracker-storage`
- localStorage is plaintext, unencrypted, accessible by any JavaScript running on the same origin, and readable by anyone with physical device access or browser developer tools
- Production replacement plan: remove the Zustand persist middleware entirely; replace localStorage persistence with server-side API calls to the production database; session state (user identity, active facility) stored in httpOnly session cookie only
- The IndexedDB offline event queue described in task 0008 is acceptable for offline log entries in transit — it is temporary write cache only, not a persistent data store; it must be cleared after server confirmation

**Secrets Management**
- No API keys, database credentials, or JWT secrets may appear in client-side code or version control
- Backend secrets (database URL, JWT signing key, external service credentials) stored in environment variables on the hosting provider (Vercel environment variables or equivalent)
- Rotate signing keys on a defined schedule; immediately on suspected compromise

**Backups**
- Managed database with automated daily backups and point-in-time recovery (PITR)
- Backup retention must be at least as long as the counsel-confirmed retention period for the relevant record categories (minimum: 3 years for resident records if § 87506 applies)
- Backups are encrypted at rest
- Backup restore must be tested before commercial launch

**Export Controls**
- Self-service export requires owner or admin role
- Export scope is limited to the authenticated facility's data
- Export events are logged in AuditTrail
- Export format: CSV or JSON (counsel-confirmed format for record portability requirements)
- No batch export of multiple facilities' data permitted

**Deletion and Retention Constraints**
- Deletion is subject to counsel-confirmed minimum retention periods (see ToS draft, Section 3)
- AuditTrail records must not be deleted before their minimum retention period — pending counsel answer
- Account closure data deletion must follow the notice and timeline defined in ToS Section 4 — pending counsel answer

### HIPAA-Adjacent Risk Assessment

The following data stored in alh-tracker may constitute Protected Health Information (PHI) under HIPAA if the facility operator is a HIPAA Covered Entity (CE) or Business Associate (BA):

- Allergy and trigger records (directly health-related for identified individuals)
- Care log entries (health observations: meals, hydration, sleep, pain/mood, incidents)
- Wellness observations
- Follow-up items (may document falls, injuries, or care concerns)
- HIPAA release status field (by name references HIPAA, implies health information context)
- Observed care task records (medication-adjacent observations)

Whether California RCFE operators are HIPAA CEs depends primarily on whether they bill Medicare or Medicaid. Many small 6-bed homes do not. However, this determination is facility-specific and cannot be made by the vendor without counsel guidance.

**Decision points requiring counsel resolution before real data:**
1. Are typical small California RCFE operators (6–20 beds) HIPAA CEs or BAs?
2. Does storage of allergy, wellness, and care observation data for identified residents constitute storage of PHI regardless of CE status?
3. Is a BAA required before storing this data commercially? If yes, what security controls are prerequisites for offering a BAA?
4. What is the minimum security standard (HIPAA Security Rule administrative, physical, and technical safeguards) the vendor must implement before any covered data is stored?

### Must-Have Controls Before Real Resident Data

The following controls must be in place — and verified operational — before any real resident data is stored under any commercial or pilot relationship:

1. **Authentication** — Named login with secure credential handling; no hardcoded or seed users in production
2. **Session management** — httpOnly session cookies; configurable timeout; idle lock for shared tablets
3. **Role-based access control** — server-side enforcement; four roles with defined permission sets
4. **Facility-level tenant isolation** — server-side scoping; verified by test
5. **Backend and database** — API layer with a managed database; no localStorage as primary data store
6. **Encryption at rest** — production database with at-rest encryption enabled
7. **HTTPS enforced** — for all production traffic; HSTS header
8. **Audit trail in database** — append-only table with database-level write-once constraint
9. **User deactivation** — immediate session revocation; AuditTrail identity preserved
10. **Data export** — self-service CSV/JSON export for owner/admin
11. **Account closure process** — documented data disposition; minimum notice period per ToS Section 4
12. **In-app compliance notices** — incident note disclaimer; observed care task boundary notice (see compliance_notes.md, language avoidance list)
13. **Counsel review of ToS** — including BAA posture, retention policy, and account closure terms
14. **Backup and recovery** — automated database backup with PITR; restore tested
15. **Prototype "demo only" banner** — must be visible on the current prototype at alh-tracker.vercel.app to prevent misuse before production controls are in place

### Open Security and Privacy Counsel Questions

These are in addition to the open compliance questions above. All require counsel resolution before commercial launch:

- **BAA**: Is a HIPAA Business Associate Agreement required before storing care observation data for any California RCFE operator? If yes, what security controls must the vendor implement as prerequisites?
- **PHI determination**: Does the combination of resident name + allergy records + care log entries constitute PHI for any RCFE operator (regardless of CE status)?
- **Caregiver identity in AuditTrail**: When a caregiver's account is deactivated (e.g., employment ends), must the User identity record be preserved in AuditTrail references? Or may it be anonymized after a defined period?
- **Breach notification**: What is the required breach notification timeline under California law (CCPA/CPPA breach notification) for a data breach affecting resident care data? Is HIPAA Breach Notification Rule also triggered if any resident is a Medicare/Medicaid beneficiary?
- **CCPA/CPPA for family contacts**: When family access (Phase 2) is built, are family contacts California "consumers" with CCPA/CPPA rights (access, deletion, portability) with respect to information about them stored in the ResidentContact entity?
- **Data minimization**: Are any of the current data fields in the ResidentContact or AllergiesTriggers entities beyond the minimum required, such that collecting them increases risk without clear operational necessity?
- **Security certifications**: Is SOC 2 Type II or any other security certification required or expected by RCFE operators at this scale before they will sign a commercial agreement?

---

## Title 22 Preliminary Research Summary

> **PRELIMINARY RESEARCH — NOT LEGAL ADVICE — PENDING COUNSEL REVIEW**
> This section was produced by desk research under task 0004 and has not been reviewed by qualified California compliance/privacy counsel. Do not treat any finding below as authoritative. All items are pending counsel confirmation before they are used in product decisions, ToS language, or marketing copy.

### Sections Researched

| Section | Topic | Key Finding (Preliminary) |
|---|---|---|
| § 87506 | Resident Records | Separate, current, complete record required per resident. Includes medical assessments, mental/social condition documentation, medication records (current meds and PRN orders), records of illness/injury affecting function. Retention: **3 years** post-service. Confidential; accessible to licensing agency. |
| § 87211 | Incident Reporting | Licensee must report defined incident categories to CDSS, Ombudsman, law enforcement, and/or family contacts within defined timeframes (2 hours to 7 days depending on severity). Written format with specified fields (resident name/age/sex/admission date, nature of event, physician findings, disposition). No specific state form mandated; no explicit vendor reporting obligation in regulation text. |
| § 87465 | Medication Management | Staff may assist with resident self-administration only (not administer). Medication assistance must be documented: date, time, dosage, resident response. Retention: **1 year** (records), **3 years** (destruction records). No separate MAR form explicitly mandated, but required content is specific. |
| § 87411 | Personnel Records | Training documentation, LIC 500 (Personnel Report-Roster), LIC 508 (Criminal Record Statement) required. No explicit shift-schedule or duty-record requirement in § 87411 itself. |

### Data Model Findings (Preliminary)

**Preserve from day one (already in current model — rationale confirmed by research):**
- `logged_at` and `created_at` timestamps on CareLogEntry (timeliness of observation matters in any care record context)
- `created_by` user reference on all record types (caregiver identity accountability)
- Soft-delete (`is_active`) on Resident — hard-deleting resident records would conflict with any retention obligation
- Append-only AuditTrail with `previous_value` JSON snapshots — required pattern for any data subject to regulatory review

**Intentional omissions confirmed correct:**
- Medication name / drug name: must NOT be added to ObservedCareTask without compliance review; adding it approaches MAR territory (§ 87465)
- Medication dosage: same — intentional absence protects the non-MAR boundary
- Physician name / findings: must NOT be added to incident log entries; implies formal incident report (§ 87211) status

**Gaps requiring counsel resolution before task 0005 (data model finalization):**
- Retention period policy: not yet defined in data model; must specify minimum retention per record type
- Account closure behavior: undefined; what happens to all records when a facility account closes
- Caregiver account termination: when a User is deactivated, must identity be retained in AuditTrail or may it be anonymized

### Incident Logging — Preliminary Risk Assessment

The `incident` log category is the highest-risk category from a regulatory misunderstanding perspective. An operator who logs an incident in alh-tracker may believe they have satisfied § 87211 reporting requirements. They have not. The in-product UI must include a plain-language notice at the point of logging an incident entry (see task 0004, Section 5 for approved notice text — pending counsel review).

### Observed Care Task — Preliminary Risk Assessment

The `observed_care_task` category is high-risk from a MAR/eMAR misrepresentation perspective. The current model captures date, time, status, and optional note — but not dosage, medication name, or "response to treatment" in the § 87465 sense. This gap is intentional and protective. The product must not imply that observed care task records satisfy § 87465 documentation requirements.

### Extended Language Avoidance List

In addition to the list in the Design Language Guidance section above, do not use in UI or marketing copy:

- "Incident Report" or "Incident Record" (implies § 87211 compliance)
- "Reportable Incident" (implies the product determines reportability)
- "Medication Record," "Med Log," "Med Pass Record," or "Medication Administration" (implies § 87465 MAR compliance)
- "Required Documentation" or "Required Record" (implies legal sufficiency)
- "Complete Record" or "Official Record" (implies § 87506 completeness)
- "Resident Record" in a regulatory sense (implies § 87506 status)
- "Title 22 documentation" or "CDSS documentation" (implies regulatory record status)

Preferred product language:
- "Shift log entry" or "care observation" (not "record" or "documentation")
- "Incident note" (not "incident report")
- "Observed care task note" (not "medication record" or "med log")
- "Handoff summary" (not "official handoff" or "required handoff document")

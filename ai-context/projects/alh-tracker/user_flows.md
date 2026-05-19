# alh-tracker — User Flows

This file describes the primary user flows for alh-tracker at a task level. Screen-level UI design and component layout are separate concerns.

---

## Flow 0: Business Onboarding (Internal CRM Staff → Facility Owner)

**Actors:** ALH Tracker internal business/admin staff (CRM), then facility owner (tracker app)
**Device:** CRM steps on desktop; facility owner steps on phone or tablet
**Updated:** 2026-05-18 (task 0012). See ADR 0005 Section 4 and ADR 0006 for the provisioning architecture decisions.

### CRM steps (internal ALH Tracker staff, desktop)

1. Facility owner signs the ALH Tracker agreement.
2. Internal staff creates the facility/customer record in the CRM: facility name, owner contact information, license number, onboarding status, and allowable resident count configuration.
   - TODO: Onboarding status states and ownership of each step (internal staff vs. facility owner self-serve vs. hybrid) are unresolved.
   - TODO: "Allowable resident count" may mean licensed capacity, subscription-tier limit, or active resident count — or all three as separate fields. Unresolved.
3. Internal staff records the subscription and payment status in the CRM.
   - TODO: Payment provider and what data is stored in CRM vs. at the provider are unresolved.
4. Internal staff provisions a Facility Tracker App account for the facility owner (as owner/admin role). This creates a pending/invited account in the tracker app. The CRM does not read from or write directly to tracker app care data tables — provisioning is a forward write only.
   - **Mechanism (ADR 0007 — proposed):** Custom `provisioning_tokens` table. CRM calls the tracker provisioning API endpoint; tracker backend creates the `User` row (invited state), generates an opaque token, stores its SHA-256 hash in `ProvisioningToken`, and sends the activation email. The Supabase Auth user is created at activation time only — not at provisioning time. See ADR 0007 for full specification.
   - TODO: CRM-to-tracker API authentication method (API key vs. service JWT) is unresolved. See ADR 0007 Open Implementation TODOs.
5. The system sends a confirmation email to the facility owner's registered email address. The email states that an account has been created and contains an activation deep link.
   - The deep link contains an opaque, expiring, one-time-use token. It does not contain facility IDs, resident IDs, or care data.
   - Token expiry: 72 hours. Resend: previous token is expired immediately and a new one generated. Revocation: CRM staff action — active token expired and owner account disabled. See ADR 0007 for full token lifecycle specification.
   - TODO: Transactional email service selection and sender domain SPF/DKIM/DMARC configuration are unresolved. See ADR 0007 Open Implementation TODOs.

### Facility owner activation (triggered by the confirmation email)

6. The facility owner receives the confirmation email and clicks the activation deep link.

   **Deep link routing (proposed — see distribution assumption):**
   - If the app is not installed: owner is routed to the App Store (iOS) or Google Play (Android) to download and install the app.
   - If the app is installed and the owner has not yet created a password: the app opens to the create-password / account-activation screen.
   - If the app is installed and the account is already active: the app opens to the login page.

   **Distribution assumption:** App Store / Google Play routing assumes native iOS/Android distribution. The app delivery model (PWA vs. native vs. web + redirect) is a pending ADR — see `decisions\README.md`. This is the proposed/assumed flow; native distribution must be formalized before implementation.

   **iOS vs. Android deep link behavior:** iOS Universal Links and Android App Links work differently and require separate server-side configuration. This is an implementation TODO before Phase 2.

7. Owner completes account activation: creates a password and confirms their profile information (full name, phone, facility relationship/role, mailing or business address; occupation/title is optional).
   - TODO: Whether identity verification, license credential, or signed agreement reference is required before full access is granted is unresolved.

8. After successful login, the tracker app presents a blank tracker profile for that facility — no residents or routines pre-loaded.
9. The owner's tracker app account does not grant CRM access (per ADR 0005 and ADR 0006 Section 3).

### Facility setup steps (tracker app, phone or tablet — post-login)

10. Facility owner configures shift periods (see task 0003 — fixed vs. operator-configured is an open question).
11. Facility owner adds active residents: display name and room number.
12. Facility owner configures each resident's routine: which event categories to track per shift period.
13. Facility owner creates caregiver and admin accounts and assigns roles.
14. Caregivers receive login credentials (or shared tablet PIN — see task 0003).

**Exit:** Caregivers can open a shift and begin logging.

**Desktop note:** If the facility owner opens the tracker app from a desktop browser, they are directed to install/open the app on a phone or tablet (distribution policy — not a security or compliance control; implementation details TODO).

---

## Flow 1: Facility and Resident Setup (Owner / Admin — post-onboarding)

**Actor:** Owner or admin
**Device:** Phone or tablet (mobile/tablet-first; see device policy in overview.md and ADR 0005)

This flow covers setup and configuration tasks after the facility owner has completed the business onboarding flow (Flow 0) and logged into the tracker app for the first time.

1. Owner configures shift periods (e.g., Morning 7am–3pm, Evening 3pm–11pm, Night 11pm–7am). Whether periods are fixed or operator-configured is an open design question — see `ai_memory.md` and task 0003.
2. Owner adds active residents: display name and room number.
3. Owner configures each resident's routine: which event categories to track per shift period.
4. Owner creates caregiver and admin accounts and assigns roles.
5. Caregivers receive login credentials (or shared tablet PIN — see task 0003).

**Exit:** Caregivers can open a shift and begin logging.

### Flow 1b: Resident Setup Wizard (Owner / Admin)

**Actor:** Owner or admin
**When:** Adding a new resident to the facility.

1. Owner or admin selects "Add Resident" from the residents list or facility setup screen.
2. A step-by-step setup wizard opens:
   - Step 1 — Identity: display name (required), room (required), preferred name (optional), legal name (optional), approximate age (optional). DOB: TODO.
   - Step 2 — Safety Alerts: allergies, sensitivities, behavioral triggers, calming strategies. Fall precaution, wandering precaution, eating/swallowing assistance context, critical safety notes. TODO: these fields require a data model update — see `features.md` and `data_model.md`.
   - Step 3 — Mobility/Assistance: wheelchair, walker/cane/device, transfer/standing assistance, lift note. TODO: this section requires a data model update.
   - Step 4 — Daily Care/Routine Context: bathing, dressing, toileting, continence, diet, hydration, sleep, communication/hearing/vision notes. TODO: this section requires a data model update.
   - Step 5 — Family/Emergency Contacts: add one or more contacts, each with name, relationship, phone, email, emergency contact flag, emergency decision note, and privacy/release status. TODO: multi-contact model requires a data model update.
   - Step 6 — Medication-Adjacent Operational Notes: caregiver-recorded operational context only. Not a MAR. TODO: this field requires design and counsel review.
3. Owner or admin can skip optional sections and complete them later via the section-by-section edit flow.
4. On confirmation, the resident record is created and the resident appears on the active roster.
5. A profile-created audit record is written.

### Flow 1c: Deactivate / Archive a Resident (Owner / Admin)

**Actor:** Owner or admin
**Device:** Phone or tablet (mobile/tablet-first; see device policy)

1. Owner or admin navigates to the resident's profile page.
2. Owner or admin selects "Deactivate" or "Archive Resident" (exact label is a UX decision — TODO).
3. A confirmation dialog appears: displays the resident's name and a warning that the resident will be removed from the active shift roster.
4. Owner or admin optionally records a reason (e.g., "Transferred to hospital," "Family took resident home," "Resident passed away").
5. Owner or admin confirms deactivation.
6. The resident's `is_active` field is set to false. The resident no longer appears on the active roster or shift board.
7. All historical shift logs, wellness observations, follow-ups, profile data, and audit trail for this resident are fully preserved.
8. A resident-archived audit record is written with the acting user, timestamp, and optional reason.

**Exit:** Resident is no longer on the active roster. Historical data is accessible to owner/admin through the residents list (archived view).

**Edge cases:**
- If the resident has an active family access grant at the time of archiving, the behavior of that grant (auto-suspend vs. remain active) is **TODO**.
- If the resident has open follow-up items, those items are preserved but are no longer surfaced on the active shift board — owner/admin can review them in the resident's archived profile.

### Flow 1d: Reactivate an Archived Resident (Owner / Admin)

**Actor:** Owner or admin
**Device:** Phone or tablet

1. Owner or admin navigates to the archived residents view.
2. Owner or admin selects the resident to reactivate.
3. A confirmation dialog confirms the reactivation.
4. Owner or admin confirms. The resident's `is_active` field is set to true and the resident reappears on the active roster.
5. A resident-reactivated audit record is written.

**Exit:** Resident is active and visible on the shift board.

---

## Flow 2: Starting a Shift (Caregiver / Med Tech)

**Actor:** Caregiver or med tech
**Device:** Phone or shared tablet

1. Caregiver logs in (individual account or shared tablet PIN).
2. Caregiver selects or confirms the current shift period (or the shift auto-detects based on time).
3. Caregiver sees the shift board: all active residents with their scheduled routines for this shift period.
4. Caregiver begins logging events.

---

## Flow 3: Logging a Routine Event — Normal Path

**Actor:** Caregiver
**Device:** Phone

1. Caregiver taps a resident on the shift board.
2. Caregiver sees the resident's scheduled routines for this shift.
3. Caregiver taps a routine item (e.g., Breakfast).
4. Caregiver taps a status button (e.g., "Ate Well" / "Done").
5. Entry is saved with timestamp, caregiver ID, shift ID, and resident ID.
6. UI returns to the resident routine list or the shift board.

**Target:** Under 10 seconds total.

---

## Flow 4: Logging a Routine Event — Exception Path

**Actor:** Caregiver
**Device:** Phone

1–3. Same as Flow 3 (normal path).
4. Caregiver taps an exception status (e.g., "Partial", "Refused", "Needs Follow-up").
5. UI presents optional quick reason buttons (e.g., Low appetite / Nausea / Sleeping / Refused / Away).
6. Caregiver optionally taps a quick reason.
7. Caregiver optionally adds a short free-text note.
8. Entry is saved. A follow-up flag may be auto-set depending on the status and category.
9. UI returns to the resident routine list or the shift board.

---

## Flow 5: Correcting a Logged Entry

**Actor:** Caregiver (within a time window) or admin (anytime)
**Device:** Any

1. Caregiver taps an already-logged event (or a brief undo toast appears immediately after logging).
2. UI shows the current logged status with a visible "Edit" or "Undo" option.
3. Caregiver changes the status or note.
4. System saves the corrected entry and writes an AuditTrail record preserving the previous value.
5. The original entry is not deleted — only the current value changes, and the history is preserved.

**Design note:** A quick undo action (e.g., a dismissible toast immediately after logging) prevents the need to hunt for the edit path in most correction cases.

---

## Flow 6: Logging an Observed Care Task

**Actor:** Caregiver or med tech
**Device:** Phone

1. Caregiver opens a resident's observed care task list.
2. Caregiver taps a task (e.g., "Morning Medications").
3. Caregiver selects a status (e.g., Done, Partial, Refused, Needs Follow-up).
4. UI prompts for a note — required or optional depending on status. Observed care tasks are slightly more deliberate than routine events: the note prompt is a product guard against casual one-tap medication observations.
5. Entry is saved as an ObservedCareTask linked to a CareLogEntry.

**Design note:** This flow is intentionally more deliberate than a routine event tap. The caregiver should feel they are making a meaningful record, not a reflex tap. Still simple — not a form.

---

## Flow 7: Batch Logging — Normal Path

**Actor:** Caregiver
**Device:** Phone or tablet

1. Caregiver selects a routine event category from the shift board (e.g., Breakfast).
2. Caregiver sees all residents scheduled for that routine in this shift period.
3. Caregiver taps "All Ate Well" (or equivalent batch action).
4. UI prompts: "Any exceptions?" Caregiver flags exceptions by tapping individual resident names.
5. Exceptions are logged individually via Flow 4.
6. Remaining residents are batch-logged as "Done".

**Design note:** Batch logging is high-value but carries a risk of creating inaccurate records if used carelessly. Test this flow specifically with real caregivers during task 0007.

---

## Flow 8: Closing a Shift and Generating the Handoff

**Actor:** Shift lead or house manager
**Device:** Tablet or phone

1. Shift lead taps "Close Shift" or "Generate Handoff".
2. System checks for any routines that have not been logged for active residents this shift.
3. If unresolved items exist, system prompts the shift lead to review or explicitly dismiss them.
4. System generates the handoff summary:
   - Exceptions surface first: refused events, pain notes, incidents, open follow-up items, observed care tasks with non-Done status.
   - Normal events are summarized by category (not individually listed).
5. Shift lead reviews the handoff summary.
6. Shift lead confirms and submits the handoff.
7. Handoff becomes visible to incoming shift caregivers.
8. Shift record is marked closed with a `closed_at` timestamp and `closed_by` user reference.

---

## Flow 9: Reviewing the Incoming Handoff

**Actor:** Incoming caregiver or house manager
**Device:** Tablet or phone

1. Incoming caregiver logs in (or opens the shared tablet).
2. System presents the latest closed handoff for their shift period.
3. Caregiver reviews exceptions and follow-up items.
4. Caregiver acknowledges the handoff (optional acknowledgment record — design decision pending).

---

## Flow 10: Owner / Admin Daily Review

**Actor:** Owner or admin
**Device:** Desktop or tablet

1. Owner opens the admin review view.
2. Owner sees a day-level summary: shifts logged, exception count, open follow-up items.
3. Owner can drill into a specific shift or a specific resident's log for the day.
4. Owner can view and export the audit trail for a date range.
5. Owner can review and resolve or escalate open follow-up items.

---

## Flow 11: Resident Profile Details and Daily Operations

**Actor:** Owner, admin, or caregiver
**Device:** Phone or tablet

### 11a: View allergy and trigger information

1. Caregiver navigates to any resident's profile page.
2. If allergies are documented, a warning banner displays directly below the profile header, visible regardless of which tab is active.
3. Caregiver navigates to Activity Log and selects that resident.
4. If allergies are documented, an allergy banner appears below the resident selector.

### 11b: Edit allergies, contact, or preferences (Profile tab)

1. Owner or admin navigates to a resident's profile page and taps the Profile tab.
2. Profile tab shows four sections: Allergies & Triggers, Room Check Today, Transport & Appointments, Main Contact & HIPAA, Preferences.
3. Tapping "Edit" on a section opens an inline edit form for that section.
4. User edits fields and taps Save.
5. Changes are upserted to the per-resident record.

### 11c: Daily room check

1. Caregiver navigates to a resident's profile page → Profile tab.
2. Room Check Today section shows today's checklist with two checkboxes: Room made up, Sheets changed.
3. Caregiver taps a checkbox — change is saved immediately (no Save button required).
4. Optional note field allows context (e.g., "Resident requested room not be disturbed").
5. Residents with incomplete rooms (`room_made_up = false`) surface on the dashboard under "Rooms Not Made Up Today" and in the handoff summary per resident.

### 11d: Transport and appointment tracking

1. Owner or caregiver navigates to a resident's profile page → Profile tab.
2. Transport & Appointments section lists existing records with pickup and return status badges.
3. Quick action buttons allow updating pickup status (Waiting / Picked up / Missed / Cancel) without opening a form.
4. When status is "Picked up", return status buttons appear: Returned — family / Returned — transport.
5. Tapping "Add" opens a compact form: appointment label, date/time, pickup time, pickup status, transport contact, note.
6. Today's transport appointments surface on the dashboard: missed pickups in red, upcoming pickups in blue, not-yet-returned in amber.
7. Transport status also appears in the handoff summary under each relevant resident.

### 11e: Caregiver profile read — safety, mobility, and contact summary

**Actor:** Caregiver or med tech
**Device:** Phone or tablet

1. Caregiver navigates to a resident's profile page.
2. If safety alerts are documented (allergies, fall precaution, wandering precaution, eating/swallowing assistance context, critical safety notes), a warning banner is displayed prominently in the resident profile header, visible regardless of the active tab.
3. Caregiver can review the safety alerts section in read-only mode.
4. Caregiver can review the mobility/assistance section in read-only mode (once that section is implemented — TODO pending data model update).
5. Caregiver can view the emergency/family contacts section in read-only mode: emergency contact name, phone, and relationship.
6. No edit access is available to the caregiver on any profile section.
7. If no safety alert or mobility data has been entered, the section shows a graceful empty state rather than a blank that could be misread as "no concerns noted."

---

## Flow 12: Owner/Admin Grants Family Access (Phase 2 — Not Yet Implemented)

> **Phase 2 feature.** Not yet implemented. Blocked on counsel review of the consent model, family user eligibility design, and Phase 2 family member app delivery. See `ai_memory.md`, ADR 0004, and `features.md` Facility-Owner Managed Family Access Grants section.

**Actor:** Owner or admin
**Device:** Phone or tablet (mobile/tablet-first)

1. Owner or admin navigates to a resident's profile page or a family access management screen.
2. Owner or admin initiates a new family access grant for this resident.
3. Owner or admin selects the family contact from the eligible users or contacts associated with this resident.
   - **TODO:** The exact UI mechanism for this selection (dropdown, list, search) and how family users become associated with the facility for selection purposes are pending Phase 2 design.
   - **Note:** Family users are not records in the facility staff `User` table (per ADR 0004 and ADR 0005). The selection mechanism is separate from the staff user management flow.
4. Owner or admin confirms the family member's relationship to the resident.
5. Owner or admin reviews the grant scope: which log categories will be visible to the family member (controlled by `category_scope` in `FamilyAccessConsent`). Incident and observed care task categories are excluded from default scope and require explicit opt-in per ADR 0004.
6. Owner or admin completes the resident autonomy step: the system prompts them to note whether they considered the resident's preferences before granting access.
   - If `resident_autonomy_noted = false` (resident expressed concerns or declined), the system surfaces a warning before completing the grant. The owner or admin can proceed but the objection is recorded.
7. Owner or admin confirms and submits the access grant. A `FamilyAccessConsent` record is created.
   - `access_level` defaults to `summary` (status-level summaries; no raw caregiver notes visible to family). The `full_notes` level remains blocked pending counsel review.
8. The family member receives notification or confirmation that access has been granted.
   - **TODO:** Notification delivery mechanism is unresolved.

**Exit:** Family member has an active `FamilyAccessConsent` record for this resident. The grant is resident-specific — if this family user is associated with another resident, a separate grant is required for that resident.

**Audit:** A `family_access_consent` create event is written to the audit trail with: acting user (owner or admin), resident, contact identity, category scope, access level, `resident_autonomy_noted`, and timestamp.

---

## Flow 13: Owner/Admin Revokes Family Access (Phase 2 — Not Yet Implemented)

> **Phase 2 feature.** Not yet implemented. See Flow 12 context above.

**Actor:** Owner or admin
**Device:** Phone or tablet

1. Owner or admin navigates to a resident's profile page or a family access management screen.
2. Owner or admin selects the active family access grant to revoke.
3. A confirmation dialog appears: displays the family member name, resident name, and scope of the grant being revoked.
4. Owner or admin optionally records a reason for revocation.
5. Owner or admin confirms revocation. The `FamilyAccessConsent.revoked_at` and `revoked_by` fields are set.
6. The family member loses access to the resident's approved wellbeing view immediately.

**Exit:** `FamilyAccessConsent` record is revoked. The family member's app access for this resident is disabled. The grant record is preserved in the audit trail.

**Audit:** A `family_access_consent` revoke event is written with: acting user, resident, contact identity, reason (if provided), and timestamp.

---

---

## Internal CRM Flows (Stub — ALH Tracker Business/Admin Staff)

These flows describe the internal CRM used by ALH Tracker business/admin staff to manage commercial customer relationships. The CRM is a separate desktop-only product surface; these flows are not part of the facility tracker app. Implementation details are TODO pending CRM design. See ADR 0005 and `features.md` CRM stub section.

**Device:** Desktop only.
**Actor:** ALH Tracker internal business/admin staff (not facility owners, caregivers, or family members).
**CRM data scope:** Commercial relationship metadata only — no resident wellness/care logs.

### CRM Flow A: Create, configure, and provision a facility customer record

1. Internal staff receives a signed ALH Tracker agreement from a facility owner.
2. Staff creates a new customer record in the CRM: facility owner name, contact information, facility name, license number.
3. Staff configures allowable resident count for the facility.
   - TODO: Whether this is licensed capacity, subscription limit, or active count is unresolved.
4. Staff sets onboarding status (e.g., Agreement signed, Account created).
   - TODO: Onboarding status states and step ownership are unresolved.
5. Staff records subscription tier and initial payment status.
   - TODO: Payment provider and data fields are unresolved.
6. Staff records any initial support/admin notes.
7. Staff provisions a Facility Tracker App account for the facility owner (pending/invited state). This triggers the system to send a confirmation email with an activation deep link to the facility owner.
   - **Mechanism (ADR 0007 — proposed):** Custom `provisioning_tokens` table. CRM calls the tracker provisioning API endpoint; all token creation, email delivery, and account lifecycle logic runs tracker-side. CRM receives only an opaque `provisioning_reference` and `provisioning_status`. See ADR 0007.
   - The CRM does not gain access to care data or resident records through this action.
   - Staff marks onboarding status to reflect that the account has been provisioned and the confirmation email sent.

**Exit:** Customer record is live in the CRM. Facility owner has received a confirmation email with an activation deep link (see Flow 0). Staff monitors for first-login confirmation.

### CRM Flow B: Update onboarding and subscription status

1. Internal staff opens the customer record for a facility.
2. Staff updates onboarding status milestones as they are completed (e.g., Instructions sent, First login, First resident added).
   - TODO: Which milestones are tracked and who updates them (staff vs. automated signal from tracker app) is unresolved.
3. Staff updates subscription or payment status as needed.

### CRM Flow C: Log a communication with a facility owner

1. Internal staff records an interaction with a facility owner (outreach, support call, billing inquiry).
   - TODO: Communication log structure (call log, email thread, in-app message, or other) is unresolved.
2. Staff adds a summary or note to the customer record.

### CRM Flow D: Record support/admin notes

1. Internal staff opens a facility customer record.
2. Staff adds an internal note visible only to ALH Tracker business/admin staff.
3. Note must not contain resident-identifiable health data.

---

## Family Member Onboarding Flow (Planned Phase 2)

This flow describes how a family member creates an account and, separately, gains approved access to resident data through the Family Member App. It is a Phase 2 planned surface — not part of the MVP facility tracker app and not part of the current `/family` web prototype in the existing React app. Implementation details are TODO pending design and counsel review. Data access architecture is governed by ADR 0004 and ADR 0006.

**Device:** Phone or tablet (mobile/tablet-first; desktop users are directed to use phone/tablet).
**Updated:** 2026-05-18 (task 0012) — account creation now documented as a step separate from access approval.

---

### Phase A — Family member account creation (identity only)

1. A family member installs the Family Member App on their phone or tablet.
   - TODO: Whether account creation requires an invitation from the facility owner/admin or may be initiated independently (self-service) is unresolved. See ADR 0006 Section 5.
   - TODO: Family member app delivery model (native app store, PWA, or web install) is unresolved — see pending ADR in `decisions\README.md`.
   - **Note:** The Family Member App is a planned Phase 2 separate mobile/tablet surface. It is distinct from the current `/family` web prototype route in the existing React app.

2. Family member creates a FamilyUser account.
   - A FamilyUser account is an identity record only. It does NOT grant any resident data access. See ADR 0006 Section 5 and `data_model.md`.
   - FamilyUser accounts are NOT records in the facility-facing staff `User` table (per ADR 0004 Section 7 and ADR 0006 Section 7).
   - TODO: Account creation mechanism (email + password, email magic link, OTP) is unresolved.

   Profile fields collected at account creation:
   - Full name (required)
   - Phone number (required)
   - Email address (required)
   - Relationship to resident (required; e.g., Daughter, Son, Spouse, Friend)
   - Address (required — TODO: whether required for all accounts or only for identity/relationship verification is unresolved)
   - Occupation (optional — TODO: whether needed at all or only for identity context is unresolved)
   - Resident they are requesting access to (TODO: only collected if request-based access is allowed)
   - Facility association (optional — if known at signup)
   - Preferred notification method
   - Emergency/contact role (optional, if applicable)
   - Privacy/release status (optional, if known or facility-confirmed)

   **Labeling guardrail:** Do not label any of the above fields in a way that implies legal authority, HIPAA validation, or consent verification unless counsel approves exact language.

3. After creating a FamilyUser account and logging in, the family member sees no resident wellbeing data, no care log summaries, no wellness observations, and receives no resident-related notifications.
   - The app presents a pending/no-access state, clearly communicating that access to resident data requires facility owner/admin approval.
   - TODO: Whether the family member can submit a formal access request through the app at this step is unresolved.

---

### Phase B — Owner/admin approval (separate step — see also Flows 12, 13, and Flow 14)

4. The facility owner or admin reviews pending FamilyUser accounts/requests via the Family Access Management screen (see Flow 14).

5. Owner or admin approves access for a specific FamilyUser linked to a specific resident, completing the dual acknowledgment required by ADR 0004:
   - Operator authorization: owner or admin creates a FamilyAccessConsent record (see Flow 12).
   - Resident autonomy noted: operator records whether they considered the resident's preferences.

6. After approval, the family member can view the approved wellbeing summary for their authorized resident(s).
   - Access is limited to the categories and access level granted by the FamilyAccessConsent record.
   - Family members never see raw caregiver notes, incident notes (`incident` category), observed care task notes (`observed_care_task` category), allergy/safety details, mobility/ADL details, staff names or user IDs, audit trail, or operational follow-up descriptions.

7. Family member may receive approved notifications for their authorized resident(s).
   - TODO: Notification categories and who authorizes them are unresolved. Notifications are approval-gated and scope-limited.

8. Family member may communicate with the facility through approved channels.
   - TODO: Message types, direction, channels, content, and moderation/audit requirements are unresolved. This feature must not be designed or built before counsel review.

**Consent note:** Phase B requires dual authorization before any resident data is visible — operator authorization plus resident autonomy noted — per ADR 0004. Family access must not be granted automatically. Counsel review of the consent model is required before Phase 2 family portal implementation begins.

**Desktop note:** If a family member opens the app from a desktop browser, they are directed to install/open the app on a phone or tablet (distribution policy — not a security or compliance control; implementation details TODO).

---

## Flow 14: Owner/Admin Family Access Management (Phase 2 — Not Yet Implemented)

> **Phase 2 feature.** Not yet implemented. Depends on ADR 0006 being accepted and the FamilyUser entity being implemented. See `data_model.md` and `ai_memory.md`.

**Actor:** Owner or admin
**Device:** Phone or tablet (mobile/tablet-first)

This flow covers the owner/admin's management of FamilyUser access requests, active grants, and revocations from a single management surface.

1. Owner or admin navigates to the Family Access Management screen. This screen may be accessible from:
   - A resident's profile page.
   - A facility settings / user management area.
   - TODO: Exact navigation path is a UX decision pending Phase 2 design.

2. The management screen shows three sections:

   **Pending requests** (if request-based access is allowed — TODO):
   - FamilyUser accounts that have submitted a request for access to a resident at this facility.
   - Each row shows: family member name, relationship, resident requested, date of request.
   - Owner/admin can: approve (opens Flow 12 grant flow) or reject (TODO: rejection notification behavior is unresolved).

   **Active grants:**
   - FamilyUser accounts with active FamilyAccessConsent records.
   - Each row shows: family member name, resident, category scope, access level, grant date.
   - Owner/admin can: view grant details, edit scope (TODO: whether scope editing is in-place or requires revoke + re-grant is unresolved), revoke access (opens Flow 13).

   **Revoked grants** (optional reference view):
   - Historical revoked grants, preserved in the audit trail.

3. Owner or admin can also initiate a new grant proactively (without a pending request):
   - Owner/admin searches for a FamilyUser by name or email.
   - TODO: Discovery/search mechanism depends on whether FamilyUsers must be associated with the facility before they appear — unresolved.
   - On selection, proceeds to Flow 12 (grant flow).

**Audit:** All approval, rejection, and revocation actions are audited in the AuditTrail (entity type: `family_access_consent`).

**Guardrail:** Owner/admin may only manage family access for residents at their own facility. Cross-facility management is not permitted.

---

## Out of Scope for Facility Tracker App MVP

- Family portal / family-facing app — planned as separate Phase 2 mobile/tablet surface; see ADR 0005 and overview.md Product Surfaces
- External notifications to families (SMS/email) — TODO pending Phase 2 design
- Clinical reporting formats
- MAR administration record review or verification

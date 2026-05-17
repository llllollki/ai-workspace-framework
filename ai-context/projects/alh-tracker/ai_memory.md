# alh-tracker — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

### Business model and ALH relationship (Task 0001)

Resolved items (ADRs created 2026-05-05 and 2026-05-09):
- Pricing model type: flat monthly per-facility — ADR 0002, accepted.
- ALH partner pricing: free during design partner + Phase 1 pilot; $49/month add-on at commercial transition (founding partner rate) — ADR 0003, accepted. Owner must confirm this rate before first ALH pilot conversation concludes.
- Shared onboarding/billing: no shared system at MVP; ALH partner identified by `alh_partner` boolean on Facility entity only — ADR 0003, accepted.
- BD timing: "coming soon / design partner invitation" framing only before MVP ships — decided, documented in task 0001.

Still open (blocks full task closure):
- Non-ALH standalone price point ($149/month recommended, $99–$199/month working range) is NOT validated. Requires design partner pricing sensitivity probe (task 0002 validation checklist) before locking.

### Design partner (Task 0002)

- Who is the first design partner? Target profile defined (see task 0002 and working context below). Committed partner not yet identified — outreach not yet executed.
- Outreach channel priority established: (1) ALH Phase 1 market contacts, (2) CDSS/CCLD Riverside County RCFE registry cold list, (3) CALCASA/local associations, (4) personal referrals. Candidate list not yet built.

### Shift model (Task 0003)

- Are shift periods fixed time windows (e.g., 7am–3pm / 3pm–11pm / 11pm–7am) or owner-configured?
- What happens if a caregiver never closes their shift? Do log entries become orphaned from the handoff?
- What triggers handoff generation — an explicit caregiver action, a scheduled time, or both?
- How are orphaned or overlapping shifts handled?

### Caregiver authentication (Task 0003)

- Individual accounts per caregiver (better audit trail, more setup friction) or shared device PIN (lower friction, weaker individual accountability)?
- Can both models coexist per facility — e.g., individual accounts for primary caregivers, shared PIN for agency or backup staff?
- How does shared tablet behavior work: persistent session, auto-lock, or per-event re-authentication?
- How are new or agency caregivers added without blocking a shift?

### Observed care task deliberateness

- Should observed care task logging require a note when status is anything other than "Done"?
- What is the right friction level to prevent accidental one-tap medication observations without making the flow feel like a form?

### Internal CRM and three-surface model (ADR 0005 — open questions)

ADR 0005 (2026-05-16) accepted the three-surface product model and CRM architecture. The following questions remain open and must be resolved before CRM design begins:

- **Allowable resident count distinction:** Does the CRM-tracked "allowable resident count" mean (a) licensed facility capacity (set by CDSS), (b) subscription-tier resident limit (commercial), (c) currently active resident count (operational), or all three as separate tracked fields?
- **App delivery model:** Is the facility tracker app and/or family member app delivered as a native iOS/Android app store app, a PWA with install prompt, or a web app with a mobile redirect message? This affects onboarding instructions and the feasibility of the mobile-first distribution policy.
- **Onboarding ownership split:** Who owns each onboarding step — internal ALH Tracker staff, the facility owner self-serving through the app, or a hybrid? What steps are tracked in the CRM vs. the tracker app?
- **Payment provider:** Which payment provider will be used? What payment metadata is stored in the CRM vs. held by the provider? (Hard constraint: raw card/bank details must not be stored in the CRM regardless of provider.)
- **CRM roles:** What roles exist within the internal CRM — e.g., sales, onboarding, support, billing, admin? Role granularity affects access control design for the CRM.
- **CRM user authentication model:** What authentication mechanism do ALH Tracker business/admin staff use to access the CRM? Separate from tracker app auth. Pending CRM design.
- **CRM-to-tracker provisioning handshake:** What is the exact mechanism by which a CRM-provisioned facility account becomes a usable tracker app account for the facility owner? (Principle: opaque reference only; no care data flows to CRM. Implementation details are TODO.)
- **CRM communications log definition:** What constitutes a "communication" in the CRM — email thread, call log, in-app message, or other channels?
- **Desktop access policy for facility owners:** Is desktop access to the facility tracker app a hard block (HTTP 403/redirect) or a soft redirect (page nudging users to mobile)? Does any facility owner/admin workflow require desktop access (e.g., facility setup, user management, reporting)?
- **Internal support staff access to resident care data:** Can ALH Tracker business/admin staff ever access resident-level care data through the CRM for support purposes? If yes, what audited policy governs it? This access must not be enabled by default.

### Resident profile expansion and family access grants (2026-05-16)

The following open questions were identified during documentation of resident profile management and facility-owner managed family access grants. These are not yet tracked under existing task numbers.

**Resident profile field groups:**
- **Multi-contact model:** `ResidentContact` is currently one-record-per-resident. Changing to one-to-many is a structural data model change pending design review.
- **Identity field expansion:** `legal_name`, `preferred_name`, `resident_phone`, `move_in_date`, and `approximate_age` are documented as profile fields but not yet modeled on the `Resident` entity. Requires data model update.
- **Mobility/assistance entity:** No entity exists for mobility fields (wheelchair, walker/cane, transfer assistance, two-person assist, lift note). A new entity (e.g., `ResidentMobility`) is needed pending design review.
- **Daily care/routine context entity:** Structured daily care fields (bathing, dressing, toileting, continence, diet, hydration, sleep) are partially covered by `ResidentPreferences` in free text. Whether to extend `ResidentPreferences` or create a separate entity is an open design question. Counsel input on ADL data sensitivity needed.
- **Safety alerts expansion:** Fall precaution, wandering precaution, eating/swallowing assistance context, and critical safety notes are not yet modeled in `AllergiesTriggers` or elsewhere. Data model update needed.
- **Medication-adjacent operational notes field:** Whether this is a standalone named field on `Resident` or a section within `ResidentPreferences.general_notes` is pending design and counsel review.
- **DOB:** Deferred pending data minimization review and counsel sign-off. PHI-adjacent regardless of covered-entity status.

**Resident archive/reactivate flows:**
- **Archive behavior for active family access grants:** If a resident is archived, should active `FamilyAccessConsent` records be auto-revoked or auto-suspended? Behavior is undefined — needs a product decision.
- **Archive/reactivate field additions:** `deactivated_at`, `deactivated_by`, `deactivation_reason`, `reactivated_at`, `reactivated_by` are needed on the `Resident` entity but not yet modeled.
- **Caregiver safety/mobility empty state:** If no mobility or safety data has been entered for a resident, the caregiver read view must show a graceful empty state (not a blank that reads as "no concerns noted").

**Family access grant flow:**
- **Family user eligibility model:** How family users become associated with a facility for the owner/admin selection step (invitation from a contact record, email verification flow, separate family app onboarding) is unresolved. Pending Phase 2 design and counsel review.
- **Owner/admin UI for family user selection:** The exact mechanism (dropdown, list, search) depends on the eligibility model — pending Phase 2 design.
- **Behavior when `hipaa_release_status = expired` during grant:** Should the UI surface a warning or block when an owner/admin tries to grant family access to a contact with an expired privacy release status? Behavior is undefined.
- **Multi-resident family member:** A family member linked to two residents (one of whom is archived) should silently hide the archived resident's data or show a "no longer available" state. Behavior is undefined.
- **Resident autonomy override:** ADR 0004 says the system surfaces a warning when `resident_autonomy_noted = false` but does not block. Whether an owner/admin can override the warning and what is additionally recorded in that case is undefined.
- **Notification categories for family members:** Which notification types are approved for family delivery is unresolved (see also ai_memory.md family access open questions below).
- **Communication moderation/audit for family-to-facility messaging:** Message types, direction, channels, content scope, and moderation/audit requirements are unresolved.
- **AuditTrail `entity_type` expansion:** The `family_access_consent` type (and all new profile entity types) must be added to the AuditTrail `entity_type` enum when those entities are implemented.

---

### Family access architecture (Task 0006)

Architectural decisions made (ADR 0004, 2026-05-09):
- ResidentContact holds the identity record; FamilyAccessConsent holds the access grant — these are separate entities.
- Dual acknowledgment required before any access is granted: operator authorization + resident autonomy noted by operator.
- Family access is always read-only; defaults to summary level (`access_level = summary`); raw notes access (`full_notes`) requires explicit selection and counsel review before it is built.
- Access is category-scoped via `category_scope`; incident and observed_care_task categories excluded from default scopes.
- Same primary database with row-level authorization — no derived summary layer.
- Family contacts are not User records; they authenticate via a separate future portal mechanism.
- All family access events are logged in AuditTrail.

Still open (blocks Phase 2 family portal):
- Counsel review of consent model and resident autonomy posture (task 0006, Section 2 and 5).
- Counsel confirmation on CPPA/CCPA obligations for family contacts as data subjects.
- Notice and disclosure language for family portal — required before any family contact is given access.
- Design partner validation: how do current operators share care information with families today?
- **Family app as separate mobile/tablet surface (ADR 0005, 2026-05-16):** The family portal is now planned as a separate Phase 2 mobile/tablet app surface rather than a web route within the facility tracker app. ADR 0004's architectural decisions (read-only, dual acknowledgment, category-scoped, row-level authorization) continue to govern the data access model for this surface.
- **Family app authentication mechanism:** ADR 0004 notes "email magic link or dedicated family portal login" as the authentication approach; this applies to the separate mobile app surface. The specific family app auth mechanism (email magic link, OTP, password) is unresolved and pending the app delivery model decision (native vs. PWA vs. web install).
- **Family-to-facility communications:** The family member app is planned to allow family members to communicate with the facility owner. What communications are allowed (message types, direction, channels, content) is unresolved. Family-to-facility communications involve care-adjacent content and require privacy and counsel review before design begins. Note: if messaging is implemented, it must not conflict with ADR 0004's "always read-only" constraint on care data — messaging must be treated as a separate data category from care log access.
- **Family notification types:** What notification types are "important" enough to push to family members, and who authorizes them, is unresolved.
- **Consent and authorization for family access:** Per ADR 0004, dual acknowledgment (operator authorization + resident autonomy noted) is required before any family contact accesses resident data. How this consent model applies to a separate mobile app install flow (vs. a web portal) is unresolved pending the app delivery model decision.

### HIPAA BAA posture

- Do RCFE operators using alh-tracker require a Business Associate Agreement?
- What is the vendor's HIPAA posture before commercial launch?
- This must be resolved before any real resident data is stored under a commercial relationship.

### Title 22 documentation scope (Task 0004)

Desk research complete (2026-05-05). Pending counsel review and sign-off. Key findings:
- § 87506 (resident records): 3-year post-service retention; includes medication records and condition documentation. Whether alh-tracker CareLogEntry records constitute § 87506 "resident records" is an open counsel question.
- § 87211 (incident reporting): Reporting obligation rests with the licensee per regulation text. Whether the vendor has independent obligations is an open counsel question. In-product incident notices required before commercial launch.
- § 87465 (medication management): Medication assistance records must document date, time, dosage, and response. 1-year retention for medication records. alh-tracker ObservedCareTask intentionally omits dosage/name — counsel must confirm whether these records constitute § 87465 medication records.
- § 87411 (personnel): No explicit shift-duty record requirement; caregiver identity records required. alh-tracker User entity and AuditTrail are compatible with accountability requirements.
- Full research and counsel brief in task 0004 Outcome, Section 6.

### Retention and deletion policy

> **HIGH RISK — pre-commercial-launch blocker (identified 2026-05-16):** No retention policy exists at the Supabase (production database) level. This must be resolved before any real resident data enters production. See task 0009.

- Minimum retention not yet defined as policy. Preliminary research: § 87506 (3 years post-service), § 87465 (1 year medication records, 3 years destruction records). Counsel must confirm which categories apply to alh-tracker as a vendor.
- Account closure behavior (what happens to records when a facility account closes) is undefined — must be resolved before commercial launch.
- Caregiver account deactivation: User identity must be preserved in AuditTrail references; anonymization policy pending counsel guidance.
- PITR backup retention (Supabase) must be at least as long as the counsel-confirmed minimum retention period per record type — not yet verified.
- Must be defined before commercial launch — blocks task 0005 (data model finalization). Task 0009 created to track this work.

---

## Current Working Context

<!-- Add temporary assumptions, in-progress decisions, and unresolved questions here as work progresses. Remove entries when resolved. -->

**Assumption (2026-05-05):** Commercial starting point is standalone SaaS pricing for non-ALH facilities; discounted or bundled for ALH facility partners. Not yet locked — see task 0001.

**Assumption (2026-05-05):** MVP targets California RCFEs with 6–20 residents currently using paper binders, whiteboards, or verbal handoffs. This profile was chosen as the sharpest initial wedge and closest first-fit.

**Assumption (2026-05-05):** Observed care tasks are caregiver observations only — no MAR/eMAR structure — until compliance and legal review confirms a safe, appropriate path forward.

**Family access architecture (2026-05-09 — task 0006 architectural decisions complete):** Family access stubs (ResidentContact, FamilyAccessConsent) are finalized in data_model.md per ADR 0004. Architecture is conservative, consent-first, and read-only by default. Stubs are present in schema but unpopulated at MVP. Phase 2 implementation is blocked on counsel review of the consent model — not on architecture decisions.

**Design partner strategy (2026-05-05 — task 0002 planning complete):**

- **Profile (must-have):** California RCFE, active license, 6–20 resident capacity, currently using paper/whiteboard/text/verbal handoff process, no digital shift log software, owner accessible for site visit, at least one caregiver willing to test during a real shift. Located in Temecula, Murrieta, or Menifee (SW Riverside County) — aligns with ALH Phase 1 markets.
- **Profile (disqualifiers):** Already using PointClickCare, MatrixCare, or similar; under active CDSS license action; fewer than 4 active residents; outside California; owner unwilling to allow caregiver participation.
- **Outreach channel priority:** (1) ALH Phase 1 facility contacts — warmest path; (2) CDSS/CCLD Riverside County RCFE registry filtered to capacity 6–20 — cold list; (3) CALCASA/local RCFE networks — lower-certainty; (4) personal referrals if Channels 1–2 stall after 4–6 weeks.
- **Candidate list:** Not yet built. Owner must pull ALH contact list and ca_ccld_registry Riverside County RCFE data, apply filters, and build 5–10 candidate list. Target 30–50 cold contacts to yield 1 committed partner.
- **LOI terms:** Free access during design partner phase; no pricing commitment in the LOI; founding partner rate to be communicated before design partner relationship concludes. No compliance claims. No production dependency. 30-day exit by either party.
- **Outreach script and site visit plan:** Documented in task 0002 Sections 3 and 4. Do not deviate from the language guardrails — no launch date, no pricing, no compliance language.
- **Validation gate for Task 0003:** Shift model and auth questions from the task 0002 validation checklist must have answers from a real facility before task 0003 is activated.

**Working direction (2026-05-05 — tasks 0001, 0002, 0004 activated):**

- **Business model:** alh-tracker is positioned primarily as a stickiness tool for ALH facility relationships, not a standalone SaaS-first business. ALH facility partners: bundled or heavily discounted during early rollout. Non-ALH RCFEs: flat monthly rate in the $99–$199/month working range. Per-resident pricing explicitly deferred — adds complexity at onboarding and harder to justify for sole-operator homes. Refines commercial assumption above dated 2026-05-05.
- **BD timing:** alh-tracker may be introduced in ALH BD conversations now as a "coming soon / design partner invitation" signal only — not a finished-product promise.
- **Design partner target:** California RCFE, 6–20 residents, paper/whiteboard/text/verbal handoff workflow, owner accessible, at least one active caregiver willing to test phone/tablet during a real shift. Preferred geography: Temecula, Murrieta, Menifee, or nearby Inland Empire/Southwest Riverside County. Refines MVP target assumption above dated 2026-05-05.
- **Caregiver auth starting instinct:** Named individual accounts for regular caregivers (audit-sensitive actions require traceable identity). Shared tablet mode with quick per-session PIN switch for shared-device facilities. Not finalized — design partner site visit (task 0002) must validate before task 0003 locks the model.
- **Title 22 research posture:** Desk research begins as preliminary work for counsel review. Output is labeled preliminary research only — not legal advice. Language hard-stops confirmed: no compliance claims, no MAR/eMAR claims, no clinical monitoring claims, no medication safety claims, no legal sufficiency claims.

**Task 0001 in-progress state (updated 2026-05-09):**

- **Decided (firm):** Pricing model type is flat monthly per-facility. Data boundary is a non-negotiable architectural constraint. BD timing: design partner invitation only before MVP ships.
- **Decided (rate locked as recommendation):** ALH partners: free during design partner + Phase 1 pilot; $49/month add-on at commercial transition. Shared onboarding/billing: no shared system at MVP. ADR 0003 accepted.
- **Still open (blocks task closure):** Non-ALH price point ($149/month) not market-validated — requires design partner pricing probe. Support model at $99–$149/month not defined.
- **ADRs created:** ADR 0001 (data boundary), ADR 0002 (pricing model type), ADR 0003 (ALH partner pricing and shared onboarding) — all accepted.

**Task 0008 activated (2026-05-09); AI-assisted TA review completed (2026-05-10):**

- Offline behavior spec complete. Conservative PWA model: IndexedDB event queue, visible offline banner, automatic sync on reconnect, flag-for-review conflict resolution (no auto-merge or auto-discard). No Background Sync API dependency. Device tier matrix defined (phone priority 1, tablet priority 2, desktop priority 3). Minimum: Android 9+/Chrome 80+, iOS 14+/Safari. One item requires design partner site visit validation: actual WiFi quality at a real facility.
- `features.md` updated with offline behavior spec.
- AI-assisted TA review note added to task 0008 (2026-05-10): spec confirmed technically coherent. IndexedDB queue, dual-timestamp model, FIFO sync, flag-for-review conflict policy, no Background Sync dependency, and browser targets all reviewed. Minor implementation notes added (service worker registration order, IndexedDB schema versioning, stale-while-revalidate cache behavior, 200-entry queue capacity edge case). No blocking issues found. **Human TA must still confirm before Phase 1 implementation begins — AI review does not satisfy acceptance criterion 6.**

**Design partner tracker created (2026-05-10):**

- `projects/alh-tracker/design_partner_tracker.md` created with candidate list pre-seeded from third-party directory data (seniorguidance.org, aplaceformom.com) for Temecula, Murrieta, and Menifee.
- 36+ candidate rows across three cities. All capacity and license data requires CCLD verification before outreach.
- Key finding: the Temecula/Murrieta/Menifee RCFE market is dominated by 6-bed homes. No facilities with capacity 10–16 identified in public data. Most cold candidates will score Priority 3 under current rubric. ALH warm contacts (owner-supplied) are the most likely source of Priority 1 and 2 candidates.
- Warm contact section (Section A) is unpopulated — owner must supply from ALH CRM.
- Owner must verify all rows against CCLD before outreach: https://www.ccld.dss.ca.gov/carefacilitysearch/

**ToS draft created (2026-05-10):**

- `projects/alh-tracker/tos_draft_for_counsel.md` created as preliminary draft for counsel review.
- Covers: vendor role (service provider / data processor), record ownership (Customer owns data), retention (placeholders pending Q1 and Q2 counsel answers), account closure and record disposition (placeholder pending Q4), export/return/deletion rights, HIPAA BAA posture (explicitly unresolved — Section 6), no compliance certification clause, data security / breach notification.
- Each open provision maps to a specific counsel question from the handoff packet.
- Counsel handoff packet and phase_0_owner_action_packet updated to reference this draft.
- **This draft must not be used in any commercial context until counsel has reviewed and approved it.**

**alh-tracker MVP Phase 4 features shipped (2026-05-11):**

- Five new operational features added to the live app at https://alh-tracker.vercel.app and committed to git main (`edaa187`).
- **Preferences** — per-resident record: food, activity, communication, wake/sleep times, personal care, general notes. Upsert, one record per resident.
- **Main Contact / HIPAA Release Status** — per-resident record: contact name, relationship, phone, email, and a facility-recorded HIPAA release status field (Unknown / Not on file / On file / Expired / Not required). Operational tracking only — not legal validation of a release.
- **Allergies & Triggers** — per-resident record: allergies (with severity), sensitivities, behavioral triggers, calming/support strategies. Displayed as a prominent warning banner on the resident profile (always visible regardless of tab) and in the Activity Log when that resident is selected. Severe allergies (text contains "severe" or "anaphylaxis") render in red; others in amber.
- **Room Made Up / Sheets** — daily boolean checklist per resident (one record per calendar day). Inline checkboxes in the Profile tab. Incomplete rooms surface on the dashboard and in the handoff summary.
- **Transport Pickup for Appointment** — per-resident transport records. Full lifecycle: scheduled → waiting → picked up → returned, or missed/cancelled. Quick status update buttons on the Profile tab. Missed/upcoming/not-returned transport alerts surface on the dashboard. Transport status appears in the handoff summary per resident.
- Data model notes: all new entities use upsert (one record per resident for preferences/contact/allergies; one per resident per day for room checklist; multiple per resident for transport). New TypeScript types: `HipaaReleaseStatus`, `PickupStatus`, `ReturnStatus`. New interfaces: `ResidentPreferences`, `ResidentContact`, `AllergiesTriggers`, `RoomChecklist`, `AppointmentTransport`.
- Product boundaries held: no MAR/eMAR, no medication names/dosages/prescribers, no compliance claims, "resident" not "patient".
- `features.md`, `data_model.md`, and `user_flows.md` updated to reflect new scope.

**UI redesigned for caregiver clarity (2026-05-11 — session 10):**

- Redesigned 6 pages (Dashboard, Residents, ActivityLog, WellnessObservations, FollowUps, HandoffSummary) to reduce cognitive load for caregivers during a shift.
- Core design shift: Dashboard now leads with a single "Needs attention today" unified alert list (missed transport / not returned / room not made up / high follow-ups / concerns / upcoming transport) in one card with colored urgency dots. Stats row and Quick Access moved below. Nothing is hidden — alerts are just consolidated.
- Activity and Wellness forms now numbered (1. Who? 2. What? 3. How? 4. Note?) to make the step sequence legible at a glance.
- Follow-ups page priority filter row removed (no UI for it; priorityFilter always 'all'). Resolved items visually quieted to opacity-55.
- HandoffSummary shift-level section added: 3-col stats grid (entries/exceptions/follow-ups) + conditional amber "Shift alerts" callout for missed pickups, not returned, incomplete rooms.
- Committed `221fe19` ("Simplify app UI for caregiver clarity"), deployed to https://alh-tracker.vercel.app.

**Phase A demo-only banner implemented (2026-05-11 — session 9):**

- Added a fixed amber banner at the bottom of every app screen: "Demo only — do not enter real resident data."
- Implemented in `src/components/Layout.tsx`: added `AlertTriangle` icon import, appended the fixed banner div before the closing root div, added `pb-10` to the main content wrapper to prevent content from being obscured.
- Build passed clean (`tsc && vite build`). Committed as `fa8577a` ("Add demo-only warning banner"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Banner is visible on all screens (desktop and mobile) at the bottom of the viewport. It does not overlap the sidebar or mobile header. It does not block navigation.
- Updated `features.md` (banner status note), `ai_memory.md` (this entry), `execution_log.md`.

**Security and privacy architecture plan produced (2026-05-11 — session 8):**

- Security and privacy implementation plan drafted for alh-tracker. Covers data classification, required security architecture, data protection requirements, HIPAA-adjacent risk assessment, and a "must-have before real data" checklist. Pending counsel and security reviewer confirmation before any controls are treated as final.
- Current prototype confirmed as demo-only: no authentication, no authorization, all data in browser localStorage (plaintext), no backend. Seed data for 8 named residents persists in every browser that visits the live prototype. This is prototype-appropriate but must not receive real resident data.
- **Must-have production controls (15 items):** Authentication, session management, RBAC (server-side), facility-level tenant isolation, backend + database, encryption at rest, HTTPS enforced, AuditTrail in database (append-only at DB level), MFA for owner/admin, data export, account closure process, in-app compliance notices, counsel review of ToS, backups, and "demo only" banner on prototype.
- **Open security/privacy counsel questions added:** BAA prerequisites, PHI determination for RCFE operators, caregiver identity retention in AuditTrail after deactivation, breach notification timeline under California law, CCPA/CPPA obligations for family contacts (Phase 2), data minimization review, and SOC 2 / certification expectations from operators.
- Files updated: `compliance_notes.md` (new Security and Privacy Implementation Posture section), `data_model.md` (security notes in preamble and AuditTrail entry), `features.md` (Production Security Prerequisites section), `tos_draft_for_counsel.md` (new Section 10, updated open issues table), `ai_memory.md` (this entry), `execution_log.md`.
- No app code changed. No deployment.

**Session 6 link cleanup and packet update (2026-05-11):**

- Fixed two broken relative links in `next_7_days_owner_checklist.md` (Items 3 and 6 used `../../ai-workspace-framework/` — corrected to `../../../ai-workspace-framework/`).
- Updated `phase_0_owner_action_packet.md` Action 5 to explicitly reference the AI-Assisted Technical Review Note in Task 0008 and restate that AI review does not satisfy human TA acceptance criterion 6.
- No task statuses changed. No new facts added. No links to external resources. No counsel review claimed.

**Session 5 verification and additions (2026-05-10):**

- Consistency check completed across all Session 4 files. One gap found and fixed: `design_partner_tracker.md` was not referenced in `phase_0_owner_action_packet.md` Action 1 checklist or Sections 3A/3B. Three edits made to add those cross-references.
- Counsel email cover note added to `0004-counsel-handoff-packet.md` at the bottom (before "Contact and Next Steps"). Covers both Priority 1 Q1–Q4 ask and Phase 2 Q5–Q10 ask. Labeled preliminary / not legal advice.
- `projects/alh-tracker/next_7_days_owner_checklist.md` created: 6 operational items with times, source files, and completion signals. No strategic content — execution only. Items ordered by leverage: warm list (Item 1), CCLD verification (Item 2), counsel routing (Item 3), first outreach (Item 4), $49/month rate confirmation (Item 5), TA review scheduling (Item 6).

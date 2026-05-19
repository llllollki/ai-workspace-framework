# alh-tracker — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

### Business model and ALH relationship (Task 0001)

Still open (blocks full task closure):
- Non-ALH standalone price point ($149/month recommended, $99–$199/month working range) is NOT validated. Requires design partner pricing sensitivity probe (task 0002 validation checklist) before locking.

Decided and captured in ADRs: pricing model type (ADR 0002), ALH partner pricing and shared onboarding policy (ADR 0003, superseded by ADR 0005), BD timing (task 0001).

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

- **Allowable resident count distinction (partially resolved — task 0011):** The current CRM implementation uses a single `allowedResidentCount` integer as a placeholder. It may represent (a) licensed facility capacity (CDSS), (b) subscription-tier resident limit (commercial), or (c) active resident count (operational). The UI labels it clearly as "CRM config · not a live care-ops count." Whether to split this into three separate fields remains an open question for a future CRM design task. No Supabase schema has been created — splitting can happen when persistence is implemented.
- **App delivery model:** Is the facility tracker app and/or family member app delivered as a native iOS/Android app store app, a PWA with install prompt, or a web app with a mobile redirect message? This affects onboarding instructions and the feasibility of the mobile-first distribution policy.
- **Onboarding ownership split:** Who owns each onboarding step — internal ALH Tracker staff, the facility owner self-serving through the app, or a hybrid? What steps are tracked in the CRM vs. the tracker app?
- **Payment provider:** Which payment provider will be used? What payment metadata is stored in the CRM vs. held by the provider? (Hard constraint: raw card/bank details must not be stored in the CRM regardless of provider.)
- **CRM roles:** What roles exist within the internal CRM — e.g., sales, onboarding, support, billing, admin? Role granularity affects access control design for the CRM.
- **CRM user authentication model:** What authentication mechanism do ALH Tracker business/admin staff use to access the CRM? Separate from tracker app auth. Pending CRM design.
- **CRM-to-tracker provisioning mechanism (resolved in ADR 0007 — proposed):** ADR 0007 (2026-05-18) selects the custom `provisioning_tokens` table approach (Option B). The Supabase Auth invite API was rejected because it requires the CRM to hold the tracker's Supabase service-role key, violating the CRM/tracker boundary. Key decisions: (a) custom `ProvisioningToken` table with SHA-256 hashed token, 72h expiry, one-time use; (b) Supabase Auth user created at activation time via Admin API — not at provisioning time; (c) `ProvisioningEvent` append-only audit table for the full lifecycle; (d) CRM stores only `provisioning_reference` (opaque) and `provisioning_status` — no tracker credentials. Remaining implementation TODOs: CRM-to-tracker API authentication method (resolved in ADR 0008 — see below), transactional email service selection, Facility record creation timing, resend rate limit, `User.created_by` behavior for provisioned accounts. See ADR 0007 and ADR 0008.
- **iOS Universal Links vs. Android App Links:** The owner activation deep link behaves differently on iOS (Universal Links — requires Apple App Site Association file on the server) and Android (App Links — requires Digital Asset Links file). These mechanisms have different trust models and different server-side configuration requirements. This must be resolved before the app is submitted to the stores. Blocked on native distribution ADR.
- **CRM-to-tracker API authentication (resolved — ADR 0008, 2026-05-19 accepted):** ADR 0008 selects a rotating static API key for MVP, stored exclusively server-side (CRM: Vercel env var `CRM_TRACKER_PROVISIONING_KEY`; tracker: SHA-256 hash in Edge Function secret). Zero-downtime rotation via versioned key slots. Phase 2 hardening: HMAC-signed short-lived JWT. Request contract requires `X-Request-Id`, `X-Idempotency-Key`, `X-CRM-Facility-Id`, `X-CRM-Actor-Id`, `X-Request-Timestamp`. Response returns only `provisioning_reference` (opaque UUID) and `status`. No care data crosses the boundary. Remaining TODOs: idempotency store mechanism, endpoint hosting model, alert delivery. See ADR 0008.
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
- **FamilyUser account creation model (ADR 0006 — proposed, partially resolved):** ADR 0006 documents that family members may create a `FamilyUser` account (identity only, no data access) before owner/admin approval. Account creation does not grant data access. What remains unresolved: (a) whether family members must be invited by owner/admin before creating an account, or may self-register independently; (b) how a family member finds the correct facility at self-signup (invitation code, facility search, or invitation-only model). These are blocking open questions for Phase 2 design.
- **FamilyUser access request rejection behavior:** When an owner/admin rejects a FamilyUser access request, what happens? Notification to FamilyUser? Record of rejection? Behavior is undefined — needs product decision.
- **FamilyUser authentication model:** FamilyUser must authenticate through a mechanism separate from the facility-facing User authentication (ADR 0004, ADR 0006). Whether this is a separate Supabase Auth project, a separate auth table, or another mechanism is unresolved.
- **Family user eligibility model (partially superseded — see above):** The earlier framing ("how family users become associated with a facility for the owner/admin selection step") is now partially answered by ADR 0006: FamilyUser self-signup creates the identity record; the owner/admin selects from pending requests or by proactive search. The remaining open question is whether self-signup requires an invitation code or facility identifier at signup time. Pending Phase 2 design and counsel review.
- **Owner/admin UI for family user selection:** The exact mechanism (dropdown, list, search) depends on the eligibility model — pending Phase 2 design.
- **Behavior when `hipaa_release_status = expired` during grant:** Should the UI surface a warning or block when an owner/admin tries to grant family access to a contact with an expired privacy release status? Behavior is undefined.
- **Multi-resident family member:** A family member linked to two residents (one of whom is archived) should silently hide the archived resident's data or show a "no longer available" state. Behavior is undefined.
- **Resident autonomy override:** ADR 0004 says the system surfaces a warning when `resident_autonomy_noted = false` but does not block. Whether an owner/admin can override the warning and what is additionally recorded in that case is undefined.
- **Notification categories for family members:** Which notification types are approved for family delivery is unresolved.
- **Communication moderation/audit for family-to-facility messaging:** Message types, direction, channels, content scope, and moderation/audit requirements are unresolved.
- **AuditTrail `entity_type` expansion:** The `family_access_consent` type (and all new profile entity types) must be added to the AuditTrail `entity_type` enum when those entities are implemented.

---

### Family access architecture (Task 0006)

Architectural decisions made and captured in ADR 0004 (2026-05-09): separate ResidentContact / FamilyAccessConsent entities; dual acknowledgment required; always read-only; summary-level default; category-scoped; same primary database with row-level authorization; family contacts are not User records; all events logged in AuditTrail.

Still open (blocks Phase 2 family portal):
- Counsel review of consent model and resident autonomy posture (task 0006, Section 2 and 5).
- Counsel confirmation on CPPA/CCPA obligations for family contacts as data subjects.
- Notice and disclosure language for family portal — required before any family contact is given access.
- Design partner validation: how do current operators share care information with families today?
- **Family app as separate mobile/tablet surface (ADR 0005, 2026-05-16):** Family portal is now planned as a separate Phase 2 mobile/tablet app surface. ADR 0004's data access model (read-only, dual acknowledgment, category-scoped, row-level authorization) continues to govern. Stubs present in schema but unpopulated at MVP. Phase 2 blocked on counsel review of consent model.
- **Family app authentication mechanism:** ADR 0004 notes "email magic link or dedicated family portal login" as the approach; specific mechanism (magic link, OTP, password) is unresolved and pending the app delivery model decision.
- **Family-to-facility communications:** Message types, direction, channels, content, privacy review requirements are unresolved. Must not conflict with ADR 0004's "always read-only" constraint on care data — messaging is a separate data category.
- **Family notification types:** What notification types are "important" enough to push to family members, and who authorizes them, is unresolved.
- **Consent and authorization for family access:** How the dual acknowledgment model (ADR 0004) applies to a separate mobile app install flow is unresolved pending the app delivery model decision.

### HIPAA BAA posture

- Do RCFE operators using alh-tracker require a Business Associate Agreement?
- What is the vendor's HIPAA posture before commercial launch?
- This must be resolved before any real resident data is stored under a commercial relationship.

### Title 22 documentation scope (Task 0004)

Desk research complete (2026-05-05). Pending counsel review and sign-off. Key findings:
- § 87506 (resident records): 3-year post-service retention; includes medication records and condition documentation. Whether alh-tracker CareLogEntry records constitute § 87506 "resident records" is an open counsel question.
- § 87211 (incident reporting): Reporting obligation rests with the licensee per regulation text. Whether the vendor has independent obligations is an open counsel question. In-product incident notices required before commercial launch.
- § 87465 (medication management): Medication assistance records must document date, time, dosage, and response. 1-year retention for medication records. alh-tracker ObservedCareTask intentionally omits dosage/name — counsel must confirm whether these records constitute § 87465 medication records.
- § 87411 (personnel): Confirmed compatible with alh-tracker User entity and AuditTrail.
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

**Assumption (2026-05-05):** MVP targets California RCFEs with 6–20 residents currently using paper binders, whiteboards, or verbal handoffs. This profile was chosen as the sharpest initial wedge and closest first-fit.

**Assumption (2026-05-05):** Observed care tasks are caregiver observations only — no MAR/eMAR structure — until compliance and legal review confirms a safe, appropriate path forward.

**Commercial model (decided — see ADR 0002, ADR 0003, superseded by ADR 0005):** Flat monthly per-facility. ALH partners free during design partner + Phase 1 pilot; $49/month at commercial transition. Non-ALH price $99–$199/month working range ($149/month recommended) — NOT yet validated; pending design partner probe.

**Family access architecture (ADR 0004, 2026-05-09 — decided):** ResidentContact / FamilyAccessConsent stubs finalized in data_model.md. Architecture is conservative, consent-first, and read-only by default. Stubs present in schema but unpopulated at MVP. Phase 2 implementation is blocked on counsel review of the consent model — not on architecture decisions.

**Design partner strategy (2026-05-05 — task 0002 planning complete):**

- **Profile (must-have):** California RCFE, active license, 6–20 resident capacity, currently using paper/whiteboard/text/verbal handoff process, no digital shift log software, owner accessible for site visit, at least one caregiver willing to test during a real shift. Located in Temecula, Murrieta, or Menifee (SW Riverside County) — aligns with ALH Phase 1 markets.
- **Profile (disqualifiers):** Already using PointClickCare, MatrixCare, or similar; under active CDSS license action; fewer than 4 active residents; outside California; owner unwilling to allow caregiver participation.
- **Outreach channel priority:** (1) ALH Phase 1 facility contacts — warmest path; (2) CDSS/CCLD Riverside County RCFE registry filtered to capacity 6–20 — cold list; (3) CALCASA/local RCFE networks — lower-certainty; (4) personal referrals if Channels 1–2 stall after 4–6 weeks.
- **Candidate list:** Not yet built. Owner must pull ALH contact list and ca_ccld_registry Riverside County RCFE data, apply filters, and build 5–10 candidate list. Target 30–50 cold contacts to yield 1 committed partner. See `design_partner_tracker.md` — 36+ candidate rows pre-seeded from public data; all rows require CCLD verification before outreach; warm contact section (Section A) is unpopulated — owner must supply from ALH CRM.
- **LOI terms:** Free access during design partner phase; no pricing commitment in the LOI; founding partner rate to be communicated before design partner relationship concludes. No compliance claims. No production dependency. 30-day exit by either party.
- **Outreach script and site visit plan:** Documented in task 0002 Sections 3 and 4. Do not deviate from the language guardrails — no launch date, no pricing, no compliance language.
- **Validation gate for Task 0003:** Shift model and auth questions from the task 0002 validation checklist must have answers from a real facility before task 0003 is activated.

**Caregiver auth starting instinct (2026-05-05):** Named individual accounts for regular caregivers (audit-sensitive actions require traceable identity). Shared tablet mode with quick per-session PIN switch for shared-device facilities. Not finalized — design partner site visit (task 0002) must validate before task 0003 locks the model.

**Title 22 language hard-stops (active constraint):** No compliance claims, no MAR/eMAR claims, no clinical monitoring claims, no medication safety claims, no legal sufficiency claims. Desk research is labeled preliminary research only — not legal advice.

**Task 0008 — offline behavior spec and TA review (2026-05-09/05-10):**

- Offline behavior spec complete. Conservative PWA model: IndexedDB event queue, visible offline banner, automatic sync on reconnect, flag-for-review conflict resolution (no auto-merge or auto-discard). No Background Sync API dependency. Device tier matrix defined (phone priority 1, tablet priority 2, desktop priority 3). Minimum: Android 9+/Chrome 80+, iOS 14+/Safari. One item requires design partner site visit validation: actual WiFi quality at a real facility.
- AI-assisted TA review completed (2026-05-10): spec confirmed technically coherent. **Human TA must still confirm before Phase 1 implementation begins — AI review does not satisfy acceptance criterion 6.**

**ToS draft (2026-05-10):** `projects/alh-tracker/tos_draft_for_counsel.md` created as preliminary draft. Must not be used in any commercial context until counsel has reviewed and approved it.

**Prototype is demo-only (2026-05-11):** Current live app at https://alh-tracker.vercel.app has no authentication, no authorization, all data in browser localStorage (plaintext), no backend. Seed data for 8 named residents persists in every browser. Demo-only banner is live. Must not receive real resident data. Production controls (15 items) documented in `compliance_notes.md` — Security and Privacy Implementation Posture section.

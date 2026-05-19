# alh-tracker — Execution Log

This file records project-specific documentation maintenance activity in mechanical summary form.

Each entry should be one or two lines: what was done, when, and what files were affected.

For retrospective notes and patterns discovered during a task, use `reflection.md`.
For durable decisions, use `decisions\`.

---

## 2026-05-19 (task 0022 — accept ADR 0009)

- ADR 0009 (tracker Facility record creation during CRM provisioning) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md`, `data_model.md`, `features.md`, `user_flows.md`, and `ai_memory.md` proposed references updated in both mirrors. Task doc `0022-accept-adr-0009.md` created in done. No application code changed.

## 2026-05-19 (task 0021 — ADR 0009 architecture review)

- Architecture review of ADR 0009 (tracker Facility record creation during CRM provisioning — status: proposed). Recommendation: **Accept with minor edits** (edits applied in this task).
- No conflicts with ADR 0005/0006/0007/0008 or compliance_notes.md found. All seven review focus areas passed. Documentation consistency confirmed across all 10 updated files.
- Two behavioral edge cases were undocumented — added as TODOs in ADR 0009 Open Implementation TODOs: (1) retry payload conflict behavior (same `X-CRM-Facility-Id`, different `facility_name`) must be specified before implementation; (2) re-provision when `User.account_status = disabled` (revoked invitation) must be specified before implementation.
- ADR 0008 Authorization Scope table row 1 updated: description now includes Facility creation per ADR 0009.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. ADR 0009 status remains `proposed` pending explicit user acceptance.

## 2026-05-19 (task 0020 — ADR 0009: tracker Facility creation during CRM provisioning)

- Architecture/design documentation task. Created ADR 0009 (tracker Facility record creation during CRM provisioning — status: proposed) resolving the facility creation timing blocker deferred in ADR 0007 Step 3a and ADR 0008 request contract.
- Decision: The tracker provisioning API call creates the tracker `Facility` record in `pending_setup` state atomically with the `User` row and `ProvisioningToken`. Allowed CRM-to-tracker facility fields: `facility_name`, `facility_city`, `facility_state`, `license_number` (optional). `Facility.capacity`, subscription resident limit, and allocated resident count are NOT forwarded at provisioning time. Idempotency keyed on `Facility.crm_facility_reference` UNIQUE constraint (= `X-CRM-Facility-Id`). Facility transitions `pending_setup → active` on owner activation.
- ADR 0009 documents: 3 options evaluated (pre-exist, created by provisioning call, created at activation); full facility creation/provisioning sub-sequence; allowed and excluded CRM-to-tracker fields; Facility status lifecycle (pending_setup → active → suspended → closed); idempotency and duplicate prevention; four distinct resident count concepts defined and separated; audit/event requirements (no new ProvisioningEvent types added); 9 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0009 row.
- Updated `decisions/0007-crm-owner-provisioning-token-mechanism.md`: resolved Facility creation TODO in Step 3a and Open Implementation TODOs with ADR 0009 reference.
- Updated `decisions/0008-crm-to-tracker-provisioning-api-authentication.md`: replaced facility association dependency note with resolved facility field table (facility_name, facility_city, facility_state, license_number).
- Updated `data_model.md`: added `provisioning_status` and `crm_facility_reference` fields to Facility entity; added FacilityProvisioningStatus enum; added four resident count concepts table.
- Updated `features.md`: resolved facility creation TODO in CRM Owner account provisioning section; added ADR 0009 reference.
- Updated `user_flows.md`: resolved facility creation TODO in Flow 0 Step 4; updated post-activation Step 8 to reflect pending_setup → active transition.
- Updated `ai_memory.md`: resolved facility creation timing blocker in the CRM open questions section; added ADR 0009 entry.
- Updated `compliance_notes.md`: extended CRM data boundary row with facility fields boundary and resident count concept distinctions.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. No Supabase schema changes.

## 2026-05-19 (task 0019 — accept ADR 0008)

- ADR 0008 (CRM-to-tracker provisioning API authentication) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md`, `ai_memory.md`, and `data_model.md` proposed references updated in both mirrors. Task doc `0019-accept-adr-0008.md` created in done. No application code changed.

## 2026-05-19 (task 0018 — ADR 0008 architecture review)

- Architecture review of ADR 0008 (CRM-to-tracker provisioning API authentication — status: proposed). Recommendation: Accept with minor edits.
- No conflicts with ADR 0005/0006/0007 or compliance_notes.md found. All boundary checks passed. All documentation consistency checks passed. All 7 open TODOs correctly flagged.
- Three documentation gaps fixed in ADR 0008 (both mirrors): (1) added owner role note — CRM-provisioned accounts always receive `role = owner`, server-enforced; (2) added facility association dependency note cross-referencing ADR 0007's facility TODO; (3) added "Intentionally excluded fields" note for `phone` (collected at activation) and `allocated_resident_count` (CRM-side concept).
- ADR 0008 status remains `proposed`. Post-acceptance cleanup documented in task 0018 Outcome. No application code changed.

## 2026-05-19 (task 0017 — ADR 0008: CRM-to-tracker provisioning API authentication)

- Architecture/design documentation task. Created ADR 0008 (CRM-to-tracker provisioning API authentication — status: proposed) resolving the authentication blocker deferred in ADR 0007.
- Decision: rotating static API key (MVP). CRM stores raw key server-side in Vercel env vars (`CRM_TRACKER_PROVISIONING_KEY`); tracker stores only SHA-256 hash(es) of valid keys. Zero-downtime rotation via versioned key slots (V1/V2). Phase 2 hardening: HMAC-signed short-lived service JWT. ADR 0007 service-role key (Option A) remains rejected.
- ADR 0008 documents: 5 options evaluated (static API key, HMAC JWT, asymmetric JWT, OAuth2 client credentials, mTLS); full authentication flow for MVP and Phase 2; secret storage and rotation procedure; least-privilege scope table; request contract (5 required headers + body schema); response contract (opaque `provisioning_reference` + `status` only); idempotency keyed on `X-Idempotency-Key` (24h TTL); two-layer replay prevention (timestamp window ±5 min + idempotency key deduplication); audit/logging requirements (key version logged, raw key never logged); 7 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0008 row.
- Updated `decisions/0007-crm-owner-provisioning-token-mechanism.md`: resolved CRM-to-tracker API auth TODO with ADR 0008 reference.
- Updated `ai_memory.md`: resolved CRM-to-tracker API authentication open question (both the standalone bullet and the CRM provisioning mechanism entry).
- Updated `data_model.md`: added ADR 0008 reference note to User entity provisioning mechanism paragraph.
- Updated `compliance_notes.md`: added CRM-to-tracker provisioning API authentication row to Data Handling Posture table.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. No Supabase schema changes.

## 2026-05-18 (task 0016 — accept ADR 0007)

- ADR 0007 (CRM owner provisioning token mechanism) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md` updated in both mirrors. Task doc `0016-accept-adr-0007.md` created and placed in done. No application code changed.

## 2026-05-18 (task 0015 — ADR 0007 architecture review)

- Architecture review of ADR 0007 (CRM owner provisioning token mechanism — status: proposed). Recommendation: Accept with minor edits. No conflicts with ADR 0004, 0005, or 0006 found. CRM/tracker boundary confirmed intact.
- Three findings requiring edits before acceptance: (1) activation sequence lacked explicit atomicity requirement — fixed in ADR 0007 Phase 2 step 8c (SELECT FOR UPDATE + transaction spanning steps 8c–8i); (2) `token_expired_passive` event type was in the ENUM but missing from Audit/Event Requirements table — added row with background-job requirement and remove-if-not-built note; (3) partial activation recovery (Supabase createUser success + later failure) was unaddressed — added as Open Implementation TODO.
- Two stale TODOs cleaned up in `user_flows.md`: Flow 0 step 5 (expiry/resend/revocation now resolved by ADR 0007) and CRM Flow A step 7 (provisioning mechanism now resolved by ADR 0007). One stale TODO block cleaned up in `features.md` (same).
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. ADR 0007 status remains `proposed` — pending explicit user acceptance. No app code changed. No Supabase schema changes.

## 2026-05-18 (task 0014 — CRM owner provisioning token mechanism, ADR 0007)

- Architecture/design documentation task. Created ADR 0007 (CRM owner provisioning token mechanism — status: proposed) selecting Option B (custom `provisioning_tokens` table) over Supabase Auth invite API. Rationale: Supabase invite API requires CRM to hold tracker service-role key, violating ADR 0005 CRM/tracker boundary; custom table gives full lifecycle auditability and defers Supabase Auth user creation to activation time.
- ADR 0007 specifies: 32-byte hex opaque token, SHA-256 hashed storage, 72h expiry, one-time use, constant-time lookup, four-phase sequence (provision → activate → resend → revoke), `ProvisioningEvent` append-only audit table, CRM provisioning fields (`provisioning_reference`, `provisioning_status`), deep-link routing behavior, full token security model, and 10 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0007 row; corrected ADR 0006 status from Proposed to Accepted.
- Updated `data_model.md`: promoted `ProvisioningToken` from "TODO — Conceptual" to fully specified (ADR 0007); updated account_status TODO to note mechanism resolved; added `ProvisioningEvent` new entity (append-only audit); added CRM provisioning fields note to CRM entity model section.
- Updated `ai_memory.md`: narrowed CRM provisioning mechanism open question (resolved to ADR 0007 Option B); retained iOS/Android deep-link TODO; added CRM-to-tracker API authentication as new open question.
- Updated `user_flows.md`: updated Flow 0 step 4 TODO to reference ADR 0007 mechanism decision.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No app code changed. No Supabase schema changes. No deployment.

## 2026-05-18 (ADR 0006 accepted — CRM owner provisioning and family account approval)

- ADR 0006 status updated from `proposed` to `accepted` in both mirrors. Removed `(proposed)` qualifiers from ADR 0006 references in `compliance_notes.md` in both mirrors. Created task doc `0013-accept-adr-0006.md` and moved to done.

## 2026-05-18 (ADR 0006 review — CRM owner provisioning and family account approval)

- Architecture review of ADR 0006 (proposed). Recommendation: Accept with minor edits. No conflicts found with ADR 0004 or ADR 0005. One documentation gap fixed: added five missing optional FamilyUser fields from ADR 0006 Section 6 (occupation, facility_association, emergency_contact_role, privacy_release_status, resident_access_request) as TODO entries in `data_model.md` FamilyUser entity table — mirrored to ai-workspace-framework. ADR 0006 status remains `proposed` pending explicit user acceptance.

## 2026-05-18 (task 0012 — CRM owner provisioning and family account flow)

- Documentation-only task. Created ADR 0006 (CRM owner provisioning and family account approval — status: proposed, requires human review before accepted) in both mirrors. Updated ADR 0005 Section 4 (resolved the CRM-to-tracker provisioning handshake TODO with a 7-step conceptual flow). Updated `decisions/README.md` (added ADR 0006 row; clarified app delivery model ADR remains pending).
- Rewrote `user_flows.md` Flow 0 (CRM onboarding + owner activation deep link with 3 routing cases), CRM Flow A Step 7 (provisioning action), and Family Member Onboarding (split into Phase A identity-only account creation and Phase B owner/admin approval). Added new Flow 14 (Owner/Admin Family Access Management: pending/active/revoked grant views, proactive initiation).
- Updated `features.md`: added CRM owner account provisioning to Conceptual/TODO section; updated onboarding milestones; rewrote Family User Eligibility to reflect FamilyUser self-signup (account ≠ data access); added Owner/Admin Family Access Management subsection; updated Role Permissions Summary table to distinguish FamilyUser-no-consent from FamilyUser-with-active-grant.
- Updated `overview.md`: CRM surface description now includes owner account provisioning (forward write only); Family Member App description updated with FamilyUser account creation model and ADR references.
- Updated `data_model.md`: added `account_status` field and AccountStatus enum to User entity; added ProvisioningToken conceptual entity (opaque/expiring/one-time-use token security properties); added FamilyUser entity (identity-only, NOT User table, NOT FamilyAccessConsent); updated FamilyAccessConsent to link via `family_user_id` (not contact_id).
- Updated `ai_memory.md`: narrowed CRM provisioning handshake open question (conceptual flow resolved; implementation mechanism still open); added iOS Universal Links / Android App Links TODO; added Supabase Auth invite API compatibility TODO; added FamilyUser self-registration vs. invite-only and rejection behavior TODOs.
- Updated `compliance_notes.md`: added FamilyUser pre-approval account language (no data access granted by account existence); added CRM forward-write-only boundary note; added owner activation token security row to Data Handling Posture table.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No app code changed. No Supabase schema changes. No deployment.

## 2026-05-17 (task 0011 — CRM facility management)

- Implemented CRM facility create, edit, archive, and allowable resident count management.
- **New files:** `src/store/useCrmStore.ts` (Zustand session store for CRM: facilities, communications, notes, followUps — initialized from seed, not persisted); `src/pages/crm/FacilityFormModal.tsx` (shared modal for create and edit with full CRM field set and positive-integer validation for allowedResidentCount).
- **Modified files:** `src/types/crm.ts` (added `archived`, `archivedAt` to `CrmFacility`); `src/pages/crm/CrmFacilities.tsx` (connected to store, added "Add facility" button, allowable resident count column, archived toggle, post-create navigation); `src/pages/crm/CrmFacilityDetail.tsx` (connected to store, added edit modal, archive confirmation dialog, archived-state banner, all actions routed through store); `src/pages/crm/CrmDashboard.tsx` (connected to store, all counts filter archived facilities).
- Data boundary confirmed: no resident care types imported in CRM files. No Supabase schema/migration changes.
- Build passed clean (`tsc && vite build`). Task doc created in both mirrors: `tasks/active/alh-tracker/0011-crm-facility-management.md`.
- Updated `features.md` (Internal CRM section expanded from stub to implemented spec), `data_model.md` (CRM entity model section updated with actual field definitions), `ai_memory.md` (allowable resident count open question partially resolved), `README.md` (internal CRM section added).
- Subagents: not used for implementation (store → pages is a sequential dependency chain). Documentation mirror writes were parallelized within the main agent.

## 2026-05-17 (task 0010 — Internal CRM MVP — smoke test verification)

- Ran smoke test on dev server (`npm run dev`): all required routes returned 200 OK — `/crm`, `/crm/facilities`, `/crm/facilities/crm-fac-001`, `/`, `/family`.
- Code review confirmed: CRM pages render without blank screens; search/filter (CrmFacilities) functional; add note, add follow-up, mark follow-up done, add communication log entry (CrmFacilityDetail) all functional; no resident care types imported in any CRM file.
- Checked off smoke test item in task 0010 acceptance criteria. Moved `tasks/active/alh-tracker/0010-internal-crm-mvp.md` to `tasks/done/alh-tracker/0010-internal-crm-mvp.md` in both mirrors.
- Data boundary confirmed: CRM files import no resident care types. CRM uses fake/demo data only.
- No Supabase schema changes. No deployment changes. Build passed clean (`tsc && vite build`).

---

## 2026-05-17 (task 0010 — Internal CRM MVP — implementation)

- Built first usable internal CRM surface as a separate route tree (`/crm`) in the existing React/Vite app.
- Architecture decision: CRM implemented in this repo as a separate surface, matching the family portal pattern (`/family`), consistent with ADR 0005. No conflict with docs.
- **New files:**
  - `src/types/crm.ts` — CRM-specific TypeScript types (CrmFacility, CrmOnboardingStage, CrmSubscriptionStatus, CrmCommunicationEntry, CrmNote, CrmFollowUp, etc.). Explicitly separate from resident/care types.
  - `src/data/crm-seed.ts` — 7 demo/fake facilities with communications, notes, and follow-ups. No real data.
  - `src/components/CrmLayout.tsx` — dark-slate desktop sidebar layout, separate from facility tracker Layout; internal-only warning banner on every screen; TODO auth badge.
  - `src/pages/crm/CrmDashboard.tsx` — pipeline summary counts, onboarding counts, open follow-up list, priority notes, facilities table.
  - `src/pages/crm/CrmFacilities.tsx` — facilities list with search and subscription status filter.
  - `src/pages/crm/CrmFacilityDetail.tsx` — facility profile, owner contact, onboarding checklist, follow-up management (add/mark done), support notes (add/edit), communication log (add entry). All local state / demo only.
- **Modified files:**
  - `src/App.tsx` — added `/crm`, `/crm/facilities`, `/crm/facilities/:id` routes under CrmLayout. CRM auth is TODO per ADR 0005; route is unguarded in demo prototype mode.
- CRM data boundary enforced: CRM files import no resident care types (CareLogEntry, Resident, WellnessObservation, FollowUp) from `src/types/index.ts`.
- No Supabase schema changes. No real payment processing. No resident care data in CRM views.
- Build passed clean (`tsc && vite build`).
- Task doc created: `tasks/active/alh-tracker/0010-internal-crm-mvp.md` (mirrored to ai-workspace-framework).

---

## 2026-05-16 (documentation review and task queue cleanup)

- Ran four-subagent documentation review: Documentation Inventory, Product/Business, Compliance/Data Boundary, and Task Queue reviewers.
- **overview.md:** Added compliance caveats to product mantra ("positioning goal — no compliance claims without counsel review"), Later Expansion MAR/eMAR-adjacent language (separate legal review required), and "Daily care visibility" phrase (pending Phase 2 counsel review). Updated Pinned Versions section with actual selected tech stack (React 18 + TypeScript, Vite, Tailwind CSS, Zustand, React Router v6, Supabase).
- **compliance_notes.md:** Updated "Current Prototype State" table to note it has been superseded by Supabase production backend; added current status notes per control; added hard "blocked on counsel review" requirement to family-to-facility communications TODO.
- **features.md:** Updated stale "uses localStorage with no authentication" prototype state note to reflect Supabase migration.
- **tasks/active/0001:** Checked off ADR 0003 (created 2026-05-09) and shared onboarding/billing decision (ADR 0003 + ADR 0005) as complete. Added "blocked on external execution (task 0002)" note for remaining items.
- **tasks/active/0004:** Updated documents list — ToS draft reference corrected from "not yet written" to reference `tos_draft_for_counsel.md` (created 2026-05-10).
- **tasks/backlog/README.md:** Updated Phase 0 task status table to reflect actual queue state (tasks 0001/0002/0004/0006/0008 are active; 0003/0005/0007 remain in backlog). Added new tasks 0009/0010/0011 to table.
- **decisions/README.md:** Replaced stale "Expected First ADRs" with actual ADR table (ADRs 0001–0005, all accepted) and updated pending ADR list.
- **ai_memory.md:** Corrected "git master" to "git main". Added HIGH RISK label and task 0009 reference to retention and deletion policy section.
- **New task 0009:** `tasks/backlog/0009-data-retention-policy.md` — pre-commercial-launch blocker; defines retention periods, account closure procedure, Supabase PITR alignment.
- **New task 0010:** `tasks/backlog/0010-crm-design-open-questions.md` — resolves 9 open questions from ADR 0005 before CRM design begins.
- **New task 0011:** `tasks/backlog/0011-resident-profile-data-model-expansion.md` — defines expanded resident entity designs to unblock task 0005.
- No app code changed. No schema changes. No deployment.

---

## 2026-05-11 (session 10 — UI redesign for caregiver clarity)

- Redesigned 6 of 7 app pages for caregiver clarity. Guiding principles: urgent-first, one purpose per page, primary action obvious, reduce competing cards, caregiver language.
- **Dashboard.tsx** — full rewrite. Removed 5 separate alert cards. Replaced with one unified "Needs attention today" section listing all alert types (missed transport, not returned, room not made up, high follow-ups, wellness concerns, normal follow-ups, upcoming transport) in a single prioritized list with colored dots. Green "All looking good" card when nothing needs attention. Secondary stats row (4 cols) and simplified Quick Access (5 rows, no descriptions).
- **Residents.tsx** — added per-resident alert badges (severe allergy, allergy on file, open follow-ups count, room not made up, transport attention) computed per card in the map callback from store slices.
- **ActivityLog.tsx** — renamed form title to "Log a care observation"; added numbered step labels (1. Who? / 2. What type? / 3. How did it go? / 4. Note) to the 4-step form flow.
- **WellnessObservations.tsx** — renamed form title to "Record a wellness observation"; added numbered step labels (1. Who? / 2. What area? / 3. How are they doing? / 4. Note) to the form flow.
- **FollowUps.tsx** — removed priority filter row (all/high/normal/low buttons removed; `priorityFilter` state retained at 'all' but no UI to change it). Resolved items rendered at `opacity-55` to visually quiet them.
- **HandoffSummary.tsx** — replaced dark brand-colored stats header with clean 3-col white stats grid (entries today, exceptions, open follow-ups) with red highlight when nonzero. Added conditional "Shift alerts" amber callout block for missed pickups/not returned/incomplete rooms. Replaced verbose amber disclaimer with quieter border-only box. Added per-resident room check and transport sections (already present from Phase 4).
- ResidentDetail.tsx not changed — structure already aligned with redesign goals.
- Build passed clean (`tsc && vite build`). Committed as `221fe19` ("Simplify app UI for caregiver clarity"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md`, `ai_memory.md`, `execution_log.md` (this entry).

---

## 2026-05-11 (session 9 — Phase A demo-only banner)

- Added fixed amber "Demo only" warning banner to `src/components/Layout.tsx`: displays at the bottom of every screen on all device sizes. Text: "Demo only — do not enter real resident data." Amber background (`bg-amber-50`), amber border, amber icon (`AlertTriangle`), amber text. `z-20` fixed positioning — does not conflict with sidebar (no z-index) or mobile drawer (z-40).
- Added `pb-10` to main content wrapper to prevent page content from being hidden behind the banner.
- Build passed clean. Committed as `fa8577a` ("Add demo-only warning banner"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md` (prototype status note with commit hash), `ai_memory.md` (Phase A session 9 entry), `execution_log.md` (this entry).

---

## 2026-05-11 (session 8 — security and privacy architecture plan)

- Produced security and privacy implementation plan for alh-tracker based on review of all 7 project context files plus current app source (store, types, seed, App.tsx, package.json).
- Confirmed current prototype security state: no authentication, no authorization, all data in browser localStorage (plaintext), no backend, hardcoded seed user. Seed data for 8 named residents persists in any browser that visits alh-tracker.vercel.app. Prototype is demo-only.
- Updated `compliance_notes.md`: added "Security and Privacy Implementation Posture" section covering current prototype state table, data classification by sensitivity, required security architecture (authentication, RBAC, tenant isolation, AuditTrail, session/device security, password/MFA policy, user deactivation), data protection requirements (encryption, localStorage risk and replacement plan, secrets management, backups, export controls, deletion/retention), HIPAA-adjacent risk assessment, 15-item must-have checklist, and 7 open security/privacy counsel questions.
- Updated `data_model.md`: added security notes block in preamble (tenant isolation requirement, sensitive data categories, encryption, AuditTrail integrity, localStorage prototype-only note); extended AuditTrail entity note with database-level write-once constraint requirement and identity preservation requirement.
- Updated `features.md`: added "Production Security Prerequisites" section (15-item checklist of controls required before real data, with reference to compliance_notes.md for full detail).
- Updated `tos_draft_for_counsel.md`: added Section 10 (Security Controls, Access, and Data Handling Standards) with 7 PENDING COUNSEL questions (Q-S1 through Q-S6) covering HIPAA Security Rule safeguards, California law security obligations, SOC 2 certification, breach notification timeline, caregiver identity retention, and audit log compliance claim risk; updated open issues table with Section 10 rows.
- Updated `ai_memory.md`: added dated security planning entry summarizing key findings, must-have controls, and open questions.
- No app code changed. No deployment.

---

## 2026-05-11 (session 7 — data model doc cleanup)

- Fixed duplicate `ResidentContact` definition in `projects/alh-tracker/data_model.md`. The file contained two definitions: the implemented operational entity added in Phase 4 (Entities section) and the original family-access stub (Family Access Stub section). Removed the stub definition. Updated the Family Access Stub preamble to reference the canonical ResidentContact in the Entities section and clarify that: having a ResidentContact record does not authorize family portal access; `hipaa_release_status` is operational tracking only and not legal validation or portal consent; `FamilyAccessConsent.contact_id` will reference the canonical entity when built. Updated `FamilyAccessConsent` to note it is not yet implemented and is blocked on counsel review (task 0006). One `ResidentContact` definition now exists in the file.

---

## 2026-05-11 (session 7 — Phase 4 app build)

- Added 5 new operational features to the live alh-tracker MVP: Preferences, Main Contact / HIPAA Release Status, Allergies & Triggers, Room Made Up / Sheets checklist, and Transport Pickup for Appointment.
- Modified `src/types/index.ts`: added `HipaaReleaseStatus`, `PickupStatus`, `ReturnStatus` type literals; added `ResidentPreferences`, `ResidentContact`, `AllergiesTriggers`, `RoomChecklist`, `AppointmentTransport` interfaces; added label constant records for all three new enums.
- Modified `src/data/seed.ts`: added `tomorrow()` helper; added `SEED_PREFERENCES`, `SEED_CONTACTS`, `SEED_ALLERGIES`, `SEED_ROOM_CHECKLISTS`, `SEED_APPOINTMENT_TRANSPORTS` seed exports for all 8 residents.
- Rewrote `src/store/useStore.ts`: added 5 new state collections and 6 new store actions (`upsertPreferences`, `upsertContact`, `upsertAllergies`, `upsertRoomChecklist`, `addAppointmentTransport`, `updateAppointmentTransport`).
- Rewrote `src/pages/ResidentDetail.tsx`: added Profile tab (4th tab) with inline-editable sections for Allergies & Triggers, Room Check Today, Transport & Appointments, Main Contact & HIPAA, Preferences. Added allergy warning banner below the resident header card, visible on all tabs.
- Modified `src/pages/ActivityLog.tsx`: added allergy warning banner when a resident with documented allergies is selected.
- Modified `src/pages/Dashboard.tsx`: added operational alerts section above the follow-ups/concerns grid — shows incomplete rooms and missed/upcoming/not-returned transport appointments.
- Modified `src/pages/HandoffSummary.tsx`: added room check and transport status sections to each per-resident card in the handoff.
- Build passed clean (`tsc && vite build` — no errors). Committed as `edaa187` ("Add resident profile operations fields"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md`, `data_model.md`, `user_flows.md`, `ai_memory.md`, `execution_log.md`.

---

## 2026-05-11 (session 6)

- Fixed two broken relative links in `projects/alh-tracker/next_7_days_owner_checklist.md`: Item 3 (counsel packet link) and Item 6 (Task 0008 link) both used `../../ai-workspace-framework/...` — corrected to `../../../ai-workspace-framework/...` to resolve from the file's directory to `C:\Projects\ai-workspace-framework\`.
- Updated `projects/alh-tracker/phase_0_owner_action_packet.md` Action 5: added explicit reference to the AI-Assisted Technical Review Note in Task 0008 (added Session 4, 2026-05-10); clarified that AI review does not satisfy acceptance criterion 6. Updated "Document last updated" to reflect Session 4/5 actual update date (2026-05-10).
- Updated `projects/alh-tracker/ai_memory.md` with session 6 maintenance note.

---

## 2026-05-10 (session 5)

- Verified Session 4 cross-references. Found one gap: `design_partner_tracker.md` not referenced in `phase_0_owner_action_packet.md`. Fixed in three places: Action 1 checklist, Section 3A Step 3, and Section 3B outreach tracker paragraph.
- Added counsel email cover note to `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: covers the routing ask, lists five documents to attach, articulates Priority 1 Q1–Q4 ask and Phase 2 Q5–Q10 ask. Labeled preliminary / not legal advice throughout. No content changed in other sections.
- Created `projects/alh-tracker/next_7_days_owner_checklist.md`: six operational items (warm list, CCLD verification, counsel routing, first outreach, $49/month rate confirmation, TA review scheduling). Each item has exact time estimate, source file reference, and completion signal. No strategic content.
- Updated `projects/alh-tracker/ai_memory.md` with Session 5 verification findings and additions.

---

## 2026-05-10 (session 4)

- Conducted Phase 0 state assessment: confirmed complete items (4 ADRs, task 0002 planning, task 0004 desk research, task 0008 spec), active tasks (0001/0002/0004/0006/0008), and hard-blocked tasks (0003/0005/0007). No task statuses changed — no acceptance criteria were newly satisfied this session.
- Created `projects/alh-tracker/design_partner_tracker.md`: candidate list pre-seeded from third-party directory data (seniorguidance.org for Temecula and Menifee; aplaceformom.com for Murrieta). 36+ candidate rows across Temecula (14), Murrieta (17), Menifee (8), and adjacent geography (Wildomar). Includes scoring guide, CCLD verification instructions, outreach status key, and a Section A placeholder for owner-supplied ALH warm contacts. Key finding: area is dominated by 6-bed homes; no 10–16 capacity facilities identified in public data. All rows require CCLD verification before outreach.
- Created `projects/alh-tracker/tos_draft_for_counsel.md`: preliminary draft ToS / data handling addendum for counsel review. Nine sections covering vendor role, record ownership, retention (with counsel-answer placeholders), account closure and record disposition, export/return/deletion rights, HIPAA BAA posture (explicitly unresolved), no compliance certification, data security / breach notification, and amendment process. Open issues table maps each unresolved provision to the specific counsel question. Labeled clearly as draft only — not legal advice.
- Updated `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: updated supporting documents table row for ToS draft to reference the new file.
- Updated `projects/alh-tracker/phase_0_owner_action_packet.md`: marked ToS draft checklist item as complete; referenced `tos_draft_for_counsel.md`.
- Updated `tasks/active/alh-tracker/0008-device-and-offline-behavior.md`: added AI-Assisted Technical Review Note section. Reviewed IndexedDB queue, offline banner, reconnect sync, conflict flagging, no Background Sync dependency, and minimum browser targets. All confirmed technically coherent. Added 4 implementation notes (service worker registration, IndexedDB schema versioning, stale-while-revalidate cache behavior, 200-entry queue capacity). No blocking issues. Human TA still required to satisfy acceptance criterion 6.
- Updated `projects/alh-tracker/ai_memory.md`: added task 0008 TA review note, design partner tracker creation, and ToS draft creation.

---

## 2026-05-09 (session 3)

- Created `projects/alh-tracker/phase_0_owner_action_packet.md`: owner-facing Phase 0 action guide consolidating status snapshot (complete/active/blocked/do-not-start), 5-item owner action checklist ordered by leverage, design partner execution worksheet (candidate scoring table, outreach tracker, site visit questions organized by what they unblock: tasks 0003/0001/0006/0008), combined counsel routing checklist (task 0004 Priority 1 questions + task 0006 family access questions Q5–Q10), 4-ADR decision log summary, and explicit do-not-start gate list.

---

## 2026-05-09 (session 2)

- Fixed task 0002 formatting (`tasks/active/alh-tracker/0002-design-partner-criteria-and-outreach.md`): renamed LOI internal clause headers from "Section N" to "Clause N" to eliminate naming collision with the outer document's Section 8 (Candidate List); removed duplicate `---` separator; renamed Section 8 heading for clarity.
- Activated task 0006: created `tasks/active/alh-tracker/0006-family-access-architecture.md` with full architectural specification (family-resident association model, dual-authorization consent model, read-only/summary-default access scope, same-database row-level authorization, resident autonomy posture, 7-item open-questions register for counsel). Deleted `tasks/backlog/alh-tracker/0006-family-access-architecture.md`.
- Created `decisions/0004-family-access-architecture.md` (ADR, accepted): locks family access as read-only, summary-default, category-scoped, dual-acknowledgment, same-database, family contacts not User records, all access audited.
- Updated `data_model.md` family access stubs: ResidentContact — removed `is_authorized_viewer` (authorization is in FamilyAccessConsent), added `contact_type` enum and `is_active`; FamilyAccessConsent — renamed `scope` to `category_scope`, added `access_level` enum (summary/full_notes), added `resident_autonomy_noted` boolean nullable, added `resident_autonomy_notes` text, added `granted_by` role constraint note.
- Updated `compliance_notes.md`: added "Family Access and Consent Posture" section (clearly labeled preliminary / not legal advice / pending counsel review) covering what family access is and is not, resident autonomy posture, and 6 open counsel questions for Phase 2.
- Updated `ai_memory.md`: resolved family access open questions with architectural decisions from ADR 0004; replaced stale assumption entry; noted remaining Phase 2 blocks (counsel review, design partner validation, disclosure language).

---

## 2026-05-09 (session 1)

- Created `decisions/0003-business-model-alh-pricing.md` (ADR, accepted): locks ALH partner pricing as free during design partner + Phase 1 pilot, then $49/month add-on at commercial transition; documents no-shared-onboarding/billing policy at MVP; retains non-ALH price as working assumption ($149/month recommended, not validated).
- Updated task 0001 (`tasks/active/alh-tracker/0001-business-model-and-alh-relationship.md`): marked ALH partner policy, shared onboarding/billing recommendation, and full ADR checklist items as complete; narrowed remaining-to-close list to non-ALH validation and support model.
- Updated task 0002 (`tasks/active/alh-tracker/0002-design-partner-criteria-and-outreach.md`): added Section 8 — owner-execution candidate list checklist with CCLD search instructions, spreadsheet structure, ranking rules, and outreach sequencing (no internet access; public registry method only).
- Created `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: standalone 2-page counsel brief packaging all 9 priority questions from task 0004 Section 6, product description, what-it-is-not, and supporting document list. Clearly labeled as preliminary research / not legal advice.
- Updated task 0004 (`tasks/active/alh-tracker/0004-title-22-documentation-review.md`): marked counsel packet prepared; updated remaining-to-close to reference the packet file.
- Activated task 0008: created `tasks/active/alh-tracker/0008-device-and-offline-behavior.md` with full offline behavior spec (device tier matrix, offline detection, IndexedDB queue, pre-cached data, sync strategy, conflict resolution — flag for review, no auto-merge/discard, no Background Sync API dependency, minimum browser/OS requirements). Deleted `tasks/backlog/alh-tracker/0008-device-and-offline-behavior.md`.
- Updated `features.md`: added Offline Behavior Specification section (inline summary of task 0008 spec) to device support section.
- Updated `ai_memory.md`: resolved business model open questions (ADRs 0001-0003 all accepted); added task 0008 activation status; narrowed remaining open items to non-ALH price validation and Technical Architect confirmation of offline spec.

---

## 2026-05-05

- Created initial alh-tracker AI context framework scaffold: `overview.md`, `data_model.md`, `features.md`, `user_flows.md`, `compliance_notes.md`, `ai_memory.md`, `execution_log.md`, `decisions\README.md`.
- Created task directories with README files: `tasks\active\alh-tracker\`, `tasks\backlog\alh-tracker\`, `tasks\done\alh-tracker\`.
- Created eight backlog task documents: 0001 through 0008 covering business model, design partner, shift model, Title 22 review, data model, family access, logging UX, and device/offline behavior.
- Updated `ai-context\README.md` to add alh-tracker to the Projects Index and Start Here use-case table.
- Updated `ai-context\CHANGELOG.md` with v0.2 entry.
- Updated `ai-context\orchestration\context_rules.md` to generalize the Default Context Loading Sequence and add alh-tracker context file references.
- Conducted Phase 0 planning assessment: identified task dependencies, recommended activation order, and listed key owner-answered questions for tasks 0001–0004.
- Activated tasks 0001, 0002, and 0004: moved from `tasks\backlog\alh-tracker\` to `tasks\active\alh-tracker\`; updated status field to active and added planning notes in each task document reflecting strategic direction.
- Task 0003 (shift model and caregiver auth) remains in backlog pending design partner site visit from task 0002.
- Updated `projects\alh-tracker\ai_memory.md`: added working direction entry for business model, design partner profile, caregiver auth instinct, and Title 22 research posture.
- Worked task 0001 (business model and ALH relationship): wrote full recommendation covering standalone and partner pricing models, ALH relationship framing, data boundary, rollout phases, and risks/open questions. Updated plan checklist; 5 of 8 items complete. Created `decisions/0001-data-boundary-alh-tracker-vs-alh.md` and `decisions/0002-pricing-model-type.md`. Task 0001 remains active — ALH partner rate, non-ALH price validation, and shared workflow question still open. Updated `ai_memory.md` with task 0001 in-progress state.
- Worked task 0002 (design partner criteria and outreach): wrote full design partner profile (must-have criteria, nice-to-have, disqualifiers), outreach channel priority and candidate list strategy, outreach scripts, site visit discovery plan, LOI outline, validation checklist for tasks 0001 and 0003, and risk register. Plan checklist items 1–3 complete. Task 0002 remains active — candidate list build, outreach execution, site visit, committed partner, and LOI are required to close. Updated `ai_memory.md` with durable design partner strategy.
- Worked task 0004 (Title 22 documentation review): desk research complete on § 87506 (resident records, 3-year retention), § 87211 (incident reporting, licensee obligation), § 87465 (medication management, 1-year retention, MAR boundary), § 87411 (personnel records, caregiver identity). Produced full mapping table, data model preserve/omit/validate assessment, extended language avoidance list, required in-product disclosures, and structured counsel brief (9 questions in priority order). Plan checklist items 1–6 (desk research) complete. Task 0004 remains active — counsel review and sign-off required. Updated `compliance_notes.md` with preliminary research section (labeled). Updated `ai_memory.md` with Title 22 research status and refined retention policy open questions.

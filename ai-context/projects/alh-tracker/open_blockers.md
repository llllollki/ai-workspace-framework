# alh-tracker — Open Blockers

**Updated:** 2026-05-17
**Audience:** Product / Program Lead
**Purpose:** Concise view of blockers that must clear before commercial launch or Phase 1 implementation. Each item references its source document — do not duplicate content here.

---

## Pre-Commercial-Launch Blockers

These items must be resolved before any real resident data enters production under a commercial relationship or before a commercial launch date is set.

### 1. Retention and Deletion Policy — HIGH RISK

**Status:** No policy defined
**Source:** Task 0009 — `tasks/active/alh-tracker/0009-retention-deletion-policy.md`
**Blocked by:** Counsel answers to Q1, Q2, Q4, Q6 in `0038-counsel-handoff-packet.md`

No retention policy exists at the Supabase production database level. Account closure behavior, caregiver deactivation/anonymization policy, and Supabase PITR backup retention alignment are all undefined. Until counsel answers the Priority 1 questions, no real resident data may enter production under any commercial relationship.

**Next action:** Route `0038-counsel-handoff-packet.md` to counsel immediately. Task 0009 is covered by the same engagement — no separate outreach needed.

---

### 2. HIPAA BAA Posture

**Status:** Unresolved
**Source:** `projects/alh-tracker/ai_memory.md` (HIPAA BAA posture section); task `0038-counsel-handoff-packet.md` Question 2c

Whether alh-tracker must offer a HIPAA Business Associate Agreement to facility operators is open. Until this is resolved, the product must not represent itself as HIPAA-covered or BAA-eligible in any commercial context.

**Next action:** Addressed in the same counsel engagement as tasks 0004 and 0009. No additional action beyond routing the existing packet.

---

### 3. Terms of Service — Counsel Review Required

**Status:** Draft exists; not counsel-reviewed
**Source:** `projects/alh-tracker/tos_draft_for_counsel.md`
**Blocked by:** Counsel review of Priority 1 questions (tasks 0004, 0009)

The ToS draft is preliminary only. It must not be used in any commercial context until counsel has reviewed and approved it. Each open provision in the draft is explicitly mapped to the counsel question that must resolve it.

**Next action:** Send `tos_draft_for_counsel.md` alongside `0038-counsel-handoff-packet.md` in the same counsel engagement.

---

## Phase 1 Implementation Blocker

This item blocks Phase 1 technical implementation (application code). It does not block Phase 0 documentation or design partner outreach.

### 4. Task 0008 AC 6 — Human Technical Architect Confirmation

**Status:** Spec written; AI-assisted review complete; human TA written sign-off not yet received
**Source:** Task 0008 — `tasks/active/alh-tracker/0008-device-and-offline-behavior.md`, Acceptance Criterion 6

The offline behavior spec (IndexedDB queue, dual-timestamp model, conflict-flagging, no Background Sync API dependency, minimum browser targets) was reviewed by AI and found technically coherent. AI review does not satisfy AC 6. A human Technical Architect must confirm in writing before Phase 1 implementation begins.

**TA must confirm:**
- IndexedDB queue, dual-timestamp model, and conflict-flagging approach are compatible with Phase 1 architecture plans
- No-Background-Sync-API decision is confirmed given the target device class (Android 9+/Chrome 80+, iOS 14+/Safari)
- Minimum browser targets are acceptable

**Next action:** Owner schedules 60–90 min TA review session. Share `0008-device-and-offline-behavior.md` beforehand. Record written TA response in task 0008 AC 6.

---

## Design Partner Blockers

These items gate on a committed design partner. Tasks 0003, 0005 (partial), 0007, and WiFi assumption validation all depend on a real site visit.

### 5. Design Partner Candidate List — Not Yet Built

**Status:** Outreach strategy and scripts ready; ALH warm contact list unpopulated
**Source:** `design_partner_tracker.md` Section A; task 0002 Outcome; `next_7_days_owner_checklist.md` Item 1

The warm contact list (Section A of the design partner tracker) has no rows. The owner must pull ALH CRM/facility partner contacts, filter for SW Riverside County RCFE, capacity 6–20, no existing digital shift log software, and populate at least 3 candidates before outreach can begin.

**Next action:** Owner opens ALH CRM, applies filters (RCFE license, Temecula/Murrieta/Menifee, capacity 6–20), and fills Section A with ≥3 rows including owner name and contact method.

---

### 6. Non-ALH Standalone Price — $149/Month Not Validated

**Status:** Working range only; not validated
**Source:** `ai_memory.md` (business model section); ADR 0002; task 0001
**Unblocked by:** First design partner committed (task 0002) and pricing sensitivity probe conducted

$149/month is the recommended point in the $99–$199/month working range. It is NOT a confirmed or locked price. Design partner pricing sensitivity conversations are required before this is locked. No market validation is available without a committed partner.

**Next action:** No action available yet — gated on design partner commitment (Item 5 above).

---

## Summary Table

| # | Blocker | Category | Gate | Source |
|---|---|---|---|---|
| 1 | Retention/deletion policy | Commercial launch | Counsel Q1, Q2, Q4, Q6 | Task 0009 |
| 2 | HIPAA BAA posture | Commercial launch | Counsel Q2c | Task 0004 counsel packet |
| 3 | ToS counsel review | Commercial launch | Counsel all Priority 1 | `tos_draft_for_counsel.md` |
| 4 | TA confirmation for offline spec | Phase 1 implementation | Human TA written sign-off | Task 0008 AC 6 |
| 5 | Design partner candidate list | Phase 1 / design validation | Owner: build list from ALH CRM | `design_partner_tracker.md` Section A |
| 6 | Non-ALH price validation | Commercial launch | Design partner committed + probe | Task 0001 / ADR 0002 |

---

**Items 1–3 share one counsel engagement.** Routing `0038-counsel-handoff-packet.md` alongside `tos_draft_for_counsel.md` covers all three. Routing is the single highest-leverage action available right now.

**Item 4** does not block any Phase 0 work — it only blocks Phase 1 kickoff.

**Item 5** is the highest-leverage Phase 0 owner action — nothing in Phase 1 starts without a committed design partner.

**Item 6** is gated entirely on Item 5 — no parallel path exists to validate pricing without a committed partner.

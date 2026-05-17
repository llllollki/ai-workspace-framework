# Task 0009 — Retention and Deletion Policy

**Project:** alh-tracker
**Status:** active
**Created:** 2026-05-17
**Owner role:** Product / Program Lead
**Reviewers:** Compliance / Privacy Counsel, Technical Architect

---

## Goal

Define the retention and deletion policy for alh-tracker before any real resident data enters production under a commercial relationship.

No retention policy exists at the Supabase (production database) level as of 2026-05-16. This is a HIGH RISK pre-commercial-launch blocker. Until this policy is defined and counsel-confirmed:

- No real resident care data may be stored in production under any commercial relationship.
- Account closure behavior is undefined — the system cannot responsibly terminate a facility account.
- Caregiver deactivation behavior for AuditTrail identity references is undefined.
- Supabase PITR backup retention alignment with legal minimum retention is unverified.

This task is documentation-first: define the policy decisions required, route open legal questions to counsel (via the existing task 0004 counsel engagement), and record the technical implementation actions needed. Do not implement data retention logic in application code until counsel has answered the Priority 1 retention questions in task 0004.

---

## Acceptance Criteria

1. **Title 22 retention periods confirmed:** Counsel has confirmed which § 87506 (3-year post-service) and § 87465 (1-year medication records) retention obligations apply to alh-tracker as a software vendor — not just the facility licensee. (Counsel questions Q1 and Q2 in `0004-counsel-handoff-packet.md`.)

2. **Minimum retention policy documented by record type:** A written policy defines minimum retention periods for each alh-tracker record category:
   - CareLogEntry (shift log entries)
   - ObservedCareTask (medication-adjacent observations)
   - AuditTrail entries
   - User / caregiver identity records
   - Resident profile records
   - FamilyAccessConsent records
   - Facility records

3. **Account closure behavior defined:** A documented and counsel-reviewed policy covers what happens to records when a facility account closes (facility cancels service, facility closes, or operator terminates), including:
   - Retention period after closure
   - Destruction/purge timing and mechanism
   - Export or return of records to the facility operator
   - Notice requirements to the facility operator
   (Counsel question Q4 in `0004-counsel-handoff-packet.md`.)

4. **Caregiver deactivation and anonymization policy defined:** A documented and counsel-reviewed policy covers what happens to a caregiver User record when their account is deactivated, including whether AuditTrail entries may be anonymized and when. (Counsel question Q6 in `0004-counsel-handoff-packet.md`.)

5. **Supabase PITR backup retention verified:** Supabase Point-in-Time Recovery backup retention is verified to be at least as long as the longest counsel-confirmed minimum retention period for any record type stored in the database.

6. **Export and return rights documented:** The policy defines what export or return rights the facility operator has for all resident data and care records on account closure or on demand.

7. **Counsel review complete:** A qualified California compliance/privacy counsel has reviewed and confirmed (or revised) the retention policy before commercial launch. This acceptance criterion cannot be checked off by AI review alone.

8. **Policy incorporated into ToS:** The retention and deletion policy is reflected in `tos_draft_for_counsel.md` and the final Terms of Service before commercial launch.

9. **Technical implementation plan exists:** A separate technical task or plan defines the Supabase-level implementation of the retention policy (scheduled purge jobs, deletion flags, export tooling, PITR configuration). This criterion is met when that plan exists — implementation itself is a separate task gated on AC 1–7.

---

## Plan

- [ ] Route this document alongside `0004-counsel-handoff-packet.md` — retention questions Q1, Q2, Q4, and Q6 in that packet directly map to AC 1, 3, and 4 of this task. One counsel engagement covers both.
- [ ] Once counsel responds, record the confirmed retention periods by record type (AC 2) in the Outcome section of this document.
- [ ] Once counsel responds, record the confirmed account closure policy (AC 3) in the Outcome section.
- [ ] Once counsel responds, record the confirmed caregiver deactivation/anonymization policy (AC 4) in the Outcome section.
- [ ] Verify Supabase PITR backup retention against the confirmed minimum retention periods (AC 5). Check Supabase plan tier and PITR settings against the longest required retention period.
- [ ] Confirm export/return rights with counsel and document the operator-facing policy (AC 6).
- [ ] Update `tos_draft_for_counsel.md` to reflect counsel-confirmed retention policy language (AC 8). Do not edit before counsel responds.
- [ ] Create a separate technical implementation task for Supabase-level retention enforcement (AC 9).
- [ ] Mark this task complete only after all ACs above are checked.

---

## Notes

> **Pre-commercial-launch hard stop:** Real resident care data must not enter production under any commercial relationship until AC 1–7 are complete and counsel has confirmed the policy. The prototype at alh-tracker.vercel.app is demo-only (no auth, browser localStorage only) and holds no real data — it is not affected by this policy.

**Counsel dependency:** This task does not introduce new counsel questions beyond those already in `0004-counsel-handoff-packet.md`. Questions Q1 (§ 87506 resident records), Q2 (§ 87465 medication records and HIPAA BAA), Q4 (account closure), and Q6 (caregiver identity preservation) directly answer the open items in ACs 1–4. Route this task to counsel in the same engagement as task 0004.

**Title 22 preliminary findings (desk research only — not legal advice):**
- § 87506 (resident records): 3-year post-service retention. Whether alh-tracker CareLogEntry records constitute "resident records" subject to this requirement is an open counsel question (Q1 in `0004-counsel-handoff-packet.md`).
- § 87465 (medication records): 1-year retention; 3-year destruction records. Whether alh-tracker ObservedCareTask records (no dosage/medication name) constitute "medication records" is an open counsel question (Q2).
- Preliminary interpretation: if § 87506 applies to the vendor, minimum retention is 3 years post-service; if § 87465 also applies, ObservedCareTask records may have a separate 1-year inner window. Counsel must confirm before these periods are implemented as policy. Do not treat these as final.

**Supabase-specific technical considerations (not legal advice):**
- Supabase PITR backup retention is plan-tier dependent. The Pro plan provides 7-day PITR. Longer retention windows require a paid add-on. If counsel confirms a 3-year retention requirement, PITR configuration alone is not sufficient — application-level archiving or export is required.
- Logical deletion (soft-delete with `deleted_at` flag) vs. physical row deletion has implications for AuditTrail integrity. If care log entries are physically deleted, AuditTrail entries referencing them may become orphaned. The retention policy must define whether entries are soft-deleted, archived to cold storage, or physically purged — and in what order.
- Scheduled purge jobs at the retention boundary must be designed to avoid purging records still within their retention window. Staggered retention periods by record type add complexity.

**Relationship to other tasks:**
- Blocks task 0005 (data model finalization) — the data model cannot be finalized until retention/deletion policies are known, since those policies affect field-level design (soft-delete flags, retention timestamps, anonymization fields).
- Linked to task 0004 — counsel questions Q1, Q2, Q4, Q6 in `0004-counsel-handoff-packet.md`.
- Linked to task 0001 — the Terms of Service and commercial launch readiness gate.
- Linked to task 0008 — PITR configuration is part of the production infrastructure context for Phase 1.

---

## Outcome

_To be filled in after counsel review and policy definition. Record confirmed retention periods, account closure policy, caregiver deactivation policy, and PITR verification results here._

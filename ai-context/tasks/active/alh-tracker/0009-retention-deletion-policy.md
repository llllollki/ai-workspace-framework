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

- [x] Produce preliminary policy draft: schema audit, data category retention table, account closure behavior, archive/delete/anonymize framework, implementation implications, and additional counsel questions (task 0009 work, 2026-05-23). See Notes section below. This does not satisfy AC 1–7 — counsel approval is still required before any of the policy positions below may be treated as final.
- [ ] Route this document alongside `0004-counsel-handoff-packet.md` — retention questions Q1, Q2, Q4, and Q6 in that packet directly map to AC 1, 3, and 4 of this task. Route Q-R1 through Q-R8 from the Notes section below in the same engagement. One counsel engagement covers both.
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

## Preliminary Policy Draft (2026-05-23)

> **PRELIMINARY — NOT LEGAL ADVICE — REQUIRES COUNSEL APPROVAL BEFORE ANY COMMERCIAL USE, DATA DELETION, PRODUCTION DELETION AUTOMATION, OR BINDING POLICY COMMITMENT**
> This draft was produced on 2026-05-23 by AI-assisted desk research as part of task 0009. It is not a legal determination. It is not a compliance claim. Do not treat any statement below as authoritative. Do not implement deletion or purge logic based on any period stated here until counsel has confirmed the applicable retention obligations. Do not use this draft in any commercial agreement, ToS, or facility-operator communication without prior counsel review and approval.

### Schema Audit Findings (2026-05-23)

Existing soft-delete and archive fields in the production schema (migrations 0000–0014):

| Table | Soft-delete / archive field(s) | Status |
|---|---|---|
| `residents` | `is_active` (boolean) + `deleted_at` (timestamptz) | Good — two-stage soft delete |
| `care_log_entries` | `deleted_at` (timestamptz) | Soft delete present |
| `wellness_observations` | `deleted_at` (timestamptz) | Soft delete present |
| `follow_ups` | `deleted_at` (timestamptz) | Soft delete present |
| `appointment_transports` | `deleted_at` (timestamptz) | Soft delete present |
| `users` | `is_active` (boolean) | No `deleted_at` — intentional for FK safety; see note below |
| `facilities` | `is_active` (boolean); closure via `provisioning_status = 'closed'` | No explicit `closed_at` timestamp — add when closure workflow is designed |
| `family_resident_links` | `is_active` (boolean) | Revocation via `is_active = false`; no `deleted_at` |
| `audit_events` | None | Correct — append-only; no deletion fields should be added |
| `shift_close_records` | None | Immutable closure records; no deletion fields appropriate |
| `handoff_summary` | None | Operational summary; no deletion fields currently |
| `resident_contacts` | None | Gap — no soft delete; if a contact must be removed, history is lost |
| `resident_preferences` | None | Gap — no soft delete |
| `allergies_triggers` | None | Gap — no soft delete |
| `room_checklists` | None | Gap — no soft delete |
| `provisioning_tokens` | TTL via `expires_at` / `used_at` | Correct for short-lived tokens |
| `provisioning_events` | None | Append-only; no deletion appropriate |
| `crm.*` tables | `crm.facilities.archived` (boolean) | CRM-scoped archiving only; no care data |

**Critical implementation risk — auth user cascade:**
`users.id` is a FK to `auth.users(id) ON DELETE CASCADE`. If a Supabase Auth user is deleted, the corresponding `users` row is also deleted. However, `care_log_entries.created_by` and `edited_by` reference `users(id)` with no explicit `ON DELETE` action (PostgreSQL default: NO ACTION), which prevents deleting a `users` row that has associated care log entries. This is an important protection. The deactivation workflow MUST be: set `users.is_active = false` and revoke Auth sessions. DO NOT delete the `auth.users` entry for any user who has care log entries, wellness observations, follow_ups, or audit_events referencing their identity. Deleting the auth user would cascade-delete the `users` row, which would then fail on the `care_log_entries` FK constraint — or, worse, succeed if that constraint is not present on all referencing tables.

### Data Category Retention Recommendations (Preliminary)

> PRELIMINARY — NOT LEGAL ADVICE — PENDING COUNSEL CONFIRMATION

| Data Category | Table(s) | Risk Level | Preliminary Minimum Retention | Basis | Deletion Approach | Key Counsel Question |
|---|---|---|---|---|---|---|
| Care log entries (all categories incl. incident, observed_care_task) | `care_log_entries` | High | 3 years post-service per resident | § 87506 if CareLogEntry = "resident record" | Soft-delete via `deleted_at` only; no physical purge within window | Q1: Does § 87506 apply to vendor? |
| Wellness observations | `wellness_observations` | High | 3 years post-service (same basis) | § 87506 framework | `deleted_at` only; no physical purge within window | Q1: same |
| Observed care task entries (log category within care_log_entries) | `care_log_entries` (category = `observed_care_task`) | High | 1 year minimum if § 87465 applies; 3 years if § 87506 also applies — retain the longer | § 87465 and/or § 87506 | Same as care_log_entries | Q2: Does § 87465 apply to vendor despite absence of dosage/medication name? |
| Audit trail entries | `audit_events` | Compliance-critical | At minimum as long as the longest retention period of any audited entity type | Compliance integrity | NEVER delete before the retention window of all referenced records expires; pending counsel confirmation of absolute minimum | Q-R2: Can audit immutability override CPPA/CCPA deletion requests? |
| Resident profile records | `residents`, `resident_preferences`, `allergies_triggers`, `resident_contacts` | High | 3 years post-service (same basis as care_log_entries) | § 87506 | `is_active = false` on `residents`; `deleted_at` where present; no physical purge within window | Q1: same |
| User / caregiver identity records | `users` | Medium | Retain as long as any `audit_events`, `care_log_entries`, `wellness_observations`, or `follow_ups` reference the user's identity | Audit trail integrity | DEACTIVATE (`is_active = false`) only; NEVER anonymize until all referenced records have passed their retention window AND counsel confirms anonymization is permissible | Q6: Must identity be preserved? When may it be anonymized? |
| Follow-up records | `follow_ups` | High | 3 years post-service (follow-ups may document care concerns or incidents) | § 87506 framework (follow-ups are care log extensions) | `deleted_at` only; no physical purge within window | Q1: same |
| Shift close records | `shift_close_records` | Medium-High | 3 years (operational shift records tied to care periods) | § 87506 framework | No `deleted_at` currently; add if purge is eventually needed | Counsel to confirm whether shift close records are a separate retention category |
| Handoff summaries | `handoff_summary` | Medium-High | 3 years (same as shift records) | § 87506 framework | No `deleted_at` currently | Same as shift close records |
| Appointment / transport records | `appointment_transports` | Medium | 3 years post-service (PHI-adjacent; tied to resident care) | § 87506 framework | `deleted_at` only; no physical purge within window | Counsel to confirm whether transport records are a separate category |
| Room checklists | `room_checklists` | Low-Medium | Pending counsel — may be shorter; operational housekeeping records less clearly "care data" | Less clearly "resident record" but linked to resident welfare checks | No `deleted_at` currently | Counsel to confirm whether room checklists constitute § 87506 "resident records" |
| Facility records | `facilities` | Medium | Retain for at least the retention window of all associated care records | Closure integrity | `provisioning_status = 'closed'`; NO physical deletion of Facility while associated records are within retention window | Q4: Account closure obligations — can Facility row be deleted while care records must still be retained? |
| Family access consent records | `family_resident_links` | Medium | Retain at least as long as the care records they govern access to | Access authorization integrity | `is_active = false` on revocation; no physical purge until retention window expires | Q-R1: Can CPPA/CCPA deletion rights for the family contact override care-record retention obligation? |
| Provisioning tokens | `provisioning_tokens` | Low | Token TTL (72h or immediate on use/revocation) | Security — no retention obligation beyond operational validity; no care data | Token row can be purged after expiry without retention concern | No Title 22 question; confirm with security review |
| Provisioning events | `provisioning_events` | Medium | Retain as long as the associated Facility record exists | Account lifecycle audit | Append-only; no purge while Facility is active or within closure window | No Title 22 concern; standard commercial audit retention |
| CRM records (`crm.*`) | `crm.*` | Low (no care data) | Standard commercial / business record retention (recommend 7 years for financial/contract records) | No Title 22 obligation applies (no resident care data); standard business record principles apply | CRM-scoped archiving (`archived` flag); separate from care data retention | What is the company's standard commercial record retention policy? Counsel to confirm |

### Account Closure Behavior Recommendations (Preliminary)

> PRELIMINARY — NOT LEGAL ADVICE — PENDING COUNSEL CONFIRMATION ON Q4

When a facility account closes (`Facility.provisioning_status` transitions to `'closed'`):

**Phase 1 — Immediate on closure:**
1. Revoke all active Supabase Auth sessions for all Users in the facility (prevent any further access).
2. Set `User.is_active = false` for all Users associated with the facility.
3. Block all write operations via RLS: `provisioning_status = 'closed'` must be treated as a quarantine state (same as `pending_setup` — deny all client-side writes, deny new care log entries, deny resident additions or profile edits).
4. Generate a full facility data export (see Export section below) and notify the facility owner via email.
5. Send written notice of account closure, export availability window, and the data hold period.

**Phase 2 — Hold period (minimum 30 days; counsel to confirm exact notice period):**
- Records remain readable only by authorized system administrators (not facility-facing users).
- The data export package remains downloadable by the facility owner.
- No new records may be written.
- The facility owner may contact ALH Tracker during this window to retrieve data or dispute the closure.

**Phase 3 — Post-hold period, during retention window (counsel-confirmed periods apply):**
- Until counsel confirms the exact retention obligations: retain everything. The correct interim posture is retain-all until policy is confirmed.
- Per-resident retention clock starts from when each resident's service ended — NOT from when the vendor account closed. Records for residents still active at closure start their retention clock at the time of closure.
- During the retention window: records must be retrievable if required (e.g., CDSS licensing review, litigation hold, operator request). Cold storage archiving is acceptable if records remain accessible within a reasonable retrieval window.

**Phase 4 — Post-retention-window purge (DO NOT BUILD until policy is settled):**
When the counsel-confirmed retention window has expired for a record category, purge in this order to preserve FK integrity:
1. `care_log_entries`, `wellness_observations`, `follow_ups`, `appointment_transports` (care operational records)
2. `resident_contacts`, `resident_preferences`, `allergies_triggers`, `room_checklists` (profile records)
3. `residents` (only after all care records referencing them are purged)
4. `shift_close_records`, `handoff_summary`
5. `family_resident_links`
6. `users` (only after all `audit_events` and care records referencing them are also purged or anonymized per counsel guidance)
7. `audit_events` (last — must remain until all records they reference are also past their retention window)
8. `provisioning_events`, `provisioning_tokens`
9. `facilities` (absolute last — only when all associated records have been purged or archived)

**Export and return rights (preliminary):**
- On account closure: provide a full facility export covering all care log entries, wellness observations, follow-ups, transport records, resident profiles, contacts, preferences, allergies, room checklists, shift close records, handoff summaries, and audit events.
- Format: CSV per entity type + JSON summary index.
- Delivery: secure download link sent to the facility owner's email; available for minimum 30 days.
- Counsel must confirm: (a) is an export legally required or contractual? (b) what format is required? (c) must the audit trail be included? (d) are there redaction requirements before export?

### Archive vs. Delete vs. Anonymize Recommendations (Preliminary)

> PRELIMINARY — NOT LEGAL ADVICE — ALL THREE RECOMMENDATIONS REQUIRE COUNSEL CONFIRMATION

| Approach | When Appropriate | When NOT Appropriate | Recommendation |
|---|---|---|---|
| **Soft-delete (archive in place)** | Active operations — resident archived by facility, care entry marked deleted by staff, family access revoked | Never for records within the counsel-confirmed retention window — soft-delete is still retention, not purge | RECOMMENDED for all care data operational workflows; `deleted_at` and `is_active` fields support this |
| **Anonymize** | User identity fields (`name`, `email`) ONLY after: (1) retention window for ALL referenced records expires, AND (2) counsel confirms anonymization is permissible, AND (3) the facility account is closed | On any care records (destroys regulatory integrity); on `audit_events`; before retention window expires; before counsel confirms; on `User.id` (UUID — must stay for FK integrity) | Only the identifying fields of the `users` table may be anonymized, and only under the conditions above. The UUID, `facility_id`, `role`, and `created_at` must be preserved for FK referential integrity |
| **Physical delete (purge)** | Records that have: (1) passed the counsel-confirmed retention window, AND (2) been exported per the closure policy, AND (3) no remaining audit references pending their own retention window | Everything else — including anything within the retention window, any care record before counsel confirms the applicable period | DO NOT IMPLEMENT purge jobs until counsel has confirmed retention periods. Gate purge execution on explicit retention window expiry check per record |

**Critical rule:** `audit_events` must not be anonymized or deleted while any record it references is within its retention window. Deleting or anonymizing audit entries while primary records still exist removes the ability to verify record integrity during a regulatory review.

### Implementation Implications (Preliminary — Do Not Build Until Policy Is Settled)

> IMPLEMENTATION PLANNING ONLY — NOT LEGAL ADVICE — DO NOT BUILD RETENTION AUTOMATION UNTIL COUNSEL CONFIRMS PERIODS AND APPROACH

**Schema gaps to address when policy is confirmed:**
1. No `deleted_at` on `users`, `facilities`, `family_resident_links`, `resident_contacts`, `resident_preferences`, `allergies_triggers`, `room_checklists`, `shift_close_records`, `handoff_summary` — decide whether to add or document why no soft-delete is needed for each.
2. `facilities` has no explicit `closed_at` timestamp — add when account closure workflow is designed.
3. `users` has no `deactivated_at` timestamp — add when user lifecycle management is designed.
4. `residents` has `deleted_at` but `data_model.md` also lists `deactivated_at`/`deactivated_by`/`deactivation_reason` as TODOs — these need to be added before the resident archive workflow is built.
5. RLS for `provisioning_status = 'closed'` is not yet defined — migration 0008 covers the quarantine gate for `pending_setup`; `closed` and `suspended` states need explicit RLS policies (deny all writes; read-only for export during hold period).
6. No per-resident departure timestamp exists for the retention clock — needed if § 87506 retention runs per-resident from departure date, not from account closure date.

**Future jobs needed (DO NOT BUILD until policy is settled and counsel approves):**
- Retention enforcement scheduler: identifies records past their counsel-confirmed retention window and queues them for cold storage archiving or purge.
- Export generation job: on account closure, generates the full data export package — this can be designed independently of retention policy.
- Cold storage archiving: moves records past active query period but within retention window to encrypted durable storage (e.g., encrypted S3-compatible object store) — needed if PITR alone cannot satisfy retention requirements.

**Supabase PITR assessment:**
- Supabase Pro plan: 7-day PITR.
- If counsel confirms 3-year vendor retention applies: PITR alone is NOT sufficient for compliance retention. Application-level archiving or export to durable cold storage is required.
- PITR should be viewed as a disaster-recovery mechanism, not a retention compliance mechanism.
- Do not claim PITR satisfies any Title 22 retention obligation.

### Additional Counsel Questions (2026-05-23 — Supplement to Task 0004 Q1–Q9)

> Route these questions alongside Q1–Q9 already in `0004-counsel-handoff-packet.md`. One engagement covers all.

**Q-R1 — CPPA/CCPA deletion requests vs. Title 22 retention obligations**
When a data subject (facility operator, caregiver, or family contact) submits a CPPA/CCPA deletion request, can that request override alh-tracker's obligation to retain records for Title 22 retention periods? Specifically: if a caregiver submits a CCPA deletion request for their name and email address, must their identity be removed from AuditTrail references, even if doing so would compromise audit integrity for care records still within a 3-year retention window?

**Q-R2 — Audit trail immutability vs. data subject deletion rights**
The `audit_events` table is append-only by design — no UPDATE or DELETE is permitted at the database level. If a CPPA/CCPA deletion request applies to information recorded in `audit_events`, is the product's inability to delete those events a violation? Or does the Title 22 retention obligation override the consumer deletion right in this context?

**Q-R3 — Supabase PITR backup copies as retention mechanism**
Do Supabase PITR backup copies (7-day rolling window on the Pro plan) constitute "copies" of records for retention compliance purposes? If the vendor must retain records for 3 years, must those records be in an immediately queryable active database, or is encrypted cold storage archiving with a retrieval SLA acceptable?

**Q-R4 — "Destruction records" under § 87465 applied to a software vendor**
Section 87465 requires retention of medication destruction records for 3 years. As a software vendor that never physically holds medication records, does alh-tracker have any obligation with respect to § 87465 destruction records requirements? If yes, what would count as a "destruction record" in a software system context?

**Q-R5 — Per-resident vs. per-account retention clock**
For § 87506's 3-year post-service retention: is the clock measured per-resident (from when the individual resident's service at the facility ends) or per-account (from when the facility cancels service with alh-tracker)? If per-resident: what is the vendor's obligation to track individual resident departure dates for retention purposes, and how must this tracking be implemented?

**Q-R6 — Vendor obligation to retain records after account closure**
If a facility cancels its alh-tracker subscription before the § 87506 3-year retention window has expired for some residents, is the vendor obligated to retain those records after the commercial relationship ends? Or does the retention obligation transfer entirely to the facility operator at account closure? This has significant product architecture and cost implications.

**Q-R7 — Export format and content requirements on account closure**
Is the vendor legally obligated to provide the facility with an export of their records on account closure, or is this solely a contractual matter? If legally required: what format (structured data, human-readable print), what content (care records only, audit trail, user records?), and within what timeline?

**Q-R8 — Backup retention and queryability requirements**
Is it legally permissible to satisfy a 3-year retention obligation by maintaining encrypted cloud backups (not immediately queryable), rather than keeping records in an active production database for the full retention period? If cold storage archiving is permissible, what retrieval timeline is required if CDSS or a court requests the records?

---

## Outcome

_To be filled in after counsel review and policy definition. Record confirmed retention periods, account closure policy, caregiver deactivation policy, and PITR verification results here._

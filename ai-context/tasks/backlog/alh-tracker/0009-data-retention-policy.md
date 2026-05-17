# Task 0009 — Data Retention and Archive Policy

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-16
**Owner role:** Product / Program Lead (with Compliance / Privacy Counsel)
**Reviewers:** Technical Architect

---

## Goal

Define and document the data retention and archive policy for all alh-tracker record types stored in the production Supabase database. This is a pre-commercial-launch blocker — real resident data must not enter the production database without a defined, counsel-reviewed retention policy in place.

Specifically:
- What is the minimum retention period for each record type (CareLogEntry, ObservedCareTask, AuditTrail, Resident, User, Facility)?
- What happens to all records when a facility account closes?
- What are the vendor's obligations vs. the facility's obligations for record retention?
- How does Supabase PITR backup retention interact with minimum record retention requirements?
- What purge/deletion mechanism is needed in the data model and application?

---

## Acceptance Criteria

1. A documented retention policy specifying minimum retention periods for each record category (per counsel-confirmed answers to task 0004 Priority 1 questions Q1–Q4).
2. A documented account closure procedure: what happens to each record category, what notice is given to the facility operator, and what the timeline is.
3. The retention policy and account closure procedure are incorporated into the ToS draft (`tos_draft_for_counsel.md` Sections 3–4, currently placeholder).
4. The data model is updated (task 0005 dependency) to include the fields and constraints required to enforce the policy.
5. Counsel review of the retention policy and account closure terms is completed before any real resident data is accepted under a commercial or pilot relationship.

---

## Plan

- [ ] Obtain counsel answers to task 0004 Priority 1 Questions Q1–Q4 (prerequisite — cannot define policy without these answers)
- [ ] Define minimum retention period per record type based on counsel guidance
- [ ] Define account closure procedure (record disposition, notice period, deletion timeline)
- [ ] Update ToS draft Sections 3–4 with counsel-confirmed retention and closure terms
- [ ] Identify data model changes required to enforce the policy (e.g., purge-after-N-years flag, closure-status field on Facility) — document as a task 0005 input
- [ ] Confirm Supabase PITR backup retention is configured to at least match the minimum retention period
- [ ] Record durable decisions as an ADR in `decisions\`

---

## Notes

- This task is blocked on task 0004 (counsel review) for the retention period question. However, the account closure procedure and Supabase backup retention alignment can be drafted in parallel as a placeholder pending counsel answers.
- Risk: if real resident data enters the production Supabase instance before a retention policy exists, the vendor has no documented basis for how long it retains data, when it deletes data, or how it handles account closure. This is a regulatory risk under § 87506 (3-year resident record retention), § 87465 (medication records), and CPPA/CCPA.
- The ToS draft (`tos_draft_for_counsel.md`) already has placeholder sections (3.2, 3.3, 4.x) awaiting counsel answers. The output of this task fills those placeholders.
- Supabase PITR: per `compliance_notes.md` Security section, backup retention must be at least as long as the counsel-confirmed retention period. This has not been verified against the Supabase project's current PITR configuration.

---

## Dependencies

- **Blocks:** Task 0005 (data model finalization) — retention fields and purge mechanism must be defined first.
- **Blocked by:** Task 0004 (counsel review) — retention period per record type requires counsel answer to Priority 1 Questions Q1–Q4.
- **Informs:** ADR for data retention policy.

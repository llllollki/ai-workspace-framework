# Task 0003 — Shift Model and Caregiver Authentication

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Technical Architect
**Reviewers:** Product / Program Lead, Operations / Concierge Workflow Lead

---

## Goal

Define the shift model and caregiver authentication model before the MVP data model is finalized.

These two decisions are tightly coupled: how shifts are defined and closed affects the AuditTrail and handoff logic; how caregivers authenticate determines what the `created_by` field on every care log entry actually means for accountability.

---

## Acceptance Criteria

1. Shift model decision: are shift periods fixed time windows, owner-configured, or flexible open/close?
2. Shift edge cases documented: what happens if a shift is never closed? What if two shifts overlap?
3. Shift close trigger decision: does closing require a caregiver action, a scheduled time, or both?
4. Caregiver authentication decision: individual accounts, shared facility PIN, or a hybrid model.
5. Shared-device behavior documented: if a shared tablet is used, how is individual identity preserved for audit trail purposes?
6. New or agency caregiver onboarding scenario documented: how does an unfamiliar caregiver log in without blocking a shift?
7. Durable decisions recorded as ADRs in `decisions\`. `data_model.md` updated to reflect these decisions.

---

## Plan

Sequence note: input from task 0002 (design partner site visit) is recommended before finalizing these decisions. Real shift patterns at a real facility are the most reliable input.

- [ ] Review common shift patterns in small RCFEs (typically three 8-hour shifts; some use 12-hour; some use flexible or split shifts)
- [ ] Define and compare shift period model options:
  - Fixed time windows (predictable but inflexible)
  - Owner-configured windows (flexible but more setup)
  - Open/close model (most flexible; edge case risk highest)
- [ ] Define how shift close and handoff generation are triggered
- [ ] Define what happens to log entries if a shift is never closed (orphaned entry handling)
- [ ] Define caregiver authentication options and their trade-offs:
  - Individual accounts: stronger audit trail; more setup friction; harder for agency staff
  - Shared device PIN: lower friction; weaker accountability; simpler for small homes
  - Hybrid: individual accounts for regular staff, PIN fallback for coverage shifts
- [ ] Define shared tablet behavior: persistent session, auto-lock after inactivity, or per-action confirmation?
- [ ] Define agency or new caregiver scenario: can they log in without a pre-created account?
- [ ] Record durable decisions as ADRs in `decisions\`
- [ ] Update `data_model.md` Shift and User entities to reflect finalized decisions

---

## Notes

- The AuditTrail entity requires `changed_by` (a User ID) on every write. If caregivers use a shared PIN, individual accountability is reduced. Owners should understand this trade-off explicitly when configuring their facility.
- Small RCFE operators frequently use floating or agency caregivers for coverage. A model that requires a pre-created account for every caregiver may create real shift-blocking friction in practice.
- This task should be sequenced after at least one design partner site visit (task 0002) to validate assumptions against real facility behavior.

---

## Outcome

<!-- To be filled when the task is completed. -->

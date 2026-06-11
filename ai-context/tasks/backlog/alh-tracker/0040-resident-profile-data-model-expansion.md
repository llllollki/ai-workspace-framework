# Task 0040 — Resident Profile Data Model Expansion

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-16
**Owner role:** Product / Program Lead
**Reviewers:** Technical Architect; Compliance / Privacy Counsel (for ADL and medication-adjacent field questions)

---

## Goal

Define the expanded Resident entity design — including new field groups, new related entities, and the AuditTrail scope expansion — so that task 0005 (MVP data model finalization) can proceed. These design questions have been deferred pending review but must be resolved before any of the new field groups are implemented.

---

## Acceptance Criteria

1. Multi-contact model decision: one-to-many vs. current one-to-one ResidentContact, with structural change plan if needed.
2. Identity field expansion defined: `legal_name`, `preferred_name`, `resident_phone`, `move_in_date`, `approximate_age` — field names, types, constraints, and DOB deferral policy documented.
3. `ResidentMobility` entity designed: fields (wheelchair, walker/cane, transfer assistance, two-person assist, lift note), access model, and audit requirements.
4. `ResidentDailyCare` entity decision: extend `ResidentPreferences` or create a separate entity? Fields defined. Counsel input on ADL data sensitivity documented.
5. Safety alerts expansion defined: fall precaution, wandering precaution, eating/swallowing assistance context, critical safety notes — field names, types, and where they live in the data model.
6. Medication-adjacent operational notes field decision: standalone field on `Resident` or within `ResidentPreferences.general_notes`? Language posture confirmed.
7. Archive/reactivate field additions defined: `deactivated_at`, `deactivated_by`, `deactivation_reason`, `reactivated_at`, `reactivated_by` on the `Resident` entity.
8. `FamilyAccessConsent` archive behavior defined: what happens to active family access grants when a resident is archived?
9. AuditTrail `entity_type` expansion: new entity types to add when new entities are implemented.
10. All design decisions documented in `data_model.md` as pending-implementation stubs; durable decisions recorded as ADR(s) where appropriate.

---

## Plan

- [ ] Decide: multi-contact model for ResidentContact (one-to-many vs. current one-to-one). If one-to-many, design the structural change.
- [ ] Define: identity field expansion (`legal_name`, `preferred_name`, `resident_phone`, `move_in_date`, `approximate_age`). Confirm DOB deferral policy pending data minimization review.
- [ ] Design: `ResidentMobility` entity — fields, access model, audit scope.
- [ ] Decide: `ResidentDailyCare` approach — extend `ResidentPreferences` or separate entity? Get counsel input on ADL data sensitivity before deciding.
- [ ] Define: safety alerts expansion — fall precaution, wandering precaution, eating/swallowing, critical safety notes. Where do these live in the model?
- [ ] Decide: medication-adjacent operational notes — standalone field or within `ResidentPreferences.general_notes`? Document language posture (must include MAR boundary disclaimer wherever this field appears).
- [ ] Define: archive/reactivate fields on `Resident` entity.
- [ ] Define: `FamilyAccessConsent` behavior when the linked resident is archived (auto-revoke, auto-suspend, or no change with a read-only flag?).
- [ ] Define: AuditTrail `entity_type` enum expansion for new entity types.
- [ ] Update `data_model.md` with all design decisions as pending-implementation stubs.
- [ ] Identify any decisions that require counsel input and document them as TODOs.

---

## Notes

- This task is a prerequisite for task 0005 (MVP data model finalization). Task 0005 cannot be closed until the entity designs in this task are resolved.
- Counsel input is specifically required before building: (a) the `ResidentDailyCare` entity (ADL data sensitivity and care plan language risk), (b) any medication-adjacent notes field (MAR boundary language), (c) the `FamilyAccessConsent` archive behavior (interaction with consent model). These are design questions only — implementation requires owner approval and is a separate task.
- All new field groups are PHI-adjacent (high sensitivity) and must be subject to the same security, access control, and audit requirements as existing high-sensitivity entities per `compliance_notes.md`.
- The caregiver safety/mobility empty state must show a graceful empty state (not a blank that reads as "no concerns noted") — this is a UX design requirement that follows from the data model decision.

---

## Open Questions (from ai_memory.md — Resident profile expansion)

1. Multi-contact model: one-to-many ResidentContact structural change?
2. Identity fields: `legal_name`, `preferred_name`, `resident_phone`, `move_in_date`, `approximate_age` — field types and constraints?
3. `ResidentMobility` entity: what fields? What access model?
4. `ResidentDailyCare`: extend `ResidentPreferences` or separate entity? Counsel input on ADL sensitivity needed.
5. Safety alerts: where in the model? What field names avoid clinical terminology?
6. Medication-adjacent notes: standalone field or within preferences?
7. Archive behavior for active FamilyAccessConsent records: auto-revoke, auto-suspend, or flag?
8. AuditTrail entity_type enum: what new types are needed?
9. Caregiver empty state: what does the read view show when no mobility/safety data exists for a resident?

---

## Dependencies

- **Blocked by:** Counsel input on ADL data sensitivity and medication-adjacent notes language (informal question, not a formal task gate).
- **Blocks:** Task 0005 (MVP data model finalization).
- **Informs:** Implementation tasks for new resident profile sections (not yet approved — no task numbers).

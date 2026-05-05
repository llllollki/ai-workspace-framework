# Task 0005 — MVP Data Model

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Technical Architect
**Reviewers:** Product / Program Lead, Compliance / Privacy Counsel

---

## Goal

Draft and validate the implementation-ready core entity schemas for alh-tracker before any application code is written.

The current `data_model.md` is a design reference. This task produces the implementation-ready version with column types, nullability, foreign key constraints, indexes, and retention rules defined.

---

## Acceptance Criteria

1. Implementation-ready schemas defined for: Facility, User, Role, Resident, Routine, Shift, CareLogEntry, ObservedCareTask, FollowUp, AuditTrail.
2. Family access stubs (ResidentContact, FamilyAccessConsent) included with at minimum a foreign key placeholder, even if tables are empty at MVP launch.
3. Every entity that stores care event data includes: `created_by` (User ID), `created_at` (timestamp), `facility_id`, `resident_id`, and `shift_id` where applicable.
4. AuditTrail schema supports append-only semantics with entity type, entity ID, action, changed_by, changed_at, and previous_value (JSON snapshot).
5. The caregiver authentication model (from task 0003) is reflected in the User and Session entities.
6. The shift model decisions (from task 0003) are reflected in the Shift entity.
7. Title 22 design guidance (from task 0004) is reflected in relevant field definitions and retention notes.
8. Family access architecture stubs (from task 0006) are present in the schema.
9. A soft-delete strategy for Resident and Facility records is defined (care log records must be retained after resident deactivation).
10. The finalized schema is reviewed and signed off by Technical Architect and Compliance / Privacy Counsel.
11. `data_model.md` is updated with the finalized schemas.

---

## Plan

Sequence dependency: tasks 0003, 0004, and 0006 should be substantially complete before this task is finalized.

- [ ] Review current `data_model.md` design reference
- [ ] Incorporate shift model decisions from task 0003
- [ ] Incorporate caregiver auth model from task 0003
- [ ] Incorporate Title 22 field and retention guidance from task 0004
- [ ] Incorporate family access stubs from task 0006
- [ ] Define all field types and nullability
- [ ] Define foreign key relationships and cascade behavior
- [ ] Define a soft-delete and retention strategy for Resident and care log records
- [ ] Define AuditTrail storage strategy: same database (separate append-only table) vs. dedicated store
- [ ] Define indexes for the most common query patterns (shift board, resident timeline, handoff generation)
- [ ] Technical Architect review
- [ ] Compliance / Privacy Counsel review for PHI handling and retention
- [ ] Update `data_model.md` with the finalized, implementation-ready schema

---

## Notes

- The current `data_model.md` is a first-pass design reference intentionally written before these decisions were made. This task upgrades it to be implementation-ready.
- AuditTrail must be append-only. No row in AuditTrail should ever be edited or deleted. Enforce this at the database level, not just in application code.
- Consider the implications of soft-delete vs. hard-delete for RCFE residents who move out or are deceased. Care log records may need to be retained for regulatory purposes even after a resident is deactivated.
- The choice of database engine (Supabase/PostgreSQL, etc.) is a separate decision that may be made in parallel. This task should produce schemas that are database-agnostic where possible.
- Do not begin implementation until this task is signed off.

---

## Outcome

<!-- To be filled when the task is completed. -->

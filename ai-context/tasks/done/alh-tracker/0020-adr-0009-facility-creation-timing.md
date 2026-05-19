Status: done
Created: 2026-05-19
Owner role: AI assistant (Claude Code)
Reviewers: n/a

## Goal

Resolve the ADR 0007/0008 blocker: decide when and how the tracker `Facility` record is
created during CRM owner provisioning. Produce ADR 0009 and update all referencing docs.

## Acceptance Criteria

- [ ] ADR 0009 created under `decisions/` with status `proposed`
- [ ] ADR 0009 clearly decides when/how tracker Facility records are created
- [ ] CRM/tracker boundary remains intact
- [ ] Facility creation idempotency and duplicate-prevention strategy documented
- [ ] Relationship among allocated resident count, licensed capacity, subscription resident
      limit, and active resident count clarified or explicitly marked TODO
- [ ] `ai_memory.md` updated to resolve facility creation timing blocker
- [ ] `decisions/README.md` indexes ADR 0009
- [ ] `execution_log.md` updated
- [ ] Changes mirrored to `ai-workspace-framework`
- [ ] No application code changed

## Plan

- [x] Create this task doc
- [x] Draft and write ADR 0009
- [x] Update decisions/README.md
- [x] Update ADR 0007 (resolve Facility record creation TODO)
- [x] Update ADR 0008 (update request contract with facility fields note)
- [x] Update data_model.md (Facility entity: add provisioning_status, crm_facility_reference)
- [x] Update features.md (CRM provisioning — resolve facility creation TODO)
- [x] Update user_flows.md (Flow 0 — resolve facility creation TODO)
- [x] Update ai_memory.md (resolve facility creation timing blocker)
- [x] Update compliance_notes.md
- [x] Update execution_log.md
- [x] Mirror all changes to ai-workspace-framework
- [x] Move this task doc to done

## Notes

Subagent policy: single tightly-coupled design task — serial execution is correct.
Subagents would add coordination overhead without benefit here since every subsequent
doc update depends on the ADR 0009 decision.

Decision summary (pre-write):
- The tracker provisioning API call creates the tracker Facility record in a
  `pending_setup` state as part of the provisioning action (same call that creates the
  User row and ProvisioningToken). This is Option 2 from the task prompt, framed as a
  pending/onboarding-state Facility.
- CRM sends: facility_name, crm_facility_id (opaque), city, state, license_number
  (optional placeholder). Nothing else.
- Allocated resident count is NOT copied to tracker. It remains a CRM commercial concept.
- Idempotency: keyed on crm_facility_reference UNIQUE constraint.
- Facility stays in pending_setup if owner never activates. Cleanup is TODO.
- CRM never receives tracker facility_id.

## Outcome

ADR 0009 created (proposed). Decision: tracker provisioning API call creates the tracker
Facility record in `pending_setup` state atomically with User + ProvisioningToken. Keyed by
`crm_facility_reference` (opaque CRM ID) with UNIQUE constraint for idempotency. Facility
fields forwarded from CRM: `facility_name`, `facility_city`, `facility_state`,
`license_number` (optional). `Facility.capacity`, subscription resident limit, and
allocated resident count explicitly excluded and defined as separate concepts. ADR 0007 Step
3a and ADR 0008 request contract updated. data_model.md, features.md, user_flows.md,
ai_memory.md, compliance_notes.md, execution_log.md, decisions/README.md all updated.
Changes mirrored to ai-workspace-framework. No app code changed.

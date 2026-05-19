Status: done
Created: 2026-05-18
Owner role: Documentation maintainer
Reviewers: n/a

## Goal

Accept ADR 0006 (CRM owner provisioning and family account approval) and clean up all documentation references that still describe it as proposed.

## Acceptance Criteria

- [x] ADR 0006 status is `accepted` in both mirrors (`ai-context` and `ai-workspace-framework`)
- [x] `(proposed)` qualifier removed from ADR 0006 in `compliance_notes.md` (both mirrors)
- [x] Compliance guardrails intact: CRM forward-write-only boundary, no CRM access to resident care data, family account creation ≠ data access, family access approval-gated/read-only/resident-specific/auditable/revocable, counsel review required before Phase 2 family access goes live
- [x] `execution_log.md` updated in both mirrors
- [x] Task doc created and moved to done

## Plan

- [x] Update ADR 0006 `**Status:**` from `proposed` to `accepted` in both mirrors
- [x] Remove `**Status is proposed:**` paragraph from ADR 0006 Context section in both mirrors
- [x] Remove `(ADR 0006, proposed)` qualifier in Data Handling Posture table row (CRM data boundary) in `compliance_notes.md` — both mirrors
- [x] Remove `Per ADR 0006 (proposed),` qualifier in Family Access and Consent Posture section — both mirrors
- [x] Add one-line acceptance entry to `execution_log.md` — both mirrors
- [x] Create this task doc and move directly to done in both mirrors

## Outcome

ADR 0006 accepted 2026-05-18. Status updated in both mirrors. Two `(proposed)` qualifiers removed from `compliance_notes.md` in both mirrors. All compliance guardrails remain intact. Changes committed to `ai-workspace-framework`.

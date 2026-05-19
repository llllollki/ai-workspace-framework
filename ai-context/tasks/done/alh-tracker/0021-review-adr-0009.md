Status: done
Created: 2026-05-19
Completed: 2026-05-19
Owner role: AI agent
Reviewers: Product owner (human review — see review report)

## Goal

Review ADR 0009 (tracker Facility record creation during CRM provisioning — status: proposed) for correctness, security soundness, ADR 0005/0006/0007/0008 consistency, data model consistency, and readiness for acceptance.

## Acceptance Criteria

- [x] ADR 0009 readiness clearly assessed
- [x] CRM/tracker boundary confirmed intact (all 7 review focus areas)
- [x] Facility creation decision reviewed (pending_setup state, lifecycle, excluded fields)
- [x] Idempotency and duplicate prevention reviewed
- [x] Resident count separation confirmed (four distinct concepts, none forwarded at provisioning)
- [x] Security/RLS TODOs confirmed correctly flagged
- [x] Account/provisioning lifecycle coherence verified
- [x] Documentation consistency verified across all 10 updated files
- [x] No conflicts with ADR 0005/0006/0007/0008 or compliance notes identified
- [x] No application code changed
- [x] Documentation edits stay inside allowed ai-context scope
- [x] Review report produced with clear recommendation
- [x] ADR 0009 status remains `proposed` pending explicit user acceptance

## Plan

Subagent policy: Not using subagents. Architecture review is a tightly coupled read-then-analyze task; cross-document comparison is the primary work and cannot be parallelized meaningfully.

- [x] Read ADR 0009, ADR 0008, ADR 0007, ADR 0006, ADR 0005
- [x] Read data_model.md, features.md, user_flows.md, ai_memory.md, compliance_notes.md
- [x] Read decisions/README.md, execution_log.md
- [x] Analyze findings against all seven review focus areas
- [x] Add 2 TODOs to ADR 0009 (retry payload conflict; re-provision when User = disabled)
- [x] Update ADR 0008 Authorization Scope table row 1 (stale description, predates ADR 0009)
- [x] Mirror ADR 0008 and ADR 0009 to ai-workspace-framework
- [x] Update execution_log.md
- [x] Write task 0021 and move to done
- [x] Deliver review report to user

## Outcome

Recommendation: **Accept with minor edits** (edits have been applied in this task — ADR is ready for acceptance).

Two TODOs added to ADR 0009 Open Implementation TODOs:
1. Retry payload conflict behavior — same `X-CRM-Facility-Id`, different field values (e.g., `facility_name`) — behavior not specified; must be decided before implementation.
2. Re-provision when `User.account_status = disabled` — CRM revokes then re-provisions same facility — endpoint behavior not specified; must be decided before implementation.

One description update in ADR 0008 Authorization Scope table row 1: added Facility creation (ADR 0009) to the allowed-action description.

No conflicts with any prior ADR. All seven focus areas passed. Post-acceptance cleanup steps documented in the review report.

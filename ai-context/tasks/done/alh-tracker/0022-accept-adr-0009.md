Status: done
Created: 2026-05-19
Owner role: main agent
Reviewers: n/a

## Goal

Accept ADR 0009 (tracker Facility record creation during CRM provisioning) following the architecture review completed in task 0021. Update all proposed qualifiers to accepted across both mirrors.

## Acceptance Criteria

- [x] ADR 0009 status updated from `proposed` to `accepted` in both mirrors
- [x] `decisions/README.md` lists ADR 0009 as `Accepted` in both mirrors
- [x] `data_model.md` no longer refers to ADR 0009 as proposed in both mirrors
- [x] `features.md` no longer refers to ADR 0009 as proposed in both mirrors
- [x] `user_flows.md` no longer refers to ADR 0009 as proposed in both mirrors
- [x] `ai_memory.md` references ADR 0009 as accepted in both mirrors
- [x] `execution_log.md` updated in both mirrors
- [x] Task doc exists under `tasks/done/alh-tracker/`
- [x] Changes committed to `ai-workspace-framework`
- [x] No application code changed

## Plan

Serial — small documentation-only acceptance task with no independent workstreams.

- [x] Update ADR 0009 status: proposed → accepted (both mirrors)
- [x] Update decisions/README.md: Proposed → Accepted (both mirrors)
- [x] Update data_model.md: remove four (ADR 0009 — proposed) / (proposed — ADR 0009) qualifiers (both mirrors)
- [x] Update features.md: (ADR 0009 — proposed) → (ADR 0009 — accepted) (both mirrors)
- [x] Update user_flows.md: (ADR 0009 — proposed) → (ADR 0009 — accepted) (both mirrors)
- [x] Update ai_memory.md: proposed → accepted (both mirrors)
- [x] Update execution_log.md (both mirrors)
- [x] Create this task doc in done
- [x] Commit ai-workspace-framework

## Notes

ADR 0009 was created in task 0020 and reviewed in task 0021. The architecture review recommendation was "Accept with minor edits." The minor edits (two additional Open Implementation TODOs: retry payload conflict behavior and re-provision-when-disabled edge case) were applied during task 0021. No further edits were needed before acceptance.

No application code was changed in this task. No Supabase schema changes.

## Outcome

ADR 0009 accepted. All proposed qualifiers removed. Eight files updated in each mirror (ADR file, decisions/README.md, data_model.md, features.md, user_flows.md, ai_memory.md, execution_log.md, this task doc). Changes committed to ai-workspace-framework.

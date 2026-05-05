# Improve Staff Follow-Up Queue

Status: backlog
Created: 2026-05-04
Owner role: Operations / Concierge Workflow Lead
Reviewers: Developer, QA / Test Lead

## Goal

Improve the internal staff follow-up queue for lead review, facility outreach, reminders, and scheduling next steps.

## Acceptance Criteria

- Staff can see due follow-up tasks in priority order.
- Lead-related tasks are linked to lead detail.
- Facility outreach and scheduling reminders are represented clearly.
- Completed or stale tasks have an expected handling path.
- The workflow supports manual Google Workspace and Google Voice operations for MVP.

## Plan

- [ ] Review `features.md`, `user_flows.md`, `global/api_patterns.md`, and current admin pages.
- [ ] Inspect how task interactions are currently stored and displayed.
- [ ] Define the staff queue UX and filtering needs.
- [ ] Identify data/API changes, if any.
- [ ] Implement and verify in a later scoped task.

## Notes

- The `POST /api/leads` task records due task interactions directly in `alh_interactions`; reuse that pattern unless a better task model is introduced.

## Outcome

Pending.

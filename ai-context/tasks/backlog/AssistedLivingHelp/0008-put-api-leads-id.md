# Implement Lead Update API Endpoint

Status: backlog
Created: 2026-05-04
Owner role: Developer
Reviewers: Technical Architect, QA / Test Lead

## Goal

Implement a staff-authenticated JSON endpoint for updating an existing lead, consistent with current admin lead edit behavior and the established `POST /api/leads` route pattern.

## Acceptance Criteria

- `PUT /api/leads/[id]` or `PATCH /api/leads/[id]` behavior is selected and documented.
- The endpoint requires an active staff session and returns JSON 401 rather than redirecting.
- Only allowed lead fields are updateable.
- Validation errors return JSON 400 responses.
- Lead update interactions are logged.
- `api_spec.md` is updated with the route contract.
- TypeScript verification passes.

## Plan

- [ ] Review `api_spec.md`, `global/api_patterns.md`, and `skills/core/write_api_endpoint_v1.md`.
- [ ] Inspect existing admin lead edit action.
- [ ] Choose PATCH vs PUT based on current app patterns.
- [ ] Implement the route with `getActiveStaffUser()`.
- [ ] Add route documentation and execution log entry.
- [ ] Verify with TypeScript or the available project check.

## Notes

- Do not add broad public lead update access in this task.
- Do not implement before `0004-lock-mvp-intake-fields.md` and `0005-define-consent-language-versions.md` are complete; the allowed update field set depends on those outcomes.

## Outcome

Pending.

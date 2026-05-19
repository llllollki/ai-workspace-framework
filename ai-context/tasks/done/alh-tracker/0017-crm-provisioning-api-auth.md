Status: done
Created: 2026-05-19
Completed: 2026-05-19
Owner role: Architecture / Documentation
Reviewers: n/a

## Goal

Resolve the ADR 0007 implementation blocker: decide how the internal CRM securely
authenticates to the tracker-controlled owner provisioning API endpoint.

ADR 0007 (accepted 2026-05-18) selected the custom `provisioning_tokens` table approach
and documented a tracker-owned provisioning API endpoint. The CRM-to-tracker API
authentication mechanism was explicitly deferred as an open TODO. That TODO blocks
implementation of both the tracker provisioning endpoint and the CRM's provisioning
action wiring.

## Acceptance Criteria

- [x] ADR 0008 created under `decisions/` with status `proposed`
- [x] ADR 0008 chooses an MVP authentication mechanism and documents a later-hardening path
- [x] ADR 0008 explicitly rejects giving CRM the tracker Supabase service-role key
- [x] ADR 0008 documents secret storage, rotation, revocation, least privilege, request
      metadata, replay/idempotency, and audit requirements
- [x] `ai_memory.md` updated to resolve the CRM-to-tracker API auth open question
- [x] `decisions/README.md` indexes ADR 0008
- [x] `execution_log.md` updated
- [x] No application code changed
- [x] Changes mirrored to `ai-workspace-framework`
- [x] This task doc moved to done

## Plan

- [x] Create this task doc
- [x] Write ADR 0008
- [x] Update `decisions/README.md`
- [x] Update ADR 0007 (resolve the API auth TODO reference)
- [x] Update `ai_memory.md`
- [x] Update `data_model.md` (add ADR 0008 reference to provisioning section)
- [x] Update `compliance_notes.md` (add API auth row to Data Handling Posture table)
- [x] Update `execution_log.md`
- [x] Mirror all to `ai-workspace-framework`
- [x] Move this task doc to done

## Notes

- Architecture/design documentation task only. No application code was touched.
- ADR 0008 status: `proposed`. Acceptance requires explicit user review.
- Subagents: not used. Task is design-sensitive and fully sequential.

## Outcome

Created `decisions/0008-crm-to-tracker-provisioning-api-authentication.md` (status:
proposed). Decision: rotating static API key (MVP); HMAC-signed short-lived JWT (Phase 2
hardening). CRM stores raw key server-side only (Vercel env vars). Tracker stores SHA-256
hash only. Zero-downtime rotation via versioned key slots. Five options evaluated and
rejected or deferred. Full request/response contract, idempotency, replay prevention, and
audit requirements documented. Seven open implementation TODOs recorded.

See `execution_log.md` entry dated 2026-05-19 for mechanical detail.

Status: done
Created: 2026-05-18
Completed: 2026-05-18
Owner role: AI agent
Reviewers: Product owner (human review before ADR 0007 is accepted)

## Goal

Resolve the next implementation blocker from ADR 0006: choose and document the CRM-to-Facility-Tracker owner provisioning mechanism and confirmation/deep-link token behavior. Produce ADR 0007 and update all affected context documents.

## Acceptance Criteria

- [x] ADR 0007 created with status: proposed
- [x] Provisioning mechanism options compared clearly (Supabase invite API, custom token table, manual, hybrid)
- [x] A recommended mechanism documented as proposed
- [x] Token behavior specified enough to unblock implementation planning (format, expiry, one-time use, resend, revocation, audit, storage, URL rules)
- [x] CRM/care-data boundary remains intact
- [x] Remaining TODOs are explicit
- [x] No application code changed
- [x] `ai_memory.md` updated to narrow or resolve the CRM provisioning mechanism blocker
- [x] `execution_log.md` updated
- [x] `decisions/README.md` updated (ADR 0007 row added; ADR 0006 status corrected to Accepted)
- [x] `data_model.md` updated (ProvisioningToken promoted from conceptual; ProvisioningEvent added; CRM fields noted)
- [x] Changes mirrored to `ai-workspace-framework`
- [x] Task doc moved to done after completion

## Plan

- [x] Read all required context files (ADR 0004, 0005, 0006, data_model.md, ai_memory.md, compliance_notes.md, user_flows.md, decisions/README.md)
- [x] Write ADR 0007
- [x] Update decisions/README.md
- [x] Update data_model.md
- [x] Update ai_memory.md
- [x] Update user_flows.md (Flow 0 step 4 TODO reference)
- [x] Update execution_log.md
- [x] Mirror all to ai-workspace-framework
- [x] Move task doc to done

## Notes

Subagent policy: Not using subagents. Design-sensitive documentation task where option analysis and ADR writing are tightly coupled. Proceeding serially.

Key decision: Custom `provisioning_tokens` table (Option B) selected over Supabase Auth invite API. Supabase invite API rejected because it requires CRM to hold tracker Supabase service-role key — violates ADR 0005 CRM/tracker boundary.

## Outcome

ADR 0007 created as `decisions/0007-crm-owner-provisioning-token-mechanism.md` with status: proposed. Decision: custom `provisioning_tokens` table (tracker-side). Supabase Auth user deferred to activation time. Full token lifecycle specified (72h expiry, SHA-256 hash, constant-time lookup, one-time use). `ProvisioningEvent` append-only audit table added to data model. 10 open implementation TODOs documented, none blocking architecture acceptance. CRM/tracker boundary maintained. No app code changed.

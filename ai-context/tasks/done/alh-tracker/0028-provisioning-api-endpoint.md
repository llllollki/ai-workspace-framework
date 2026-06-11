# 0028 — CRM Owner Provisioning: API Endpoint

Status: done
Created: 2026-05-19
Completed: 2026-05-20
Owner role: AI agent (main)
Depends on: 0030 (schema/RLS migrations), 0033 (ADR 0012 proposed), 0034 (ADR 0012 accepted)

---

## Goal

Implement the provisioning endpoint that the CRM calls to provision, resend, and revoke
tracker facility owner accounts. Implemented as a Supabase Edge Function per ADR 0012
Decision 1. All four Phase 2 blockers were resolved by ADR 0012 (accepted in task 0034)
before this task began.

---

## Acceptance Criteria

- [x] Edge Function exists at `supabase/functions/provision-owner/index.ts` and implements
      provision/resend/revoke behavior.
- [x] Constant-time API key comparison implemented (manual fixed-time byte loop, no
      Node.js-only dependencies).
- [x] All 7 required headers validated; missing header returns 400.
- [x] Timestamp window rejection (>5 min) returns 401.
- [x] Idempotency store consulted before action; same key + payload returns stored response.
- [x] Same key, different payload returns 409.
- [x] `provision` creates Facility (pending_setup) + Auth user (no-password, email_confirm=false)
      + User (invited, role=owner) + ProvisioningToken atomically (sequential service-role
      writes; auth user cleaned up on any subsequent failure).
- [x] `provision` sends activation email via Resend after DB writes; returns email_delivered
      flag so CRM can retry via resend action on delivery failure.
- [x] `resend` expires old tokens (used_at = now()), creates new token, sends new email.
- [x] `revoke` disables User (account_status = disabled) and expires tokens; bans auth user.
- [x] Re-provision of disabled User resets to invited, new token, new provisioning_reference
      (new ProvisioningEvent.id per ADR 0012 Decision 6).
- [x] Same X-CRM-Facility-Id with conflicting body data logs to structured application log
      only — no ProvisioningEvent written (per ADR 0034 defect fix / ADR 0012 Decision 5).
- [x] All actions write a ProvisioningEvent. provisioning_reference = ProvisioningEvent.id
      of the most recent `provisioned` event for the facility.
- [x] Response body never contains tracker IDs, raw tokens, token hashes, or care data.
- [x] Error responses are generic (no stack traces, no internal IDs).
- [x] Idempotency storage migration exists (migration 0009) and is reflected in db/schema.sql.
- [x] token_expired_passive enum value added via migration 0010; db/schema.sql updated.
- [x] `.env.local.example` updated with server-side variable documentation.
- [x] No client-side code (src/) modified.

---

## Plan

- [x] Read all required startup context and ADRs 0007–0012
- [x] Verify migration 20260101000007 state: token_expired_passive absent (confirmed); users.id FK
      to auth.users confirmed (critical constraint — requires auth user at provisioning time)
- [x] Write migration 0009: provisioning_idempotency_keys table
- [x] Write migration 0010: token_expired_passive enum value
- [x] Implement supabase/functions/provision-owner/index.ts
- [x] Update db/schema.sql
- [x] Update .env.local.example
- [x] Move task doc to done
- [x] Update ai_memory.md
- [x] Update execution_log.md
- [x] Mirror to ai-workspace-framework

---

## Subagent Policy

Not used for implementation. The Edge Function has critical ADR-interdependencies (users.id FK
to auth.users schema constraint discovered at implementation time, provisioning_reference
derivation, exact token semantics from six ADRs) that require tight context continuity.
Migrations are short SQL; function is design-sensitive. Proceeding serially per workspace
policy exception for tightly coupled, design-sensitive tasks.

---

## Notes

### Schema constraint: users.id FK to auth.users(id)

ADR 0007 intends to defer Supabase Auth user creation to activation time to avoid phantom
auth accounts. However, `users.id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE`
(from the initial schema migration) requires an `auth.users` entry before any `users` row
can be inserted. Since no schema migration was in scope to remove this FK for task 0028,
the pragmatic resolution is:

- At provisioning time: call `auth.admin.createUser({ email, email_confirm: false })` with no
  password. The auth user exists but cannot authenticate: no password set, email not confirmed.
- At activation time (task 0029): set the password via `auth.admin.updateUserById`.
- On revoke: ban the auth user (`ban_duration: '876000h'`) and set account_status = disabled.
- On re-provision: unban (`ban_duration: 'none'`), reset account_status = invited.

This satisfies the letter of ADR 0007's security requirement: the user cannot log in until
activation. A future task may add a schema migration to separate `users.id` from `auth.users.id`
to fully align with the ADR 0007 intent.

### provisioning_reference derivation

`provisioning_reference` is the `ProvisioningEvent.id` (UUID) of the most recent
`event_type = 'provisioned'` event for the facility. No additional column is needed.
For re-provision, a new `provisioned` event is written, yielding a new reference UUID per
ADR 0012 Decision 6.

### Atomicity

The Edge Function uses sequential service-role writes (not a true DB transaction). The
`crm_facility_reference` UNIQUE constraint provides structural idempotency for Facility
creation. On failure mid-sequence, the function cleans up the auth user and facility row.
A future hardening task should wrap the creation steps in a PostgreSQL RPC function for
true atomicity.

### token expiry semantics

Task 0028 spec specifies `used_at = now()` for both resend and revoke expiry. Tokens are
considered inactive when `used_at IS NOT NULL` (activation lookup includes `AND used_at IS NULL`).
The function uses this approach for both actions.

### alert delivery

Per ADR 0012 Decision 8, alert delivery is deferred. Auth failures are logged as structured
JSON via `console.warn` with source IP and request ID. The monitoring task to wire delivery
must be completed before production launch.

---

## Outcome

Edge Function `supabase/functions/provision-owner/index.ts` created. Migrations 0009
(provisioning_idempotency_keys) and 0010 (token_expired_passive) created and reflected in
`db/schema.sql`. `.env.local.example` updated with server-side variable documentation.
All three actions (provision/resend/revoke) implemented including re-provision of disabled
User. Response contract verified: no raw tokens, no tracker IDs, no care data returned.

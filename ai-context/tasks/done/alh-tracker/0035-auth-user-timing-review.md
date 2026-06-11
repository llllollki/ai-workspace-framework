# 0035 — Auth-User Timing Review and ADR 0013

Status: done
Created: 2026-05-20
Completed: 2026-05-20
Owner role: AI agent (main)
Depends on: 0028 (provisioning endpoint)

---

## Goal

Review the auth-user creation timing deviation introduced in task 0028 (provisioning
endpoint): `public.users.id FK → auth.users(id)` requires the Supabase Auth user to be
created at provisioning time, not at activation time as ADR 0007 originally specified.
Document whether this deviation preserves ADR 0007 security intent, update activation
task 0029 requirements accordingly, and create an ADR recording the decision.

---

## Acceptance Criteria

- [x] Auth-user timing deviation reviewed and accepted as safe.
- [x] ADR 0013 created documenting the deviation, security analysis, and activation requirements.
- [x] ADR 0007 updated (Phase 2 step 8g and partial activation recovery TODO).
- [x] Backlog task 0029 updated to reflect `updateUserById` instead of `createUser`.
- [x] Defect found and fixed: `ref ?? facility.id` fallback in Edge Function responses.
- [x] `decisions/README.md` updated with ADR 0013 row.
- [x] `ai_memory.md` updated.
- [x] `execution_log.md` updated.
- [x] Changes mirrored to `ai-workspace-framework`.
- [x] No unrelated app changes.

---

## Plan

- [x] Read all required startup and project context files
- [x] Review Edge Function for six security/contract points
- [x] Fix response contract defect (ref ?? facility.id fallback)
- [x] Write ADR 0013 (provisioning auth-user creation timing)
- [x] Update ADR 0007 (step 8g and partial activation recovery TODO)
- [x] Update backlog task 0029 (createUser → updateUserById, recovery spec)
- [x] Update decisions/README.md
- [x] Update ai_memory.md
- [x] Update execution_log.md
- [x] Create task done doc
- [x] Mirror to ai-workspace-framework

---

## Subagent Policy

Not used. The task is documentation-only with one small Edge Function fix. All work is
sequential: review findings → ADR → ADR 0007 update → task 0029 update → README →
ai_memory → log → mirror. No independent workstreams of sufficient size to warrant
subagent overhead.

---

## Review Findings

### Finding 1: Security verdict — ACCEPTED

The auth-user timing deviation preserves ADR 0007 security intent. Confirmed:

| Check | Result |
|---|---|
| No password set at provisioning | Pass — `createUser` call has no `password` field |
| email_confirm: false at provisioning | Pass — verified in Edge Function |
| No usable session before activation | Pass — no sign-in path works without password + confirmed email |
| account_status = invited | Pass — verified in Edge Function User insert |
| provisioning_status = pending_setup | Pass — verified in Edge Function Facility insert |
| Care-ops RLS quarantine blocks access | Pass — `is_active_user_on_active_facility()` requires both `active` states |

Residual risk (OTP/magic-link) documented in ADR 0013. Mitigation: tracker app must not
call `signInWithOtp` in the provisioning/activation context.

### Finding 2: New cleanup/revoke requirements — implemented

| Event | Required action | Implemented |
|---|---|---|
| Revoke | `updateUserById({ ban_duration: '876000h' })` | Yes — `handleRevoke()` |
| Re-provision | `updateUserById({ ban_duration: 'none' })` | Yes — `handleReprovision()` |
| Mid-provision failure | `deleteUser(authUserId)` | Yes — failure branches |

Cascade `public.users.id → auth.users(id) ON DELETE CASCADE` handles User row cleanup
when auth user is deleted.

### Finding 3: Task 0029 must use updateUserById

ADR 0007 Phase 2 Step 8g specified `auth.admin.createUser(...)`. Since the auth user
already exists, activation must call `auth.admin.updateUserById(user_id, { password,
email_confirm: true })`. Calling `createUser` with an existing email returns an error.

Both ADR 0007 and backlog task 0029 updated to reflect this.

### Finding 4: Partial activation recovery simplified

Original ADR 0007 spec required checking whether an auth user exists before calling
`createUser`. Since activation now calls `updateUserById` (always safe to retry),
no pre-existence check is needed. Task 0029 Section 3 rewritten accordingly.

### Finding 5: Response contract defect — found and fixed

`getProvisioningReference()` fallback to `facility.id` in three Edge Function paths
would expose the tracker's internal Facility UUID. Fixed in all three locations:
`handleProvision` (idempotent retry path), `handleResend`, and `handleRevoke`.
Error path now returns `{ error: 'internal_error' }` with a structured console log.

### Finding 6: No secrets exposed to client — PASS

All secrets (`SUPABASE_SERVICE_ROLE_KEY`, `CRM_API_KEY_V1_HASH`, `CRM_API_KEY_V2_HASH`,
`RESEND_API_KEY`, `RESEND_FROM_ADDRESS`, `TRACKER_BASE_URL`) accessed only via
`Deno.env.get()` in the Edge Function. No VITE_ prefix. No client-side code modified.
Activation URL (containing raw token) appears only in the Resend email call, never in
any response payload.

---

## Outcome

ADR 0013 created and accepted: auth-user timing deviation is safe and documented. Edge
Function defect fixed (response contract). ADR 0007 updated. Backlog task 0029 updated.
All context files updated and mirrored.

# 0013 — Provisioning Auth-User Creation Timing

**Date:** 2026-05-20
**Status:** accepted
**Supersedes:** ADR 0007 Phase 2 step 8g (auth.admin.createUser at activation) and the
Partial Activation Recovery TODO in ADR 0007 Open Implementation TODOs.
**Superseded by:** n/a

## Context

ADR 0007 (CRM Owner Provisioning Token Mechanism) specified that the Supabase Auth user
(`auth.users` entry) should be created at **activation time**, not at provisioning time.
The stated rationale was: "Supabase Auth user created only on successful activation —
no phantom auth accounts for unactivated or revoked owners."

ADR 0007 Phase 2 Step 8g specified:
> "Calls Supabase Admin API `auth.admin.createUser({ email, password, email_confirm: true })`
> to create the Supabase Auth user."

During implementation of the provisioning endpoint (task 0028), this was found to be
infeasible. The tracker schema defines:

```sql
CREATE TABLE users (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    ...
);
```

`public.users.id` is a primary key AND a foreign key to `auth.users(id)`. A row cannot be
inserted into `public.users` without a corresponding row in `auth.users`. There is no
migration in scope to remove this FK for task 0028 — doing so would require significant
schema surgery and RLS policy changes beyond the provisioning endpoint's scope.

This ADR documents the deviation from ADR 0007, records the security analysis confirming
that the security intent is preserved, specifies the new auth-user lifecycle requirements
that flow from this change, and records one defect found and fixed during the review.

### Constraints

1. The `public.users.id FK → auth.users(id)` constraint cannot be removed without a
   separate schema migration task. It is not in scope for the provisioning endpoint.
2. ADR 0007's security intent must be preserved: the auth user must not be usable for
   authentication until the owner completes the activation flow.
3. ADR 0010's RLS quarantine gate must remain the defense-in-depth layer even if an
   auth session were somehow obtained before activation.

---

## Decision

**Supabase Auth users are created at provisioning time, not activation time.**

At provisioning time, the Edge Function calls:

```typescript
db.auth.admin.createUser({
  email: owner_email,
  email_confirm: false,        // email not confirmed
  // no password field          // no password set
  user_metadata: { provisioned: true, provisioned_at: <iso_timestamp> },
})
```

The resulting auth user has:
- No password — cannot authenticate via `signInWithPassword`
- `email_confirm: false` — cannot authenticate via email confirmation flow
- No usable Supabase session
- `public.users.account_status = 'invited'`
- `Facility.provisioning_status = 'pending_setup'`

At activation time, the activation endpoint calls:

```typescript
db.auth.admin.updateUserById(user_id, {
  password: submitted_password,
  email_confirm: true,          // token validates email ownership
})
```

This replaces ADR 0007's Phase 2 Step 8g `createUser` call.

---

## Security Analysis

### Does this preserve ADR 0007's security intent?

**Verdict: Yes.** The auth user is created in an unusable state and cannot authenticate
until activation sets a password. Each security property is confirmed below.

| Property | ADR 0007 intent | Actual implementation | Preserved? |
|---|---|---|---|
| No phantom usable auth accounts | Auth user created only at activation | Auth user created at provisioning with no password and email_confirm: false | Yes — the auth user cannot authenticate; it is a database entry only |
| No password-based login before activation | Auth user has no password before activation | No `password` field in `createUser` call — Supabase creates user with no password | Yes ✓ |
| No email-confirmation flow before activation | Auth user not confirmed before activation | `email_confirm: false` at provisioning time | Yes ✓ |
| No usable session before activation | Owner cannot get a session before activating | Without password and with email unconfirmed, no normal sign-in path produces a session | Yes ✓ |
| Care-ops access blocked before activation | RLS quarantine blocks access | `account_status = invited` + `provisioning_status = pending_setup` fail `is_active_user_on_active_facility()` | Yes — defense in depth ✓ |

### Residual risk: Supabase OTP / magic link

Even without a password, a Supabase project that has OTP/magic-link sign-in enabled could
issue a session for a provisioning-time auth user (if someone calls `signInWithOtp` with
the owner's email before activation). This is not a production risk for alh-tracker
because:

1. The tracker app does not implement OTP or magic-link sign-in — the activation flow uses
   a custom provisioning token, not a Supabase auth magic link.
2. The RLS quarantine gate (ADR 0010) would block care-ops access even if a session were
   obtained — `is_active_user_on_active_facility()` requires `account_status = 'active'`
   AND `provisioning_status = 'active'`.
3. An OTP sent by Supabase goes to the owner's email — an attacker cannot intercept it
   without access to the owner's email account.

**Mitigation requirement:** The tracker app must never call `supabase.auth.signInWithOtp()`
for pre-existing users. OTP/magic-link flows must remain disabled or unused in the
provisioning context.

### New cleanup requirements introduced

Provisioning-time auth user creation introduces two additional auth-lifecycle operations
that did not exist in the original ADR 0007 spec:

| Event | Auth action required | Implementation |
|---|---|---|
| Revoke invitation | Ban auth user: `auth.admin.updateUserById(id, { ban_duration: '876000h' })` | Implemented in `handleRevoke()` |
| Re-provision disabled user | Unban auth user: `auth.admin.updateUserById(id, { ban_duration: 'none' })` | Implemented in `handleReprovision()` |
| Mid-provision failure | Delete auth user: `auth.admin.deleteUser(id)` | Implemented in failure-cleanup branches |

The cascade `public.users.id REFERENCES auth.users(id) ON DELETE CASCADE` means that
deleting the auth user automatically deletes the `public.users` row. The cleanup branches
in the Edge Function issue `deleteUser` on failure followed by facility deletion — the
cascade handles the user row.

---

## Activation Endpoint Impact (Task 0029)

### Step 8g change

ADR 0007 Phase 2 Step 8g specified `auth.admin.createUser(...)`. This is now:

```
auth.admin.updateUserById(user_id, {
  password: submitted_password,
  email_confirm: true
})
```

The activation endpoint must NOT call `createUser` — the auth user already exists. Calling
`createUser` with an existing email will return an error.

### Partial activation recovery — simplified

ADR 0007 Open Implementation TODOs specified:
> "Before calling `createUser`, check whether a Supabase auth user already exists for this
> email; if so, skip creation and proceed directly to account status update and token marking."

This check is no longer needed. The auth user always exists. The activation endpoint
simply calls `updateUserById` in all cases — this call is idempotent (safe to call
multiple times for the same user ID). Partial activation recovery is now:

1. Token is found with `used_at IS NULL` (same token, re-attempted activation)
2. Call `updateUserById` to set/reset the password (idempotent)
3. Proceed with DB state updates and token marking

No pre-existence check required. If `updateUserById` fails (e.g., auth user was deleted
due to a data integrity issue), the error is caught and written as `activation_failed`.

### Full activation sequence (corrected)

```
a. Parse raw token from request body
b. Compute SHA-256(raw_token) = token_hash
c. BEGIN transaction (SELECT ... FOR UPDATE on provisioning_token row)
d.   If token not found or used_at IS NOT NULL: return 400
e.   If expires_at < now(): return 400
f.   UPDATE users SET account_status = 'password_pending' WHERE id = token.user_id
g.   Validate submitted password (min complexity per compliance_notes.md)
h.   Call auth.admin.updateUserById(token.user_id, {
       password: submitted_password,
       email_confirm: true
     })
i.   UPDATE users SET account_status = 'active', name = submitted_name
j.   UPDATE facilities SET provisioning_status = 'active'
k.   UPDATE provisioning_tokens SET used_at = now()
l.   INSERT INTO provisioning_events (event_type = 'activated', ...)
m. COMMIT
n. Issue session (auth.signInWithPassword or signInWithIdToken) and return to client
```

---

## Defect Found and Fixed During Review

**Defect:** In the provisioning Edge Function (`supabase/functions/provision-owner/index.ts`),
three response paths used a fallback `ref ?? facility.id` when `getProvisioningReference()`
returned null. This fallback would expose the tracker's internal `Facility.id` UUID in the
response — a violation of the ADR 0008 response contract ("CRM never receives the tracker
Facility ID").

The three locations were:
1. `handleProvision` — idempotent retry path (facility exists, user not disabled)
2. `handleResend` — resend response
3. `handleRevoke` — revoke response

**Fix (applied in task 0035):** Each fallback replaced with a structured error log and
`{ error: 'internal_error' }` response. The null case should not occur in practice
(a Facility can only exist if a `provisioned` event was written), but the defensive path
must never expose internal IDs. The fix eliminates the exposure.

---

## Consequences

**Easier:**
- Activation endpoint is simpler: `updateUserById` is always called unconditionally.
  No pre-existence check, no conditional `createUser`/skip-creation logic.
- Partial activation recovery is simpler: `updateUserById` is idempotent — no additional
  state inspection needed before calling it.
- Auth-user cleanup on failure is handled by the existing cascade: `deleteUser` cascades
  to delete the `public.users` row.

**Harder / new constraints:**
- Revocation must ban the auth user, not just mark the tracker User as disabled.
  Without a ban, the auth user entry persists in `auth.users` without a corresponding
  blocker. This is implemented and verified.
- Re-provision must unban the auth user. Without an unban, the re-provisioned owner would
  be blocked even after activation.
- The `auth.users` table will contain entries for provisioning-time users that have never
  logged in. This is a minor operational reality — Supabase's auth admin dashboard will
  show these entries. They are identifiable by `user_metadata.provisioned = true` and
  `email_confirm = false`.
- If the FK constraint `public.users.id → auth.users(id)` is ever removed via a future
  migration (to fully align with the original ADR 0007 intent), the auth-user lifecycle
  described in this ADR must be revisited.

**Future hardening path:**
If a future migration removes the `public.users.id → auth.users(id)` FK, auth user
creation can be moved back to activation time per the original ADR 0007 intent. This
ADR should then be marked superseded by the new migration ADR.

---

## Non-Goals

This ADR does not change:
- The CRM/tracker boundary (ADR 0005, ADR 0006) — no CRM credentials are exposed.
- The provisioning token mechanism (ADR 0007) — tokens, hashing, expiry, and lifecycle events are unchanged.
- The RLS quarantine gate (ADR 0010) — the quarantine requirements are unchanged.
- The activation endpoint implementation scope (task 0029) — only the `createUser` → `updateUserById` substitution and the partial activation recovery simplification are in scope here.
- The `public.users.id → auth.users(id)` FK constraint — removing it is a separate hardening task.

# 0029 — CRM Owner Provisioning: Activation Endpoint and Page

Status: backlog
Created: 2026-05-19
Depends on: 0027 (schema), 0028 (provisioning API live — ProvisioningToken exists)
Blocks: 0032
Audit source: 0026

## Goal

Implement the owner activation flow: the `/activate` frontend route that renders a
create-password form, and the server-side endpoint that validates the provisioning token,
creates the Supabase Auth user, and transitions both `User.account_status → active` and
`Facility.provisioning_status → active` atomically. This is greenfield — no `/activate`
route, no activation endpoint, and no account_status routing logic exists today.

## Scope

### 1. Frontend: `/activate` Route and Page

**New route in App.tsx (or router config):**
```
/activate  →  ActivationPage
```

No authentication guard on this route (the token in the query param is the credential).

**ActivationPage component (`src/pages/ActivationPage.tsx`):**

URL query param: `?t=<raw_token>`

States:
1. **Loading** — validating token against server (on mount, do a lightweight token-check
   request before showing the form, to surface expired/used tokens early)
2. **Form** — create-password + profile confirmation fields:
   - Owner name (pre-populated from User record, editable)
   - Password (min 12 chars, uppercase, lowercase, digit — match ADR 0007 requirements)
   - Confirm password
3. **Submitting** — loading state while activation POST is in-flight
4. **Success** — brief success message + redirect to facility setup or dashboard
5. **Error: expired token** — "Your invitation link has expired" message with a prompt
   to contact the facility admin or request a resend
6. **Error: used or invalid token** — generic "This link is no longer valid" message
   (do not distinguish used from invalid — prevents enumeration)

**Post-activation routing:**
After successful activation, issue a Supabase session and redirect to the facility
tracker app's main route. The auth flow (Task 0031) adds routing logic to direct newly
active users with a `pending_setup` facility to a facility setup screen.

### 2. Server-Side Activation Endpoint

**Hosting:** Same runtime as the provisioning endpoint (decided in Task 0028).

**Route:** `POST /api/provisioning/activate` (or equivalent based on hosting model)

**Full activation sequence (ADR 0007 Phase 2, atomicity requirements):**

```
a. Parse raw token from request body
b. Compute SHA-256(raw_token) = token_hash
c. BEGIN transaction
d.   SELECT * FROM provisioning_tokens
       WHERE token_hash = $hash AND used_at IS NULL
       FOR UPDATE  ← row lock prevents concurrent activation
e.   If not found: return 400 (expired or invalid — same error for both)
f.   If expires_at < now(): return 400 (expired)
g.   UPDATE users SET account_status = 'password_pending' WHERE id = token.user_id
h.   Validate submitted password:
       - Min 12 characters
       - At least one uppercase letter
       - At least one lowercase letter
       - At least one digit
       - Return 400 on validation failure (do NOT advance DB state)
i.   Check partial activation recovery (see section 3 below)
j.   Call Supabase Admin API: auth.admin.createUser({
       email: user.email,
       password: submitted_password,
       email_confirm: true  ← skip email verification (token already validates ownership)
     })
k.   UPDATE users SET account_status = 'active', name = submitted_name
       WHERE id = token.user_id
l.   UPDATE facilities SET provisioning_status = 'active'
       WHERE id = token.facility_id
m.   UPDATE provisioning_tokens SET used_at = now()
       WHERE id = token.id
n.   INSERT INTO provisioning_events (event_type = 'activated', ...)
o. COMMIT
p. Issue Supabase session (auth.signInWithPassword) and return session to client
```

**On any failure between step j and step o:**
- Roll back the DB transaction if the commit has not yet occurred.
- Write `ProvisioningEvent: event_type = 'activation_failed'` OUTSIDE the rolled-back
  transaction (separate connection or after rollback).
- Return appropriate error to client.

### 3. Partial Activation Recovery

**Scenario:** Supabase `auth.admin.createUser()` (step j) succeeds but the DB transaction
(steps k–n) fails. The next activation attempt will hit the same token (still valid,
`used_at` still NULL).

**Recovery logic (before step j):**
```
Check: does a Supabase Auth user already exist for user.email?
  If yes (partial prior run detected):
    Skip auth.admin.createUser() — user already exists in auth.users
    Resume at step k
  If no:
    Proceed normally with auth.admin.createUser()
```

Implementation: call `auth.admin.listUsers()` or `auth.admin.getUserByEmail()` to detect
the existing auth user. This check requires the service-role key (server-side only).

### 4. Token-Check Endpoint (Lightweight Pre-Form Validation)

**Route:** `GET /api/provisioning/activate/check?t=<token>`

Purpose: called on ActivationPage mount before showing the form, to surface expired/used
tokens without the user filling out the form first.

Response:
- `200 { "valid": true }` — token is present, unexpired, unused
- `200 { "valid": false, "reason": "expired" }` — token expired
- `200 { "valid": false, "reason": "invalid" }` — token not found or used

Note: this is informational only. The activation POST re-validates the token under the
SELECT FOR UPDATE lock regardless of this check result.

### 5. Account Status Routing (delegated to Task 0031)

The AuthProvider and post-login routing changes that check `account_status` and
`provisioning_status` are in Task 0031 (Tracker Auth/Frontend Changes). Task 0029's
activation endpoint issues the session; Task 0031 ensures the app routes correctly
after that session is established.

## Acceptance Criteria

- [ ] `/activate` route exists and renders ActivationPage.
- [ ] ActivationPage shows loading state while validating token.
- [ ] Expired/used/invalid token shows appropriate error message.
- [ ] Password form validates all complexity requirements client-side before submit.
- [ ] Activation POST validates token with SELECT FOR UPDATE.
- [ ] Supabase Auth user is created server-side only (service-role key — never client-side).
- [ ] `User.account_status → active` and `Facility.provisioning_status → active` transition atomically.
- [ ] `ProvisioningToken.used_at` is set after activation.
- [ ] `ProvisioningEvent: activated` is written on success.
- [ ] `ProvisioningEvent: activation_failed` is written on failure (outside rolled-back txn).
- [ ] Partial activation recovery: if auth user already exists, skip createUser and resume.
- [ ] Two concurrent activations of the same token: exactly one succeeds (SELECT FOR UPDATE).
- [ ] Post-activation session is issued and client is redirected.
- [ ] Raw token never logged, never stored in plaintext, never returned to client.

## Dependencies (blockers)

- 0027 must be complete (users.account_status, facilities.provisioning_status, provisioning_tokens exist)
- 0028 must be complete (determines hosting model, env vars, and service-role key pattern)
- Blocker #4 (native deep-link model) blocks mobile deep-link behavior for the activation URL,
  but does NOT block server-side activation or web-based activation flow

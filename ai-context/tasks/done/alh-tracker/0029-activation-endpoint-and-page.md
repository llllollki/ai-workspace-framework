# 0029 — CRM Owner Provisioning: Activation Endpoint and Page

Status: done
Created: 2026-05-19
Completed: 2026-05-20
Depends on: 0030 (schema), 0028 (provisioning API live — ProvisioningToken exists)
Blocks: 0032
Audit source: 0026

## Goal

Implement the owner activation flow: the `/activate` frontend route that renders a
create-password form, and the server-side endpoint that validates the provisioning token,
sets the Supabase Auth user password (via `auth.admin.updateUserById` per ADR 0013), and
transitions both `User.account_status → active` and `Facility.provisioning_status → active`
atomically via PostgreSQL RPC.

## Outcome

### Deliverables

1. **`supabase/migrations/20260101000011_activate_owner_rpc.sql`** — Two SECURITY DEFINER
   PostgreSQL RPC functions, REVOKE from PUBLIC, GRANT to service_role:
   - `check_activation_token(p_token_hash text) → jsonb`: Pre-flight read; returns `{valid, email,
     name}` for valid tokens, `{valid: false, reason}` for expired/invalid. Treats not-found and
     already-used identically to prevent enumeration.
   - `complete_owner_activation(p_token_hash text, p_user_name text, p_actor_id text) → jsonb`:
     Atomic commit using `SELECT FOR UPDATE SKIP LOCKED`; updates users, facilities,
     provisioning_tokens; inserts `activated` provisioning_event; returns `{ok, user_id,
     facility_id, token_id}` or `{error}`.

2. **`supabase/functions/activate-owner/index.ts`** — Deno Edge Function:
   - CORS headers (browser-facing, unlike provision-owner which is server-to-server).
   - **GET `?t=<token>`**: token pre-flight check; strips internal IDs before response.
   - **POST `{ token, password, name }`**: full activation sequence — hash token, validate
     password complexity, check token via RPC, set `account_status = password_pending`,
     call `auth.admin.updateUserById(userId, { password, email_confirm: true })`, call
     `complete_owner_activation` RPC, handle idempotency (double-submit → success), sign
     in and return session.
   - Best-effort `activation_failed` audit events on any failure path.
   - Raw token never logged; internal IDs never returned to client.

3. **`src/pages/ActivationPage.tsx`** — React activation form:
   - Reads `?t=` from URL via `useSearchParams()`.
   - On mount: GET pre-flight check → states: `loading | no_token | expired | invalid | ready`.
   - Form: read-only email display, editable name (pre-populated), password + confirm password.
   - Client-side password complexity validation (mirrors server rules).
   - On success: `auth.setSession()` + `navigate('/')`, or `navigate('/sign-in', { state: { activated: true } })` if no session.
   - UI matches SignIn.tsx (same layout, brand colors, rounded-2xl card).

4. **`src/App.tsx`** — Public `/activate` route added outside all auth guards.

5. **`db/schema.sql`** — `check_activation_token` and `complete_owner_activation` functions
   added to the reference schema.

### Acceptance criteria met

- [x] `/activate` route exists and renders ActivationPage.
- [x] ActivationPage shows loading state while validating token.
- [x] Expired/used/invalid token shows appropriate error message.
- [x] Password form validates all complexity requirements client-side before submit.
- [x] Activation POST validates token with SELECT FOR UPDATE (via RPC).
- [x] Supabase Auth user password is set server-side only via `auth.admin.updateUserById()`.
- [x] `User.account_status → active` and `Facility.provisioning_status → active` atomically.
- [x] `ProvisioningToken.used_at` is set after activation.
- [x] `ProvisioningEvent: activated` is written on success.
- [x] `ProvisioningEvent: activation_failed` is written on failure (best-effort, non-throwing).
- [x] Partial activation recovery: `updateUserById` called unconditionally — idempotent, no pre-existence check.
- [x] Two concurrent activations: exactly one succeeds (SKIP LOCKED → `locked_or_invalid`).
- [x] Idempotency: second POST after `account_status = active` returns success, no duplicate event.
- [x] Post-activation session issued and client redirected.
- [x] Raw token never logged, never stored plaintext, never returned to client.
- [x] `tsc --noEmit` clean, `vite build` clean.

### Notes

- CORS required on activate-owner (browser → Edge Function direct); provision-owner is
  server-to-server and does not need CORS headers.
- `auth.admin.updateUserById()` is idempotent for the same user_id — safe to retry on partial failure.
- `SELECT FOR UPDATE SKIP LOCKED` in `complete_owner_activation` means a concurrent request
  returns `locked_or_invalid` immediately rather than blocking; Edge Function checks
  `account_status = active` and returns success for the double-submit case.
- Account status `password_pending` is set as a pre-flight marker before the auth admin API
  call, signaling in-progress activation to any concurrent reads.

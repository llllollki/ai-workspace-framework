# 0031 — Tracker App: Auth and Frontend Changes for Provisioning

Status: backlog
Created: 2026-05-19
Depends on: 0027 (schema — account_status, provisioning_status columns), 0029 (activation endpoint creates sessions)
Parallel with: 0030 (CRM UI changes)
Blocks: 0032
Audit source: 0026

## Goal

Update the tracker app's AuthProvider and routing logic to handle the new `account_status`
and `provisioning_status` states introduced by the provisioning flow. No auth logic
for these states exists today. This task covers post-login routing, the "pending setup"
facility state, and disabled-user session revocation.

## Current State (from audit 0026)

- `AuthProvider.tsx`: dual-mode (demo/Supabase); `AuthUser` includes `facilityId: string | null`;
  facility_id derived from `users` table on login ✓. No `account_status` or
  `provisioning_status` checks anywhere.
- `supabase.ts`: anon key only (correct) ✓.
- No `/activate` route (created in Task 0029).
- No routing logic for `account_status != active` or `provisioning_status != active`.
- No "setup pending" screen or "account disabled" screen.

## Scope

### 1. AuthUser Type

Add to `AuthUser` interface (`src/lib/AuthProvider.tsx` or `src/types/auth.ts`):
```typescript
accountStatus: 'invited' | 'password_pending' | 'active' | 'disabled';
facilityProvisioningStatus: 'pending_setup' | 'active' | 'suspended' | 'closed';
```

Populate these fields from the `users` table query on login (same query that derives
`facilityId` today). Also join `facilities.provisioning_status`.

### 2. Post-Login Routing Guard

After a successful Supabase session is established and the user record is loaded,
apply routing logic before entering care-ops routes:

```
if accountStatus == 'active' AND facilityProvisioningStatus == 'active':
  → proceed to normal app routing (no change to current behavior)

if accountStatus == 'active' AND facilityProvisioningStatus == 'pending_setup':
  → redirect to <FacilitySetupScreen> (see section 4)

if accountStatus == 'disabled':
  → sign out immediately (auth.signOut())
  → show "Your account has been disabled. Contact ALH Tracker support." message

if accountStatus == 'password_pending':
  → this state should only exist transiently during activation (server-side)
  → if a session somehow exists: sign out + generic error message
  → in practice, Supabase Auth users are created only at activation time,
    so a 'password_pending' user has no auth user and cannot hold a session
    (this guard is defensive only)
```

**Note:** `invited` users also have no Supabase Auth session (auth user created at
activation per ADR 0007) — they cannot reach this routing logic. This guard is for
`active` and `disabled` states only in practice.

### 3. Route Protection

Existing route guards that check `isAuthenticated` should be extended to also verify
`accountStatus == 'active'` AND `facilityProvisioningStatus == 'active'` before rendering
any care-ops route.

**Routes that require both checks:**
- All existing protected routes (shift logs, residents, care logs, etc.)

**Routes that do NOT require these checks:**
- `/activate` — token is the credential; added in Task 0029 as unguarded route
- `/login` — pre-auth

### 4. FacilitySetupScreen

A minimal interstitial screen shown when `facilityProvisioningStatus == 'pending_setup'`
after activation (edge case: facility may still be in pending_setup briefly if the
activation transaction is delayed, though normally it transitions atomically).

In practice, by the time a user activates, the facility should be `active`. This screen
handles any race or edge case and provides a clear state for the owner:

- Message: "Your account is active. Your facility is being set up — this should complete
  shortly. If this persists, contact support."
- Auto-retry check every 30 seconds (polling `facilities.provisioning_status` via Supabase
  anon client).
- On `provisioning_status == 'active'`: redirect to main app.

**Note:** This screen may never be shown in the happy path. It is a defensive fallback.

### 5. Disabled User Session Revocation

When `account_status` changes to `disabled` server-side (via `revoke` action in Task 0028),
the user's active Supabase session must be revoked:

- The provisioning endpoint's `revoke` action should call
  `supabase.auth.admin.signOut(userId)` (service-role only) after setting
  `User.account_status = 'disabled'` in the DB.
- The tracker app's routing guard (section 2 above) is a defensive second check:
  on next session refresh or page load, the guard will catch `account_status == 'disabled'`
  and sign out.

**Implementation note for Task 0028:** Add `auth.admin.signOut(userId)` call to the
`revoke` action, after the DB update and ProvisioningEvent write.

### 6. Auth Refresh Handling

If a user's session is revoked server-side (disabled), the Supabase Auth client may
return a `SIGNED_OUT` event on the next token refresh. AuthProvider must handle this
event and redirect to login with an appropriate message.

## Acceptance Criteria

- [ ] `AuthUser` type includes `accountStatus` and `facilityProvisioningStatus`.
- [ ] Both fields populated from DB on login (joined query).
- [ ] `active` user + `active` facility: no routing change — existing behavior preserved.
- [ ] `active` user + `pending_setup` facility: redirected to FacilitySetupScreen.
- [ ] `disabled` user: signed out immediately on login or session check.
- [ ] All care-ops route guards verify both `accountStatus == 'active'` and `facilityProvisioningStatus == 'active'`.
- [ ] FacilitySetupScreen exists with polling retry and redirect on active state.
- [ ] Supabase `SIGNED_OUT` session event handled gracefully (redirect to login).
- [ ] No service-role key in any client-side code.
- [ ] Existing demo mode behavior unaffected (demo mode bypasses account_status checks).

## Dependencies

- 0027 must be complete (`users.account_status`, `facilities.provisioning_status` columns exist)
- 0029 must be complete (activation endpoint sets account_status and provisioning_status)
- 0028 `revoke` action should call `auth.admin.signOut` (cross-task note — see section 5)

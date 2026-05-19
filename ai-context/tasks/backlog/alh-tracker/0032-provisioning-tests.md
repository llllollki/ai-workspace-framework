# 0032 — CRM Owner Provisioning: Tests and Security Verification

Status: backlog
Created: 2026-05-19
Depends on: 0027, 0028, 0029, 0030, 0031 (all implementation phases complete)
Audit source: 0026

## Goal

Verify correctness, security, and tenant isolation of the complete CRM owner provisioning
and activation flow through unit tests, RLS/SQL policy tests, API integration tests,
end-to-end tests, and a manual Vercel validation checklist. No new application code is
added beyond test infrastructure.

## Scope

### 1. Unit Tests

**Token utilities:**
- Token generation: output is exactly 64 lowercase hex characters; output is different
  on each call (randomness check — run 100 iterations, assert no duplicates).
- SHA-256 hashing: consistent output for same input; produces 64-char hex.
- Constant-time comparison: a correct key returns true; an incorrect key returns false;
  execution time must not differ meaningfully between matching and non-matching keys
  (timing test — measure 1000 iterations of each, assert mean difference < 1ms).

**Request validation:**
- Timestamp window: request from 4m 59s ago → passes; request from 5m 1s ago → rejects 401.
- Future timestamp > 60s ahead → rejects 401.
- Missing `Authorization` header → rejects 400.
- Missing any of the 6 other required headers → rejects 400.
- Invalid `action` value → rejects 400.

**Password complexity:**
- 12 chars with uppercase + lowercase + digit → passes.
- 11 chars → fails (too short).
- 12 chars no uppercase → fails.
- 12 chars no digit → fails.

### 2. RLS / SQL Policy Tests

Run against a local Supabase instance (or test project) with the 0027 migrations applied.

**`pending_setup` facility quarantine:**
- Authenticated user on a `pending_setup` facility:
  - SELECT on any care-ops table (residents, care_log_entries, etc.) → returns 0 rows
  - INSERT on any care-ops table → returns permission denied / 0 rows affected
  - Verify for all 13 tables listed in task 0027 Part E

**`active` user + `active` facility access:**
- Authenticated user on an `active` facility:
  - SELECT on care-ops tables → returns rows (not empty)
  - INSERT on care-ops tables → succeeds

**`disabled` user:**
- `disabled` user cannot hold a Supabase session (structural: no auth.users entry for
  an invited/disabled user, and signOut called on revoke) — verify via auth.admin check.

**`provisioning_tokens` table:**
- Anon role SELECT → permission denied
- Authenticated role SELECT → permission denied
- Anon role INSERT → permission denied
- Authenticated role INSERT → permission denied

**`provisioning_events` table:**
- Same as provisioning_tokens (zero client policies).
- Authenticated role UPDATE → permission denied (REVOKE in place).
- Authenticated role DELETE → permission denied.

**`crm_facility_reference` column:**
- A SELECT query on `facilities` from an authenticated user must not return
  `crm_facility_reference` in the result set (application-layer enforcement test —
  check that no repository query or API response includes this column).

**Tenant isolation:**
- User from Facility A cannot SELECT Facility B rows on any care-ops table.

### 3. API Integration Tests

Run against a local or staging provisioning endpoint.

**`provision` action (happy path):**
- POST with all required headers + valid body → 201
- Response contains `status: "provisioned"` and a UUID `provisioning_reference`
- Response does NOT contain tracker Facility.id, User.id, token_hash, or any care data
- DB: Facility row created with `provisioning_status = 'pending_setup'`
- DB: User row created with `account_status = 'invited'`
- DB: ProvisioningToken row created, `used_at IS NULL`
- DB: ProvisioningEvent row with `event_type = 'provisioned'`
- Activation email sent to owner_email

**`provision` idempotency:**
- Same `X-Idempotency-Key`, same payload → 201 with same `provisioning_reference` (no duplicate rows)
- Same `X-Idempotency-Key`, different payload → 409
- Same `X-CRM-Facility-Id`, expired idempotency key (24h+) → returns existing `provisioning_reference`
  (UNIQUE constraint deduplication, not idempotency store)

**`resend` action:**
- POST resend on `pending_setup` facility → 200; new ProvisioningToken; old token `used_at` set
- POST resend on `active` facility → 409
- POST resend on non-existent facility → 404

**`revoke` action:**
- POST revoke on `pending_setup` facility → 200; User.account_status = 'disabled'; token expired
- POST revoke on non-existent facility → 404

**Authentication failures:**
- Wrong API key → 401 (response body: `{"error":"unauthorized"}` — no detail)
- Missing Authorization header → 400
- Expired timestamp (>5 min) → 401
- Future timestamp (>60s) → 401

**Response sanitization:**
- Verify for every action: response body parsed as JSON contains no `facility_id`,
  `user_id`, `token_hash`, `token`, `crm_facility_reference`, or any care-data fields.

### 4. Activation Flow Tests

**Happy path:**
- GET /activate?t=<valid_raw_token> → ActivationPage renders form (not error)
- POST activation with valid token + password + name → 200; session issued; Facility active; User active; ProvisioningToken.used_at set; ProvisioningEvent `activated` written

**Expired token:**
- GET /activate?t=<expired_token> → ActivationPage shows expired message
- POST activation with expired token → 400

**Used token:**
- POST activate with same token twice → first succeeds; second returns 400

**Invalid token:**
- POST activate with fabricated hex string → 400

**Partial activation recovery:**
- Simulate: createUser succeeds, DB transaction fails (use test hook or direct DB manipulation to leave auth.users entry without completing the DB update)
- Retry activation with same token → recovery path skips createUser; completes DB steps; success

**Race condition (two concurrent activation requests):**
- Fire two simultaneous POST activations with the same token
- Assert: exactly one succeeds with 200; the other returns 400
- Assert: only one ProvisioningEvent `activated` is written; ProvisioningToken.used_at set once

**Password validation:**
- POST activate with password too short → 400; DB not advanced past `password_pending`

### 5. End-to-End Tests

Full flow from CRM action to active facility (requires staging environment with both
CRM and tracker deployed):

1. CRM staff clicks "Provision tracker account" → tracker provisioning API called → 201 returned
2. Owner email received with activation link
3. Owner opens activation link → ActivationPage rendered
4. Owner sets password + submits → session issued → redirected to tracker app
5. Facility.provisioning_status = active → care-ops routes accessible
6. ProvisioningToken.used_at is set; ProvisioningEvent records exist for `provisioned` and `activated`

**Expired token E2E:**
7. Token expires (advance DB `expires_at` to past) → owner clicks original link → expired message shown

**Revoke then attempt activation:**
8. CRM clicks "Revoke invitation" → User.account_status = disabled; token expired
9. Owner clicks original activation link → generic invalid error shown (not expired)

### 6. Manual Vercel Validation Checklist

Execute against the production Vercel deployment after go-live:

- [ ] Provisioning endpoint returns 401 for missing Authorization header
- [ ] Provisioning endpoint returns 400 for missing `X-Request-Id` header
- [ ] Provisioning endpoint returns 401 for expired `X-Request-Timestamp`
- [ ] `provision` action creates Facility in `pending_setup` state (verify in Supabase Studio)
- [ ] `provision` action creates User in `invited` state (verify in Supabase Studio)
- [ ] Activation email received (check inbox and spam)
- [ ] Activation URL opens `/activate` page correctly on web browser
- [ ] Create-password form visible; client-side validation works
- [ ] Successful activation transitions Facility to `active` (verify in Supabase Studio)
- [ ] Successful activation transitions User to `active` (verify in Supabase Studio)
- [ ] ProvisioningToken.used_at is set after activation (verify in Supabase Studio)
- [ ] ProvisioningEvent rows exist for `provisioned` and `activated` events
- [ ] `resend` creates new token and expires old one
- [ ] `revoke` sets User.account_status to `disabled`; old token expires
- [ ] Active facility owner can access care-ops routes after activation
- [ ] API response to CRM contains no tracker IDs or care data
- [ ] `crm_facility_reference` does not appear in any API response to the CRM or client
- [ ] Service-role key not visible in any browser network request

## Acceptance Criteria

- [ ] All unit tests pass.
- [ ] All RLS/SQL policy tests pass.
- [ ] All API integration tests pass.
- [ ] Happy path E2E test passes.
- [ ] Race condition test: exactly one concurrent activation succeeds.
- [ ] Partial activation recovery test passes.
- [ ] Manual Vercel validation checklist completed and signed off.
- [ ] No test uses the service-role key in client-side test code.

## Dependencies

- All of 0027, 0028, 0029, 0030, 0031 must be complete
- Staging environment with both CRM and tracker deployed (for E2E tests)
- Supabase local dev or test project with 0027 migrations applied (for RLS tests)

# 0032 — CRM Owner Provisioning: Tests and Security Verification

Status: done
Created: 2026-05-19
Closed: 2026-05-23
Owner role: AI agent (main)
Depends on: 0027, 0028, 0029, 0030, 0031 (all implementation phases complete)
Audit source: 0026

## Goal

Verify correctness, security, and tenant isolation of the complete CRM owner provisioning
and activation flow through unit tests, RLS/SQL policy tests, API integration tests,
end-to-end tests, and a manual Vercel validation checklist. No new application code is
added beyond test infrastructure.

## Subagent Policy

Proceeding serially. Test files are small and tightly coupled to the handler under test.
Subagent overhead would exceed the benefit for this scoped implementation.

## Acceptance Criteria (original — full scope)

- [ ] All unit tests pass.
- [ ] All RLS/SQL policy tests pass. **BLOCKED — requires local Supabase instance.**
- [ ] All API integration tests pass. **BLOCKED — requires staging credentials.**
- [ ] Happy path E2E test passes. **BLOCKED — requires staging environment.**
- [ ] Race condition test: exactly one concurrent activation succeeds. **BLOCKED — staging.**
- [ ] Partial activation recovery test passes. **BLOCKED — staging.**
- [ ] Manual Vercel validation checklist completed and signed off. **BLOCKED — production.**
- [ ] No test uses the service-role key in client-side test code.

## What Was Implemented (local, no-credential scope)

### Test Framework Added

- **Vitest** (`^4.1.7`) added as devDependency alongside `@types/node` (`^25.9.1`).
- `vitest.config.ts` created: Node.js test environment; includes `tests/**/*.test.ts`.
- `"test:provisioning": "vitest run tests/provisioning"` added to `package.json` scripts.

### `tests/provisioning/bridge.test.ts` — 23 tests

Tests `api/crm/provision.ts` (the CRM-to-tracker provisioning bridge) with all external
calls mocked (`requireCrmAuth`, `fetch`, `process.env`). No credentials required.

**Method validation:**
- GET → 405 method_not_allowed
- DELETE → 405 method_not_allowed

**CRM auth validation (mocked requireCrmAuth):**
- 401 missing_token → forwarded as 401
- 403 staff_inactive → forwarded as 403
- 403 insufficient_role → forwarded as 403

**Bridge configuration:**
- CRM_TRACKER_PROVISIONING_KEY absent → 503 bridge_not_configured
- TRACKER_PROVISION_URL absent → 503 bridge_not_configured

**Request body validation:**
- Malformed JSON → 400 bad_request
- Invalid action value → 400 bad_request
- Missing crmFacilityId → 400 bad_request
- provision action missing facilityCity → 400 bad_request
- provision action missing ownerEmail → 400 bad_request
- resend without provision fields → passes to upstream (200 from mock)
- status without provision fields → passes to upstream (200 from mock)

**Response sanitization — security boundary (5 tests):**
- All 10 forbidden tracker fields verified absent from bridge response when present in
  upstream: `facility_id`, `user_id`, `token_hash`, `token`, `crm_facility_reference`,
  `service_role_key`, `tracker_user_id`, `auth_user_id`, `care_data`, `tracker_facility_id`
- Only safe fields forwarded: `provisioning_reference`, `provisioning_status`,
  `email_delivered`, `token_expired` (last two only when upstream sends a boolean)
- `token_expired` omitted when upstream sends non-boolean; included for false and true
- `email_delivered` omitted when absent from upstream

**Upstream error handling:**
- fetch throws (ECONNREFUSED) → 502 upstream_unavailable
- upstream returns non-JSON → 502 upstream_invalid_response
- upstream 404 → 404 provisioning_failed
- upstream 409 → 409 provisioning_failed
- upstream 500 → 500 provisioning_failed

### `tests/provisioning/crypto.test.ts` — 20 tests

Implements Node.js equivalents of the Deno Edge Function utility functions and tests
their behavioral contract. The Deno functions (`provision-owner/index.ts`,
`activate-owner/index.ts`) use `https://esm.sh/` imports and cannot be imported in
Node.js — these tests verify the contract without requiring the Deno runtime.

**sha256Hex (4 tests):**
- Produces exactly 64 lowercase hex chars
- Deterministic for same input
- Produces different output for different inputs
- No fixed point (sha256(x) ≠ x for representative inputs)

**generateRawToken (3 tests):**
- Produces exactly 64 lowercase hex chars
- 100 consecutive calls produce 100 unique values
- Encodes exactly 32 bytes (256 bits of entropy)

**timingSafeEqualHex (5 tests):**
- Identical hex strings → true
- Different hex strings of equal length → false
- Different length strings → false
- Empty string vs real hash → false (both orders)
- Two separately computed hashes of same input → true

**validatePassword (8 tests):**
- Valid 12+ char password with upper/lower/digit → `{ valid: true }`
- Several valid variants accepted
- 11 chars → `{ valid: false, reason: 'min_length' }`
- Exactly 11 chars even when otherwise valid → min_length
- Exactly 12 chars with all requirements → passes
- No uppercase → `{ valid: false, reason: 'uppercase_required' }`
- No lowercase → `{ valid: false, reason: 'lowercase_required' }`
- No digit → `{ valid: false, reason: 'digit_required' }`

## Test Results

All 43 tests pass:
- `tests/provisioning/bridge.test.ts`: 23 tests PASS
- `tests/provisioning/crypto.test.ts`: 20 tests PASS
- Duration: ~288ms

## Local Checks

| Check | Result |
|---|---|
| npm run test:provisioning | PASS (43/43 tests) |
| npx tsc --noEmit | PASS (exit 0, no output) |
| npm run build | PASS (479.00 kB, built in ~2.00s) |
| npm run verify:secrets | PASS (FAIL: 0, WARN: 0) |

## Remaining Credential-Dependent Scope

The following test categories from the original task 0032 backlog spec are **BLOCKED**
pending external environment access:

1. **RLS/SQL policy tests** (Section 2): require a local Supabase instance with migrations
   0000–0014 applied. Verify: `pending_setup` quarantine, `active` user access, disabled
   user, `provisioning_tokens` zero-policy, `crm_facility_reference` column exclusion,
   tenant isolation. Reference: task 0032 backlog spec Section 2.

2. **API integration tests** (Section 3): require staging Vercel deployment + Supabase with
   live SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY. Verify: provision/resend/revoke happy
   paths, idempotency (same key → same reference; different payload → 409), auth failures,
   full response sanitization with real tracker response. Reference: task 0032 backlog spec
   Section 3.

3. **Activation flow tests** (Section 4): require full staging environment with Supabase Auth
   Admin API. Verify: GET /activate with valid token, POST activation with password, expired
   token, used token, race condition (two concurrent activations). Reference: task 0032 backlog
   spec Section 4.

4. **End-to-end tests** (Section 5): require both CRM and tracker deployed. Verify: full
   provision → email → activate → care-ops access flow. Reference: task 0032 backlog spec
   Section 5.

5. **Manual Vercel validation checklist** (Section 6): execute against production after go-live.
   Reference: task 0032 backlog spec Section 6.

Existing staging verification resources that partially cover sections 3–6:
- `scripts/verify-provisioning/scenarios.md` — provisioning lifecycle scenarios
- `scripts/verify-crm-persistence/scenarios.md` + `db-assertions.sql` — CRM persistence P1–P20

## Outcome

Completed 2026-05-23. Local-only scope implemented: Vitest framework added; 43 unit tests
covering CRM bridge validation, response sanitization, upstream error handling, and crypto
utility behavioral contracts — all pass without external credentials. Credential-dependent
scope (RLS, integration, E2E, manual checklist) documented as remaining operator work.

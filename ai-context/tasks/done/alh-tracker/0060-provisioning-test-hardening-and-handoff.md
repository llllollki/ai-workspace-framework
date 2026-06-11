# 0060 — Provisioning Test Hardening and Integration-Test Handoff

Status: done
Created: 2026-05-23
Closed: 2026-05-23
Owner role: AI agent (main)
Depends on: 0032 (local provisioning tests), 0052 (CRM auth middleware), 0053 (CRM login)

## Goal

Verify the local provisioning test setup from task 0032 is durable; fix documentation
gaps in the existing operator verification guide; create a concise operator-ready handoff
document for the credential-dependent provisioning checks that remain blocked locally.

No new provisioning behavior is added. No tests require real secrets.

## Subagent Policy

Proceeding serially. Steps are tightly sequential: gap inspection → fix → checks → docs.
No independent workstreams warrant subagent delegation.

## Acceptance Criteria

- [x] Local provisioning tests verified durable (npm run test:provisioning passes 43/43).
- [x] Gap 1 fixed: scenarios.md Prerequisites updated with CRM auth requirement (added in
      task 0052, missing from guide written in task 0040).
- [x] Gap 2 fixed: scenarios.md Environment Limitations updated to mention Scenario 9
      alongside Scenarios 1–7 (Scenario 9 added after the limitations section was written).
- [x] scripts/verify-provisioning/operator-handoff.md created: concise entry-point document
      covering what local Vitest covers, what requires credentials, RLS/SQL prerequisites,
      staging prerequisites, pointer to scenarios.md, explicit no-production-secrets
      instruction, pass/fail criteria.
- [x] npx tsc --noEmit PASS.
- [x] npm run build PASS (479.00 kB).
- [x] npm run verify:secrets FAIL: 0, WARN: 0.
- [x] ai_memory.md updated.
- [x] execution_log.md updated.
- [x] All changes mirrored to ai-workspace-framework.
- [x] Task moved to done.

## Gaps Found and Fixed

### Gap 1 — CRM auth header missing from scenarios.md Prerequisites

`scripts/verify-provisioning/scenarios.md` was written in task 0040 before CRM auth
middleware was added in task 0052. All 9 scenarios call `/api/crm/provision` but the
guide had no mention of the `Authorization: Bearer <jwt>` header now required by
`requireCrmAuth()`. Without this, every curl command returns 401.

**Fix:** Added a "CRM bridge auth" row to the Prerequisites table explaining the JWT
requirement and the `CRM_DEMO_AUTH_BYPASS=true` local dev shortcut (with explicit
"never in staging" warning). Updated the "How to call the CRM bridge" section with
`$AUTH_TOKEN` shell variable and `Authorization: Bearer $AUTH_TOKEN` in all three curl
examples. Updated `$BASE_URL` variable for consistency.

### Gap 2 — Scenario 9 missing from scenarios.md Environment Limitations

The Environment Limitations section stated "Scenarios 1-7 require a live DB" but Scenario 9
(Status Query) was added later and wasn't included. The section now reads:
"Scenarios 1–7 and Scenario 9 require a live DB and are manual-only."

Also added a pointer to `operator-handoff.md` from the Environment Limitations section.

## Operator Handoff Created

`scripts/verify-provisioning/operator-handoff.md` — concise entry point document:

- **Section 1:** What local Vitest tests cover (43 tests, no credentials) — bridge validation,
  auth forwarding, bridge config, body validation, response sanitization (10 forbidden fields),
  upstream error handling, crypto contracts (sha256Hex, generateRawToken, timingSafeEqualHex,
  validatePassword)
- **Section 2:** What requires local Supabase (Scenarios 1–7, 9) — `supabase start`
  prerequisites table, CRM auth setup (CRM_DEMO_AUTH_BYPASS note), RLS/SQL policy checks
- **Section 3:** What requires full staging (Scenario 6 activation, race condition, idempotency
  conflict, E2E) — staging env var checklist with STOP condition for CRM_DEMO_AUTH_BYPASS
- **Section 4:** Pass/fail criteria — local checks, staging assertions, 4 explicit STOP conditions
- **Section 5:** Canonical verification files table (7 files)

## Local Check Results

| Check | Result |
|---|---|
| npm run test:provisioning | PASS (43/43 tests) |
| npx tsc --noEmit | PASS (exit 0) |
| npm run build | PASS (479.00 kB) |
| npm run verify:secrets | PASS (FAIL: 0, WARN: 0) |

## Remaining Credential-Dependent Scope

Unchanged from task 0032 — nothing new added, nothing resolved:

- RLS/SQL policy tests: local Supabase required
- API integration tests (live idempotency, resend, revoke with real DB): staging required
- Activation flow and race condition tests: staging + Supabase Auth Admin API required
- E2E (provision → email → activate → care-ops): both CRM and tracker deployed required
- Manual Vercel checklist: production go-live required

Operator next actions: see `scripts/verify-provisioning/operator-handoff.md`.

## Outcome

Completed 2026-05-23. Two documentation gaps fixed in scenarios.md (CRM auth header
requirement; Scenario 9 in Environment Limitations). Operator handoff document created.
43/43 local tests still pass. No provisioning behavior changed.

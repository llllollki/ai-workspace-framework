# 0059 — CRM Staging Operator Verification Handoff

Status: done
Created: 2026-05-23
Owner role: Operator (human with staging credentials)
Depends on: 0058 (CRM persistence staging verification — runbook complete)

## Goal

Convert the 0058 staging blocker into a ready-to-execute operator handoff.
The CRM persistence code was verified locally (tasks 0051–0058); the only outstanding
work is executing P1–P20 against a real staging environment with real credentials.

This document is the operator's single entry point. It lists exactly what env vars
to confirm, what to run, and what pass/fail looks like. It does not duplicate the
detailed scenario steps — those live in the canonical files listed below.

## Subagent Policy

Proceeding serially. This is a documentation-only task. No independent workstreams.

## Acceptance Criteria

1. [x] Operator handoff document written with exact env var checklists.
2. [x] Canonical file index: 0058 runbook, scenarios.md, db-assertions.sql,
       crm_auth_runbook.md, provisioning_runbook.md.
3. [x] CRM_DEMO_AUTH_BYPASS confirmed absent in current shell env; documented as
       forbidden in all real-data environments.
4. [x] Local checks pass: npx tsc --noEmit, npm run build, npm run verify:secrets.
5. [ ] Operator executes P1–P20 against staging — BLOCKED pending operator credentials.
6. [x] ai_memory.md updated.
7. [x] execution_log.md updated.
8. [x] Mirrored to ai-workspace-framework.
9. [x] Task moved to done (handoff complete; staging execution remains operator-owned).

## Canonical Files

| File | Contents |
|---|---|
| `ai-context/tasks/done/alh-tracker/0058-crm-persistence-staging-verification.md` | Full operator runbook with prerequisites, P1–P20 checkpoints, DB assertion checkpoints, pass/fail criteria, cleanup SQL |
| `scripts/verify-crm-persistence/scenarios.md` | P1–P20 curl commands with expected HTTP responses |
| `scripts/verify-crm-persistence/db-assertions.sql` | A0–A9 SQL assertions for schema structure, audit_log, notes, comms, follow-ups |
| `scripts/verify-crm-auth/scenarios.md` | CRM auth boundary scenarios (missing token, inactive staff, no public.users) |
| `scripts/verify-crm-auth/db-assertions.sql` | CRM auth DB assertions |
| `ai-context/projects/alh-tracker/crm_auth_runbook.md` | CRM staff bootstrap steps (create Supabase Auth user → insert crm.crm_staff row → confirm no public.users row) |
| `ai-context/projects/alh-tracker/provisioning_runbook.md` | Full env var table (Sections 1.1–1.4), deployment order, alert webhook config (Section 7.4) |

## Operator Pre-Flight: Environment Variable Checklist

Run this checklist before executing any P1–P20 scenarios.
All steps require access to the Vercel project dashboard and Supabase project dashboard.

### Step 1 — Vercel Environment Variables

Open: Vercel project → Settings → Environment Variables.

**Must be present:**

| Variable | Purpose | If missing |
|---|---|---|
| `SUPABASE_URL` | Used by api/lib/crmAuth.ts to validate JWTs and query crm.crm_staff | All CRM API calls return HTTP 503 auth_not_configured |
| `SUPABASE_SERVICE_ROLE_KEY` | Service-role DB access for all crm.* queries | Same — HTTP 503 |
| `VITE_SUPABASE_URL` | Puts CRM frontend into Supabase mode (not demo) | Frontend falls back to demo/localStorage mode; CRM login page unreachable |
| `VITE_SUPABASE_ANON_KEY` | Frontend Supabase anon key | Same as above |
| `CRM_TRACKER_PROVISIONING_KEY` | Auth key for CRM→tracker provisioning bridge | Provisioning calls return HTTP 503 (CRM persistence scenarios unaffected) |
| `TRACKER_PROVISION_URL` | URL of provision-owner Edge Function | Same |
| `ALERT_WEBHOOK_URL` | Provisioning failure alerting | Alert calls no-op silently; not a staging blocker but required pre-production |

**Must be absent (or not set to 'true'):**

| Variable | Why it must be absent |
|---|---|
| `CRM_DEMO_AUTH_BYPASS` | If set to `'true'`, all CRM API auth is bypassed; audit_log entries use `changed_by='demo-staff'` instead of real crm_staff.id; staging results are invalid. **STOP if this is present.** |

**Verify CRM_DEMO_AUTH_BYPASS is absent:**
In Vercel dashboard, search the environment variables list for `CRM_DEMO_AUTH_BYPASS`.
It must not appear, or if it does appear, its value must not be `true`.

### Step 2 — Supabase Edge Function Secrets

Open: Supabase Dashboard → Edge Functions → Secrets (or run `supabase secrets list`).

| Secret | Required by | Status needed |
|---|---|---|
| `CRM_API_KEY_V1_HASH` | provision-owner | Required for provisioning (not CRM persistence) |
| `RESEND_API_KEY` | provision-owner, activate-owner | Required for invitation emails |
| `RESEND_FROM_ADDRESS` | provision-owner, activate-owner | Required for invitation emails |
| `TRACKER_BASE_URL` | provision-owner | Required for activation link |
| `ALERT_WEBHOOK_URL` | provision-owner, activate-owner, expire-tokens | Pre-production requirement — must be set before real data |

Note: `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are auto-injected by Supabase
for all deployed Edge Functions. Do not set them manually.

### Step 3 — CRM Staff Bootstrap

Confirm a test CRM staff user exists before running any P1–P20 scenario:

```sql
-- Run in Supabase SQL editor (service-role)
SELECT id, name, email, role, is_active, auth_user_id
FROM crm.crm_staff
WHERE email = 'crm-staff-test@example.test';
-- Expected: 1 row with is_active=true, role='crm_admin'

-- Confirm NO public.users row for this auth user
SELECT id FROM public.users WHERE id = '<auth_user_id_from_crm_staff>';
-- Expected: 0 rows
```

If the CRM staff row does not exist, follow `crm_auth_runbook.md` Section 2 to
bootstrap it before running scenarios.

### Step 4 — Confirm Migration Applied

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'crm' ORDER BY table_name;
-- Expected: audit_log, communications, crm_staff, facilities, follow_ups, notes, owner_contacts
```

If fewer than 7 tables appear, apply migration:
`supabase/migrations/20260101000014_crm_schema_phase0.sql`

## Operator Execution: P1–P20 Run Order

Execute scenarios in this order. All curl commands and DB assertions are in the
canonical files listed above.

```
P1–P3   Auth boundary (missing token, invalid token, inactive staff)
P4      List facilities — expect empty array
P5      Create facility — capture $CREATED_ID
P6      List facilities — expect result with ownerContact
P7      Get facility detail — expect empty notes/followUps/communications
P8      Update facility — capture audit_log with previous_values
P9      Archive facility — confirm excluded from default list
P10     Unarchive facility
P11     PATCH provisioning_status — expect HTTP 400 no_valid_fields
P12     No public.users row for CRM staff
P13     No care-data in API code (grep)
P14     Create note — capture $NOTE_ID; verify author_name = crm_staff.name
P15     Update note — verify audit_log previous_values snapshot
P16     Create communication — capture $COMM_ID; verify author_name
P17     Create follow-up — capture $FU_ID; verify assigned_to = crm_staff.name
P18     Mark follow-up done — verify audit_log previous_values = { "status": "open" }
P19     Auth rejection on all new endpoints (notes, comms, follow-ups)
P20     Detail endpoint round-trip — verify noteCount >= 1, fuCount >= 1, commCount >= 1
```

After each group, run the matching DB assertion group from `db-assertions.sql`:
- A0 before P1 (schema structure)
- A1–A2 after P5–P7
- A3 after P8, A4 after P9/P10
- A5 after P12–P13 (boundary assertions)
- A7 after P14–P15, A8 after P16, A9 after P17–P18

## Pass/Fail Criteria

**PASS if all of:**
- All P1–P20 response codes match expected values.
- DB assertions A0–A9 match EXPECT comments.
- `is_crm_staff_id = true` and `is_auth_user_id_violation = false` (A1.4).
- `author_name` and `assigned_to` = real crm_staff.name, not `'Internal Staff (Demo)'`.
- No `public.users` row for the test CRM staff user (A5.1).
- Grep confirms no care-data references (P13, P20 code check).
- `CRM_DEMO_AUTH_BYPASS` absent from Vercel environment variables.

**STOP IMMEDIATELY if any of:**
- `CRM_DEMO_AUTH_BYPASS=true` is present in Vercel — all staging results are invalid.
- Any endpoint returns tracker internal IDs, token_hash, or care data.
- Any auth scenario (P1–P3) returns HTTP 200 OK.
- `is_auth_user_id_violation = true` in A1.4.
- `author_name` = `'Internal Staff (Demo)'` — bypass is active even without the env var set.

## Cleanup After Run

```sql
DELETE FROM crm.facilities WHERE facility_name = 'Test Care Home';
SELECT id FROM crm.facilities WHERE facility_name = 'Test Care Home';
-- Expected: 0 rows
```

## CRM_DEMO_AUTH_BYPASS: Non-Negotiable Constraint

This constraint is documented here explicitly because it is the single easiest way
to accidentally invalidate an entire staging run.

`CRM_DEMO_AUTH_BYPASS=true` causes `api/lib/crmAuth.ts` to skip all JWT validation
and return a hardcoded demo actor (`crm_staff_id='demo-staff'`, `display_name='Internal
Staff (Demo)'`). Every audit_log entry will have `changed_by='demo-staff'`, which is
detectable in DB assertion A1.4 (`is_crm_staff_id = false`). The staging run is not
valid with bypass active.

The bypass was documented as Phase 0 only. It must not appear in:
- Any Vercel environment with real CRM data
- Any staging environment used to verify production readiness
- Any `.env.local` file on a machine connected to a real Supabase project

## ALERT_WEBHOOK_URL: Pre-Production Requirement

`ALERT_WEBHOOK_URL` must be set in two places before any real facility data enters
the CRM. It is not required to run P1–P20 (provisioning alert calls no-op silently
when unset), but it IS a blocker before production go-live.

- Vercel: project → Settings → Environment Variables → `ALERT_WEBHOOK_URL`
- Supabase Edge Functions: `supabase secrets set ALERT_WEBHOOK_URL=<url>` (applies to
  provision-owner, activate-owner, and expire-tokens functions)

See `provisioning_runbook.md` Sections 7.4–7.5 for webhook configuration and
`npm run test:alert` for delivery verification.

## Local Checks (2026-05-23)

| Check | Result |
|---|---|
| npx tsc --noEmit | PASS (exit 0) |
| npm run build | PASS (479.00 kB) |
| npm run verify:secrets | PASS (FAIL: 0, WARN: 0) |

## Outcome

Completed 2026-05-23. Operator handoff document written. All canonical runbook files
referenced. Vercel and Supabase env var checklists produced. P1–P20 run order and
pass/fail criteria summarized. Local checks pass. No application behavior changed.

Remaining operator action: supply staging credentials, run pre-flight checklist,
execute P1–P20, confirm all DB assertions, record results. Once staging run is PASS,
the CRM persistence work (tasks 0051–0057) is production-ready for real facility data.

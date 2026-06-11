# 0058 — CRM Persistence Staging Verification and Production-Readiness Audit

Status: done
Created: 2026-05-23
Owner role: AI agent (main)
Depends on: 0051 (schema), 0052 (crmAuth), 0053 (CRM login), 0054 (auth runbook),
            0055 (facilities API), 0056 (store/UI migration), 0057 (related records API)

## Goal

Verify that the CRM persistence work from tasks 0051–0057 is ready for real staging data.
Confirm auth boundaries, CRUD persistence, related records persistence, audit logging,
CRM_DEMO_AUTH_BYPASS controls, and data boundary (no care data, no tracker internals
exposed). Produce a precise operator runbook for manual staging verification.

## Subagent Policy

Proceeding serially. This is a read-heavy audit + documentation task. Code inspection
is complete; remaining work (run checks, assess staging, write runbook, update context)
is sequentially dependent. No independent parallel workstreams.

## Acceptance Criteria

1. [x] Verification scenarios P1–P20 confirmed to cover facility CRUD, notes, communications,
       follow-ups, auth failures, audit_log writes, and no browser direct crm.* access.
2. [x] Missing gap fixed: summary table in scenarios.md extended to include P14–P20.
3. [x] Local checks pass: npx tsc --noEmit, npm run build, npm run verify:secrets.
4. [ ] Live staging verification: BLOCKED — no .env.local, no SUPABASE_URL/SERVICE_ROLE_KEY
       available locally. Operator runbook in this document covers all scenarios.
5. [x] Operator runbook for manual staging verification produced (see below).
6. [x] CRM_DEMO_AUTH_BYPASS confirmed forbidden for real-data environments and not required
       for normal authenticated usage. Confirmed absent from current shell environment.
7. [x] Confirmed no endpoint returns tracker care data, tracker IDs, provisioning tokens,
       service-role values, or public.users details (code inspection + grep confirms).
8. [x] ai_memory.md updated.
9. [x] execution_log.md updated.
10. [x] Task moved to done (all satisfiable criteria met; staging blocked is documented).
11. [x] Changes mirrored to ai-workspace-framework.

## Code Inspection Results

All findings from inspection of api/lib/crmAuth.ts, api/crm/facilities.ts,
api/crm/facilities/[id].ts, api/crm/notes.ts, api/crm/notes/[id].ts,
api/crm/communications.ts, api/crm/follow-ups.ts, api/crm/follow-ups/[id].ts,
src/lib/crmApi.ts, src/store/useCrmStore.ts, src/pages/crm/CrmFacilityDetail.tsx,
.env.local.example.

### Auth boundary

- PASS: `requireCrmAuth(req)` is called before any business logic in all 7 endpoints.
- PASS: JWT validated server-side via `supabase.auth.getUser(token)` (not decoded client-side).
- PASS: `crm.crm_staff` lookup uses service-role key; enforces `is_active = true` and
        `role = 'crm_admin'`. Returns 401 missing_token / invalid_token, 403 not_crm_staff /
        staff_inactive / insufficient_role, or 503 auth_not_configured.
- PASS: `CRM_DEMO_AUTH_BYPASS === 'true'` check uses strict equality; not set in current env.
- PASS: `CRM_DEMO_AUTH_BYPASS` commented out in .env.local.example with explicit
        "NEVER enable in a production deployment with real CRM data" warning.

### Service-role boundary

- PASS: All DB operations use `getServiceClient()` which reads SUPABASE_URL and
        SUPABASE_SERVICE_ROLE_KEY exclusively from `process.env` (Vercel server-side).
- PASS: No service-role key reference in src/ (grep confirms). Only comment mention
        in src/lib/crmProvisioningAdapter.ts ("no provisioning API secrets, no tracker
        service-role keys") — not a usage.
- PASS: All queries target `crm.*` schema via `.schema('crm')`.

### Data boundary

- PASS: Zero references to care_log_entries, residents, wellness_observations,
        shift_close_records, or public.users in api/crm/ or api/lib/ (grep confirms).
- PASS: Response mappers expose only safe camelCase fields. Verified fields excluded:
        auth_user_id, token_hash, service_role_key, tracker_facility_id, tracker_user_id.
- PASS: `author_name` and `assigned_to` set to `actor.display_name` (crm.crm_staff.name),
        not auth.users.id or any tracker identifier.

### Audit logging

- PASS: All write operations insert an audit_log row with `changed_by = actor.crm_staff_id`
        (crm.crm_staff.id UUID — not auth.users.id, not email).
- PASS: PATCH operations capture `previous_values` snapshot before update.
- PASS: `crm.audit_log` has UPDATE/DELETE revoked for `authenticated` role (schema migration
        confirmed in db-assertions.sql A0.4).

### Demo mode separation

- PASS: `isDemo = !getSupabaseClient()` in useCrmStore (module-level detection).
- PASS: Demo mode resolves write actions immediately with local-only update; no API calls.
- PASS: Authenticated mode calls API, reconciles state with server response.
- PASS: Seed data only initialized in demo mode.

### Scenarios coverage

- PASS: P1–P13 cover facility CRUD, auth failures, provisioning_status boundary,
        public.users check, care-data code check.
- PASS: P14–P20 (added in task 0057) cover notes CRUD, communications create,
        follow-ups CRUD, auth rejection on all new endpoints, detail endpoint round-trip.
- GAP FIXED: Summary table in scenarios.md previously stopped at P13. P14–P20 rows added.

### Local check results

| Check | Result |
|---|---|
| npx tsc --noEmit | PASS (exit 0, no output) |
| npm run build | PASS (479.00 kB, built in ~2.3s) |
| npm run verify:secrets | PASS (FAIL: 0, WARN: 0) |

## Staging Environment Status

**BLOCKED — no staging credentials available locally.**

- `.env.local` does not exist in `c:\Projects\alh-tracker\`.
- `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` not set in current shell environment.
- `CRM_DEMO_AUTH_BYPASS` not set in current shell environment.

Live staging execution of P1–P20 requires a Supabase project with migration
20260101000014_crm_schema_phase0.sql applied, a Vercel deployment (or local server)
with `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` configured, and a CRM staff user
bootstrapped per crm_auth_runbook.md Section 2.

## Operator Runbook — Manual Staging Verification

Use this runbook to execute P1–P20 against a real staging environment.
Follow the prerequisite checklist before running any scenarios.

### Prerequisites Checklist

Before beginning:

- [ ] Migration `20260101000014_crm_schema_phase0.sql` applied to staging Supabase project.
- [ ] `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` set as Vercel environment variables
      (or in local `.env.local` for local dev server testing).
- [ ] `CRM_DEMO_AUTH_BYPASS` is NOT set (or is not present) in the staging Vercel environment.
      Verify: Vercel project → Settings → Environment Variables → confirm key is absent.
- [ ] CRM staff test user bootstrapped:
      - Supabase Auth user created with email `crm-staff-test@example.test`
      - `crm.crm_staff` row inserted with correct `auth_user_id`, `name`, `email`, `role='crm_admin'`
      - Confirm no `public.users` row for this auth user (see A5.1 below)
      - See crm_auth_runbook.md Section 2 for step-by-step bootstrap.
- [ ] Valid Supabase Auth access token obtained for the test staff user (sign in at `/crm/sign-in`
      or via Supabase Dashboard → Authentication → Generate link).
- [ ] `jq` installed for response parsing.
- [ ] `BASE_URL` and `AUTH_TOKEN` set in shell.

```bash
BASE_URL="https://<your-vercel-or-local-url>"   # e.g., https://alh-tracker.vercel.app or http://localhost:3000
AUTH_TOKEN="<valid-crm-staff-access-token>"
```

### Pre-Run Schema Assertions (run in Supabase SQL editor with service-role)

Run db-assertions.sql group A0 before any scenario to confirm schema is as expected.

```sql
-- A0.1: All 7 crm schema tables present
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'crm' ORDER BY table_name;
-- EXPECT: audit_log, communications, crm_staff, facilities, follow_ups, notes, owner_contacts

-- A0.2: RLS enabled on all crm.* tables
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'crm' ORDER BY tablename;
-- EXPECT: rowsecurity = true for ALL rows

-- A0.3: No client-accessible policies on any crm.* table
SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'crm';
-- EXPECT: 0 rows

-- A0.4: audit_log UPDATE/DELETE revoked from authenticated
SELECT grantee, privilege_type FROM information_schema.role_table_grants
WHERE table_schema = 'crm' AND table_name = 'audit_log'
  AND grantee = 'authenticated' AND privilege_type IN ('UPDATE', 'DELETE');
-- EXPECT: 0 rows
```

### Scenario Execution

Run `scripts/verify-crm-persistence/scenarios.md` scenarios in order: P1 through P20.

Key checkpoints after each scenario group:

**After P1–P3 (auth boundary):**
- Confirm 401 and 403 responses match expected error codes exactly.
- Confirm no partial data is returned on auth failure (response body is only `{ ok: false, error: "..." }`).

**After P4–P7 (facility CRUD happy path):**
- Save `$CREATED_ID` for use in P8–P11 and P14–P20.
- Run A1.1–A1.4 from db-assertions.sql to confirm facility row, owner_contacts row, and audit_log entry.
- Confirm `is_crm_staff_id = true` and `is_auth_user_id_violation = false` in A1.4.

**After P8–P11 (update, archive, provisioning boundary):**
- Run A3.1–A3.2 (post-update), A4.1–A4.2 (archive/unarchive) from db-assertions.sql.
- Confirm `previous_values` in audit_log for both update and archive entries.

**After P12–P13 (boundary checks):**
- A5.1: Confirm test CRM staff user has NO public.users row.
- A5.2–A5.5: Confirm no tracker IDs, no client-accessible policies, no forbidden columns,
             no care-data references.

**After P14–P15 (notes):**
- Save `$NOTE_ID` for P15.
- Run A7.1–A7.5 from db-assertions.sql.
- Confirm `author_name` in crm.notes matches `crm.crm_staff.name` (not 'Internal Staff (Demo)').
- Confirm A7.4 shows previous_values snapshot on note_updated.

**After P16 (communications):**
- Save `$COMM_ID`.
- Run A8.1–A8.3.
- Confirm `note_type` = 'call', `author_name` = crm_staff.name.
- Confirm invalid noteType (e.g., 'fax') rejected with HTTP 400.

**After P17–P18 (follow-ups):**
- Save `$FU_ID`.
- Run A9.1–A9.5.
- Confirm `status` = 'open' on create, 'done' after PATCH.
- Confirm `assigned_to` = crm_staff.name.
- Confirm A9.4 shows previous_values = `{ "status": "open" }`.
- Confirm invalid status (e.g., 'cancelled') rejected with HTTP 400 invalid_status.

**After P19–P20 (auth rejection on new endpoints, round-trip):**
- Confirm all new endpoints (notes POST, notes PATCH, communications POST,
  follow-ups POST, follow-ups PATCH) return 401 with no token.
- Run P20 detail round-trip: GET /api/crm/facilities/$CREATED_ID and confirm
  `notes.length >= 1`, `followUps.length >= 1`, `communications.length >= 1`.

**P20 code check (no care-data):**
```bash
grep -r "care_log_entries\|residents\|wellness_observations\|shift_close_records\|public\.users" \
  api/crm/notes.ts api/crm/notes/ \
  api/crm/communications.ts \
  api/crm/follow-ups.ts api/crm/follow-ups/
# EXPECT: no output (zero matches)
```

### Post-Run Cleanup

```sql
-- Remove test facility (CASCADE removes notes, follow_ups, communications, owner_contacts)
DELETE FROM crm.facilities WHERE facility_name = 'Test Care Home';
-- Verify: 0 rows
SELECT id FROM crm.facilities WHERE facility_name = 'Test Care Home';
```

### Pass/Fail Criteria

The staging run is **PASS** if:
- All P1–P20 response codes match expectations.
- DB assertions A0–A9 all match EXPECT comments.
- `is_crm_staff_id = true`, `is_auth_user_id_violation = false` (A1.4).
- `author_name` / `assigned_to` = real crm_staff.name (not 'Internal Staff (Demo)').
- No public.users row for the test CRM staff user (A5.1).
- No care-data references in grep (P13, P20 code check).
- `CRM_DEMO_AUTH_BYPASS` absent from Vercel environment variables.

The staging run is **BLOCKED/FAIL** if:
- `CRM_DEMO_AUTH_BYPASS=true` is set in the Vercel environment — STOP immediately.
- Any endpoint returns tracker internal IDs, token_hash, or care data — STOP immediately.
- Any auth failure scenario returns 200 OK — STOP immediately.
- `is_auth_user_id_violation = true` in A1.4 — STOP immediately.

## CRM_DEMO_AUTH_BYPASS Production Constraint

**CONFIRMED:** `CRM_DEMO_AUTH_BYPASS` is documented as forbidden for all environments
that handle real CRM data. Evidence:

1. `api/lib/crmAuth.ts` line 16–19: Comment states "DEMO BYPASS (Phase 0 only — remove
   before Phase 1 production)" and "Must NOT be set in production."
2. `.env.local.example` lines 64–72: Key is commented out with explicit warning:
   "REMOVE before Phase 1 CRM login is live. Never enable in a production deployment
   with real CRM data."
3. `CRM_DEMO_AUTH_BYPASS` not set in current shell environment (confirmed: exit 1).
4. When set to 'true', the bypass returns `DEMO_ACTOR` with `crm_staff_id='demo-staff'`
   and `display_name='Internal Staff (Demo)'` — audit log entries would use 'demo-staff'
   as `changed_by`, which is detectable in A1.4 (is_crm_staff_id = false).

**Production gate:** Before enabling any real facility data in CRM:
1. Confirm `CRM_DEMO_AUTH_BYPASS` is absent from Vercel environment variables.
2. Confirm `crm.crm_staff` has at least one real staff row.
3. Run A1.4 and verify `is_crm_staff_id = true` for any audit entry.

## Remaining Pre-Production Blockers

The following must be resolved before real facility/owner data is entered in the CRM:

1. **Staging live verification (this task blocker):** Run P1–P20 scenarios above against
   a real Supabase staging project. Requires: SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY
   in Vercel, CRM staff user bootstrapped, CRM_DEMO_AUTH_BYPASS absent.

2. **`CRM_DEMO_AUTH_BYPASS` absent from production Vercel:** Confirm in Vercel project
   Settings → Environment Variables that the key is not present.

3. **Alert webhook configuration:** `ALERT_WEBHOOK_URL` must be set in both Vercel
   and Supabase Edge Function secrets before production (see provisioning_runbook.md
   Section 7.4). This is a provisioning alerting blocker, not CRM persistence.

4. **Google Workspace SSO (if adopted):** ADR 0015 notes Google Workspace SSO as an
   option if the team uses Google Workspace. This requires a separate implementation
   task if selected over Supabase Auth.

5. **CRM role granularity (ADR 0015 Q4):** Only `crm_admin` is supported at MVP.
   `crm_support` access to tracker care data MUST NOT be enabled without a separate ADR.

## Outcome

Completed 2026-05-23. Code inspection across all 9 API/auth files and 3 source files
passed with zero violations. All local checks pass. One gap fixed (summary table in
scenarios.md). Operator runbook produced for manual staging verification.

Live staging execution blocked: no .env.local, SUPABASE_URL, or SUPABASE_SERVICE_ROLE_KEY
available in the local environment. Runbook is complete and sufficient for an operator
with staging access to execute P1–P20 independently.

**Local checks:** npx tsc --noEmit PASS; npm run build PASS (479.00 kB);
npm run verify:secrets FAIL: 0, WARN: 0.

**Staging status:** BLOCKED — operator must supply staging credentials and run P1–P20.

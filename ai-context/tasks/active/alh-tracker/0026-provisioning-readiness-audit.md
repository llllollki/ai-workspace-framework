# 0026 — CRM Owner Provisioning Endpoint — Implementation Readiness Audit

Status: done
Created: 2026-05-19
Owner role: AI agent (main) + Explore subagents (schema, frontend)
Reviewers: n/a (audit/planning task)

## Goal

Perform an implementation readiness audit for the CRM owner provisioning endpoint
defined by ADRs 0006–0010. Inspect the current app, Supabase migrations, schema,
repository layer, auth flow, and docs. Produce a concrete implementation plan and
task breakdown. No application code or migrations are changed in this task.

## Acceptance Criteria

- [x] Current schema/RLS/frontend/backend readiness clearly assessed.
- [x] Required workstreams identified.
- [x] Implementation order recommended.
- [x] Open blockers listed with dependencies.
- [x] Backlog task candidates created.
- [x] No application code or migrations changed.
- [x] ai_memory.md updated with newly discovered blockers.
- [x] execution_log.md updated.
- [x] Changes mirrored to ai-workspace-framework.

## Plan

- [x] Read ADRs 0006, 0007, 0008, 0009, 0010, data_model.md, features.md,
      user_flows.md, ai_memory.md, compliance_notes.md
- [x] Schema/RLS migration subagent: inspect supabase/migrations/ and db/schema.sql
- [x] Frontend/auth/repo subagent: inspect src/, CRM store, auth flow, API layer
- [x] Synthesize findings into readiness report (this document)
- [x] Create backlog task candidates (0027–0032)
- [x] Update ai_memory.md with new blockers
- [x] Update execution_log.md
- [x] Mirror to ai-workspace-framework

---

## Audit Findings

### 1. Current Supabase Schema State

**Migrations applied:** 7 (20260101000000 through 20260101000006)

**Tables that exist (14 total):**

| Table | RLS | facility_id | Notes |
|---|---|---|---|
| facilities | Yes | — (is the facility) | Missing provisioning_status, crm_facility_reference |
| users | Yes | FK | Missing account_status |
| residents | Yes | FK | |
| care_log_entries | Yes | FK | |
| wellness_observations | Yes | FK | Separate table (not part of care_log_entries) |
| follow_ups | Yes | FK | |
| shift_close_records | Yes | FK | Note: ADR 0010 references "shifts" — actual table is shift_close_records |
| appointment_transports | Yes | FK | |
| resident_contacts | Yes | FK | |
| resident_preferences | Yes | FK | |
| allergies_triggers | Yes | FK | |
| room_checklists | Yes | FK | |
| family_resident_links | Yes | FK | Note: ADR 0010 references "family_access_consent" — actual table is family_resident_links |
| audit_events | Yes | FK | Note: ADR 0010 references "audit_trail" — actual table is audit_events; append-only enforced |
| handoff_summary | Yes | FK | Not in ADR 0010 care-ops list; needs RLS gate too |

**Tables that do NOT exist yet (required by ADRs 0006–0010):**
- `provisioning_tokens` — MISSING
- `provisioning_events` — MISSING

**Tables listed in ADR 0010 care-ops gate that do NOT exist in schema:**
- `shifts` — MISSING (shift_close_records exists but is different)
- `routines` — MISSING
- `observed_care_tasks` — MISSING (care_log_entries has observed_care_task category but no separate table)
- `family_access_consent` — MISSING (family_resident_links is the current analog)

**Columns that do NOT exist yet (required by ADRs 0009–0010):**
- `facilities.provisioning_status` — MISSING
- `facilities.crm_facility_reference` — MISSING (UNIQUE constraint required)
- `users.account_status` — MISSING
- `users.created_by` — MISSING (also open ADR 0007 TODO)

**Enums that do NOT exist yet:**
- `user_account_status` — MISSING (invited, password_pending, active, disabled)
- `facility_provisioning_status` — MISSING (pending_setup, active, suspended, closed)
- `provisioning_event_type` — MISSING (provisioned, token_resent, token_revoked, token_expired_passive, activated, activation_failed)

**CRITICAL DISCREPANCY — Role naming:**
The actual `app_role` enum in the database is:
`facility_admin, caregiver, med_tech, family_member, auditor`

ADR 0007 Phase 1 Step 3b states the provisioned account receives `role = owner`.
data_model.md defines roles as: `owner, admin, caregiver, med_tech`.

There is a mismatch between the documented role model (`owner`/`admin`) and the actual
database enum (`facility_admin`). This must be resolved before any provisioning migration
touches the `users` table.

**Helper functions that exist:**
- `current_facility_id()` — EXISTS ✓ (sql, STABLE, SECURITY DEFINER)
- `current_user_role()` — EXISTS ✓ (sql, STABLE, SECURITY DEFINER)

**Helper functions that do NOT exist yet:**
- `is_active_user_on_active_facility()` — MISSING (required by ADR 0010)

### 2. RLS Readiness

**Current RLS state on care-ops tables:**
All existing tables have RLS enabled. Existing staff-scope policies check only:
`facility_id = current_facility_id()`

**Missing from all care-ops policies:** The `is_active_user_on_active_facility()`
combined gate (User.account_status = 'active' AND Facility.provisioning_status = 'active')
is not enforced anywhere. Every existing care-ops policy must be updated to add this gate.

**Additional RLS gaps:**
- `facilities` table: no policy restricting UPDATE on `provisioning_status` or
  `crm_facility_reference` to service-role only; no column-level exclusion of
  `crm_facility_reference` from client reads.
- `users` table: INSERT is not restricted; `users_read_own` policy exists (✓) but
  INSERT for provisioning must be service-role only.
- `provisioning_tokens`: table does not exist yet; must have RLS enabled with zero
  client-accessible policies (default deny).
- `provisioning_events`: table does not exist yet; same default-deny requirement.
- `handoff_summary`: exists with `facility_id = current_facility_id()` policy only;
  needs `is_active_user_on_active_facility()` gate added.

**Naming mismatches between ADR 0010 and actual schema:**
- ADR 0010 references `audit_trail` — actual table is `audit_events`. RLS migration
  must target `audit_events`.
- ADR 0010 references `family_access_consent` — actual table is `family_resident_links`.
- ADR 0010 references `shifts` — actual table is `shift_close_records` (different entity).
- Tables `routines` and `observed_care_tasks` do not yet exist; the RLS migration
  must note which tables to apply the gate to now vs. which tables will need it added
  when they are implemented.

**`crm_facility_reference` column-level security:**
Supabase Postgres does not support column-level security at the RLS policy layer. The
application layer must exclude `crm_facility_reference` from all client-facing API
responses even when the row-level SELECT policy passes (per ADR 0010 TODO).

### 3. Backend/API Hosting Readiness

**Current state:** Pure SPA with Supabase anon client. No Vercel API routes. No
Supabase Edge Functions. No `src/api/` or `supabase/functions/` directory exists.

The provisioning endpoint (`POST /api/provisioning/owner`) is a greenfield implementation.
The activation endpoint is also greenfield.

**Hosting model decision (UNRESOLVED — ADR 0008 open TODO):** The endpoint must be
hosted as either:
- A Vercel API route (if the tracker frontend app is or can be extended with server-side
  functions at `src/pages/api/` or via a Vercel Next.js/serverless pattern)
- A Supabase Edge Function (Deno-based, runs in Supabase's infrastructure)

**Implications of each:**
- Vercel API route: env vars stored in Vercel project settings; same deployment as
  frontend; Node.js runtime.
- Supabase Edge Function: env vars stored as Supabase secrets; separate deployment;
  Deno runtime; less familiar stack for this codebase (Vite/React, not Next.js).

**Note:** The current project is a Vite SPA (not Next.js), so Vercel API routes would
require either converting to Next.js/Vercel framework or using a separate API
service deployment. A Supabase Edge Function avoids this and keeps the tracker
stack self-contained.

**Recommendation (not a decision):** Supabase Edge Function avoids the Vite/Next.js
migration overhead and keeps provisioning logic collocated with the tracker Supabase
project. However, the Deno runtime requires verification of crypto and HTTP library
availability. This must be decided before implementation begins.

**Required env vars (not yet defined anywhere):**
- Tracker side: `CRM_API_KEY_V1_HASH` (SHA-256 hash of current CRM API key)
- CRM side: `CRM_TRACKER_PROVISIONING_KEY` (raw key — server-side only, never committed)
- Tracker side: `SUPABASE_SERVICE_ROLE_KEY` (for Admin API calls at activation time)

**Current `.env.local.example` only defines:** `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`

### 4. Provisioning Endpoint Design Readiness

**Required actions:** provision, resend, revoke
**Endpoint:** `POST /api/provisioning/owner`

**Request headers (ADR 0008):** All required; none yet implemented:
- `Authorization: Bearer <api_key>`
- `X-Request-Id` (UUID v4)
- `X-Idempotency-Key` (UUID v4)
- `X-CRM-Facility-Id` (opaque CRM facility identifier)
- `X-CRM-Actor-Id` (CRM staff member opaque ID)
- `X-Request-Timestamp` (ISO 8601 UTC)
- `Content-Type: application/json`

**Request body for `provision` action (ADRs 0008 + 0009):**
- `facility_name` (required)
- `facility_city` (required)
- `facility_state` (required)
- `license_number` (optional)
- `owner_email` (required)
- `owner_name` (required)
- `action: "provision"`

**Excluded body fields confirmed:** resident data, family data, payment refs,
subscription dates, allowedResidentCount, allocated resident count, tracker IDs,
raw tokens, activation URLs.

**Idempotency storage (UNRESOLVED — ADR 0008 open TODO):** The server-side store for
`X-Idempotency-Key` deduplication (24h TTL) must be one of:
- A `provisioning_idempotency_keys` Supabase table (with TTL-based cleanup job)
- An Upstash Redis instance
- In-process memory (NOT safe for distributed serverless — excluded)
Must be decided before implementation.

**Retry payload conflict behavior (UNRESOLVED — ADR 0009 open TODO):** What happens
when the same `X-CRM-Facility-Id` returns with a different `facility_name` on a
non-idempotency-key retry is undefined. Must be specified before implementation.

**Re-provision of disabled user (UNRESOLVED — ADR 0009 open TODO):** What the endpoint
returns if CRM attempts to re-provision a facility where the User is already `disabled`
(i.e., was previously revoked) is undefined. Must be specified before implementation.

**Audit writes:** ProvisioningEvent records for all lifecycle events. Table does not
yet exist in schema.

### 5. Activation Endpoint Design Readiness

**Route:** `GET /activate?t=[raw_token]` → renders activation page; activation POST
submits password + profile.

**Activation steps (ADR 0007 Phase 2):**
a. Parse `t` query param (raw token)
b. Compute SHA-256 hash
c. SELECT ... FOR UPDATE on `provisioning_tokens` WHERE `token_hash = hash AND used_at IS NULL`
d. Validate expiry
e. Update `User.account_status = password_pending`
f. Validate submitted password complexity
g. Call Supabase Admin API `auth.admin.createUser()` server-side
h. Update `User.account_status = active` + `Facility.provisioning_status = active` atomically
i. Mark `ProvisioningToken.used_at = NOW()`
j. Write `ProvisioningEvent: event_type = activated`
k. Issue Supabase session

**Frontend requirements:**
- New route `/activate` does not exist
- Create-password form with profile confirmation fields
- Routing logic: check `account_status` after activation to direct to facility setup
- Error states: expired token (show resend prompt), invalid/used token (show generic error)
- No account_status or provisioning_status routing logic currently exists anywhere in `src/`

**Partial activation recovery (ADR 0007 open TODO):**
If Supabase `createUser` succeeds but subsequent steps fail, the next activation
attempt must detect the existing auth user and skip `createUser`. Must be implemented.

### 6. Frontend and CRM Surface Readiness

**CRM store:** Session-only Zustand store (no Supabase persistence). No provisioning
fields on `CrmFacility` type. No provisioning actions in store.

**CRM UI gaps:**
- `FacilityFormModal.tsx`: no "Provision tracker account" action
- `CrmFacilityDetail.tsx`: onboarding checklist checkboxes are disabled (marked TODO
  at line 395); no provisioning status display, no resend or revoke buttons
- `CrmFacilities.tsx`: no provisioning status column
- `CrmDashboard.tsx`: no provisioning metrics

**CRM type changes needed:**
- `CrmFacility` needs `provisioning_status` and `provisioning_reference` fields
  (per data_model.md CrmFacility section)
- `CrmOnboardingStage` enum needs update: "install_instructions_sent" milestone is
  superseded by provisioning model per features.md TODO

**Tracker app auth changes needed:**
- AuthProvider does not handle `account_status` post-login routing
- No logic to show "setup pending" or redirect from `/activate`
- facility_id derivation is correct and session-safe ✓

### 7. Security/Compliance Readiness

**Confirmed secure:**
- Supabase anon key only in client code ✓
- Service-role key not referenced anywhere in src/ ✓
- facility_id derived from session, not injectable by client ✓
- `audit_events` is append-only (SELECT grant only; INSERT blocked by RLS WITH CHECK(false)) ✓
- CRM/tracker data boundary enforced (no resident care types in CRM files) ✓

**Gaps identified:**

| Concern | Status |
|---|---|
| CRM never receives tracker service-role key | Enforced by hosting architecture (tracker endpoint uses its own service-role) ✓ |
| No resident/care/family data returned to CRM | Enforced server-side in response contract (must be implemented) |
| Failed auth burst alerting | No alert delivery mechanism exists. ADR 0008 open TODO. |
| Disabled-user session revocation | No `auth.admin.signOut()` call for disabled users. ADR 0010 open TODO. |
| Transactional email provider | No email service in codebase. ADR 0007 open TODO. |
| Native deep-link model | No app delivery ADR. iOS Universal Links / Android App Links not configured. |
| `crm_facility_reference` client exposure | No column-level exclusion mechanism; must be excluded at application layer. |
| Provisioning token default-deny RLS | Table doesn't exist yet; must be enforced when created. |

---

## Required Implementation Workstreams

### Workstream A: Schema Migrations
1. Add enums: `user_account_status`, `facility_provisioning_status`, `provisioning_event_type`
2. Add columns: `facilities.provisioning_status`, `facilities.crm_facility_reference` (UNIQUE)
3. Add column: `users.account_status` (with enum)
4. Resolve `users.created_by` column for CRM-provisioned accounts (ADR 0007 open TODO)
5. Resolve role naming discrepancy: `facility_admin` vs `owner` (new blocker)
6. Create `provisioning_tokens` table (full spec from ADR 0007)
7. Create `provisioning_events` table (full spec from ADR 0007)
8. Set default `provisioning_status = active` for existing Facility rows
9. Set default `account_status = active` for existing User rows (all current users are active)
→ Task 0027

### Workstream B: RLS Helper Functions and Policy Updates
1. Create `is_active_user_on_active_facility()` helper (SECURITY DEFINER, STABLE)
2. Verify/update `current_facility_id()` (already exists — verify spec matches ADR 0010)
3. Enable RLS on `provisioning_tokens` with zero client policies (default deny)
4. Enable RLS on `provisioning_events` with zero client policies (default deny)
5. Update all existing care-ops table policies to add `is_active_user_on_active_facility()` gate
   Affected tables (existing): residents, care_log_entries, wellness_observations,
   follow_ups, shift_close_records, appointment_transports, resident_contacts,
   resident_preferences, allergies_triggers, room_checklists, family_resident_links,
   audit_events, handoff_summary
6. Update `facilities` table policies per ADR 0010 setup-safe access matrix
7. Update `users` table INSERT policy (service-role only)
8. Add note in migration: `shifts`, `routines`, `observed_care_tasks` RLS gates deferred
   until those tables are created
→ Task 0027 (depends on Workstream A schema objects existing)

### Workstream C: Provisioning API Endpoint
1. Decide hosting model: Vercel API route vs Supabase Edge Function (BLOCKER)
2. Decide idempotency storage mechanism (BLOCKER)
3. Implement API key auth middleware (constant-time hash comparison)
4. Implement request header/body validation
5. Implement timestamp window check (±5 min)
6. Implement idempotency key deduplication (24h TTL)
7. Implement `provision` action: atomic Facility + User + ProvisioningToken creation
8. Implement `resend` action: expire active token, generate new one, send email
9. Implement `revoke` action: expire token, set User.account_status = disabled
10. Implement ProvisioningEvent writes for all lifecycle events
11. Wire transactional email service (BLOCKER — select provider first)
12. Add env vars: `CRM_API_KEY_V1_HASH`, `CRM_TRACKER_PROVISIONING_KEY`
13. Implement failed-auth burst detection (rate limit + alert delivery)
→ Task 0028

### Workstream D: Activation Endpoint and Frontend Page
1. Add `/activate` route to App.tsx
2. Build ActivationPage component (create-password + profile confirmation form)
3. Implement server-side activation endpoint (token validation + Supabase Admin createUser)
4. Implement SELECT FOR UPDATE row lock + full atomic transaction
5. Handle partial activation recovery (idempotent Supabase createUser)
6. Implement ProvisioningEvent write for `activated` and `activation_failed`
7. Handle expired/used/invalid token error states in UI
8. Implement post-activation routing (facility setup flow)
→ Task 0029

### Workstream E: CRM UI Provisioning Integration
1. Add `provisioning_status` and `provisioning_reference` to `CrmFacility` type
2. Add "Provision tracker account" button to CrmFacilityDetail
3. Add "Resend invitation" button (shown when provisioning_status = invited)
4. Add "Revoke invitation" button (shown when provisioning_status = invited)
5. Wire buttons to tracker provisioning endpoint (CRM server-side call)
6. Update CrmOnboardingStage enum to replace install_instructions_sent
7. Make onboarding checklist editable in CrmFacilityDetail (currently disabled TODO)
→ Task 0030

### Workstream F: Tracker Auth/Frontend Changes
1. Update AuthProvider to handle `account_status` routing post-login
2. Add `pending_setup` facility state display (facility setup screen)
3. Ensure `account_status != active` blocks access to care-ops routes
4. Implement disabled user session revocation (call auth.admin.signOut on disable)
→ Task 0031

### Workstream G: Tests
1. Unit tests: token generation, SHA-256 hashing, constant-time comparison
2. API tests: provisioning endpoint (provision, resend, revoke — happy path + failure)
3. API tests: auth failure (wrong key, missing header, expired timestamp)
4. API tests: idempotency (same key same payload returns stored response; different payload → 409)
5. API tests: replay prevention (timestamp too old → 401)
6. RLS tests: pending_setup facility quarantine (care-ops reads/writes blocked)
7. RLS tests: active facility + active user access matrix
8. RLS tests: provisioning_tokens and provisioning_events inaccessible from client
9. Activation flow tests: happy path, expired token, used token, partial recovery
10. E2E: CRM provision → activation email → owner activates → facility goes active
11. Manual Vercel validation checklist
→ Task 0032

---

## Recommended Implementation Order

### Phase 1: Schema + RLS helpers (Task 0027)
Prerequisites: resolve role naming discrepancy (blocker #5); decide `users.created_by`
behavior. All downstream phases depend on this migration.

### Phase 2: Provisioning API skeleton (Task 0028)
Prerequisites: Phase 1 complete; endpoint hosting model decided (blocker #1);
idempotency storage decided (blocker #2); transactional email service selected (blocker #3).

### Phase 3: Activation flow (Task 0029)
Prerequisites: Phase 1 and Phase 2 complete. Depends on Phase 2 (ProvisioningToken exists).
Parallel-capable with Task 0030 (CRM UI) once provisioning API is building.

### Phase 4: CRM UI integration (Task 0030) + Tracker auth changes (Task 0031)
Prerequisites: Phase 2 API endpoint live (for CRM integration). These two workstreams
are parallel to each other.

### Phase 5: End-to-end tests and security checks (Task 0032)
Prerequisites: All implementation phases complete.

---

## Open Blockers Requiring Decisions Before Code

| # | Blocker | Where documented | Who decides |
|---|---|---|---|
| 1 | Endpoint hosting model: Vercel API route vs Supabase Edge Function | ADR 0008 open TODO | Product/tech owner |
| 2 | Idempotency storage: Supabase table vs Upstash Redis vs other | ADR 0008 open TODO | Product/tech owner |
| 3 | Transactional email service: Resend, SendGrid, Postmark, or Supabase | ADR 0007 open TODO | Product/tech owner |
| 4 | Native distribution/deep link model: PWA vs native app (iOS Universal Links / Android App Links require pending ADR) | ADR 0007 open TODO; decisions/README.md | Product/tech owner |
| 5 | Role naming discrepancy: `app_role` enum uses `facility_admin` not `owner`; ADRs say provisioned accounts get `role = owner` | NEW blocker — not in any ADR | Product/tech owner |
| 6 | `users.created_by` behavior for CRM-provisioned accounts: sentinel, nullable, or structural column | ADR 0007 open TODO | Product/tech owner |
| 7 | Retry payload conflict: same `X-CRM-Facility-Id`, different `facility_name` on retry → ignore, log, or 409? | ADR 0009 open TODO | Product/tech owner |
| 8 | Re-provision disabled user: can a revoked facility be re-provisioned via the same `X-CRM-Facility-Id`? | ADR 0009 open TODO | Product/tech owner |
| 9 | Alert delivery: failed auth burst alerting mechanism (email, Slack, monitoring service) | ADR 0008 open TODO | Product/tech owner |
| 10 | `token_expired_passive` event type: include in enum (requires background job) or exclude before migration? | ADR 0007 open TODO | Product/tech owner |

**Blockers #1, #2, #3 block Phase 2 (provisioning API).**
**Blocker #4 blocks Phase 3 (activation/deep link routing on mobile) but not server-side activation.**
**Blocker #5 blocks Phase 1 (schema migration — role naming must be resolved).**
**Blockers #6, #7, #8, #10 block Phase 1/2 finalization.**
**Blocker #9 can be deferred to Phase 5 but should be wired in Phase 2.**

---

## Risk Register

### Tenant Isolation Risks
- **Current RLS gap (HIGH):** All existing care-ops policies check only `facility_id =
  current_facility_id()`. If a `pending_setup` facility somehow obtained a session (edge
  case), care-ops data could be written to a quarantined facility. Mitigated by ADR 0010
  quarantine model — but the migration must actually be applied before provisioning goes live.
- **`crm_facility_reference` exposure:** If not excluded at application layer, it leaks
  an opaque CRM identifier to facility clients. Low risk (opaque), but violates ADR 0009.

### Token/Account Takeover Risks
- **Partial activation recovery gap:** If Supabase `createUser` succeeds but the
  transaction fails before `used_at = NOW()`, a second activation attempt would find an
  existing auth user and must handle it idempotently. Not yet implemented.
- **Token timing attack:** Only mitigated if constant-time comparison is used. Must be
  enforced in implementation (Node.js `crypto.timingSafeEqual` or equivalent).
- **SELECT FOR UPDATE atomicity:** If the activation transaction does not hold the row
  lock through both status updates, two concurrent requests for the same token could
  both pass validation. Must be enforced at the database transaction layer.

### CRM Boundary Risks
- **CRM must never receive raw token, token_hash, tracker User.id, tracker Facility.id.**
  Enforced by response contract. Must be verified by tests.
- **Provisioning endpoint response must not contain any care-ops data.** Must be tested.
- **CRM API key compromise:** Scoped only to provisioning actions (ADR 0008 least-privilege).
  A compromised key cannot access care data. Rotation cadence (90 days) must be documented
  as an operational procedure.

### Activation Idempotency Risks
- **Supabase `createUser` followed by DB failure:** Leaves a dangling auth.users entry.
  Partial recovery check (does auth user already exist for this email?) must be
  implemented before first activation attempt.
- **Race condition on activation:** Two concurrent clicks of the same activation link.
  SELECT FOR UPDATE prevents double-activation but must be verified in load tests.

### Email/Deep-Link Delivery Risks
- **No email service selected:** Activation emails cannot be sent until a transactional
  email service is configured and SPF/DKIM/DMARC are set for the sender domain.
- **Deep link routing on mobile:** iOS Universal Links require AASA file; Android App
  Links require assetlinks.json. Both require the native distribution ADR to be resolved
  first. PWA fallback may be viable for MVP.
- **Email deliverability:** If the sender domain lacks SPF/DKIM/DMARC, activation emails
  may land in spam. Must be tested before any real facility owners receive emails.

---

## Verification Plan

### Unit Tests
- Token generation: output is 64-char lowercase hex, cryptographically random
- SHA-256 hashing: consistent output for same input
- Constant-time comparison: does not leak timing information
- Timestamp window validation: requests older than 5 min rejected; future requests (>60s) rejected
- Password complexity: min 12 chars, uppercase, lowercase, digit

### RLS / SQL Policy Tests
- `pending_setup` facility: care-ops SELECT returns empty; INSERT returns error
- `active` user + `active` facility: SELECT returns rows
- `invited`/`password_pending` user (no session): no access possible (structural)
- `provisioning_tokens`: anon/authenticated role returns permission denied for all operations
- `provisioning_events`: anon/authenticated role returns permission denied for all operations
- `crm_facility_reference`: must not appear in any client SELECT response
- Tenant isolation: user from Facility A cannot read Facility B rows (existing test)

### API Tests
- `POST /api/provisioning/owner` provision action: 201 with opaque reference
- `POST /api/provisioning/owner` resend action: 200; new token created, old expired
- `POST /api/provisioning/owner` revoke action: 200; User.account_status = disabled
- Auth failure (wrong key): 401 with generic error body
- Missing required headers: 400
- Expired timestamp: 401
- Replay (same idempotency key, same payload): returns stored 200 without re-processing
- Replay (same idempotency key, different payload): 409
- Duplicate provision same `X-CRM-Facility-Id`: returns existing provisioning_reference
- Response body contains no tracker IDs, no tokens, no care data

### E2E Tests
- Happy path: CRM provision → email received → owner clicks link → create-password → facility active → care-ops accessible
- Expired token: owner clicks link after 72h → expired message → resend prompt
- Used token: second click on same link → generic invalid error
- Revoked account: owner clicks link after CRM revoke → invalid error
- Partial activation recovery: Supabase createUser success + DB failure → idempotent retry succeeds

### Manual Vercel Validation Checklist
- [ ] Provisioning endpoint returns 401 for missing Authorization header
- [ ] Provisioning endpoint returns 400 for missing `X-Request-Id` header
- [ ] Provisioning endpoint returns 401 for expired X-Request-Timestamp
- [ ] Provision action creates Facility in pending_setup state (verify in Supabase Studio)
- [ ] Provision action creates User in invited state (verify in Supabase Studio)
- [ ] Activation email received with opaque token URL
- [ ] Activation URL opens /activate page on web (or app store redirect on mobile)
- [ ] Create-password flow completes and issues a session
- [ ] After activation, Facility.provisioning_status = active in Supabase Studio
- [ ] After activation, User.account_status = active in Supabase Studio
- [ ] ProvisioningToken.used_at is set after activation
- [ ] ProvisioningEvent records exist for provisioned and activated events
- [ ] Resend creates new token and expires old one
- [ ] Revoke sets User.account_status = disabled; old token expires
- [ ] Active facility owner can access care-ops routes
- [ ] Response to CRM contains no tracker IDs

---

## Outcome

Audit complete. No application code changed. No migrations applied. All findings
documented above. Seven implementation task candidates created in tasks/backlog/alh-tracker/
(0027–0032). ai_memory.md updated with newly discovered blockers. execution_log.md updated.
All changes mirrored to ai-workspace-framework.

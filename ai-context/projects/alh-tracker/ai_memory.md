# alh-tracker — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

### Business model and ALH relationship (Task 0001)

**Decided and captured in ADRs:**
- Pricing model type: flat monthly per-facility, no per-resident component (ADR 0002)
- ALH partner founding partner commercial rate: $49/month, communicated before pilot conversation concludes (ADR 0003)
- Design partner and Phase 1 ALH pilot: free (ADR 0003)
- No shared onboarding/billing system at MVP; internal CRM manages onboarding (ADR 0003 superseded by ADR 0005)
- Data boundary: resident care data siloed; only alh_partner boolean crosses (ADR 0001)
- BD timing: design partner framing only in ALH conversations; not a product pitch (task 0001 Section 2)

**Still open (blocks task closure — requires design partner execution):**
- Non-ALH standalone price point ($149/month recommended, $99–$199/month working range) is NOT validated. Requires 2–3 design partner pricing sensitivity probes (task 0001 Section 6b, aligned with task 0002 Section 6).
- Support and onboarding workload model undefined — owner must answer 5 operational questions (task 0001 Section 6d) before Phase 3 commercial launch.

**Owner validation packet (task 0001 Section 6, added 2026-05-24):** 5-question pricing sensitivity probe script, decision thresholds for $149/month (5 scenarios), ALH partner talking points with approved/prohibited language, and support/onboarding workload questions for owner.

### Design partner (Task 0002)

- Who is the first design partner? Target profile defined. Committed partner not yet identified — outreach not yet executed.
- Outreach channel priority: (1) ALH Phase 1 market contacts — warm, highest priority; (2) CDSS/CCLD Riverside County RCFE registry cold list; (3) CALCASA/local associations; (4) personal referrals.
- **Outreach packet status (2026-05-23):** Task 0002 Sections 1–7 complete (profile, scripts, site visit plan, LOI outline, validation checklist, risks). `design_partner_tracker.md` has Quick Start, candidate tracker (36+ pre-seeded rows for Temecula/Murrieta/Menifee/Wildomar), scoring guide, CCLD verification steps, and status key. Section A (ALH warm contacts) is empty — owner must fill from ALH CRM. Section B/C require CCLD verification before outreach. On-site observation checklist added (task 0002 Section 4b, 2026-05-23). Offline/WiFi validation questions added to Section 6 (task 0008 offline spec validation requirement).
- **Next owner actions (in order):** (1) Fill Section A from ALH CRM; (2) Verify top-priority Section B rows in CCLD portal; (3) Score and rank candidates; (4) Send first warm message (one at a time); (5) Schedule site visit and run using task 0002 Sections 4 and 4b.
- Task 0002 remains active until: committed partner identified, LOI signed, at least one shift observed and documented, 5–10 candidate list built and initial outreach sent.

### Shift model (Task 0003)

- Are shift periods fixed time windows (e.g., 7am–3pm / 3pm–11pm / 11pm–7am) or owner-configured?
- What happens if a caregiver never closes their shift? Do log entries become orphaned from the handoff?
- What triggers handoff generation — an explicit caregiver action, a scheduled time, or both?
- How are orphaned or overlapping shifts handled?

### Caregiver authentication (Task 0003)

- Individual accounts per caregiver (better audit trail, more setup friction) or shared device PIN (lower friction, weaker individual accountability)?
- Can both models coexist per facility — e.g., individual accounts for primary caregivers, shared PIN for agency or backup staff?
- How does shared tablet behavior work: persistent session, auto-lock, or per-event re-authentication?
- How are new or agency caregivers added without blocking a shift?

### Observed care task deliberateness

- Should observed care task logging require a note when status is anything other than "Done"?
- What is the right friction level to prevent accidental one-tap medication observations without making the flow feel like a form?

### Internal CRM and three-surface model (ADR 0005 — open questions)

ADR 0005 (2026-05-16) accepted the three-surface product model and CRM architecture. The following questions remain open and must be resolved before CRM design begins:

- **Allowable resident count distinction (partially resolved — task 0011):** The current CRM implementation uses a single `allowedResidentCount` integer as a placeholder. It may represent (a) licensed facility capacity (CDSS), (b) subscription-tier resident limit (commercial), or (c) active resident count (operational). The UI labels it clearly as "CRM config · not a live care-ops count." Whether to split this into three separate fields remains an open question for a future CRM design task. No Supabase schema has been created — splitting can happen when persistence is implemented.
- **App delivery model:** Is the facility tracker app and/or family member app delivered as a native iOS/Android app store app, a PWA with install prompt, or a web app with a mobile redirect message? This affects onboarding instructions and the feasibility of the mobile-first distribution policy.
- **Onboarding ownership split:** Who owns each onboarding step — internal ALH Tracker staff, the facility owner self-serving through the app, or a hybrid? What steps are tracked in the CRM vs. the tracker app?
- **Payment provider:** Which payment provider will be used? What payment metadata is stored in the CRM vs. held by the provider? (Hard constraint: raw card/bank details must not be stored in the CRM regardless of provider.)
- **CRM roles (partially resolved — ADR 0015, proposed 2026-05-22):** MVP decision: single `crm_admin` role for all CRM staff. Phase 2 roles (crm_sales, crm_support, crm_billing) deferred until team grows. HARD CONSTRAINT: `crm_support` access to tracker care data requires a separate ADR before any implementation — must NOT be enabled by default. See ADR 0015 Q4.
- **CRM user authentication model (RESOLVED — ADR 0015, proposed 2026-05-22):** Same Supabase Auth project + service-role API pattern (Option D). CRM staff have Supabase Auth accounts but NO row in `public.users`. All `crm.*` DB access routes through CRM Vercel API functions using the service-role key (extending the `api/crm/provision.ts` pattern). `crm.*` tables use service-role-only RLS — this unblocks schema implementation in Phase 0 without waiting for per-user auth. **Phase 1 prerequisites implemented (2026-05-22):** `crm.crm_staff` table CREATED (task 0051, migration 20260101000014); CRM JWT validation middleware IMPLEMENTED (task 0052, `api/lib/crmAuth.ts`); CRM login page IMPLEMENTED (task 0053, `src/pages/crm/CrmSignIn.tsx` + `RequireCrmAuth`). Google Workspace SSO if team adopts Workspace. **CRM persistence Phase 0+1 complete (tasks 0051–0057):** crm schema, auth, CRUD APIs (facilities/notes/communications/follow-ups), store/UI migration from Zustand-only to server-fetched. Staging verification runbook ready (tasks 0058–0059) — **BLOCKED on operator staging credentials** (P1–P20 scenarios, A0–A9 DB assertions). See ADR 0015.
- **CRM-to-tracker provisioning mechanism (resolved in ADR 0007 — accepted):** ADR 0007 (2026-05-18) selects the custom `provisioning_tokens` table approach (Option B). The Supabase Auth invite API was rejected because it requires the CRM to hold the tracker's Supabase service-role key, violating the CRM/tracker boundary. Key decisions: (a) custom `ProvisioningToken` table with SHA-256 hashed token, 72h expiry, one-time use; (b) Supabase Auth user created at activation time via Admin API — not at provisioning time; (c) `ProvisioningEvent` append-only audit table for the full lifecycle; (d) CRM stores only `provisioning_reference` (opaque) and `provisioning_status` — no tracker credentials. Remaining implementation TODOs: transactional email service selection (Resend API — not yet configured for production); resend rate limit. `User.created_by` RESOLVED: ADR 0012 Decision 4 — nullable, provenance tracked in ProvisioningEvent table. See ADR 0007 and ADR 0008.
- **Facility record creation timing (resolved in ADR 0009 — accepted, 2026-05-19):** The tracker `Facility` record is created by the CRM provisioning API call — not pre-existing. The provisioning endpoint atomically creates `Facility` (in `pending_setup` state) + `User` (invited state) + `ProvisioningToken` in one transaction. Facility is keyed by `crm_facility_reference` (= `X-CRM-Facility-Id` header) with a UNIQUE constraint for idempotency. Allowed CRM-to-tracker facility fields: `facility_name`, `facility_city`, `facility_state`, `license_number` (optional). `Facility.capacity` (licensed capacity), subscription resident limit, and allocated resident count are not set at provisioning time. `Facility.provisioning_status` transitions `pending_setup → active` on owner activation (same transaction as `User.account_status → active`). CRM never receives tracker `Facility.id`. Remaining TODOs: orphaned Facility cleanup, multi-facility owner eligibility, subscription resident limit enforcement. **RLS policy for pending_setup state (addressed in ADR 0010, 2026-05-19 — accepted):** quarantine model — all care-ops tables require `User.account_status = 'active'` AND `Facility.provisioning_status = 'active'`; `ProvisioningToken`/`ProvisioningEvent` have zero client-accessible policies. **Retry payload conflict and re-provision behavior (RESOLVED — ADR 0012, accepted 2026-05-20):** retry with conflicting fields ignores new values, logs in metadata, returns existing reference; re-provision of a revoked facility resets User to `invited`, issues new token, returns new reference. See ADR 0009, ADR 0010, ADR 0012.
- **iOS Universal Links vs. Android App Links:** The owner activation deep link behaves differently on iOS (Universal Links — requires Apple App Site Association file on the server) and Android (App Links — requires Digital Asset Links file). These mechanisms have different trust models and different server-side configuration requirements. This must be resolved before the app is submitted to the stores. Blocked on native distribution ADR.
- **CRM-to-tracker API authentication (resolved — ADR 0008, 2026-05-19 accepted):** ADR 0008 selects a rotating static API key for MVP, stored exclusively server-side (CRM: Vercel env var `CRM_TRACKER_PROVISIONING_KEY`; tracker: SHA-256 hash in Edge Function secret). Zero-downtime rotation via versioned key slots. Phase 2 hardening: HMAC-signed short-lived JWT. Request contract requires `X-Request-Id`, `X-Idempotency-Key`, `X-CRM-Facility-Id`, `X-CRM-Actor-Id`, `X-Request-Timestamp`. Response returns only `provisioning_reference` (opaque UUID) and `status`. No care data crosses the boundary. Remaining TODOs: idempotency store mechanism (RESOLVED ADR 0012), endpoint hosting model (RESOLVED ADR 0012), alert delivery (deferred ADR 0012 — must be wired before production). See ADR 0008, ADR 0012.
- **CRM communications log definition:** What constitutes a "communication" in the CRM — email thread, call log, in-app message, or other channels?
- **Desktop access policy for facility owners:** Is desktop access to the facility tracker app a hard block (HTTP 403/redirect) or a soft redirect (page nudging users to mobile)? Does any facility owner/admin workflow require desktop access (e.g., facility setup, user management, reporting)?
- **Internal support staff access to resident care data:** Can ALH Tracker business/admin staff ever access resident-level care data through the CRM for support purposes? If yes, what audited policy governs it? This access must not be enabled by default.

### Provisioning implementation blockers — new, discovered in audit 0026 (2026-05-19)

These blockers were found during the implementation readiness audit (task 0026) by inspecting
the actual Supabase migrations and source code. None were previously documented.

**Role naming discrepancy (IMPLEMENTED — migration applied 2026-05-19, task 0030):**
The actual `app_role` enum in the database is `facility_admin, caregiver, med_tech, family_member, auditor`.
ADR 0007 and data_model.md say provisioned accounts receive `role = owner`. **Decision made in ADR 0011
(accepted):** rename `facility_admin` → `owner` in the DB enum; add `admin` as a new enum value.
Migration `20260101000007` applies `ALTER TYPE app_role RENAME VALUE 'facility_admin' TO 'owner'` and
`ADD VALUE 'admin'`. AuthProvider.tsx renamed to `DbRole`, `mapToStoreRole()` updated and fallback
hardened. `src/types/index.ts` dead `AnyRole` export removed. `db/schema.sql` updated.
No remaining blocker. See ADR 0011 and task 0030.

**`users.created_by` behavior (RESOLVED — ADR 0012, accepted 2026-05-20):**
Nullable UUID FK (NULL = CRM-provisioned). CRM staff are not tracker users (ADR 0005/0006); no
sentinel or fake tracker User created. Provenance for CRM-provisioned accounts is authoritative
in `ProvisioningEvent` (event_type = 'provisioned', actor_id = CRM staff ID). No schema migration
needed — column already supports NULL. See ADR 0012 Decision 4.

**Schema naming discrepancies between ADRs and actual migrations:**
- ADR 0010 "audit_trail" → actual table: `audit_events`
- ADR 0010 "family_access_consent" → actual table: `family_resident_links`
- ADR 0010 "shifts" → actual table: `shift_close_records`
All RLS migration work (task 0027) must target the actual table names.

**Tables in ADR 0010 care-ops gate list that do not yet exist in schema:**
- `shifts` (different from `shift_close_records`), `routines`, `observed_care_tasks`
The RLS migration must note these as deferred — apply the quarantine gate when those tables
are eventually created.

**CRM login and authenticated provisioning calls (DONE — task 0053, 2026-05-22):**
`src/pages/crm/CrmSignIn.tsx` created: CRM-branded email+password login page; uses
`useAuth().signIn()` (AuthProvider); maps Supabase errors to safe copy; demo mode redirects
immediately to /crm. `src/components/RequireCrmAuth.tsx` created: route guard for /crm/*;
checks `session` (not `user`) — CRM staff have valid sessions but no `public.users` rows;
redirects to /crm/sign-in when no session; passes through in demo mode. 
`src/lib/crmProvisioningAdapter.ts` updated: `callBridge()` calls
`getSupabaseClient().auth.getSession()` → adds `Authorization: Bearer <token>` header when
present; 401 → "session expired" copy; 403 → "access denied" copy; `crmActorId: 'crm-staff'`
removed from all bridge calls. `src/components/CrmLayout.tsx` updated: sign-out button
showing truncated email (Supabase mode); demo badge updated. `src/App.tsx` updated: public
`/crm/sign-in` route added; `/crm/*` wrapped in `RequireCrmAuth`. `.env.local.example`
updated: CRM login setup section (no new env vars — reuses VITE_SUPABASE_*);
`CRM_DEMO_AUTH_BYPASS` now documented as "no longer required for normal authenticated usage."
TypeScript clean, build clean (466.60 kB), verify:secrets FAIL: 0 WARN: 0.
Remaining Phase 1 requirements: (1) populate `crm.crm_staff` (create Supabase Auth accounts
for CRM staff — bootstrap steps in `crm_auth_runbook.md` Section 2); (2) remove
`CRM_DEMO_AUTH_BYPASS` env var from any environment with real data; (3) replace
`author_name`/`changed_by` denormalization with `crm_staff.id`.
**Production bug fix (2026-05-24):** `CrmSignIn.tsx`, `RequireCrmAuth.tsx`, `ActivationPage.tsx`, and the corresponding `App.tsx` route changes were implemented in task 0053 but never committed. /crm/sign-in was blank in production because React Router had no matching route. All four files committed (425f60f) and pushed to origin/main — Vercel redeploy triggered.

**Provisioning schema and RLS migrations audit (DONE — task 0027, 2026-05-23):**
Task 0027 (backlog since 2026-05-19) verified as fully superseded. All schema and RLS work was
implemented in migrations 0007 and 0008 (task 0030, 2026-05-19) and subsequent migrations
0009–0013. All 12 acceptance criteria confirmed against actual migration files: three
provisioning enums (user_account_status, facility_provisioning_status, provisioning_event_type
+ token_expired_passive); facilities.provisioning_status NOT NULL DEFAULT 'active';
facilities.crm_facility_reference UNIQUE; users.account_status NOT NULL DEFAULT 'active';
provisioning_tokens (RLS enabled, zero client policies); provisioning_events (RLS enabled,
UPDATE/DELETE revoked from authenticated); is_active_user_on_active_facility() STABLE SECURITY
DEFINER; all 13 care-ops tables (residents, care_log_entries, wellness_observations, follow_ups,
shift_close_records, appointment_transports, resident_contacts, resident_preferences,
allergies_triggers, room_checklists, family_resident_links, audit_events, handoff_summary)
updated with quarantine gate in migration 0008; deferred tables (shifts, routines,
observed_care_tasks) noted in migration comments. All three original blockers resolved: #5
(role naming — ADR 0011 + migration 0007), #6 (users.created_by — ADR 0012 Decision 4,
nullable, no migration), #10 (token_expired_passive — migration 0010). Safe defaults for
existing rows handled by NOT NULL DEFAULT 'active' column definitions. SQL assertion scripts
in scripts/verify-provisioning/db-assertions.sql (task 0040). Credential-dependent RLS checks
remain blocked on local Supabase — same as tasks 0032 and 0060. Local checks: npm run
test:provisioning PASS (43/43); tsc PASS; build PASS (479.00 kB); verify:secrets FAIL: 0
WARN: 0. Task moved to done.

**Provisioning test hardening and operator handoff (DONE — task 0060, 2026-05-23):**
Two gaps fixed in `scripts/verify-provisioning/scenarios.md`: (1) CRM auth header requirement missing from Prerequisites — scenarios.md was written in task 0040 before task 0052 added `requireCrmAuth()` to the bridge; added CRM bridge auth row and `Authorization: Bearer $AUTH_TOKEN` to all curl examples; (2) Scenario 9 (Status Query) missing from Environment Limitations list. Created `scripts/verify-provisioning/operator-handoff.md`: entry point covering local Vitest scope (43 tests, no credentials), local Supabase prerequisites (Scenarios 1–7, 9), staging prerequisites (activation/race/E2E), RLS/SQL policy check list, explicit STOP conditions (CRM_DEMO_AUTH_BYPASS present in staging, forbidden fields in bridge response, auth failure returns 200), canonical file index. Local checks: npm run test:provisioning PASS (43/43); tsc PASS; build PASS (479.00 kB); verify:secrets FAIL: 0 WARN: 0. Remaining credential-dependent scope unchanged from task 0032: RLS/SQL, activation, E2E all require external environments.

**Provisioning bridge and crypto unit tests (DONE — task 0032 local scope, 2026-05-23):**
Vitest added as project test framework (`^4.1.7`); `@types/node` (`^25.9.1`) added to devDependencies. `vitest.config.ts` created (Node.js environment). `npm run test:provisioning` script added. `tests/provisioning/bridge.test.ts` (23 tests): covers `api/crm/provision.ts` with all externals mocked — method validation (GET/DELETE → 405), CRM auth failures (401/403 forwarded), bridge configuration (503 when env vars absent), body validation (malformed JSON, invalid action, missing fields, provision-required fields), response sanitization (10 forbidden fields verified absent from bridge response when present in upstream: facility_id, user_id, token_hash, token, crm_facility_reference, service_role_key, tracker_user_id, auth_user_id, care_data, tracker_facility_id; email_delivered/token_expired only forwarded when upstream sends boolean), upstream error handling (502 network/non-JSON, 404/409/500 proxied as provisioning_failed). `tests/provisioning/crypto.test.ts` (20 tests): Node.js equivalents of Deno Edge Function utilities — sha256Hex (64-char hex, deterministic, input-sensitive), generateRawToken (64-char hex, 32-byte entropy, 100-call uniqueness), timingSafeEqualHex (equal → true, unequal → false, length mismatch → false), validatePassword (min_length/uppercase_required/lowercase_required/digit_required rules). 43/43 tests pass. tsc PASS; build PASS (479.00 kB); verify:secrets FAIL: 0 WARN: 0. BLOCKED (credential-dependent): RLS/SQL policy tests require local Supabase instance; E2E/integration/activation tests require staging environment; manual checklist requires production. Operator verification resources: `scripts/verify-provisioning/scenarios.md`.

**CRM staging operator handoff (DONE — task 0059, 2026-05-23):**
Operator handoff document created. Local CRM persistence verification complete (code inspection + local checks all PASS across tasks 0051–0058). Staging execution remains BLOCKED pending operator credentials. Task 0059 document is the single operator entry point: Vercel and Supabase env var pre-flight checklists, P1–P20 run order with DB assertion group mapping, pass/fail criteria, stop conditions, cleanup SQL. All local checks: tsc PASS, build PASS (479.00 kB), verify:secrets FAIL: 0 WARN: 0.

**Pre-production gate for CRM real data (OPEN — operator action required):**
1. Vercel: confirm SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY present; confirm CRM_DEMO_AUTH_BYPASS absent.
2. Supabase Edge Function secrets: confirm ALERT_WEBHOOK_URL set for provision-owner, activate-owner, expire-tokens. Run `npm run test:alert` to verify delivery.
3. CRM staff bootstrap: confirm crm.crm_staff row exists; confirm NO public.users row (see crm_auth_runbook.md Section 2).
4. Run P1–P20 scenarios from scripts/verify-crm-persistence/scenarios.md against staging.
5. Run DB assertions A0–A9 from scripts/verify-crm-persistence/db-assertions.sql.
6. Verify A1.4: is_crm_staff_id = true, is_auth_user_id_violation = false.
7. Confirm author_name / assigned_to = real crm_staff.name (not 'Internal Staff (Demo)').
Canonical runbook: tasks/done/alh-tracker/0059-crm-staging-operator-handoff.md

**CRM persistence staging verification (DONE — task 0058, 2026-05-23):**
Full code inspection across all 9 CRM API/auth files and 3 frontend source files. All auth boundary, service-role boundary, data boundary, and audit logging checks passed. Zero care-data/public.* references in api/crm/ or api/lib/. CRM_DEMO_AUTH_BYPASS confirmed absent from shell env, commented out in .env.local.example with "NEVER enable in production" warning. One gap fixed: scenarios.md summary table extended to include P14–P20 (was missing since task 0057). Full operator runbook written in task 0058 document. Local checks: tsc PASS, build PASS (479.00 kB), verify:secrets FAIL: 0 WARN: 0. **Live staging execution BLOCKED** — no .env.local or staging credentials available locally; operator must supply SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY and run P1–P20 per runbook before real facility data is entered.

**CRM frontend store/UI persistence migration (DONE — task 0056, 2026-05-22):**
`src/lib/crmApi.ts` created: authenticated API client for CRM persistence endpoints. `getAuthHeaders()` reads Supabase session token via `supabase.auth.getSession()` — no manual token storage. Exports `listFacilities(showArchived?)`, `getFacilityDetail(id)`, `createFacility(input)`, `patchFacility(id, patch)`. `normalizeFacility()` guards against null ownerContact from DB. `createFacility` input type defined inline (prevents circular import with useCrmStore). `useCrmStore.ts` heavily updated: demo mode detected at module level (`const isDemo = !getSupabaseClient()`); seed data populates initial state in demo mode; authenticated mode starts empty. New state: `facilitiesLoading`, `facilitiesError`, `detailLoading[id]`, `detailError[id]`, `facilityUpdateError[id]`. `loadFacilities(showArchived?)` no-ops in demo mode; loads from API in authenticated mode. `loadFacilityDetail(id)` replaces notes/comms/followUps for that facilityId. `addFacility` now async (returns server-assigned UUID in authenticated mode). `updateFacility` uses optimistic local update + background API call; error stored without revert. `archiveFacility` is API-first (no optimistic update); caller checks `facilityUpdateError` before navigating. PATCH_EXCLUDED set prevents patching `id`, `createdAt`, `updatedAt`, `provisioning_status`, `provisioning_reference`, `archived`, `archivedAt`. `CrmFacilities.tsx`, `CrmFacilityDetail.tsx`, `CrmDashboard.tsx` updated: call `loadFacilities`/`loadFacilityDetail` on mount; show loading spinners and error banners; detail page shows loader (not "not found") while `detailLoading[id]` is true. TypeScript clean, build clean (474.15 kB), verify:secrets FAIL: 0 WARN: 0. Browser never queries crm.* tables directly.
Remaining Phase 1 work: (1) notes/follow_ups/communications CRUD write endpoints — DONE (task 0057); (2) remove CRM_DEMO_AUTH_BYPASS before production data.

**CRM persistence API Phase 1 (DONE — task 0055, 2026-05-22):**
`api/crm/facilities.ts` created: GET /api/crm/facilities (list active/archived, includes ownerContact via PostgREST join, limit 100); POST /api/crm/facilities (create facility + owner_contacts + audit_log entry, validates required fields). `api/crm/facilities/[id].ts` created: GET /api/crm/facilities/:id (facility detail with notes/follow_ups/communications); PATCH /api/crm/facilities/:id (update allowed fields via ALLOWED_UPDATE_FIELDS map + onboardingChecklist nested; archive via archived:true/false; ownerContact update; writes facility_updated/facility_archived/facility_unarchived to audit_log with previous_values snapshot; provisioning_status and provisioning_reference explicitly excluded from PATCH — bridge-managed only). All endpoints use requireCrmAuth(); changed_by = actor.crm_staff_id (crm.crm_staff.id UUID, not auth.users.id). Response shapes map DB snake_case → camelCase per CrmFacility type; no auth_user_id/tracker IDs/tokens in responses. `scripts/verify-crm-persistence/scenarios.md` (13 scenarios) and `db-assertions.sql` (groups A0–A6) created. TypeScript clean, build clean (466.60 kB), verify:secrets FAIL: 0 WARN: 0.
Remaining Phase 1 work: (1) frontend store/UI migration — DONE (task 0056); (2) notes/follow_ups/communications CRUD write endpoints — DONE (task 0057); (3) remove CRM_DEMO_AUTH_BYPASS before production data.

**CRM staff bootstrap and auth verification (DONE — task 0054, 2026-05-22):**
`crm_auth_runbook.md` created: step-by-step bootstrap flow (create auth user → insert
crm.crm_staff → confirm no public.users row → sign in → provision call → confirm
X-CRM-Actor-Id = crm_staff.id → sign out), positive verification checklist, 5 negative
boundary checks (no crm_staff row → 403, inactive → 403, wrong role → 403, missing/expired
token → 401, care-data boundary — 3 layers), demo bypass guidance (detection + disable), and
cleanup steps. `scripts/verify-crm-auth/scenarios.md` and `db-assertions.sql` (S0–S13) created
for repeatable staging verification. Section 11 added to `provisioning_runbook.md` with
cross-references. No TypeScript changes. verify:secrets FAIL: 0 WARN: 0.

**CRM API auth middleware and staff identity (DONE — task 0052, 2026-05-22):**
`api/lib/crmAuth.ts` created: reusable `requireCrmAuth(req)` helper for Vercel API functions.
Validates Supabase Auth JWT via `supabase.auth.getUser(token)` server-side; queries
`crm.crm_staff` by `auth_user_id` using service-role key + `supabase.schema('crm')`;
enforces `is_active = true` and `role = 'crm_admin'`. Returns typed `CrmActor
{ crm_staff_id, display_name, email, role }` on success; 401/403/503 on failure.
`CRM_DEMO_AUTH_BYPASS=true` server-side env var bypasses JWT validation (Phase 0 only;
must be removed before Phase 1 production). `api/crm/provision.ts` updated: auth runs before
body parse; `X-CRM-Actor-Id` set to `crmActor.crm_staff_id` (real UUID in Phase 1;
'demo-staff' in bypass mode). `.env.local.example` updated with `SUPABASE_URL` (Vercel),
`SUPABASE_SERVICE_ROLE_KEY` (Vercel), and `CRM_DEMO_AUTH_BYPASS` docs.
TypeScript clean, build clean (462.17 kB), verify:secrets FAIL: 0 WARN: 0.

**CRM persistence schema Phase 0 (DONE — task 0051, 2026-05-22):**
Migration `20260101000014_crm_schema_phase0.sql` applied: creates `crm` schema, 7 CRM-scoped
enums, and 7 tables (crm_staff, facilities, owner_contacts, notes, follow_ups, communications,
audit_log). RLS enabled on all tables; no client-accessible policies (service-role-only per
ADR 0015). `crm.audit_log` append-only enforced via REVOKE. Forbidden provisioning fields
absent. `db/schema.sql` updated. TypeScript clean, build clean (462.17 kB), verify:secrets
FAIL: 0 WARN: 0. Phase 0 pre-production blocker is RESOLVED. Remaining for CRM persistence:
Phase 1 (CRM login page, crm_staff population, JWT validation middleware, author_name
denormalization removal) is still required before any real CRM data enters production.

**Provisioning pre-production cutover dry run (DONE — task 0044, 2026-05-21):**
Readiness audit confirmed: 14 migrations (0000–0013) present and ordered; all 3 Edge Functions
exist; all 3 npm scripts exist (`verify:secrets`, `test:alert`, `check:sweep-cadence`); all
operator tooling needs labeled. Three docs-drift fixes applied: (1) runbook section 2.2
migration count corrected to 14 (0000–0013); (2) critical migrations table updated with
migration 0013 row; (3) `.env.local.example` updated with note that `SUPABASE_SERVICE_ROLE_KEY`
may be set locally for operator scripts (no `VITE_` prefix). New runbook Section 10
(Pre-Production Cutover Dry Run): 10-step ordered checklist with pass/fail signals, completion
criteria, and remaining pre-production blockers labeled as operator action required.
No code changes. Secret scan: FAIL: 0, WARN: 1 at time of task 0044 — resolved to WARN: 0 by task 0045
(removed `CRM_TRACKER_PROVISIONING_KEY` from browser-visible 503 error string). Remaining pre-production
blockers (updated by task 0051): (1) set `ALERT_WEBHOOK_URL` in Vercel + Supabase; (2) Resend domain verification;
(3) auth burst detection (deferred); (4) CRM persistence schema Phase 0 DONE (migration 0014 applied); Phase 1 (per-user CRM auth) required before production data; (5) HIPAA BAA; (6) retention policy.

**Provisioning alert verification and sweep cadence monitoring (DONE — task 0043, 2026-05-21):**
`npm run test:alert` (`scripts/verify-provisioning/test-alert.mjs`): synthetic alert delivery
test; reads `ALERT_WEBHOOK_URL` from env or `.env.local`; sends safe test payload; verifies
delivery to the same URL used by both Vercel and Supabase environments. `sweep_heartbeat` table
(migration 0013): single-row, service-role-only, RLS enabled, no client policies; updated by
`expire-tokens` via UPSERT after each successful sweep (best-effort, non-fatal). `npm run
check:sweep-cadence` (`scripts/verify-provisioning/check-sweep-cadence.mjs`): reads
`sweep_heartbeat.last_sweep_at` via Supabase REST API; checks age vs `SWEEP_MAX_AGE_HOURS` (default
26); reports PASS/FAIL with troubleshooting steps. Runbook Sections 7.5 (alert delivery
verification) and 7.6 (sweep cadence verification) added. TypeScript clean, build clean (458.66 kB),
secret scan FAIL: 0 WARN: 1. Remaining pre-production blockers: (1) set `ALERT_WEBHOOK_URL` in
Vercel + Supabase; (2) apply migration 0013; (3) auth burst detection (counter store, deferred).

**Provisioning monitoring/alerting (DONE — task 0042, 2026-05-21):**
`sendAlert()` webhook helper added to all four provisioning surfaces: `api/crm/provision.ts`
(Node.js, reads `process.env.ALERT_WEBHOOK_URL`), `provision-owner/index.ts`,
`activate-owner/index.ts`, `expire-tokens/index.ts` (all Deno, read `Deno.env.get('ALERT_WEBHOOK_URL')`).
No-op when `ALERT_WEBHOOK_URL` is unset. 19 alert call sites across 4 surfaces covering: auth
failures, email delivery failures, DB/rollback failures, idempotency conflicts, token validation
failures, activation RPC failures, sweep RPC failures, unexpected response shapes, and unhandled
exceptions. Alert payloads contain only safe operational context (source, event, action, request_id,
crm_facility_id, status_code, error_category, timestamp) — no tokens, keys, UUIDs, or PHI.
`ALERT_WEBHOOK_URL` does not appear in src/ or dist/. TypeScript clean, build clean (458.66 kB,
unchanged), secret scan FAIL: 0 WARN: 1 (expected). Runbook Section 7.2 updated to wired-vs-TODO
table; Section 7.4 added for ALERT_WEBHOOK_URL configuration. `.env.local.example` updated.
Remaining pre-production blockers (updated by task 0043): (1) set ALERT_WEBHOOK_URL in Vercel +
Supabase secrets (verify with `npm run test:alert`); (2) auth burst rate detection (counter store,
deferred); sweep invocation failure detection now WIRED via sweep_heartbeat + check:sweep-cadence.

**Provisioning production runbook (DONE — task 0041, 2026-05-21):**
`ai-context/projects/alh-tracker/provisioning_runbook.md` created. Covers: env var placement
(Vercel vs. Supabase secrets vs. public), deployment order (migrations → secrets → Edge Functions
→ Resend domain → Vercel → smoke tests), Resend SPF/DKIM/DMARC setup, token expiry scheduling,
zero-downtime key rotation + emergency revocation, smoke-test checklist referencing
`scripts/verify-provisioning/scenarios.md`, monitoring/alerting status (all pre-production
blockers: no alert delivery wired — Section 7.2), rollback/recovery for 7 failure scenarios,
data boundary and compliance guardrails. Documentation-only — no application source changed.
Pre-production blockers documented in runbook: monitoring not wired, Resend domain unverified,
CRM persistence not implemented, HIPAA BAA unresolved, retention policy unresolved.

**Provisioning verification harness (DONE — task 0040, 2026-05-21):**
`scripts/verify-provisioning/` created with three artifacts: `check-secrets.mjs` (automated
Node.js secret scan, zero deps, CI-safe, `npm run verify:secrets`), `db-assertions.sql`
(SQL query blocks for all 8 scenarios with EXPECT comments), `scenarios.md` (full walkthrough
including curl commands, environment prerequisites, cleanup SQL, and manual review checklists).
Scenarios 1-7 require live Supabase + Vercel; Scenario 8 (secret exposure) is fully automated.
No test framework added — harness stays lightweight per repo style.

**Greenfield backend (RESOLVED — tasks 0028 + 0029 + 0036 + 0039, 2026-05-21):**
`supabase/functions/provision-owner/index.ts` (task 0028), `supabase/functions/activate-owner/index.ts`
(task 0029), and `supabase/functions/expire-tokens/index.ts` (task 0039) now exist. Migrations 0009
(provisioning_idempotency_keys), 0010 (token_expired_passive enum value), 0011 (activate_owner_rpc),
and 0012 (expire_tokens_rpc) applied. Activation RPCs `check_activation_token` and
`complete_owner_activation`, plus sweep RPC `sweep_expired_provisioning_tokens`, added to `db/schema.sql`.
Token sweep is complete: passive expiry events are idempotent via NOT EXISTS keyed on
`(user_id, event_type, metadata->>'token_id')`. Scheduling: Supabase Dashboard cron (preferred) or pg_cron.
Provisioning backend greenfield gap is closed. Remaining: task 0032 (E2E tests).

**CRM provisioning status sync (DONE — task 0047, 2026-05-22):**
Read-only `status` action added to `provision-owner` Edge Function, CRM bridge, adapter, store,
and UI. `handleStatus()` queries `facilities.provisioning_status` + `users.account_status` +
`provisioning_tokens.expires_at` and maps to CRM status. Status mapping: `pending_setup+invited`
→ `pending_setup`; `pending_setup+disabled` → `not_provisioned`; `active` → `active`; `suspended`/`closed`
passthrough. `token_expired: true` returned when the invitation token has expired (passively or otherwise)
— status still shows `pending_setup` (LIMITATION: `token_expired_passive` events do not change
`facility.provisioning_status`; staff must resend). Bridge filters response to CRM-safe fields only.
"Check status" button in CrmFacilityDetail; dismissable token-expired warning banner. Dashboard/list
metrics auto-refresh via shared Zustand store. Idempotency skipped for status (read-only). TypeScript
clean, build clean (462.17 kB), secrets FAIL: 0, WARN: 0.

**CRM UI provisioning integration (DONE — task 0036, 2026-05-20):**
CRM Zustand store has `provisionFacility`, `resendProvisioningInvite`, `revokeProvisioningInvite` actions.
Adapter stub `src/lib/crmProvisioningAdapter.ts` isolates the server-side CRM call requirement with clear
TODO comments. `CRM_TRACKER_PROVISIONING_KEY` must never appear in browser code — the adapter stub
documents this constraint. CRM UI shows provisioning status badges, Provision/Resend/Revoke buttons with
confirm modals, and provisioning metrics on the dashboard. Checklist is now editable (click-to-toggle).
Seed data updated: `installInstructionsSent` → `trackerProvisioned`, `provisioning_status` added to all facilities.

**CRM server-side provisioning bridge (DONE — task 0037, 2026-05-21):**
`api/crm/provision.ts` (Vercel serverless function) is the CRM-to-tracker bridge. Reads
`CRM_TRACKER_PROVISIONING_KEY` and `TRACKER_PROVISION_URL` exclusively from `process.env` — never
exposed to browser. Validates request, generates ADR 0008 headers, forwards to tracker Edge Function,
filters response to CRM-safe fields only (provisioning_reference, provisioning_status, email_delivered).
`src/lib/crmProvisioningAdapter.ts` updated: all three functions now call `/api/crm/provision` via
`callBridge()` — demo simulation is no longer the main path. `useCrmStore.ts` updated: passes
`facility.city`, `facility.state`, `facility.rcfeLicensePlaceholder` to the adapter (required by
tracker provision action). `.env.local.example` updated with bridge env var docs. TypeScript clean,
production build clean, forbidden-string check passed. In local development without `vercel dev`,
provisioning returns a network error — this is correct (requires Vercel deployment).

**Tracker provisioning lifecycle verification (DONE — task 0038, 2026-05-21):**
Full inspection of provision-owner/index.ts, activate-owner/index.ts, ActivationPage.tsx, db/schema.sql,
and migrations 0009–0011. All three provisioning actions (provision/resend/revoke) plus re-provision are
implemented correctly per ADRs 0007/0008/0009/0010/0012/0013. Token invalidation is atomic via
`expireActiveTokens()` (sets used_at=now() on all active tokens before creating new one). ProvisioningEvents
written for all action types: provisioned, token_resent, token_revoked, activated, activation_failed.
Revoke bans auth user (876000h) and sets account_status='disabled'. activate-owner uses SECURITY DEFINER
RPC `complete_owner_activation` with SELECT FOR UPDATE SKIP LOCKED for concurrent-activation safety.
Activation page (/activate) correctly wired in App.tsx. No missing implementation — task 0032
(provisioning E2E tests) is the remaining gap. Noted: resend doesn't guard against revoked-user state
at the tracker layer — CRM UI correctly prevents this via local state machine. TypeScript clean,
build clean, forbidden-string check PASS.

**Auth-user timing deviation (RESOLVED — ADR 0013, accepted 2026-05-20):**
`public.users.id FK → auth.users(id)` requires auth user creation at provisioning time,
not activation time (contradicting ADR 0007 original intent). Auth user is created unusable
(no password, email_confirm: false). Activation calls `auth.admin.updateUserById()` to set
password and confirm email — NOT `createUser`. Revoke bans auth user; re-provision unbans.
Partial activation recovery simplified: `updateUserById` is idempotent, no pre-existence
check needed. See ADR 0013. Task 0029 backlog updated to reflect `updateUserById` behavior.

**Endpoint hosting model (RESOLVED — ADR 0012, accepted 2026-05-20):**
Supabase Edge Function selected. Vite SPA has no existing Vercel API layer; Edge Function is
the natural tracker-side backend extension point. Deno Web Crypto API covers SHA-256 + timing-safe
comparison. Service-role key stays within Supabase environment. Entry point:
`supabase/functions/provision-owner/index.ts`. See ADR 0012 Decision 1.

**Idempotency storage mechanism (RESOLVED — ADR 0012, accepted 2026-05-20):**
Supabase `provisioning_idempotency_keys` table selected. Co-located with provisioning data,
no external service, adequate performance at MVP volume. TTL: 24h, lazy cleanup on read + pg_cron
sweep. Schema migration included in task 0028 scope. See ADR 0012 Decision 2.

**Transactional email service (RESOLVED — ADR 0012, accepted 2026-05-20):**
Resend selected for MVP (free tier, Deno-compatible REST API, SPF/DKIM/DMARC supported). Postmark
documented as preferred fallback if deliverability is insufficient. Domain setup (SPF/DKIM/DMARC)
required before production launch. API key stored as Supabase Edge Function secret. See ADR 0012
Decision 3.

---

### Resident profile open questions

The following open questions were identified during documentation of resident profile management. These are not yet tracked under existing task numbers. Family access questions are in the section below.

**Resident profile field groups:**
- **Multi-contact model:** `ResidentContact` is currently one-record-per-resident. Changing to one-to-many is a structural data model change pending design review.
- **Identity field expansion:** `legal_name`, `preferred_name`, `resident_phone`, `move_in_date`, and `approximate_age` are documented as profile fields but not yet modeled on the `Resident` entity. Requires data model update.
- **Mobility/assistance entity:** No entity exists for mobility fields (wheelchair, walker/cane, transfer assistance, two-person assist, lift note). A new entity (e.g., `ResidentMobility`) is needed pending design review.
- **Daily care/routine context entity:** Structured daily care fields (bathing, dressing, toileting, continence, diet, hydration, sleep) are partially covered by `ResidentPreferences` in free text. Whether to extend `ResidentPreferences` or create a separate entity is an open design question. Counsel input on ADL data sensitivity needed.
- **Safety alerts expansion:** Fall precaution, wandering precaution, eating/swallowing assistance context, and critical safety notes are not yet modeled in `AllergiesTriggers` or elsewhere. Data model update needed.
- **Medication-adjacent operational notes field:** Whether this is a standalone named field on `Resident` or a section within `ResidentPreferences.general_notes` is pending design and counsel review.
- **DOB:** Deferred pending data minimization review and counsel sign-off. PHI-adjacent regardless of covered-entity status.

**Resident archive/reactivate flows:**
- **Archive behavior for active family access grants:** If a resident is archived, should active `FamilyAccessConsent` records be auto-revoked or auto-suspended? Behavior is undefined — needs a product decision.
- **Archive/reactivate field additions:** `deactivated_at`, `deactivated_by`, `deactivation_reason`, `reactivated_at`, `reactivated_by` are needed on the `Resident` entity but not yet modeled.
- **Caregiver safety/mobility empty state:** If no mobility or safety data has been entered for a resident, the caregiver read view must show a graceful empty state (not a blank that reads as "no concerns noted").

---

### Family access architecture (Task 0006 — Phase 2, counsel-blocked)

Architecture decided in ADR 0004 (accepted 2026-05-09). Stubs (ResidentContact, FamilyAccessConsent) present but empty at MVP. Family portal is a separate Phase 2 mobile/tablet surface (ADR 0005). **Do not build any family-facing feature before counsel review.**

**Decided (ADR 0004):** always read-only; dual acknowledgment (operator authorization + resident autonomy noted); summary default; category-scoped; same database, row-level authorization; family contacts are not User records; AuditTrail required.

**Blocks Phase 2 (all open):**
- Counsel review: consent model and resident autonomy posture (task 0006 §2 and §5), CPPA/CCPA obligations for family contacts, notice and disclosure language
- Family app authentication mechanism (magic link / OTP / password — pending ADR)
- Family-to-facility messaging scope, content, and audit requirements
- Access request/rejection behavior and notification scope
- Design partner validation: how do operators currently share care info with families?

See task 0006 for full spec; ADR 0004 for accepted decisions.

### HIPAA BAA posture

- Do RCFE operators using alh-tracker require a Business Associate Agreement?
- What is the vendor's HIPAA posture before commercial launch?
- This must be resolved before any real resident data is stored under a commercial relationship.

### Title 22 documentation scope (Task 0004)

Desk research complete (2026-05-05). Pending counsel review and sign-off. Key findings:
- § 87506 (resident records): 3-year post-service retention; includes medication records and condition documentation. Whether alh-tracker CareLogEntry records constitute § 87506 "resident records" is an open counsel question.
- § 87211 (incident reporting): Reporting obligation rests with the licensee per regulation text. Whether the vendor has independent obligations is an open counsel question. In-product incident notices required before commercial launch.
- § 87465 (medication management): Medication assistance records must document date, time, dosage, and response. 1-year retention for medication records. alh-tracker ObservedCareTask intentionally omits dosage/name — counsel must confirm whether these records constitute § 87465 medication records.
- § 87411 (personnel): Confirmed compatible with alh-tracker User entity and AuditTrail.
- Full research and counsel brief in task 0004 Outcome, Section 6.

### Retention and deletion policy

> **HIGH RISK — pre-commercial-launch blocker (identified 2026-05-16):** No retention policy exists at the Supabase (production database) level. This must be resolved before any real resident data enters production. See task 0009.

**2026-05-23 update:** A preliminary policy draft was produced under task 0009 Notes. It covers: schema audit of existing soft-delete fields, data category retention recommendations, account closure behavior, archive/delete/anonymize framework, implementation implications, and 8 additional counsel questions (Q-R1 through Q-R8). That draft is PRELIMINARY — NOT LEGAL ADVICE — and requires counsel approval before any retention period, purge job, or account closure workflow is implemented or committed in ToS.

**Schema audit confirmed (2026-05-23):** Existing `deleted_at` fields on `care_log_entries`, `wellness_observations`, `follow_ups`, `appointment_transports`, `residents`. `is_active` flags on `users`, `facilities`, `residents`, `family_resident_links`. `audit_events` is append-only (correct). Key gap: `resident_contacts`, `resident_preferences`, `allergies_triggers`, `room_checklists`, `shift_close_records`, `handoff_summary` have no soft-delete fields. Auth user cascade risk documented — deactivation must use `is_active = false` only; never delete `auth.users` entries for users with care records.

**Remaining open blockers (all require counsel resolution before closing task 0009):**
- Q1: Do CareLogEntry records constitute § 87506 "resident records"? Does the 3-year vendor retention obligation apply?
- Q2: Do ObservedCareTask records constitute § 87465 "medication records"? Does the 1-year retention apply to the vendor?
- Q4: Account closure vendor obligations — retention, destruction, export, notice.
- Q6: Caregiver identity preservation in AuditTrail after deactivation; when (if ever) may anonymization occur?
- Q-R1–Q-R8: CPPA/CCPA vs. retention, audit immutability, PITR as retention mechanism, per-resident retention clock, vendor obligation post-closure, export requirements, cold storage queryability. See task 0009 Notes for full question text.
- PITR backup retention (Supabase Pro: 7-day PITR) is NOT sufficient if 3-year retention applies to the vendor. Application-level archiving or cold storage is required — DO NOT BUILD until counsel confirms retention periods.
- Task 0009 remains active. None of task 0009's acceptance criteria can be satisfied without counsel answers to Q1, Q2, Q4, Q6, and Q-R1–Q-R8.

**Counsel handoff packet consolidated (2026-05-23):** `0038-counsel-handoff-packet.md` updated to include Q-R1–Q-R8 from task 0009. Questions now organized into 5 priority groups: (1) pre-commercial launch blockers Q1–Q4, (2) retention/account closure Q-R3/Q-R5–Q-R8, (3) medication-adjacent/Title 22 Q-R4, (4) privacy/data subject rights Q-R1–Q-R2, (5) future family access Q5–Q9. Decisions-blocked table expanded; email cover note updated to reference full Q1–Q9 plus Q-R1–Q-R8 set. Packet ready to route to counsel in one engagement.

---

## Current Working Context

**Assumption (2026-05-05):** MVP targets California RCFEs with 6–20 residents currently using paper binders, whiteboards, or verbal handoffs. This profile was chosen as the sharpest initial wedge and closest first-fit.

**Assumption (2026-05-05):** Observed care tasks are caregiver observations only — no MAR/eMAR structure — until compliance and legal review confirms a safe, appropriate path forward.

**Commercial model (decided — see ADR 0002, ADR 0003, superseded by ADR 0005):** Flat monthly per-facility. ALH partners free during design partner + Phase 1 pilot; $49/month at commercial transition. Non-ALH price $99–$199/month working range ($149/month recommended) — NOT yet validated; pending design partner probe.

**Family access architecture (ADR 0004, 2026-05-09 — decided):** ResidentContact / FamilyAccessConsent stubs finalized in data_model.md. Architecture is conservative, consent-first, and read-only by default. Stubs present in schema but unpopulated at MVP. Phase 2 implementation is blocked on counsel review of the consent model — not on architecture decisions.

**Design partner strategy (2026-05-05 — task 0002 planning complete):**

- **Profile (must-have):** California RCFE, active license, 6–20 resident capacity, currently using paper/whiteboard/text/verbal handoff process, no digital shift log software, owner accessible for site visit, at least one caregiver willing to test during a real shift. Located in Temecula, Murrieta, or Menifee (SW Riverside County) — aligns with ALH Phase 1 markets.
- **Profile (disqualifiers):** Already using PointClickCare, MatrixCare, or similar; under active CDSS license action; fewer than 4 active residents; outside California; owner unwilling to allow caregiver participation.
- **Outreach channel priority:** (1) ALH Phase 1 facility contacts — warmest path; (2) CDSS/CCLD Riverside County RCFE registry filtered to capacity 6–20 — cold list; (3) CALCASA/local RCFE networks — lower-certainty; (4) personal referrals if Channels 1–2 stall after 4–6 weeks.
- **Candidate list:** Not yet built. Owner must pull ALH contact list and ca_ccld_registry Riverside County RCFE data, apply filters, and build 5–10 candidate list. Target 30–50 cold contacts to yield 1 committed partner. See `design_partner_tracker.md` — 36+ candidate rows pre-seeded from public data; all rows require CCLD verification before outreach; warm contact section (Section A) is unpopulated — owner must supply from ALH CRM.
- **LOI terms:** Free access during design partner phase; no pricing commitment in the LOI; founding partner rate to be communicated before design partner relationship concludes. No compliance claims. No production dependency. 30-day exit by either party.
- **Outreach script and site visit plan:** Documented in task 0002 Sections 3 and 4. Do not deviate from the language guardrails — no launch date, no pricing, no compliance language.
- **Validation gate for Task 0003:** Shift model and auth questions from the task 0002 validation checklist must have answers from a real facility before task 0003 is activated.

**Caregiver auth starting instinct (2026-05-05):** Named individual accounts for regular caregivers (audit-sensitive actions require traceable identity). Shared tablet mode with quick per-session PIN switch for shared-device facilities. Not finalized — design partner site visit (task 0002) must validate before task 0003 locks the model.

**Title 22 language hard-stops (active constraint):** No compliance claims, no MAR/eMAR claims, no clinical monitoring claims, no medication safety claims, no legal sufficiency claims. Desk research is labeled preliminary research only — not legal advice.

**Task 0008 — offline behavior spec and TA review (2026-05-09/05-10; spec refined 2026-05-24):**

- Offline behavior spec complete. Conservative PWA model: IndexedDB event queue, visible offline banner, automatic sync on reconnect, flag-for-review conflict resolution (no auto-merge or auto-discard). No Background Sync API dependency. Device tier matrix defined (phone priority 1, tablet priority 2, desktop priority 3). Minimum: Android 9+/Chrome 80+, iOS 14+/Safari. Confirmed: package.json has no service worker library, no IndexedDB wrapper, no `vite-plugin-pwa` — offline support is not yet implemented.
- **Spec refined 2026-05-24:** Queue structure now uses "idempotency key" (UUID v4, client-generated) terminology. Queue item validation rules documented (8 fields; clock-skew guard ±24h; note max 2000 chars; server idempotency contract defined). Design partner WiFi/site validation checklist added (Section 6; aligns with task 0002 Section 4b). Implementation test plan added (Section 7: 18 unit tests, 10 integration tests, 12 browser/manual tests, 8 failure/retry scenarios, 7 privacy/security checks — all prospective).
- AI-assisted TA review completed (2026-05-10): spec confirmed technically coherent. **Human TA must still confirm before Phase 1 implementation begins — AI review does not satisfy acceptance criterion 6.**
- Task remains active pending: (1) human TA confirmation (AC #6); (2) design partner site visit validates WiFi assumptions (Section 6 checklist).

**ToS draft (2026-05-10):** `projects/alh-tracker/tos_draft_for_counsel.md` created as preliminary draft. Must not be used in any commercial context until counsel has reviewed and approved it.

**Prototype is demo-only (2026-05-11):** Current live app at https://alh-tracker.vercel.app has no authentication, no authorization, all data in browser localStorage (plaintext), no backend. Seed data for 8 named residents persists in every browser. Demo-only banner is live. Must not receive real resident data. Production controls (15 items) documented in `compliance_notes.md` — Security and Privacy Implementation Posture section.

# alh-tracker — Execution Log

This file records project-specific documentation maintenance activity in mechanical summary form.

Each entry should be one or two lines: what was done, when, and what files were affected.

For retrospective notes and patterns discovered during a task, use `reflection.md`.
For durable decisions, use `decisions\`.

---

## 2026-05-26 (repair — missing provisioning schema, migrations 0007–0011)

- Ops fix task. Root cause: migrations 0007–0011 were marked applied via `supabase migration repair --status applied` but their SQL was never executed. `sweep_expired_provisioning_tokens()` failed at runtime with `ERROR: 42P01: relation "provisioning_events" does not exist`. Fix: created `supabase/migrations/20260101000017_repair_provisioning_schema.sql` — comprehensive idempotent repair covering all missing objects from 0007–0011: `user_account_status`, `facility_provisioning_status`, `provisioning_event_type` enums; `app_role` rename (`facility_admin` → `owner`) and `admin` value; `provisioning_status` column on `facilities`, `account_status` on `users`; `provisioning_tokens` table; `provisioning_events` table; `is_active_user_on_active_facility()` RLS helper; all staff-facing table policies updated with quarantine gate; `provisioning_idempotency_keys` table; `check_activation_token()` and `complete_owner_activation()` RPCs. Created `supabase/migrations/20260101000018_admin_role_policies.sql` — deferred the two policies referencing `'admin'` enum value (`admin_manage_family_links`, `audit_read_staff`) into a separate migration to satisfy PostgreSQL 55P04 constraint (cannot use newly-added enum value in same transaction it was added). Also fixed partial index predicate (`WHERE expires_at < NOW()` → removed; `NOW()` is STABLE not IMMUTABLE). Pushed via `supabase db push --linked` — both migrations applied successfully. All 19 migrations now in sync. Verified 2026-05-26: `SELECT public.sweep_expired_provisioning_tokens();` → `{"swept": 0, ...}` ✓; `cron.job` row exists with `schedule = '0 * * * *'`, `active = true` ✓. Provisioning schema fully operational.

---

## 2026-05-26 (repair — missing sweep RPC and sweep_heartbeat table)

- Ops fix task. Root cause: `supabase migration repair --status applied` (from pg_cron task) recorded migrations 0012 and 0013 as applied in the tracking table but never executed their SQL against the remote DB. `sweep_expired_provisioning_tokens()` function and `sweep_heartbeat` table were absent despite the tracker showing them applied. Fix: created `supabase/migrations/20260101000016_repair_sweep_rpc_and_heartbeat.sql` — fully idempotent re-application of 0012 (`CREATE OR REPLACE FUNCTION`) and 0013 (`CREATE TABLE IF NOT EXISTS`) content. Pushed via `supabase db push --linked`. All 17 migrations now in sync. Operator must confirm in Supabase Dashboard SQL Editor: (1) `SELECT public.sweep_expired_provisioning_tokens();` → `{"swept": 0, ...}`; (2) `SELECT jobid, jobname, schedule, active FROM cron.job WHERE jobname = 'expire-provisioning-tokens';` → one row, active = true. No source code changed.

---

## 2026-05-26 (pg_cron schedule — passive provisioning-token expiry sweep)

- Ops task. No application source changed. Created `supabase/migrations/20260101000015_pg_cron_schedule.sql`: enables `pg_cron` (IF NOT EXISTS), grants `cron` schema usage to `postgres`, schedules `sweep_expired_provisioning_tokens()` hourly at `0 * * * *` UTC via idempotent DO block. Remote DB had pre-existing schema but no migration tracking history — marked migrations 0000–0014 as applied via `supabase migration repair --status applied`, then pushed 0015 via `supabase db push --linked`. All 16 migrations now in sync (local = remote per `supabase migration list`). CLI cannot run SELECT queries without Docker/DB URL in this environment; cron job verification and manual sweep test must be confirmed in Supabase Dashboard SQL Editor. `sweep_heartbeat` is NOT updated by this SQL-cron path — only the `expire-tokens` Edge Function updates it. `supabase functions invoke` not available in CLI 2.101.0.

---

## 2026-05-26 (Edge Function deployment — provision-owner, activate-owner, expire-tokens)

- Ops task. No application source changed. Supabase CLI (2.101.0 via npx) used to deploy three Edge Functions to project `ocofrmysgwvlfkltubzw`. Functions were pre-implemented in `supabase/functions/`; no code changes required. Secrets set: `CRM_API_KEY_V1_HASH`, `RESEND_API_KEY`, `RESEND_FROM_ADDRESS`, `ALERT_WEBHOOK_URL`, `TRACKER_BASE_URL=https://alh-tracker.vercel.app`. `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are auto-injected by Supabase. Functions deployed: `provision-owner` (POST — provision/resend/revoke/status actions, CRM Bearer auth), `activate-owner` (GET preflight + POST activation, anon key), `expire-tokens` (sweep scheduled function). Verification: GET `https://ocofrmysgwvlfkltubzw.supabase.co/functions/v1/provision-owner` → 401 (expected — auth required, not 404). Vercel env vars needed: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `CRM_TRACKER_PROVISIONING_KEY`, `TRACKER_PROVISION_URL`, `ALERT_WEBHOOK_URL`. Note: `ALERT_WEBHOOK_URL` set as placeholder in Supabase secrets — update when a real webhook is available. `expire-tokens` requires a cron schedule in Supabase Dashboard (e.g., `0 * * * *`) to run automatically.

---

## 2026-05-25 (Phase 2 readiness — date-range CSV export, blocked/safe assessment)

- Phase 2 assessment and implementation task. Blocked items identified: family access portal (hard block — counsel + FamilyUser design + app delivery ADR), family messaging, family push/SMS notifications (unresolved model), app delivery ADR. Safe items identified: follow-up resolution tracking (already fully implemented in FollowUps.tsx), owner/admin data export (production prerequisite #10), richer analytics (deferred). Implemented Phase 2 slice: added date-range care log CSV export card to `src/pages/DataManagement.tsx` — date pickers (default last 7 days), fetches via `repository.getFacilityCareLogEntries` + `repository.getResidents`, generates CSV (Date/Time/Resident/Room/Category/Status/Note), in-UI regulatory disclaimer (not RCFE documentation). Build: `tsc && vite build`, 490.12 kB, FAIL: 0 WARN: 0. Updated `features.md` (Phase 2 blocked/implemented/pending breakdown). No family access, CRM, or compliance-sensitive files touched. Commit 4a78d91.

---

## 2026-05-25 (mobile/tablet UI refresh — Layout, Dashboard, ActivityLog, Residents)

- UI implementation. Changed 4 source files. `Layout.tsx`: mobile bottom tab bar (Home/Residents/Log CTA/Alerts/More); demo banner stacked above tab row on mobile; desktop sidebar and banner unchanged. `Dashboard.tsx`: Log New Event CTA button at top; 4-stat row replaced with category mini-cards (Meals/Fluids/Activity/Care counts); recent entries list (last 5 today). `ActivityLog.tsx`: icon+label category grid buttons (CATEGORY_ICONS map; tap target increased to py-3). `Residents.tsx`: per-card quick Log button (navigates to /activity?resident=id); list changed to 2-col grid on sm breakpoint. Incident/observed_care_task guardrails preserved; family sharing hidden for those categories; demo banner visible on all screens. Build passed clean (`tsc && vite build`, 486 kB). Committed `406eaf6`. Deployed: https://alh-tracker.vercel.app.

---

## 2026-05-24 (E2E QA cycle — CRM → owner provisioning → tracker → family)

- QA-only task. No application source changed. Coordinator ran all local automated checks: `npx tsc --noEmit` PASS, `npm run build` PASS (479.00 kB), `npm run verify:secrets` FAIL: 0 WARN: 0, `npm run test:provisioning` PASS (43/43). QA subagent inspected all four E2E flow segments (CRM staff, owner activation, tracker app, family access) via code review and Vercel live URL checks. No bugs found in runnable implemented functionality. All credential-dependent scenarios (CRM CRUD P1–P20, provisioning Scenarios 1–9, activation, RLS checks) confirmed blocked on operator staging credentials as previously documented. Family Phase 2 and offline/PWA confirmed not implemented per current scope — not bugs. All security boundary checks (CRM auth guard, service-role key server-only, response sanitization, no accidental family data exposure) PASS. No ai_memory.md updates required — no durable status changed.

## 2026-05-24 (production bug fix — /crm/sign-in blank screen)

- Code fix task. Root cause: `CrmSignIn.tsx`, `RequireCrmAuth.tsx`, `ActivationPage.tsx`, and the App.tsx route changes from task 0053 were implemented but never committed — React Router had no route for /crm/sign-in, producing a blank screen via the SPA catch-all rewrite. Fix: staged exactly those 4 files (no other working-tree changes staged), confirmed `npx tsc --noEmit` PASS, `npm run build` PASS (479.00 kB), `npm run verify:secrets` FAIL:0 WARN:0, committed as 425f60f, pushed to origin/main (Vercel redeploy triggered). ai_memory.md updated (CRM login section — added deployment note). Mirrored to ai-workspace-framework.

## 2026-05-24 (housekeeping — active task status index and blocker dashboard)

- Documentation-only task. No application source changed. No ai_memory.md changes needed — all blocker language was current. Created `tasks/active/alh-tracker/README.md` as a quick-scan dashboard: 6-row status table (task, blocker category, next required action, AI-now flag), supporting artifact row for `0004-counsel-handoff-packet.md`, explicit "No AI/dev-ready tasks" finding, and a blocker routing map showing that all counsel tasks (0004, 0006, 0009) route through one engagement and that all future-phase items (0006, 0008) unlock when task 0002 yields a committed design partner. File mirrored to ai-workspace-framework.

## 2026-05-24 (task 0006 — family access Phase 2 cleanup: ai_memory.md canonical family access entry, Phase 2 gate note)

- Documentation-only task. No application source changed. ai_memory.md was the primary deliverable. Work: (1) Renamed "Resident profile expansion and family access grants" section to "Resident profile open questions" — removed family access reference from the heading and intro sentence; (2) Removed the "Family access grant flow" subsection (11 bullets) from that renamed section — content is tracked more accurately in task 0006 and ADR 0004; (3) Replaced the existing "Family access architecture (Task 0006)" section with a canonical ≤15-line entry structured as: decided (ADR 0004 summary), Phase 2 blockers (5 open items), and pointer to task 0006/ADR 0004; (4) Added Phase 2 gate note to task 0006 Planning Notes: three unresolved blockers before any family-facing implementation (counsel review, app delivery ADR, auth mechanism ADR). All files mirrored to ai-workspace-framework. Task 0006 remains active — all three gate blockers are unresolved.

## 2026-05-24 (task 0001 — business model owner-validation packet: pricing probe, decision thresholds, ALH talking points, support model)

- Documentation-only task. No application source changed. Context read: task 0001, ADR 0001/0002/0003/0005, task 0002 Sections 4b and 6. Key corrections: (1) ALH partner rate ($49/month) was finalized in ADR 0003 but plan item and "Remaining to close" item both had stale [ ] — updated to [x]; (2) ADR plan item updated to [x] (ADR 0001/0002/0003 all accepted); (3) Section 5 "Open questions" table updated — 3 of 5 questions resolved (ALH rate, shared billing, founding rate), 2 remain open (standalone price, support model). Work produced: task 0001 Section 6 (Owner Validation Packet) with 5 subsections: (6a) decided vs. open status summary table; (6b) 5-question pricing sensitivity probe aligned with task 0002 Section 6 and Section 4b; (6c) decision thresholds for $149/month — 5 scenarios covering lock/lower/raise/reposition/floor; (6d) 5 support/onboarding workload questions owner must answer before Phase 3; (6e) ALH partner talking points with approved framing and 5 prohibited statements. Updated ai_memory.md: split business model section into decided vs. open; added validation packet pointer. All files mirrored to ai-workspace-framework. Task 0001 remains active pending design partner pricing probe (2–3 conversations) and owner support/onboarding model assessment.

## 2026-05-24 (task 0008 — offline spec refinement: idempotency keys, queue validation, WiFi checklist, implementation test plan)

- Documentation-only task. No application source changed (offline support not yet implemented — package.json confirmed: no service worker library, no IndexedDB wrapper, no `vite-plugin-pwa`). Refinements to `0008-device-and-offline-behavior.md`: (1) Queue structure bullet renamed from "Optimistic local ID" to "Idempotency key (UUID v4, client-generated)"; server idempotency contract (HTTP 200/201 or 409-as-success) documented; (2) Queue item validation rules added (8-field table: resident_id, routine_id, category, status, logged_at ±24h clock-skew guard, shift_id, note max 2000 chars, idempotency_key UUID v4 format); (3) AC #2 description updated to reference idempotency and validation additions; (4) Section 6 (Design Partner WiFi/Site Validation Checklist) added — aligns with task 0002 Section 4b format, covers pre-visit, WiFi coverage, device/browser, offline posture validation, and post-visit findings; (5) Section 7 (Implementation Test Plan) added — 18 unit tests (queue write/validation/idempotency/capacity/status transitions/retry/FIFO/timestamps/batch), 10 integration tests (sync, idempotent replay, conflict detection, auth expiry), 12 browser/manual tests (real devices at minimum baseline), 8 failure/retry scenarios, 7 privacy/security checks. All prospective — no tests written or run. Updated ai_memory.md (task 0008 section). All files mirrored to ai-workspace-framework. Task remains active pending human TA confirmation (AC #6) and design partner site visit.

## 2026-05-23 (active task queue audit — CRM/provisioning stale task cleanup)

- Housekeeping task. Audited all 9 active alh-tracker tasks against tasks 0027/0032/0051–0060 completed work. Two tasks moved to done/: (1) task 0011 (CRM facility management — marked done since 2026-05-17 via Status field and Outcome section, implementation complete with build pass and commit 1709a8d, never moved from active/); (2) task 0026 (CRM owner provisioning readiness audit — all acceptance criteria checked, outcome complete, superseded by workstreams 0027–0032 and 0051–0060). Both moves mirrored to ai-workspace-framework. Cleaned two stale entries in ai_memory.md: (a) CRM Phase 1 prerequisites (crm.crm_staff table, JWT middleware, login page) — updated to show implemented by tasks 0051–0053 with staging verification blocked on operator credentials; (b) User.created_by removed from remaining provisioning TODOs — marked RESOLVED (ADR 0012 Decision 4). Remaining active tasks confirmed accurately blocked (0001/0002: owner-blocked; 0004/0009: counsel-blocked; 0006/0008: future-phase; remaining execution: operator-blocked on staging credentials). No application source changed.

## 2026-05-23 (task 0002 — design partner outreach packet: offline/WiFi validation, on-site checklist, tracker Quick Start)

- Documentation-only task. Task 0002 remains active — outreach execution required by owner. Work produced: (1) Added WiFi/connectivity observation row to task 0002 Section 4 "What to Observe" table; (2) Added Section 4b on-site observation checklist (discrete tick-box format for use during actual site visit); (3) Added offline/WiFi and phone-access-policy validation questions to task 0002 Section 6 task-0003-blocker table (reflects task 0008 offline spec validation requirement); (4) Updated task 0003 gating sentence to include question 9 (WiFi/connectivity); (5) Added Quick Start section to design_partner_tracker.md with 5-step owner action sequence and pointers to scripts/checklist. Updated ai_memory.md (design partner status and next owner actions). All files mirrored to ai-workspace-framework. No application source changed.

## 2026-05-23 (counsel handoff consolidation — 0004-counsel-handoff-packet.md updated with Q-R1–Q-R8)

- Documentation-only task. Updated `0004-counsel-handoff-packet.md` to consolidate all current compliance/privacy counsel questions. Added Q-R1–Q-R8 from task 0009 retention/deletion analysis. Reorganized questions into 5 priority groups (pre-commercial launch, retention/account closure, medication-adjacent/Title 22, privacy/data subject rights, future family access). Expanded decisions-blocked table with 7 new rows covering retention clock, post-closure retention obligation, export format, cold storage, CCPA/audit events, medication destruction records, and retention automation gating. Updated email cover note to reference full question set (Q1–Q4, Q-R1–Q-R8, Q5–Q9). Updated `ai_memory.md` (counsel handoff consolidated note). All files mirrored to ai-workspace-framework. No application source changed.

## 2026-05-23 (task 0009 — retention and deletion policy: preliminary policy draft)

- Documentation-only task. Task 0009 remains active — counsel approval is still required before any acceptance criteria can close. Work produced: (1) schema audit of soft-delete and archive fields across all 15+ tables in migrations 0000–0014 (documented in task 0009 Notes); (2) preliminary data category retention recommendation table (12 data categories with preliminary minimum retention, deletion approach, and key counsel question per category); (3) account closure behavior recommendations (4-phase: immediate, hold, retention window, purge); (4) archive vs. delete vs. anonymize framework; (5) implementation implications (5 schema gaps, 3 future jobs, PITR assessment); (6) 8 additional counsel questions (Q-R1 through Q-R8 — CPPA/CCPA vs. retention, audit immutability, PITR, § 87465 destruction records, per-resident retention clock, vendor obligation post-closure, export requirements, cold storage queryability). Updated `compliance_notes.md` (Deletion and Retention Constraints section + 8 new counsel questions in Open Security Questions). Updated `ai_memory.md` (retention section with schema audit status, remaining blockers, and pointer to policy draft). All files mirrored to ai-workspace-framework. No application source changed. No TypeScript/build run (documentation-only task).

## 2026-05-23 (task 0027 — provisioning schema and RLS migrations audit)

- Audit and verification task. Task 0027 (backlog since 2026-05-19) activated and verified as fully superseded. All 12 acceptance criteria confirmed against actual migration files: three provisioning enums (user_account_status, facility_provisioning_status, provisioning_event_type + token_expired_passive) in migrations 0007/0010; facilities.provisioning_status + crm_facility_reference UNIQUE + users.account_status in migration 0007; provisioning_tokens (RLS, zero client policies) + provisioning_events (RLS, REVOKE UPDATE/DELETE) in migration 0007; is_active_user_on_active_facility() STABLE SECURITY DEFINER in migration 0008; all 13 care-ops tables quarantine gate applied in migration 0008; safe defaults via NOT NULL DEFAULT 'active'; blockers #5 (role naming — ADR 0011), #6 (users.created_by — ADR 0012), #10 (token_expired_passive — migration 0010) all resolved. No new migrations or assertion scripts required — db-assertions.sql exists from task 0040. Local checks: npm run test:provisioning PASS (43/43); npx tsc --noEmit PASS; npm run build PASS (479.00 kB); npm run verify:secrets FAIL: 0 WARN: 0. Credential-dependent RLS checks blocked on local Supabase (same as tasks 0032, 0060). Task moved to done.

## 2026-05-23 (task 0060 — provisioning test hardening and integration-test handoff)

- Hardening and documentation task. Two gaps fixed in `scripts/verify-provisioning/scenarios.md`: (1) Prerequisites table missing CRM auth requirement — added "CRM bridge auth" row with JWT header instruction and `CRM_DEMO_AUTH_BYPASS=true` local dev shortcut (never in staging); updated all three "How to call the CRM bridge" curl examples with `$AUTH_TOKEN` shell variable and `Authorization: Bearer` header; (2) Environment Limitations section missing Scenario 9 — updated to read "Scenarios 1–7 and Scenario 9 require a live DB". Created `scripts/verify-provisioning/operator-handoff.md`: concise 5-section operator entry point covering local Vitest coverage (43 tests, no credentials), local Supabase prerequisites (Scenarios 1–7, 9), staging prerequisites (Scenario 6 activation, race condition, idempotency, E2E), pass/fail criteria with 4 explicit STOP conditions, canonical file index. Local checks: `npm run test:provisioning` PASS (43/43); `npx tsc --noEmit` PASS; `npm run build` PASS (479.00 kB); `npm run verify:secrets` FAIL: 0 WARN: 0. Task moved to done. No provisioning behavior changed.

## 2026-05-23 (task 0032 — provisioning bridge and crypto unit tests)

- Implementation task. Added Vitest (`^4.1.7`) and `@types/node` (`^25.9.1`) as devDependencies. Created `vitest.config.ts` (Node.js environment, includes `tests/**/*.test.ts`). Added `"test:provisioning": "vitest run tests/provisioning"` script to `package.json`. Created `tests/provisioning/bridge.test.ts` (23 tests): covers `api/crm/provision.ts` with all externals mocked (`requireCrmAuth`, `fetch`, `process.env`); tests: GET/DELETE → 405; 401 missing_token / 403 staff_inactive / 403 insufficient_role forwarded correctly; 503 when CRM_TRACKER_PROVISIONING_KEY or TRACKER_PROVISION_URL absent; 400 for malformed JSON / invalid action / missing crmFacilityId / provision missing required fields; resend/status pass without provision fields; response sanitization verifies 10 forbidden tracker fields absent from bridge response (facility_id, user_id, token_hash, token, crm_facility_reference, service_role_key, tracker_user_id, auth_user_id, care_data, tracker_facility_id) and only safe fields forwarded (provisioning_reference, provisioning_status, email_delivered, token_expired — last two only when upstream sends boolean); 502 on fetch throw / non-JSON; 404/409/500 proxied as provisioning_failed. Created `tests/provisioning/crypto.test.ts` (20 tests): Node.js equivalents of Deno Edge Function utilities (sha256Hex, generateRawToken, timingSafeEqualHex, validatePassword); covers: 64-char hex output, determinism, uniqueness across 100 calls, timing-safe comparison, password complexity rules. All 43 tests pass. `npx tsc --noEmit` PASS; `npm run build` PASS (479.00 kB); `npm run verify:secrets` FAIL: 0 WARN: 0. BLOCKED: RLS/SQL tests require local Supabase; E2E/integration tests require staging credentials. Task moved to done; credential-dependent scope documented in task document.

## 2026-05-23 (task 0059 — CRM staging operator verification handoff)

- Documentation task. No application code changed. Created operator handoff document `0059-crm-staging-operator-handoff.md`: canonical file index (0058 runbook, scenarios.md, db-assertions.sql, crm_auth_runbook.md, provisioning_runbook.md); Vercel env var checklist (must-present: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, CRM_TRACKER_PROVISIONING_KEY, TRACKER_PROVISION_URL, ALERT_WEBHOOK_URL; must-absent: CRM_DEMO_AUTH_BYPASS); Supabase Edge Function secrets checklist (CRM_API_KEY_V1_HASH, RESEND_API_KEY, RESEND_FROM_ADDRESS, TRACKER_BASE_URL, ALERT_WEBHOOK_URL across provision-owner/activate-owner/expire-tokens); CRM staff bootstrap SQL check; P1–P20 run order with DB assertion group mapping; pass/fail criteria; cleanup SQL; explicit stop conditions (CRM_DEMO_AUTH_BYPASS present, auth_user_id_violation, Internal Staff (Demo) in author_name). Local checks: npx tsc --noEmit PASS; npm run build PASS (479.00 kB); npm run verify:secrets FAIL: 0 WARN: 0. Task moved to done; staging execution remains operator-owned.

## 2026-05-23 (task 0058 — CRM persistence staging verification and production-readiness audit)

- Audit and documentation task. Inspected all 9 CRM API/auth files (api/lib/crmAuth.ts; api/crm/facilities.ts, facilities/[id].ts, notes.ts, notes/[id].ts, communications.ts, follow-ups.ts, follow-ups/[id].ts) and 3 frontend files (src/lib/crmApi.ts, src/store/useCrmStore.ts, src/pages/crm/CrmFacilityDetail.tsx) plus .env.local.example. All findings: requireCrmAuth called before business logic in all 7 endpoints; service-role client uses process.env exclusively; all DB ops target crm.* schema only; zero care_log_entries/residents/wellness_observations/shift_close_records/public.users references in api/ (grep PASS); response mappers exclude auth_user_id, token_hash, service_role_key, tracker IDs; audit_log changed_by = actor.crm_staff_id (crm.crm_staff.id UUID, not auth.users.id); CRM_DEMO_AUTH_BYPASS not set in shell env, commented out in .env.local.example with "NEVER enable in production" warning. One gap fixed: Summary of Expected Outcomes table in scripts/verify-crm-persistence/scenarios.md extended from P13 to P20 (P14–P20 rows added for notes, communications, follow-ups). Full operator runbook written in task document covering prerequisites checklist, pre-run schema assertions (A0), per-scenario execution checkpoints, post-run cleanup, and staging pass/fail criteria. Local checks: npx tsc --noEmit PASS; npm run build PASS (479.00 kB); npm run verify:secrets FAIL: 0 WARN: 0. Live staging execution BLOCKED — no .env.local, SUPABASE_URL, or SUPABASE_SERVICE_ROLE_KEY available locally. Task moved to done; runbook is operator-ready once staging credentials are available.

## 2026-05-23 (task 0057 — CRM related records persistence)

- Implementation task. Created 5 new Vercel serverless API endpoints: `api/crm/notes.ts` (POST create note; author_name = actor.display_name; validates facilityId, content, isPriority; audit_log note_created; returns 201 CrmNote); `api/crm/notes/[id].ts` (PATCH update content/isPriority; fetches current for facility_id + previous_values snapshot; audit_log note_updated); `api/crm/communications.ts` (POST create communication; validates noteType against ALLOWED_NOTE_TYPES = call/email/meeting/internal/support; audit_log communication_created); `api/crm/follow-ups.ts` (POST create follow-up; assigned_to = actor.display_name, status = 'open'; audit_log follow_up_created); `api/crm/follow-ups/[id].ts` (PATCH update status; validates against ALLOWED_STATUSES = open/done/snoozed; audit_log follow_up_updated with previous_values snapshot). All endpoints use requireCrmAuth(); service-role DB access only; changed_by = actor.crm_staff_id. Updated `src/lib/crmApi.ts`: 5 new exported functions (createNote, patchNote, createCommunication, createFollowUp, patchFollowUpStatus) following the same auth-header + error-handling pattern as existing functions. Updated `src/store/useCrmStore.ts`: added relatedWriteError (Record<string, string|null>) state and clearRelatedWriteError action; all 5 write actions made async (addNote, updateNote, addCommunication, addFollowUp, markFollowUpDone); demo mode resolves immediately with local update only; authenticated mode calls API, reconciles store with server response, sets relatedWriteError on failure; updateNote and markFollowUpDone apply optimistic local update first; markFollowUpDone reverts to status 'open' on API failure. Updated `src/pages/crm/CrmFacilityDetail.tsx`: added isDemo detection via getSupabaseClient(); handleAddComm, handleAddOrUpdateNote, handleAddFollowUp made async — form reset only happens when relatedWriteError is not set (form stays open on failure preserving user input); relatedWriteError error banner added per-facility; health-data warning copy added to note and comm forms in authenticated mode ("CRM notes/communications only — do not include resident health information"); all "Demo only" copy wrapped in {isDemo && ...}. Extended `scripts/verify-crm-persistence/scenarios.md` with P14–P20 (create note, update note, create comm with invalid noteType rejection, create follow-up, mark done with invalid status rejection, 401/403 rejection on all new endpoints, detail endpoint returns persisted records). Extended `scripts/verify-crm-persistence/db-assertions.sql` with A7–A9 (post-note, post-comm, post-follow-up assertions including audit_log entries and previous_values checks). `npx tsc --noEmit` clean; `npm run build` clean (479.00 kB); `verify:secrets` FAIL: 0 WARN: 0. Browser never queries crm.* tables directly. No tracker care data or tracker internal IDs exposed.

## 2026-05-22 (task 0056 — CRM store/UI persistence migration Phase 1)

- Implementation task. Created `src/lib/crmApi.ts`: typed API client for CRM persistence endpoints. `listFacilities(showArchived?)`, `getFacilityDetail(id)`, `createFacility(input)`, `patchFacility(id, patch)`. Reads Supabase Auth session token via `supabase.auth.getSession()` for `Authorization: Bearer` header (same pattern as crmProvisioningAdapter.ts). Returns `CrmApiResult<T>` discriminated union; 401/403/network errors return safe messages. No circular imports — createFacility input typed inline. Updated `src/store/useCrmStore.ts`: added `facilitiesLoading`, `facilitiesError`, `detailLoading`, `detailError`, `facilityUpdateError` state fields; added `loadFacilities(showArchived?)`, `loadFacilityDetail(id)`, `clearFacilityUpdateError(id)` actions; changed `addFacility` → `Promise<string>`, `updateFacility` → `Promise<void>`, `archiveFacility` → `Promise<void>`; `isDemo = !getSupabaseClient()` at module level gates all API calls; seed data initialized in demo mode only; authenticated mode starts with empty arrays; `PATCH_EXCLUDED` set prevents patching id/timestamps/provisioning fields; demo mode resolves immediately with existing local behavior; archive is API-first (navigates only on success). Updated `src/pages/crm/CrmFacilities.tsx`: `useEffect` calls `loadFacilities(showArchived)` on mount and toggle; `handleAdd` is async with `addError` toast; loading spinner and error banner added; table is conditionally rendered. Updated `src/pages/crm/CrmFacilityDetail.tsx`: `useEffect` calls `loadFacilityDetail(id)` on mount; `handleEditSave` and `handleArchive` are async; checklist toggles use `void updateFacility(...)`; not-found shows loading spinner when `detailLoading[id]` is true; update error banner and detail error banner added. Updated `src/pages/crm/CrmDashboard.tsx`: `useEffect` calls `loadFacilities()` on mount; loading spinner and error banner added; hardcoded "Demo mode" note replaced with conditional empty-state message. `npx tsc --noEmit` clean; `npm run build` clean (474.15 kB); `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0055 — CRM persistence API Phase 1)

- Implementation task. Created `api/crm/facilities.ts`: GET /api/crm/facilities (list active or archived facilities, up to 100, includes owner contact via PostgREST join, ?archived=true for archived list); POST /api/crm/facilities (create facility + owner_contacts row, validates required fields, writes `facility_created` audit_log entry with `changed_by = crm_staff_id`). Created `api/crm/facilities/[id].ts`: GET /api/crm/facilities/:id (facility detail with notes/follow_ups/communications joined); PATCH /api/crm/facilities/:id (update allowed fields, owner contact update via ownerContact body key, archive/unarchive via `archived: true/false`, checklist fields via nested `onboardingChecklist`, writes facility_updated/facility_archived/facility_unarchived audit_log entries with previous_values snapshot; `provisioning_status`/`provisioning_reference` excluded — bridge-managed only). All endpoints use requireCrmAuth(); changed_by in audit_log is crm.crm_staff.id (not auth.users.id); response shapes map DB snake_case to camelCase per CrmFacility type. Created `scripts/verify-crm-persistence/scenarios.md` (13 scenarios P1–P13: auth failures, CRUD operations, archive/unarchive, provisioning boundary, no public.users requirement, no care-data access) and `scripts/verify-crm-persistence/db-assertions.sql` (groups A0–A6: schema structure, post-create, audit_log, post-update, archive, boundary assertions, cleanup). `npx tsc --noEmit` clean; `npm run build` clean (466.60 kB); `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0054 — CRM staff bootstrap and auth verification)

- Documentation task. Created `crm_auth_runbook.md`: 7-section runbook covering CRM staff bootstrap (create auth user, insert crm.crm_staff row, confirm no public.users row, sign in, provision call, confirm X-CRM-Actor-Id = crm_staff.id, sign out), positive verification checklist, 5 negative verification scenarios (no crm_staff row → 403, is_active=false → 403, non-crm_admin role → 403, missing token → 401, care-table boundary check), demo bypass guidance (detection + disable), cleanup steps, and boundary constraint summary. Created `scripts/verify-crm-auth/scenarios.md` (8 scenarios P1 + N1–N6 + bypass check) and `scripts/verify-crm-auth/db-assertions.sql` (S0–S13 covering bootstrap, RLS posture, care-data boundary, audit_log append-only, demo bypass detection). Added Section 11 (CRM Staff Authentication) to `provisioning_runbook.md` with cross-reference and quick-reference table. No TypeScript files modified. `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0053 — CRM login and authenticated provisioning calls)

- Implementation task. Created `src/pages/crm/CrmSignIn.tsx`: CRM-branded email+password login page; uses `useAuth().signIn()` (AuthProvider); maps Supabase Auth errors to safe copy; redirects to /crm on success; passes through immediately in demo mode. Created `src/components/RequireCrmAuth.tsx`: route guard for `/crm/*`; checks `session` (not `user`) from `useAuth()` — CRM staff have valid sessions but no `public.users` rows; redirects to /crm/sign-in when no session; passes through in demo mode. Updated `src/lib/crmProvisioningAdapter.ts`: added `getSupabaseClient().auth.getSession()` call in `callBridge()` to get access_token; adds `Authorization: Bearer <token>` header when present; added 401 → session expired copy, 403 → access denied copy; removed `crmActorId: 'crm-staff'` from all bridge calls. Updated `src/components/CrmLayout.tsx`: added sign-out button (shows truncated email) in Supabase mode; demo mode shows "No authentication (demo mode)" badge. Updated `src/App.tsx`: added public `/crm/sign-in` route; wrapped `/crm` routes with `RequireCrmAuth`. Updated `.env.local.example`: added CRM login setup section (no new env vars — reuses VITE_SUPABASE_*); updated CRM_DEMO_AUTH_BYPASS note to say no longer required for normal authenticated usage. `npx tsc --noEmit` clean; `npm run build` clean (466.60 kB); `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0052 — CRM API auth middleware and staff identity)

- Implementation task. Created `api/lib/crmAuth.ts`: reusable CRM auth helper for Vercel serverless functions. Exports `requireCrmAuth(req)` → validates Supabase Auth JWT via `supabase.auth.getUser(token)`, queries `crm.crm_staff` by `auth_user_id` using service-role key + `supabase.schema('crm')`, enforces `is_active = true` and `role = 'crm_admin'`; returns `CrmActor { crm_staff_id, display_name, email, role }`. Returns 401/403/503 on failure. Demo bypass: `CRM_DEMO_AUTH_BYPASS=true` skips JWT validation and returns hardcoded demo actor (Phase 0 only). Updated `api/crm/provision.ts`: added auth check before body parse; actor identity now comes from auth result (`crmActor.crm_staff_id`) not request body; `crmActorId` removed from `BridgeRequest`. Updated `.env.local.example` with `SUPABASE_URL` (Vercel), `SUPABASE_SERVICE_ROLE_KEY` (Vercel), and `CRM_DEMO_AUTH_BYPASS` docs. `npx tsc --noEmit` clean; `npm run build` clean (462.17 kB); `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0051 — CRM persistence schema Phase 0)

- Implementation task. Created migration `supabase/migrations/20260101000014_crm_schema_phase0.sql`: creates `crm` schema, 7 CRM-scoped enums (aligned with src/types/crm.ts values), and 7 tables (crm_staff, facilities, owner_contacts, notes, follow_ups, communications, audit_log). RLS enabled on all tables; no client-accessible policies (service-role-only posture per ADR 0015). `crm.audit_log` has `REVOKE UPDATE, DELETE FROM authenticated` (append-only). `crm.facilities` has partial unique index on provisioning_reference. Forbidden provisioning fields (token, token_hash, tracker IDs, resident IDs, care data) are absent. Updated `db/schema.sql` with matching CRM section. `npx tsc --noEmit` clean; `npm run build` clean (462.17 kB); `verify:secrets` FAIL: 0 WARN: 0.

## 2026-05-22 (task 0050 — CRM user authentication model)

- Design task only — no source code or migrations created. Created ADR 0015 at `decisions/0015-crm-user-authentication-model.md`: evaluates 5 auth options (same Supabase Auth + custom JWT hook; separate Supabase project; Google Workspace SSO; same Supabase Auth + service-role API pattern; Vercel password protection); recommends Option D (same Supabase Auth, service-role API) for MVP as consistent with existing provisioning bridge pattern. Key insight: service-role-only RLS on `crm.*` tables unblocks schema implementation immediately (Phase 0) without waiting for per-user auth — per-user auth is a pre-production blocker, not a pre-schema blocker. Documents `crm.crm_staff` table schema, three-layer care-data boundary enforcement, single `crm_admin` role for MVP, `X-CRM-Actor-Id` as `crm.crm_staff.id` in Phase 1 (fallback `'crm-staff'` in Phase 0), and full migration path from unguarded demo route. Updated decisions/README.md with ADR 0015 row.

## 2026-05-22 (task 0049 — CRM provisioning state persistence design)

- Design task only — no schema, migration, or production code created. Created ADR 0014 at `decisions/0014-crm-persistence-and-provisioning-state-boundary.md`: recommends same Supabase project + separate `crm` schema for MVP; documents all CRM entities (crm.facilities, crm.owner_contacts, crm.notes, crm.follow_ups, crm.communications, crm.audit_log); explicitly lists safe provisioning fields (provisioning_reference, provisioning_status, tracker_provisioned boolean) and forbidden fields (raw token, token_hash, tracker Facility.id, tracker User.id, auth.users.id, resident IDs, care data, service-role key); documents migration path from Zustand seed (Phase A: schema; Phase B: data loading; Phase C: store refactor — transient fields remain client-only); marks CRM auth model and CRM role granularity as pre-persistence blockers. Updated decisions/README.md with ADR 0014 row. No source code, migrations, or seed data modified.

## 2026-05-22 (task 0048 — Provisioning status sync verification)

- Verification hardening only — no production behavior changed. `scripts/verify-provisioning/scenarios.md`: added Scenario 9 (action=status) with curl examples for all 7 status mapping cases (not_provisioned, pending_setup+invited, pending_setup+invited+expired, pending_setup+disabled, active, suspended, closed), expected safe response shapes, status mapping table, forbidden-field manual checklist, store/UI behavior checklist, and read-only behavior confirmation. `scripts/verify-provisioning/db-assertions.sql`: added S9-A through S9-I with DB state setup queries, EXPECT comments for each mapping case, S9-H confirming status writes no events, and S9-I documenting that `handleStatus()` reads only `expires_at` (not `token_hash`). `scripts/verify-provisioning/check-secrets.mjs`: added two FORBIDDEN patterns scanning `api/` — `"facility_id"` and `"user_id"` as quoted JSON response keys — both pass cleanly. TypeScript clean, build clean (462.17 kB), `npm run verify:secrets`: FAIL: 0, WARN: 0.

## 2026-05-22 (task 0047 — CRM provisioning status sync)

- Added read-only `status` action to the provisioning system across 5 files. `supabase/functions/provision-owner/index.ts`: added `handleStatus()` (reads `facilities.provisioning_status` + `users.account_status` + `provisioning_tokens.expires_at`; maps tracker state → CRM status per documented table; checks for expired invitation token; returns `{ provisioning_reference, status, token_expired? }`); wired into action dispatch; idempotency check/storage skipped for status (read-only). `api/crm/provision.ts`: added `'status'` to Action type and validation; added `token_expired` to bridge response. `src/lib/crmProvisioningAdapter.ts`: added `token_expired?: boolean` to `ProvisionResult`; added `refreshProvisioningStatus()` export. `src/store/useCrmStore.ts`: added `provisioningTokenExpired` state, `refreshProvisioningStatus` action, `clearProvisioningTokenExpired` action; resend/revoke success clears token-expired flag. `src/pages/crm/CrmFacilityDetail.tsx`: added "Check status" button (RotateCcw icon, visible for all provisioned states); added dismissable token-expired warning banner. Dashboard/list metrics reflect refreshed status automatically via shared store. Status mapping and `token_expired_passive` limitation documented in code and task doc. TypeScript clean, build clean (462.17 kB), `npm run verify:secrets`: FAIL: 0, WARN: 0. No existing provision/resend/revoke behavior changed.

## 2026-05-22 (task 0046 — CRM provisioning UX: failure states and safe copy)

- Hardened CRM provisioning UX across 3 files. `src/lib/crmProvisioningAdapter.ts`: added explicit 502 / `upstream_unavailable` handling with actionable "tracker temporarily unavailable, try again" message (before the generic fallback). `src/store/useCrmStore.ts`: added `provisioningEmailWarning: Record<string, boolean>` state and `clearProvisioningEmailWarning` action; wired into `provisionFacility` (set on `email_delivered === false`), `resendProvisioningInvite` (same), and `revokeProvisioningInvite` (clears on success). `src/pages/crm/CrmFacilityDetail.tsx`: removed stale `provisionDemoNote` state and all three post-action demo note assignments; updated provision/resend/revoke confirm dialog copy to remove inaccurate "Demo mode — no real API call" notes (now accurate: provision dialog notes Vercel deployment requirement); added info text for `active` / `suspended` / `closed` provisioning states (no buttons, informational only); added dismissable email-not-delivered warning banner (amber, full-width, safe copy, no email/token/ID). TypeScript clean, build clean (459.80 kB), `npm run verify:secrets`: FAIL: 0, WARN: 0. No provisioning lifecycle behavior changed.

## 2026-05-21 (task 0045 — Resolve CRM bridge secret name in bundle warning)

- Removed `CRM_TRACKER_PROVISIONING_KEY` from the browser-visible 503 error string in `src/lib/crmProvisioningAdapter.ts` (line 46). Changed error message to: "Provisioning bridge is not configured. Contact your technical administrator to configure the server-side environment variables." Updated stale comment and note in `scripts/verify-provisioning/check-secrets.mjs` (WARN_PATTERNS entry is retained as a regression guard). Updated `provisioning_runbook.md` sections 6.1 and 10/Step 7: expected output changed from FAIL: 0, WARN: 1 to FAIL: 0, WARN: 0. TypeScript clean, build clean (458.66 kB), `npm run verify:secrets`: FAIL: 0, WARN: 0. No provisioning behavior changed.

## 2026-05-21 (task 0044 — Provisioning pre-production cutover dry run)

- Documentation-only readiness audit. Confirmed: 14 migrations (0000–0013) present; 3 Edge Functions present (`provision-owner`, `activate-owner`, `expire-tokens`); 3 npm scripts present (`verify:secrets`, `test:alert`, `check:sweep-cadence`); all operator tooling needs are labeled in `scenarios.md`. Fixed three docs-drift items: (1) `provisioning_runbook.md` section 2.2 migration count corrected from 13 (0000–0012) to 14 (0000–0013); (2) critical migrations table in section 2.2 updated with migration 0013 row (`sweep_heartbeat` table); (3) `.env.local.example` updated to note that `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` may be set locally for operator scripts (`check:sweep-cadence`), with warning against `VITE_` prefix. Added new `provisioning_runbook.md` Section 10 (Pre-Production Cutover Dry Run): 10-step ordered checklist with test constants, per-step commands, pass/fail signals, 10-checkbox completion criteria, and remaining pre-production blockers. `npm run verify:secrets`: FAIL 0, WARN 1 (expected).

## 2026-05-21 (task 0043 — Provisioning alert verification and sweep cadence)

- Created `scripts/verify-provisioning/test-alert.mjs`: synthetic alert delivery test script (Node 18+, zero deps, `npm run test:alert`). Reads `ALERT_WEBHOOK_URL` from env or `.env.local`; sends safe test payload (`event: test_alert`, `_test: true`); exits 0 on 2xx. Vercel vs. Supabase distinction documented in usage comments and runbook. Created `supabase/migrations/20260101000013_sweep_heartbeat.sql`: single-row `sweep_heartbeat` table (RLS enabled, service-role only, no client policies; seeds id=1 row). Updated `supabase/functions/expire-tokens/index.ts`: UPSERT to `sweep_heartbeat` after each successful sweep (best-effort, non-fatal). Created `scripts/verify-provisioning/check-sweep-cadence.mjs`: heartbeat health check via Supabase PostgREST REST API (Node 18+, zero deps, `npm run check:sweep-cadence`; reads `last_sweep_at`, checks age vs `SWEEP_MAX_AGE_HOURS` default 26). Updated `package.json` with `test:alert` and `check:sweep-cadence` scripts. Updated `db/schema.sql` with `sweep_heartbeat` table definition. Updated `provisioning_runbook.md`: Section 7.2 (sweep cadence TODO → WIRED; alert blocker references test:alert), new Section 7.5 (alert delivery verification), new Section 7.6 (sweep cadence verification), Section 9.5. TypeScript clean, build clean (458.66 kB, unchanged), secret scan FAIL: 0, WARN: 1 (expected). Remaining pre-production blocker: set `ALERT_WEBHOOK_URL` in Vercel + Supabase; apply migration 0013; auth burst detection deferred.

## 2026-05-21 (task 0042 — Provisioning monitoring/alerting)

- Added `sendAlert()` webhook helper to `api/crm/provision.ts` (Node.js, `process.env.ALERT_WEBHOOK_URL`), `supabase/functions/provision-owner/index.ts`, `supabase/functions/activate-owner/index.ts`, and `supabase/functions/expire-tokens/index.ts` (all Deno, `Deno.env.get('ALERT_WEBHOOK_URL')`). No-op when env var is unset. 19 alert call sites across 4 surfaces. Updated `logAuthFailure()` in provision-owner to be async and call `sendAlert()`. Added response shape validation to expire-tokens. Updated `.env.local.example` with `ALERT_WEBHOOK_URL` documentation. Updated `provisioning_runbook.md` Section 7.2 (wired-vs-TODO table) and added Section 7.4 (configuration). TypeScript clean, build clean (458.66 kB), secret scan FAIL: 0 WARN: 1 (expected). `ALERT_WEBHOOK_URL` confirmed absent from src/ and dist/.

## 2026-05-21 (task 0041 — Provisioning production runbook)

- Created `ai-context/projects/alh-tracker/provisioning_runbook.md`: 9-section production runbook covering env vars (Vercel + Supabase secrets, public vars, browser-exposure list), deployment order (migrations 0000–0012, secrets, Edge Functions, Resend domain, Vercel, smoke tests), Resend SPF/DKIM/DMARC setup with safe no-email fallback, token expiry scheduling (Dashboard cron preferred / pg_cron alternative), zero-downtime key rotation sequence + emergency revocation, smoke-test checklist referencing `scripts/verify-provisioning/scenarios.md`, monitoring/alerting status (all pre-production blockers documented — no alert delivery wired), rollback/recovery procedures for 7 failure scenarios, data boundary and compliance guardrails. Secret scan: FAIL 0, WARN 1 (expected). Documentation-only — no application source changed.

## 2026-05-21 (task 0040 — Provisioning end-to-end verification harness)

- Created `scripts/verify-provisioning/check-secrets.mjs`: automated Node.js ESM secret scan (zero deps, Node 18+); scans `src/`, `api/`, `dist/` for SUPABASE_SERVICE_ROLE_KEY, token_hash, activation_url, CRM_API_KEY, RESEND_API_KEY, sweep_expired_provisioning_tokens; warns on CRM_TRACKER_PROVISIONING_KEY name in dist (expected); exits 1 on failure. Created `scripts/verify-provisioning/db-assertions.sql`: SQL query blocks for all 8 scenarios with EXPECT comments; never selects token_hash or care data. Created `scripts/verify-provisioning/scenarios.md`: master walkthrough with curl commands, DB assertions, environment prerequisites, manual review checklists, cleanup SQL. Updated `package.json`: added `verify:secrets` script. Secret scan: FAIL 0, WARN 1 (expected). TypeScript clean, build clean (458.66 kB).

## 2026-05-21 (task 0039 — Passive provisioning token expiry sweep)

- Created `supabase/migrations/20260101000012_expire_tokens_rpc.sql`: `sweep_expired_provisioning_tokens()` SECURITY DEFINER RPC. Uses INSERT ... SELECT ... WHERE NOT EXISTS keyed on `(user_id, event_type, metadata->>'token_id')` for idempotency. Sets `actor_id='system:token-sweep'`, `metadata={token_id, expired_at}`. REVOKE from PUBLIC, GRANT to service_role. Created `supabase/functions/expire-tokens/index.ts`: minimal scheduled Edge Function; calls RPC, logs swept count, returns `{ok, swept}`. Updated `db/schema.sql` with sweep RPC for schema reference. `npx tsc --noEmit` clean, `npm run build` clean (458.66 kB, unchanged). Forbidden-string check: no secrets, token hashes, or care data in browser code or dist. Provisioning backend greenfield gap fully closed.

## 2026-05-21 (task 0038 — Tracker provisioning lifecycle verification)

- Inspected provision-owner/index.ts, activate-owner/index.ts, ActivationPage.tsx, db/schema.sql, and migrations 0009–0011. All three provisioning actions (provision/resend/revoke) plus re-provision fully implemented and verified against ADRs 0007/0008/0009/0010/0012/0013. Token atomicity confirmed via `expireActiveTokens()`. RLS/SECURITY DEFINER grants confirmed on provisioning_tokens, provisioning_events, provisioning_idempotency_keys, check_activation_token, complete_owner_activation. ActivationPage wired to /activate in App.tsx. No missing implementation found — task 0032 (E2E tests) is the remaining gap. Noted tracker-side gap: resend does not guard revoked-user state (CRM UI state machine correctly prevents this). `npx tsc --noEmit` clean, `npm run build` clean (458.66 kB), forbidden-string check PASS.

## 2026-05-21 (task 0037 — CRM server-side provisioning bridge)

- Created `api/crm/provision.ts`: Vercel serverless bridge. Reads `CRM_TRACKER_PROVISIONING_KEY` and `TRACKER_PROVISION_URL` exclusively from `process.env`; validates action + required fields; generates ADR 0008 headers (X-Request-Id, X-Idempotency-Key, X-CRM-Facility-Id, X-CRM-Actor-Id, X-Request-Timestamp); forwards to tracker Edge Function; filters response to CRM-safe fields only (provisioning_reference, provisioning_status, email_delivered); returns 503 if env vars not configured. Updated `src/lib/crmProvisioningAdapter.ts`: replaced demo-simulate-success stubs with `callBridge()` calling `/api/crm/provision`; payload updated (added facilityCity, facilityState, licenseNumber; removed allowedResidentCount). Updated `src/store/useCrmStore.ts`: `provisionFacility` passes `facility.city`, `facility.state`, `facility.rcfeLicensePlaceholder` to adapter. Updated `.env.local.example`: documented `CRM_TRACKER_PROVISIONING_KEY` and `TRACKER_PROVISION_URL` as Vercel env vars with setup instructions. `npx tsc --noEmit` clean, `npm run build` clean. Forbidden-string check: no secrets or raw tokens in browser code; `CRM_TRACKER_PROVISIONING_KEY` appears only as env var name in error message string — not a secret value.

## 2026-05-20 (task 0036 — CRM UI provisioning integration)

- Added `CrmProvisioningStatus` type and `CRM_PROVISIONING_STATUS_LABELS` to `src/types/crm.ts`. Renamed `CrmOnboardingStage` value `install_instructions_sent` → `tracker_provisioned`. Added `provisioning_status?` and `provisioning_reference?` fields to `CrmFacility`. Renamed `CrmOnboardingChecklist.installInstructionsSent` → `trackerProvisioned`. Created `src/lib/crmProvisioningAdapter.ts`: demo stub with clear TODO comments explaining server-side CRM call requirement and that `CRM_TRACKER_PROVISIONING_KEY` must never appear in browser code. Updated `src/store/useCrmStore.ts`: `provisioningLoading`/`provisioningError` state; `provisionFacility`, `resendProvisioningInvite`, `revokeProvisioningInvite`, `clearProvisioningError` actions; `addFacility` sets `provisioning_status: 'not_provisioned'` on new facilities. Updated `src/data/crm-seed.ts`: `installInstructionsSent` → `trackerProvisioned` in all checklist objects; `provisioning_status` and `provisioning_reference` added to all 7 seed facilities. Updated `src/pages/crm/CrmFacilityDetail.tsx`: `ProvisioningBadge` component; provisioning row in facility header with Provision/Resend/Revoke buttons and confirm modals; spinner/error/demo-note states; checklist made editable (click-to-toggle). Updated `src/pages/crm/CrmFacilities.tsx`: `tracker_provisioned` replaces `install_instructions_sent` in `ONBOARDING_BADGE`; new `PROVISIONING_BADGE` record; "Tracker" column added to facilities table. Updated `src/pages/crm/CrmDashboard.tsx`: provisioning metrics section (Not Provisioned / Invitation Sent / Tracker Active counts). Security check: `CRM_TRACKER_PROVISIONING_KEY` appears only in adapter TODO comments — no secrets in browser code. `tsc --noEmit` clean, `vite build` clean.

## 2026-05-20 (task 0029 — Activation endpoint and page)

- Implemented owner activation flow per ADR 0013. Migration `20260101000011`: two SECURITY DEFINER RPC functions (`check_activation_token`, `complete_owner_activation` with SELECT FOR UPDATE SKIP LOCKED) — REVOKE PUBLIC, GRANT service_role. Edge Function `supabase/functions/activate-owner/index.ts`: GET pre-flight token check (strips internal IDs), POST full activation sequence (hash → complexity check → check_activation_token RPC → password_pending marker → auth.admin.updateUserById → complete_owner_activation RPC → idempotency guard → signInWithPassword → return session); CORS headers added (browser-facing, unlike provision-owner). React page `src/pages/ActivationPage.tsx`: loading/expired/invalid/ready states, read-only email, editable pre-populated name, password + confirm with client-side complexity validation, setSession on success + navigate. Public `/activate` route added to `src/App.tsx`. `db/schema.sql` updated with both RPC functions. `tsc --noEmit` clean, `vite build` clean.

## 2026-05-20 (task 0035 — Auth-user timing review and ADR 0013)

- Reviewed the auth-user creation timing deviation introduced in task 0028: `public.users.id FK → auth.users(id)` requires auth user creation at provisioning time. Security analysis confirmed ADR 0007 intent is preserved — auth user has no password and email_confirm: false, cannot authenticate until activation. RLS quarantine (ADR 0010) provides defense in depth. One defect found and fixed: Edge Function `handleProvision`/`handleResend`/`handleRevoke` each had a `ref ?? facility.id` response fallback that would expose the tracker's internal Facility UUID — replaced with structured error log + 500 response (unreachable in practice, but must not leak IDs). Created ADR 0013 (accepted): documents the timing deviation, security analysis, auth-lifecycle requirements (ban on revoke, unban on re-provision, idempotent `updateUserById` at activation), and the defect fix. Updated ADR 0007: Phase 2 step 8g changed from `createUser` to `updateUserById`; partial activation recovery TODO resolved. Backlog task 0029 updated: activation sequence uses `updateUserById`, partial activation recovery section rewritten (simpler — no pre-existence check). `decisions/README.md` updated (ADR 0013 row). `ai_memory.md` updated (auth-user timing deviation resolved). Task doc `0035-auth-user-timing-review.md` created in done. Changes mirrored to ai-workspace-framework. No unrelated app changes.

## 2026-05-20 (task 0028 — CRM owner provisioning endpoint)

- Implemented `supabase/functions/provision-owner/index.ts` Edge Function: provision/resend/revoke actions; Bearer API key auth (SHA-256 constant-time comparison, V1/V2 rotation slots); all 7 required headers validated; ±5 min timestamp replay prevention; idempotency via `provisioning_idempotency_keys` table (24h TTL, lazy cleanup); atomic provision sequence (Facility pending_setup + auth user no-password + User invited + ProvisioningToken SHA-256 + ProvisioningEvent); activation email via Resend REST API; re-provision of disabled User (ADR 0012 Decision 6); retry payload conflict logged to structured application log only (no ProvisioningEvent written); response contract enforced (provisioning_reference + status only, no tracker IDs or raw tokens). Migration 0009 (`provisioning_idempotency_keys` table) and migration 0010 (`token_expired_passive` enum value) created and reflected in `db/schema.sql`. `.env.local.example` updated with server-side secret documentation. Schema FK constraint `users.id → auth.users(id)` requires auth user at provisioning time; auth user created with no password and `email_confirm: false` (cannot authenticate until activation). Task doc `0028-provisioning-api-endpoint.md` created in done; backlog file deleted. No client-side code (src/) modified.

## 2026-05-20 (task 0034 — Accept ADR 0012)

- ADR 0012 accepted. Two defects fixed before acceptance: (1) Decision 4 schema note softened — changed assertive "column accepts NULL by intent" to "verify at implementation time that the column is nullable in the applied migration"; (2) Decision 5 conflict logging corrected — changed "log in ProvisioningEvent.metadata" to "log in Edge Function structured application log" (no new ProvisioningEvent row is written on a conflict-retry; no applicable event_type exists per ADR 0008). Status `proposed` → `accepted` in ADR 0012. `decisions/README.md` updated (Proposed → Accepted). `ai_memory.md` updated (all 5 ADR 0012 resolution entries changed from proposed to accepted). Task doc `0034-accept-adr-0012.md` created in done. Changes mirrored to `ai-workspace-framework`. No application code changed.

## 2026-05-20 (task 0033 — Phase 2 provisioning platform decisions, ADR 0012)

- Created ADR 0012 (proposed): resolves all four Phase 2 provisioning blockers — endpoint hosting (Supabase Edge Function), idempotency storage (Supabase `provisioning_idempotency_keys` table), transactional email (Resend; Postmark fallback), `User.created_by` for CRM-provisioned accounts (nullable UUID FK; NULL = CRM, provenance in ProvisioningEvent). Also resolved: retry payload conflict behavior (ignore, log, return existing reference), re-provision of disabled User (permitted; reset to invited, new token, new reference), `token_expired_passive` retention (add back via migration + scheduled sweep), alert delivery (deferred to pre-production monitoring task). Updated `ai_memory.md` (4 blockers resolved/narrowed), `decisions/README.md` (ADR 0012 row added), `execution_log.md`. Task doc `0033-phase-2-provisioning-platform-decisions.md` created in done. Changes mirrored to `ai-workspace-framework`. No application code or schema files changed.

## 2026-05-19 (task 0030 — Phase 1 schema/RLS migrations and role cleanup)

- Applied Phase 1 provisioning schema + RLS foundations. Two new migrations: `20260101000007` (role enum rename `facility_admin`→`owner`, `admin` added, 3 provisioning enum types, `provisioning_status`/`crm_facility_reference` on facilities, `account_status` on users, `provisioning_tokens` and `provisioning_events` tables with zero client-accessible policies); `20260101000008` (`is_active_user_on_active_facility()` SECURITY DEFINER helper, care-ops quarantine gate applied to 13+ tables). TypeScript: `AuthProvider.tsx` `DbRole` rename + `mapToStoreRole()` hardened fallback; `src/types/index.ts` dead `AnyRole` removed; `src/data/seed.ts` demo user role fixed. `db/schema.sql` reference schema updated. Build clean. Task doc `0030-provisioning-schema-rls-migrations.md` created in done. `ai_memory.md` role-naming blocker updated to IMPLEMENTED.

## 2026-05-19 (task 0029 — Accept ADR 0011)

- ADR 0011 accepted and role-naming references updated. Status changed `proposed` → `accepted` in `decisions/0011-facility-owner-role-naming.md`, `decisions/README.md`, and `ai_memory.md`. Task doc `0029-accept-adr-0011.md` created in done. Changes mirrored to `ai-workspace-framework`. No application code changed.

## 2026-05-19 (task 0028 — ADR 0011 architecture review)

- Architecture review of ADR 0011 (facility owner role naming — status: proposed). Recommendation: **Accept with minor edits** (edits applied in this task).
- Two defects found and fixed: (1) migration section contained a factual error — claimed Postgres enum values "cannot be renamed directly"; `ALTER TYPE ... RENAME VALUE` has been available since PG10 and is fully transactional in PG15; migration SQL corrected to use `RENAME VALUE` + `ADD VALUE 'admin'`; removes `facility_admin` cleanly (no dead enum value); eliminates need for `UPDATE users` data migration. (2) `db/schema.sql` (reference production schema file) also defines `app_role` with `facility_admin` and uses it in `audit_read_admin` policy; not mentioned in ADR 0011 implementation TODOs — added.
- No conflicts with ADR 0006/0007/0010 or data_model.md found. All cross-references consistent.
- Task doc `0028-adr-0011-architecture-review.md` created in done. Task `0027-facility-owner-role-naming-adr.md` moved from active to done.
- Changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed.

## 2026-05-19 (task 0027 — facility owner role naming ADR)

- Architecture/design task. Resolved role naming discrepancy (blocker #5 from audit 0026). Discovered full three-layer inconsistency: DB `app_role` enum uses `facility_admin`; AuthProvider `mapToStoreRole()` maps `facility_admin` → `admin` (bug — owners presented as admins); `src/types/index.ts` `Role` type uses `owner`/`admin`; all docs/ADRs use `owner`/`admin`; two exported `AppRole` types with different values in different files.
- Created ADR 0011 (proposed): rename `facility_admin` → `owner` in DB enum; add `admin` as new enum value; migrate existing rows; remove mapping layer. CRM provisioning assigns `role = 'owner'` directly. 2 RLS policy updates identified.
- Updated `decisions/README.md`: added ADR 0011 row.
- Updated `data_model.md`: added implementation note (ADR 0011 migration required); documented `auditor` and `family_member` DB-only roles.
- Updated `ai_memory.md`: narrowed blocker #5 (decision made in ADR 0011; implementation still pending task 0027 schema migration backlog).
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed.

## 2026-05-19 (task 0026 — provisioning readiness audit)

- Implementation readiness audit for CRM owner provisioning endpoint (ADRs 0006–0010). Read-only inspection of all 7 Supabase migrations, src/ (AuthProvider, Zustand CRM store, repository layer, CRM types and pages), .env.local.example, and vercel.json. No application code or migrations changed.
- Key findings: no backend API layer exists (greenfield); 5 new enums + 4 new columns + 2 new tables required; `is_active_user_on_active_facility()` RLS helper missing; 13 care-ops policies need quarantine gate update; CRITICAL role naming discrepancy (`app_role` enum uses `facility_admin`, not `owner` as documented in ADRs); `users.created_by` column missing; 3 ADR 0010 table name mismatches vs. actual schema.
- Created audit task doc `0026-provisioning-readiness-audit.md` in tasks/active.
- Created backlog task candidates: `0027-provisioning-schema-and-rls-migrations.md`, `0028-provisioning-api-endpoint.md`, `0029-activation-endpoint-and-page.md`, `0030-crm-ui-provisioning-integration.md`, `0031-tracker-auth-frontend-changes.md`, `0032-provisioning-tests.md` in tasks/backlog.
- Updated `ai_memory.md`: added 8 new provisioning implementation blockers section.
- Changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed.

## 2026-05-19 (task 0025 — accept ADR 0010)

- ADR 0010 (pending setup facility RLS policy) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md`, `data_model.md`, `compliance_notes.md`, and `ai_memory.md` proposed references updated in both mirrors. Task doc `0025-accept-adr-0010.md` created in done. No application code changed.

## 2026-05-19 (task 0024 — ADR 0010 architecture review)

- Architecture review of ADR 0010 (pending setup facility RLS policy — status: proposed). Recommendation: **Accept with minor edits** (edits applied in this task).
- No conflicts with ADR 0005/0006/0007/0008/0009 or compliance_notes.md found. All seven review focus areas passed. Documentation consistency confirmed (ADR 0009, data_model.md, compliance_notes.md, ai_memory.md, decisions/README.md all correct and consistent).
- One documentation defect found and fixed: "encapsulates conditions 1 and 2" in the Care-Ops Table RLS Rule prose was misleading — the helper encapsulates condition 2 only; condition 1 (`facility_id = current_facility_id()`) must be a separate USING clause condition. Incorrect prose could cause an implementer to omit the tenant isolation check. Fixed in `decisions/0010-pending-setup-facility-rls-policy.md` and mirrored to `ai-workspace-framework`. Companion Usage note for `is_active_user_on_active_facility()` also updated to make the required companion condition explicit.
- ADR 0010 status remains `proposed` pending explicit user acceptance. No application code changed.

## 2026-05-19 (task 0023 — ADR 0010: pending setup facility RLS policy)

- Architecture/design documentation task. Created ADR 0010 (pending setup facility RLS policy — status: proposed) resolving the RLS blocker identified in ADR 0009 Open Implementation TODOs.
- Decision: quarantine model (Option A). All care-ops tables require both `User.account_status = 'active'` AND `Facility.provisioning_status = 'active'` for any client access. `invited`/`password_pending` users have no Supabase session (ADR 0007 — auth user created at activation time); RLS is a defensive layer. `ProvisioningToken` and `ProvisioningEvent` have zero client-accessible policies (default deny). `pending_setup → active` transitions atomically (ADR 0009); no `setup_incomplete` intermediate state. No residents may be created before facility is active. Limited setup mode (Option B) excluded as infeasible under ADR 0007 activation model. `suspended` read-only policy deferred to billing/suspension feature task.
- ADR 0010 documents: facility and user account state access matrices; full care-ops table list; setup-safe table access (`users` self-read, `facilities` setup fields); activation transaction expectations and atomicity requirement; suspended/closed facility notes; family access implications (5 constraints); audit/provisioning event implications; `is_active_user_on_active_facility()` and `current_facility_id()` helper function specs; new table policies summary; 10 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0010 row.
- Updated `decisions/0009-tracker-facility-creation-during-crm-provisioning.md`: annotated RLS TODO as addressed by ADR 0010; updated `provisioning_status` lifecycle RLS note.
- Updated `data_model.md`: added provisioning-state RLS note to security section; updated ProvisioningToken and ProvisioningEvent access control paragraphs with ADR 0010 references.
- Updated `compliance_notes.md`: added provisioning-state RLS row to Data Handling Posture table.
- Updated `ai_memory.md`: narrowed pending_setup RLS blocker entry to reflect ADR 0010 (proposed) addressing it.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. No Supabase schema changes.

## 2026-05-19 (task 0022 — accept ADR 0009)

- ADR 0009 (tracker Facility record creation during CRM provisioning) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md`, `data_model.md`, `features.md`, `user_flows.md`, and `ai_memory.md` proposed references updated in both mirrors. Task doc `0022-accept-adr-0009.md` created in done. No application code changed.

## 2026-05-19 (task 0021 — ADR 0009 architecture review)

- Architecture review of ADR 0009 (tracker Facility record creation during CRM provisioning — status: proposed). Recommendation: **Accept with minor edits** (edits applied in this task).
- No conflicts with ADR 0005/0006/0007/0008 or compliance_notes.md found. All seven review focus areas passed. Documentation consistency confirmed across all 10 updated files.
- Two behavioral edge cases were undocumented — added as TODOs in ADR 0009 Open Implementation TODOs: (1) retry payload conflict behavior (same `X-CRM-Facility-Id`, different `facility_name`) must be specified before implementation; (2) re-provision when `User.account_status = disabled` (revoked invitation) must be specified before implementation.
- ADR 0008 Authorization Scope table row 1 updated: description now includes Facility creation per ADR 0009.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. ADR 0009 status remains `proposed` pending explicit user acceptance.

## 2026-05-19 (task 0020 — ADR 0009: tracker Facility creation during CRM provisioning)

- Architecture/design documentation task. Created ADR 0009 (tracker Facility record creation during CRM provisioning — status: proposed) resolving the facility creation timing blocker deferred in ADR 0007 Step 3a and ADR 0008 request contract.
- Decision: The tracker provisioning API call creates the tracker `Facility` record in `pending_setup` state atomically with the `User` row and `ProvisioningToken`. Allowed CRM-to-tracker facility fields: `facility_name`, `facility_city`, `facility_state`, `license_number` (optional). `Facility.capacity`, subscription resident limit, and allocated resident count are NOT forwarded at provisioning time. Idempotency keyed on `Facility.crm_facility_reference` UNIQUE constraint (= `X-CRM-Facility-Id`). Facility transitions `pending_setup → active` on owner activation.
- ADR 0009 documents: 3 options evaluated (pre-exist, created by provisioning call, created at activation); full facility creation/provisioning sub-sequence; allowed and excluded CRM-to-tracker fields; Facility status lifecycle (pending_setup → active → suspended → closed); idempotency and duplicate prevention; four distinct resident count concepts defined and separated; audit/event requirements (no new ProvisioningEvent types added); 9 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0009 row.
- Updated `decisions/0007-crm-owner-provisioning-token-mechanism.md`: resolved Facility creation TODO in Step 3a and Open Implementation TODOs with ADR 0009 reference.
- Updated `decisions/0008-crm-to-tracker-provisioning-api-authentication.md`: replaced facility association dependency note with resolved facility field table (facility_name, facility_city, facility_state, license_number).
- Updated `data_model.md`: added `provisioning_status` and `crm_facility_reference` fields to Facility entity; added FacilityProvisioningStatus enum; added four resident count concepts table.
- Updated `features.md`: resolved facility creation TODO in CRM Owner account provisioning section; added ADR 0009 reference.
- Updated `user_flows.md`: resolved facility creation TODO in Flow 0 Step 4; updated post-activation Step 8 to reflect pending_setup → active transition.
- Updated `ai_memory.md`: resolved facility creation timing blocker in the CRM open questions section; added ADR 0009 entry.
- Updated `compliance_notes.md`: extended CRM data boundary row with facility fields boundary and resident count concept distinctions.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. No Supabase schema changes.

## 2026-05-19 (task 0019 — accept ADR 0008)

- ADR 0008 (CRM-to-tracker provisioning API authentication) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md`, `ai_memory.md`, and `data_model.md` proposed references updated in both mirrors. Task doc `0019-accept-adr-0008.md` created in done. No application code changed.

## 2026-05-19 (task 0018 — ADR 0008 architecture review)

- Architecture review of ADR 0008 (CRM-to-tracker provisioning API authentication — status: proposed). Recommendation: Accept with minor edits.
- No conflicts with ADR 0005/0006/0007 or compliance_notes.md found. All boundary checks passed. All documentation consistency checks passed. All 7 open TODOs correctly flagged.
- Three documentation gaps fixed in ADR 0008 (both mirrors): (1) added owner role note — CRM-provisioned accounts always receive `role = owner`, server-enforced; (2) added facility association dependency note cross-referencing ADR 0007's facility TODO; (3) added "Intentionally excluded fields" note for `phone` (collected at activation) and `allocated_resident_count` (CRM-side concept).
- ADR 0008 status remains `proposed`. Post-acceptance cleanup documented in task 0018 Outcome. No application code changed.

## 2026-05-19 (task 0017 — ADR 0008: CRM-to-tracker provisioning API authentication)

- Architecture/design documentation task. Created ADR 0008 (CRM-to-tracker provisioning API authentication — status: proposed) resolving the authentication blocker deferred in ADR 0007.
- Decision: rotating static API key (MVP). CRM stores raw key server-side in Vercel env vars (`CRM_TRACKER_PROVISIONING_KEY`); tracker stores only SHA-256 hash(es) of valid keys. Zero-downtime rotation via versioned key slots (V1/V2). Phase 2 hardening: HMAC-signed short-lived service JWT. ADR 0007 service-role key (Option A) remains rejected.
- ADR 0008 documents: 5 options evaluated (static API key, HMAC JWT, asymmetric JWT, OAuth2 client credentials, mTLS); full authentication flow for MVP and Phase 2; secret storage and rotation procedure; least-privilege scope table; request contract (5 required headers + body schema); response contract (opaque `provisioning_reference` + `status` only); idempotency keyed on `X-Idempotency-Key` (24h TTL); two-layer replay prevention (timestamp window ±5 min + idempotency key deduplication); audit/logging requirements (key version logged, raw key never logged); 7 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0008 row.
- Updated `decisions/0007-crm-owner-provisioning-token-mechanism.md`: resolved CRM-to-tracker API auth TODO with ADR 0008 reference.
- Updated `ai_memory.md`: resolved CRM-to-tracker API authentication open question (both the standalone bullet and the CRM provisioning mechanism entry).
- Updated `data_model.md`: added ADR 0008 reference note to User entity provisioning mechanism paragraph.
- Updated `compliance_notes.md`: added CRM-to-tracker provisioning API authentication row to Data Handling Posture table.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No application code changed. No Supabase schema changes.

## 2026-05-18 (task 0016 — accept ADR 0007)

- ADR 0007 (CRM owner provisioning token mechanism) accepted. Status updated from `proposed` to `accepted` in both mirrors. `decisions/README.md` updated in both mirrors. Task doc `0016-accept-adr-0007.md` created and placed in done. No application code changed.

## 2026-05-18 (task 0015 — ADR 0007 architecture review)

- Architecture review of ADR 0007 (CRM owner provisioning token mechanism — status: proposed). Recommendation: Accept with minor edits. No conflicts with ADR 0004, 0005, or 0006 found. CRM/tracker boundary confirmed intact.
- Three findings requiring edits before acceptance: (1) activation sequence lacked explicit atomicity requirement — fixed in ADR 0007 Phase 2 step 8c (SELECT FOR UPDATE + transaction spanning steps 8c–8i); (2) `token_expired_passive` event type was in the ENUM but missing from Audit/Event Requirements table — added row with background-job requirement and remove-if-not-built note; (3) partial activation recovery (Supabase createUser success + later failure) was unaddressed — added as Open Implementation TODO.
- Two stale TODOs cleaned up in `user_flows.md`: Flow 0 step 5 (expiry/resend/revocation now resolved by ADR 0007) and CRM Flow A step 7 (provisioning mechanism now resolved by ADR 0007). One stale TODO block cleaned up in `features.md` (same).
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. ADR 0007 status remains `proposed` — pending explicit user acceptance. No app code changed. No Supabase schema changes.

## 2026-05-18 (task 0014 — CRM owner provisioning token mechanism, ADR 0007)

- Architecture/design documentation task. Created ADR 0007 (CRM owner provisioning token mechanism — status: proposed) selecting Option B (custom `provisioning_tokens` table) over Supabase Auth invite API. Rationale: Supabase invite API requires CRM to hold tracker service-role key, violating ADR 0005 CRM/tracker boundary; custom table gives full lifecycle auditability and defers Supabase Auth user creation to activation time.
- ADR 0007 specifies: 32-byte hex opaque token, SHA-256 hashed storage, 72h expiry, one-time use, constant-time lookup, four-phase sequence (provision → activate → resend → revoke), `ProvisioningEvent` append-only audit table, CRM provisioning fields (`provisioning_reference`, `provisioning_status`), deep-link routing behavior, full token security model, and 10 open implementation TODOs.
- Updated `decisions/README.md`: added ADR 0007 row; corrected ADR 0006 status from Proposed to Accepted.
- Updated `data_model.md`: promoted `ProvisioningToken` from "TODO — Conceptual" to fully specified (ADR 0007); updated account_status TODO to note mechanism resolved; added `ProvisioningEvent` new entity (append-only audit); added CRM provisioning fields note to CRM entity model section.
- Updated `ai_memory.md`: narrowed CRM provisioning mechanism open question (resolved to ADR 0007 Option B); retained iOS/Android deep-link TODO; added CRM-to-tracker API authentication as new open question.
- Updated `user_flows.md`: updated Flow 0 step 4 TODO to reference ADR 0007 mechanism decision.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No app code changed. No Supabase schema changes. No deployment.

## 2026-05-18 (ADR 0006 accepted — CRM owner provisioning and family account approval)

- ADR 0006 status updated from `proposed` to `accepted` in both mirrors. Removed `(proposed)` qualifiers from ADR 0006 references in `compliance_notes.md` in both mirrors. Created task doc `0013-accept-adr-0006.md` and moved to done.

## 2026-05-18 (ADR 0006 review — CRM owner provisioning and family account approval)

- Architecture review of ADR 0006 (proposed). Recommendation: Accept with minor edits. No conflicts found with ADR 0004 or ADR 0005. One documentation gap fixed: added five missing optional FamilyUser fields from ADR 0006 Section 6 (occupation, facility_association, emergency_contact_role, privacy_release_status, resident_access_request) as TODO entries in `data_model.md` FamilyUser entity table — mirrored to ai-workspace-framework. ADR 0006 status remains `proposed` pending explicit user acceptance.

## 2026-05-18 (task 0012 — CRM owner provisioning and family account flow)

- Documentation-only task. Created ADR 0006 (CRM owner provisioning and family account approval — status: proposed, requires human review before accepted) in both mirrors. Updated ADR 0005 Section 4 (resolved the CRM-to-tracker provisioning handshake TODO with a 7-step conceptual flow). Updated `decisions/README.md` (added ADR 0006 row; clarified app delivery model ADR remains pending).
- Rewrote `user_flows.md` Flow 0 (CRM onboarding + owner activation deep link with 3 routing cases), CRM Flow A Step 7 (provisioning action), and Family Member Onboarding (split into Phase A identity-only account creation and Phase B owner/admin approval). Added new Flow 14 (Owner/Admin Family Access Management: pending/active/revoked grant views, proactive initiation).
- Updated `features.md`: added CRM owner account provisioning to Conceptual/TODO section; updated onboarding milestones; rewrote Family User Eligibility to reflect FamilyUser self-signup (account ≠ data access); added Owner/Admin Family Access Management subsection; updated Role Permissions Summary table to distinguish FamilyUser-no-consent from FamilyUser-with-active-grant.
- Updated `overview.md`: CRM surface description now includes owner account provisioning (forward write only); Family Member App description updated with FamilyUser account creation model and ADR references.
- Updated `data_model.md`: added `account_status` field and AccountStatus enum to User entity; added ProvisioningToken conceptual entity (opaque/expiring/one-time-use token security properties); added FamilyUser entity (identity-only, NOT User table, NOT FamilyAccessConsent); updated FamilyAccessConsent to link via `family_user_id` (not contact_id).
- Updated `ai_memory.md`: narrowed CRM provisioning handshake open question (conceptual flow resolved; implementation mechanism still open); added iOS Universal Links / Android App Links TODO; added Supabase Auth invite API compatibility TODO; added FamilyUser self-registration vs. invite-only and rejection behavior TODOs.
- Updated `compliance_notes.md`: added FamilyUser pre-approval account language (no data access granted by account existence); added CRM forward-write-only boundary note; added owner activation token security row to Data Handling Posture table.
- All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`. No app code changed. No Supabase schema changes. No deployment.

## 2026-05-17 (task 0011 — CRM facility management)

- Implemented CRM facility create, edit, archive, and allowable resident count management.
- **New files:** `src/store/useCrmStore.ts` (Zustand session store for CRM: facilities, communications, notes, followUps — initialized from seed, not persisted); `src/pages/crm/FacilityFormModal.tsx` (shared modal for create and edit with full CRM field set and positive-integer validation for allowedResidentCount).
- **Modified files:** `src/types/crm.ts` (added `archived`, `archivedAt` to `CrmFacility`); `src/pages/crm/CrmFacilities.tsx` (connected to store, added "Add facility" button, allowable resident count column, archived toggle, post-create navigation); `src/pages/crm/CrmFacilityDetail.tsx` (connected to store, added edit modal, archive confirmation dialog, archived-state banner, all actions routed through store); `src/pages/crm/CrmDashboard.tsx` (connected to store, all counts filter archived facilities).
- Data boundary confirmed: no resident care types imported in CRM files. No Supabase schema/migration changes.
- Build passed clean (`tsc && vite build`). Task doc created in both mirrors: `tasks/active/alh-tracker/0011-crm-facility-management.md`.
- Updated `features.md` (Internal CRM section expanded from stub to implemented spec), `data_model.md` (CRM entity model section updated with actual field definitions), `ai_memory.md` (allowable resident count open question partially resolved), `README.md` (internal CRM section added).
- Subagents: not used for implementation (store → pages is a sequential dependency chain). Documentation mirror writes were parallelized within the main agent.

## 2026-05-17 (task 0010 — Internal CRM MVP — smoke test verification)

- Ran smoke test on dev server (`npm run dev`): all required routes returned 200 OK — `/crm`, `/crm/facilities`, `/crm/facilities/crm-fac-001`, `/`, `/family`.
- Code review confirmed: CRM pages render without blank screens; search/filter (CrmFacilities) functional; add note, add follow-up, mark follow-up done, add communication log entry (CrmFacilityDetail) all functional; no resident care types imported in any CRM file.
- Checked off smoke test item in task 0010 acceptance criteria. Moved `tasks/active/alh-tracker/0010-internal-crm-mvp.md` to `tasks/done/alh-tracker/0010-internal-crm-mvp.md` in both mirrors.
- Data boundary confirmed: CRM files import no resident care types. CRM uses fake/demo data only.
- No Supabase schema changes. No deployment changes. Build passed clean (`tsc && vite build`).

---

## 2026-05-17 (task 0010 — Internal CRM MVP — implementation)

- Built first usable internal CRM surface as a separate route tree (`/crm`) in the existing React/Vite app.
- Architecture decision: CRM implemented in this repo as a separate surface, matching the family portal pattern (`/family`), consistent with ADR 0005. No conflict with docs.
- **New files:**
  - `src/types/crm.ts` — CRM-specific TypeScript types (CrmFacility, CrmOnboardingStage, CrmSubscriptionStatus, CrmCommunicationEntry, CrmNote, CrmFollowUp, etc.). Explicitly separate from resident/care types.
  - `src/data/crm-seed.ts` — 7 demo/fake facilities with communications, notes, and follow-ups. No real data.
  - `src/components/CrmLayout.tsx` — dark-slate desktop sidebar layout, separate from facility tracker Layout; internal-only warning banner on every screen; TODO auth badge.
  - `src/pages/crm/CrmDashboard.tsx` — pipeline summary counts, onboarding counts, open follow-up list, priority notes, facilities table.
  - `src/pages/crm/CrmFacilities.tsx` — facilities list with search and subscription status filter.
  - `src/pages/crm/CrmFacilityDetail.tsx` — facility profile, owner contact, onboarding checklist, follow-up management (add/mark done), support notes (add/edit), communication log (add entry). All local state / demo only.
- **Modified files:**
  - `src/App.tsx` — added `/crm`, `/crm/facilities`, `/crm/facilities/:id` routes under CrmLayout. CRM auth is TODO per ADR 0005; route is unguarded in demo prototype mode.
- CRM data boundary enforced: CRM files import no resident care types (CareLogEntry, Resident, WellnessObservation, FollowUp) from `src/types/index.ts`.
- No Supabase schema changes. No real payment processing. No resident care data in CRM views.
- Build passed clean (`tsc && vite build`).
- Task doc created: `tasks/active/alh-tracker/0010-internal-crm-mvp.md` (mirrored to ai-workspace-framework).

---

## 2026-05-16 (documentation review and task queue cleanup)

- Ran four-subagent documentation review: Documentation Inventory, Product/Business, Compliance/Data Boundary, and Task Queue reviewers.
- **overview.md:** Added compliance caveats to product mantra ("positioning goal — no compliance claims without counsel review"), Later Expansion MAR/eMAR-adjacent language (separate legal review required), and "Daily care visibility" phrase (pending Phase 2 counsel review). Updated Pinned Versions section with actual selected tech stack (React 18 + TypeScript, Vite, Tailwind CSS, Zustand, React Router v6, Supabase).
- **compliance_notes.md:** Updated "Current Prototype State" table to note it has been superseded by Supabase production backend; added current status notes per control; added hard "blocked on counsel review" requirement to family-to-facility communications TODO.
- **features.md:** Updated stale "uses localStorage with no authentication" prototype state note to reflect Supabase migration.
- **tasks/active/0001:** Checked off ADR 0003 (created 2026-05-09) and shared onboarding/billing decision (ADR 0003 + ADR 0005) as complete. Added "blocked on external execution (task 0002)" note for remaining items.
- **tasks/active/0004:** Updated documents list — ToS draft reference corrected from "not yet written" to reference `tos_draft_for_counsel.md` (created 2026-05-10).
- **tasks/backlog/README.md:** Updated Phase 0 task status table to reflect actual queue state (tasks 0001/0002/0004/0006/0008 are active; 0003/0005/0007 remain in backlog). Added new tasks 0009/0010/0011 to table.
- **decisions/README.md:** Replaced stale "Expected First ADRs" with actual ADR table (ADRs 0001–0005, all accepted) and updated pending ADR list.
- **ai_memory.md:** Corrected "git master" to "git main". Added HIGH RISK label and task 0009 reference to retention and deletion policy section.
- **New task 0009:** `tasks/backlog/0009-data-retention-policy.md` — pre-commercial-launch blocker; defines retention periods, account closure procedure, Supabase PITR alignment.
- **New task 0010:** `tasks/backlog/0010-crm-design-open-questions.md` — resolves 9 open questions from ADR 0005 before CRM design begins.
- **New task 0011:** `tasks/backlog/0011-resident-profile-data-model-expansion.md` — defines expanded resident entity designs to unblock task 0005.
- No app code changed. No schema changes. No deployment.

---

## 2026-05-11 (session 10 — UI redesign for caregiver clarity)

- Redesigned 6 of 7 app pages for caregiver clarity. Guiding principles: urgent-first, one purpose per page, primary action obvious, reduce competing cards, caregiver language.
- **Dashboard.tsx** — full rewrite. Removed 5 separate alert cards. Replaced with one unified "Needs attention today" section listing all alert types (missed transport, not returned, room not made up, high follow-ups, wellness concerns, normal follow-ups, upcoming transport) in a single prioritized list with colored dots. Green "All looking good" card when nothing needs attention. Secondary stats row (4 cols) and simplified Quick Access (5 rows, no descriptions).
- **Residents.tsx** — added per-resident alert badges (severe allergy, allergy on file, open follow-ups count, room not made up, transport attention) computed per card in the map callback from store slices.
- **ActivityLog.tsx** — renamed form title to "Log a care observation"; added numbered step labels (1. Who? / 2. What type? / 3. How did it go? / 4. Note) to the 4-step form flow.
- **WellnessObservations.tsx** — renamed form title to "Record a wellness observation"; added numbered step labels (1. Who? / 2. What area? / 3. How are they doing? / 4. Note) to the form flow.
- **FollowUps.tsx** — removed priority filter row (all/high/normal/low buttons removed; `priorityFilter` state retained at 'all' but no UI to change it). Resolved items rendered at `opacity-55` to visually quiet them.
- **HandoffSummary.tsx** — replaced dark brand-colored stats header with clean 3-col white stats grid (entries today, exceptions, open follow-ups) with red highlight when nonzero. Added conditional "Shift alerts" amber callout block for missed pickups/not returned/incomplete rooms. Replaced verbose amber disclaimer with quieter border-only box. Added per-resident room check and transport sections (already present from Phase 4).
- ResidentDetail.tsx not changed — structure already aligned with redesign goals.
- Build passed clean (`tsc && vite build`). Committed as `221fe19` ("Simplify app UI for caregiver clarity"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md`, `ai_memory.md`, `execution_log.md` (this entry).

---

## 2026-05-11 (session 9 — Phase A demo-only banner)

- Added fixed amber "Demo only" warning banner to `src/components/Layout.tsx`: displays at the bottom of every screen on all device sizes. Text: "Demo only — do not enter real resident data." Amber background (`bg-amber-50`), amber border, amber icon (`AlertTriangle`), amber text. `z-20` fixed positioning — does not conflict with sidebar (no z-index) or mobile drawer (z-40).
- Added `pb-10` to main content wrapper to prevent page content from being hidden behind the banner.
- Build passed clean. Committed as `fa8577a` ("Add demo-only warning banner"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md` (prototype status note with commit hash), `ai_memory.md` (Phase A session 9 entry), `execution_log.md` (this entry).

---

## 2026-05-11 (session 8 — security and privacy architecture plan)

- Produced security and privacy implementation plan for alh-tracker based on review of all 7 project context files plus current app source (store, types, seed, App.tsx, package.json).
- Confirmed current prototype security state: no authentication, no authorization, all data in browser localStorage (plaintext), no backend, hardcoded seed user. Seed data for 8 named residents persists in any browser that visits alh-tracker.vercel.app. Prototype is demo-only.
- Updated `compliance_notes.md`: added "Security and Privacy Implementation Posture" section covering current prototype state table, data classification by sensitivity, required security architecture (authentication, RBAC, tenant isolation, AuditTrail, session/device security, password/MFA policy, user deactivation), data protection requirements (encryption, localStorage risk and replacement plan, secrets management, backups, export controls, deletion/retention), HIPAA-adjacent risk assessment, 15-item must-have checklist, and 7 open security/privacy counsel questions.
- Updated `data_model.md`: added security notes block in preamble (tenant isolation requirement, sensitive data categories, encryption, AuditTrail integrity, localStorage prototype-only note); extended AuditTrail entity note with database-level write-once constraint requirement and identity preservation requirement.
- Updated `features.md`: added "Production Security Prerequisites" section (15-item checklist of controls required before real data, with reference to compliance_notes.md for full detail).
- Updated `tos_draft_for_counsel.md`: added Section 10 (Security Controls, Access, and Data Handling Standards) with 7 PENDING COUNSEL questions (Q-S1 through Q-S6) covering HIPAA Security Rule safeguards, California law security obligations, SOC 2 certification, breach notification timeline, caregiver identity retention, and audit log compliance claim risk; updated open issues table with Section 10 rows.
- Updated `ai_memory.md`: added dated security planning entry summarizing key findings, must-have controls, and open questions.
- No app code changed. No deployment.

---

## 2026-05-11 (session 7 — data model doc cleanup)

- Fixed duplicate `ResidentContact` definition in `projects/alh-tracker/data_model.md`. The file contained two definitions: the implemented operational entity added in Phase 4 (Entities section) and the original family-access stub (Family Access Stub section). Removed the stub definition. Updated the Family Access Stub preamble to reference the canonical ResidentContact in the Entities section and clarify that: having a ResidentContact record does not authorize family portal access; `hipaa_release_status` is operational tracking only and not legal validation or portal consent; `FamilyAccessConsent.contact_id` will reference the canonical entity when built. Updated `FamilyAccessConsent` to note it is not yet implemented and is blocked on counsel review (task 0006). One `ResidentContact` definition now exists in the file.

---

## 2026-05-11 (session 7 — Phase 4 app build)

- Added 5 new operational features to the live alh-tracker MVP: Preferences, Main Contact / HIPAA Release Status, Allergies & Triggers, Room Made Up / Sheets checklist, and Transport Pickup for Appointment.
- Modified `src/types/index.ts`: added `HipaaReleaseStatus`, `PickupStatus`, `ReturnStatus` type literals; added `ResidentPreferences`, `ResidentContact`, `AllergiesTriggers`, `RoomChecklist`, `AppointmentTransport` interfaces; added label constant records for all three new enums.
- Modified `src/data/seed.ts`: added `tomorrow()` helper; added `SEED_PREFERENCES`, `SEED_CONTACTS`, `SEED_ALLERGIES`, `SEED_ROOM_CHECKLISTS`, `SEED_APPOINTMENT_TRANSPORTS` seed exports for all 8 residents.
- Rewrote `src/store/useStore.ts`: added 5 new state collections and 6 new store actions (`upsertPreferences`, `upsertContact`, `upsertAllergies`, `upsertRoomChecklist`, `addAppointmentTransport`, `updateAppointmentTransport`).
- Rewrote `src/pages/ResidentDetail.tsx`: added Profile tab (4th tab) with inline-editable sections for Allergies & Triggers, Room Check Today, Transport & Appointments, Main Contact & HIPAA, Preferences. Added allergy warning banner below the resident header card, visible on all tabs.
- Modified `src/pages/ActivityLog.tsx`: added allergy warning banner when a resident with documented allergies is selected.
- Modified `src/pages/Dashboard.tsx`: added operational alerts section above the follow-ups/concerns grid — shows incomplete rooms and missed/upcoming/not-returned transport appointments.
- Modified `src/pages/HandoffSummary.tsx`: added room check and transport status sections to each per-resident card in the handoff.
- Build passed clean (`tsc && vite build` — no errors). Committed as `edaa187` ("Add resident profile operations fields"). Deployed to Vercel production: https://alh-tracker.vercel.app.
- Updated `features.md`, `data_model.md`, `user_flows.md`, `ai_memory.md`, `execution_log.md`.

---

## 2026-05-11 (session 6)

- Fixed two broken relative links in `projects/alh-tracker/next_7_days_owner_checklist.md`: Item 3 (counsel packet link) and Item 6 (Task 0008 link) both used `../../ai-workspace-framework/...` — corrected to `../../../ai-workspace-framework/...` to resolve from the file's directory to `C:\Projects\ai-workspace-framework\`.
- Updated `projects/alh-tracker/phase_0_owner_action_packet.md` Action 5: added explicit reference to the AI-Assisted Technical Review Note in Task 0008 (added Session 4, 2026-05-10); clarified that AI review does not satisfy acceptance criterion 6. Updated "Document last updated" to reflect Session 4/5 actual update date (2026-05-10).
- Updated `projects/alh-tracker/ai_memory.md` with session 6 maintenance note.

---

## 2026-05-10 (session 5)

- Verified Session 4 cross-references. Found one gap: `design_partner_tracker.md` not referenced in `phase_0_owner_action_packet.md`. Fixed in three places: Action 1 checklist, Section 3A Step 3, and Section 3B outreach tracker paragraph.
- Added counsel email cover note to `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: covers the routing ask, lists five documents to attach, articulates Priority 1 Q1–Q4 ask and Phase 2 Q5–Q10 ask. Labeled preliminary / not legal advice throughout. No content changed in other sections.
- Created `projects/alh-tracker/next_7_days_owner_checklist.md`: six operational items (warm list, CCLD verification, counsel routing, first outreach, $49/month rate confirmation, TA review scheduling). Each item has exact time estimate, source file reference, and completion signal. No strategic content.
- Updated `projects/alh-tracker/ai_memory.md` with Session 5 verification findings and additions.

---

## 2026-05-10 (session 4)

- Conducted Phase 0 state assessment: confirmed complete items (4 ADRs, task 0002 planning, task 0004 desk research, task 0008 spec), active tasks (0001/0002/0004/0006/0008), and hard-blocked tasks (0003/0005/0007). No task statuses changed — no acceptance criteria were newly satisfied this session.
- Created `projects/alh-tracker/design_partner_tracker.md`: candidate list pre-seeded from third-party directory data (seniorguidance.org for Temecula and Menifee; aplaceformom.com for Murrieta). 36+ candidate rows across Temecula (14), Murrieta (17), Menifee (8), and adjacent geography (Wildomar). Includes scoring guide, CCLD verification instructions, outreach status key, and a Section A placeholder for owner-supplied ALH warm contacts. Key finding: area is dominated by 6-bed homes; no 10–16 capacity facilities identified in public data. All rows require CCLD verification before outreach.
- Created `projects/alh-tracker/tos_draft_for_counsel.md`: preliminary draft ToS / data handling addendum for counsel review. Nine sections covering vendor role, record ownership, retention (with counsel-answer placeholders), account closure and record disposition, export/return/deletion rights, HIPAA BAA posture (explicitly unresolved), no compliance certification, data security / breach notification, and amendment process. Open issues table maps each unresolved provision to the specific counsel question. Labeled clearly as draft only — not legal advice.
- Updated `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: updated supporting documents table row for ToS draft to reference the new file.
- Updated `projects/alh-tracker/phase_0_owner_action_packet.md`: marked ToS draft checklist item as complete; referenced `tos_draft_for_counsel.md`.
- Updated `tasks/active/alh-tracker/0008-device-and-offline-behavior.md`: added AI-Assisted Technical Review Note section. Reviewed IndexedDB queue, offline banner, reconnect sync, conflict flagging, no Background Sync dependency, and minimum browser targets. All confirmed technically coherent. Added 4 implementation notes (service worker registration, IndexedDB schema versioning, stale-while-revalidate cache behavior, 200-entry queue capacity). No blocking issues. Human TA still required to satisfy acceptance criterion 6.
- Updated `projects/alh-tracker/ai_memory.md`: added task 0008 TA review note, design partner tracker creation, and ToS draft creation.

---

## 2026-05-09 (session 3)

- Created `projects/alh-tracker/phase_0_owner_action_packet.md`: owner-facing Phase 0 action guide consolidating status snapshot (complete/active/blocked/do-not-start), 5-item owner action checklist ordered by leverage, design partner execution worksheet (candidate scoring table, outreach tracker, site visit questions organized by what they unblock: tasks 0003/0001/0006/0008), combined counsel routing checklist (task 0004 Priority 1 questions + task 0006 family access questions Q5–Q10), 4-ADR decision log summary, and explicit do-not-start gate list.

---

## 2026-05-09 (session 2)

- Fixed task 0002 formatting (`tasks/active/alh-tracker/0002-design-partner-criteria-and-outreach.md`): renamed LOI internal clause headers from "Section N" to "Clause N" to eliminate naming collision with the outer document's Section 8 (Candidate List); removed duplicate `---` separator; renamed Section 8 heading for clarity.
- Activated task 0006: created `tasks/active/alh-tracker/0006-family-access-architecture.md` with full architectural specification (family-resident association model, dual-authorization consent model, read-only/summary-default access scope, same-database row-level authorization, resident autonomy posture, 7-item open-questions register for counsel). Deleted `tasks/backlog/alh-tracker/0006-family-access-architecture.md`.
- Created `decisions/0004-family-access-architecture.md` (ADR, accepted): locks family access as read-only, summary-default, category-scoped, dual-acknowledgment, same-database, family contacts not User records, all access audited.
- Updated `data_model.md` family access stubs: ResidentContact — removed `is_authorized_viewer` (authorization is in FamilyAccessConsent), added `contact_type` enum and `is_active`; FamilyAccessConsent — renamed `scope` to `category_scope`, added `access_level` enum (summary/full_notes), added `resident_autonomy_noted` boolean nullable, added `resident_autonomy_notes` text, added `granted_by` role constraint note.
- Updated `compliance_notes.md`: added "Family Access and Consent Posture" section (clearly labeled preliminary / not legal advice / pending counsel review) covering what family access is and is not, resident autonomy posture, and 6 open counsel questions for Phase 2.
- Updated `ai_memory.md`: resolved family access open questions with architectural decisions from ADR 0004; replaced stale assumption entry; noted remaining Phase 2 blocks (counsel review, design partner validation, disclosure language).

---

## 2026-05-09 (session 1)

- Created `decisions/0003-business-model-alh-pricing.md` (ADR, accepted): locks ALH partner pricing as free during design partner + Phase 1 pilot, then $49/month add-on at commercial transition; documents no-shared-onboarding/billing policy at MVP; retains non-ALH price as working assumption ($149/month recommended, not validated).
- Updated task 0001 (`tasks/active/alh-tracker/0001-business-model-and-alh-relationship.md`): marked ALH partner policy, shared onboarding/billing recommendation, and full ADR checklist items as complete; narrowed remaining-to-close list to non-ALH validation and support model.
- Updated task 0002 (`tasks/active/alh-tracker/0002-design-partner-criteria-and-outreach.md`): added Section 8 — owner-execution candidate list checklist with CCLD search instructions, spreadsheet structure, ranking rules, and outreach sequencing (no internet access; public registry method only).
- Created `tasks/active/alh-tracker/0004-counsel-handoff-packet.md`: standalone 2-page counsel brief packaging all 9 priority questions from task 0004 Section 6, product description, what-it-is-not, and supporting document list. Clearly labeled as preliminary research / not legal advice.
- Updated task 0004 (`tasks/active/alh-tracker/0004-title-22-documentation-review.md`): marked counsel packet prepared; updated remaining-to-close to reference the packet file.
- Activated task 0008: created `tasks/active/alh-tracker/0008-device-and-offline-behavior.md` with full offline behavior spec (device tier matrix, offline detection, IndexedDB queue, pre-cached data, sync strategy, conflict resolution — flag for review, no auto-merge/discard, no Background Sync API dependency, minimum browser/OS requirements). Deleted `tasks/backlog/alh-tracker/0008-device-and-offline-behavior.md`.
- Updated `features.md`: added Offline Behavior Specification section (inline summary of task 0008 spec) to device support section.
- Updated `ai_memory.md`: resolved business model open questions (ADRs 0001-0003 all accepted); added task 0008 activation status; narrowed remaining open items to non-ALH price validation and Technical Architect confirmation of offline spec.

---

## 2026-05-05

- Created initial alh-tracker AI context framework scaffold: `overview.md`, `data_model.md`, `features.md`, `user_flows.md`, `compliance_notes.md`, `ai_memory.md`, `execution_log.md`, `decisions\README.md`.
- Created task directories with README files: `tasks\active\alh-tracker\`, `tasks\backlog\alh-tracker\`, `tasks\done\alh-tracker\`.
- Created eight backlog task documents: 0001 through 0008 covering business model, design partner, shift model, Title 22 review, data model, family access, logging UX, and device/offline behavior.
- Updated `ai-context\README.md` to add alh-tracker to the Projects Index and Start Here use-case table.
- Updated `ai-context\CHANGELOG.md` with v0.2 entry.
- Updated `ai-context\orchestration\context_rules.md` to generalize the Default Context Loading Sequence and add alh-tracker context file references.
- Conducted Phase 0 planning assessment: identified task dependencies, recommended activation order, and listed key owner-answered questions for tasks 0001–0004.
- Activated tasks 0001, 0002, and 0004: moved from `tasks\backlog\alh-tracker\` to `tasks\active\alh-tracker\`; updated status field to active and added planning notes in each task document reflecting strategic direction.
- Task 0003 (shift model and caregiver auth) remains in backlog pending design partner site visit from task 0002.
- Updated `projects\alh-tracker\ai_memory.md`: added working direction entry for business model, design partner profile, caregiver auth instinct, and Title 22 research posture.
- Worked task 0001 (business model and ALH relationship): wrote full recommendation covering standalone and partner pricing models, ALH relationship framing, data boundary, rollout phases, and risks/open questions. Updated plan checklist; 5 of 8 items complete. Created `decisions/0001-data-boundary-alh-tracker-vs-alh.md` and `decisions/0002-pricing-model-type.md`. Task 0001 remains active — ALH partner rate, non-ALH price validation, and shared workflow question still open. Updated `ai_memory.md` with task 0001 in-progress state.
- Worked task 0002 (design partner criteria and outreach): wrote full design partner profile (must-have criteria, nice-to-have, disqualifiers), outreach channel priority and candidate list strategy, outreach scripts, site visit discovery plan, LOI outline, validation checklist for tasks 0001 and 0003, and risk register. Plan checklist items 1–3 complete. Task 0002 remains active — candidate list build, outreach execution, site visit, committed partner, and LOI are required to close. Updated `ai_memory.md` with durable design partner strategy.
- Worked task 0004 (Title 22 documentation review): desk research complete on § 87506 (resident records, 3-year retention), § 87211 (incident reporting, licensee obligation), § 87465 (medication management, 1-year retention, MAR boundary), § 87411 (personnel records, caregiver identity). Produced full mapping table, data model preserve/omit/validate assessment, extended language avoidance list, required in-product disclosures, and structured counsel brief (9 questions in priority order). Plan checklist items 1–6 (desk research) complete. Task 0004 remains active — counsel review and sign-off required. Updated `compliance_notes.md` with preliminary research section (labeled). Updated `ai_memory.md` with Title 22 research status and refined retention policy open questions.

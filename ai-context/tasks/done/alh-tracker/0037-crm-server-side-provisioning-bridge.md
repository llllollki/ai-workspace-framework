# 0037 — CRM Server-Side Provisioning Bridge

Status: done
Created: 2026-05-21
Completed: 2026-05-21
Owner role: AI agent (main)
Depends on: 0028 (provision-owner Edge Function), 0036 (CRM UI provisioning integration)
Blocks: 0032 (provisioning tests)

## Goal

Implement the real browser-safe CRM-to-tracker provisioning bridge. The CRM UI calls a
server-side Vercel API function (`api/crm/provision.ts`) owned by the CRM/app deployment.
That function holds `CRM_TRACKER_PROVISIONING_KEY` exclusively server-side and forwards
calls to the tracker Supabase Edge Function. Replaces the demo-only simulation in
`src/lib/crmProvisioningAdapter.ts` as the main provisioning path.

## Subagent Policy

Proceeding serially. The bridge and adapter are tightly coupled (adapter interface must match
the bridge request contract), and the task is security-sensitive (secret handling). Single
workstream: no subagents warranted per workspace exception for tightly-coupled, design-sensitive tasks.

## Architecture

```
Browser (CRM UI)
  → POST /api/crm/provision
      (Vercel serverless function — api/crm/provision.ts)
      reads CRM_TRACKER_PROVISIONING_KEY from process.env [server-only]
      reads TRACKER_PROVISION_URL from process.env [Supabase Edge Function URL]
  → POST <TRACKER_PROVISION_URL>
      (supabase/functions/provision-owner/index.ts)
      validates Authorization: Bearer <key>
      executes provision/resend/revoke
  ← { provisioning_reference, status, email_delivered }
← { ok, provisioning_reference, provisioning_status, email_delivered }
```

The `CRM_TRACKER_PROVISIONING_KEY` is set as a Vercel environment variable on the CRM app
deployment. It never appears in browser code, client bundles, localStorage, or UI output.

## Acceptance Criteria

- [ ] Browser bundle contains no CRM_TRACKER_PROVISIONING_KEY value and no provisioning API secret.
- [ ] src/lib/crmProvisioningAdapter.ts no longer simulates successful provisioning as main path.
- [ ] CRM provision/resend/revoke buttons use real server-side bridge.
- [ ] Server-side bridge uses server-only env vars for tracker provisioning authentication.
- [ ] Returned data is CRM-safe: no tracker internal IDs, raw tokens, token hashes, resident data, service-role credentials.
- [ ] TypeScript passes with `npx tsc --noEmit` (existing command).
- [ ] Production build passes.
- [ ] Forbidden-string check run and reported.
- [ ] Task moved to done; ai_memory and execution_log updated.

## Plan

- [x] Create task document
- [x] Create `api/crm/provision.ts` — Vercel serverless bridge
- [x] Update `src/lib/crmProvisioningAdapter.ts` — call bridge, remove demo-simulate-success main path
- [x] Update `src/store/useCrmStore.ts` — pass city/state to provisionFacility adapter call
- [x] Update `.env.local.example` — document CRM_TRACKER_PROVISIONING_KEY and TRACKER_PROVISION_URL
- [x] Run `npx tsc --noEmit` — verify TypeScript (clean)
- [x] Run `npm run build` — verify production build (clean, 458.66 kB JS bundle)
- [x] Run forbidden-string grep — report result (see Outcome)
- [x] Move to done, update ai_memory, update execution_log

## Notes

### Vercel API function format

The project is a Vite SPA (`package.json "type": "module"`). Vercel auto-deploys files
in the `api/` directory as serverless functions. The `api/crm/provision.ts` function:
- Uses Node.js runtime (`IncomingMessage` / `ServerResponse`)
- Is excluded from `tsconfig.json` (`include: ["src"]`) — not checked by existing tsc command
- Exports `export default async function handler(req, res)`
- Uses `process.env.CRM_TRACKER_PROVISIONING_KEY` (server-side only; never bundled)

### Required headers forwarded to tracker

Per ADR 0008/0012, the bridge generates and forwards:
- `Authorization: Bearer <CRM_TRACKER_PROVISIONING_KEY>` — from server env
- `X-Request-Id` — fresh UUID per request
- `X-Idempotency-Key` — fresh UUID per request (retries handled by tracker's idempotency store via crm_facility_id)
- `X-CRM-Facility-Id` — from request body (CRM facility ID)
- `X-CRM-Actor-Id` — from request body (CRM staff placeholder)
- `X-Request-Timestamp` — fresh ISO 8601 timestamp per request

### Adapter signature change

`provisionFacility` payload gains `facilityCity` and `facilityState` (required by tracker).
The store action passes `facility.city` and `facility.state` from the CrmFacility record.
`allowedResidentCount` is dropped from the adapter payload (not sent to tracker per ADR 0009).

### Demo disclaimers

The 0036 demo notice banners in CrmFacilityDetail.tsx remain as-is. The adapter no longer
simulates success — it calls the bridge. If the bridge is not configured (missing env vars),
it returns 503 and the adapter propagates a clear error to the UI.

## Outcome

### Acceptance criteria met

- [x] Browser bundle contains no CRM_TRACKER_PROVISIONING_KEY **value** and no provisioning API
      secret. The string "CRM_TRACKER_PROVISIONING_KEY" appears once in the bundle as the env
      var **name** in a human-readable 503 error message for admins — this is not a secret value.
- [x] `src/lib/crmProvisioningAdapter.ts` no longer simulates successful provisioning as main path.
      All three functions call `/api/crm/provision` via `callBridge()`.
- [x] CRM provision/resend/revoke buttons use the real server-side bridge (adapter wired to bridge).
- [x] Server-side bridge (`api/crm/provision.ts`) reads `CRM_TRACKER_PROVISIONING_KEY` and
      `TRACKER_PROVISION_URL` exclusively from `process.env` — never passed to client.
- [x] Returned data is CRM-safe: bridge filters upstream response to `{ ok, provisioning_reference,
      provisioning_status, email_delivered }` only. No tracker IDs, tokens, token hashes,
      resident data, or service-role credentials returned.
- [x] TypeScript (`npx tsc --noEmit`) clean — no errors.
- [x] Production build (`npm run build`) clean — 458.66 kB JS bundle.
- [x] Forbidden-string check run and reported (see below).

### Forbidden-string check results

| Search term | src/ result | dist/ result |
|---|---|---|
| `CRM_TRACKER_PROVISIONING_KEY` | Name only in comments/error string — no value | Name in error message string only — no value |
| `SERVICE_ROLE` | No match | No match |
| `token_hash` | No match | No match |
| `activation_url` | No match | No match |
| `SUPABASE_SERVICE_ROLE` | No match | No match |

Result: PASS. No secrets, raw tokens, token hashes, or service-role credentials in browser code.

### Deliverables

1. **`api/crm/provision.ts`** (new) — Vercel serverless bridge. Reads
   `CRM_TRACKER_PROVISIONING_KEY` and `TRACKER_PROVISION_URL` from `process.env`. Validates
   request, generates ADR 0008 headers (X-Request-Id, X-Idempotency-Key, X-CRM-Facility-Id,
   X-CRM-Actor-Id, X-Request-Timestamp), forwards to tracker Edge Function, filters response
   to CRM-safe fields only. Returns 503 if env vars not configured.

2. **`src/lib/crmProvisioningAdapter.ts`** (updated) — Replaced demo-simulate-success stubs
   with real `fetch('/api/crm/provision', ...)` calls via `callBridge()`. Error cases return
   clear messages including 503 "bridge not configured" guidance. No secrets in this file.
   `provisionFacility` payload updated: added `facilityCity`, `facilityState`, `licenseNumber`;
   removed `allowedResidentCount` (not sent to tracker per ADR 0009).

3. **`src/store/useCrmStore.ts`** (updated) — `provisionFacility` action passes
   `facility.city`, `facility.state`, and `facility.rcfeLicensePlaceholder` to the adapter.

4. **`.env.local.example`** (updated) — Documents `CRM_TRACKER_PROVISIONING_KEY` and
   `TRACKER_PROVISION_URL` as Vercel environment variables with setup instructions.

### Notes

- The `api/crm/provision.ts` is a Vercel serverless function (Node.js runtime). It is excluded
  from `tsconfig.json` (`include: ["src"]`), so it is not checked by `npx tsc --noEmit`. This
  is expected — Vercel compiles API functions independently.
- In local development without `vercel dev`, the `/api/crm/provision` endpoint is unavailable.
  The adapter returns a network error. The CRM UI will show the error state. This is correct
  behavior — provisioning requires the Vercel deployment.
- The 0036 demo disclaimers in `CrmFacilityDetail.tsx` are preserved as-is. They remain accurate
  because the CRM data store is still session-only and the onboarding flow is still partial.
- `_provisioningReference` parameters on resend/revoke are unused — the tracker looks up the
  facility by `X-CRM-Facility-Id`. They are kept in the signature for future use or direct
  tracker API calls if the bridge interface evolves.

# 0028 — CRM Owner Provisioning: API Endpoint

Status: backlog
Created: 2026-05-19
Depends on: 0027 (schema + RLS migrations complete), blocker #1 (hosting model), blocker #2 (idempotency storage), blocker #3 (email service)
Blocks: 0029, 0030, 0032
Audit source: 0026

## Goal

Implement the `POST /api/provisioning/owner` server-side endpoint that the CRM calls
to provision, resend, and revoke tracker facility owner accounts. This is a greenfield
implementation — no API layer exists in the codebase today. The endpoint runs outside
the Supabase anon client layer and uses the Supabase service-role key server-side only.

## Pre-Implementation Decision Gate

Before any code is written, the following blockers must be resolved and documented
(in an ADR addendum or new ADR):

| Blocker | Options | Constraint |
|---|---|---|
| #1 Hosting model | Supabase Edge Function (recommended) vs Vercel API route | Vite SPA — not Next.js; Vercel API routes require framework migration or separate service. Supabase Edge Function is self-contained. |
| #2 Idempotency storage | Supabase `provisioning_idempotency_keys` table vs Upstash Redis | In-process memory is NOT safe for distributed serverless — excluded. |
| #3 Email service | Resend, SendGrid, Postmark, Supabase | Must support transactional emails; DKIM/SPF/DMARC must be configured for sender domain. |

## Scope

### Authentication Middleware

- Extract `Authorization: Bearer <api_key>` header.
- Compute SHA-256 hash of the received key.
- Constant-time compare with `CRM_API_KEY_V1_HASH` env var (use `crypto.timingSafeEqual`
  or Deno-equivalent — do NOT use string `===`).
- Reject with HTTP 401 generic error body on any mismatch.
- On `CRM_API_KEY_V2_HASH` env var presence, attempt comparison against V2 first, then V1
  (zero-downtime rotation per ADR 0008).

### Request Validation

Required headers (HTTP 400 on any missing):
- `Authorization` — Bearer token
- `X-Request-Id` — UUID v4 format
- `X-Idempotency-Key` — UUID v4 format
- `X-CRM-Facility-Id` — non-empty string
- `X-CRM-Actor-Id` — non-empty string
- `X-Request-Timestamp` — ISO 8601 UTC
- `Content-Type: application/json`

**Timestamp window check:**
- Parse `X-Request-Timestamp`.
- Reject with HTTP 401 if `|now - timestamp| > 5 minutes` (replay prevention).
- This check runs before idempotency store lookup.

**Body validation (for `provision` action):**
Required: `facility_name`, `facility_city`, `facility_state`, `owner_email`, `owner_name`, `action`
Optional: `license_number`
Reject with 400 on any missing required field or invalid `action` value.

### Idempotency

- After validation and timestamp check, look up `X-Idempotency-Key` in the idempotency
  store (TTL 24h).
- If found AND the stored request payload matches the current payload: return the stored
  response (HTTP 200/201 as originally returned).
- If found AND the stored request payload differs: return HTTP 409 Conflict.
- If not found: proceed with action logic; on success, store the key + payload + response
  with 24h TTL.

### `provision` Action

Atomic database transaction:
1. Check for existing `Facility` with `crm_facility_reference = X-CRM-Facility-Id`.
   - If found: return stored `provisioning_reference` + `status` (idempotent).
2. Insert `Facility`:
   - `name = facility_name`, `city = facility_city`, `state = facility_state`
   - `license_number = license_number` (if provided)
   - `provisioning_status = 'pending_setup'`
   - `crm_facility_reference = X-CRM-Facility-Id`
3. Insert `User`:
   - `email = owner_email`, `name = owner_name`
   - `role = <resolved role value — depends on blocker #5 resolution>`
   - `facility_id = new Facility.id`
   - `account_status = 'invited'`
4. Generate provisioning token:
   - 32 cryptographically random bytes → lowercase hex (64-char string)
   - Compute SHA-256 hash
   - Insert `ProvisioningToken`: `token_hash`, `facility_id`, `user_id`, `expires_at = now() + 72h`
5. Insert `ProvisioningEvent`: `event_type = 'provisioned'`, `actor_id = X-CRM-Actor-Id`,
   `request_id = X-Request-Id`, `facility_id`, `user_id`
6. Send activation email via selected email service (step 4 raw token embedded in URL).
   - URL format: `https://<tracker_domain>/activate?t=<raw_token>`
   - Email is sent AFTER the transaction commits to avoid sending before DB write.
   - If email send fails: log the error; do NOT roll back the DB transaction. Return 201
     with a flag indicating email delivery failed (CRM may retry via `resend` action).
7. Return HTTP 201: `{ "status": "provisioned", "provisioning_reference": "<new UUID>" }`

**Idempotency guarantee:** `crm_facility_reference` UNIQUE constraint prevents duplicate
Facility rows even if the idempotency key store is bypassed (e.g., key expired within 24h
but same facility ID is re-submitted).

### `resend` Action

1. Look up `Facility` by `crm_facility_reference = X-CRM-Facility-Id`.
   - 404 if not found.
2. Check `Facility.provisioning_status` — resend only valid for `pending_setup`.
   - Return 409 if status is `active`, `suspended`, or `closed`.
3. Expire all active `ProvisioningToken` records for this facility (`used_at = now()`).
4. Generate new `ProvisioningToken` (same process as provision step 4).
5. Insert `ProvisioningEvent`: `event_type = 'token_resent'`, `actor_id`, `request_id`.
6. Send new activation email.
7. Return HTTP 200: `{ "status": "token_resent", "provisioning_reference": "<existing UUID>" }`

### `revoke` Action

1. Look up `Facility` by `crm_facility_reference = X-CRM-Facility-Id`.
   - 404 if not found.
2. Expire all active `ProvisioningToken` records for this facility (`used_at = now()`).
3. Update `User.account_status = 'disabled'` for the facility owner.
4. Insert `ProvisioningEvent`: `event_type = 'token_revoked'`, `actor_id`, `request_id`.
5. Return HTTP 200: `{ "status": "revoked", "provisioning_reference": "<existing UUID>" }`

### Response Contract (enforced for all actions)

The response body must NEVER contain:
- Tracker `Facility.id` or `User.id`
- Raw provisioning token or `token_hash`
- Any resident, care log, wellbeing, audit trail, or family data
- `crm_facility_reference` echoed back
- Any stack trace or internal error detail

Error bodies: `{ "error": "unauthorized" }`, `{ "error": "bad_request" }`, etc. — generic.

### Failed Auth Burst Detection

- Track failed authentication attempts per source IP (or per `X-CRM-Actor-Id`) in a
  sliding 5-minute window.
- After N failures (TBD — recommend 5): record to `ProvisioningEvent` (or a separate
  rate-limit log), then trigger alert delivery.
- Alert delivery mechanism must be decided (blocker #9 — email/Slack/monitoring service).
  If undecided: log to server console + structured log for Phase 1; add alert wiring in Phase 5.

### Environment Variables

Server-side only (never committed, never in VITE_ prefix):
- `CRM_API_KEY_V1_HASH` — SHA-256 hash of current CRM API key
- `CRM_API_KEY_V2_HASH` — SHA-256 hash of rotation key (optional; present during rotation window)
- `SUPABASE_SERVICE_ROLE_KEY` — for Admin API calls (activation) and any service-role DB writes
- `SUPABASE_URL` — tracker Supabase project URL
- `EMAIL_SERVICE_API_KEY` — transactional email service API key
- `TRACKER_BASE_URL` — base URL for activation link generation (e.g., `https://alh-tracker.vercel.app`)

CRM side (separate environment, never in tracker):
- `CRM_TRACKER_PROVISIONING_KEY` — raw API key (CRM server-side only)

### Update `.env.local.example`

Add server-side variable documentation (values as `<placeholder>` — not real values):
```
# Server-side only (never prefixed with VITE_)
CRM_API_KEY_V1_HASH=<sha256-hash-of-crm-api-key>
SUPABASE_SERVICE_ROLE_KEY=<supabase-service-role-key>
EMAIL_SERVICE_API_KEY=<email-service-api-key>
TRACKER_BASE_URL=https://alh-tracker.vercel.app
```

## Acceptance Criteria

- [ ] `POST /api/provisioning/owner` endpoint exists and is reachable.
- [ ] Constant-time API key comparison implemented.
- [ ] All 7 required headers validated; missing header returns 400.
- [ ] Timestamp window rejection (>5 min) returns 401.
- [ ] Idempotency store consulted before action; same key+payload returns stored response.
- [ ] Same key, different payload returns 409.
- [ ] `provision` creates Facility (pending_setup) + User (invited) + ProvisioningToken atomically.
- [ ] `provision` sends activation email after DB commit.
- [ ] `resend` expires old token and creates new one; sends new email.
- [ ] `revoke` disables User and expires tokens.
- [ ] All actions write a ProvisioningEvent.
- [ ] Response body never contains tracker IDs, raw tokens, or care data.
- [ ] Error responses are generic (no stack traces, no internal IDs).
- [ ] `.env.local.example` updated with server-side variable documentation.
- [ ] No client-side code (src/) modified.

## Dependencies (blockers)

- 0027 must be complete (provisioning_tokens, provisioning_events, users.account_status, facilities.provisioning_status tables/columns must exist)
- Blocker #1 resolved: hosting model decided
- Blocker #2 resolved: idempotency storage decided
- Blocker #3 resolved: email service selected and configured (SPF/DKIM/DMARC verified for sender domain)
- Blocker #5 resolved: role naming decided (determines users.role value at provision time)
- Blocker #7 resolved: retry payload conflict behavior decided
- Blocker #8 resolved: re-provision disabled user behavior decided

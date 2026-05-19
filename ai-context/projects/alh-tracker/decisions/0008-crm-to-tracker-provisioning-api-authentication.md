# 0008 — CRM-to-Tracker Provisioning API Authentication

**Date:** 2026-05-19
**Status:** accepted
**Supersedes:** The CRM-to-tracker provisioning API authentication TODO in ADR 0007 Section — Open Implementation TODOs
**Superseded by:** n/a

## Context

ADR 0007 (accepted 2026-05-18) selected the custom `provisioning_tokens` table as the
tracker-side provisioning mechanism. It defines a tracker-owned API endpoint that the
CRM calls to create, resend, and revoke owner activation tokens. ADR 0007 explicitly
deferred how the CRM authenticates to that endpoint:

> "TODO — CRM-to-tracker provisioning API authentication: The provisioning API endpoint
> must authenticate the CRM's request. Options: rotating API key (simplest; requires key
> management), short-lived service JWT (more secure; requires a token exchange service).
> Must be decided and implemented before the provisioning API is built."

This ADR resolves that blocker.

### System context

- The tracker backend runs on Supabase (PostgreSQL + Auth + Row Level Security).
  Serverless functions may be Supabase Edge Functions or a Next.js/Vercel API route.
- The CRM is a separate surface (ADR 0005). CRM frontend is a React SPA deployed on
  Vercel. CRM backend/server-side runtime is Vercel (serverless functions or server-side
  rendering context).
- Both surfaces have access to server-side environment variable stores (Vercel env vars
  for CRM; Supabase Edge Function secrets or Vercel env vars for tracker API).
- There is no shared infrastructure between CRM and tracker beyond an HTTPS API
  boundary. Neither surface is a trusted intranet host.

### Constraints

1. CRM must never receive the tracker's Supabase service-role key or any broad tracker
   database credential. (ADR 0005 boundary; ADR 0007 rationale.)
2. The credential must be stored exclusively server-side — never in browser/client code,
   never committed to version control.
3. The credential must grant only one permission scope: create, resend, and revoke owner
   provisioning records. It must not grant access to care data, resident records, family
   data, audit trails, or any tracker entity outside of the provisioning workflow.
4. The mechanism must support rotation and revocation without a maintenance window.
5. The mechanism must support audit identification: every provisioning API call must be
   attributable to the source system and the specific CRM actor who triggered it.
6. The mechanism must be compatible with the likely hosting model (Vercel + Supabase
   Edge Functions or serverless API route).
7. Operational complexity must be reasonable at MVP scale (one internal team, no
   dedicated DevSecOps staff).
8. The tracker provisioning endpoint must not return any resident care data, family
   access data, care logs, wellbeing events, audit trails, or resident profile data.

---

## Options Considered

### Option 1 — Rotating static API key

A dedicated, long-lived API key is generated for the CRM integration (a 32-byte
cryptographically random hex string, same generation method as ProvisioningToken).
The CRM transmits it as `Authorization: Bearer <api_key>` on every request to the
tracker provisioning endpoint. The tracker stores only a SHA-256 hash of each valid key
and validates via constant-time comparison.

**Rotation approach (zero-downtime):** The tracker maintains a small set of valid key
hashes (e.g., `crm_api_key_v1`, `crm_api_key_v2`). To rotate: (1) generate a new key
and add its hash to the tracker's accepted set; (2) update the CRM environment variable
and redeploy; (3) remove the old key hash from the tracker's accepted set after
confirming the CRM is using the new key.

**Pros:**
- Simplest mechanism compatible with Vercel + Supabase Edge Functions or serverless API
  routes.
- No additional infrastructure (no token exchange server, no auth service).
- Server-side-only storage in Vercel env vars; never in client code.
- Supports zero-downtime rotation via versioned key slots.
- Supports immediate revocation by removing the key hash from the tracker's accepted set.
- Supports audit: key ID (not value) is logged with every provisioning event.

**Cons:**
- Indefinite-use credential: a compromised key grants provisioning access until rotated.
  Mitigated by: server-side-only storage (no browser exposure), narrow permission scope,
  rate limiting, and defined rotation cadence.
- Rotation requires a coordinated two-step deployment (tracker update + CRM redeploy).
  Mitigated by versioned key slots allowing overlap.
- No automatic expiry; key remains valid until actively rotated or revoked.

**Verdict:** Suitable for MVP. All hard constraints are satisfied. Operational complexity
is low.

---

### Option 2 — Short-lived HMAC-signed service JWT (symmetric)

The CRM mints a short-lived JWT (e.g., 5-minute TTL) signed with a shared HMAC-SHA256
secret. The JWT payload includes `iss` (issuer), `sub` (subject), `iat` (issued-at),
`exp` (expiry), and `jti` (unique token ID for replay prevention). The tracker verifies
the JWT signature and expiry on every request. The `jti` can be stored server-side with
a short TTL for one-use enforcement if desired.

**Pros:**
- Automatic token expiry limits the window of a compromised request.
- `jti` provides built-in replay prevention without a separate idempotency mechanism.
- No token exchange server required — both sides share only the signing secret.
- Standard JWT libraries available in all relevant runtimes (Node.js, Edge Functions).

**Cons:**
- Shared HMAC secret is still a long-lived credential; compromise of the signing secret
  is equivalent to compromise of the API key. The improved security is in per-request
  token expiry, not in the secret's exposure profile.
- CRM must mint a new JWT for every provisioning request, adding a code dependency on a
  JWT library and correct expiry logic.
- Clock skew between CRM and tracker can cause spurious validation failures; requires a
  configurable skew tolerance.
- Rotation of the signing secret requires the same two-step coordinated deployment as
  Option 1.
- Marginal complexity increase over Option 1 for MVP with the same fundamental credential
  model.

**Verdict:** Preferred for Phase 2 hardening. Not selected for MVP because the
incremental security benefit over Option 1 (per-request expiry) does not justify the
added complexity at this scale. Recommended upgrade path once provisioning volume and
operational maturity justify it.

---

### Option 3 — Asymmetric JWT (RSA or ECDSA)

CRM signs JWTs with an RSA or ECDSA private key. Tracker verifies with the corresponding
public key. The private key never leaves the CRM's server-side environment; the public
key is published to the tracker.

**Pros:**
- Strongest key compromise isolation: a leaked tracker public key grants nothing.
- No shared secret between CRM and tracker.
- Well-established pattern for service-to-service auth.

**Cons:**
- Significant operational overhead for a startup MVP: key pair generation, certificate
  lifecycle, key rotation involves publishing a new public key to the tracker and
  coordinating rotation.
- No hosted key management infrastructure (KMS, certificate store) exists in the current
  tech stack; adding one is out of scope for MVP.
- Complexity is disproportionate to the threat model at this scale (one internal
  integration, one provisioning endpoint).

**Verdict:** Architecturally correct for a mature multi-service system. Out of scope for
MVP and Phase 2. Viable if the tracker grows into a multi-tenant API platform with
multiple service clients.

---

### Option 4 — OAuth2 client credentials (external auth server)

CRM presents a `client_id` and `client_secret` to a dedicated authorization server
(e.g., Auth0, Okta, or a self-hosted OAuth2 server). The auth server issues a short-
lived access token. The CRM uses the access token on the provisioning endpoint. The
tracker verifies the access token against the auth server's JWKS endpoint.

**Pros:**
- Standard, well-understood service-to-service auth protocol.
- Short-lived access tokens with automatic expiry.
- Centralized token management; multiple service clients can be managed independently.

**Cons:**
- Requires a third-party auth service dependency or a self-hosted OAuth2 server — both
  are out of scope for MVP.
- Adds network dependency: the tracker must call the auth server's JWKS endpoint to
  validate tokens (can be cached, but adds latency and failure mode).
- The `client_secret` in OAuth2 client credentials is functionally equivalent to a
  static API key with additional protocol overhead at this scale.
- Highest operational complexity of all options for a single internal integration.

**Verdict:** Appropriate if the CRM-to-tracker boundary expands to include multiple
service clients or if an auth server is already in place. Out of scope for MVP and Phase
2. Revisit if the provisioning API becomes a platform-level API with multiple consumers.

---

### Option 5 — mTLS (mutual TLS)

Both the CRM and tracker present TLS client certificates to each other. Authentication is
at the transport layer.

**Pros:**
- Strong mutual authentication with no shared application-level secret.
- No credential in the HTTP layer.

**Cons:**
- Requires a PKI for both sides: certificate issuance, distribution, rotation, and
  revocation.
- Not natively supported by Vercel serverless functions or Supabase Edge Functions without
  significant infrastructure wrapping.
- Disproportionate complexity for a single internal integration at MVP scale.

**Verdict:** Excluded. Infrastructure requirements are incompatible with the Vercel +
Supabase hosting model without significant additional infrastructure.

---

## Decision

**Selected: Option 1 — Rotating static API key for MVP.**
**Planned upgrade: Option 2 — Short-lived HMAC-signed service JWT, in a later hardening
phase.**

### Rationale

1. Option 1 satisfies all hard constraints: the CRM never receives the tracker's Supabase
   service-role key; the credential is scoped exclusively to the provisioning endpoint;
   it is stored server-side only; it supports rotation (zero-downtime via versioned key
   slots) and revocation (immediate by removing the key hash); it is auditable by key ID.

2. The risk profile of a static API key is acceptable at MVP scale given: (a) server-
   side-only storage with no browser exposure; (b) narrow permission scope (provisioning
   only); (c) rate limiting and failed-auth alerting on the endpoint; (d) a defined
   rotation cadence.

3. A compromise of the CRM server environment exposes the CRM API key — a credential
   scoped only to provisioning actions. It does not expose the tracker Supabase service-
   role key, resident care data, audit trails, or any other tracker entity. This is
   materially better than the ADR 0007 Option A rejection scenario (CRM holding tracker
   service-role key).

4. Option 2 (HMAC JWT) adds per-request expiry without changing the fundamental credential
   model. It is the right upgrade path once provisioning volume and operational maturity
   justify the added code complexity. The migration path is straightforward: replace the
   static key with a shared HMAC secret, update CRM to mint JWTs, update tracker to
   verify them.

5. Options 3, 4, and 5 are architecturally sound but disproportionate in operational
   complexity for a single internal integration at MVP scale.

---

## Authentication Flow

### MVP flow (rotating static API key)

```
CRM server-side runtime
  │
  │  1. CRM staff triggers "Provision tracker account" in CRM UI.
  │  2. CRM server-side function reads CRM_TRACKER_PROVISIONING_KEY from env.
  │  3. CRM constructs request with required headers (see Request Contract below).
  │
  └─── HTTPS POST /api/provisioning/owner ──────────────────────────────────────┐
       Authorization: Bearer <crm_api_key>                                       │
       Content-Type: application/json                                            │
       X-Request-Id: <uuid_v4>                                                   │
       X-Idempotency-Key: <uuid_v4>                                              │
       X-CRM-Facility-Id: <crm_facility_id>                                      │
       X-CRM-Actor-Id: <crm_staff_member_id>                                     │
       X-Request-Timestamp: <iso8601_utc>                                        │
                                                                                 ▼
                                                               Tracker API endpoint
  4. Tracker extracts Bearer token from Authorization header.
  5. Tracker computes SHA-256(extracted_token) → hash.
  6. Tracker performs constant-time comparison of hash against all valid key hashes
     in its accepted set (crm_key_v1_hash, crm_key_v2_hash, ...).
  7. If no match → 401 Unauthorized. Log attempt (no token detail). Rate-limit check.
  8. If match → proceed to request validation (schema, timestamp, idempotency).
  9. Tracker executes provisioning logic (see ADR 0007).
 10. Tracker returns opaque response (see Response Contract below).
```

### Phase 2 flow (HMAC-signed JWT — future hardening)

```
CRM server-side runtime
  │
  │  1. CRM reads shared HMAC signing secret (CRM_TRACKER_JWT_SECRET) from env.
  │  2. CRM mints JWT: { iss: "crm", sub: "crm-provisioning", iat, exp: iat+300,
  │     jti: uuid_v4() }. Signs with HMAC-SHA256.
  │  3. CRM constructs request with JWT in Authorization: Bearer header.
  │
  └─── HTTPS POST /api/provisioning/owner ──────────────────────────────────────┐
       Authorization: Bearer <signed_jwt>                                        │
       (other headers same as MVP flow)                                          │
                                                                                 ▼
                                                               Tracker API endpoint
  4. Tracker verifies JWT signature with shared secret.
  5. Tracker checks exp (reject if expired) and iss/sub claims.
  6. Tracker checks jti against short-lived deduplication store (TTL: token exp + buffer).
  7. If jti seen → replay detected → 409. If valid → proceed to request handling.
  8. Continue as in MVP flow from step 8.
```

---

## Secret Storage and Rotation

### MVP (static API key)

| Party | Where stored | What is stored |
|---|---|---|
| CRM | Vercel environment variable: `CRM_TRACKER_PROVISIONING_KEY` | Raw API key (never committed to source control) |
| Tracker | Environment variable or Edge Function secret: `CRM_API_KEY_V1_HASH`, `CRM_API_KEY_V2_HASH` (or a structured secrets store) | SHA-256 hex hash of each valid key. Never the raw key. |

**Rotation procedure (zero-downtime):**

1. Generate new key: `crypto.randomBytes(32).toString('hex')` (or equivalent).
2. Compute SHA-256 of new key.
3. Add new key hash to tracker's accepted set (e.g., set `CRM_API_KEY_V2_HASH`).
4. Deploy tracker update. Both V1 and V2 keys are now valid.
5. Update `CRM_TRACKER_PROVISIONING_KEY` in CRM Vercel env vars with new key.
6. Redeploy CRM. CRM now uses V2 key; V1 is still accepted during propagation.
7. Confirm CRM is successfully authenticating with new key (check provisioning event
   log for successful auth).
8. Remove V1 hash from tracker's accepted set. Deploy tracker update.
9. V1 key is now invalid.

**Revocation (emergency):**

Remove all key hashes from tracker's accepted set and deploy. All CRM provisioning API
calls immediately return 401. Generate a new key out-of-band, distribute to CRM, and
restore service. Log the revocation event.

**Rotation cadence:** Minimum every 90 days. Immediately on any suspected compromise.

### Phase 2 (HMAC signing secret)

| Party | Where stored | What is stored |
|---|---|---|
| CRM | Vercel environment variable: `CRM_TRACKER_JWT_SECRET` | Raw HMAC-SHA256 signing secret (never committed) |
| Tracker | Environment variable or Edge Function secret: same `CRM_TRACKER_JWT_SECRET` | Same raw secret (needed to verify the HMAC) |

Rotation for a symmetric secret requires coordinated deployment to both sides. Use a
versioned accept-old-during-transition approach: CRM switches to new secret; tracker
accepts both old and new signatures for a short overlap window, then removes old secret.

---

## Authorization Scope — Least Privilege

The CRM API key (or JWT subject claim in Phase 2) grants exactly three provisioning
actions on the tracker:

| Action | Allowed |
|---|---|
| Trigger owner account provisioning (create ProvisioningToken + User in `invited` state) | Yes |
| Trigger token resend (expire existing token, generate new one) | Yes |
| Trigger invitation revocation (expire token, set User to `disabled`) | Yes |
| Read any tracker entity | No |
| Write any care-operations entity (CareLogEntry, WellnessObservation, Resident, etc.) | No |
| Write any ProvisioningEvent directly | No — endpoint writes events internally |
| Call Supabase Admin API | No — deferred to owner activation endpoint, never CRM-triggered |
| Read ProvisioningToken.token_hash or ProvisioningToken.id | No |
| Read any tracker User.id | No |
| Read or modify any resident, family, or care data | No — hard constraint (ADR 0005) |

The provisioning endpoint must enforce these constraints server-side. They must not
rely on CRM-side behavior.

---

## Request Contract (Conceptual)

All CRM-to-tracker provisioning requests must include the following metadata fields.
The tracker provisioning endpoint validates all of them before processing the action.

### Required HTTP headers

| Header | Description | Validation |
|---|---|---|
| `Authorization` | `Bearer <crm_api_key>` | Present, non-empty, valid via constant-time hash comparison |
| `X-Request-Id` | UUID v4 — unique per request; used as correlation ID in all audit events | Present, valid UUID |
| `X-Idempotency-Key` | Caller-supplied key (UUID v4 recommended) — see Idempotency section | Present, non-empty |
| `X-CRM-Facility-Id` | CRM's opaque facility identifier — stored in ProvisioningEvent metadata for correlation; not a tracker Facility ID | Present, non-empty, max 128 chars |
| `X-CRM-Actor-Id` | CRM staff member's opaque identifier — stored as `performed_by` in ProvisioningEvent | Present, non-empty, max 128 chars |
| `X-Request-Timestamp` | ISO 8601 UTC timestamp of when CRM sent the request | Present, parseable, within ±5 minutes of tracker server time |
| `Content-Type` | `application/json` | Must be `application/json` |

**Note:** `X-CRM-Actor-Id` must be an opaque identifier for the CRM staff member
(e.g., the CRM's internal user ID). It must never be a care-facility user ID, a resident
ID, or any tracker-internal identifier. It is stored as `performed_by` in ProvisioningEvent
(type `crm_staff`) for audit purposes only.

### Request body (conceptual)

```json
{
  "owner_email": "<string — owner's email address>",
  "owner_name": "<string — owner's display name>",
  "action": "provision" | "resend" | "revoke"
}
```

For `resend` and `revoke` actions, the tracker resolves the target account by
`owner_email`. For `provision`, the tracker checks for an existing `invited` or
`password_pending` account with the same email; if found, the endpoint returns the
existing `provisioning_reference` without creating a duplicate (idempotent by email
within the `invited` state).

**Owner role:** CRM-provisioned accounts always receive `role = owner`. The role is not
caller-specified — it is enforced server-side by the provisioning endpoint (per ADR 0007
Phase 1 step 3b). The CRM cannot provision a non-owner account via this API.

**Intentionally excluded fields:**
- `phone`: Collected from the owner at activation time, not at provisioning time (ADR 0006
  Section 4 — "Phone number: Required" is listed as an activation-time field).
- `allocated_resident_count`: A CRM-managed commercial subscription concept (ADR 0005).
  The tracker provisioning endpoint has no function for this value.

**Facility association (RESOLVED — ADR 0009, 2026-05-19):** The tracker Facility record
is created by the provisioning API call. For `action = "provision"`, the request body
must include the following additional facility fields (defined and governed by ADR 0009):

| Field | Type | Required | Notes |
|---|---|---|---|
| `facility_name` | string | Required | Facility's commercial name from CRM. Max 200 chars. |
| `facility_city` | string | Required | City. CA only at MVP. Max 100 chars. |
| `facility_state` | string | Required | State abbreviation (e.g., `"CA"`). |
| `license_number` | string | Optional | RCFE license placeholder from CRM. May be null/empty. Max 50 chars. |

`X-CRM-Facility-Id` (already required per the headers table above) is used as the
`crm_facility_reference` for idempotency and deduplication — it must not be duplicated in
the body. The tracker never returns its internal `Facility.id` to the CRM. See ADR 0009
for the full facility creation sequence, status lifecycle, and excluded fields.

**What the request body must not contain:**
- Tracker User IDs
- Tracker Facility IDs
- Resident IDs, care data references, or any care-operations entity identifiers
- Raw tokens or token hashes
- Any session or auth credential besides the `Authorization` header

---

## Response Contract (Conceptual)

### Success response (2xx)

```json
{
  "provisioning_reference": "<opaque UUID>",
  "status": "invited" | "resent" | "revoked"
}
```

- `provisioning_reference` is an opaque UUID v4 generated by the tracker. It is the
  only correlation identifier the CRM stores. It is not a token, not a tracker User ID,
  not a tracker Facility ID.
- `status` reflects the outcome of the action.

**What the response must never contain:**
- Activation token or token hash
- Tracker User.id
- Tracker Facility.id
- Any resident record, care log, wellness observation, allergy record, shift record,
  audit trail entry, family access consent record, or any resident-identifiable data
- Session tokens or refresh tokens
- Supabase credentials of any kind

### Error responses

| Status | When |
|---|---|
| 400 Bad Request | Missing required fields, schema validation failure, unrecognized action |
| 401 Unauthorized | Authentication failure (key not valid). No detail in response body — return generic `{"error":"unauthorized"}` only. |
| 409 Conflict | Replay detected (same idempotency key within TTL, different payload hash) |
| 422 Unprocessable Entity | Valid auth, valid schema, but business rule violation (e.g., revoke on an already-active account) |
| 429 Too Many Requests | Rate limit exceeded. Include `Retry-After` header. |
| 500 Internal Server Error | Unexpected tracker-side error. Log internally; return generic error to CRM. |

---

## Idempotency Requirements

The tracker provisioning endpoint must implement idempotency keyed on
`X-Idempotency-Key`:

1. On receipt of a request, the tracker checks whether `X-Idempotency-Key` has been
   seen within the idempotency window (24 hours recommended).
2. If the key is new: process the request, store the idempotency key with the response
   payload and a TTL of 24 hours, return the response.
3. If the key is seen and the request payload matches: return the stored response without
   re-processing (safe retry).
4. If the key is seen but the request payload differs: return 409 Conflict. Log the
   inconsistency.
5. CRM must generate a fresh `X-Idempotency-Key` for each new provisioning action.
   CRM may re-use the same key for a retry of the same action if the previous attempt
   failed without a successful response.

**TODO — Idempotency storage:** The server-side store for idempotency keys may be a
Supabase table (append-only with TTL cleanup), a Redis/Upstash instance, or in-memory
per function invocation (not safe for distributed serverless — requires an external store).
The storage mechanism must be decided before the provisioning endpoint is built.

---

## Replay Prevention

Two layers of replay prevention are required:

**Layer 1 — Request timestamp validation:**
- The tracker rejects any request where `X-Request-Timestamp` is more than 5 minutes
  older than the tracker's current server time.
- The tracker also rejects requests with timestamps more than 60 seconds in the future
  (clock skew tolerance).
- This prevents replay of captured requests outside the timestamp window.

**Layer 2 — Idempotency key deduplication:**
- As described in the Idempotency section above, `X-Idempotency-Key` deduplication
  within a 24-hour window catches replays of the same intended action.
- These two layers together cover both short-window replay (timestamp) and longer-window
  duplicate-request scenarios (idempotency key).

**Note for Phase 2 (HMAC JWT):** The JWT `jti` claim provides an additional replay
prevention layer. A `jti` seen more than once (within the JWT's validity window) is
rejected as a replay. This supplements — it does not replace — the timestamp and
idempotency checks.

---

## Audit and Logging Requirements

All provisioning API calls must be auditable regardless of outcome.

### On every request (success or failure)

| Field | Where logged |
|---|---|
| Request ID (`X-Request-Id`) | ProvisioningEvent.metadata + server-side request log |
| CRM Actor ID (`X-CRM-Actor-Id`) | ProvisioningEvent.performed_by (type `crm_staff`) |
| CRM Facility ID (`X-CRM-Facility-Id`) | ProvisioningEvent.metadata (correlation only) |
| Action type | ProvisioningEvent.event_type |
| Outcome (success / failure code) | ProvisioningEvent.metadata |
| Timestamp | ProvisioningEvent.created_at |
| Key version (not the key value) | ProvisioningEvent.metadata (e.g., `crm_key_v1` or `crm_key_v2`) |

**Never log:** The raw API key. The raw JWT. The activation token. The token hash.
Any care-data identifiers. Any resident record.

### On authentication failure

- Log: timestamp, source IP (or forwarded IP), key version attempted (if determinable
  from request format), request ID.
- Do not log: the submitted key value.
- Rate-limit: 10 failed auth attempts per source IP per minute → 429 response.
- Alert: 50 failed auth attempts from any source within 5 minutes → operational alert to
  ALH Tracker staff. **TODO: alert delivery mechanism unresolved (email, Slack, PagerDuty
  equivalent).**

### Idempotency deduplication events

When a request is deduplicated (successful idempotency match), log the deduplication
alongside the original request ID. Do not write a new ProvisioningEvent — return the
original stored response.

---

## Non-Goals

This ADR does not define or change:

- The CRM authentication model for ALH Tracker internal staff (separate TODO per ADR 0005
  and `ai_memory.md`).
- The tracker provisioning API implementation (implementation task — requires this ADR
  to be accepted first).
- The full owner activation flow (fully specified in ADR 0007).
- Token security properties, expiry, resend, or revocation logic (ADR 0007).
- Caregiver or admin account creation flows (direct within tracker app — no provisioning
  API).
- FamilyUser account activation (ADR 0006).
- The native vs. PWA app delivery decision (pending ADR candidate).
- The transactional email service selection (ADR 0007 TODO).
- The CRM data boundary (ADR 0005) — unchanged.
- Any family access architecture (ADR 0004) — unchanged.
- HIPAA BAA posture, Title 22 compliance, or regulatory claims.

---

## Consequences

**Easier:**
- The CRM provisioning API can be implemented immediately after this ADR is accepted.
  The API key mechanism requires only: env var configuration, SHA-256 hash storage on
  the tracker side, and constant-time comparison middleware.
- A compromised CRM environment exposes only the provisioning API key — a credential
  scoped to provisioning actions only. It does not expose tracker Supabase credentials,
  resident care data, or any other tracker entity.
- Zero-downtime key rotation is achievable with versioned key slots without a maintenance
  window.
- The Phase 2 upgrade path (HMAC JWT) is clearly defined and does not require
  architectural changes — only replacing the credential model in existing CRM and tracker
  code.

**Harder:**
- API key rotation requires a two-step coordinated deployment (tracker update to add new
  key hash, CRM redeploy with new key, tracker update to remove old key hash). This is a
  defined operational procedure but requires coordination discipline.
- A static API key has no automatic expiry. Rotation cadence discipline (90 days minimum)
  must be maintained operationally.
- The idempotency key store requires an external persistent store (Supabase table or
  equivalent) — not in-process memory — to be safe in a distributed serverless
  environment. **TODO: storage mechanism unresolved — must be decided before implementation.**
- The endpoint must enforce the least-privilege constraint (no care data access, no
  Supabase service-role exposure) entirely server-side; client-side enforcement is
  insufficient.

---

## Open Implementation TODOs

- **TODO — Idempotency key storage mechanism:** The server-side store for idempotency
  keys must persist across serverless function invocations. Options: a dedicated
  `provisioning_idempotency_keys` table in Supabase (with TTL cleanup job), an Upstash
  Redis instance, or another persistent cache. In-memory storage is not safe in a
  distributed serverless environment. Must be decided before the provisioning endpoint
  is built.
- **TODO — Provisioning endpoint hosting model:** Decide whether the tracker provisioning
  endpoint is a Supabase Edge Function or a Vercel API route (on the tracker front-end
  deployment, if one exists, or on a separate API service). The hosting model affects how
  secrets are loaded and how the endpoint is secured. Must be decided before
  implementation.
- **TODO — Alert delivery mechanism:** Failed auth burst alerting (50 failures / 5 min)
  requires a notification delivery path. Options: email via transactional email service,
  Slack webhook, or a monitoring service alert rule. Must be decided before the endpoint
  is in production.
- **TODO — Key version tagging in ProvisioningEvent:** The exact format of the key
  version identifier logged in ProvisioningEvent.metadata (e.g., `crm_key_v1`, a
  truncated key hash prefix, or a sequential version number) is unresolved. Must be
  consistent between tracker and any future key audit tooling.
- **TODO — Phase 2 upgrade timing:** No specific trigger is defined for when to upgrade
  from rotating API key to HMAC-signed JWT. Candidate triggers: provisioning volume
  exceeds N requests/month; multiple CRM service clients require independent credentials;
  a security review recommends it. Defer decision until one of these triggers is reached.
- **TODO — Provisioning endpoint rate limiting:** The per-IP rate limit (10 failures/min)
  is specified. A separate per-key (successful auth) rate limit for total provisioning
  volume may also be appropriate (e.g., max 100 provision/resend/revoke actions per day
  per key). Exact limits are unresolved — set after measuring expected provisioning
  volume.
- **TODO — `X-CRM-Facility-Id` validation:** Whether the tracker validates that the
  CRM-supplied facility ID corresponds to a known CRM account (beyond storing it for
  correlation) is unresolved. At MVP, it may be stored as an opaque string with no
  tracker-side validation. This is acceptable if the tracker does not need to enforce any
  CRM-side business rules.

# 0012 — Phase 2 Provisioning Platform Decisions

**Date:** 2026-05-20
**Status:** accepted
**Supersedes:** The following open TODOs from prior ADRs:
- ADR 0007 Open TODOs: transactional email service selection; `User.created_by` for CRM-provisioned accounts; `token_expired_passive` background job
- ADR 0008 Open TODOs: provisioning endpoint hosting model; idempotency key storage mechanism; alert delivery mechanism
- ADR 0009 Open TODOs: retry payload conflict behavior; re-provision when invited User is disabled
**Superseded by:** n/a

## Context

ADRs 0007–0011 fully specified the provisioning token mechanism, API authentication contract,
facility creation sequence, RLS quarantine gate, and role naming. Task 0030 applied the Phase 1
schema and RLS migrations. The four open blockers that remain before provisioning endpoint
implementation (backlog task 0028) can begin are:

1. **Endpoint hosting model** — Where does the tracker provisioning endpoint run? (ADR 0008 TODO)
2. **Idempotency storage mechanism** — What persists idempotency keys across serverless invocations? (ADR 0008 TODO)
3. **Transactional email service** — What service sends the owner activation email? (ADR 0007 TODO)
4. **`User.created_by` behavior** — How is the `created_by` column populated for accounts provisioned by CRM staff who are not tracker users? (ADR 0007 TODO)

In addition, two edge-case behaviors from ADR 0009 remain unspecified:

5. **Retry payload conflict behavior** — What happens when a retry uses the same `X-CRM-Facility-Id` but sends conflicting facility field values?
6. **Re-provision behavior** — What happens when CRM attempts to provision a facility whose previous User is `disabled` (invitation revoked)?

And two ADR 0007 items that the Phase 1 migration decision left open:

7. **`token_expired_passive` in the enum** — The Phase 1 migration omitted `token_expired_passive` from `provisioning_event_type`. Should it be added back?
8. **Alert delivery mechanism** — Where should failed auth burst alerts be sent? (ADR 0008 TODO)

### Constraints in scope

1. The tracker app is a Vite SPA deployed on Vercel — not Next.js. There are no existing Vercel API routes in the repo (`api/` directory does not exist; `vercel.json` contains only frontend deployment config).
2. The provisioning endpoint must use the Supabase service-role key to write to `provisioning_tokens`, `provisioning_events`, and `users` — access that must never be exposed to the browser client.
3. CRM users are not tracker users (ADR 0005, ADR 0006). The `User.created_by` FK must not force a CRM actor into the tracker `users` table.
4. Idempotency store must persist across independent serverless function invocations — in-process memory is excluded.
5. Provisioning volume at MVP is very low (expected single digits to low tens of facilities per month).
6. No application code is implemented in this ADR — this is an architecture/design decision record only.

---

## Decision 1 — Endpoint Hosting Model

### Options Considered

**Option A — Supabase Edge Function**

A Supabase Edge Function (`supabase/functions/provision-owner/`) runs in the Deno runtime, directly
adjacent to the Supabase project. Environment variables and secrets are managed through
`supabase secrets set`. The service-role key is read at runtime from the function's secret store.

Pros:
- No framework migration. The tracker is a Vite SPA — there is no Next.js App Router or `pages/api`
  directory. A Supabase Edge Function is the natural tracker-side backend extension point.
- The service-role key never leaves the Supabase environment. The Edge Function calls
  `createClient(url, serviceRoleKey)` with values injected at runtime, never returned to the browser.
- The Deno Web Crypto API provides `crypto.subtle.digest('SHA-256', ...)` for hashing and supports
  timing-safe byte comparison (implemented with `crypto.subtle.timingSafeEqual` polyfill or a
  manual fixed-time comparison loop — `crypto.timingSafeEqual` is Node.js-specific and not in Deno
  Web Crypto; the Deno standard library `std/crypto` includes a `timingSafeEqual` helper).
- Supabase CLI (`supabase functions deploy`) provides deployment tooling without a separate service.
- Atomic DB transactions use the `postgres` or `supabase-js` service-role client within the same
  Supabase project. No cross-service latency for DB writes.
- Supabase Edge Functions support scheduled invocations via pg_cron or Supabase Scheduled Functions
  — required for the `token_expired_passive` sweep (Decision 7).

Cons:
- Deno runtime (not Node.js): some Node.js packages unavailable. The required primitives
  (Web Crypto API, fetch, Postgres client via `supabase-js`) are all available in Deno.
- Cold starts are possible for very low-volume endpoints (provisioning is infrequent — acceptable).
- Requires Supabase CLI for local development and deployment.

**Option B — Vercel API Route (separate `api/` folder)**

Add a Vercel serverless function at `api/provisioning/owner.ts` (or equivalent). This would require
restructuring the Vercel deployment from a pure SPA to include serverless functions.

Pros:
- Familiar Node.js runtime; `crypto.timingSafeEqual` available natively.
- Co-located in the same Vercel project as the frontend SPA.

Cons:
- The tracker frontend is a Vite SPA with no existing API layer. Adding Vercel API routes to a
  Vite app requires `vercel.json` restructuring and introduces a Node.js runtime alongside the
  frontend build — complexity not currently in the project.
- The Supabase service-role key would be stored as a Vercel environment variable and used in a
  Vercel function — this works, but creates a dependency where the Vercel project holds tracker
  service-role credentials, a wider blast radius than the Supabase-internal Edge Function approach.
- Does not benefit from pg_cron-adjacent scheduling for the token expiry sweep job.

**Option C — Separate Node.js/Express API service**

A standalone backend service (e.g., Express or Fastify on a second Vercel project or Railway).

Verdict: Out of scope for MVP. Disproportionate infrastructure for a low-volume internal endpoint.
Excluded.

### Decision 1

**Selected: Option A — Supabase Edge Function.**

Rationale:
1. The Vite SPA has no existing API layer. A Supabase Edge Function requires no framework migration.
2. The service-role key stays within the Supabase environment — narrower blast radius than a
   Vercel env var configuration.
3. Deno Web Crypto API satisfies all cryptographic requirements (SHA-256, timing-safe comparison).
4. Supabase's scheduling primitives support the `token_expired_passive` sweep (Decision 7).
5. Supabase CLI (`supabase functions deploy`) provides a standard, low-friction deployment path.

**Implementation notes:**
- Function entry point: `supabase/functions/provision-owner/index.ts`
- Service-role key injected via `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')` (Supabase auto-injects
  this for Edge Functions deployed to a linked project).
- CRM API key hashes injected as Supabase secrets: `CRM_API_KEY_V1_HASH`, `CRM_API_KEY_V2_HASH`.
- Timing-safe comparison: use `std/crypto` `timingSafeEqual` from the Deno standard library
  (`https://deno.land/std/crypto/timing_safe_equal.ts`), or implement a manual constant-time
  byte-by-byte comparison using `Uint8Array` slices of equal length.
- The activation endpoint (backlog task 0029) will be a separate Edge Function
  (`supabase/functions/activate-owner/index.ts`).

---

## Decision 2 — Idempotency Storage Mechanism

### Options Considered

**Option A — Supabase table (`provisioning_idempotency_keys`)**

A `provisioning_idempotency_keys` table in the tracker Supabase database stores
`(idempotency_key, response_payload, expires_at)`. The Edge Function checks this table before
processing, stores the result after processing, and returns the cached response on subsequent
identical requests (per ADR 0008 Idempotency Requirements).

Pros:
- No additional external service. The provisioning flow is already entirely within Supabase.
- Transactional consistency: the idempotency key check and provisioning writes can execute within
  the same database transaction context using the service-role client.
- Audit co-location: idempotency records are stored adjacent to `provisioning_events` — easier to
  correlate and audit.
- TTL cleanup: lazy deletion (delete expired rows on read) or a Supabase pg_cron job. Either is
  straightforward.
- At MVP provisioning volume (single-digit new facilities per month), table read/write latency is
  negligible.
- Zero additional operational dependencies: no extra service account, credentials, or billing.

Cons:
- PostgreSQL is not optimized for high-frequency short-TTL key-value operations. At MVP volume,
  this is not a concern. If provisioning volume grows to thousands of requests per minute (not
  expected), reconsider.
- No native TTL expiry — requires lazy deletion on read or a cleanup job. Acceptable given volume.

**Option B — Upstash Redis**

A Redis-as-a-service instance (Upstash offers a serverless-compatible HTTP-based Redis).

Pros:
- Native TTL expiry. Sub-millisecond lookups. Designed for idempotency/deduplication patterns.

Cons:
- New external service dependency. An Upstash account, API credentials, and billing.
- Idempotency keys are separated from provisioning data — cross-service audit correlation requires
  matching request IDs between Supabase and Upstash logs.
- HTTP-based client adds a network hop within the Edge Function.
- Disproportionate complexity for MVP provisioning volume.

**Option C — In-process memory**

Not viable. Serverless function invocations are stateless — memory does not persist across
invocations. Excluded per ADR 0008.

### Decision 2

**Selected: Option A — Supabase table (`provisioning_idempotency_keys`).**

Rationale:
1. Zero external service dependency. The provisioning flow is already Supabase-native.
2. Transactional consistency with provisioning writes.
3. Adequate performance at MVP provisioning volume.
4. Auditability: all provisioning state in one place.

**Schema (to be applied in a migration with backlog task 0028):**

```sql
CREATE TABLE provisioning_idempotency_keys (
  idempotency_key  TEXT        NOT NULL PRIMARY KEY,
  request_hash     TEXT        NOT NULL,  -- SHA-256 of request payload for conflict detection
  response_payload JSONB       NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at       TIMESTAMPTZ NOT NULL  -- NOW() + 24 hours (per ADR 0008)
);

ALTER TABLE provisioning_idempotency_keys ENABLE ROW LEVEL SECURITY;
-- No client-accessible policies. Service-role only.
```

**TTL cleanup:** Lazy deletion on read (delete expired rows during the idempotency lookup step).
A pg_cron sweep (e.g., daily) can also delete rows where `expires_at < NOW()` to prevent
unbounded table growth. Exact cleanup cadence is an implementation detail for task 0028.

---

## Decision 3 — Transactional Email Service

### Options Considered

**Option A — Resend**

Resend is a developer-focused transactional email API with a React Email template system, REST
API, and Node.js/Deno SDK.

Pros:
- Generous free tier (3,000 emails/month — more than sufficient for MVP provisioning volume).
- Simple API. Deno-compatible SDK available (`https://deno.land/x/resend`); alternatively, the
  REST API is callable via `fetch` with no SDK dependency.
- SPF, DKIM, and DMARC domain verification supported through the Resend dashboard.
- React Email integration for well-structured activation email templates.
- Good transactional email deliverability.

Cons:
- Deliverability may be lower than Postmark for certain mail domains. If activation emails
  land in spam filters, onboarding is blocked — this is a hard product failure for provisioning.
- Newer service with less established deliverability reputation than Postmark or SendGrid.

**Option B — Postmark**

Postmark specializes in transactional email deliverability. Widely used in healthcare-adjacent
and compliance-sensitive SaaS contexts.

Pros:
- Industry-leading deliverability reputation for transactional email.
- Strict anti-spam enforcement by Postmark means senders on the platform have high reputation.
- Strong track record for activation / onboarding emails reaching inboxes.
- Good for healthcare-adjacent contexts where delivery failure = blocked onboarding.

Cons:
- No free tier (paid from first send; lowest plan ~$15/month).
- Higher operational cost relative to Resend at low volume.
- Slightly more setup overhead than Resend.

**Option C — SendGrid**

Better suited for high-volume mixed transactional + marketing email. Overkill for MVP.
Excluded.

**Option D — Supabase built-in email**

Supabase's built-in email service is for Supabase Auth flows (password reset, email confirmation).
It cannot send custom application-triggered emails and has restrictive rate limits. Excluded.

### Decision 3

**Selected: Option A — Resend for MVP.**

Rationale:
1. Zero cost at MVP provisioning volume (free tier easily covers initial facility count).
2. Deno-compatible — callable via fetch or Deno SDK in the Supabase Edge Function.
3. Adequate deliverability for transactional email in the expected volume range.
4. Simple integration: one API key, one REST call.

**Fallback condition:** If activation emails consistently fail to reach inbox (spam filter
issues confirmed via email delivery logs), migrate to Postmark. Postmark is the documented
preferred fallback for this product category. Migration does not require architectural changes
— only the email client call and API key in the Edge Function secrets change.

**Domain setup requirements (required before the provisioning endpoint goes to production):**
- SPF: Add Resend's SPF `include` directive to the sender domain's DNS TXT record.
- DKIM: Add the DKIM public key TXT record provided by Resend to the sender domain's DNS.
- DMARC: Add a `v=DMARC1; p=none` DMARC TXT record initially. Tighten to `p=quarantine` or
  `p=reject` after confirming alignment in DMARC reports.
- Send from a dedicated sending subdomain (e.g., `no-reply@mail.alh-tracker.app` or equivalent).
  Using a sending subdomain isolates the sender reputation from the primary domain.
- Verify domain and DKIM in the Resend dashboard before deploying the provisioning endpoint.

**API key storage:** Resend API key stored as a Supabase Edge Function secret
(`RESEND_API_KEY`). Never committed to source control.

---

## Decision 4 — `User.created_by` for CRM-Provisioned Accounts

### Options Considered

**Option A — Nullable UUID FK (selected)**

`User.created_by` is a nullable UUID FK → `users.id`. For accounts created in-app by an
owner or admin, `created_by` = the creating user's ID. For CRM-provisioned accounts,
`created_by = NULL`. The authoritative provenance source for CRM-provisioned accounts is
the `ProvisioningEvent` table (`event_type = 'provisioned'`, `actor_id = crm_staff_id`).

Pros:
- No new columns. The column already exists conceptually in `data_model.md`.
- NULL is semantically correct: no tracker User created the account.
- CRM/tracker principal separation (ADR 0005, ADR 0006) is preserved — no CRM actor enters
  the tracker `users` table.
- Provenance is fully recoverable from `ProvisioningEvent` without adding redundant data
  to the `users` table.
- Consistent with the ADR 0007 NOTE: "CRM staff are not tracker users."

Cons:
- `created_by = NULL` is ambiguous without context (was it CRM, system, or a future self-signup
  path?). Mitigated by: the account lifecycle (`account_status = 'invited'` + associated
  `ProvisioningEvent`) unambiguously identifies CRM-provisioned accounts; no self-signup
  path exists at MVP.

**Option B — Sentinel value (fake CRM user in `users` table)**

Create a special `users` row with a well-known UUID representing "CRM provisioning system".
Set `created_by = crm_sentinel_user_id` for all CRM-provisioned accounts.

Verdict: Rejected. This violates ADR 0005/ADR 0006 principal separation — a CRM actor must
not become a tracker `User`. A fake tracker `User` for the CRM creates false identity records,
confuses any future user-management UI, and permanently couples the CRM actor model to the
tracker data model.

**Option C — Structural actor model (`created_by_actor_type` + `created_by_actor_id`)**

Replace `created_by UUID FK → users` with two columns:
`created_by_user_id UUID FK → users` (nullable) +
`created_by_actor_type ENUM ('owner', 'admin', 'crm', 'system')` +
`created_by_actor_id TEXT` (opaque).

Verdict: Architecturally thorough but premature for MVP. Adds schema complexity beyond what
the task requires. The combination of `created_by = NULL` and `ProvisioningEvent` already
provides complete provenance. Defer this generalization if a future requirement (e.g., system
self-signup path) demands it.

### Decision 4

**Selected: Option A — Nullable `created_by` UUID FK.**

For CRM-provisioned `User` rows, `created_by = NULL`. The `ProvisioningEvent` table
(`event_type = 'provisioned'`, `actor_id = crm_staff_id`) is the authoritative provenance
record for CRM-provisioned accounts.

**Schema note:** The `created_by` column is documented in `data_model.md` as
`created_by | Foreign key → User (admin who created this account)`. The existing definition
is correct for in-app-created accounts. For CRM-provisioned accounts, the column is NULL.
Verify at implementation time (task 0028) that the `created_by` column is nullable in the
applied migration — `data_model.md` documents no NOT NULL constraint, but the schema file
should be confirmed before proceeding. The provisioning endpoint must set `created_by = NULL`
explicitly when creating the `User` row (not pass `auth.uid()` or any CRM actor identifier
as the value).

**Audit note:** The `ProvisioningEvent` record written at provisioning time captures
`actor_id = X-CRM-Actor-Id` (the CRM staff member's opaque identifier). This is the
canonical audit record for who triggered the provisioning action. Implementers must NOT
duplicate this into `users.created_by` — doing so would require a CRM actor ID to
be stored as a user reference, which violates the principal separation constraint.

---

## Decision 5 — Retry Payload Conflict Behavior (Same `X-CRM-Facility-Id`, Different Facility Data)

ADR 0009 Open Implementation TODOs identified this as unspecified:
> "TODO — Retry payload conflict behavior: Idempotency Scenario 2 (same X-CRM-Facility-Id,
> new X-Idempotency-Key) specifies that the endpoint reuses the existing Facility when found
> in pending_setup state. It does not specify what happens if the retry body includes
> conflicting field values (e.g., different facility_name or facility_city)."

**Decision:** When a provisioning request with a new `X-Idempotency-Key` finds an existing
`pending_setup` Facility by `crm_facility_reference`, the endpoint **ignores conflicting
facility body fields** (does not apply the new values to the existing Facility record) and
returns the existing `provisioning_reference` with the current status.

Rationale:
1. Conflicting data on a retry indicates a CRM-side inconsistency, not an intent to update.
   The existing Facility was created correctly from the first provisioning call; silently
   overwriting it with retry data could corrupt the record.
2. The owner corrects and completes facility data during post-activation setup. Incorrect
   provisioning-time fields do not block activation — they are corrected by the owner.
3. Returning a 409 Conflict for payload mismatch adds implementation burden on the CRM
   (which must interpret and handle the conflict) for a scenario that is a CRM bug, not a
   legitimate use case.
4. Log the conflict: the conflicting fields are written to the Edge Function's structured
   application log so ALH Tracker staff can detect systematic CRM data inconsistencies.
   No new `ProvisioningEvent` row is written — no provisioning action occurred on this
   request, and there is no applicable `provisioning_event_type` for a conflict-on-retry
   scenario (ADR 0008 specifies "Do not write a new ProvisioningEvent" for deduplicated
   requests).

**Implementation note (task 0028):** The conflicting fields must be identified and written
to the Edge Function's structured application log (not in a `ProvisioningEvent` row — no
new provisioning action occurred and no applicable event_type exists for this scenario).
The fields themselves are not applied to the existing Facility. The response returns the
existing `provisioning_reference` and `status = "invited"` (or current status if different).

---

## Decision 6 — Re-Provision When Previous Invited User Is `disabled`

ADR 0009 Open Implementation TODOs identified this as unspecified:
> "TODO — Re-provision when invited User is disabled: ... Facility is in pending_setup but
> the associated User is in disabled state (i.e., the CRM revoked the invitation, then
> attempts to re-provision the same facility)."

**Decision:** Re-provisioning a facility whose previous User is `disabled` (invitation
revoked) is **permitted**. The provisioning endpoint:

1. Finds the existing `pending_setup` Facility by `crm_facility_reference`.
2. Finds the existing `disabled` User associated with that Facility (same email or the only
   User linked to the Facility in `invited`/`disabled` state).
3. Resets `User.account_status = 'invited'`.
4. Expires any existing ProvisioningTokens for this User (`expires_at = NOW()`).
5. Generates a new ProvisioningToken (72h expiry, new raw token, new hash).
6. Sends a new activation email.
7. Generates a new `provisioning_reference` (fresh opaque UUID v4).
8. Writes a `ProvisioningEvent: event_type = 'provisioned'` for the re-provision action.
9. Returns `{ "provisioning_reference": "<new_opaque_uuid>", "status": "invited" }`.

Rationale:
1. Revocation followed by re-provisioning is a legitimate CRM workflow (e.g., the wrong email
   was entered; the owner was unavailable and the invitation is being restarted).
2. Reusing the existing Facility record is correct — the facility relationship with the CRM
   is unchanged; only the owner activation lifecycle is restarting.
3. A new `provisioning_reference` is returned to signal to the CRM that this is a new
   provisioning attempt, not a deduplication response. The CRM should update its stored
   `provisioning_reference` accordingly.
4. Resetting `account_status = 'invited'` (rather than creating a new User row) avoids
   orphaned User records in the tracker.

**Implementation detail deferred to task 0028:** Edge case: if the CRM provides a different
`owner_email` on re-provision (i.e., replacing the owner contact), the behavior is deferred.
The common case (same email, resetting the lifecycle) is specified above. A different email
on re-provision should return a descriptive error until that case is specified.

---

## Decision 7 — `token_expired_passive` in the Enum

The Phase 1 migration (task 0030, migration `20260101000007`) applied the
`provisioning_event_type` ENUM without `token_expired_passive`. ADR 0007 stated:
> "If no cleanup job is built, remove this event type from the ENUM before schema migration."

Task 0030 omitted it, treating the background job as not yet committed. This ADR now commits
to the scheduled sweep approach (enabled by the Supabase Edge Function hosting decision).

**Decision:** **Add `token_expired_passive` back to the `provisioning_event_type` enum** via
a new migration in backlog task 0028.

```sql
ALTER TYPE provisioning_event_type ADD VALUE IF NOT EXISTS 'token_expired_passive';
```

A scheduled Supabase Edge Function (or pg_cron job) runs on a defined cadence (recommended:
every 4 hours) to detect tokens where `expires_at <= NOW() AND used_at IS NULL` and no prior
`token_revoked` or `token_expired_passive` event exists for the token. For each detected
token, the sweep writes a `provisioning_events` row: `event_type = 'token_expired_passive'`,
`actor_id = 'system'`, `token_id = token.id`, `facility_id`, `user_id`.

Rationale:
1. Passive expiry events provide meaningful audit visibility: they show which invited owners
   never activated, enabling ALH Tracker staff to identify facilities that may need outreach.
2. Supabase Edge Functions with scheduled invocations (Supabase Scheduled Functions or
   pg_cron) make the sweep feasible without external infrastructure.
3. The `ADD VALUE IF NOT EXISTS` migration is safe and fully transactional in PostgreSQL 12+.

**Implementation notes (task 0028):**
- The sweep function is a separate Edge Function from the provisioning endpoint.
- The sweep uses the service-role key to query `provisioning_tokens` and write
  `provisioning_events`. Both tables are service-role-only.
- Sweep cadence: 4 hours recommended (balances audit freshness against invocation cost).
- Cleanup idempotency: the sweep must check for an existing `token_expired_passive` event
  for each token before inserting a new one (avoid duplicate events on multiple sweeps).

---

## Decision 8 — Alert Delivery Mechanism

ADR 0008 specified:
> "Alert: 50 failed auth attempts from any source within 5 minutes → operational alert to
> ALH Tracker staff. TODO: alert delivery mechanism unresolved."

**Decision: Deferred.** The provisioning endpoint (task 0028) will implement the rate-limit
counter and threshold detection in the Edge Function. When the threshold is crossed (50 failed
auth attempts / 5 minutes), the endpoint writes a structured log event that can be monitored
externally. The alert delivery channel (email, Slack webhook, Supabase monitoring integration)
is deferred to a separate monitoring and ops setup task.

Rationale:
1. Alert delivery requires operational setup beyond the provisioning endpoint itself:
   a Slack workspace, an email distribution list, or a monitoring service configuration.
2. At MVP provisioning volume, the threshold is extremely unlikely to be crossed in normal
   operation. A delayed alert is acceptable.
3. The rate limiting and per-IP failure counting are implemented in the endpoint regardless
   of the delivery channel. The alert channel can be wired in separately without modifying
   the endpoint's core logic.

**Deferral condition:** Alert delivery must be wired before the provisioning endpoint handles
any real provisioning requests in production. A monitoring task should be created before the
endpoint goes live.

---

## Summary of Decisions

| Decision | Choice | ADR superseded TODO |
|---|---|---|
| Endpoint hosting model | Supabase Edge Function | ADR 0008 |
| Idempotency storage | Supabase `provisioning_idempotency_keys` table | ADR 0008 |
| Transactional email service | Resend (Postmark fallback) | ADR 0007 |
| `User.created_by` for CRM-provisioned accounts | Nullable UUID FK (NULL = CRM); provenance in `ProvisioningEvent` | ADR 0007 |
| Retry payload conflict (same facility ID, different data) | Ignore conflicting fields; log in structured application log (not ProvisioningEvent); return existing reference | ADR 0009 |
| Re-provision disabled User | Permitted; reset to `invited`; new token; new reference | ADR 0009 |
| `token_expired_passive` enum value | Add back via migration; implement scheduled sweep | ADR 0007 |
| Alert delivery mechanism | Deferred; log structured event; wire channel before production | ADR 0008 |

---

## Consequences

**Easier:**
- The provisioning endpoint (backlog task 0028) can now begin with all platform decisions
  resolved. No architecture questions remain for the core provisioning flow.
- Supabase Edge Function + Supabase idempotency table keeps the entire provisioning stack
  within Supabase — one service, one credential boundary, one deployment toolchain.
- Resend's free tier eliminates email service cost at MVP provisioning volume.
- Nullable `created_by` — verify at implementation time that the column is nullable in the applied migration (expected, but must be confirmed before task 0028 sets it to NULL).
- `token_expired_passive` audit completeness is preserved without external infrastructure.

**Harder / new constraints:**
- Deno runtime requires using Deno-compatible libraries (no Node.js-only packages). Must
  use `std/crypto` or Web Crypto API for timing-safe comparison, not `crypto.timingSafeEqual`.
- Domain setup (SPF/DKIM/DMARC for Resend) must be completed before the provisioning
  endpoint is deployed to production. This is a DNS configuration prerequisite, not a code
  change — it has its own lead time.
- The `provisioning_idempotency_keys` table adds one more migration to task 0028.
- The `token_expired_passive` `ADD VALUE` migration also belongs in task 0028.
- Alert delivery deferral means the monitoring gap must be closed before production launch.
- Re-provision behavior (Decision 6) constrains the provisioning endpoint to handle the
  `pending_setup` + `disabled` User case explicitly.

---

## Non-Goals

This ADR does not define or change:
- The CRM authentication model for ALH Tracker internal staff (ADR 0005 TODO).
- The native vs. PWA app delivery model (pending ADR candidate).
- iOS Universal Links / Android App Links server-side configuration (ADR 0007 TODO).
- The full owner activation flow implementation (backlog task 0029).
- Caregiver and admin account creation flows (direct within tracker app, no provisioning API).
- FamilyUser account activation (ADR 0006, Phase 2).
- Subscription resident limit enforcement (ADR 0009 TODO).
- Orphaned `pending_setup` Facility cleanup policy (ADR 0009 TODO).
- Suspension RLS policy (ADR 0010 TODO, deferred to billing/suspension feature).
- Any care data schema, RLS, or audit policy not directly related to provisioning.
- HIPAA BAA posture, Title 22 compliance, or regulatory claims.

---

## Open Implementation TODOs (Task 0028)

- Apply `provisioning_idempotency_keys` table migration (service-role only, no client policies, TTL 24h).
- Apply `ALTER TYPE provisioning_event_type ADD VALUE IF NOT EXISTS 'token_expired_passive'` migration.
- Implement timing-safe comparison using Deno `std/crypto timingSafeEqual` or manual constant-time comparison.
- Configure Resend account, verify sender domain (SPF/DKIM/DMARC), store API key as Supabase secret.
- Implement `token_expired_passive` scheduled sweep as a separate Supabase Edge Function or pg_cron job.
- Specify and implement the alert delivery channel before production launch (separate task recommended).
- Implement re-provision for `disabled` User (Decision 6), including the different-email edge case
  (return error for now; full multi-owner-email behavior deferred).
- Implement retry payload conflict logging (Decision 5): log conflicting fields in the Edge
  Function's structured application log (not in a `ProvisioningEvent` row — no provisioning
  action occurred on a conflict-retry; no applicable event_type exists).

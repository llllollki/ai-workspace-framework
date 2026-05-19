# 0007 — CRM Owner Provisioning Token Mechanism

**Date:** 2026-05-18
**Status:** proposed
**Supersedes:** The provisioning mechanism TODO in ADR 0006 Section 1 ("TODO: The exact mechanism by which a CRM provisioning action creates a tracker app account is unresolved.")
**Superseded by:** n/a

## Context

ADR 0006 (accepted 2026-05-18) resolved the conceptual business flow for CRM-initiated facility owner provisioning: CRM staff triggers the creation of an `invited` owner account in the tracker app; the system sends an email with an opaque, expiring, one-time-use deep link; the owner activates via that link. ADR 0006 explicitly deferred the implementation mechanism:

> "The exact mechanism by which a CRM provisioning action creates a tracker app account is unresolved. Options include: (a) Supabase Auth invite API triggered server-side; (b) a custom `invited_accounts` or `provisioning_tokens` table populated by a CRM-to-tracker service; (c) a manual step by internal staff using a tracker app admin interface separate from the CRM. The choice has security and architecture implications — it must be decided before implementation."

This ADR resolves that blocker by selecting the provisioning mechanism, specifying the token lifecycle rules, defining the activation sequence, and documenting the data model requirements.

### Constraints in scope

1. CRM must remain forward-write-only. It must not read, display, cache, infer, or store resident care data.
2. Deep links must use opaque, expiring tokens. The URL must not contain facility IDs, resident IDs, family IDs, care categories, or any identifiable information.
3. Token lifecycle (expiry, resend, revocation) must be under tracker-side control, fully auditable, and implemented with hashed-storage semantics (raw token never stored).
4. The CRM-to-tracker boundary must be maintained: CRM triggers provisioning through a defined API boundary; all token creation, email delivery, and account activation logic runs on the tracker side.
5. Owner account activation must not grant CRM access (ADR 0006 Section 3).
6. No application code is implemented in this ADR — this is an architecture/design decision record only.

---

## Options Considered

### Option A — Supabase Auth invite API (`auth.admin.inviteUserByEmail`)

Supabase provides `auth.admin.inviteUserByEmail()`, which creates an auth user in a pending/invited state and sends an invitation email with Supabase's internal magic-link token.

**How it would work:** The CRM backend (or a shared service function) calls the Supabase Admin API with the owner's email. Supabase creates the `auth.users` entry immediately and sends an invitation email with Supabase's internal token. The owner clicks the link, sets a password, and the Supabase auth flow completes.

**Pros:**
- Native Supabase feature; minimal custom token code required.
- Supabase manages email delivery and token lifecycle internally.

**Cons:**
- The CRM must call the Supabase Admin API using the tracker's Supabase **service-role key**. This means the CRM holds a service-role key for the tracker database — a significant security coupling. If the CRM is ever compromised, the attacker has service-role access to the entire tracker Supabase project.
- The Supabase Auth invitation token is internal to Supabase and not stored in a custom table. Custom audit events (resend, revocation, expiry, activation) cannot be recorded without building workarounds on top of Supabase's API.
- Resend requires calling `inviteUserByEmail` again (behavior varies by Supabase version; may create duplicate users or silently extend the existing token).
- Revocation requires `auth.admin.deleteUser()` or `auth.admin.updateUserById()` — complex and not audit-friendly.
- The `auth.users` entry is created at provisioning time, before the owner activates. Cleanup on revocation is manual.
- Custom activation states (`invited`, `password_pending`, `active`) in the tracker `User` table must be maintained separately alongside Supabase's internal state — two sources of truth.
- **Key risk: The CRM/tracker boundary.** Giving CRM the tracker service-role key violates the spirit of the boundary established in ADR 0005. A compromised CRM becomes a compromised tracker backend.

**Verdict:** Does not satisfy the CRM/tracker boundary requirement. The service-role key coupling is unacceptable.

---

### Option B — Custom `provisioning_tokens` table (tracker-side, preferred)

A tracker-internal provisioning API endpoint accepts a provisioning request from the CRM. The tracker backend generates an opaque token, hashes it, stores it in a `provisioning_tokens` table, creates a `User` row in `invited` state, and sends the activation email via a transactional email service. The Supabase Auth user (`auth.users` entry) is deferred — it is created at activation time when the owner sets their password, using the Supabase Admin API `auth.admin.createUser()` within the tracker backend.

**Pros:**
- CRM does not hold tracker Supabase credentials. CRM calls a tracker-controlled API endpoint; the endpoint uses its own Supabase service-role key internally.
- Full control over token lifecycle: expiry period, resend, revocation, and audit events are all tracker-managed.
- Raw token never stored — only its SHA-256 hash. The URL is the only place the raw token appears.
- Custom account states (`invited` → `password_pending` → `active`) are fully tracked in the tracker `User` table without Supabase state ambiguity.
- Supabase Auth user created only on successful activation — no phantom auth entries for unactivated or revoked accounts.
- Every provisioning lifecycle event (provisioned, resent, revoked, activated, activation failed) can be written to a `ProvisioningEvent` append-only audit table.
- The `ProvisioningToken` conceptual entity is already modeled in `data_model.md` — this ADR formalizes and promotes it.

**Cons:**
- More implementation work than Option A: custom token generation, hash storage, email delivery service integration, activation endpoint.
- Requires selecting and configuring a transactional email service for the activation email (Resend, SendGrid, Postmark, or Supabase transactional emails).
- The CRM-to-tracker provisioning API endpoint is a new interface point that must be authenticated and hardened (service-to-service auth is a TODO).
- Supabase Admin API `auth.admin.createUser()` call at activation time is still required, but is isolated to the tracker backend activation endpoint and never exposed to the CRM.

**Verdict:** Preferred. Clean CRM/tracker boundary, full auditability, correct security model.

---

### Option C — Manual admin step (tracker admin interface)

Internal ALH Tracker staff create the owner account directly in a dedicated tracker admin interface, then manually share an activation link.

**Verdict:** Does not scale, error-prone, no automated audit trail. Excluded.

---

### Option D — Hybrid: Supabase invite for email + custom token state table

Use `inviteUserByEmail` purely for email delivery but maintain a parallel custom token state table for lifecycle management.

**Verdict:** Duplicates token state across two systems, introduces sync complexity, and retains the CRM service-role key coupling from Option A. Complexity exceeds Option B with no clear benefit. Excluded.

---

## Decision

**Selected: Option B — Custom `provisioning_tokens` table (tracker-side).**

Rationale:
1. The CRM/tracker boundary (ADR 0005) requires that the CRM not hold tracker Supabase service-role credentials. Option B achieves this by exposing a tracker-controlled provisioning API endpoint that the CRM calls.
2. Token lifecycle auditability (resend, revocation, expiry, activation) is a first-class requirement. Option B provides full control; Option A cannot satisfy this without significant workarounds.
3. Deferring Supabase Auth user creation to activation time is architecturally cleaner: provisioning creates a tracker-side pending identity record; the auth account is created only on successful owner activation.
4. The `ProvisioningToken` conceptual entity already exists in `data_model.md` — Option B formalizes it.

---

## Provisioning Sequence

### Phase 1 — CRM provisioning action (CRM desktop, ALH Tracker internal staff)

1. CRM staff navigates to the facility record and initiates "Provision tracker account" for the facility owner.
2. CRM sends a provisioning request to the tracker provisioning API endpoint. The request includes: owner email, owner name, and the CRM facility identifier (for correlation).
   - The provisioning API endpoint is authenticated via a service-to-service mechanism. **TODO: authentication method unresolved — options include rotating API key or short-lived service JWT. Decide before the provisioning API is built.**
   - This endpoint is not accessible to facility users, caregivers, or family users — it is an internal service endpoint only.
3. Tracker backend executes all of the following:
   a. Creates or resolves the tracker `Facility` record. **TODO: whether the tracker Facility record is created at provisioning time or must pre-exist is unresolved — see Open Implementation TODOs.**
   b. Creates a tracker `User` row: `email = owner_email`, `name = owner_name`, `role = owner`, `account_status = invited`, `facility_id = tracker_facility_id`.
   c. Generates an opaque activation token: 32 cryptographically random bytes → lowercase hex string (64 characters). Uses a cryptographically secure random source (e.g., `crypto.randomBytes(32).toString('hex')` in Node.js).
   d. Hashes the token: `SHA-256(raw_token)` → stored as `token_hash` in the `ProvisioningToken` row. The raw token is not stored anywhere server-side.
   e. Creates a `ProvisioningToken` row: `user_id`, `facility_id`, `token_hash`, `expires_at = NOW() + 72 hours`, `used_at = NULL`.
   f. Constructs the activation link: `https://[tracker-domain]/activate?t=[raw_token]`. No facility ID, user ID, resident ID, or identifiable information in the URL.
   g. Sends the activation email to the owner's email address via a transactional email service. **TODO: email service selection unresolved — see Open Implementation TODOs.**
   h. Writes a `ProvisioningEvent` record: `event_type = provisioned`, `user_id`, `facility_id`, `performed_by = crm_staff_id`, `performed_by_type = crm_staff`, `timestamp`.
4. Tracker API response to CRM: `{ "provisioning_reference": "[opaque_reference_id]", "status": "invited" }`.
   - CRM stores `provisioning_reference` (an opaque correlation ID, not a token, not a care-data reference) and updates `provisioning_status = invited` on the CRM facility record.
   - CRM never receives the raw token, the token hash, the tracker User ID, or any care data.

### Phase 2 — Owner activation (triggered by the confirmation email)

5. Owner receives the activation email and clicks the deep link.
6. Deep link routing (per ADR 0006 Section 2 — distribution assumption: native iOS/Android):
   - App not installed → App Store (iOS) or Google Play (Android). **TODO: native distribution ADR required before this routing can be implemented. See Open Implementation TODOs.**
   - App installed + `account_status = invited` or `password_pending` → app opens to the create-password / account-activation screen.
   - App installed + `account_status = active` → app opens to the login page.
7. Activation screen: owner enters password + confirms profile information (full name, phone, facility relationship/role, mailing or business address; occupation/title optional).
8. Tracker backend activation endpoint:
   a. Receives `t=[raw_token]` from the URL query parameter.
   b. Computes `SHA-256(raw_token)`.
   c. Looks up `ProvisioningToken WHERE token_hash = [computed_hash] AND used_at IS NULL AND expires_at > NOW()`. Uses constant-time comparison to prevent timing attacks.
   d. **If no matching token:** Returns an error. If the token appears to have expired (hash found but `expires_at <= NOW()`), surfaces a resend prompt. If hash not found or token malformed, surfaces a generic invalid-link error. **Do not distinguish used vs. expired vs. invalid in user-facing messages** (prevents token oracle attacks).
   e. **If matching token found:** Updates `User.account_status = password_pending`.
   f. Validates owner-submitted password (minimum complexity: 12+ characters with at least one uppercase, lowercase, and digit — per `compliance_notes.md` password policy).
   g. Calls Supabase Admin API `auth.admin.createUser({ email, password, email_confirm: true })` to create the Supabase Auth user. This call runs server-side only, never from a browser client.
   h. Updates `User.account_status = active`.
   i. Marks `ProvisioningToken.used_at = NOW()`.
   j. Writes `ProvisioningEvent: event_type = activated`, `performed_by_type = owner`.
   k. Issues a Supabase session for the new auth user.
9. Owner is logged in with full Facility Tracker App access for their facility. Owner's tracker app account does not grant CRM access (ADR 0006 Section 3).

### Phase 3 — Token resend (CRM staff action)

10. CRM staff triggers "Resend activation email" for an owner with `provisioning_status = invited`.
11. Tracker provisioning API:
    a. Finds any active `ProvisioningToken` for that `user_id` where `used_at IS NULL` and expires it immediately: `expires_at = NOW()`.
    b. Generates a new token (steps 3c–3e from Phase 1).
    c. Sends a new activation email.
    d. Writes `ProvisioningEvent: event_type = token_resent`, `performed_by_type = crm_staff`.
12. CRM record: `provisioning_status` remains `invited`.

### Phase 4 — Invitation revocation (CRM staff action)

13. CRM staff triggers "Revoke invitation" for an owner still in `invited` state (has not yet activated).
14. Tracker provisioning API:
    a. Finds the active `ProvisioningToken` and expires it immediately: `expires_at = NOW()`.
    b. Updates `User.account_status = disabled`.
    c. Writes `ProvisioningEvent: event_type = token_revoked`, `performed_by_type = crm_staff`.
15. CRM record: `provisioning_status = revoked`.

---

## Token/Security Model

| Property | Specification |
|---|---|
| Format | 32 cryptographically random bytes encoded as lowercase hex (64 characters). Hex is URL-safe without percent-encoding. Never base64url — hex avoids padding and case-sensitivity issues in URLs. |
| Storage | SHA-256 hash of the raw token stored in `ProvisioningToken.token_hash`. Raw token never stored server-side. Raw token appears only in the activation URL. |
| Expiry | 72 hours from creation (`expires_at = created_at + 72h`). Chosen to allow facility owners reasonable time to check email without creating a long-lived attack surface. |
| One-time use | `used_at` column. Activation lookup always includes `AND used_at IS NULL`. Set atomically at successful activation. |
| Resend | Previous active token is expired (`expires_at = NOW()`). New token generated and emailed. Rate limiting recommended: maximum 3 resends within 24 hours per owner account. **TODO: exact rate-limit implementation unresolved.** |
| Revocation | CRM staff action via the revocation endpoint. Token expired; `User.account_status = disabled`. |
| URL structure | `https://[tracker-domain]/activate?t=[raw_token]`. No facility ID, user ID, resident ID, family ID, care category, or any identifiable data in URL. |
| Lookup method | Constant-time SHA-256 hash comparison using `crypto.timingSafeEqual` (Node.js) or equivalent. Prevents timing-based token enumeration. |
| Email delivery | Sent to the owner's pre-recorded email address only. Sender domain must have SPF, DKIM, and DMARC configured. **TODO: email service selection and sender domain configuration unresolved.** |
| Expired token UX | "This link has expired. Request a new activation email." Do not reveal whether the token was used or merely expired. |
| Invalid/used token UX | "This activation link is invalid or has already been used. Contact ALH Tracker support." Do not distinguish invalid from used in user-facing messages — prevents token oracle attacks. |

---

## Data Model Impact

### ProvisioningToken — promoted from conceptual to specified

The "TODO — Conceptual, Not Yet Implemented" designation in `data_model.md` is removed. This entity is required before provisioning can be implemented. The field definitions below supersede the conceptual stub.

| Field | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| user_id | UUID FK | → User (the invited owner account) |
| facility_id | UUID FK | → Facility |
| token_hash | TEXT | SHA-256 hex digest of the raw activation token. Raw token never stored. |
| expires_at | TIMESTAMPTZ | Token invalid after this time. Set to `NOW() + 72h` at creation. Set to `NOW()` to expire immediately (resend/revocation). |
| used_at | TIMESTAMPTZ | NULL until activation is completed. Set atomically at the end of successful activation. |
| created_at | TIMESTAMPTZ | Record creation time. |

**Access control:** This table must not be accessible via any client-side Supabase query. All reads and writes must go through tracker backend server-side functions using the Supabase service-role key. RLS must deny all client-originated access.

---

### ProvisioningEvent — new append-only audit table

Append-only record of all provisioning lifecycle events. Follows the same append-only constraint as `AuditTrail`: no UPDATE or DELETE permitted at the database level. Separate from `AuditTrail` because provisioning is an account lifecycle concern, not a care-operations entity.

| Field | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_type | ENUM | `provisioned`, `token_resent`, `token_revoked`, `token_expired_passive`, `activated`, `activation_failed` |
| user_id | UUID FK | → User (the owner being provisioned) |
| facility_id | UUID FK | → Facility |
| performed_by | TEXT | CRM staff identifier (for CRM-triggered events) or tracker user_id (for owner activation). Stored as opaque reference. |
| performed_by_type | ENUM | `crm_staff` or `owner` |
| token_id | UUID FK nullable | → ProvisioningToken.id. Null for passive/derived events (e.g., `token_expired_passive` has no explicit trigger). |
| metadata | JSONB nullable | Additional context (e.g., failure reason for `activation_failed`). Must not contain PHI, care data, raw tokens, or facility care identifiers. |
| created_at | TIMESTAMPTZ | Event timestamp. Append-only — no updates or deletes. |

**Access control:** Append-only. Same database-level enforcement as `AuditTrail`: revoke UPDATE and DELETE on this table from the application user; use a write-only role for inserts.

---

### User entity — clarification

The `account_status` field and `AccountStatus` enum are already modeled in `data_model.md` (added per ADR 0006). No new fields are required on `User` for this ADR.

**`User.created_by` for CRM-provisioned accounts:** The `created_by` field currently references a tracker `User` ID, but CRM staff are not tracker users. This requires a resolution at implementation time. **TODO: define `created_by` behavior for CRM-provisioned User rows — options: a sentinel system user ID, a nullable `created_by` with a non-null `crm_provisioned = true` flag, or a separate `provisioned_by_type` column.**

---

### CRM entity additions (informational — CRM entity model is separate from tracker schema)

The following fields should be added to `CrmFacility` when CRM persistence is implemented. These are the only provisioning-related fields stored in the CRM.

| Field | Notes |
|---|---|
| `provisioning_reference` | Opaque correlation ID returned by the tracker provisioning API. Not a token, not a tracker user ID, not a care-data reference. Stored for operational correlation only. |
| `provisioning_status` | Enum: `not_started`, `invited`, `activation_pending`, `active`, `revoked`. Managed by the CRM; updated based on tracker provisioning API responses. |

**Hard constraint:** CRM must not store the activation token, the token hash, the tracker `User` ID, the tracker `Facility` ID, resident IDs, or any resident care data.

---

## Audit/Event Requirements

| Event | Trigger | What is recorded |
|---|---|---|
| `provisioned` | CRM staff provisioning action | event_type, user_id, facility_id, performed_by=crm_staff_id, performed_by_type=crm_staff, timestamp |
| `token_resent` | CRM staff resend action | event_type, user_id, facility_id, performed_by=crm_staff_id, performed_by_type=crm_staff, timestamp |
| `token_revoked` | CRM staff revocation action | event_type, user_id, facility_id, performed_by=crm_staff_id, performed_by_type=crm_staff, timestamp |
| `activated` | Owner completes activation | event_type, user_id, facility_id, performed_by=user_id, performed_by_type=owner, token_id, timestamp |
| `activation_failed` | Owner submits invalid/expired/used token | event_type, user_id (if derivable), token_id (if known), metadata=failure_reason. metadata must not contain the raw token or care data. |

All events are written to `ProvisioningEvent`. The table is append-only. No event record may be updated or deleted.

---

## Deep-Link Routing Behavior

| State | Behavior |
|---|---|
| App not installed | **TODO: Native distribution ADR required before this routing can be implemented.** Proposed behavior (assumes native distribution): route to App Store (iOS) or Google Play (Android). If PWA is decided: route to tracker web activation URL directly. |
| App installed + `account_status = invited` | App opens to activation screen (create-password + profile confirmation) |
| App installed + `account_status = password_pending` | App opens to activation screen (resume from password creation step) |
| App installed + `account_status = active` | App opens to login page |
| Token expired | Activation screen shows expired-link message with resend prompt |
| Token used or invalid | Activation screen shows generic invalid-link error with support contact |

**iOS vs. Android deep link mechanics:** iOS Universal Links require an `apple-app-site-association` (AASA) file served from the activation domain. Android App Links require a `assetlinks.json` file. Both must be configured and deployed before the app is submitted to the stores. **TODO: separate implementation task required; not resolved in this ADR.**

---

## Non-Goals

This ADR does not define or change:
- The CRM authentication model for ALH Tracker internal staff (separate TODO per ADR 0005 Section 2).
- The native vs. PWA app delivery model (pending ADR candidate — see `decisions/README.md`).
- iOS Universal Links or Android App Links server-side configuration (implementation TODO).
- The CRM-to-tracker provisioning API authentication mechanism (service-to-service auth is a TODO).
- Caregiver and admin account creation flows — those accounts are created directly within the tracker app and do not go through this provisioning flow.
- FamilyUser account activation — that is a separate flow defined in ADR 0006 Sections 5–8.
- The CRM data boundary (ADR 0005) or family access architecture (ADR 0004) — those remain unchanged.

---

## Consequences

**Easier:**
- The CRM/tracker boundary is maintained cleanly. CRM calls a defined API endpoint; all token, auth, and audit logic is tracker-owned. No tracker Supabase credentials are exposed to the CRM.
- Full token lifecycle audit is achievable with the `ProvisioningEvent` append-only table.
- The Supabase Auth user is created only on successful activation — no phantom auth accounts for unactivated or revoked owners.
- Token security properties (opaque, expiring, one-time-use, hashed storage, constant-time lookup) are fully specified and implementable without dependency on Supabase's internal invitation token mechanics.
- The `ProvisioningToken` entity already existed as a conceptual model in `data_model.md` — this ADR formalizes it.

**Harder:**
- Implementing a tracker provisioning API endpoint with its own service-to-service authentication adds complexity vs. using Supabase's built-in invitation flow.
- A transactional email service must be selected and configured for the activation email.
- Token generation, SHA-256 hashing, and constant-time comparison add implementation steps.
- The `ProvisioningEvent` append-only audit table is a new table with the same write-once constraints as `AuditTrail`, requiring explicit database-level enforcement.
- The activation deep link requires server-side hosting of the AASA and Digital Asset Links files for native iOS/Android distribution — a separate implementation prerequisite.

---

## Open Implementation TODOs

- **TODO — CRM-to-tracker provisioning API authentication:** The provisioning API endpoint must authenticate the CRM's request. Options: rotating API key (simplest; requires key management), short-lived service JWT (more secure; requires a token exchange service). Must be decided and implemented before the provisioning API is built.
- **TODO — Transactional email service:** Select and configure the email delivery service for activation emails (Resend, SendGrid, Postmark, or Supabase transactional emails). Must include SPF, DKIM, and DMARC configuration for the sender domain before the activation email can be sent.
- **TODO — Facility record creation at provisioning:** When the CRM provisions the owner's account, does the tracker `Facility` record already exist (created by a separate internal process), or is it created as part of the provisioning API call? If created at provisioning time, what is the minimum required facility data? This sequencing dependency must be resolved before the provisioning API is built.
- **TODO — `User.created_by` for CRM-provisioned accounts:** The `created_by` field on `User` references a tracker `User` ID, but CRM staff are not tracker users. Define the sentinel or structural behavior.
- **TODO — Token resend rate limit:** Maximum resends per owner account within a time window to prevent inbox spam. Recommended: 3 resends per 24 hours per account. Implementation details pending.
- **TODO — Native distribution ADR:** App Store / Google Play routing in the deep link requires the app delivery model decision (native vs. PWA) to be formalized in a separate ADR before this routing behavior can be implemented.
- **TODO — iOS Universal Links / Android App Links:** Server-side AASA file and Digital Asset Links file configuration required before native app submission. Not resolved in this ADR.
- **TODO — `activation_failed` metadata security:** Ensure `activation_failed` event metadata never includes the raw token, PII beyond user_id, or any resident/care data.
- **TODO — Token expiry period validation:** 72 hours is recommended. Validate with the product team that this is appropriate for the target user (facility owners who may be slow to check email, especially during busy periods).
- **TODO — Provisioning API response reference format:** Define the exact format of `provisioning_reference` returned to the CRM — UUID, opaque slug, or other. Must be opaque and not encode tracker-internal IDs.

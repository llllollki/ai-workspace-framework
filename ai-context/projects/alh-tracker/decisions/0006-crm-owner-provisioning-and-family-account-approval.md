# 0006 — CRM Owner Provisioning and Family Account Approval

**Date:** 2026-05-18
**Status:** accepted
**Supersedes:** The pending TODO in ADR 0005 Section 4 (provisioning handshake implementation details)
**Superseded by:** n/a

## Context

ADR 0005 Section 4 established the principle that the CRM kicks off the facility owner's tracker app account setup, but deferred implementation details with a TODO: "Implementation details of the provisioning handshake (invite token format, delivery mechanism, first-login confirmation) are pending CRM design."

ADR 0004 established that family contacts do not have records in the facility-facing `User` table and must authenticate via a separate mechanism. However, it did not define a family account creation flow — it described the grant flow as beginning with an operator action that pre-supposes the family member already has a usable identity.

Two new flows are now defined at a conceptual architectural level:

1. **CRM owner provisioning:** CRM staff creates the facility owner's Facility Tracker App account (not just sends install instructions). The owner activates via a deep link sent to their email.

2. **Family self-signup:** A family member may create a Family Member App account (identity only) before the facility owner approves their access. Account existence does not grant any resident data access.

This ADR records the durable architectural decisions being made for both flows. Implementation details (token storage mechanism, specific API calls, exact database fields) remain deferred and are marked as TODOs.


---

## Decision

### 1. CRM staff creates the facility owner's tracker app account

CRM staff provision a Facility Tracker App account for the facility owner as part of the onboarding flow. This is a forward write from CRM operations into the tracker app's user provisioning system. The CRM does not read from or write directly to tracker app care data tables — the provisioning action is limited to creating an invited account record in the tracker app.

**What "provisioning" means at this level:**
- CRM staff trigger an account creation in the tracker app for the facility owner.
- The created account is in a `pending` or `invited` state — the owner has not yet set a password.
- The account is associated with the correct facility and assigned the `owner` role.

**What CRM provisioning does not do:**
- CRM staff do not gain access to tracker app care data, resident records, or shift logs by performing this action.
- The provisioning action is a forward write only — the CRM does not read back from the tracker app database.
- The CRM record and the tracker app account are separate records; the tracker app Facility record carries an opaque correlation reference only (per ADR 0005 Section 4).

**TODO:** The exact mechanism by which a CRM provisioning action creates a tracker app account is unresolved. Options include: (a) Supabase Auth invite API triggered server-side; (b) a custom `invited_accounts` or `provisioning_tokens` table populated by a CRM-to-tracker service; (c) a manual step by internal staff using a tracker app admin interface separate from the CRM. The choice has security and architecture implications — it must be decided before implementation. See `ai_memory.md`.

### 2. Owner activation uses a deep link with an opaque, expiring token

After the CRM provisions the owner's account, the system sends a confirmation email to the facility owner's email address. The email contains an activation deep link.

**Token properties:**
- Opaque: the token is a random, unguessable identifier with no embedded data.
- The deep link does not contain facility IDs, resident IDs, care data, family IDs, or any identifiable information in the URL.
- Expiring: the token has a defined expiry period after which it is invalid.
- One-time-use: once the activation flow is completed, the token cannot be reused.

**Deep link routing behavior (proposed — native distribution assumed):**

When the deep link is clicked:
- If the app is not installed: the owner is routed to the App Store (iOS) or Google Play (Android) to download and install the app.
- If the app is installed and the owner has not yet set a password: the app opens to the create-password / account-activation screen.
- If the app is installed and the account is already active: the app opens to the login page.

**Distribution assumption:** The App Store / Google Play routing above assumes native iOS/Android distribution. The app delivery model (PWA vs. native vs. web + redirect) is a pending ADR candidate (see `decisions\README.md`). This provisioning flow is documented as the proposed/assumed behavior — native distribution must be formalized in a separate ADR before this routing behavior is implemented.

**iOS Universal Links vs. Android App Links:** Deep link routing works differently on iOS (Universal Links) and Android (App Links). This difference affects how the token/redirect architecture must be built and requires implementation-level design before Phase 2. See `ai_memory.md`.

**TODO — token implementation details:** Token expiry period, resend behavior (can the facility owner request a new activation link?), revocation (can CRM staff cancel an unactivated invite?), and storage mechanism are unresolved.

### 3. The owner's tracker app account does not grant CRM access

The facility owner's Facility Tracker App account is scoped to the facility tracker app. It provides no access to the internal CRM. CRM and tracker app are separate surfaces with separate authentication models, per ADR 0005 Section 2. This must be enforced at the authentication and authorization layer — a tracker app session must never grant CRM surface access.

### 4. Owner account profile fields

When a facility owner activates their account, the following profile information is collected (fields marked TODO require further design):

| Field | Status |
|---|---|
| Full name | Required |
| Phone number | Required |
| Email address | Required (pre-populated from CRM provisioning) |
| Facility relationship/role (owner, administrator, manager, etc.) | Required |
| Mailing or business address | Required |
| Occupation/title | Optional |
| Facility association | Required (established at provisioning; confirmed at activation) |
| Account status | System-managed: `invited` → `password_pending` → `active` → `disabled` |

**TODO:** Whether identity verification, license/administrator credential check, or signed agreement reference is required before full access is granted is unresolved. No identity verification mechanism is defined in this ADR.

### 5. Family self-signup creates a FamilyUser identity record before approval

A family member may install the Family Member App and create an account before the facility owner/admin has approved their access. Account creation creates a `FamilyUser` identity record only — it does not grant any resident data access.

**FamilyUser entity (identity record — see `data_model.md` for full entity definition):**
- Represents the family member's account in the Family Member App.
- Is NOT a record in the facility-facing `User` table (per ADR 0004 Section 7).
- Is NOT a `FamilyAccessConsent` record — it carries no authorization to view resident data.
- Has its own authentication mechanism separate from the tracker app staff authentication.

**What a FamilyUser account does:**
- Allows the family member to log in to the Family Member App.
- Allows the family member to submit a request for access to a specific resident (if request-based access is allowed — TODO).
- Allows the family member to be found and selected by an owner/admin in the grant flow (Flow 12).

**What a FamilyUser account does not do:**
- Does not grant access to any resident wellbeing data, care logs, wellness observations, or notifications.
- Does not create a `FamilyAccessConsent` record.
- Does not appear in the facility-facing staff user management screens.

### 6. Family member account profile fields

When a family member creates a FamilyUser account, the following profile information may be collected (fields marked TODO require further design):

| Field | Status |
|---|---|
| Full name | Required |
| Phone number | Required |
| Email address | Required |
| Relationship to resident | Required |
| Address | Required — TODO: whether required for all accounts or only for identity/relationship verification is unresolved |
| Occupation | Optional — TODO: whether needed at all or only for identity context is unresolved |
| Resident they are requesting access to | TODO: only collected if request-based access is allowed |
| Facility association | Optional (if known at signup) |
| Preferred notification method | Collected at signup |
| Emergency/contact role | Optional (if applicable) |
| Privacy/release status | Optional (if known or facility-confirmed) |

**Labeling guardrail:** Do not label occupation, address, relationship, emergency contact role, or privacy/release status in a way that implies legal authority, HIPAA validation, or consent verification unless counsel approves exact language. Government/legal representative status must not be implied.

**TODO:** Whether identity verification is required before a FamilyUser account is approved, and who performs that verification, is unresolved.

**TODO:** Whether family members must be invited by owner/admin before they can create a FamilyUser account, or may create one independently, is unresolved.

### 7. FamilyUser is separate from User and from FamilyAccessConsent

Three distinct entities govern family access:

| Entity | Type | Purpose |
|---|---|---|
| `FamilyUser` | Identity | The family member's app account. Created at self-signup or upon invitation. No data access granted. |
| `FamilyAccessConsent` | Authorization | Operator-granted permission for a specific FamilyUser to see specific categories of data for a specific resident. Requires dual acknowledgment per ADR 0004. |
| `User` | Facility staff | Facility owner, admin, caregiver, or med tech. FamilyUser must NOT be added to this table. |

This separation maintains the ADR 0004 Section 7 constraint that family contacts are not User entity records.

### 8. Family members receive no resident data until explicit owner/admin approval

A FamilyUser who has created an account but has no active `FamilyAccessConsent` record sees no resident wellbeing data, no care log summaries, no wellness observations, and receives no resident-related notifications. The app UI presents a pending/no-access state after login.

When an owner/admin creates a `FamilyAccessConsent` record for the FamilyUser (per ADR 0004 dual acknowledgment requirement), the FamilyUser gains access to the approved scope only. All other ADR 0004 constraints apply: always read-only, category-scoped, resident-specific, revocable, audited.

### 9. Owner/admin family access management

Facility owners and admins need a dedicated management surface to:
- Review pending FamilyUser access requests (if request-based — TODO).
- Approve access per resident with category scope and resident autonomy notation (per ADR 0004 Flow 12).
- View and manage active grants.
- Revoke access at any time (per ADR 0004 Flow 13).

**TODO:** Whether owner only or both owner and admin may approve family access is unresolved. The current role permissions table allows both — this ADR does not change that but notes it as an open question for counsel or product review.

**TODO:** Whether approval happens at the facility level (owner approves FamilyUser → facility), resident level (owner approves FamilyUser → resident), or both is unresolved.

**TODO:** Behavior when an owner/admin rejects a family access request (notification to FamilyUser, record of rejection) is unresolved.

---

## Consequences

**Easier:**
- CRM provisioning creates a clear, auditable starting point for the facility owner's account — no ambiguity about whether an account exists before the owner clicks a link.
- The deep link routing model gives facility owners a clear, friction-reducing activation path.
- FamilyUser self-signup decouples account creation from access approval, allowing family members to "get ready" before the owner processes their request — reduces back-and-forth.
- The FamilyUser / FamilyAccessConsent / User separation is clean and consistent with ADR 0004.

**Harder:**
- CRM provisioning requires a secure, auditable write path from CRM operations into the tracker app's user provisioning system — this is a new integration point that must be designed to prevent it from becoming a data-sharing path.
- The deep link token lifecycle (expiry, resend, revocation) must be implemented carefully to prevent account takeover or dead links.
- iOS Universal Links and Android App Links have different trust models and require different server-side configuration (Apple App Site Association file, Digital Asset Links file) — this adds implementation complexity before the app can be submitted to the stores.
- Family self-signup without invitation creates a discovery problem: how does a family member find the facility to associate with at signup? This is unresolved and may require either an invitation code, a facility search, or an invitation-only model.
- The FamilyUser pending/no-access state must be clearly communicated in the app so family members understand why they see no data after creating an account.

**Counsel review required before Phase 2 family access goes live.** This ADR records architectural decisions — it does not constitute legal review of the family access model, consent posture, or notification scope.

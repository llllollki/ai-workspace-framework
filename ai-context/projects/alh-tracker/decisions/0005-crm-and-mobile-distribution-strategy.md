# 0005 — CRM and Mobile Distribution Strategy

**Date:** 2026-05-16
**Status:** accepted
**Supersedes:** [0003 — Business Model: ALH Partner Pricing and Shared Onboarding Policy](0003-business-model-alh-pricing.md)
**Superseded by:** n/a

## Context

ADR 0003 established that alh-tracker would operate without a shared onboarding system at MVP, relying on a manually set `alh_partner` flag on the Facility entity to identify ALH partner facilities. As the product moves toward commercial operation, ALH Tracker business/admin staff need a dedicated internal tool to manage facility customer relationships, onboarding, subscriptions, and support — work that cannot be managed long-term via manual flags alone.

At the same time, the product is expanding from a single care-operations surface to a model with three distinct user-facing surfaces:

1. An internal CRM used exclusively by ALH Tracker business/admin staff.
2. The facility tracker app used by facility owners, admins, and caregivers.
3. A family member app (planned Phase 2) for family members with view-only access to approved resident wellbeing data.

These three surfaces have different user populations, different device usage patterns, and different data access requirements. The boundaries between them must be explicitly defined to prevent care data from flowing into commercial or family-facing contexts without explicit policy and technical enforcement.

This decision supersedes ADR 0003's "no shared onboarding system at MVP" stance. The data boundary principle from ADR 0003 remains in full force.

## Decision

### 1. Three-surface product model

ALH Tracker operates with three distinct product surfaces. Each has a defined user population, device policy, and data access scope:

| Surface | Users | Device Policy | Data Scope |
|---|---|---|---|
| **Internal CRM** | ALH Tracker business/admin staff only | Desktop-only | Commercial relationship data only — no resident care data |
| **Facility Tracker App** | Facility owners, admins, caregivers, med techs | Mobile/tablet-first; desktop users directed to use phone/tablet | Full care-operations data for authenticated facility |
| **Family Member App** | Family members authorized per resident | Mobile/tablet-first; desktop users directed to use phone/tablet | View-only, operator-authorized resident wellbeing summaries |

### 2. Internal CRM is a separate product surface

The CRM is an internal ALH Tracker business tool — it is not a care-delivery surface and is not accessible to facility owners, caregivers, or family members. CRM users (ALH Tracker business/admin staff) are not User records in the facility-facing alh-tracker User table. They are a separate principal class with their own authentication model.

**TODO:** CRM user authentication model is pending CRM design.

The CRM manages commercial relationship data only: facility owner/customer profiles, facility records, allowable resident count configuration (see TODO below), onboarding status, subscription/payment status, communications with facility owners, and internal support/admin notes.

**TODO:** "Allowable resident count" in the CRM may refer to licensed facility capacity, subscription-tier resident limit, or active resident count — or all three as separate tracked fields. This distinction is unresolved and must be decided before CRM design begins.

### 3. CRM does not expose resident care data

CRM users have no read access to care log tables, resident wellness records, shift logs, handoff records, observed care task records, or any resident-identifiable care data in the tracker app database. This is a hard architectural constraint identical in principle to ADR 0001's boundary between alh-tracker and the AssistedLivingHelp placement platform: resident care data must not flow to the CRM under any circumstance without explicit policy approval, legal review, and technical enforcement.

Whether internal support staff may ever access resident-level care data for support purposes — and under what audited policy — is an open question. See `ai_memory.md`. That access must not be enabled by default or by CRM design.

### 4. CRM-to-tracker provisioning (principle)

The onboarding flow begins in the CRM: internal staff creates the facility/customer record, configures the allowable resident count, and provisions a Facility Tracker App account for the facility owner (as owner/admin role). This provisioning action creates a pending/invited account in the tracker app. The tracker app Facility record carries an opaque reference to the CRM customer record for operational correlation only — this reference is not a data-sharing path. The CRM does not read from the tracker app database.

**Provisioning flow (conceptual — see ADR 0006 for full decision):**
1. CRM staff creates the facility customer record and configures the subscription.
2. CRM staff provisions a Facility Tracker App account for the facility owner (pending/invited state).
3. The system sends a confirmation email to the facility owner containing an opaque, expiring, one-time-use deep link for account activation.
4. The deep link does not contain facility IDs, resident IDs, or any care data.
5. When clicked, the deep link routes based on app installation state:
   - If the app is not installed: routes to the App Store or Google Play (see distribution assumption note below).
   - If the app is installed and no password has been set: opens to the account-activation / create-password screen.
   - If the app is installed and the account is already active: opens to the login page.
6. After successful login, the owner has full Facility Tracker App capability for that facility.
7. The owner's tracker app account does not grant CRM access — the CRM and tracker app are separate surfaces with separate authentication models.

**Distribution assumption:** Step 5 describes App Store / Google Play routing, which assumes native iOS/Android distribution. The app delivery model (PWA vs. native vs. web + redirect) is not decided in this ADR. It is a pending ADR candidate listed in `decisions\README.md`. Document this as the proposed/assumed provisioning flow — native distribution must be formalized before implementation.

**Implementation TODOs (not resolved in this ADR or ADR 0006):** Token expiry rules, one-time-use enforcement, resend behavior, revocation mechanism, whether Supabase Auth invite API or a custom token table is used, iOS Universal Links vs. Android App Links behavior difference, and whether one owner account can span multiple facilities are all unresolved. See `ai_memory.md`.

### 5. Payment provider boundary (principle)

The CRM will manage payment and subscription status metadata. Raw payment credentials (card numbers, bank account details) must not be stored in the CRM directly. Any future payment provider integration will use the provider's opaque reference identifiers only.

**TODO:** Specific payment provider, which fields are stored locally versus at the provider, and the full billing data model are unresolved. No payment provider is selected.

### 6. Mobile/tablet-first distribution policy

The facility tracker app and the family member app are mobile/tablet-first. Facility owners, caregivers, and family members who access these apps from a desktop browser should be presented with a page directing them to download/install/open the app on a phone or tablet.

This is a distribution policy, not a security control and not a compliance measure. It must not be documented or implemented as a privacy or access-control guardrail.

**TODO:** Whether desktop access for these apps is a hard block (no desktop access at all) or a soft redirect (nudge to use mobile, with desktop fallback) is unresolved. Whether facility owner/admin roles need any desktop access for administrative tasks (facility setup, user management) is also unresolved.

The internal CRM is desktop-only. It is not accessible or useful from mobile devices.

### 7. Supersedes ADR 0003

ADR 0003 decided that alh-tracker would use no shared onboarding system at MVP. This decision supersedes that stance: an internal CRM for ALH Tracker business operations is now a planned product surface that manages onboarding, subscription, and customer records. The data boundary principle from ADR 0003 remains: the CRM does not create a shared integration between alh-tracker and the AssistedLivingHelp placement platform.

## Consequences

**Easier:** The three-surface model explicitly defines which users belong to which surface, reducing access-control ambiguity. The CRM creates a formal home for commercial relationship data that was previously managed manually via the `alh_partner` flag. The mobile-first distribution policy gives the tracker app and family app a clear device strategy.

**Harder:** Three product surfaces imply three separate authentication systems (CRM staff auth, facility tracker auth, family app auth). Maintaining the data boundary between CRM and tracker app requires consistent enforcement — any support workflow that surfaces care data in the CRM would require formal policy approval, legal review, and technical enforcement. The onboarding provisioning handshake between CRM and tracker app is a new integration point that must be designed to prevent it from becoming a data-sharing path. Whether any facility owner/admin workflows require desktop access must be explicitly resolved before the mobile-first policy is enforced.

Family app authentication model, family-to-facility communications model, and notification architecture are not covered by this decision — they are open questions in `ai_memory.md` pending design and counsel review. Family app data access is governed by ADR 0004.

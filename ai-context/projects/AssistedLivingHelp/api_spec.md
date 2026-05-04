# AssistedLivingHelp — API Specification

> Migrated from `AssistedLivingHelp\CLAUDE.md` — Early Architecture Direction and Backend Functional Requirements sections. Source document retained unchanged.

<!-- TODO: Expand this file with formal API route documentation as the API layer is built out. Use `templates\api_endpoint_v1.md` for each endpoint. -->

## Architecture Direction

### Backend Overview

- API layer for leads, facilities, matching, communication, consent, outreach, and scheduling
- Admin dashboard for internal staff at `admin.AssistedLivingHelp.com`
- Admin-controlled employee account management with username/password credentials
- Workflows for manual lead entry, lead updates, outreach, and appointment lifecycle management
- Partner CRM workflows for sales, onboarding, renewals, and account management

### Database

- Read initially from the current SQLite facility dataset (`facilities_ca.sqlite`)
- Introduce a primary application database for leads, communications, consent, matches, outreach, appointments, and staff workflows
- Build a vetted application-facing facility model from the reliable SQLite subsets
- Optionally migrate normalized facility data later

## Domain Areas Requiring API Coverage

Based on functional requirements, the API must support the following functional areas:

**Lead management:**
- create, read, update leads
- update lead status
- update lead contact data
- update lead intake/profile
- source and campaign tracking

**Facility management:**
- facility list and search
- facility profile read

**Matching:**
- lead-to-facility matching workflow
- match approval, edit, override

**Outreach:**
- facility outreach workflow
- outreach status tracking

**Scheduling:**
- appointment / tour creation and lifecycle management

**Communications:**
- communication event logging
- consent log management

**Notes and activity:**
- notes, tasks, reminders, follow-up queue

**Partner / BD:**
- partner prospect list
- partner account detail
- partner outreach and sales pipeline
- package and add-on tracking
- partner onboarding workflow
- billing-status tracking
- partner performance reporting

**Authentication:**
- public user signup, login, logout, password reset
- admin authentication
- admin-managed employee account creation

Source: `AssistedLivingHelp\CLAUDE.md` — Functional Requirements section

## Route Documentation

### POST /api/leads

**File:** `app/api/leads/route.ts`
**Authentication:** Active staff session cookie required (`getActiveStaffUser`). Returns 401 if not authenticated.

**Purpose:** Staff-authenticated JSON endpoint for programmatic lead creation. Distinct from `POST /api/intake` (public form, redirects) and `createLeadAction` (Server Action, redirects). Intended for internal tooling, programmatic use, and future integrations.

**Request body (JSON):**

| Field | Type | Required | Notes |
|---|---|---|---|
| `firstName` | string | Yes | |
| `lastName` | string | Yes | |
| `email` | string | One of email/phone | |
| `phone` | string | One of email/phone | |
| `preferredContactMethod` | string | No | |
| `relationshipToResident` | string | No | |
| `launchMarketSlug` | string | No | Resolved to `launch_market_id`; null if not found (no 400) |
| `desiredCity` | string | No | |
| `moveInTimeframe` | string | No | |
| `generalCareCategory` | string | No | |
| `budgetMin` | number | No | |
| `budgetMax` | number | No | |
| `wantsSchedulingHelp` | boolean | No | Defaults to false |
| `consentPrivacyAcknowledgment` | boolean | No | Defaults to false |
| `consentContactSupport` | boolean | No | Defaults to false |
| `consentEmail` | boolean | No | Defaults to false |
| `consentSms` | boolean | No | Defaults to false |
| `consentPhone` | boolean | No | Defaults to false |
| `consentFacilitySharing` | boolean | No | Defaults to false |
| `consentSource` | string | No | e.g. `"phone_call"`, `"referral_email"` |
| `consentBasis` | string | No | e.g. `"Family stated permissions verbally"` |

**Responses:**

| Status | Body | Condition |
|---|---|---|
| 201 | `{ "lead_id": "<uuid>" }` | Lead created successfully |
| 400 | `{ "error": "<message>" }` | Missing required fields or invalid JSON |
| 401 | `{ "error": "Authentication required" }` | No active staff session |
| 500 | `{ "error": "Lead creation failed" }` | Database error on insert |

**Side effects on success:**
- Row inserted in `public.leads` with `status = "intake_in_progress"` and `attribution_channel = "manual_entry"`
- Six consent rows inserted in `public.consents` via `buildConsentRows()` with `captured_by_staff_user_id` set
- `status_change` interaction logged in `public.alh_interactions`
- `task` interaction logged with `due_at` 4 hours from creation time
- Initial facility matches seeded via `seedLeadMatchesForStaff()` if market resolved; note logged if any seeded
- Warning note logged if `consentSource` or `consentBasis` absent

**Compliance:** All six consent types are recorded regardless of granted state. `consentFacilitySharing` defaults to false. No facility sharing should occur until that consent is explicitly granted and documented.

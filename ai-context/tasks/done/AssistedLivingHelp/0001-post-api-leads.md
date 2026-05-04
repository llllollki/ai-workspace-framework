# Task 0001 — Implement POST /api/leads

**Project:** AssistedLivingHelp
**Status:** done
**Started:** 2026-05-03
**Completed:** 2026-05-03

---

## Goal

Add `app/api/leads/route.ts` implementing `POST /api/leads` — a staff-authenticated JSON endpoint for programmatic lead creation. It mirrors the logic in `createLeadAction` (consent rows, interaction logging, match seeding) but accepts a JSON body and returns JSON, making it usable for programmatic callers, internal tooling, and future integrations without the redirect behavior of the Server Action.

Distinct from the existing endpoints:
- `POST /api/intake` — public form submission, form-data, redirects to `/confirmation`
- `createLeadAction` — Server Action for admin form, form-data, redirects to `/admin/leads/[id]`

---

## Acceptance Criteria

1. `POST /api/leads` returns `401` with `{ "error": "Authentication required" }` if the caller has no active staff session.
2. `POST /api/leads` returns `400` with `{ "error": "<message>" }` for missing required fields (`firstName`, `lastName`, and at least one of `email` or `phone`).
3. `POST /api/leads` returns `400` if the request body is not valid JSON.
4. On success, returns `HTTP 201` with `{ "lead_id": "<uuid>" }`.
5. A row is inserted into `public.leads` with `attribution_channel = "manual_entry"` and `status = "intake_in_progress"`.
6. Six consent rows are inserted into `public.consents` via `buildConsentRows()` with `capturedByStaffUserId` set to the authenticated staff user's ID.
7. A `status_change` interaction and a `task` interaction (with `due_at` 4 hours out) are logged in `public.alh_interactions`.
8. If a valid `launchMarketSlug` is provided and resolves, `seedLeadMatchesForStaff()` is called and a note is logged for any seeded matches.
9. If `consentSource` or `consentBasis` is missing, a note interaction is logged so staff can follow up.
10. No redirect behavior. All responses are JSON.

---

## Plan

### Files to read
- `app/api/intake/route.ts` — existing API route structure
- `app/admin/(protected)/leads/new/actions.ts` — full lead creation workflow to mirror
- `lib/lead-workflow.ts` — `buildConsentRows`, `seedLeadMatchesForStaff`
- `lib/supabase-server.ts` — `getActiveStaffUser` (not `requireActiveStaffUser`)
- `lib/log-interaction.ts` — `logInteraction` signature
- `lib/types.ts` — `LeadStatus`
- `supabase/schema.sql` — `leads` table columns, RLS policies

### Files to modify
- `app/api/leads/route.ts` — **create new**
- `ai-context\projects\AssistedLivingHelp\api_spec.md` — document new route
- `ai-context\projects\AssistedLivingHelp\execution_log.md` — log implementation activity

### API behavior

```
POST /api/leads
Content-Type: application/json
Authentication: active staff session cookie required

Required body fields:
  firstName  string
  lastName   string
  email      string  (required if no phone)
  phone      string  (required if no email)

Optional body fields:
  preferredContactMethod    string
  relationshipToResident    string
  launchMarketSlug          string  (resolved to launch_market_id; null if not found)
  desiredCity               string
  moveInTimeframe           string
  generalCareCategory       string
  budgetMin                 number
  budgetMax                 number
  wantsSchedulingHelp       boolean
  consentPrivacyAcknowledgment  boolean
  consentContactSupport         boolean
  consentEmail                  boolean
  consentSms                    boolean
  consentPhone                  boolean
  consentFacilitySharing        boolean
  consentSource             string  (e.g. "phone_call", "referral_email")
  consentBasis              string  (e.g. "Family stated permissions verbally")

Success:    HTTP 201  { "lead_id": "<uuid>" }
Auth fail:  HTTP 401  { "error": "Authentication required" }
Bad input:  HTTP 400  { "error": "<validation message>" }
DB fail:    HTTP 500  { "error": "Lead creation failed" }
```

### Validation and error handling
- Parse body with `request.json()`; return 400 on parse error
- Validate `firstName`, `lastName`, and at least one of `email`/`phone`
- Use `getActiveStaffUser()` to avoid redirect behavior; return 401 manually
- Wrap lead insert in error check; return 500 on failure

### Data persistence
1. Resolve `launchMarketSlug` → `launch_market_id` (null if not found — no 400)
2. Insert into `public.leads`
3. Insert consent rows via `buildConsentRows()` with `capturedByStaffUserId`
4. Log `status_change` interaction
5. Insert `task` interaction directly (with `due_at`) — `logInteraction()` does not support `due_at`
6. Call `seedLeadMatchesForStaff()` if market resolved; log note if matches seeded
7. Log note if `consentSource` or `consentBasis` missing

### Compliance notes (from overview.md)
- All six consent types must be recorded even when not granted (audit completeness)
- `capturedByStaffUserId` links consent records to the capturing staff member
- `consentFacilitySharing` defaults to false if omitted
- `attribution_channel = "manual_entry"` marks this as a staff-originated record

### Test and verification plan

| Test case | Expected result |
|---|---|
| Valid required fields, staff session | 201 + `lead_id`; rows in leads, consents, alh_interactions |
| No session cookie | 401 |
| Missing `firstName` | 400 + validation error |
| Missing both `email` and `phone` | 400 + validation error |
| Invalid JSON body | 400 |
| Valid `launchMarketSlug` | Lead with market ID; matches seeded; note logged |
| No `launchMarketSlug` | Lead without market ID; no matches seeded |
| Unknown `launchMarketSlug` | Lead without market ID (resolves to null); 201 |
| Missing `consentSource` | 201; warning note logged |
| All consent flags false | 201; all six rows with `not_granted` or `missing` state |

### Open questions
- Unknown `launchMarketSlug`: resolves silently to null (consistent with `createLeadAction`). Change to 400 if strict validation is preferred.
- Future: idempotency key header for integration retries — out of scope for this task.

---

## Notes

- `logInteraction()` in `lib/log-interaction.ts` does not accept `due_at`. The task interaction must use `supabase.from("alh_interactions").insert()` directly, matching the pattern in `createLeadAction`.
- `requireActiveStaffUser()` calls `redirect()` from `next/navigation`, which is not appropriate for a JSON API route. `getActiveStaffUser()` is used instead.

---

## Outcome

**2026-05-03 — Implemented.**

- Created `app/api/leads/route.ts` — 130-line TypeScript Next.js App Router route handler.
- Uses `getActiveStaffUser()` for auth (401 on failure, no redirect).
- Validates `firstName`, `lastName`, and at least one of `email`/`phone`.
- Mirrors full lead creation workflow from `createLeadAction`: lead insert, consent rows via `buildConsentRows()`, `status_change` interaction via `logInteraction()`, task interaction with `due_at` via direct insert, match seeding via `seedLeadMatchesForStaff()`, consent documentation warning note.
- Returns `HTTP 201 { lead_id }` on success.
- Updated `api_spec.md` with full route documentation.
- Updated `execution_log.md` with implementation entry.
- TypeScript verification: `node node_modules/typescript/bin/tsc --noEmit` — no errors.

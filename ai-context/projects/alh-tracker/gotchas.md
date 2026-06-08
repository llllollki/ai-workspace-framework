# alh-tracker — Durable Technical Gotchas

This file captures durable, recall-first technical traps for `alh-tracker`.
It is distinct from `ai_memory.md`, which stores volatile working context and open questions,
and from `reflection.md`, which records post-task retrospectives and lessons learned.
`gotchas.md` is a project context file for issues that should be recalled proactively during
future debugging, auth, RLS, and provisioning work.

## Supabase re-firing SIGNED_IN on tab/window refocus

- Symptom: A valid CRM session is already active, but switching browser windows or tabs causes the app to reprocess auth state and reload the protected CRM tree.
- Root cause: Supabase Auth emits `SIGNED_IN` on visibility change/refocus, and the auth guard treats that as a fresh login event, resetting local UI state and re-rendering protected components.
- Fix-or-guard: In the auth guard, preserve a one-time "ever authorized" marker and suppress transient loading during auth refresh cycles. Only treat a true sign-out or invalid session as a redirect.
- How to recognize next time: The CRM page shows a loading or redirect cycle on window refocus while the underlying Supabase token is still valid and no explicit sign-out occurred.

## ALT+Tab unintentionally closing a modal

- Symptom: A modal closes silently when the user switches windows or presses ALT+Tab, even though the form is untouched.
- Root cause: The modal backdrop or global key handler interprets a focus/change event or synthetic click as an explicit cancel action, and a noisy window-focus path is treated like a user cancellation.
- Fix-or-guard: Remove implicit outside-click or escape-key close behavior for modal dialogs that contain unsaved state. Require explicit user actions for close/cancel, and isolate window focus changes from modal close events.
- How to recognize next time: ALT+Tab or taskbar focus returns the app to an open modal that is unexpectedly gone and the only close path in the UI was the ghost backdrop or keyboard shortcut.

## RLS GRANT-related 403s

- Symptom: A valid authenticated request is denied with 403 when the feature path should have allowed access.
- Root cause: RLS policies or grant checks are too strict or are evaluating the wrong role/claim context; the request may be missing the expected service-layer grant, required `crm_staff` row, or the correct auth path.
- Fix-or-guard: Confirm the request flow is using the intended auth boundary and grant model. For CRM/tracker work, ensure the CRM staff user has the correct `crm.crm_staff` row and role, the bridge uses a server-side grant or service-role path, and client-side paths do not bypass RLS assumptions. See `crm_auth_runbook.md` and `provisioning_runbook.md` for current auth/RLS posture.
- How to recognize next time: A 403 occurs on a path that previously worked, or the failure is in a grant check rather than a missing session. Check whether the request is using `authenticated` client access when it should be using the server-side service-role boundary.

## Auth redirect loops

- Symptom: The app loops between login and protected routes after sign-in or when restoring a session.
- Root cause: Guard logic does not distinguish between a fresh authenticated session and a restored or incomplete session state, so the app redirects back to login even though an auth token exists.
- Fix-or-guard: Track an explicit successful session approval marker before redirecting to protected routes, and treat restored or incomplete sessions as login-needed rather than a successful redirect path.
- How to recognize next time: The browser repeatedly navigates between the sign-in page and the protected CRM page even though a valid auth token is present in the request headers.

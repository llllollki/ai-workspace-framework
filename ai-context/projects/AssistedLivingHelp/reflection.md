# AssistedLivingHelp — Reflection

This file stores retrospective notes written after tasks are complete.

Entries here are for patterns, lessons, and observations that are worth remembering — things that would help future contributors work better on this project.

This is not an activity log (see `execution_log.md`) and not a decision record (see `decisions\`).

Write here after a significant task or phase is complete, not during ongoing work.

---

## 2026-05-03 — POST /api/leads implementation

### 1. `requireActiveStaffUser()` is not safe for JSON API routes

`requireActiveStaffUser()` in `lib/supabase-server.ts` calls `redirect()` from `next/navigation` when the session is missing. In a Next.js App Router context, `redirect()` throws a special error that the framework catches and turns into a 302 response — which is correct for Server Components and Server Actions but breaks a JSON API route. The fix is to use `getActiveStaffUser()` instead (returns null values) and return a manual `NextResponse.json({ error: "Authentication required" }, { status: 401 })`.

This is a general trap: any helper named `require*` in this codebase likely throws/redirects. Always check the implementation before using in an API route.

### 2. `logInteraction()` has no `due_at` parameter

`lib/log-interaction.ts` accepts `interaction_type: "task"` but does not accept a `due_at` field. For any task interaction that needs a due date, use a direct `supabase.from("alh_interactions").insert()` call. This pattern is already used in `createLeadAction` in `app/admin/(protected)/leads/new/actions.ts` — match that pattern rather than extending `logInteraction()` unless the signature is updated.

### 3. Staff lead creation is non-atomic

`POST /api/leads` (and `createLeadAction`) performs three separate DB writes: `leads`, `consents`, `alh_interactions`. If a later write fails, the lead row exists without consent rows or interaction history. This is currently acceptable and consistent with the existing admin flow. The public intake path (`submit_public_intake`) handles this atomically via a stored procedure. If data integrity requirements tighten, the staff path should be moved to a stored procedure or wrapped in a Supabase RPC transaction.

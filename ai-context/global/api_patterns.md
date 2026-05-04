# API Patterns

## Responsibility

This file documents shared API design patterns, conventions, and standards that apply across projects.

## What Belongs Here

- REST or RPC naming conventions
- Request and response shape conventions
- Authentication and authorization patterns
- Error response formats
- Pagination conventions
- Versioning approach

## What Does Not Belong Here

- Project-specific API routes and endpoints (see `projects\AssistedLivingHelp\api_spec.md`)
- Business logic rules
- Database schema (see `projects\AssistedLivingHelp\data_model.md`)

## Related Files

- `projects\AssistedLivingHelp\api_spec.md` — AssistedLivingHelp-specific API routes and integration notes

---

## Authentication Patterns (AssistedLivingHelp — Next.js App Router)

### JSON API routes: use `getActiveStaffUser()`

```typescript
const { supabase, user, staffUser } = await getActiveStaffUser();
if (!user || !staffUser) {
  return NextResponse.json({ error: "Authentication required" }, { status: 401 });
}
```

`getActiveStaffUser()` returns null values when the session is missing. Use this in any route that must return JSON.

### Server Components and Server Actions: use `requireActiveStaffUser()`

`requireActiveStaffUser()` calls `redirect()` from `next/navigation` on auth failure. This is correct behavior for rendered pages and form actions but throws an unrecoverable error inside a JSON route handler. Do not use it in API routes.

The pattern name `require*` signals redirect-on-failure across this codebase.

---

## Response Shape

All JSON API routes return `NextResponse.json(body, { status })`:

| Outcome | Status | Body shape |
|---|---|---|
| Success (created) | 201 | `{ "<resource>_id": "<uuid>" }` |
| Success (read/update) | 200 | Resource object |
| Validation error | 400 | `{ "error": "<message>" }` |
| Auth failure | 401 | `{ "error": "Authentication required" }` |
| Server / DB error | 500 | `{ "error": "<short description>" }` |

---

## Interaction Logging (AssistedLivingHelp)

### `logInteraction()` — standard usage

`lib/log-interaction.ts` exports `logInteraction(supabase, params)`. Supports interaction types: `note`, `sms`, `email`, `call`, `share`, `task`, `status_change`.

**Limitation:** `logInteraction()` does not accept a `due_at` field. For task interactions that need a due date, insert directly:

```typescript
await supabase.from("alh_interactions").insert({
  lead_id: lead.id,
  created_by_staff_user_id: user.id,
  interaction_type: "task",
  outcome: "...",
  body_summary: "...",
  due_at: new Date(Date.now() + 4 * 60 * 60 * 1000).toISOString()
});
```

This pattern is established in `createLeadAction` (`app/admin/(protected)/leads/new/actions.ts`) and `POST /api/leads` (`app/api/leads/route.ts`).

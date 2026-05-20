# Task 0029 — Accept ADR 0011

**Date:** 2026-05-19
**Status:** Done
**Type:** ADR acceptance / documentation cleanup

---

## Objective

Accept ADR 0011 (canonical facility staff role naming — `owner`/`admin` replace `facility_admin`)
following the architecture review completed in task 0028. Update all proposed-status references
across both mirrors.

---

## Actions Taken

1. Updated `decisions/0011-facility-owner-role-naming.md` status: `proposed` → `accepted`
2. Updated `decisions/README.md` ADR 0011 row: `Proposed` → `Accepted`
3. Updated `ai_memory.md` ADR 0011 blocker heading: `NARROWED — ADR 0011 proposed` → `RESOLVED — ADR 0011 accepted`
4. Updated `ai_memory.md` ADR 0011 body reference: `(proposed)` → `(accepted)` — implementation blockers preserved
5. All four changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`
6. Updated `execution_log.md` in both mirrors
7. Committed changes to `ai-workspace-framework` (see commit hash in final report)

No application code changed. No Supabase schema changes. No migrations written.

---

## Files Changed

| File | Change |
|---|---|
| `decisions/0011-facility-owner-role-naming.md` | Status: proposed → accepted |
| `decisions/README.md` | ADR 0011 row: Proposed → Accepted |
| `ai_memory.md` | ADR 0011 blocker: proposed → accepted; heading NARROWED → RESOLVED |
| All above mirrored in `ai-workspace-framework` | Same changes |
| `execution_log.md` (both mirrors) | Task 0029 entry added |

---

## Remaining Blockers Before Provisioning Implementation

The following must be resolved before task 0027 implementation can begin (role naming migration + RLS):

1. **Schema migration (task 0027 Part A):** `ALTER TYPE app_role RENAME VALUE 'facility_admin' TO 'owner'` + `ADD VALUE 'admin'`. No data migration needed — `RENAME VALUE` propagates to existing rows automatically.
2. **RLS policy updates (task 0027 Part E):** `admin_manage_family_links` and `audit_read_admin` policies must be updated to reference `owner`/`admin` instead of `facility_admin`.
3. **`AuthProvider.tsx` (task 0031):** Rename local `AppRole` to `DbRole`; update DEMO_AUTH_USER role; simplify/remove `mapToStoreRole()`.
4. **`src/types/index.ts` (task 0031):** Resolve `AppRole` naming collision with AuthProvider's DB-facing type.
5. **`src/data/seed.ts` (task 0031):** Verify and update demo user roles; add an `owner` demo user.
6. **`db/schema.sql` (task 0027):** Update reference schema to use `owner`/`admin` enum values and fix `audit_read_admin` policy reference.
7. **Endpoint hosting model (task 0026 blocker #1):** ADR 0008 TODO — unresolved before task 0028 begins.
8. **Idempotency storage mechanism (task 0026 blocker #2):** ADR 0008 TODO — unresolved before task 0028 begins.
9. **Transactional email service (task 0026 blocker #3):** ADR 0007 TODO — unresolved before activation emails can be sent.

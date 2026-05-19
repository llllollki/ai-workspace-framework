# Task 0025 — Accept ADR 0010

**Date:** 2026-05-19
**Status:** Done
**Type:** ADR acceptance / documentation cleanup

---

## Objective

Accept ADR 0010 (pending setup facility RLS policy) following the architecture review
completed in task 0024. Update all proposed-status references across both mirrors.

---

## Actions Taken

1. Updated `decisions/0010-pending-setup-facility-rls-policy.md` status: `proposed` → `accepted`
2. Updated `decisions/README.md` ADR 0010 row: `Proposed` → `Accepted`
3. Updated `data_model.md` security note: `(ADR 0010 — proposed)` → `(ADR 0010 — accepted)`
4. Updated `compliance_notes.md` data handling row: `See ADR 0010 (proposed)` → `See ADR 0010 (accepted)`
5. Updated `ai_memory.md` ADR 0010 entry: `(ADR 0010, 2026-05-19 — proposed)` → `(ADR 0010, 2026-05-19 — accepted)`
6. All five changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`
7. Updated `execution_log.md` in both mirrors

No application code changed. No Supabase schema changes.

---

## Files Changed

| File | Change |
|---|---|
| `decisions/0010-pending-setup-facility-rls-policy.md` | Status: proposed → accepted |
| `decisions/README.md` | ADR 0010 row: Proposed → Accepted |
| `data_model.md` | ADR 0010 reference: proposed → accepted |
| `compliance_notes.md` | ADR 0010 reference: proposed → accepted |
| `ai_memory.md` | ADR 0010 reference: proposed → accepted |
| All above mirrored in `ai-workspace-framework` | Same changes |
| `execution_log.md` (both mirrors) | Task 0025 entry added |

---

## Remaining Blockers Before Implementation

The following are documented in ADR 0010 Open Implementation TODOs and must be resolved
before the provisioning endpoint is implemented:

1. Review all existing RLS migrations in `supabase/migrations/` — extend, do not delete.
2. Confirm whether `wellness_observations` is a separate Supabase table or part of `care_log_entries`.
3. Verify/create `current_facility_id()` helper — check if an equivalent already exists.
4. Profile `is_active_user_on_active_facility()` under production load; add partial indexes if needed.
5. Design `disabled` user session revocation mechanism (`auth.admin.signOut(userId)` server-side).
6. Resolve `crm_facility_reference` column-level exclusion approach (CLS or app-layer filter).
7. Define exact `suspended` facility RLS behavior (deferred to billing task; required before commercial launch if suspension is a supported state).

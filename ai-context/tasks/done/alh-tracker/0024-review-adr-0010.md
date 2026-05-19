# Task 0024 — ADR 0010 Architecture Review

**Date:** 2026-05-19
**Status:** Done
**Type:** Architecture / documentation review

---

## Objective

Review ADR 0010 (pending setup facility RLS policy — status: proposed) and determine
whether it is ready for acceptance, needs edits, or conflicts with existing architecture.

---

## Outcome

**Recommendation: Accept with minor edits. Edits applied in this task.**

ADR 0010 is architecturally sound and ready for user acceptance. No conflicts found.

---

## Review Summary

### 1. Quarantine model — PASS

`pending_setup` correctly has zero client care-ops access. ADR 0007 confirms
`invited`/`password_pending` users have no Supabase session at all (auth user created at
activation time only); RLS is a defensive layer covering invariant-violation edge cases.
No setup shell, no resident creation, no care data before activation. No `setup_incomplete`
state — `pending_setup → active` transitions atomically (ADR 0009 + ADR 0007). The logic
is correct and complete.

### 2. Active user + active facility rule — PASS (one wording fix applied)

The combined two-condition gate is logically correct. `is_active_user_on_active_facility()`
correctly uses `STABLE SECURITY DEFINER` and performs a JOIN checking both
`u.account_status = 'active'` and `f.provisioning_status = 'active'`.

**Documentation defect found and fixed:** The prose in the Care-Ops Table RLS Rule section
stated the helper "encapsulates conditions 1 and 2." This was misleading: condition 1 is
`row.facility_id = current_facility_id()` (separate tenant isolation check); the helper
is condition 2 only. If an implementer relied on this prose instead of the policy table,
they could omit `facility_id = current_facility_id()` from the USING clause, breaking
tenant isolation — a security bug. The policy table at the bottom was correct; the prose
was not.

**Fix applied:** Prose updated to "encapsulates condition 2 — both the `account_status`
and `provisioning_status` status checks — and must be used alongside condition 1
(`facility_id = current_facility_id()`)...". Usage note updated to warn implementers
explicitly not to use the helper alone.

### 3. Covered tables — PASS

All care-ops tables from `data_model.md` are covered. No table missing:
residents, care_log_entries, observed_care_tasks, wellness_observations (TODO preserved),
follow_ups, room_checklists, appointment_transports, resident_contacts,
resident_preferences, allergies_triggers, shifts, routines, audit_trail,
family_access_consent. Handoff summaries are captured in the `shifts` table (no separate
table in the data model — correct omission). `wellness_observations` TODO correctly
preserved.

### 4. Provisioning tables — PASS

`provisioning_tokens`: zero RLS policies, default deny, consistent with ADR 0007 and
data_model.md. `provisioning_events`: zero client-write policies during MVP; owner/admin
read deferred as a documented TODO. Audit/admin viewing implications documented. All
access is service-role only. Non-negotiable security note on provisioning_tokens included.

### 5. Family access — PASS

`family_access_consent` is in the care-ops table list (blocked for pending_setup/closed).
Five constraints documented: no grants for pending_setup/closed; any future FamilyUser RLS
must include provisioning_status = 'active'; no new grants during suspension; active grants
during suspension is a documented TODO (must resolve before Phase 2). FamilyUser RLS
explicitly deferred to Phase 2 (ADR 0004, ADR 0006) — appropriate.

### 6. CRM boundary — PASS

ADR 0010 does not create CRM access to tracker data. CRM constraint is service-layer only
(ADR 0005) — explicitly outside RLS scope per ADR 0010 constraint 5.

### 7. Documentation consistency — PASS

- ADR 0009 Open Implementation TODOs: correctly annotated as addressed by ADR 0010.
- ADR 0009 Facility Status Lifecycle RLS note: correctly updated to reference ADR 0010.
- `data_model.md` security section: accurately summarizes ADR 0010. ProvisioningToken
  and ProvisioningEvent access control paragraphs correct.
- `compliance_notes.md` data handling row: accurate, does not overclaim compliance.
- `ai_memory.md`: correctly narrows the blocker; implementation TODOs preserved.
- `decisions/README.md`: ADR 0010 correctly indexed as "Proposed."

---

## Files Changed in This Task

| File | Change |
|---|---|
| `decisions/0010-pending-setup-facility-rls-policy.md` | Fixed misleading "encapsulates conditions 1 and 2" prose in Care-Ops Rule section; updated Usage note for `is_active_user_on_active_facility()` |
| `ai-workspace-framework` mirror of the above | Same edits mirrored |
| `execution_log.md` (both mirrors) | Task 0024 entry added |
| `tasks/done/alh-tracker/0024-review-adr-0010.md` | This file (created in both mirrors) |

---

## Open Questions (Before Implementation — Not Blocking Acceptance)

These are all already documented in ADR 0010 Open Implementation TODOs:

1. Review existing RLS migrations in `supabase/migrations/` before writing new migration.
2. Confirm whether `wellness_observations` is a separate table or part of `care_log_entries`.
3. Verify/create `current_facility_id()` function — check if equivalent already exists.
4. Profile `is_active_user_on_active_facility()` performance under production load;
   add partial indexes if needed.
5. Design session revocation mechanism for `disabled` users
   (`auth.admin.signOut(userId)` server-side, not deferred to session expiry).
6. Decide `crm_facility_reference` column-level exclusion approach (CLS or app-layer filter).
7. Define exact RLS behavior for `suspended` facilities (deferred to billing task).

---

## Post-Acceptance Cleanup (After User Approves Acceptance)

1. Update ADR 0010 status from `proposed` to `accepted` in both mirrors.
2. Update `decisions/README.md` status row in both mirrors.
3. Update `data_model.md` ADR 0010 reference from "(proposed)" to "(accepted)" in both mirrors.
4. Update `compliance_notes.md` provisioning-state RLS row reference in both mirrors.
5. Update `ai_memory.md` ADR 0010 reference in both mirrors.

# Task 0034 — Accept ADR 0012

Status: done
Created: 2026-05-20
Owner role: AI agent (main)
Reviewers: n/a

---

## Goal

Review ADR 0012 (Phase 2 Provisioning Platform Decisions) for soundness, apply any required
fixes, and change its status from `proposed` to `accepted`. Update all downstream documentation
to reflect acceptance.

Scope: documentation/context only. No application source, migrations, dependencies, env files,
or Supabase function code changed.

---

## Acceptance Criteria

- [x] ADR 0012 reviewed against all eight focus areas (ADRs 0007–0011 conflicts, CRM/tracker
      boundary, Edge Function fit, Resend secrets, nullable created_by, re-provision audit,
      token_expired_passive migration, docs consistency).
- [x] All defects found during review fixed in ADR 0012 before acceptance.
- [x] ADR 0012 status changed `proposed` → `accepted`.
- [x] `decisions/README.md` updated: ADR 0012 row changed from `Proposed` to `Accepted`.
- [x] `ai_memory.md` updated: all ADR 0012 resolution entries changed from `proposed` to `accepted`.
- [x] `execution_log.md` updated with acceptance entry.
- [x] Task doc created under `tasks/done/alh-tracker/` with Goal, Acceptance Criteria, Plan,
      Notes, and Outcome.
- [x] All ai-context changes mirrored to `c:\Projects\ai-workspace-framework\ai-context\`.
- [x] No application source, config, dependency, migration, env, or generated files changed.

---

## Plan

- [x] Read ADR 0012 in full
- [x] Read ADRs 0007–0011 for conflict check
- [x] Evaluate all eight review focus areas
- [x] Identify defects
- [x] Apply defect fixes to ADR 0012
- [x] Change ADR 0012 status to `accepted`
- [x] Update `decisions/README.md`
- [x] Update `ai_memory.md`
- [x] Update `execution_log.md`
- [x] Write this task doc
- [x] Mirror all changes to `ai-workspace-framework`

---

## Subagent Policy

Not used. This is a tightly coupled, sequential review-and-edit task — every write depends on
the review findings, and all writes target the same set of context files. No independent
workstreams exist.

---

## Notes

### Review findings — areas that passed cleanly

1. **No conflicts with ADRs 0007–0011.** All eight decisions in ADR 0012 are consistent with
   the token mechanism (ADR 0007), API auth contract (ADR 0008), facility creation sequence
   (ADR 0009), quarantine RLS gate (ADR 0010), and role naming (ADR 0011).

2. **CRM/tracker boundary intact.** Service-role key stays within Supabase; Resend API key
   is a Supabase Edge Function secret (never client-side); `created_by = NULL` means no CRM
   actor ID enters the tracker `users` table; CRM actor IDs stored only opaquely in
   `ProvisioningEvent.actor_id`.

3. **Supabase Edge Function fits the Vite SPA architecture.** The tracker is a pure Vite SPA
   with no existing Vercel API layer. The CRM calls the provisioning endpoint server-side; the
   browser never contacts the endpoint. Service-role key stays within Supabase.

4. **Resend does not introduce client-side secrets or care-data exposure.** Resend API key is
   a Supabase secret (`RESEND_API_KEY`). The activation email contains only a deep-link URL —
   no resident name, care data, or identifying care information per ADR 0007 URL spec.

5. **Nullable `created_by` does not imply CRM users are tracker users.** NULL means "no tracker
   User created this account." CRM actor IDs are stored exclusively in `ProvisioningEvent.actor_id`
   (opaque, not a tracker User FK). ADR 0005/0006 principal separation is preserved.

6. **Re-provision audit trail is adequate.** The existing `provisioned` event_type reused in
   step 8 of Decision 6 is sufficient. The audit chain `provisioned → token_revoked → provisioned`
   is reconstructable from `ProvisioningEvent` ordered by `created_at`.

7. **`token_expired_passive` migration note is consistent with the applied schema.** Task 0030
   intentionally omitted this value per ADR 0007's conditional. The `ADD VALUE IF NOT EXISTS`
   migration in ADR 0012 is correct — the value does not currently exist in the enum, so the
   migration will add it safely.

8. **`ai_memory.md` and `decisions/README.md` are consistent with ADR 0012 content.** All five
   ADR 0012 resolution entries in `ai_memory.md` correctly reference ADR 0012. The README row
   is complete.

### Review findings — defects fixed

**Defect 1 — Decision 4 schema note (nullable `created_by` assertion):**

Original text: "No schema migration is needed for this decision — the column accepts NULL by
intent."

Issue: This asserted as fact that the column is nullable without verifying the applied migration.
`data_model.md` documents no NOT NULL constraint, but task 0030 did not explicitly verify
nullability and the assertion could cause an implementer to skip the check.

Fix: Changed to "Verify at implementation time (task 0028) that the `created_by` column is
nullable in the applied migration — `data_model.md` documents no NOT NULL constraint, but the
schema file should be confirmed before proceeding." Also softened the Consequences section
entry from "the column already supports NULL" to "verify at implementation time that the column
is nullable in the applied migration."

**Defect 2 — Decision 5 conflict logging target (ProvisioningEvent vs. application log):**

Original text (rationale point 4): "the conflicting fields are noted in the `ProvisioningEvent`
metadata for the retry call"

Original text (implementation note): "The conflicting fields must be identified and logged in
`ProvisioningEvent.metadata` for the retry event."

Issue: ADR 0008 states "Do not write a new ProvisioningEvent" for deduplicated/retry requests.
A conflict-on-retry is not a provisioning action — no new facility or user is created, no token
is issued. There is no `provisioning_event_type` value that represents "retry-with-conflicting-
payload." Writing a new ProvisioningEvent row here would contradict ADR 0008 and pollute the
audit table with a spurious event.

Fix: Changed all references in Decision 5 (rationale point 4, implementation note, summary
table, Open Implementation TODOs) from "ProvisioningEvent.metadata" to "Edge Function's
structured application log." Added explicit note: "No new `ProvisioningEvent` row is written —
no provisioning action occurred on this request, and there is no applicable
`provisioning_event_type` for a conflict-on-retry scenario (ADR 0008 specifies 'Do not write
a new ProvisioningEvent' for deduplicated requests)."

---

## Outcome

ADR 0012 accepted. Two defects fixed: (1) `created_by` nullability assertion softened to
require implementation-time verification; (2) conflict-on-retry logging target corrected from
`ProvisioningEvent.metadata` to Edge Function structured application log (no new ProvisioningEvent
written). `decisions/README.md`, `ai_memory.md`, and `execution_log.md` updated. Task doc
created. All changes mirrored to `ai-workspace-framework`. No application code or schema files
changed. Backlog task 0028 (provisioning endpoint) is now fully unblocked.

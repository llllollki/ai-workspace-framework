Status: done
Created: 2026-05-19
Completed: 2026-05-19
Owner role: Architecture / Documentation
Reviewers: n/a

## Goal

Review ADR 0008 (CRM-to-tracker provisioning API authentication — status: proposed) and
determine whether it is ready for acceptance, needs edits, or conflicts with ADR 0005/0006/
0007 or compliance constraints.

ADR 0008 was created in task 0017 (2026-05-19). It selects rotating static API keys as
the MVP authentication mechanism for the CRM-to-tracker provisioning API, with HMAC-signed
short-lived JWT as the Phase 2 hardening path.

## Acceptance Criteria

- [x] ADR 0008 readiness clearly assessed
- [x] Any conflicts with ADR 0005/0006/0007 or compliance notes identified
- [x] No application code changed
- [x] Documentation edits stay inside ai-context scope
- [x] Final response clearly states whether ADR 0008 is ready for user acceptance
- [x] Task doc created and moved to done
- [x] execution_log.md updated

## Plan

- [x] Read ADR 0008, ADR 0007, ADR 0006, ADR 0005
- [x] Read data_model.md, ai_memory.md, compliance_notes.md, decisions/README.md
- [x] Review all seven criteria areas (boundary, API key design, request contract,
      response contract, replay/idempotency, Phase 2, documentation consistency)
- [x] Identify findings and required edits
- [x] Apply minor documentation edits to ADR 0008 (both mirrors)
- [x] Update execution_log.md (both mirrors)

## Notes

- Architecture/documentation review task only. No application code was touched.
- ADR 0008 status remains `proposed` pending explicit user acceptance.
- Subagents: not used. All workstreams share the same already-loaded documents; serial
  review was more efficient.

## Outcome

**Recommendation: Accept with minor edits. Edits applied in this task.**

No conflicts with ADR 0005/0006/0007 or compliance_notes.md were found. All hard
security constraints are satisfied. Three documentation gaps identified and fixed in
ADR 0008 (both mirrors):

1. **Owner role clarity (MEDIUM):** Added explicit note that CRM-provisioned accounts
   always receive `role = owner`, enforced server-side, and that the CRM cannot specify
   a different role via the provisioning API.

2. **Facility association dependency (MEDIUM):** Added note cross-referencing ADR 0007's
   unresolved facility TODO and explicitly stating that the request body's facility
   association mechanism is outside ADR 0008's scope but must be resolved before
   implementation.

3. **Excluded fields documentation (LOW):** Added "Intentionally excluded fields" note
   documenting that `phone` is collected at activation (not provisioning) and
   `allocated_resident_count` is a CRM-side commercial concept.

**All boundary checks passed:** CRM never receives tracker service-role key; response
returns only `provisioning_reference` and `status`; no care data crosses the boundary;
credential stored server-side only; SHA-256 hash only on tracker side; constant-time
comparison required; 90-day rotation cadence documented; revocation documented; failed-
auth logging and alerting specified.

**All documentation consistency checks passed:** ADR 0007 resolves its auth TODO
correctly; ai_memory.md entry is accurate; compliance_notes.md row is accurate; README
indexes correctly; data_model.md references correctly.

**Open implementation TODOs correctly identified:**
- (Blocking) Idempotency key storage mechanism
- (Blocking) Provisioning endpoint hosting model
- (Pre-production) Alert delivery mechanism
- (Minor) Key version tag format
- (Deferred) Phase 2 upgrade timing, per-key rate limit, X-CRM-Facility-Id validation

**ADR 0008 is ready for user acceptance after these edits.** Implementation may begin
after user approves acceptance and changes status to `accepted`.

**Post-acceptance cleanup required:**
- Change ADR 0008 status from `proposed` to `accepted` (both mirrors)
- Update decisions/README.md status column (both mirrors)
- Update ai_memory.md ADR 0008 references from "proposed" to "accepted" (both mirrors)
- Update data_model.md ADR 0008 reference from "proposed" to "accepted" (both mirrors)

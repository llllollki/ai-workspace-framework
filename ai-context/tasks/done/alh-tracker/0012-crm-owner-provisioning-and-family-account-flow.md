Status: done
Created: 2026-05-18
Owner role: Claude Code (documentation agent)
Reviewers: Noel Castillo

## Goal

Update the `ai-context` markdown documentation to reflect the new end-to-end business flow for CRM-based facility onboarding, facility-owner account activation, app deep-link routing, app account creation information, and family-member approval-gated access.

## Acceptance Criteria

- Task doc 0012 is created in both mirror paths per workspace planning rules.
- `user_flows.md` clearly reflects the new CRM-to-owner onboarding flow and all three deep-link cases.
- Family flows distinguish account creation (identity only) from approved resident access.
- Owner/admin family access management flow is documented.
- `features.md`, `overview.md`, `data_model.md`, `ai_memory.md`, and `compliance_notes.md` are updated consistently.
- ADR 0005 Section 4 TODO is resolved at the conceptual level.
- ADR 0006 is created with status: proposed.
- `decisions\README.md` is updated with ADR 0006.
- App Store / Google Play routing is documented as proposed/assumed, not as an accepted architectural decision.
- FamilyUser entity is documented as separate from User and from FamilyAccessConsent.
- No document implies CRM users can access resident care data.
- No document implies family members receive resident data merely by creating an account.
- Family access remains read-only, resident-specific, category-scoped, approval-gated, auditable, and revocable.
- Unresolved product/security/implementation details are marked as TODOs.
- `execution_log.md` is updated with a one-line documentation summary.
- Task doc 0012 is moved to `tasks\done\alh-tracker\` in both mirror paths on completion.
- All updated files are committed to both `c:\Projects\ai-context\` and `c:\Projects\ai-workspace-framework\ai-context\`.

## Plan

- [x] Create task doc in both mirror paths (this document)
- [x] Subagent policy assessment (see Notes — proceeding serially)
- [x] Review existing docs for conflicts (see Notes — none found)
- [x] Update ADR 0005 — resolve Section 4 TODO
- [x] Create ADR 0006 — status: proposed
- [x] Update decisions/README.md — add ADR 0006
- [x] Update user_flows.md — Flow 0 revised, Family Onboarding revised, new Flow 14
- [x] Update features.md — CRM provisioning, family management page, role summary
- [x] Update overview.md — Product Surfaces descriptions
- [x] Update data_model.md — account status fields, ProvisioningToken TODO, FamilyUser entity
- [x] Update ai_memory.md — resolve provisioning open question, add new ambiguity TODOs
- [x] Update compliance_notes.md — alignment check, FamilyUser pre-approval language
- [x] Update execution_log.md — one-line summary
- [ ] Move task doc to tasks\done\alh-tracker\ in both mirrors
- [ ] Commit both mirrors

## Notes

### Subagent policy assessment

Proceeding serially. This is a design-sensitive documentation task where all files must be internally consistent with one another and with the new ADR decisions. The ADR decisions (ADR 0005 update, ADR 0006 new) must be established before downstream files (user_flows.md, features.md, data_model.md) can accurately reference them. Parallelizing documentation across subagents would risk inconsistency between tightly-coupled files.

### Conflict review

Read all target files before editing. No conflicts found between existing documents and the new flow.

**ADR 0004 alignment confirmed:** Family self-signup before owner approval is consistent with ADR 0004 provided:
- Family self-signup creates a `FamilyUser` entity (identity record) that is separate from the facility-facing `User` table. ADR 0004 Section 7 says "Family contacts authenticate via a separate mechanism... They do not have User records in the facility-facing User table." A `FamilyUser` entity satisfies this — it is not a `User` table record.
- `FamilyUser` existence does not grant any resident data access. ADR 0004 Section 3 requires dual acknowledgment (operator authorization + resident autonomy noted) before any care data is visible. A FamilyUser account creation event does not trigger either condition.
- `FamilyAccessConsent` remains the authorization record, unchanged.
- ADR 0004 does not need to be updated. The `FamilyUser` entity is additive — it represents the pre-approval identity account that ADR 0004 Section 7 already anticipated with "authenticate via a separate mechanism."

**ADR 0005 Section 4 TODO resolved at conceptual level:** The existing TODO in Section 4 ("Implementation details of the provisioning handshake... are pending CRM design") is resolved here at the conceptual architectural level. The full decision is captured in new ADR 0006. ADR 0005 Section 4 will be updated to reference ADR 0006 and close the TODO.

**user_flows.md family onboarding flow order changed:** The current flow starts with "Facility owner or admin authorizes family access" as Step 1, then the family member installs and creates an account. The new flow reverses this: the family member creates a FamilyUser account first (identity only), then the owner approves access. This is a flow change, not a document conflict. Both orderings are consistent with ADR 0004's constraint that data access requires explicit operator authorization.

### Ambiguities preserved as TODOs

Per task instructions, the following are recorded as TODOs in the relevant documents and not resolved:

- Native app vs. PWA/web delivery model (pending future ADR — noted in decisions/README.md)
- Allocated resident count definition (single integer placeholder; three-field split still open)
- Supabase Auth invite API vs. custom provisioning token (implementation detail)
- iOS Universal Links vs. Android App Links behavior difference (affects token/redirect architecture)
- Token expiry, one-time-use, resend, and revocation rules
- Whether one owner login can span multiple facilities
- Owner-only vs. owner+admin family approval
- Family self-serve account creation vs. invitation-only
- Approval scope: facility level, resident level, or both
- Owner approval required fields (relationship confirmation, privacy release, autonomy note, scope, notifications)
- Behavior when an owner rejects a family access request
- Wellbeing notification categories (before approval / after approval / after revocation)
- Whether family occupation is always required or only for identity verification
- Whether family address is required for all accounts or only for verification
- Whether /family web prototype coexists with the Phase 2 native app

## Outcome

**Completed 2026-05-18.** All documentation updated across both `ai-context` and `ai-workspace-framework/ai-context` mirrors.

**ADR 0006 created (status: proposed):** Documents CRM owner provisioning (forward write only; deep link with opaque/expiring/one-time-use token; three routing cases; account status lifecycle), FamilyUser identity-only account model (not a User table record; not a FamilyAccessConsent; no data access until owner/admin approval), and the Owner/Admin Family Access Management surface. Requires human review before status changes to accepted.

**ADR 0005 Section 4 updated:** Resolved the open TODO by documenting the 7-step provisioning flow at the conceptual level, with a forward reference to ADR 0006 for full decision details.

**All 8 documentation files updated consistently:** user_flows.md, features.md, overview.md, data_model.md, ai_memory.md, compliance_notes.md, execution_log.md, decisions/README.md.

**Key design decisions preserved as proposed (not accepted):** App Store/Google Play routing is documented as the assumed flow for a native app delivery model — the app delivery model ADR (PWA vs. native) is still pending and must be resolved before this routing is implemented.

**Unresolved implementation details preserved as TODOs in ai_memory.md and ADR 0006:** iOS Universal Links vs. Android App Links, Supabase Auth invite API vs. custom provisioning_tokens table, token expiry/resend/revocation, FamilyUser self-registration vs. invite-only, facility discovery at signup.

Status: active
Created: 2026-05-19
Owner role: architecture / documentation
Reviewers: human review required before ADR status moves to accepted

## Goal

Design the Row Level Security (RLS) policy for `pending_setup` facilities and
invited/password-pending owner accounts. Produce ADR 0010 resolving the RLS
blocker identified in ADR 0009 Open Implementation TODOs. This is the security
design blocker before the tracker provisioning endpoint can be implemented.

## Acceptance Criteria

- [ ] ADR 0010 created at `decisions/0010-pending-setup-facility-rls-policy.md` with status `proposed`.
- [ ] ADR 0010 defines RLS behavior for `pending_setup` facilities.
- [ ] ADR 0010 defines access behavior for `invited`, `password_pending`, `active`, and `disabled` users.
- [ ] ADR 0010 includes a Facility state access matrix.
- [ ] ADR 0010 includes a User account state access matrix.
- [ ] ADR 0010 identifies all care-ops tables requiring active facility + active user.
- [ ] ADR 0010 documents whether resident setup is blocked until activation.
- [ ] ADR 0010 documents family access implications.
- [ ] ADR 0010 documents required Supabase helper/policy changes conceptually.
- [ ] `decisions/README.md` indexes ADR 0010.
- [ ] ADR 0009 RLS TODO annotated as addressed by ADR 0010 (proposed).
- [ ] `ai_memory.md` updated to narrow/resolve the pending_setup RLS blocker.
- [ ] `data_model.md` updated with RLS notes for provisioning-related tables.
- [ ] `compliance_notes.md` updated with pending_setup RLS row.
- [ ] `execution_log.md` updated.
- [ ] All changes mirrored to `C:\Projects\ai-workspace-framework\ai-context\`.
- [ ] No application code changed.
- [ ] Task doc moved to done.

## Plan

### Reference material loaded

ADRs 0005–0009 read. data_model.md, features.md, user_flows.md, ai_memory.md,
compliance_notes.md, decisions/README.md, execution_log.md read.

### Subagent gate

Not used. Design-sensitive single-deliverable task. All ADR sections must be
internally consistent before any dependent doc can be updated. Serial execution
is correct.

### Execution order

- [x] Create task doc (this file).
- [ ] Write ADR 0010.
- [ ] Update decisions/README.md.
- [ ] Update decisions/0009-... RLS TODO note.
- [ ] Update data_model.md.
- [ ] Update compliance_notes.md.
- [ ] Update ai_memory.md.
- [ ] Update execution_log.md.
- [ ] Mirror all changes to ai-workspace-framework.
- [ ] Move task doc to done.

## Notes

Key design invariants from ADR 0007 + ADR 0009:
- Supabase Auth user is created at activation time only (not at provisioning time).
- `User.account_status = active` and `Facility.provisioning_status = active`
  transition atomically in the same transaction.
- Therefore, no valid client session can exist for an `invited` or `password_pending`
  user, and no `active` session can exist on a `pending_setup` facility in normal
  operation.
- RLS must be defensive: both conditions enforced independently.

Recommended option: quarantine model (Option A). No limited setup mode (Option B)
is feasible under current ADR 0007 activation model (auth user not created until
activation).

## Outcome

[To be filled in on completion.]

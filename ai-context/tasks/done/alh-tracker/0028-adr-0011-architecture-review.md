# 0028 — ADR 0011 Architecture Review: Facility Owner Role Naming

Status: done
Created: 2026-05-19
Owner role: AI agent (main)
Reviewers: n/a

## Goal

Review ADR 0011 (proposed) for correctness, internal consistency, migration feasibility,
and compatibility with ADRs 0006–0010. Produce a readiness recommendation. Apply any
required documentation edits to ADR 0011. No application code or migrations changed.

## Acceptance Criteria

- [x] ADR 0011 readiness clearly assessed.
- [x] Migration/source impacts verified without implementing them.
- [x] Conflicts with ADR 0006/0007/0010 or data_model checked.
- [x] Required documentation edits applied to ADR 0011.
- [x] No application code or migrations changed.
- [x] Task doc created in done.
- [x] execution_log.md updated.
- [x] Changes mirrored to ai-workspace-framework.

## Plan

- [x] Read ADR 0011 and all cross-referenced ADRs, data_model.md, compliance_notes.md, user_flows.md
- [x] Read src/lib/AuthProvider.tsx, src/types/index.ts, supabase/migrations/*, db/schema.sql
- [x] Verify PostgreSQL 15 RENAME VALUE behavior
- [x] Check db/schema.sql for undocumented facility_admin references
- [x] Synthesize findings and produce recommendation
- [x] Apply targeted edits to ADR 0011
- [x] Update execution_log.md
- [x] Mirror to ai-workspace-framework

## Subagent Policy Note

Serial: this is a review task where all findings must be synthesized into a single
recommendation. No independent workstreams benefit from delegation.

## Review Findings

### Finding 1 — P0: Factual error in migration section (FIXED)

ADR 0011's migration section stated: "In Postgres, enum values can be added but existing
values cannot be renamed directly." This is incorrect. `ALTER TYPE ... RENAME VALUE` has
been available since PostgreSQL 10 and is fully transactional in PostgreSQL 15.

The original proposed approach (`ADD VALUE 'owner'` + `UPDATE users` + leave dead value)
was valid but unnecessarily complex. The correct one-step approach is:
```sql
ALTER TYPE app_role RENAME VALUE 'facility_admin' TO 'owner';
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'admin';
```
`RENAME VALUE` propagates to all existing rows automatically — no `UPDATE` needed.
`facility_admin` is cleanly removed (no dead enum value remains).

There was also a contradiction: Option A's Cons bullet correctly referenced `RENAME VALUE`,
but the Implementation section then said it wasn't possible. The Cons bullet and migration
section now agree.

**Edit applied:** Migration SQL section rewritten. Consequences "harder" note updated.
Option A Cons bullet updated for consistency.

### Finding 2 — P1: `db/schema.sql` not in implementation TODOs (FIXED)

`db/schema.sql` (a reference production schema file, distinct from the migrations) also
defines `app_role AS ENUM ('facility_admin', ...)` on line 25, and includes
`current_user_role() IN ('facility_admin', 'auditor')` in the `audit_read_admin` policy
on line 436. ADR 0011's implementation TODOs did not mention this file.

**Edit applied:** Added `db/schema.sql` TODO to the implementation TODOs section.

### Finding 3 — Confirmed consistent: all ADR cross-references

- ADR 0006: "assigned the `owner` role" — consistent ✓
- ADR 0007 Phase 1 Step 3b: `role = owner` — consistent ✓
- ADR 0010: `user.role IN ('owner', 'admin')` — consistent ✓ (written against the
  intended post-migration model; no changes to ADR 0010 needed)

### Finding 4 — Confirmed consistent: documentation layer

- `data_model.md` Role enum: already uses `owner`/`admin` ✓
- `data_model.md` implementation note (added in task 0027 companion update): correct ✓
- `ai_memory.md` blocker #5: correctly narrowed ✓
- `decisions/README.md`: ADR 0011 row present ✓
- `compliance_notes.md` role permissions table: Owner/Admin columns correct ✓
- No docs still imply `facility_admin` is canonical ✓

### Finding 5 — Confirmed: AuthProvider analysis correct

`AuthProvider.tsx` exports `AppRole = 'facility_admin' | 'caregiver' | 'med_tech' | 'family_member'`
(line 37) and `mapToStoreRole()` maps `facility_admin` → `admin` (line 141) — both correctly
identified as the bug in ADR 0011. `src/types/index.ts` exports a conflicting `AppRole = Role | 'family_member'`
— naming collision correctly flagged. DEMO_AUTH_USER has `role: 'facility_admin'` — correctly
identified as needing update.

### Finding 6 — Minor: JSDoc comment in AuthProvider.tsx

AuthProvider.tsx line 7 says "user = DEMO_AUTH_USER (Maria Gonzalez, facility_admin)" — after
migration this comment should say `owner`. ADR 0011 identifies the value fix but not this comment.
This is a minor implementation detail captured in the existing AuthProvider TODO; no ADR edit
needed (too fine-grained for an ADR).

## Recommendation

**Accept ADR 0011 with minor edits applied.** (Edits have been made in this task.)

The two edits applied:
1. Migration section corrected to use `RENAME VALUE` (factual fix)
2. `db/schema.sql` added to implementation TODOs

No conflicts with any existing ADR or documentation were found. The decision is sound,
well-reasoned, and aligns with all existing architecture docs. Cross-references to ADRs
0006, 0007, 0010 are consistent.

## Post-Acceptance Cleanup (after user accepts ADR 0011)

1. Update ADR 0011 status from `proposed` → `accepted`
2. Mirror the status change to `ai-workspace-framework`
3. Update `decisions/README.md` status column
4. Update `ai_memory.md` blocker #5 entry (change "proposed" → "accepted")
5. Update `execution_log.md`

## Schema Migration Enablement (after acceptance)

After ADR 0011 is accepted, backlog task 0027 (provisioning schema + RLS migrations)
may begin. The schema migration for the role rename is:
```sql
ALTER TYPE app_role RENAME VALUE 'facility_admin' TO 'owner';
ALTER TYPE app_role ADD VALUE IF NOT EXISTS 'admin';
```
Plus updating the 2 RLS policies (`family_resident_links` and `audit_events`) and
updating `AuthProvider.tsx` and `db/schema.sql` in the same release.

## Outcome

ADR 0011 edits applied. ADR 0011 is ready for user acceptance. Status remains `proposed`
pending explicit user approval. No application code changed.

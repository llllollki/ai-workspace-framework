Status: done
Created: 2026-05-17
Owner role: Claude Code (implementation agent)
Reviewers: Noel Castillo

## Goal

Extend the internal CRM MVP so ALH Tracker business/admin staff can manage facility customer records — add, edit, archive, and manage allowable resident count — within the existing `/crm` route tree. All behavior is local session state (prototype). No Supabase schema changes.

## Acceptance Criteria

- [ ] CRM user can create a facility customer record from `/crm/facilities`.
- [ ] CRM user can update facility profile fields (name, city, state, license placeholder, owner contact, subscription status, onboarding stage, ALH partner flag, relationship source, internal priority).
- [ ] CRM user can delete/archive a facility record with confirmation; archived facilities do not appear as active in dashboard counts or the default facilities list.
- [ ] CRM user can edit allowable resident count; input validates as a positive integer.
- [ ] The UI clearly distinguishes allowable resident count from real resident records (label and copy make clear this is a CRM-managed placeholder, not a live care-ops count).
- [ ] No resident care data (CareLogEntry, Resident, WellnessObservation, FollowUp, ObservedCareTask) is imported, displayed, created, edited, or deleted by any CRM screen.
- [ ] All behavior is demo/prototype local session state (Zustand store initialized from seed, not persisted to Supabase or localStorage).
- [ ] Build passes (`tsc && vite build` with zero errors).
- [ ] Manual smoke test passes: create facility, edit facility, change allowable resident count, archive facility, dashboard counts update, detail page of archived facility shows archived state, notes/follow-ups/comm log work after refactor.

## Plan

### Documentation (done first)
- [x] Create task 0011 in `tasks/active/alh-tracker/` in both mirrors.
- [ ] Update `projects/alh-tracker/features.md` — CRM facility management section.
- [ ] Update `projects/alh-tracker/data_model.md` — CRM entity model section with allowable resident count note.
- [ ] Update `projects/alh-tracker/ai_memory.md` — resolve / narrow the allowable resident count open question.
- [ ] Update `projects/alh-tracker/execution_log.md` after completion.
- [ ] Add internal CRM section to `alh-tracker/README.md`.
- [ ] Keep both ai-context mirrors aligned.

### Implementation

- [x] **types/crm.ts** — add `archived?: boolean` and `archivedAt?: string | null` to `CrmFacility`.
- [x] **src/store/useCrmStore.ts** — new Zustand store (no persistence). Holds facilities, communications, notes, followUps. Actions: `addFacility`, `updateFacility`, `archiveFacility`, `addCommunication`, `addNote`, `updateNote`, `addFollowUp`, `markFollowUpDone`. Initialized from seed constants.
- [x] **src/pages/crm/FacilityFormModal.tsx** — shared modal/form for create and edit. Fields: facility name, city, state, RCFE license placeholder, allowable resident count (validated positive integer), owner name, owner email, owner phone, preferred contact, relationship source, subscription status, onboarding stage, ALH partner, internal priority. Required field validation. Demo-safe placeholder language.
- [x] **CrmFacilities.tsx** — connect to `useCrmStore`; show only non-archived by default; add "Add facility" button that opens `FacilityFormModal` in create mode; show allowable resident count in the table; include archived toggle to reveal archived rows.
- [x] **CrmFacilityDetail.tsx** — connect to `useCrmStore`; add "Edit facility" button → `FacilityFormModal` in edit mode; add "Archive facility" destructive action with inline confirmation; if facility is archived, show an archived-state banner and disable edit/archive actions; preserve notes/follow-ups/comm log via store.
- [x] **CrmDashboard.tsx** — connect to `useCrmStore`; filter archived facilities from all pipeline summary counts; followUps and notes also from store.

### Verification
- [ ] `npm run build` passes clean.
- [ ] Manual smoke test of all acceptance criteria routes.
- [ ] Confirm no Supabase schema/migration/env/deployment files changed.
- [ ] Confirm no resident care types imported into CRM files.
- [ ] Commit app repo (`c:\Projects\alh-tracker`) and context repo (`c:\Projects\ai-workspace-framework`).

## Notes

- **Numbering conflict:** `0011-resident-profile-data-model-expansion.md` already exists in `tasks/backlog/alh-tracker/` (created 2026-05-16 during documentation review). This task uses the same number in `tasks/active/alh-tracker/`. The two tasks are in different folders and serve different purposes; the numbering collision is noted here for disambiguation. A future task-numbering cleanup should rationalize the backlog numbering.
- **Allowable resident count:** Per ADR 0005 and `ai_memory.md`, this field may eventually split into three separate fields: (a) licensed facility capacity (CDSS-issued), (b) subscription-tier resident limit (commercial), and (c) active resident count (operational). The current implementation uses a single `allowedResidentCount` integer field as a placeholder, with a clear UI label explaining it is a CRM-managed configuration field, not a live care-ops count.
- **No Supabase changes:** All CRM data for this task lives in a Zustand store initialized from demo seed data. No Supabase schema, migration, env, or RLS changes were made.
- **Data boundary:** CRM files import only from `src/types/crm.ts`. No imports from `src/types/index.ts` (resident/care types).
- **Archive vs. hard delete:** Archive (soft delete via `archived: true`) was chosen over hard delete to preserve customer records and allow recovery, consistent with how the facility tracker app handles resident records.

## Outcome

Completed 2026-05-17.

**Implementation:**
- `src/store/useCrmStore.ts` — new Zustand session store for CRM (no persistence). Holds facilities, communications, notes, followUps. All pages read from and write to this store.
- `src/pages/crm/FacilityFormModal.tsx` — shared create/edit form modal with all required CRM fields and validation.
- `src/types/crm.ts` — added `archived` and `archivedAt` to `CrmFacility`.
- `CrmFacilities.tsx` — store-connected, "Add facility" button, allowable resident count column, archived toggle.
- `CrmFacilityDetail.tsx` — store-connected, edit modal, archive confirmation, archived-state banner, notes/followUps/comms preserved via store.
- `CrmDashboard.tsx` — store-connected, all counts exclude archived facilities.

**Build:** Passed clean (`tsc && vite build`, 0 errors).

**Data boundary:** Confirmed. No resident care types imported into any CRM file.

**No Supabase schema changes.** Session-only demo state.

**App repo commit:** `1709a8d` (`main → main` pushed to origin).
**Context repo commit:** `79beb13` (`main → main` pushed to origin).

**Vercel:** Vercel should auto-deploy from the pushed app commit (`1709a8d`) if the Vercel project is connected to the `main` branch.

# 0057 — CRM Related Records Persistence

Status: done
Created: 2026-05-22
Owner role: AI agent (main)
Depends on: 0055 (CRM persistence API Phase 1), 0056 (CRM store/UI migration Phase 1)

## Goal

Persist CRM facility related records — notes, follow-ups, and communications — through
server-side CRM API endpoints. All writes must require CRM auth (requireCrmAuth),
use service-role DB access, and write crm.audit_log entries. Demo mode stays separate.

## Subagent Policy

Proceeding serially. Workstreams are strictly sequential: API endpoints → crmApi.ts →
store → UI. Each layer depends on the one before. Total scope: 5 new API files +
4 modified source files + 2 verification docs. Subagent coordination overhead exceeds
the benefit for this tightly-coupled chain.

## Acceptance Criteria

1. [ ] Notes/follow-ups/communications write actions persist through CRM API.
2. [ ] All write endpoints require CRM auth and use server-side service-role DB access.
3. [ ] Audit log entries are created for all write operations.
4. [ ] Demo mode remains separate and functional (no API calls in demo).
5. [ ] No browser direct access to crm.* tables is introduced.
6. [ ] No tracker care data or tracker internal IDs are exposed.
7. [ ] TypeScript passes: npx tsc --noEmit.
8. [ ] Build passes: npm run build.
9. [ ] npm run verify:secrets reports FAIL: 0, WARN: 0.
10. [ ] Task outcome written; moved to done; ai_memory/execution_log updated.

## Plan

- [x] Create this task document
- [ ] Create `api/crm/notes.ts` — POST create note
- [ ] Create `api/crm/notes/[id].ts` — PATCH update note content/priority
- [ ] Create `api/crm/communications.ts` — POST create communication
- [ ] Create `api/crm/follow-ups.ts` — POST create follow-up
- [ ] Create `api/crm/follow-ups/[id].ts` — PATCH update follow-up status
- [ ] Update `src/lib/crmApi.ts` — 5 new API functions
- [ ] Update `src/store/useCrmStore.ts` — async write actions, relatedWriteError state
- [ ] Update `src/pages/crm/CrmFacilityDetail.tsx` — async handlers, error state, copy updates
- [ ] Extend `scripts/verify-crm-persistence/scenarios.md` — P14–P20 scenarios
- [ ] Extend `scripts/verify-crm-persistence/db-assertions.sql` — A7–A9 assertions
- [ ] Run checks: npx tsc --noEmit, npm run build, npm run verify:secrets
- [ ] Write outcome; move to done; update execution_log and ai_memory

## API Design

### Routes

| File | Route | Methods |
|---|---|---|
| `api/crm/notes.ts` | `POST /api/crm/notes` | POST (create) |
| `api/crm/notes/[id].ts` | `PATCH /api/crm/notes/:id` | PATCH (update content/priority) |
| `api/crm/communications.ts` | `POST /api/crm/communications` | POST (create) |
| `api/crm/follow-ups.ts` | `POST /api/crm/follow-ups` | POST (create) |
| `api/crm/follow-ups/[id].ts` | `PATCH /api/crm/follow-ups/:id` | PATCH (update status) |

All routes: requireCrmAuth(req), service-role Supabase client, crm.audit_log write.

### POST /api/crm/notes

Required body: `facilityId` (uuid), `content` (non-empty string), `isPriority` (boolean)
Creates crm.notes row. `author_name` = actor.display_name.
Writes audit_log: `note_created`, changed_by = actor.crm_staff_id.
Returns 201: `{ ok: true, note: CrmNote }`

### PATCH /api/crm/notes/:id

Allowed body: `content` (string), `isPriority` (boolean).
Fetches note to get facility_id for audit log.
Updates crm.notes row. Sets updated_at.
Writes audit_log: `note_updated`, previous_values snapshot.
Returns 200: `{ ok: true, note: CrmNote }`

### POST /api/crm/communications

Required body: `facilityId` (uuid), `noteType` (enum string), `content` (non-empty string)
Creates crm.communications row. `author_name` = actor.display_name.
Writes audit_log: `communication_created`, changed_by = actor.crm_staff_id.
Returns 201: `{ ok: true, communication: CrmCommunicationEntry }`

### POST /api/crm/follow-ups

Required body: `facilityId` (uuid), `description` (non-empty string), `dueDate` (date string)
Creates crm.follow_ups row. `assigned_to` = actor.display_name, status = 'open'.
Writes audit_log: `follow_up_created`.
Returns 201: `{ ok: true, followUp: CrmFollowUp }`

### PATCH /api/crm/follow-ups/:id

Allowed body: `status` ('open' | 'done' | 'snoozed').
Fetches follow-up to get facility_id for audit log.
Updates crm.follow_ups row.
Writes audit_log: `follow_up_updated`, previous_values snapshot.
Returns 200: `{ ok: true, followUp: CrmFollowUp }`

### Response security

- author_name and assigned_to use actor.display_name (crm.crm_staff.name), not auth.users.id
- No tracker IDs, raw tokens, care data in any response
- Changed_by in audit_log = actor.crm_staff_id (crm.crm_staff.id UUID)

## Store Changes

### New state

```typescript
relatedWriteError: Record<string, string | null>  // per-facilityId
clearRelatedWriteError: (facilityId: string) => void
```

### Changed action signatures

```typescript
addCommunication: (...) => Promise<void>  // was void
addNote: (...) => Promise<void>           // was void
updateNote: (...) => Promise<void>        // was void
addFollowUp: (...) => Promise<void>       // was void
markFollowUpDone: (id: string) => Promise<void>  // was void
```

Demo mode: all resolve immediately (existing behavior). No API calls.
Authenticated mode: call API, update local state with server response, set relatedWriteError on failure.

## UI Changes (CrmFacilityDetail.tsx)

- Make handleAddComm, handleAddOrUpdateNote, handleAddFollowUp async; await store actions.
- After await: check relatedWriteError before resetting form (don't reset on failure).
- markFollowUpDone onClick: void markFollowUpDone(...) — fire-and-forget; error shown via relatedWriteError.
- Add relatedWriteError banner near related records sections.
- Update "Demo only" note copy: show health-data warning in authenticated mode, "Demo only" in demo mode.
- Import getSupabaseClient to derive isAuthenticated for copy branching.

## Notes

- author_name denormalization remains (actor.display_name from crm.crm_staff.name) — acceptable per task.
- Do not add note delete/archive (UI has no delete action for notes).
- Do not add communication update/delete (UI has no such actions).
- Do not expose tracker care data, public.users, or tracker internal IDs.
- CRM_DEMO_AUTH_BYPASS still documented — Phase 0 only.

## Outcome

Completed 2026-05-23. All acceptance criteria met.

**New API endpoints:**
- `api/crm/notes.ts` — POST /api/crm/notes (create note; validates facilityId, content, isPriority; writes author_name = actor.display_name; audit_log note_created; returns 201 CrmNote)
- `api/crm/notes/[id].ts` — PATCH /api/crm/notes/:id (update content/isPriority; fetches current for facility_id + previous_values snapshot; audit_log note_updated; returns 200 CrmNote)
- `api/crm/communications.ts` — POST /api/crm/communications (create comm; validates noteType against ALLOWED_NOTE_TYPES; writes author_name = actor.display_name; audit_log communication_created; returns 201 CrmCommunicationEntry)
- `api/crm/follow-ups.ts` — POST /api/crm/follow-ups (create follow-up; validates facilityId, description, dueDate; sets assigned_to = actor.display_name, status = 'open'; audit_log follow_up_created; returns 201 CrmFollowUp)
- `api/crm/follow-ups/[id].ts` — PATCH /api/crm/follow-ups/:id (update status to open/done/snoozed; validates against ALLOWED_STATUSES; fetches current for facility_id + previous_values; audit_log follow_up_updated; returns 200 CrmFollowUp)

All endpoints: requireCrmAuth(), service-role DB access, crm.audit_log writes, changed_by = actor.crm_staff_id.

**Client-side changes:**
- `src/lib/crmApi.ts`: 5 new exported functions (createNote, patchNote, createCommunication, createFollowUp, patchFollowUpStatus). Same auth-header + error-handling pattern as existing functions.
- `src/store/useCrmStore.ts`: added relatedWriteError (per-facilityId) state and clearRelatedWriteError action. All 5 write actions made async: demo mode resolves immediately with local-only update; authenticated mode calls API, updates store with server response, sets relatedWriteError on failure. updateNote and markFollowUpDone use optimistic local update; markFollowUpDone reverts on API failure.
- `src/pages/crm/CrmFacilityDetail.tsx`: handleAddComm, handleAddOrUpdateNote, handleAddFollowUp made async — await store action, check relatedWriteError before form reset (form stays open on failure). relatedWriteError error banner added. Health-data warning copy added to note and comm forms in authenticated mode. "Demo only" copy wrapped in {isDemo && ...} throughout.

**Verification:**
- `scripts/verify-crm-persistence/scenarios.md`: P14–P20 added (create note, update note, create comm with invalid noteType rejection, create follow-up, mark done with invalid status rejection, 401/403 rejection on all new endpoints, detail endpoint returns persisted records)
- `scripts/verify-crm-persistence/db-assertions.sql`: A7–A9 added (post-note, post-comm, post-follow-up assertions including audit_log entries and previous_values)

**Checks:** npx tsc --noEmit clean; npm run build clean (479.00 kB); npm run verify:secrets FAIL: 0 WARN: 0.

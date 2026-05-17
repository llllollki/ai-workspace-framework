---
Status: done
Created: 2026-05-17
Completed: 2026-05-17
Owner role: Frontend / AI agent
Reviewers: Product owner

## Goal

Build the first usable internal CRM surface for ALH Tracker business/admin staff as a separate route (`/crm`) in the existing React/Vite app. This CRM is desktop-only, for ALH Tracker internal staff only, and manages commercial relationship data only. It does not expose resident care data. Auth model is TODO — implemented as demo/internal prototype only.

## Acceptance Criteria

- [x] `/crm` route renders a CRM dashboard visible only to internal staff (demo prototype mode)
- [x] CRM dashboard shows: pipeline summary, onboarding status counts, active/trial/paused/canceled counts, upcoming follow-ups, high-priority notes
- [x] Facilities list shows: name, city/region, RCFE/license placeholder, capacity, CRM status, onboarding stage, subscription status, owner/contact summary
- [x] Facility CRM detail shows: full facility profile, owner/operator contact info, allowed resident count, onboarding checklist, subscription placeholder, communication log, support/admin notes, internal-only warning label
- [x] CRM notes/follow-ups: add/edit demo-only internal note and follow-up date/status
- [x] No resident care data appears in any CRM view
- [x] CRM has its own layout (CrmLayout) visually separate from the facility tracker app layout
- [x] CRM clearly labeled as internal prototype / demo only
- [x] CRM auth is explicitly marked TODO — not pretended to be production-ready
- [x] `npm run build` passes (tsc + vite build clean)
- [x] Smoke test: `/crm`, CRM facilities list, CRM facility detail, main tracker `/`, `/family` — verified 2026-05-17; all routes 200 OK, build clean, data boundary confirmed
- [x] No application source outside CRM/UI scope was changed (no Supabase schema changes, no resident care data touched)

## Plan

- [x] Read architecture context (ADR 0005, overview.md, features.md)
- [x] Verify CRM-in-repo is consistent with docs (confirmed: matches family portal pattern; ADR 0005 authorizes)
- [x] Create CRM TypeScript types in `src/types/crm.ts`
- [x] Create CRM mock/demo seed data in `src/data/crm-seed.ts`
- [x] Create CrmLayout component in `src/components/CrmLayout.tsx`
- [x] Create CRM pages:
  - [x] `src/pages/crm/CrmDashboard.tsx`
  - [x] `src/pages/crm/CrmFacilities.tsx`
  - [x] `src/pages/crm/CrmFacilityDetail.tsx`
- [x] Update `src/App.tsx` to add `/crm` route tree
- [x] Run `npm run build` and verify
- [x] Update execution_log.md
- [x] Mirror task doc to ai-workspace-framework

## Notes

- CRM is implemented as a demo/internal prototype. CRM auth model (separate from facility tracker auth) is explicitly TODO per ADR 0005.
- CRM uses local React state + mock seed data only. No Supabase schema changes in this pass.
- CRM types live in `src/types/crm.ts` — entirely separate from `src/types/index.ts` (resident/care types).
- Mock data uses 7 fake/demo facility names and fake owner info. No real facility or person data.
- Product boundary enforced: CRM pages import no resident care types from `src/types/index.ts`.
- "Allowable resident count" distinction (licensed capacity vs. subscription limit vs. active count) is an open question per ADR 0005 — represented as a single `allowedResidentCount` field in this MVP with a TODO comment in the types file.
- Internal CRM warning banner appears on every CRM screen via CrmLayout.

## Outcome

Implementation complete. Build passed clean.

**Files created:**
- `src/types/crm.ts` — CRM-specific types, enums, label constants
- `src/data/crm-seed.ts` — 7 demo facilities + communications, notes, follow-ups
- `src/components/CrmLayout.tsx` — dark-slate desktop sidebar, internal-only warning banner, TODO auth notice
- `src/pages/crm/CrmDashboard.tsx` — pipeline summary, onboarding counts, follow-up list, priority notes, facilities table
- `src/pages/crm/CrmFacilities.tsx` — filterable facilities list
- `src/pages/crm/CrmFacilityDetail.tsx` — full facility detail with add/edit notes, follow-ups, and communication log

**Files modified:**
- `src/App.tsx` — added `/crm`, `/crm/facilities`, `/crm/facilities/:id` routes under CrmLayout

**Remaining TODOs:**
- CRM auth model (ADR 0005 open question) — unguarded route in demo mode; production CRM auth requires separate design
- Onboarding checklist is read-only in this MVP — editing/saving checklist items is TODO
- Notes and follow-ups use local React state only — not persisted to Supabase
- "Allowable resident count" field distinction (licensed / subscription / active) is TODO per ADR 0005
- Smoke test by product owner before treating this as production-ready (it is prototype only)

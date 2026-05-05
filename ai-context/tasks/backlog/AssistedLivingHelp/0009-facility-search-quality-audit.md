# Audit Facility Search and Profile Quality

Status: backlog
Created: 2026-05-04
Owner role: QA / Test Lead
Reviewers: Data / Matching Specialist, Product / Program Lead

## Goal

Audit the existing logged-in facility search and profile experience against Phase 1 data-quality requirements.

## Acceptance Criteria

- Current filters are compared against dependable Phase 1 fields.
- Facility profile fields are checked for empty, misleading, or sparse-data display issues.
- Public visibility and licensing/status wording are reviewed for clarity.
- CTA behavior back into intake/matching help is verified.
- Findings are organized into fix tasks.

## Plan

- [ ] Review `features.md` facility discovery requirements and `data_model.md` source limitations.
- [ ] Inspect current `/facilities` and `/facilities/[id]` pages.
- [ ] Test search/filter behavior against current Phase 1 data.
- [ ] Document misleading, empty, or unsupported fields.
- [ ] Create follow-up implementation tasks for fixes.

## Notes

- Advanced filters should not become Phase 1 defaults unless the underlying data is dependable.
- Blocked by `0003-curate-phase1-facility-subset.md`.

## Outcome

Pending.

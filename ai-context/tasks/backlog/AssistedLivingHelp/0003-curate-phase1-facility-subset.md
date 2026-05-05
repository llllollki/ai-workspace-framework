# Curate Phase 1 Facility Subset

Status: backlog
Created: 2026-05-04
Owner role: Data / Matching Specialist
Reviewers: Product / Program Lead, Operations / Concierge Workflow Lead

## Goal

Define and produce the vetted Phase 1 facility subset from the current California facility data, using dependable fields first and excluding records that are not appropriate for launch display or matching.

## Acceptance Criteria

- The source tables and quality rules are documented.
- Inclusion and exclusion rules are defined for facility type, active/public status, location completeness, capacity, and service area.
- The Phase 1 subset can be traced back to source records.
- Sparse fields such as pricing, amenities, websites, reviews, and live availability are explicitly excluded from launch promises unless verified.
- A follow-up implementation task is ready for updating `phase1_facilities.json` or the app-facing data source.

## Plan

- [ ] Review `data_model.md`, `features.md`, and current app facility pages.
- [ ] Inspect current facility source files and data-quality assumptions.
- [ ] Draft curation rules for Phase 1 display and matching eligibility.
- [ ] Define manual review fields and suppression criteria.
- [ ] Produce a recommended implementation plan for refreshing the app-facing subset.

## Notes

- Keep the MVP narrow. Do not treat the full raw SQLite dataset as a public directory.

## Outcome

Pending.

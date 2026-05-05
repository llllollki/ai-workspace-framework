# Define Phase 1 Market Boundaries

Status: active
Created: 2026-05-04
Owner role: Product / Program Lead
Reviewers: Data / Matching Specialist, Operations / Concierge Workflow Lead, Compliance / Privacy Counsel

## Goal

Define the exact city, ZIP code, county, and hospital-anchor boundaries for the five Phase 1 launch markets so facility curation, landing pages, intake routing, and lead matching all use the same market map.

## Acceptance Criteria

- The five hospital anchors are listed with their supported cities, ZIP codes, and counties.
- Each supported city/ZIP is assigned to one primary launch market, with notes for overlap areas.
- Out-of-market handling is specified at a product level.
- The result is ready to update `projects/AssistedLivingHelp/overview.md`, `data_model.md`, and app market configuration in a later implementation task.
- Compliance review notes any market wording that could imply hospital affiliation or endorsement.

## Plan

- [ ] Review current market references in `overview.md`, `features.md`, `data_model.md`, and `user_flows.md`.
- [ ] Inspect existing app market configuration in `AssistedLivingHelp/lib/markets.ts`.
- [ ] Draft a market boundary table for the five hospital anchors.
- [ ] Define overlap and out-of-market handling rules.
- [ ] Identify what app/config files would need updates in a future implementation task.
- [ ] Record unresolved questions in `ai_memory.md` if exact ZIP/county boundaries require external validation.

## Notes

- Do not imply hospital partnership, endorsement, affiliation, or referral relationship unless it is true and documented.
- This task is planning/documentation first. App changes should be a separate task after the boundaries are accepted.

## Outcome

Pending.

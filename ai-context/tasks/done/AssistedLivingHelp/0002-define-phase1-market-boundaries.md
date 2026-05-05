# Define Phase 1 Market Boundaries

Status: done
Created: 2026-05-04
Completed: 2026-05-04
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

- [x] Review current market references in `overview.md`, `features.md`, `data_model.md`, and `user_flows.md`.
- [x] Inspect existing app market configuration in `AssistedLivingHelp/lib/markets.ts`.
- [x] Draft a market boundary table for the five hospital anchors.
- [x] Define overlap and out-of-market handling rules.
- [x] Identify what app/config files would need updates in a future implementation task.
- [x] Record unresolved questions in `ai_memory.md` if exact ZIP/county boundaries require external validation.

### Phase 1 Market Boundary Table

MVP precision: city-level only. ZIP-level boundaries deferred to a pre-paid-launch validation pass — see open items in `ai_memory.md`.

| Slug | Hospital Anchor | Primary County | Primary Cities (intake routing) | Secondary / Service-Area Cities | Overlap Summary |
|---|---|---|---|---|---|
| `temecula-valley` | Temecula Valley Hospital | Riverside County | Temecula, Winchester, French Valley | Murrieta | Murrieta → `rancho-springs` |
| `inland-valley` | Inland Valley Hospital | Riverside County | Wildomar, Lake Elsinore† | Murrieta, Menifee | Murrieta → `rancho-springs`; Menifee → `menifee-global` |
| `rancho-springs` | Rancho Springs Hospital | Riverside County | Murrieta | Temecula, Menifee, Wildomar | Murrieta primary here. All others primary in their named market. |
| `murrieta-loma-linda` | Loma Linda University Medical Center - Murrieta | Riverside County | (supplemental — none) | Murrieta, Temecula, Menifee, Wildomar | All four cities primary elsewhere. Market serves LLUMC proximity searches only. |
| `menifee-global` | Menifee Global Medical Center | Riverside County | Menifee, Sun City†, Perris† | Murrieta | Menifee primary here. Murrieta → `rancho-springs`. |

† Secondary/service-area city — retained in Phase 1 config; validate against facility subset before paid launch.

### Primary Market Assignment for Overlap Cities

When intake routing must assign a city to exactly one primary market:

| City | Primary Market | Basis |
|---|---|---|
| Murrieta | `rancho-springs` | Explicit business decision — Rancho Springs Hospital is the Murrieta-specific anchor. |
| Menifee | `menifee-global` | Explicit business decision — Menifee Global Medical Center is the Menifee-specific anchor. |
| Temecula | `temecula-valley` | Logical assignment — Temecula Valley Hospital is named for this city and is located there. |
| Wildomar | `inland-valley` | Logical assignment — Inland Valley Hospital is physically located in Wildomar. |

### Out-of-Market Intake Handling

Accept all leads regardless of city. When a submitted city does not match any market's city list:

- Tag the lead record as `out_of_market`.
- Show the user: the team will review the request, but do not promise matched facilities or scheduling support outside supported areas.
- Do not reject the form submission.
- Log the city for future expansion tracking.

### Files Requiring Future Implementation Updates

Do not modify these in this task. A future implementation task will apply changes after this boundary document is accepted.

- `AssistedLivingHelp/lib/markets.ts` — add `county` field; add `primaryCities` vs `serviceCities` distinction; review secondary city list against this table.
- `AssistedLivingHelp/app/markets/[slug]/page.tsx` — verify hospital-anchor copy is compliant before launch (see compliance open item in `ai_memory.md`).
- Supabase `launch_markets` table — likely needs `county text` column; `out_of_market` lead handling requires `leads` schema review.
- `ai-context/projects/AssistedLivingHelp/overview.md` — update market section with approved boundary definitions.
- `ai-context/projects/AssistedLivingHelp/data_model.md` — update `launch_markets` schema docs; add `out_of_market` field to `leads` docs.

## Notes

- Do not imply hospital partnership, endorsement, affiliation, or referral relationship unless it is true and documented.
- This task is planning/documentation first. App changes should be a separate task after the boundaries are accepted.
- The `murrieta-loma-linda` market has no exclusively-primary cities for MVP intake routing. It serves as supplemental coverage for LLUMC Murrieta proximity searches. If this market needs to generate leads independently, it may need a dedicated primary city list in a later revision.
- Temecula and Wildomar primary assignments (to `temecula-valley` and `inland-valley` respectively) follow hospital geography and were not explicitly decided by the product owner — flag for confirmation if the business logic differs.
- Compliance review (2026-05-04): hospital-anchor eyebrow copy fixed to "Near {hospitalAnchor}" in three render locations; menifee-global summary changed from "referring partners" to "facility partners". Advisory: "Murrieta Loma Linda" market display name flagged for future Compliance/Privacy Counsel acknowledgment — no change made, tracked in `ai_memory.md`.

## Outcome

Draft market boundary table complete (2026-05-04). City-level boundaries defined for all five Phase 1 markets. Primary market assignments established for all overlap cities. Out-of-market intake handling specified. ZIP-level validation deferred to pre-launch pass (tracked in `ai_memory.md`).

Compliance wording review complete (2026-05-04): (1) bare hospital-anchor labels prefixed with "Near" in all three render locations (`[slug]/page.tsx`, `markets/page.tsx`, `page.tsx`); (2) menifee-global summary changed from "referring partners" to "facility partners" (`lib/markets.ts`). Advisory item open: "Murrieta Loma Linda" market display name requires Compliance/Privacy Counsel acknowledgment — no change made, tracked in `ai_memory.md`.

Complete. Moved to done 2026-05-04.

# AssistedLivingHelp — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

> Migrated from `AssistedLivingHelp\CLAUDE.md` — Open Questions For Later Implementation section. Source document retained unchanged.

- what tech stack should be used for frontend and backend?
- what service-level promise should be shown to families after submission?
- which facility statuses should be publicly visible in v1?
- what exact consent language will be used for SMS, calls, email, and facility sharing?
- will facilities have their own partner login in a future phase?
- what data enrichment pipeline is needed before advanced filters are enabled?
- which premium features will be available at launch versus later?
- what renewal model should be used for partner accounts?

## Immediate Next Steps

> Migrated from `AssistedLivingHelp\CLAUDE.md` — Immediate Next Step section. Source document retained unchanged.

Before coding, define the MVP around the real SQLite dataset and the real operating model:

- define the exact facility subset for the supported Phase 1 markets
- define the intake questionnaire and which fields are required on first submit
- define the automated confirmation timeline and communication templates
- define the consent model for SMS, calls, email, and facility sharing
- define the facility outreach and scheduling workflow, including human escalation
- define the partner package structure, listing fees, premium add-ons, and business development workflow

## Current Working Context

<!-- Add temporary assumptions, in-progress decisions, and unresolved questions here as work progresses. Remove entries when resolved. -->

**Resolved — 2026-05-03:** The open question "what should the initial listing fee and premium add-on pricing be?" has been removed. Pricing tiers ($299–$499 Starter, $699–$999 Growth, $500–$1,500 Concierge) and add-on pricing are now documented in `business_development.md`.

**Resolved — 2026-05-04:** City-level and county boundaries for all five Phase 1 markets defined in task 0002. Open question "what exact city / ZIP / county boundaries define each Phase 1 launch market?" removed — city and county are resolved; ZIP-level deferred (see open item below).

**Resolved — 2026-05-04:** Out-of-market intake handling defined in task 0002. Accept all leads; tag as `out_of_market`; message carefully without promising facility coverage. Open question "how should no-results and out-of-market requests be handled?" removed.

**Open — ZIP-level market boundary validation (required before paid launch):** Exact ZIP codes for each Phase 1 market have not been defined. City-level routing is sufficient for MVP, but ZIP-level boundaries are required before paid launch for precise facility matching and routing. An external validation pass (USPS ZIP data or manual mapping) is needed. Affects: `lib/markets.ts`, `launch_markets` Supabase table, and intake routing logic.

**Open — Secondary city facility validation:** Perris, Sun City, and Lake Elsinore are retained as secondary/service-area cities in Phase 1 config. Confirm facility availability and active coverage in these cities before promoting them to active service-area cities. Flag during facility subset curation (task backlog: 0003 or equivalent).

**Resolved — 2026-05-04:** Compliance wording review of hospital-anchor copy complete (task 0002). Findings fixed: bare hospital-anchor labels prefixed with "Near" in three render locations (`[slug]/page.tsx`, `markets/page.tsx`, `page.tsx`); menifee-global summary changed from "referring partners" to "facility partners" (`lib/markets.ts`). Open item "Compliance review of hospital-anchor wording" removed.

**Open — Compliance/Privacy Counsel acknowledgment: "Murrieta Loma Linda" market name:** The market display name "Murrieta Loma Linda" combines the city name with the Loma Linda University Health brand, which is strongly regionally associated. Counsel should confirm this is acceptable as a geographic reference or recommend an alternative display name. No code change required until counsel responds.

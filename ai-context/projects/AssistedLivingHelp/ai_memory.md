# AssistedLivingHelp — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

> Migrated from `AssistedLivingHelp\CLAUDE.md` — Open Questions For Later Implementation section. Source document retained unchanged.

- what tech stack should be used for frontend and backend?
- what exact city / ZIP / county boundaries define each Phase 1 launch market?
- what service-level promise should be shown to families after submission?
- which facility statuses should be publicly visible in v1?
- what exact consent language will be used for SMS, calls, email, and facility sharing?
- will facilities have their own partner login in a future phase?
- how should no-results and out-of-market requests be handled?
- what data enrichment pipeline is needed before advanced filters are enabled?
- which premium features will be available at launch versus later?
- what renewal model should be used for partner accounts?

## Immediate Next Steps

> Migrated from `AssistedLivingHelp\CLAUDE.md` — Immediate Next Step section. Source document retained unchanged.

Before coding, define the MVP around the real SQLite dataset and the real operating model:

- define the exact facility subset for the supported Phase 1 markets
- define the city / ZIP / county boundaries for the five hospital anchors
- define the intake questionnaire and which fields are required on first submit
- define the automated confirmation timeline and communication templates
- define the consent model for SMS, calls, email, and facility sharing
- define the facility outreach and scheduling workflow, including human escalation
- define the partner package structure, listing fees, premium add-ons, and business development workflow

## Current Working Context

<!-- Add temporary assumptions, in-progress decisions, and unresolved questions here as work progresses. Remove entries when resolved. -->

**Resolved — 2026-05-03:** The open question "what should the initial listing fee and premium add-on pricing be?" has been removed. Pricing tiers ($299–$499 Starter, $699–$999 Growth, $500–$1,500 Concierge) and add-on pricing are now documented in `business_development.md`.

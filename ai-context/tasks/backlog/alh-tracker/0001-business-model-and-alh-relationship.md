# Task 0001 — Business Model and ALH Relationship

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Product / Program Lead
**Reviewers:** Business Development / Partner Success Lead

---

## Goal

Lock the pricing model for alh-tracker and define how it integrates commercially with the AssistedLivingHelp facility partner relationship.

Specifically:
- Is alh-tracker free for ALH facility partners, discounted, or priced independently as an add-on?
- What is the standalone SaaS pricing model for non-ALH facilities?
- How and when is alh-tracker introduced in ALH facility BD conversations?
- Are there shared onboarding or billing workflows between ALH and alh-tracker?

---

## Acceptance Criteria

1. A documented pricing model for alh-tracker: model type (per-facility flat rate vs. per-resident-per-month) and price ranges.
2. A documented policy for ALH facility partner pricing: standalone, discounted, or bundled — and at what rate.
3. A documented commercial boundary: what is shared (the commercial relationship) and what is not (resident care data).
4. A recommendation on whether alh-tracker is introduced in ALH BD conversations before or after MVP launch.
5. Durable decisions recorded as ADRs in `decisions\`. Resolved assumptions removed from `ai_memory.md`.

---

## Plan

- [ ] Review AssistedLivingHelp BD pricing tiers (`business_development.md`): Starter $299–$499, Growth $699–$999, Concierge $500–$1,500
- [ ] Assess typical willingness-to-pay for small RCFE operators (6–20 residents); context: these are often sole-operator homes with thin margins
- [ ] Define alh-tracker standalone pricing range and model
- [ ] Define ALH partner discount or bundle policy
- [ ] Define the commercial and data boundary between products (commercial relationship shared; resident care data not)
- [ ] Write a brief recommendation document
- [ ] Record durable decisions as ADRs in `decisions\`
- [ ] Update `ai_memory.md`: remove resolved open questions, add any new ones surfaced

---

## Notes

- Current assumption: standalone SaaS for non-ALH facilities; discounted or bundled for ALH partners. Not locked.
- ALH facility partners currently pay $299–$999/month for listing packages. alh-tracker pricing should be complementary in positioning and not feel like a second monthly bill for a product that should help operators.
- The data boundary (resident care data must not flow to the ALH placement side) is already a decided product constraint documented in `overview.md`. This task resolves only the commercial model.
- Small RCFE operators (6–20 residents) typically generate modest revenue per resident per day. A $300/month software bill may require justification; $99–$199/month may feel more accessible.

---

## Outcome

<!-- To be filled when the task is completed. -->

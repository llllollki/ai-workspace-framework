# 0003 — Business Model: ALH Partner Pricing and Shared Onboarding Policy

**Date:** 2026-05-09
**Status:** accepted
**Supersedes:** n/a
**Superseded by:** [0005 — CRM and Mobile Distribution Strategy](0005-crm-and-mobile-distribution-strategy.md)

## Context

Task 0001 established two upstream decisions: flat monthly per-facility pricing (ADR 0002) and the strategic posture that alh-tracker is primarily a stickiness and relationship-depth tool for AssistedLivingHelp facility partners, not a standalone-SaaS-first business. Two questions remained open and block Phase 1 planning:

1. What is the specific ALH facility partner pricing structure — free, discounted add-on, or bundled into an ALH listing tier?
2. Should alh-tracker and AssistedLivingHelp share onboarding or billing workflows?

The non-ALH standalone price point ($99–$199/month working range, $149/month recommended) remains an open working assumption — it requires design partner and pilot validation before it can be locked.

## Decision

### ALH Facility Partner Pricing

ALH facility partners pay as follows, by phase:

| Phase | Pricing | Notes |
|---|---|---|
| Design partner (Phase 0) | Free | No charges during design partner engagement; no conditions |
| Phase 1 ALH partner pilot | Free | Invite-only cohort of existing ALH partners; free during pilot |
| Commercial transition (Phase 2+) | $49/month add-on | Founding partner rate; applied when the ALH partner pilot moves to commercial terms |

The $49/month founding partner rate applies regardless of the facility's ALH listing tier (Starter, Growth, or Concierge). Tiering by ALH tier is deferred — it adds commercial complexity before the product has proven retention value at any tier.

The founding partner rate ($49/month) must be communicated explicitly before any design partner or pilot conversation concludes — not left open as a future negotiation. Re-pricing existing partners after they have been offered a rate is operationally difficult and damages trust. The rate is intentionally set well below the non-ALH standalone working range to reflect the relationship value and to not feel like a second independent bill alongside ALH listing fees.

### Non-ALH Standalone Pricing

Working range: **$99–$199/month per facility.** Recommended test price: **$149/month.**

**This is a working assumption, not a locked price.** It must be validated in design partner conversations and early pilot pricing discussions before it becomes binding. Do not quote $149/month in any commercial commitment until at least one design partner pricing sensitivity probe has been completed (see task 0002, Section 6 — validation checklist).

### Shared Onboarding and Billing: No Shared System at MVP

alh-tracker and AssistedLivingHelp use separate account creation, separate billing, and separate invoicing at MVP. There is no shared onboarding or billing integration.

ALH partner identification is communicated via the `alh_partner` boolean and `alh_partner_tier` field on the Facility entity — a lightweight commercial relationship flag, not a billing integration. Provisioning an alh-tracker account does not require action in the ALH billing system. Billing for alh-tracker is handled independently of the ALH listing invoice.

Rationale:
- A shared billing system requires ALH platform integration before alh-tracker has any customers — pre-validating an integration against zero demand.
- Shared onboarding creates a technical path between the two systems that increases data boundary risk (ADR 0001).
- Manual ALH partner identification (via the `alh_partner` flag set during account setup) is sufficient at the scale of the Phase 1 pilot (small cohort, hand-managed).
- This decision can be revisited if ALH partner volume exceeds what can be managed manually — at that scale, the build investment in shared provisioning is justified.

## Consequences

**Easier:** Phase 1 ALH partner pilot can begin without any technical integration between the two products. Partner pricing is defined and can be communicated in ALH BD conversations. No billing entanglement reduces data boundary risk. The ALH BD team has a clear, approved pricing message for design partner outreach.

**Harder:** ALH partner identification in alh-tracker requires a manual step (setting the `alh_partner` boolean during account setup). At low volume this is acceptable; at high volume it becomes an operational bottleneck. Non-ALH pricing validation is still required before Phase 2 standalone beta pricing is set — the task 0001 open question on price validation remains until design partner conversations are completed.

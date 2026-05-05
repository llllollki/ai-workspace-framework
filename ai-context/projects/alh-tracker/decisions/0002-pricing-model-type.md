# 0002 — Pricing Model Type: Flat Monthly Per-Facility

**Date:** 2026-05-05
**Status:** accepted
**Supersedes:** n/a
**Superseded by:** n/a

## Context

alh-tracker targets small California RCFE operators with 6–20 residents. Multiple pricing model types are possible for SaaS serving this segment: flat monthly per-facility, per-resident-per-month, per-seat (per-caregiver account), or usage-based. The pricing model type must be decided before price points can be validated, because the model affects onboarding conversations, invoice predictability, and the operator's perceived risk of adoption.

## Decision

alh-tracker uses a flat monthly subscription per facility. There is no per-resident component at launch.

Rationale:
- Small care homes have variable census. Per-resident billing creates unpredictable monthly invoices and a monthly reconciliation burden on the operator. Sole operators running 6–20 resident homes have enough administrative overhead without tracking software billing against room occupancy.
- Per-seat pricing (per-caregiver) has similar problems: facilities use float and agency staff, so seat count varies.
- Flat-rate is the simplest model to explain, easiest to budget for, and lowest friction at the onboarding conversation.
- The product's value — replacing the paper binder, making shift handoff auditable — does not scale meaningfully with resident count at small facility sizes.

This decision does not fix the price. The price range ($99–$199/month for non-ALH facilities) and the exact ALH partner discount or bundle structure are working assumptions documented in task 0001 and subject to design partner and pilot validation. See task 0001 for a full pricing ADR to be written when those price points are confirmed.

## Consequences

**Easier:** Onboarding is simpler (one line item, one monthly amount). Operators can budget without tracking census against their software invoice. Sales conversations are cleaner.

**Harder:** Revenue does not scale automatically with facility size within the target segment. A 20-resident facility pays the same as a 6-resident facility, which under-captures value at the larger end. This trade-off is acceptable at MVP given the target segment's profile; pricing tiers by facility size (e.g., a higher tier for facilities above 15 residents) can be introduced later if revenue capture becomes a concern.

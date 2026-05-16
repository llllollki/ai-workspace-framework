# Task 0001 — Business Model and ALH Relationship

**Project:** alh-tracker
**Status:** active
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

- [x] Review AssistedLivingHelp BD pricing tiers (`business_development.md`): Starter $299–$499, Growth $699–$999, Concierge $500–$1,500
- [x] Assess typical willingness-to-pay for small RCFE operators (6–20 residents); context: these are often sole-operator homes with thin margins
- [x] Define alh-tracker standalone pricing range and model
- [x] Define ALH partner discount or bundle policy — $49/month add-on at commercial transition; free during design partner and Phase 1 pilot; recorded in ADR 0003
- [x] Define the commercial and data boundary between products (commercial relationship shared; resident care data not)
- [x] Write a brief recommendation document
- [x] Record durable decisions as ADRs in `decisions\` — ADR 0001 (data boundary), ADR 0002 (pricing model type), ADR 0003 (ALH partner pricing and shared onboarding)
- [x] Update `ai_memory.md`: business model open questions resolved (2026-05-09)

---

## Notes

- Current assumption: standalone SaaS for non-ALH facilities; discounted or bundled for ALH partners. Not locked.
- ALH facility partners currently pay $299–$999/month for listing packages. alh-tracker pricing should be complementary in positioning and not feel like a second monthly bill for a product that should help operators.
- The data boundary (resident care data must not flow to the ALH placement side) is already a decided product constraint documented in `overview.md`. This task resolves only the commercial model.
- Small RCFE operators (6–20 residents) typically generate modest revenue per resident per day. A $300/month software bill may require justification; $99–$199/month may feel more accessible.

---

## Planning Notes

**Activated 2026-05-05.** Strategic direction provided at task activation:

- **Strategic posture:** alh-tracker is positioned primarily as a stickiness and relationship-depth tool for AssistedLivingHelp facility partners, not a standalone SaaS-first business. Pricing and positioning decisions should reflect this ordering.
- **ALH partner pricing direction:** Bundled or heavily discounted during early rollout. Should not feel like a second independent bill alongside ALH listing fees. Exact structure (free tier, percentage discount, fixed bundle) is what this task must determine.
- **Non-ALH pricing direction:** Flat monthly rate per facility. Working range: $99–$199/month. Per-resident pricing is explicitly deferred — adds complexity at onboarding and harder to justify for sole-operator homes with variable census.
- **BD timing:** alh-tracker may be introduced in ALH facility BD conversations now as a "coming soon / design partner invitation" signal only. Not a finished-product promise. This framing should generate design partner candidates (feeding task 0002), not a launch pipeline.
- **What this task must finalize:** Exact price points, ALH partner discount or bundle structure, BD introduction timing recommendation, and the formal commercial boundary document.

---

## Outcome

> **Status: work in progress — task not yet closed.** The recommendation below is complete. Two items block closure: (1) exact ALH partner pricing rate and structure not finalized; (2) standalone price point requires design partner / pilot validation before the full pricing ADR can be written.

---

### 1. Business Model Recommendation

#### Standalone SaaS Path (Non-ALH RCFEs)

**Pricing model: flat monthly subscription per facility. No per-resident component.**

Working price range: **$99–$199/month.** Recommended initial test price: **$149/month.**

Rationale for flat-rate over per-resident:
- Sole operators running 6–20 resident homes deal with variable census. Per-resident billing creates unpredictable monthly invoices and complicates the first sales conversation.
- Flat-rate is simpler to budget, easier to explain, and lower friction at onboarding.
- The product's value does not scale linearly with resident count at small facility sizes.

Willingness-to-pay assessment (reasoning-based; requires design partner validation):
- A California RCFE charging $3,500–$5,500/resident/month at 10–16 residents generates roughly $35,000–$88,000/month in gross revenue.
- $99–$199/month is 0.2%–0.4% of low-end revenue — small in relative terms.
- However, small care homes operate on thin margins. Operators in this profile are cost-conscious and buy tools that pay for themselves quickly.
- A paper-binder replacement that saves 2 hours of admin work per shift at California minimum wage equivalence is worth approximately $180–$240/month to the operator — above the proposed price range.
- $149/month is the recommended test price: low enough to reduce friction, high enough to be taken seriously, and leaves room to move down to $99 if resistance is strong or up to $199 once value is demonstrated.
- **Not locked.** Must be validated in design partner and early pilot conversations.

#### Partner-Bundled Path (ALH Facility Partners)

**Strategic direction: bundled with the existing ALH relationship or offered at a heavy discount alongside the ALH listing tier.**

This path is primarily about relationship depth and retention, not independent revenue. A facility using both ALH (for family leads) and alh-tracker (for shift operations) is more invested in the relationship and less likely to churn from either product.

What "bundled" means operationally:
- The commercial relationship (ALH listing partner) is the shared layer.
- Billing for alh-tracker may be a discounted add-on to the ALH invoice or included above a certain ALH tier.
- Resident care data is **not** part of what is bundled — only the commercial relationship is shared.

**Exact pricing structure: not finalized.** Options to evaluate:

| Option | Pros | Cons |
|---|---|---|
| Free for all ALH partners (early rollout) | Maximum adoption, strongest retention signal | No independent revenue; hard to re-price later |
| Included in Growth/Concierge ALH tiers only | Creates upgrade incentive | Excludes Starter partners; may feel like upsell pressure |
| Fixed discounted add-on ($49–$79/month) | Generates revenue; clear pricing | Another line item on the partner invoice |
| 50% discount off standalone rate | Scales proportionally; easy to explain | Requires locking standalone rate first |

**Recommendation before finalizing:** free during design partner and Phase 1 pilot; transition to a discounted add-on ($49–$79/month) when the ALH partner pilot cohort moves to commercial terms. Establish the early-partner rate explicitly before the first ALH facility is invited to the pilot — repricing existing partners is operationally difficult.

#### Early Design Partner Pricing

**Free during Phase 0.** No money changes hands during the design partner phase.

The design partner receives free access and early product input. In exchange, they provide shift observation access, caregiver participation in prototype testing, and honest feedback. A one-page letter of intent is sufficient — no formal contract needed at this stage.

Transition language when moving to pilot: "founding partner rate of $[X]/month" — the exact rate must be defined before the first design partner conversation concludes.

#### Explicit Pricing Assumptions

| Item | Current assumption | Status |
|---|---|---|
| Pricing model type | Flat monthly per-facility, no per-resident component | Decided |
| Non-ALH standalone price range | $99–$199/month | Working range (not locked) |
| Recommended test price | $149/month | Recommendation (not locked) |
| ALH partner pricing direction | Bundled or heavily discounted | Decided in principle |
| ALH partner exact rate/structure | Free early, then $49–$79/month add-on (recommended) | Not finalized |
| Design partner pricing | Free | Decided |

---

### 2. ALH Relationship

#### How alh-tracker Supports ALH Facility Partner Retention

ALH creates facility relationships through its family placement and lead-matching platform. alh-tracker adds an operational layer to that relationship — one about the facility's internal shift operations, not just their external listing. A facility using both products is:
- More invested in the ALH relationship (two products, not one)
- More operationally capable of responding well to family leads (better shift handoff → better lead response)
- Less likely to churn, because daily operations now run through an ALH-ecosystem product

This is the retention argument: not lock-in through friction, but genuine operational value that makes the broader relationship worth keeping.

#### How to Mention alh-tracker in ALH BD Conversations

**Approved framing:**
> "We're also building a shift log and handoff tool for RCFE operators. If you're interested in being an early design partner as we develop it, we'd love to have your input."

- Surface it as a benefit of the broader ALH relationship, not a separate product pitch.
- Mention when the facility owner expresses pain with shift handoffs, paper binders, or caregiver communication.
- Mention when building rapport around ALH's operator-support mission.
- Do **not** make it a standard pitch component before MVP exists.

#### What Must Not Be Promised Before MVP Exists

- Do not quote an alh-tracker launch date.
- Do not promise specific features, pricing, or availability windows.
- Do not imply alh-tracker is included in any ALH listing tier unless that bundle is finalized and communicated by the Product / Program Lead.
- Do not imply alh-tracker is production-ready or actively deployed.
- Do not use alh-tracker as an ALH competitive differentiator until it has shipped and is in use.

---

### 3. Data Boundary

#### What Must Remain Siloed

The following data must not flow from alh-tracker to the AssistedLivingHelp platform under any circumstance without explicit operator consent and legal review:

| Data category | Why |
|---|---|
| Resident identity (names, room numbers, care notes) | Privacy; residents did not consent to ALH data sharing |
| Shift log entries and care log records | Operational care data; no placement relevance; privacy-sensitive |
| Handoff summaries and exception reports | Care operations data; not placement-relevant |
| Observed care task records | Medication-adjacent; especially sensitive |
| Incident logs and follow-up records | Potentially reportable; highest privacy sensitivity |
| Caregiver accounts and activity logs | Internal staff data; not relevant to ALH placement workflow |

#### What IS Shared (Commercial Relationship Layer Only)

| Data | How shared |
|---|---|
| Facility identity (name, address, license number) | `Facility` entity, always present |
| ALH commercial relationship status | `alh_partner` boolean, `alh_partner_tier` field |
| Billing relationship | Account/billing management layer only |

#### What Future Cross-Product Sharing Requires

Any sharing of care data from alh-tracker into ALH requires ALL of the following — no exceptions:
1. Explicit named consent from the facility operator (owner/admin), describing exactly what data categories are shared and for what purpose.
2. Legal and compliance counsel review of the consent language and sharing scope.
3. A documented data sharing agreement reviewed by counsel.
4. A technical implementation that enforces the consent scope at the query and API level — not just policy documentation.
5. An audit trail of what was shared, when, and under what consent basis.

This is an architectural constraint, not a policy. The `alh_partner` field communicates commercial status only. No care log data should ever be reachable through an ALH-platform query path.

---

### 4. Launch and Rollout

| Phase | Name | Who | Pricing | Gate |
|---|---|---|---|---|
| **Phase 0** | Design partner | 1–3 committed CA RCFEs in Temecula/Murrieta/Menifee | Free | Site visit and shift observation completed; design partner committed |
| **Phase 1** | Early ALH partner pilot | Small cohort of existing ALH facility partners; invite only | Free or heavily discounted | Design partner findings incorporated; product stable for real shift use |
| **Phase 2** | Standalone beta | Non-ALH CA RCFEs; invite or waitlist | $99–$149/month introductory | ALH pilot feedback incorporated; product stable; support model defined |
| **Phase 3** | Commercial launch | Open to CA RCFEs | $149–$199/month standalone; discounted for ALH partners | Price point validated; support sustainable; data boundary enforced in production |

Each phase transition requires Product / Program Lead sign-off.

---

### 5. Risks and Open Questions

**Pricing validation risk:** $99–$199/month is a working range with no market data behind it. Sole operators may resist $199/month; $99/month may be insufficient to cover support costs. Design partner and pilot conversations are the earliest validation point.

**Repricing risk:** If alh-tracker is offered free or near-free to ALH partners during early rollout, transitioning to paid later is operationally difficult. Establish the founding partner rate explicitly before the first ALH pilot conversation concludes.

**Bundling complexity risk:** Including alh-tracker in specific ALH tiers (e.g., Growth and above) changes the ALH commercial value proposition and may require contract revisions for existing ALH partners. Avoid until the ALH commercial model cleanly supports it.

**Support burden risk:** A $99–$149/month product must have very low per-customer support cost. Sole operators with low tech fluency will generate support requests. Support model must be defined before Phase 3 commercial launch.

**Data boundary enforcement risk:** An inadvertent query path that exposes care data to the ALH platform causes privacy harm, regulatory exposure, and facility trust destruction. The boundary must be enforced at the architecture level — not just in policy. This must be verified before any cross-product integration is built.

**Open questions that block task closure:**

| Question | Blocks |
|---|---|
| Exact ALH partner pricing rate and structure (free? $49–$79/month? bundled in specific ALH tier?) | ADR for full business model; Phase 1 ALH pilot planning |
| Non-ALH price point validated ($149 recommended; not locked) | Phase 2 standalone beta pricing; ADR |
| Shared onboarding or billing workflow between ALH and alh-tracker? (not yet addressed) | Phase 1 technical and commercial planning |
| Support model at $99–$149/month — what is sustainable? | Phase 3 commercial launch readiness |
| What founding partner rate and duration do ALH pilot participants lock in? | Phase 1 partner communications |

---

**Remaining to close this task:**
- [ ] Non-ALH price point confirmed ($149/month is the working recommendation; requires design partner pricing sensitivity probe and early pilot validation — see task 0002 validation checklist)
- [ ] Support model at $99–$149/month defined before Phase 3 commercial launch
- [ ] What founding partner rate do ALH Phase 1 pilot participants lock in? (ADR 0003 recommends $49/month; owner must confirm before first pilot conversation)

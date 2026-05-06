# alh-tracker — AI Memory

This file stores volatile working context: open questions, temporary assumptions, and in-progress decisions.

It is meant to be updated frequently. Remove or resolve entries when they are no longer open.

For durable, finalized decisions, use `decisions\` (ADR format). For retrospective notes, use `reflection.md`.

---

## Open Questions

### Business model and ALH relationship (Task 0001)

- Is alh-tracker free for AssistedLivingHelp facility partners, discounted, or priced independently as an add-on?
- What is the standalone SaaS pricing model for non-ALH facilities? (Per-facility flat rate or per-resident-per-month?)
- Will ALH BD conversations introduce alh-tracker before or after MVP launch?
- Are there shared onboarding or billing workflows between ALH and alh-tracker?

### Design partner (Task 0002)

- Who is the first design partner? Target profile defined (see task 0002 and working context below). Committed partner not yet identified — outreach not yet executed.
- Outreach channel priority established: (1) ALH Phase 1 market contacts, (2) CDSS/CCLD Riverside County RCFE registry cold list, (3) CALCASA/local associations, (4) personal referrals. Candidate list not yet built.

### Shift model (Task 0003)

- Are shift periods fixed time windows (e.g., 7am–3pm / 3pm–11pm / 11pm–7am) or owner-configured?
- What happens if a caregiver never closes their shift? Do log entries become orphaned from the handoff?
- What triggers handoff generation — an explicit caregiver action, a scheduled time, or both?
- How are orphaned or overlapping shifts handled?

### Caregiver authentication (Task 0003)

- Individual accounts per caregiver (better audit trail, more setup friction) or shared device PIN (lower friction, weaker individual accountability)?
- Can both models coexist per facility — e.g., individual accounts for primary caregivers, shared PIN for agency or backup staff?
- How does shared tablet behavior work: persistent session, auto-lock, or per-event re-authentication?
- How are new or agency caregivers added without blocking a shift?

### Observed care task deliberateness

- Should observed care task logging require a note when status is anything other than "Done"?
- What is the right friction level to prevent accidental one-tap medication observations without making the flow feel like a form?

### Family access architecture (Task 0006)

- Which entity holds the resident-family association?
- What consent model governs family access to resident care records — who grants consent, and what is the scope?
- Does family access use the same database or a derived/filtered view?
- How does resident autonomy interact with family access (a competent resident may not want family to see all care notes)?

### HIPAA BAA posture

- Do RCFE operators using alh-tracker require a Business Associate Agreement?
- What is the vendor's HIPAA posture before commercial launch?
- This must be resolved before any real resident data is stored under a commercial relationship.

### Title 22 documentation scope (Task 0004)

- Which specific RCFE documentation requirements affect the MVP data model design and retention policy?
- Are there content, format, or timeliness requirements for incident logging or medication observation records?
- Does logging incidents in alh-tracker create any mandatory reporting obligations for the vendor?

### Retention and deletion policy

- How long are care log records retained after they are created?
- What happens to care log records when a resident is deactivated (moved out or deceased)?
- Must be defined before commercial launch.

---

## Current Working Context

<!-- Add temporary assumptions, in-progress decisions, and unresolved questions here as work progresses. Remove entries when resolved. -->

**Assumption (2026-05-05):** Commercial starting point is standalone SaaS pricing for non-ALH facilities; discounted or bundled for ALH facility partners. Not yet locked — see task 0001.

**Assumption (2026-05-05):** MVP targets California RCFEs with 6–20 residents currently using paper binders, whiteboards, or verbal handoffs. This profile was chosen as the sharpest initial wedge and closest first-fit.

**Assumption (2026-05-05):** Observed care tasks are caregiver observations only — no MAR/eMAR structure — until compliance and legal review confirms a safe, appropriate path forward.

**Assumption (2026-05-05):** Family access architecture stubs (ResidentContact, FamilyAccessConsent) are included in the data model design reference but are not built in MVP. Task 0006 must resolve the full architecture before Phase 2 implementation begins.

**Design partner strategy (2026-05-05 — task 0002 planning complete):**

- **Profile (must-have):** California RCFE, active license, 6–20 resident capacity, currently using paper/whiteboard/text/verbal handoff process, no digital shift log software, owner accessible for site visit, at least one caregiver willing to test during a real shift. Located in Temecula, Murrieta, or Menifee (SW Riverside County) — aligns with ALH Phase 1 markets.
- **Profile (disqualifiers):** Already using PointClickCare, MatrixCare, or similar; under active CDSS license action; fewer than 4 active residents; outside California; owner unwilling to allow caregiver participation.
- **Outreach channel priority:** (1) ALH Phase 1 facility contacts — warmest path; (2) CDSS/CCLD Riverside County RCFE registry filtered to capacity 6–20 — cold list; (3) CALCASA/local RCFE networks — lower-certainty; (4) personal referrals if Channels 1–2 stall after 4–6 weeks.
- **Candidate list:** Not yet built. Owner must pull ALH contact list and ca_ccld_registry Riverside County RCFE data, apply filters, and build 5–10 candidate list. Target 30–50 cold contacts to yield 1 committed partner.
- **LOI terms:** Free access during design partner phase; no pricing commitment in the LOI; founding partner rate to be communicated before design partner relationship concludes. No compliance claims. No production dependency. 30-day exit by either party.
- **Outreach script and site visit plan:** Documented in task 0002 Sections 3 and 4. Do not deviate from the language guardrails — no launch date, no pricing, no compliance language.
- **Validation gate for Task 0003:** Shift model and auth questions from the task 0002 validation checklist must have answers from a real facility before task 0003 is activated.

**Working direction (2026-05-05 — tasks 0001, 0002, 0004 activated):**

- **Business model:** alh-tracker is positioned primarily as a stickiness tool for ALH facility relationships, not a standalone SaaS-first business. ALH facility partners: bundled or heavily discounted during early rollout. Non-ALH RCFEs: flat monthly rate in the $99–$199/month working range. Per-resident pricing explicitly deferred — adds complexity at onboarding and harder to justify for sole-operator homes. Refines commercial assumption above dated 2026-05-05.
- **BD timing:** alh-tracker may be introduced in ALH BD conversations now as a "coming soon / design partner invitation" signal only — not a finished-product promise.
- **Design partner target:** California RCFE, 6–20 residents, paper/whiteboard/text/verbal handoff workflow, owner accessible, at least one active caregiver willing to test phone/tablet during a real shift. Preferred geography: Temecula, Murrieta, Menifee, or nearby Inland Empire/Southwest Riverside County. Refines MVP target assumption above dated 2026-05-05.
- **Caregiver auth starting instinct:** Named individual accounts for regular caregivers (audit-sensitive actions require traceable identity). Shared tablet mode with quick per-session PIN switch for shared-device facilities. Not finalized — design partner site visit (task 0002) must validate before task 0003 locks the model.
- **Title 22 research posture:** Desk research begins as preliminary work for counsel review. Output is labeled preliminary research only — not legal advice. Language hard-stops confirmed: no compliance claims, no MAR/eMAR claims, no clinical monitoring claims, no medication safety claims, no legal sufficiency claims.

**Task 0001 in-progress state (2026-05-05):**

- **Decided (firm):** Pricing model type is flat monthly per-facility — no per-resident component. Data boundary is a non-negotiable architectural constraint: resident care data does not cross into the ALH platform without explicit operator consent and legal review. BD timing confirmed: design partner invitation only before MVP ships.
- **Decided (direction, rate not locked):** ALH partners receive bundled or heavily discounted access; direction is free during design partner and early pilot phases, then $49–$79/month add-on. Non-ALH standalone working range is $99–$199/month; recommended test price is $149/month.
- **Still open (blocks task closure):** Exact ALH partner pricing rate and structure not finalized. Non-ALH price point not validated. Shared onboarding/billing workflow between ALH and alh-tracker not yet addressed. Support model at $99–$149/month not defined.
- **ADRs created:** `decisions/0001-data-boundary-alh-tracker-vs-alh.md` (accepted), `decisions/0002-pricing-model-type.md` (accepted). Full pricing ADR (`0003-business-model-alh-pricing.md`) to be written when rate finalization is complete.

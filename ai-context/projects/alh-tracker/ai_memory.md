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

- Who is the first design partner? Target profile: California RCFE, 6–20 residents, currently using paper binders or verbal handoffs, willing to allow shift observation and prototype testing.
- Which outreach channel is most likely to yield a committed design partner? (ALH Phase 1 market contacts, RCFE associations, cold outreach?)

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

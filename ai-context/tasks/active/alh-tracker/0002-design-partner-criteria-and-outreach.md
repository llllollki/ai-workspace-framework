# Task 0002 — Design Partner Criteria and Outreach

**Project:** alh-tracker
**Status:** active
**Created:** 2026-05-05
**Owner role:** Product / Program Lead
**Reviewers:** Operations / Concierge Workflow Lead

---

## Goal

Define the ideal first design partner profile and execute an outreach plan to find and engage them before any application development begins.

A design partner is a real California RCFE that will:
- Allow observation of real shift workflows
- Test a prototype or early version during a real shift
- Provide honest feedback before the product is complete

---

## Acceptance Criteria

1. A documented design partner criteria brief: facility size, care type, workflow characteristics, location, and engagement expectations.
2. An outreach plan: channels to use, messaging approach, and a list of 5–10 candidate facilities.
3. At least one committed design partner identified before Phase 1 implementation begins.
4. A documented agreement covering: scope of engagement, data handling, confidentiality, and what the facility receives in exchange (e.g., free access during development, early partnership pricing).
5. A shift workflow observation summary: what does the current paper/verbal process look like? What is the biggest handoff pain point?

---

## Plan

- [x] Write design partner criteria brief: CA RCFE licensed, 6–20 residents preferred, current workflow uses paper/verbal/whiteboard, willing to allow a site visit and shift observation
- [x] Identify outreach channels:
  - ALH Phase 1 market facility contacts (Temecula / Murrieta / Menifee area — aligned with ALH commercial territory)
  - RCFE owner associations in California (e.g., CALCASA, RCFE operators groups)
  - Cold outreach to facilities identified in the ALH `ca_ccld_registry` data set
- [x] Draft outreach script — this is a product collaboration ask, not a listing sales pitch; tone and framing differ from ALH BD outreach
- [ ] Identify 5–10 candidate facilities (strategy defined below; candidate list requires owner data access and execution — see Section 2)
- [ ] Conduct outreach and schedule at least one site visit
- [ ] Observe a real shift: what does the paper binder contain? How long does handoff take? What do caregivers complain about most?
- [ ] Confirm commitment from at least one design partner
- [ ] Document design partner identity in `ai_memory.md` (when confirmed — limit PII to what is needed for context)

---

## Notes

- The design partner should ideally be in one of the ALH Phase 1 launch markets (Temecula, Murrieta, Menifee, Inland Valley). This creates commercial alignment with the broader ALH strategy.
- Both the owner AND at least one active caregiver should be accessible through the design partner relationship. The buyer and daily user personas have different needs; both must be represented.
- Observing one real shift before building anything is more valuable than ten post-hoc user interviews.
- The design partner agreement should be simple. Focus on trust and mutual benefit, not legal formality. A one-page letter of intent is enough for now.
- Float caregiver or agency staff are common in small RCFEs. Ask the owner how they handle shift coverage gaps — this will inform the caregiver authentication model (task 0003).

---

## Planning Notes

**Activated 2026-05-05.** Target profile and channel priority confirmed at task activation:

- **Target facility profile:** California RCFE, 6–20 residents, currently operating with paper binders, whiteboards, text chains, or verbal handoffs. Not currently using any digital shift log or care management software. Sole-operator or small team strongly preferred for Phase 0 — simpler workflow to observe, faster to build trust with.
- **Geography priority:** Temecula, Murrieta, or Menifee first; nearby Inland Empire / Southwest Riverside County acceptable. Alignment with ALH Phase 1 markets creates commercial synergy and a potential warm introduction path via ALH facility contacts.
- **Engagement requirements:** Owner or operator accessible and willing to allow a site visit and at least one observed shift. At least one active caregiver willing to test a phone or tablet logging flow during a real shift — not a simulated walkthrough. Both owner and caregiver personas must be represented.
- **ALH BD channel:** The "coming soon / design partner invitation" framing from task 0001 may surface candidate facilities through ALH Phase 1 facility contacts. Route promising contacts through the design partner brief framing — not the ALH listing pitch.
- **Critical dependency forward:** This task must deliver at least one committed design partner and one completed shift observation before task 0003 (shift model and caregiver authentication) is activated. Task 0003 is explicitly blocked on real facility input from this task.

---

## Outcome

> **Status: planning complete — task not yet closed.** Sections 1–7 below document the complete design partner strategy, criteria brief, outreach approach, site visit plan, LOI outline, and validation checklist. Criteria 1 and 2 are satisfied by this document. Criteria 3, 4, and 5 require real-world execution: outreach, a committed partner, and a site visit. Task remains active until all five criteria are met.

---

### 1. Design Partner Profile

#### Must-Have Criteria

| Criterion | Why it matters |
|---|---|
| California RCFE license, active and in good standing | Regulated operating environment is the product's target; in-good-standing ensures the facility is a realistic partner, not one distracted by compliance issues |
| 6–20 licensed resident capacity | Primary MVP target segment; small enough that the owner is accessible and the workflow is simple enough to observe meaningfully |
| Currently using a paper-based or analog handoff process | Paper binder, whiteboard, text chain, verbal handoff, or spreadsheet — at least one analog step in the shift handoff flow. This is the pain point alh-tracker solves; partners already using digital software are wrong-profile |
| Owner or operator accessible and willing to allow a site visit | The buyer persona must be reachable and open to product collaboration — not just willing to take a phone call |
| At least one active caregiver willing to participate | The daily user persona is required. The caregiver must be willing to try logging on a phone or tablet during a real shift — not a post-hoc interview and not a simulation |
| Located in Temecula, Murrieta, Menifee, or nearby Inland Empire / SW Riverside County | Alignment with ALH Phase 1 markets enables warm introductions and commercial synergy; proximity also makes an in-person site visit practical |
| No current digital shift log or care management software subscription | Avoids "switching cost" conversations at Phase 0. Partner should be paper-first today |

#### Nice-to-Have Criteria

| Criterion | Why it helps |
|---|---|
| Sole-operator or owner-operator who works shifts directly | Owner-as-caregiver eliminates the gap between buyer and user; richer insight per conversation |
| Facility has experienced a regulatory inspection in the last 2 years | Owner will have a concrete sense of what documentation gaps feel like under scrutiny — directly relevant to product value |
| Staff includes one caregiver who is comfortable with their phone | Reduces device onboarding friction during prototype testing; does not need to be tech-savvy, just not resistant |
| Willingness to allow an in-person shift observation | Observing a live shift handoff is the single highest-value discovery activity. Remote interview is a fallback; real shift is preferred |
| Already an ALH facility partner (Starter or Growth) | Enables an easier introduction via the existing ALH relationship and aligns with the business model goal of deepening ALH partner stickiness |
| 10–16 residents | Large enough that caregivers have real multi-resident logging volume; small enough that the owner knows all residents and can describe their care context |
| California RCFE in operation for 3+ years | Established enough that the workflow is stable and observable; not still improvising their first-year operations |

#### Disqualifiers

| Criterion | Why it disqualifies |
|---|---|
| Currently using PointClickCare, MatrixCare, or similar care management software | Wrong-fit: already past the paper-binder stage. Product switching at Phase 0 is a distraction for both parties |
| Under active CDSS investigation or license action | Owner's attention will be consumed by compliance response; not a stable design partner environment |
| Fewer than 4 active residents | Too small to generate meaningful multi-resident logging volume for prototype validation |
| Located outside California | California-specific regulatory context is central to product design; out-of-state partner cannot validate Title 22-adjacent concerns |
| Owner unwilling to allow caregiver participation | Without daily user access, the core logging UX cannot be validated; half-profile partner |
| Owner expects a finished product during Phase 0 | Design partner is a collaboration, not a product delivery. Partners expecting software that runs their facility on day one are misaligned |
| Facility primarily serving non-elderly populations | RCFE designation is required; adult residential facilities or ARF licensees are out-of-scope for MVP |

---

### 2. Outreach Target List Strategy

#### Channel Priority

**Channel 1 — Warm: ALH Phase 1 Market Contacts (Start here)**

ALH has active or prospective facility partner relationships in Temecula, Murrieta, and Menifee. These contacts are the lowest-friction entry point:

- When an ALH BD conversation surfaces an owner who mentions paper binders, handoff friction, or caregiver documentation — route that conversation toward a design partner inquiry. Use the approved BD framing from task 0001: "We're also building a shift log and handoff tool for RCFE operators. If you're interested in being an early design partner as we develop it, we'd love to have your input."
- Review any existing ALH facility partner list for Temecula/Murrieta/Menifee. Filter for RCFE license type, capacity in the 6–20 range. These are the warmest candidates.
- Do not pitch alh-tracker as a finished product or imply it is included in any ALH tier without explicit approval.

**Channel 2 — Registry: CDSS / CCLD Public RCFE Database**

The California CDSS Community Care Licensing Division (CCLD) maintains a public database of all licensed RCFEs. This data is searchable and filterable by:

- License type: Residential Care Facility for the Elderly (RCFE)
- County: Riverside (covers Temecula/Murrieta/Menifee)
- Capacity: filter for 6–20
- License status: active and in good standing

From the ca_ccld_registry (referenced in ALH context), pull Riverside County RCFEs in the 6–20 capacity range. This is the cold outreach list. Expected list size: 30–80 facilities depending on census cutoffs. Prioritize by proximity to the preferred cities.

**Channel 3 — Association: CALCASA and Local RCFE Operator Networks**

The California Assisted Living Association (CALCASA) represents RCFE operators and adult residential care providers. Local RCFE owner groups also exist in some counties. These channels are lower-certainty for Phase 0 but can surface committed partners who self-identify as open to new tools.

- Avoid making a broad public announcement about alh-tracker via these channels at Phase 0. The product does not exist yet. Approach individual contacts through association introductions, not mass outreach.

**Channel 4 — Referral: Existing Owner Relationships**

If any ALH staff, advisors, or network contacts personally know RCFE owners in the preferred geography, a direct personal introduction is higher-trust than any cold channel. Activate this channel if Channels 1 and 2 do not yield a committed partner in 4–6 weeks.

#### Candidate List Execution

The owner must build the actual 5–10 candidate list by:

1. Pull the ALH facility partner list (or prospective contact list) filtered to: RCFE, Temecula/Murrieta/Menifee geography, capacity 6–20.
2. Pull Riverside County RCFE records from ca_ccld_registry: capacity 6–20, active license.
3. Cross-reference: ALH contacts first (warm), then registry-only facilities (cold).
4. Apply disqualifiers to remove known PointClickCare/MatrixCare users and any facilities with active license actions.
5. Rank by: (a) existing ALH relationship, (b) proximity to preferred cities, (c) estimated capacity in the 10–16 range (higher logging volume).
6. Target 5–10 candidates for initial outreach, expecting 1–3 positive responses and 1 committed partner.

---

### 3. Outreach Script and Message

These are intended for direct owner-to-owner or warm-introduction outreach. The tone is collaborative and honest — this is a product collaboration ask, not a listing sales pitch.

#### Email / Text Message — Warm Introduction (ALH Relationship Known)

> Subject: Quick question — shift handoff tool collaboration
>
> Hi [Owner Name],
>
> I'm [Name] with AssistedLivingHelp. We've been talking about supporting RCFE operators in the Temecula/Murrieta area with more than just family placement — and one of those areas is the daily operations side.
>
> We're early in building a simple shift log and handoff tool specifically for small RCFE operators like yours. Right now it's in the design stage — no product exists yet. We're looking for one or two facilities willing to share how their current process actually works and give us feedback as we build.
>
> This would involve:
> - A short visit so I can see how a shift handoff works at your facility
> - Conversation with you and one of your caregivers about what's working and what isn't
> - Optionally, testing an early prototype during a real shift later on
>
> There's no cost — this is a design collaboration, not a product launch. You'd get early access and direct input into what we build.
>
> Is this something you'd be open to talking about? Happy to work around your schedule.
>
> [Name]

#### Cold Outreach — Phone Opener (Registry List)

> "Hi, this is [Name]. I'm reaching out because we're building a simple shift log and handoff tool for small RCFE operators in the Temecula and Murrieta area, and we're looking for one or two facilities to collaborate with us in the design phase — before we build anything. It's not a product pitch. We want to learn how your current shift process works and get feedback as we develop this. Would you be open to a short conversation?"

#### Follow-Up Message — After Initial Interest

> "Thanks for your time. To be clear about what this involves: there's no software to install yet, no cost, and no commitment beyond a short visit and honest feedback. In exchange, you'd get early access to whatever we build and direct input into the features. I'll send you a one-page summary of what we're asking for — take a look and let me know if you want to move forward."

#### What NOT to Say in Any Outreach

- Do not name a launch date or an availability window.
- Do not say the product is "ready," "available," or "coming soon" — it is in the design stage.
- Do not promise specific features, RCFE compliance support, Title 22 documentation, or medication records.
- Do not reference any pricing until a commitment is reached and the design partner LOI is signed.
- Do not use the word "free" without the context of "design partner phase" — it can imply the product will eventually be free.
- Do not imply this replaces any required CDSS documentation.

---

### 4. Site Visit and Discovery Plan

The site visit is the single most valuable activity in Phase 0. Everything designed afterward should be anchored to what was observed in a real facility.

#### Objectives

- Observe the shift handoff process as it actually happens, not as described.
- Understand the structure and contents of the paper binder or analog equivalent.
- Identify the biggest caregiver pain points in the handoff process.
- Understand device availability and usage habits.
- Begin validating shift model and caregiver auth assumptions (inputs to task 0003).
- Begin validating pricing sensitivity (input to finalizing task 0001).

#### What to Observe

| Observation area | What to look for |
|---|---|
| Handoff process | How does the outgoing caregiver communicate with the incoming caregiver? Is there a written summary? Verbal walkthrough? Both? How long does it take? |
| Paper binder or log | What is in it? How is it organized? Is it by resident, by date, by category? Are entries dated and signed? |
| Exceptions and incidents | How are missed care events, refusals, or incidents documented? Is there a separate incident log? |
| Medication observation | How are medication tasks documented during a shift? Is there a separate log? How specific is the documentation? |
| Caregiver device usage | Do caregivers use phones during shifts? For what? Do they text the owner? Use any apps? |
| Shared tablet or device | Is there a shared tablet or device on-site? Who uses it and for what? |
| Time pressure | How busy does the handoff shift period feel? How long do caregivers have to complete documentation? |
| Owner review | Does the owner review the paper binder? How often? What do they look for? |
| Float/agency staff | How common are agency or float caregivers? How are they onboarded to the current process? |

#### Who to Interview

**Owner/operator interview (30–45 minutes):**
- How do you currently run shift handoffs? Walk me through the last handoff you witnessed.
- What's in your paper binder? Can I see a recent page? (request to see — do not photograph or collect)
- What's the hardest part of managing shift documentation?
- When something goes wrong (incident, missed care event), how is it documented and communicated?
- Do you review the log every day? What do you look for?
- If you could fix one thing about your current handoff process, what would it be?
- What devices do your caregivers use on shift?
- How do you handle float or agency staff — do they follow the same documentation process?
- What does your current software spend look like for this facility? (pricing sensitivity probe — do not lead with a number)

**Caregiver interview (15–20 minutes, during or after a shift):**
- Walk me through how you document a shift event. What do you write down?
- What's the most annoying part of the current handoff process?
- Do you use your phone for anything work-related during shifts?
- If someone handed you a phone during your shift and said "log this meal," what would feel natural vs. awkward?
- When the next caregiver comes on, what do you tell them that isn't written down?

#### What to Observe But Not Collect

- The contents of the paper binder are observable (ask to see a recent page) — do not photograph, scan, or copy any pages that include resident names, care notes, or medical information.
- Do not record video of caregivers or residents.
- Do not write down resident names, room numbers, or individual care observations.
- Do not collect any documents — only look at the structure and content categories.
- Do not ask for, or accept, any copies of resident records.

#### What to Capture in Your Notes

- Structural observations: how many pages does the binder have, how is it organized, what categories appear, how entries are dated/signed.
- Time observations: how long did the handoff take, what was the most time-consuming part.
- Pain point quotes: verbatim caregiver or owner statements about what frustrates them.
- Device observations: what devices were visible, what was used during the shift period.
- Workflow gaps: things that clearly should be documented but weren't, or that were documented inconsistently.

---

### 5. Design Partner Letter of Intent (LOI) Outline

The LOI should be one page. Its purpose is to establish mutual expectations and build trust — not to create binding legal obligations. Plain language is preferred. If the owner asks for legal review before signing, that is reasonable and should be accommodated.

**Section 1 — Purpose**
> This letter confirms [Facility Name]'s agreement to participate as a design partner for alh-tracker, a shift log and handoff tool currently in development for small California RCFE operators. The purpose of this engagement is to gather feedback from a real operating facility to inform product design — not to deploy production software.

**Section 2 — What the Facility Provides**
> [Facility Name] agrees to:
> - Allow one or more site visits for the purpose of observing shift workflow and handoff processes
> - Make the owner/operator available for a structured discovery conversation (approximately 45–60 minutes)
> - Allow at least one active caregiver to participate in a feedback session or prototype test during a real shift
> - Provide honest feedback on product concepts, prototype flows, and design decisions
> - Notify [Product Name] of any concerns about the engagement at any point

**Section 3 — What the Facility Receives**
> In exchange, [Product/Company Name] provides:
> - Free access to the alh-tracker prototype or early product during the design partner phase (no charges will be applied during this period)
> - Direct input into product design decisions
> - Preferred consideration as an early access partner when the product moves to general availability
> - A founding partner rate to be communicated before any commercial relationship begins (not established in this letter)

**Section 4 — Data Handling**
> During site visits, no resident names, individual care records, or personally identifiable resident information will be collected or retained. Observations are limited to workflow structure and process patterns. Any data collected during prototype testing is handled with the same privacy protections planned for the production product and is not shared with any third party, including AssistedLivingHelp.

**Section 5 — Compliance Boundary**
> alh-tracker is a care observation and shift log tool in development. It is not a compliance system, a medication administration record (MAR), a clinical documentation system, or an official regulatory record. Participation in the design partner phase does not satisfy any CDSS documentation, incident reporting, or medication management requirements. [Facility Name] remains responsible for all required regulatory documentation during and after this engagement.

**Section 6 — No Production Dependency**
> [Facility Name] will not rely on any prototype or early version of alh-tracker for required shift documentation or regulatory record-keeping during the design partner phase. The product is in development and should be treated as supplemental or experimental only.

**Section 7 — Confidentiality**
> Both parties agree to keep the details of this engagement confidential. [Product/Company Name] will not reference [Facility Name] by name in any public communications without explicit written consent.

**Section 8 — Duration and Termination**
> This engagement begins on [Date] and continues until the product moves to a Phase 1 pilot or early access stage, or until either party provides 30 days written notice of withdrawal. No penalty applies to withdrawal by either party.

---

### 6. Validation Checklist

This checklist defines what must be learned from the design partner engagement before downstream tasks can proceed.

#### What must be learned before activating Task 0003 (shift model and caregiver auth)

| Question | Why it blocks task 0003 |
|---|---|
| Are shift periods fixed time windows or owner-configured? | Core data model assumption in Shift entity; determines whether the product needs a shift configuration UI |
| What triggers the handoff — an explicit caregiver action, a scheduled time, or both? | Determines handoff generation flow design |
| What happens if a caregiver ends their shift without closing it? | Determines orphaned shift handling rules |
| How do overlapping shifts work (e.g., two caregivers covering for a period)? | Determines shift model edge cases |
| Individual caregiver accounts or shared device PIN — what does the owner prefer? | Core auth model decision; affects audit trail design and onboarding |
| How does the facility handle float/agency staff — same process or different? | Determines whether shared PIN is needed alongside individual accounts |
| What devices do caregivers use during shifts? Phone, shared tablet, or both? | Determines priority device profile and offline tolerance requirements |
| Is there a shared tablet on-site, and who controls access to it? | Determines shared device session model requirements |

**Task 0003 cannot be activated until at least questions 1, 5, and 7 have clear answers from at least one real facility.**

#### What must be learned before finalizing Task 0001 pricing

| Question | Why it matters |
|---|---|
| What does the owner currently spend on software for this facility? | Establishes the price anchor; reveals competitive context |
| What would the owner pay today for a product that reliably replaces their paper binder? | Direct willingness-to-pay probe; validates the $99–$149/month working range |
| Does $149/month feel accessible, expensive, or cheap relative to the owner's other costs? | Calibrates price sensitivity without anchoring the conversation with a number |
| Is this facility already an ALH partner? | Determines which pricing path applies (bundled vs. standalone) |
| What would make the owner refuse to adopt software for this process? | Surfaces adoption blockers beyond price |

---

### 7. Risks and Open Questions

#### Cold Outreach Risk

The registry-based outreach list (Channel 2) will have a low response rate. Most small RCFE operators are time-poor and receive solicitation regularly. Expect 5–10% response rates on cold outreach and plan for 30–50 contacts to yield 3–5 responses. Mitigation: lead with warm channels first. Do not send mass outreach — personalized one-at-a-time messages will perform significantly better.

#### Privacy and Trust Risk

Requesting access to a facility's shift handoff process asks the owner to allow a relative stranger to observe care operations. Some owners will be uncomfortable with this, even for a product they are interested in. Mitigation: the LOI must make data handling clear before the site visit. Never show up unannounced. Give the owner maximum control over the visit format and timing.

#### Staff Adoption Risk at Prototype Stage

A caregiver who feels pressured to test unfamiliar technology during a real shift will generate negative signal — resistance that may reflect the test setup rather than the product. Mitigation: prototype testing should be invited, not mandated. If the caregiver declines to participate, observe without asking them to test. Participation must be genuinely optional. Capture the reluctance itself as a data point about change resistance.

#### Owner Time Constraint Risk

Small RCFE operators are often their own caregivers for at least part of the day. A 45-minute structured interview is a significant ask. Mitigation: offer flexible scheduling (early morning, during a slower shift period, after the night caregiver arrives). Be willing to conduct the interview across two shorter sessions. Prepare a condensed 20-minute version of the discovery questions as a fallback.

#### Site Observation Permission Risk

The owner may be willing to talk but uncomfortable allowing observation of a live shift with residents present. Mitigation: offer structured alternatives in this order: (1) observe the handoff transition only (5–10 minutes before and after caregiver changeover), not a full shift; (2) conduct a walk-through of the paper binder without observing residents; (3) describe the process over a recorded call if in-person access is declined. Any of these alternatives is sufficient to generate useful input — in-person shift observation is preferred but not required to advance task 0003.

#### Repricing Risk at LOI Stage

The LOI explicitly defers the founding partner rate to a future communication. If the design partner phase extends beyond 3–4 months without locking a rate, the transition to commercial terms becomes harder to negotiate. Mitigation: establish the founding partner rate no later than the point when the design partner says "I want this when it's ready." The rate must be confirmed before the design partner relationship concludes — not left open indefinitely.

#### Open Questions That Block Task Closure

| Question | Blocks |
|---|---|
| Who is the first committed design partner? (name/city/size) | Acceptance Criterion 3 |
| Has the LOI been signed? | Acceptance Criterion 4 |
| Has at least one shift been observed and documented? | Acceptance Criterion 5 |
| Has the 5–10 candidate list been built and initial outreach sent? | Candidate list execution (Section 2) |

---

**Remaining to close this task:**
- [ ] Build and send 5–10 candidate outreach list (owner execution required)
- [ ] Receive at least one positive response and schedule a site visit
- [ ] Conduct site visit and document observations
- [ ] Confirm at least one design partner commitment
- [ ] Obtain signed LOI (or equivalent written agreement)
- [ ] Write shift workflow observation summary (post-visit)
- [ ] Document confirmed design partner in `ai_memory.md` (first name / city / capacity only — no resident data)
- [ ] Consider activating Task 0003 once shift model and auth questions are answered from site visit

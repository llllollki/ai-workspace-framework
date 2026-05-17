# alh-tracker — Phase 0 Owner Action Packet

**Prepared:** 2026-05-09
**Audience:** Product / Program Lead
**Purpose:** Consolidates what Phase 0 has produced, what is still needed, and exactly what to do next — in priority order.

This document does not replace the task files. It is a navigation and execution guide. When you need the full detail on any item, follow the reference link to the source file.

---

## Section 1 — Current Status Snapshot

### What is complete

These decisions and specs are done. No further owner action is needed before Phase 1 — they are ready to act on or hand off.

| Item | Status | Source |
|---|---|---|
| Data boundary: resident care data must never flow to ALH | Decided — ADR 0001 | `decisions/0001-data-boundary-alh-tracker-vs-alh.md` |
| Pricing model type: flat monthly per-facility, no per-resident component | Decided — ADR 0002 | `decisions/0002-pricing-model-type.md` |
| ALH partner pricing: free during design partner + Phase 1 pilot, $49/month at commercial transition | Recommended — ADR 0003 | `decisions/0003-business-model-alh-pricing.md` |
| Shared onboarding/billing: no shared system between ALH and alh-tracker at MVP | Decided — ADR 0003 | Same |
| BD timing: "design partner invitation" framing only before MVP ships | Decided | Task 0001 |
| Family access architecture: read-only, dual-authorization, summary-default, deferred from MVP | Decided — ADR 0004 | `decisions/0004-family-access-architecture.md` |
| Title 22 desk research (§ 87506, 87211, 87465, 87411) | Research complete — awaiting counsel | Task 0004 Outcome |
| Counsel handoff packet | Written — ready to route | `0004-counsel-handoff-packet.md` |
| Design partner profile, outreach scripts, LOI outline, site visit plan | Written | Task 0002 Outcome |
| Device / offline behavior spec (PWA, IndexedDB queue, conflict resolution) | Written — awaiting TA review | Task 0008 Outcome |
| Family access data model stubs (ResidentContact, FamilyAccessConsent) | Finalized in schema | `data_model.md` |

### What is active

These tasks are in progress. Each has a specific action needed to advance.

| Task | Where it stands | What unblocks it |
|---|---|---|
| 0001 — Business model | Nearly closable; 3 ADRs accepted | Owner confirms $49/month ALH founding rate |
| 0002 — Design partner outreach | Strategy and scripts ready; no outreach sent | Owner builds candidate list and starts outreach |
| 0004 — Title 22 review | Counsel packet prepared; not yet routed | Owner routes packet to counsel |
| 0006 — Family access | Architecture decided; Phase 2 gate pending | Counsel review before Phase 2 builds |
| 0008 — Device / offline | Spec written; not yet confirmed | Technical Architect confirms spec in architecture |

### What is blocked

These items cannot proceed without a named prerequisite. Do not attempt to advance them ahead of the listed gate.

| Blocked item | Gate that must clear first |
|---|---|
| Task 0003 — Shift model and caregiver auth | Design partner site visit: answers to shift period, auth model, and device questions |
| Task 0005 — MVP data model finalization | Counsel answers to Priority 1 retention and account closure questions |
| Task 0007 — Logging UX and prototype | Design partner committed and task 0003 activated |
| Non-ALH standalone price locked ($149/month is working range only) | Design partner pricing sensitivity probe |
| Phase 2 family portal | Counsel review of task 0006 consent model |
| Commercial launch readiness | All Priority 1 counsel questions answered; ToS reviewed; HIPAA BAA posture confirmed |
| Real resident care data stored under any commercial relationship | Same as commercial launch readiness |

### What should not start yet

- **No application code.** No tech stack selection, no infrastructure, no database schema implementation.
- **No family portal or family-facing feature work.**
- **No MAR/eMAR or medication administration record features.**
- Task 0003 — blocked on design partner site visit.
- Task 0005 — blocked on counsel answers.
- Task 0007 — blocked on design partner commitment and task 0003.

---

## Section 2 — Owner Action Checklist

Ordered by leverage. Higher items unblock more downstream work.

---

### Action 1 — Build the design partner candidate list

**Owner:** Product / Program Lead
**Time:** 2–4 hours
**Why first:** Nothing in Phase 1 starts without a committed design partner. Tasks 0003, 0007, price validation, and WiFi assumptions all gate on a real site visit. This is the highest-leverage unblocked action available.
**How:** See Section 3A (Candidate List) below.

- [ ] Open `projects/alh-tracker/design_partner_tracker.md` — the working candidate tracker, pre-seeded with 36+ cold-list candidates from public directories
- [ ] Populate Section A (warm contacts) from ALH CRM: RCFE, Temecula/Murrieta/Menifee, capacity 6–20
- [ ] Verify CCLD license status and capacity for all Section B/C rows at https://www.ccld.dss.ca.gov/carefacilitysearch/
- [ ] Apply disqualifiers, score, and rank to identify 5–10 candidates for outreach

---

### Action 2 — Start warm outreach immediately

**Owner:** Product / Program Lead
**Time:** 30 minutes per contact
**Why second:** Warm outreach (ALH contacts you already know) has 5–10× the response rate of cold outreach. Start here before touching the registry list.
**Approved script:**
> "We're also building a shift log and handoff tool for RCFE operators. If you're interested in being an early design partner as we develop it, we'd love to have your input."

**Hard stops in any outreach:**
- Do not name a launch date
- Do not quote any pricing
- Do not promise specific features or compliance support
- Do not imply the product exists yet ("design stage" is accurate and correct)

**How:** See Section 3B (Outreach Sequence) below.

- [ ] First outreach sent to at least one warm ALH contact
- [ ] Outreach status tracker started (see Section 3B)

---

### Action 3 — Route the counsel packet

**Owner:** Product / Program Lead (routes); Compliance / Privacy Counsel (answers)
**Time:** 30 minutes to assemble and send
**Why third:** Priority 1 counsel questions block commercial launch and task 0005. These cannot be answered by desk research. Routing now means getting answers sooner, which keeps Phase 1 planning moving.
**How:** See Section 4 (Counsel Routing Checklist) below.

- [ ] Assemble the document package (Section 4A)
- [ ] Send to California compliance/privacy counsel with the specific ask (Section 4B)
- [ ] Note the date routed in task 0004 plan checklist

---

### Action 4 — Confirm the $49/month ALH founding partner rate

**Owner:** Product / Program Lead (business decision — no market validation required)
**Time:** Under 5 minutes once decided
**Why now:** ADR 0003 records $49/month as the recommended founding partner rate. This rate must be confirmed before any ALH pilot conversation concludes. Repricing existing partners after the fact is operationally hard. The BD team cannot promise a rate that has not been confirmed.
**Decision needed:** Confirm $49/month or record a different number. Update ADR 0003 if changed.

- [ ] Owner confirms $49/month ALH founding partner rate (or revises and updates ADR 0003)
- [ ] BD team briefed: they may use "founding partner rate to be confirmed" language in current outreach; they must not quote a number until this is locked

---

### Action 5 — Schedule Technical Architect review of the offline spec

**Owner:** Product / Program Lead (notifies Technical Architect)
**Time:** 1 hour review for the TA; 10 minutes to schedule
**Why:** Task 0008 offline behavior spec is complete but one acceptance criterion is open: the TA must confirm the spec is reflected in Phase 1 architecture before implementation begins. This is not blocking right now, but it needs to be done before Phase 1 kickoff.
**What to review:** `tasks/active/alh-tracker/0008-device-and-offline-behavior.md` — IndexedDB queue design, conflict resolution policy (flag for review, no auto-discard), no Background Sync API dependency, minimum browser/OS requirements. The file includes an **AI-Assisted Technical Review Note** (added 2026-05-10) that found no blocking issues and added 4 implementation notes (service worker registration order, IndexedDB schema versioning, stale-while-revalidate cache behavior, 200-entry queue capacity edge case). The TA should confirm or challenge those findings. **The AI review does not satisfy acceptance criterion 6 — human TA written confirmation is required.**

- [ ] TA review of task 0008 scheduled
- [ ] TA written confirmation received (or objections/changes noted)

---

## Section 3 — Design Partner Execution Worksheet

### 3A — Building the Candidate List

#### Step 1 — Pull ALH facility contacts (warm list — do this first)

1. Open the AssistedLivingHelp facility partner contact list or CRM.
2. Filter: RCFE license type, Temecula / Murrieta / Menifee / SW Riverside County.
3. Record for each match: facility name, owner name, contact method, approximate capacity, current ALH tier (Starter/Growth/Concierge).
4. Exclude: facilities known to use PointClickCare, MatrixCare, or any digital care management software.
5. Label each: "ALH partner — Warm."

#### Step 2 — Pull CCLD public registry (cold list)

1. Go to: **https://www.ccld.dss.ca.gov/carefacilitysearch/**
2. Search parameters: Facility type = RCFE; County = Riverside; License status = Licensed (active).
3. Export or copy results to spreadsheet.
4. Filter for capacity 6–20. (Apply in spreadsheet if the search tool does not support it.)
5. Sort by city: Temecula, Murrieta, Menifee first; then other SW Riverside County cities.
6. Cross-reference with ALH contact list. Mark any overlap as "ALH partner — Warm."

#### Step 3 — Score and rank all candidates

**Working file:** `projects/alh-tracker/design_partner_tracker.md` — use this as your live tracker. Section B (Temecula, Murrieta, Menifee) and Section C (adjacent geography) are pre-seeded with public directory data. Populate Section A (warm contacts) and verify all CCLD columns before outreach.

Tracker columns (already set up in the file):

| Facility name | City | Capacity | ALH relationship | Owner contact | Disqualifiers | Priority score |
|---|---|---|---|---|---|---|
| | | | Warm / Cold | Phone or email | Notes | 1–4 |

**Priority scoring rules (assign 1 = highest priority):**

| Score | Criteria |
|---|---|
| 1 | Existing ALH partner, Temecula/Murrieta/Menifee, capacity 10–16 |
| 2 | Existing ALH partner, preferred geography, capacity outside 10–16; OR registry-only, preferred geography, capacity 10–16 |
| 3 | Registry-only, preferred geography, capacity 6–9 or 17–20 |
| 4 | Any facility in adjacent SW Riverside County city (Hemet, Lake Elsinore, Wildomar, Canyon Lake) |

**Disqualifiers — remove before ranking:**
- Known PointClickCare / MatrixCare / similar software user
- Under active CDSS investigation or license action
- Fewer than 4 active residents
- Owner known to be unwilling to allow caregiver participation

Target: 5–10 qualified candidates after disqualifier filter.

---

### 3B — Outreach Sequence

Contact candidates in priority score order: Score 1 first, Score 4 last. Send outreach to warm ALH contacts before touching the registry cold list.

**Rules:**
- Send one contact at a time. Do not batch.
- Wait 5 business days before following up. Follow up once only.
- If no positive response from warm contacts + cold list after 4–6 weeks, activate Channel 4 (personal referrals via ALH staff or advisors).

**Outreach status tracker** — use `projects/alh-tracker/design_partner_tracker.md` as the live document. The "Date sent," "Status," and "Next step" columns in that file are the canonical outreach record. The format is:

| Facility | Contact | Date sent | Status | Next step |
|---|---|---|---|---|
| | | | Contacted / Interested / Visit scheduled / Declined / Committed | |

**Outreach scripts** are in task 0002, Section 3. Use the warm-introduction email for ALH contacts and the cold phone opener for registry contacts.

---

### 3C — Site Visit Questions

The site visit is the single most valuable Phase 0 activity. Organize what you ask around what each answer unlocks downstream.

> Before the visit: share the LOI outline (task 0002, Section 5) with the owner. Do not arrive without it. The LOI makes data handling expectations clear before you walk in the door.

#### Block A — Unblocks Task 0003 (shift model and caregiver auth)

Ask the owner or house manager:
- Walk me through your last shift handoff. What happened, step by step?
- Are your shifts fixed time blocks — like 7am–3pm, 3pm–11pm, 11pm–7am — or does that vary by day?
- Who opens a shift in writing, and who officially closes it?
- What happens if a caregiver leaves without closing out or writing anything?
- Do your caregivers log in individually, or do they all use a shared log or shared binder?
- How do you handle float or agency staff — do they follow the same documentation process as your regular caregivers?

Ask the caregiver (during or after shift, 15 minutes):
- What device do you use to document things during your shift — phone, tablet, paper, or something else?
- Is there a shared tablet or device anywhere in the building that caregivers use?

**What these answers unlock:** Whether shifts are fixed or configurable, how orphaned shifts are handled, whether individual accounts or shared PIN is preferred, and whether the shared tablet session model matters. All core decisions in task 0003.

---

#### Block B — Unblocks Task 0001 (pricing validation)

Ask the owner (do not anchor with a number first):
- What does your current monthly software spend look like for this facility — anything you pay for operations?
- If a tool reliably replaced your paper binder and made shift handoff faster, what would something like that be worth to you per month?
- What would make you refuse to adopt software for this, even if the price was right?

Wait for the owner's answer before asking any follow-up. Record the exact response — it is the most important pricing signal available before launch.

**What these answers unlock:** Whether $149/month is in the right range, whether ALH partner pricing at $49/month feels like a reasonable add-on, and what the real adoption blockers are beyond price.

---

#### Block C — Informs Task 0006 (family access baseline)

Ask the owner:
- How do family members currently stay informed about their loved one's daily care?
- Do you share shift notes or any written summary with families today — texts, printed sheets, email, phone calls?
- If you could automatically send a brief daily summary to family members, would you want that to go to all families or be something you control per-family?
- Have you ever had a resident who asked you specifically not to share their daily care information with family?

**What these answers unlock:** Whether family sharing is a meaningful operator pain point, what the current analog process looks like, and whether any operators have encountered the resident autonomy edge case that ADR 0004 addresses. This baseline informs the task 0006 design partner validation gate.

---

#### Block D — Informs Task 0008 (WiFi quality and devices)

Observe and note — you do not need to ask these directly, but record what you see:
- Is there a WiFi router visible on-site? Where is it located in the building (near front, in a common area, elsewhere)?
- Are there rooms or areas that seem far from the router — back bedrooms, detached units, outdoor areas?
- What phones are caregivers using? Note make and model if visible — older Android devices are common in this caregiver demographic and affect browser support assumptions.
- Is there a shared device (tablet, older phone) stationed anywhere?

**What these observations unlock:** Validates or revises the WiFi quality assumptions in task 0008's offline spec. If the facility has strong consistent WiFi coverage, the offline tolerance spec can be relaxed. If coverage is spotty (expected for a 10-room residential house with one router), the current conservative design is confirmed.

---

### 3D — After the Site Visit

Write a brief "Shift Workflow Observation Summary" covering:

- Shift structure: fixed time blocks or variable? Who opens/closes?
- Handoff format: verbal, written, or both? How long does it take?
- Biggest caregiver pain point — verbatim quote if possible
- Devices in use during shifts
- WiFi quality observation (coverage, dead spots, device types seen)
- Owner willingness-to-pay signal (paraphrase their words — do not interpret yet)
- Family sharing current practice (what the owner said they do today)

**File this in `ai_memory.md`** under a new entry dated with the visit date. It unblocks task 0003 activation and the task 0001 price lock. It also provides the task 0006 family sharing baseline.

---

## Section 4 — Counsel Routing Checklist

> **PRELIMINARY DESK RESEARCH ONLY — NOT LEGAL ADVICE.** Everything in this section and the referenced documents is preliminary research produced for the purpose of briefing counsel. It is not a legal determination or compliance certification. No product, policy, or commercial decision should be based on these findings without prior written confirmation from qualified California compliance/privacy counsel.

### 4A — What to send counsel

Assemble and send these files together:

- [ ] `tasks/active/alh-tracker/0004-counsel-handoff-packet.md` — the primary brief. Includes product description, what the product is not, all questions in priority order, supporting document list, and decisions blocked pending counsel response. Send this first.
- [ ] `projects/alh-tracker/compliance_notes.md` — product boundary statements, HIPAA posture, medication boundary language, preliminary Title 22 research summary, and family access consent posture.
- [ ] `projects/alh-tracker/data_model.md` — all entities, including CareLogEntry, ObservedCareTask, AuditTrail, Resident, User, Facility, ResidentContact, and FamilyAccessConsent with their current field definitions.
- [ ] `tasks/active/alh-tracker/0004-title-22-documentation-review.md`, Sections 3–6 — full mapping of § 87506, 87211, 87465, and 87411 against the alh-tracker data model; extended language avoidance list; in-product disclosure drafts; structured question register.
- [x] Terms of Service draft — **`projects/alh-tracker/tos_draft_for_counsel.md` created 2026-05-10.** Preliminary draft covering: vendor role, record ownership, retention (with placeholders pending Q1 and Q2 counsel answers), account closure and record disposition (placeholder pending Q4), export/return/deletion rights, HIPAA BAA posture (explicitly unresolved), no compliance certification clause. Clearly labeled draft only — not legal advice, not approved policy. Include this in the counsel package.

### 4B — Priority 1 questions (must answer before commercial launch)

These four questions from task 0004 are the primary routing ask. Request written answers to all four before setting any commercial launch target date.

**Q1 — Resident records and vendor retention**
Do alh-tracker CareLogEntry records constitute "resident records" under § 87506? If so: (a) does 3-year post-service retention apply to the vendor? (b) what are vendor confidentiality obligations? (c) what must the ToS say about record ownership, retention, and return/deletion on account termination?

**Q2 — Medication-adjacent observations and HIPAA BAA**
Do alh-tracker ObservedCareTask records (caregiver observations of medication-related care events, capturing date/time/status/note but NOT medication name, dosage, prescriber, or clinical response) constitute "medication records" under § 87465? If so: (a) does 1-year retention apply to the vendor? (b) what are destruction/purge obligations? Separately — (c) does storing medication-adjacent observations without dosage require a HIPAA BAA for facilities with Medicare/Medicaid residents?

**Q3 — Vendor incident reporting obligation**
Does logging an incident note in alh-tracker create any mandatory reporting obligation for the software vendor, independent of the licensee's § 87211 obligations? Under what circumstances would a vendor's possession of an incident record create legal exposure if the licensee has not reported?

**Q4 — Account closure and record disposition**
When a facility account closes, what are the vendor's obligations for: (a) retention, (b) destruction/purge, (c) export or return to the operator, (d) notice requirements?

### 4C — Family access questions (must answer before Phase 2 family portal is built)

These questions come from task 0006. Route them alongside the task 0004 packet — one engagement is more efficient than two. These are not urgent for Phase 1 but must be answered before any family-facing feature is designed or built.

**Q5** — Does the FamilyAccessConsent dual-acknowledgment model (operator authorization + resident autonomy noted by operator) satisfy California privacy law (CPPA/CCPA) for family contacts as California residents?

**Q6** — What notice must be given to residents at or before account creation about the possibility that the facility operator may grant family contacts access to their care information?

**Q7** — Can a competent resident actively revoke a family contact's access through the product — or only the facility operator can? Does the product have an obligation to support resident-side revocation?

**Q8** — What happens to FamilyAccessConsent records and any associated family access when a resident is transferred or deceased?

**Q9** — Does the `full_notes` access level (family contact sees raw caregiver note text rather than a summary) require separate consent language, a higher authorization threshold, or any different legal treatment?

**Q10** — Does sharing incident log notes or observed care task notes with authorized family contacts create any independent regulatory or legal obligation for the vendor?

### 4D — Decisions blocked until counsel responds

| Decision | Blocked by |
|---|---|
| Retention period policy for care log records | Q1 and Q2 |
| Account closure behavior and record disposition | Q4 |
| HIPAA BAA posture | Q2(c) |
| Incident logging UI language (final approved text) | Q3 |
| Caregiver account termination / anonymization policy | Q4 and separate task 0004 Q6 |
| Terms of Service — data handling and record ownership | Q1, Q4 |
| Commercial launch readiness | Q1, Q2, Q3, Q4 all answered |
| Phase 2 family portal implementation | Q5 through Q10 |

---

## Section 5 — Decision Log Summary

Four architectural decisions have been made and recorded. These are accepted unless reversed through the ADR process.

---

**ADR 0001 — Data Boundary: alh-tracker vs. AssistedLivingHelp** | Accepted 2026-05-05

Resident care data in alh-tracker must not flow to the AssistedLivingHelp platform without: explicit named operator consent, legal review, a documented data sharing agreement, technical enforcement at the query/API layer, and an audit trail. The only data that crosses the boundary as normal commercial operations is the `alh_partner` boolean and `alh_partner_tier` field on the Facility entity — commercial relationship status only. This is an architectural constraint, not a policy preference.

---

**ADR 0002 — Pricing Model Type: Flat Monthly Per-Facility** | Accepted 2026-05-05

alh-tracker uses a flat monthly subscription per facility. No per-resident component at launch. Variable census in 6–20 resident homes makes per-resident billing unpredictable; flat rate is simpler to budget and explain. Does not fix a price — see ADR 0003 for working ranges.

---

**ADR 0003 — Business Model: ALH Partner Pricing and Shared Onboarding Policy** | Accepted 2026-05-09

ALH facility partner pricing: free during design partner phase and Phase 1 ALH partner pilot; $49/month add-on at commercial transition (founding partner rate). **Owner must confirm this rate before any ALH pilot conversation concludes.** Non-ALH standalone: $149/month recommended test price ($99–$199/month working range) — not locked; requires design partner validation. No shared onboarding or billing system between ALH and alh-tracker at MVP. ALH partner identification is via `alh_partner` boolean on the Facility entity only.

---

**ADR 0004 — Family Access Architecture** | Accepted 2026-05-09

Family access is deferred from MVP; stubs exist in schema but are unpopulated at launch. When built: always read-only; requires dual acknowledgment (operator authorization + resident autonomy noted); defaults to summary level — not raw caregiver notes; category-scoped (incident and observed care task categories excluded from default scope); same primary database with row-level authorization; family contacts are not User records; all access events logged in AuditTrail. Phase 2 family portal implementation is blocked on counsel review of the consent model.

---

## Section 6 — Do Not Do Yet

These are explicit holds. None of these should begin until the listed gate clears.

| What not to do | Gate |
|---|---|
| Begin any application code or technical stack selection | Design partner committed AND task 0003 activated |
| Make any compliance, Title 22, or CDSS claim in marketing or product UI | Counsel review of task 0004 Priority 1 questions |
| Quote $149/month as the final non-ALH price in any communication | Design partner pricing probe completed |
| Quote or commit to an ALH partner rate other than the ADR 0003 recommendation | Owner confirms or revises ADR 0003 in writing |
| Build any family portal, family-facing feature, or family access flow | Counsel review of task 0006 consent model (Q5–Q10) |
| Add medication name, dosage, drug schedule, or prescriber fields to any data model entity | Compliance review specifically approving that scope |
| Build MAR/eMAR, medication administration records, or pharmacy workflow | Full compliance/legal review of MAR path (Phase 3 gate) |
| Activate Task 0003 (shift model and caregiver auth) | Real site visit with answers to shift period, auth model, and device questions |
| Activate Task 0005 (MVP data model finalization) | Counsel answers to Q1 and Q4 (retention and account closure) |
| Activate Task 0007 (logging UX and prototype) | Design partner committed and Task 0003 activated |
| Store real resident care data under any commercial relationship | All Priority 1 counsel questions answered; ToS reviewed; HIPAA BAA posture confirmed |

---

**Document last updated:** 2026-05-10 (Action 5 updated 2026-05-11 to reference AI-assisted review note in Task 0008)
**When to update this document:** After design partner candidate list is built, after first outreach is sent, when counsel responses are received, or when any ADR is revised.

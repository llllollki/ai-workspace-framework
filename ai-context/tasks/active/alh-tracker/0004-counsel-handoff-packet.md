# alh-tracker — Compliance/Privacy Counsel Handoff Packet

**Prepared:** 2026-05-09
**Prepared by:** Product / Program Lead (with AI-assisted desk research)
**Status:** Ready to route to counsel — not yet reviewed

> **IMPORTANT:** Everything in this packet is preliminary desk research only. It is not legal advice. It is not a compliance determination. No product, policy, or technical decision should be based on any finding here without prior review and confirmation by qualified California compliance/privacy counsel.

---

## Purpose

This packet packages the key compliance and privacy questions that must be answered before alh-tracker can proceed to commercial launch. It is structured for efficient counsel review — you should be able to engage directly with the questions below without reading the full project task documents, though supporting documents are listed at the end if context is needed.

---

## What alh-tracker Is (Product Description)

alh-tracker is a **shift log and handoff tool for small California RCFE operators** (Residential Care Facilities for the Elderly). It is a care observation and operational record system — it captures who did what, when, for which resident, during which shift.

The product is designed for caregiver phones, shared tablets, and desktop. Caregivers log shift events (meals, hydration, sleep notes, pain/mood observations, activity, general observations, and observed care tasks) during their shifts. At shift end, the system auto-generates a handoff summary for the incoming caregiver. Owners and administrators can review daily shift summaries and exception reports.

The product stores care log entries linked to named residents at a specific licensed California RCFE facility. Entries include: category, status, optional note, timestamp, caregiver identity, and shift reference. An append-only audit trail records all creates and edits.

## What alh-tracker Is Not

The product expressly does NOT:

- Constitute a medication administration record (MAR) or electronic MAR (eMAR). Observed care tasks capture caregiver observations of medication-related care events only — without medication name, dosage, prescriber, or response to treatment in the clinical sense. This omission is intentional.
- Constitute a clinical monitoring, clinical decision support, or medical advice system.
- Constitute an official regulatory record or substitute for any CDSS-required documentation under Title 22.
- Constitute an incident reporting system. An "incident note" logged in alh-tracker does not satisfy the facility's CDSS incident reporting obligation under § 87211.
- Make any HIPAA compliance claim. HIPAA BAA posture is an open question — see Question 2c below.
- Provide any guarantee that facilities using it are in compliance with any law or regulation.

These limitations will appear in the Terms of Service and in specific in-app disclosures at the relevant interaction points.

---

## Priority Questions for Counsel

Questions are grouped by priority. Priority 1 questions must be answered before commercial launch. Priority 2 questions must be answered before task 0005 (data model finalization). Priority 3 questions are relevant to a later phase (Phase 3 MAR-adjacent consideration).

---

### Priority 1 — Must answer before commercial launch

**Question 1 — Resident records and vendor retention obligation**

Do alh-tracker CareLogEntry records (care log entries created by caregivers during shifts, linking a resident, shift, caregiver, category, status, optional note, and timestamps) constitute "resident records" under Title 22, § 87506?

If yes:
- (a) Does the 3-year post-service retention requirement apply to the software vendor, the facility operator, or both?
- (b) What are the vendor's confidentiality obligations for these records?
- (c) What must the Terms of Service specify about record ownership, retention, and return/deletion on account termination?

**Question 2 — Medication-adjacent observations and HIPAA**

Do alh-tracker ObservedCareTask records (caregiver observations noting that a medication-related care event occurred during a shift, capturing date/time/status/optional note but NOT medication name, dosage, prescriber, or clinical response) constitute "medication records" under Title 22, § 87465?

If yes:
- (a) Does the 1-year retention requirement apply to the vendor?
- (b) What are the vendor's obligations on destruction/purge at the 1-year mark?

Separately:
- (c) Does the product's storage of medication-adjacent observations (even without dosage or medication name) require a HIPAA Business Associate Agreement for RCFE facilities whose residents may be Medicare or Medicaid beneficiaries?

**Question 3 — Vendor incident reporting obligation**

Does logging an incident note in alh-tracker create any mandatory reporting obligation for the software vendor — independent of the facility licensee's obligations under § 87211?

Under what circumstances, if any, would a vendor's possession of an incident record in its system create legal or regulatory exposure if the licensee has not fulfilled their mandatory reporting obligation?

The preliminary desk research finding is that § 87211 places reporting obligations on the licensee only, not on vendors. Counsel must confirm or correct this before commercial launch.

**Question 4 — Account closure and record disposition**

When a facility account closes (facility cancels service, facility closes, or operator terminates), what are the vendor's obligations with respect to:
- (a) Retention of care log records, audit trail, and resident records
- (b) Destruction or purge of those records
- (c) Export or return of records to the operator
- (d) Notice requirements to the facility operator

---

### Priority 2 — Must answer before data model finalization (task 0005)

**Question 5 — Personnel records**

Does alh-tracker's User entity (stores caregiver name, email, role, facility association, active status) and AuditTrail (records which user made which change to which care log entry) constitute a "personnel record" under § 87411 or any related regulation? If so, what retention and purge obligations apply?

**Question 6 — Caregiver identity preservation after termination**

When a caregiver's employment ends and their alh-tracker User account is deactivated, must the vendor retain the User identity record linked to their historical AuditTrail entries — or may those AuditTrail entries be anonymized? What is the vendor's obligation?

**Question 7 — Terms of Service data processing agreement**

Does the product's Terms of Service need to include a specific data processing agreement or Business Associate Agreement template for California RCFE operators? If yes, what must it include at minimum?

---

### Priority 3 — Before Phase 3 MAR-adjacent consideration (not urgent)

**Question 8 — Path toward medication name/dosage**

Under what conditions, if any, could alh-tracker add medication name and dosage fields to the observed care task model without the product becoming a medication administration record system requiring separate regulatory treatment?

**Question 9 — Stronger documentation without MAR classification**

What product design constraints (UI language, data model scope, disclaimer language) would allow alh-tracker to move toward stronger RCFE documentation support without triggering MAR/eMAR classification or clinical documentation obligations?

---

## Supporting Documents for Counsel Review

Counsel should have access to the following before answering:

| Document | Location | Purpose |
|---|---|---|
| Full desk research brief (task 0004 Outcome) | `tasks/active/alh-tracker/0004-title-22-documentation-review.md`, Sections 3–6 | Complete § 87506, 87211, 87465, 87411 mapping; data model compatibility assessment; extended language avoidance list; in-product disclosure drafts |
| Compliance notes | `projects/alh-tracker/compliance_notes.md` | Product boundary statements, HIPAA posture, data handling requirements, preliminary research summary |
| Data model design reference | `projects/alh-tracker/data_model.md` | All entities: CareLogEntry, ObservedCareTask, AuditTrail, Resident, User, Facility |
| In-product disclosure draft text | task 0004 Outcome, Section 5 | Three required in-product disclosure texts (general, incident, observed care task) — preliminary, pending counsel review |
| ToS draft — data handling addendum | `projects/alh-tracker/tos_draft_for_counsel.md` (created 2026-05-10) | Preliminary draft covering vendor role, record ownership, retention, account closure, export/return/deletion, HIPAA BAA posture (unresolved), and no compliance certification. Each open provision is mapped to the counsel question that must answer it. **Send alongside this packet — do not treat as approved policy.** |

---

## Decisions Blocked Pending Counsel Response

| Decision | Blocked by |
|---|---|
| Retention period policy for care log records | Questions 1 and 2 |
| Account closure behavior and record disposition | Question 4 |
| HIPAA BAA posture | Questions 2c and 7 |
| Incident logging UI language (final approved text) | Question 3 |
| Caregiver account termination/anonymization policy | Question 6 |
| Terms of Service — data handling and record ownership | Questions 1, 4, and 7 |
| Commercial launch readiness | All Priority 1 questions |

---

## Suggested Email Cover Note to Counsel

Use or adapt this message when routing the packet. Do not deviate from the labeling or the scope of the ask.

---

> **Subject:** alh-tracker — Compliance/Privacy Review Request: California RCFE Software Vendor Questions
>
> [Counsel name],
>
> We are developing a shift log and handoff tool (alh-tracker) for small California RCFE operators. Before proceeding to commercial launch, we need written guidance on a set of compliance and privacy questions affecting our data model, Terms of Service, and product design.
>
> I am attaching the following documents for your review:
>
> 1. **Counsel Handoff Packet** (`0004-counsel-handoff-packet.md`) — the primary brief. Describes the product, lists all questions in priority order, and identifies decisions we cannot make without your input.
> 2. **Terms of Service Draft** (`tos_draft_for_counsel.md`) — a preliminary data handling addendum. Each open provision is explicitly flagged with the question it depends on. Please review alongside the questions.
> 3. **Title 22 Desk Research** (`0004-title-22-documentation-review.md`, Sections 3–6) — our preliminary mapping of § 87506, 87211, 87465, and 87411 against the product data model.
> 4. **Compliance Notes** (`compliance_notes.md`) — product boundary statements, HIPAA posture, and preliminary research summary.
> 5. **Data Model Reference** (`data_model.md`) — all entity definitions, including the care log, audit trail, and family access stubs.
>
> **Everything in this package is preliminary desk research only. We are not making any compliance claim. We are asking for your legal guidance before we make any decisions based on these findings.**
>
> **We are asking for written responses to two groups of questions:**
>
> **Priority 1 — Please answer before we set any commercial launch date (Q1–Q4):**
> - Q1: Do CareLogEntry records constitute resident records under § 87506, and what are the vendor's retention and confidentiality obligations?
> - Q2: Do ObservedCareTask records (no dosage, no medication name) constitute medication records under § 87465, and does storage of these records require a HIPAA BAA?
> - Q3: Does vendor possession of an incident log entry create any mandatory reporting obligation independent of the licensee's § 87211 obligations?
> - Q4: When a facility account closes, what are the vendor's obligations for retention, destruction, export, and notice?
>
> **Phase 2 — Please answer before we design or build any family-facing feature (Q5–Q10):**
> - Q5–Q10 are detailed in Section 4C of the packet. They cover the family access consent model, resident autonomy, CPPA/CCPA obligations for family contacts, and the legal treatment of the `full_notes` access level.
>
> Please let us know if any document is unclear or if you need additional context before responding to the Priority 1 questions.
>
> Thank you,
> [Name]

---

## Contact and Next Steps

Route this packet and the supporting documents listed above to Compliance / Privacy Counsel. Request a written response to the Priority 1 questions (Q1–Q4) before setting any commercial launch target date. Route Q5–Q10 alongside the same engagement — one engagement is more efficient than two.

All preliminary language avoidance and in-product disclosures described in task 0004 Section 5 should be treated as drafts only until counsel has reviewed and confirmed or revised them.

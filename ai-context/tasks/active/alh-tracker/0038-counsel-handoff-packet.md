# alh-tracker — Compliance/Privacy Counsel Handoff Packet

**Prepared:** 2026-05-09  
**Updated:** 2026-05-23 (added Q-R1–Q-R8 from retention/deletion policy analysis)  
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

Questions are organized into five groups by topic and blocking urgency. Priority 1 questions must be answered before any commercial launch date is set. Priority 2 (retention/account closure) and Priority 3 (medication-adjacent / Title 22 supplement) questions must be answered before retention workflows or account closure automation are designed. Priority 4 (privacy/data subject rights) questions must be answered before any CCPA/CPPA response procedures are designed. Priority 5 questions cover future phases and family access features.

> Q-R1 through Q-R8 were added 2026-05-23 following preliminary retention and deletion policy analysis (task 0009). They supplement existing Q1–Q9 and should be routed in the same counsel engagement.

---

### Priority 1 — Pre-commercial launch blockers
*(Must be answered before any commercial launch date is set)*

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

### Priority 2 — Retention and account closure
*(Supplement to Q4 — must be answered before retention workflows or account closure automation are designed or built)*

> PRELIMINARY — NOT LEGAL ADVICE — These questions arise from preliminary retention and deletion policy analysis (task 0009, 2026-05-23).

**Q-R3 — Supabase PITR backup copies as retention mechanism**

Do Supabase PITR backup copies (7-day rolling window on the Pro plan) constitute "copies" of records for retention compliance purposes? If the vendor must retain records for 3 years, must those records be in an immediately queryable active database, or is encrypted cold storage archiving with a reasonable retrieval SLA acceptable?

**Q-R5 — Per-resident vs. per-account retention clock**

For § 87506's 3-year post-service retention: is the clock measured per-resident (from when the individual resident's service at the facility ends) or per-account (from when the facility cancels service with alh-tracker)? If per-resident: what is the vendor's obligation to track individual resident departure dates for retention purposes, and how must this tracking be implemented?

**Q-R6 — Vendor obligation to retain records after account closure**

If a facility cancels its alh-tracker subscription before the § 87506 3-year retention window has expired for some residents, is the vendor obligated to retain those records after the commercial relationship ends? Or does the retention obligation transfer entirely to the facility operator at account closure? This has significant product architecture and cost implications.

**Q-R7 — Export format and content requirements on account closure**

Is the vendor legally obligated to provide the facility with an export of their records on account closure, or is this solely a contractual matter? If legally required: what format (structured data, human-readable print), what content (care records only, audit trail, user records?), and within what timeline?

**Q-R8 — Backup retention and queryability requirements**

Is it legally permissible to satisfy a 3-year retention obligation by maintaining encrypted cloud backups (not immediately queryable), rather than keeping records in an active production database for the full retention period? If cold storage archiving is permissible, what retrieval timeline is required if CDSS or a court requests the records?

---

### Priority 3 — Medication-adjacent and Title 22 supplement
*(Addresses remaining Title 22 obligations for current product scope — answer alongside Priority 1)*

> PRELIMINARY — NOT LEGAL ADVICE

**Q-R4 — "Destruction records" under § 87465 applied to a software vendor**

Section 87465 requires retention of medication destruction records for 3 years. As a software vendor that never physically holds medication records, does alh-tracker have any obligation with respect to § 87465 destruction records? If yes, what would count as a "destruction record" in a software system context?

---

### Priority 4 — Privacy and data subject rights (CPPA/CCPA)
*(Must be answered before any data subject request workflows are designed)*

> PRELIMINARY — NOT LEGAL ADVICE

**Q-R1 — CPPA/CCPA deletion requests vs. Title 22 retention obligations**

When a data subject (facility operator, caregiver, or family contact) submits a CPPA/CCPA deletion request, can that request override alh-tracker's obligation to retain records for Title 22 retention periods? Specifically: if a caregiver submits a CCPA deletion request for their name and email address, must their identity be removed from AuditTrail references, even if doing so would compromise audit integrity for care records still within a 3-year retention window?

**Q-R2 — Audit trail immutability vs. data subject deletion rights**

The `audit_events` table is append-only by design — no UPDATE or DELETE is permitted at the database level. If a CPPA/CCPA deletion request applies to information recorded in `audit_events`, is the product's inability to delete those events a violation? Or does the Title 22 retention obligation override the consumer deletion right in this context?

---

### Priority 5 — Future phases and family access
*(Must be answered before any family-facing features are designed or built; Q8–Q9 before any MAR-adjacent consideration)*

**Question 5 — Personnel records**

Does alh-tracker's User entity (stores caregiver name, email, role, facility association, active status) and AuditTrail (records which user made which change to which care log entry) constitute a "personnel record" under § 87411 or any related regulation? If so, what retention and purge obligations apply?

**Question 6 — Caregiver identity preservation after termination**

When a caregiver's employment ends and their alh-tracker User account is deactivated, must the vendor retain the User identity record linked to their historical AuditTrail entries — or may those AuditTrail entries be anonymized? What is the vendor's obligation?

**Question 7 — Terms of Service data processing agreement**

Does the product's Terms of Service need to include a specific data processing agreement or Business Associate Agreement template for California RCFE operators? If yes, what must it include at minimum?

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
| Retention and deletion policy analysis | `tasks/active/alh-tracker/0009-retention-deletion-policy.md`, "Preliminary Policy Draft" section | Schema audit, data category retention table, account closure behavior, archive/delete/anonymize framework, and implementation implications. Source of Q-R1–Q-R8. PRELIMINARY — NOT LEGAL ADVICE. |

---

## Decisions Blocked Until Counsel Answers

> No retention, purge, deletion, anonymization, or account closure automation should be designed or built until the relevant questions below are answered.

| Decision | Blocked by |
|---|---|
| Retention period policy for care log records | Q1, Q2 |
| Account closure behavior and record disposition | Q4, Q-R6, Q-R7 |
| HIPAA BAA posture | Q2c, Q7 |
| Incident logging UI language (final approved text) | Q3 |
| Caregiver account termination / anonymization policy | Q6, Q-R1, Q-R2 |
| Terms of Service — data handling and record ownership | Q1, Q4, Q7 |
| Commercial launch readiness | All Priority 1 questions (Q1–Q4) |
| Per-resident vs. per-account retention clock | Q-R5 |
| Vendor obligation to retain records after account closure | Q-R6 |
| Export package format, content, and legal requirement | Q-R7 |
| Cold storage archiving acceptability for retention compliance | Q-R3, Q-R8 |
| CCPA/CPPA deletion request handling for `audit_events` | Q-R1, Q-R2 |
| Medication destruction records vendor obligation under § 87465 | Q-R4 |
| Retention automation / purge job design | Q-R3, Q-R5, Q-R6, Q-R8 |
| PITR reliance as a retention compliance mechanism | Q-R3 |

---

## Suggested Email Cover Note to Counsel

Use or adapt this message when routing the packet. Do not deviate from the labeling or the scope of the ask.

---

> **Subject:** alh-tracker — Compliance/Privacy Review Request: California RCFE Software Vendor Questions (Updated 2026-05-23)
>
> [Counsel name],
>
> We are developing a shift log and handoff tool (alh-tracker) for small California RCFE operators. Before proceeding to commercial launch, we need written guidance on a set of compliance and privacy questions affecting our data model, Terms of Service, product design, and retention/deletion policy.
>
> I am attaching the following documents for your review:
>
> 1. **Counsel Handoff Packet** (`0038-counsel-handoff-packet.md`) — the primary brief. Describes the product, lists all questions in priority order, and identifies decisions we cannot make without your input. Updated 2026-05-23 to add retention/deletion and privacy questions Q-R1–Q-R8.
> 2. **Terms of Service Draft** (`tos_draft_for_counsel.md`) — a preliminary data handling addendum. Each open provision is explicitly flagged with the question it depends on. Please review alongside the questions.
> 3. **Title 22 Desk Research** (`0004-title-22-documentation-review.md`, Sections 3–6) — our preliminary mapping of § 87506, 87211, 87465, and 87411 against the product data model.
> 4. **Compliance Notes** (`compliance_notes.md`) — product boundary statements, HIPAA posture, and preliminary research summary.
> 5. **Data Model Reference** (`data_model.md`) — all entity definitions, including the care log, audit trail, and family access stubs.
> 6. **Retention and Deletion Policy Analysis** (`0009-retention-deletion-policy.md`, "Preliminary Policy Draft" section) — schema audit and preliminary retention framework. Source of the Q-R supplemental questions. PRELIMINARY — NOT LEGAL ADVICE.
>
> **Everything in this package is preliminary desk research only. We are not making any compliance claim. We are asking for your legal guidance before we make any decisions based on these findings.**
>
> **We are asking for written responses to five groups of questions:**
>
> **Priority 1 — Please answer before we set any commercial launch date (Q1–Q4):**
> - Q1: Do CareLogEntry records constitute resident records under § 87506, and what are the vendor's retention and confidentiality obligations?
> - Q2: Do ObservedCareTask records (no dosage, no medication name) constitute medication records under § 87465, and does storage of these records require a HIPAA BAA?
> - Q3: Does vendor possession of an incident log entry create any mandatory reporting obligation independent of the licensee's § 87211 obligations?
> - Q4: When a facility account closes, what are the vendor's obligations for retention, destruction, export, and notice?
>
> **Priority 2 — Retention and account closure (Q-R3, Q-R5–Q-R8 — answer alongside Priority 1):**
> - Q-R3: Do PITR backup copies satisfy a vendor's retention compliance obligation, or is an immediately-queryable active database or cold storage with retrieval SLA required?
> - Q-R5: Is the 3-year retention clock per-resident (from departure) or per-account (from cancellation)?
> - Q-R6: If a facility cancels before the 3-year window expires, is the vendor obligated to retain records after the commercial relationship ends?
> - Q-R7: Is the vendor legally required to provide a data export on account closure, and if so, in what format and timeline?
> - Q-R8: Is encrypted cold storage archiving permissible to satisfy a 3-year retention obligation, and what retrieval timeline is required?
>
> **Priority 3 — Medication-adjacent / Title 22 supplement (Q-R4 — answer alongside Priority 1):**
> - Q-R4: Does alh-tracker (which never physically holds medication records) have any obligation under § 87465 destruction records provisions?
>
> **Priority 4 — Privacy and data subject rights (Q-R1–Q-R2 — answer before CCPA/CPPA response procedures are designed):**
> - Q-R1: Can a CPPA/CCPA deletion request override alh-tracker's Title 22 retention obligation, specifically for caregiver identity in AuditTrail entries?
> - Q-R2: If `audit_events` is append-only by design, is that a CPPA/CCPA violation, or does the Title 22 retention obligation override the consumer deletion right?
>
> **Priority 5 — Future phases and family access (Q5–Q9 — answer before any family-facing features are designed):**
> - Q5–Q9 are detailed in the packet. They cover personnel records, caregiver identity preservation, Terms of Service requirements, and the MAR-adjacent product boundary.
>
> Please let us know if any document is unclear or if you need additional context before responding to the Priority 1 questions.
>
> Thank you,  
> [Name]

---

## Contact and Next Steps

Route this packet and the supporting documents listed above to Compliance / Privacy Counsel. Request a written response to the Priority 1 questions (Q1–Q4) before setting any commercial launch target date. Route Q-R3, Q-R4, Q-R5–Q-R8, Q-R1, Q-R2, and Q5–Q9 alongside the same engagement — one engagement is more efficient than multiple separate engagements.

All preliminary language avoidance and in-product disclosures described in task 0004 Section 5 should be treated as drafts only until counsel has reviewed and confirmed or revised them.

No retention, purge, anonymization, export, or account closure automation should be designed or built until counsel has answered the relevant questions in Priority 2–4 above.

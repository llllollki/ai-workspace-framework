# Task 0004 — Title 22 Documentation Review

**Project:** alh-tracker
**Status:** active
**Created:** 2026-05-05
**Owner role:** Compliance / Privacy Counsel (lead); Product / Program Lead (review)
**Reviewers:** Technical Architect

---

## Goal

Conduct a focused review of California RCFE regulations (Title 22, Division 6, Chapter 8) to identify which documentation requirements affect the alh-tracker MVP data model and future compliance path.

This is a research and risk-identification task, not a compliance certification task. The output informs data model and UI design — not a legal opinion.

---

## Acceptance Criteria

1. A documented list of Title 22 documentation categories relevant to the MVP log categories (meals, sleep, pain/mood, incidents, observed care tasks).
2. For each relevant category: what Title 22 requires (content, format, retention period) and whether the current data model design is compatible or potentially conflicting.
3. A list of specific terms or language to avoid in the product UI to prevent implying regulatory compliance the product does not provide.
4. A list of data model fields or constraints that must be preserved to not block a future stronger compliance path.
5. An answer to the question: does logging an incident in alh-tracker create any mandatory reporting obligations for the product vendor?
6. A compliance/privacy counsel sign-off, or escalation if the product creates reportable obligations.
7. `compliance_notes.md` updated with confirmed findings.

---

## Plan

This task should be completed before task 0005 (MVP data model finalization) is closed.

- [x] Identify relevant Title 22 sections for RCFE operations documentation (resident records — Section 87506, incident reporting — Section 87211, medication management — Section 87465, staffing — Section 87411)
- [x] Map alh-tracker log categories to relevant Title 22 sections
- [x] For each mapped category: document the regulatory requirement, retention period, and data model compatibility assessment
- [x] Identify UI and marketing language to avoid (see initial list in `compliance_notes.md`, expanded in Section 5 below)
- [x] Identify data model constraints: fields that must exist, retention periods to plan for, soft-delete requirements
- [x] Preliminary answer on incident reporting obligation for the product vendor (see Section 5; counsel confirmation required)
- [x] Prepare counsel handoff packet — `0004-counsel-handoff-packet.md` created 2026-05-09; ready to route
- [ ] Route counsel handoff packet and supporting documents to Compliance / Privacy Counsel for review and sign-off
- [ ] Update `compliance_notes.md` with confirmed, counsel-reviewed findings
- [ ] Update `ai_memory.md`: remove resolved open questions

---

## Notes

- This task should be completed before task 0005 (data model finalization), not after. The findings may change field requirements or retention rules.
- The goal is not to make alh-tracker a compliance system. It is to ensure the product does not inadvertently conflict with or mislead operators about their CDSS obligations.
- Do not invent legal requirements or present conclusions without source-backed review. Cite specific Title 22 section numbers in the output.
- If counsel identifies that alh-tracker creates any mandatory reporting obligations for the vendor (not just the operator), escalate immediately to Product / Program Lead.
- Secondary research sources: CDSS RCFE licensing guides, California RCFE Advocate publications, CALCASA resources.

---

## Planning Notes

**Activated 2026-05-05.** Research posture and language constraints confirmed at task activation:

- **Research posture:** Desk research output produced under this task is preliminary research for compliance/privacy counsel review. All output must be clearly labeled as preliminary research, not legal advice or legal interpretation. AI-assisted research is approved to produce a structured brief; counsel must review and sign off before any findings are treated as authoritative.
- **Language hard stops — confirmed at activation:** The product must not claim, imply, or suggest any of the following in marketing copy, product UI, task output, or counsel briefs:
  - Regulatory compliance, CDSS compliance, or Title 22 compliance
  - MAR, eMAR, or medication administration record equivalence
  - Clinical monitoring, clinical decision support, or clinical record status
  - Medication safety, dose validation, drug interaction checking, or prescribing guidance
  - Legal sufficiency for any Title 22 documentation requirement
- **Desk research scope:** Map alh-tracker's seven log categories (meal, hydration, sleep, pain/mood, activity, incident, observed care task) against the four identified Title 22 sections. Flag any category where a logged entry could be misread as satisfying a regulatory documentation obligation. Flag data model fields or retention periods that may need adjustment to not conflict with CDSS requirements.
- **Completion gate:** Counsel sign-off is required to close this task. Desk research output should be formatted as a reviewable brief — section-by-section mapping with specific flagged risk items — so counsel can engage efficiently rather than starting from scratch.

---

## Outcome

> **Status: desk research complete — task not yet closed.** Sections 1–6 constitute the structured counsel brief. Desk research (Criteria 1–4 and preliminary answer to Criterion 5) is complete. Criteria 6 and 7 require counsel review and sign-off, which cannot be completed from desk research alone. Task remains active until counsel review is complete.

> **IMPORTANT:** Everything in this Outcome section is preliminary research only. It is not legal advice and does not constitute a compliance determination. All findings must be reviewed and confirmed by qualified California compliance/privacy counsel before any product, policy, or technical decision is based on them.

---

### 1. Preliminary Research Disclaimer

**This section and all findings below are PRELIMINARY RESEARCH produced for the purpose of briefing compliance/privacy counsel. This is not legal advice. This is not a compliance determination. This does not constitute legal interpretation of California Code of Regulations Title 22 or any other statute or regulation. No product, policy, contractual, or technical decision should be based on this research without prior review and confirmation by qualified California compliance/privacy counsel.**

Sources consulted are primary/official sources where available. All section citations should be verified against the current California Code of Regulations text before use in any formal context.

---

### 2. Source List

| Source | URL | Notes |
|---|---|---|
| Cal. Code Regs. Tit. 22, § 87506 — Resident Records | https://www.law.cornell.edu/regulations/california/22-CCR-87506 | Cornell LII mirror of official California CCR text |
| Cal. Code Regs. Tit. 22, § 87211 — Incident Reporting | https://www.law.cornell.edu/regulations/california/22-CCR-87211 | Cornell LII mirror |
| Cal. Code Regs. Tit. 22, § 87465 — Medication Management | https://www.law.cornell.edu/regulations/california/22-CCR-87465 | Cornell LII mirror |
| Cal. Code Regs. Tit. 22, § 87411 — Personnel Records | https://www.law.cornell.edu/regulations/california/22-CCR-87411 | Cornell LII mirror |
| CCLD RCFE Self-Assessment Guide (PDF) | https://www.ccld.dss.ca.gov/res/pdf/RCFE_Self-AssessmentGuide.pdf | Official CDSS/CCLD supplemental guidance; common problem areas |
| CDSS Community Care Licensing Division Manual | https://www.cdss.ca.gov/ord/entres/getinfo/pdf/rcfeman1.pdf | Official CDSS policy/procedure interpretation manual |

**Counsel should verify all section text against the current official California OAL or CDSS source, as third-party mirrors may not reflect recent amendments.**

---

### 3. Mapping Table

> PRELIMINARY RESEARCH — NOT LEGAL ADVICE — PENDING COUNSEL REVIEW

Each row maps one Title 22 documentation area to alh-tracker's MVP features, data model, and relevant product language questions.

#### 3A — Section 87506: Resident Records

**Summary of requirement:** Facilities must maintain a separate, current, and complete record for each resident. Required content includes: identification data; medical assessments; mental and social condition documentation; ambulatory status; records of illness or injury affecting function; current medications and PRN orders; emergency contact information; admission/discharge dates. Records must be kept confidential, accessible to the licensing agency, and retained for a minimum of **3 years** after termination of service.

| Dimension | Assessment |
|---|---|
| **Relevant alh-tracker log categories** | All categories (meal, hydration, sleep, pain/mood, activity, general, incident, observed_care_task) — any care log entry could be considered a record of a resident's condition or functional status |
| **MVP feature/entity affected** | CareLogEntry, ObservedCareTask, Resident, AuditTrail |
| **Retention implication** | If alh-tracker care log entries are considered part of the "resident record" under 87506, they must be retained for 3 years after the resident's service ends. The current data model uses soft-delete (`is_active` on Resident) and an append-only AuditTrail, which is directionally compatible — but explicit retention policy enforcement is not yet defined. |
| **Data model compatibility** | Directionally compatible. The current model never hard-deletes care log entries and preserves `created_by`, `logged_at`, `resident_id`. **Risk:** The model has no defined retention period enforcement, no purge-after-N-years mechanism, and no defined behavior when a facility account is closed. These gaps must be resolved before commercial launch. |
| **Product language boundary** | Do NOT use: "resident record," "complete record," "official care record," "CDSS record," "required documentation." Care log entries are operational observations; their status as 87506-compliant resident records is undefined and must not be implied. |
| **Counsel question** | **Do alh-tracker CareLogEntry records constitute "resident records" under 87506? If so: (a) does the 3-year retention requirement apply to the vendor, the facility, or both? (b) what are the confidentiality obligations for the vendor as a data processor of these records? (c) what must happen to records when a facility account is closed?** |

#### 3B — Section 87211: Incident Reporting

**Summary of requirement:** Licensees must report specific categories of incidents to CDSS, the State Long-Term Care Ombudsman, law enforcement, and/or family contacts within defined timeframes. 7-day written report for: death, serious injury, AED use, incidents threatening welfare/safety, unexplained absence. 24-hour/2-hour telephone report for: epidemics, catastrophes, serious abuse. The licensee (facility operator) is identified as the responsible reporting party. Incidents must be documented with: resident name, age, sex, admission date, date/nature of event, physician findings, treatment, and disposition.

| Dimension | Assessment |
|---|---|
| **Relevant alh-tracker log category** | `incident` category |
| **MVP feature/entity affected** | CareLogEntry (category=incident), FollowUp |
| **Retention implication** | 87211 does not specify a retention period for incident reports beyond what 87506 requires for resident records (3 years). Incident-related log entries are likely subject to the same 87506 retention framework — but counsel must confirm. |
| **Data model compatibility** | The current `incident` category CareLogEntry captures: status, note, timestamp, caregiver identity, resident reference, shift reference. It does NOT capture: resident age, sex, admission date, physician name, physician findings, or formal disposition. This is intentional — alh-tracker is NOT an incident reporting system. However, the gap between what alh-tracker captures and what 87211 requires must be made explicit in UI language and ToS. |
| **Product language boundary (HIGH RISK)** | This is the highest-risk language area. Do NOT use: "incident report," "incident record," "reportable incident," "CDSS incident," "required incident documentation," any language suggesting the incident log entry satisfies 87211. The in-app label for the `incident` category should be something like "Incident Note" or "Shift Incident Note" — emphatically not "Incident Report." |
| **In-product disclosure required** | When a caregiver logs an `incident`-category entry, the UI should display a visible, plain-language notice: "This note is for your internal shift log only. It does not satisfy any CDSS incident reporting requirement. Contact your administrator for required reporting procedures." |
| **Counsel question** | **Does storing an incident log entry in alh-tracker (a vendor's system) create any mandatory reporting obligation for the vendor? Under what circumstances, if any, would a vendor's knowledge of an incident in its system create independent legal or regulatory obligations? Does the answer change if the vendor is aware the licensee has not filed a required 87211 report?** |

#### 3C — Section 87465: Medication Management / Medication Assistance

**Summary of requirement:** RCFE staff may assist residents with **self-administration** of medications — not administer them (that requires a licensed professional). When medication assistance is provided, a record must be maintained showing: date, time, dosage, and the resident's response to treatment. Medication records must be retained for at least **1 year**. PRN (as-needed) medication orders must document: specific symptoms, exact dosage, minimum hours between doses, maximum doses in 24 hours. Medication destruction records must be retained for **3 years**.

| Dimension | Assessment |
|---|---|
| **Relevant alh-tracker log category** | `observed_care_task` category (specifically medication/supplement observations) |
| **MVP feature/entity affected** | ObservedCareTask, CareLogEntry (category=observed_care_task) |
| **Retention implication** | If alh-tracker's ObservedCareTask records are considered "medication records" under 87465, a 1-year minimum retention applies. Current model retains all records (no hard-delete). Policy enforcement not yet defined. |
| **Data model compatibility** | SIGNIFICANT RISK. Section 87465 requires medication records to show: date ✅ (logged_at), time ✅ (logged_at), dosage ❌ (not captured — intentionally), resident response ⚠️ (captured as status+note, but not explicitly labeled as "response to treatment"). The deliberate absence of dosage from ObservedCareTask is correct and must remain: adding a dosage field would move the entity toward a MAR, which is explicitly out of scope and requires compliance review before implementation. |
| **Product language boundary (HIGH RISK)** | Do NOT use: "medication record," "medication administration record," "MAR," "med pass record," "medication log." The in-product label for observed care tasks should use "Observed Care Task" or "Care Task Note" — not "Medication Record" or "Med Log." The product must not imply it satisfies the 87465 documentation requirement. |
| **In-product disclosure required** | In the observed care task logging flow and in the ToS: "Observed care tasks in alh-tracker are caregiver observations only. They are not a medication administration record and do not satisfy medication documentation requirements under Title 22 or applicable law. Facilities remain responsible for maintaining any required medication records." |
| **Counsel question** | **Do alh-tracker ObservedCareTask records constitute "medication records" subject to the 1-year retention requirement under 87465? If so: (a) what are the vendor's obligations regarding retention and destruction of those records? (b) does the absence of dosage information in alh-tracker's observed care task model create any compliance gap for the facility — or does it reinforce the product's non-MAR boundary? (c) does alh-tracker's role as a vendor handling medication-adjacent observations require a HIPAA Business Associate Agreement?** |

#### 3D — Section 87411: Personnel Records and Caregiver Identity

**Summary of requirement:** Facilities must maintain personnel records including: training documentation (with trainer notation), health/qualification screenings (chest x-ray or TB test within 6 months before or 7 days after hire), Personnel Report-Roster (LIC 500 form), and Criminal Record Statements (LIC 508 form). Section 87411 does not explicitly require shift schedules or duty records — those are governed by staffing level requirements in other sections (§ 87300 et seq.).

| Dimension | Assessment |
|---|---|
| **Relevant alh-tracker log category** | All categories — caregiver identity is recorded on every CareLogEntry via `created_by` |
| **MVP feature/entity affected** | User entity, CareLogEntry.created_by, AuditTrail.changed_by |
| **Retention implication** | 87411 does not specify a retention period for personnel records beyond what general retention requirements imply. The LIC 500 form is a staffing roster, not a shift-level log. alh-tracker's User entity and audit trail are not personnel records in the 87411 sense. |
| **Data model compatibility** | Compatible. alh-tracker's User entity stores caregiver identity (name, role, facility association, is_active). The AuditTrail records which user made which change. This is operationally useful to the facility and directionally aligned with accountability requirements. alh-tracker is not a personnel records system and makes no claim to be. |
| **Product language boundary** | Do NOT use: "personnel record," "staffing record," "required caregiver record." alh-tracker records caregiver actions within a shift for shift log purposes only — not as a personnel or HR record. |
| **Counsel question** | **Does alh-tracker's User entity and AuditTrail constitute a "personnel record" in any sense that creates retention obligations under 87411 or other regulation? If a facility terminates a caregiver's employment, what obligation (if any) does alh-tracker have to preserve or purge that caregiver's action records?** |

#### 3E — Cross-Cutting: Record Retention and Account Closure

This item cuts across all four sections and is not addressed in the current data model design.

| Dimension | Assessment |
|---|---|
| **Affected entities** | CareLogEntry, ObservedCareTask, AuditTrail, Resident, User, Facility |
| **Retention requirements** | 87506: 3 years post-service for resident records. 87465: 1 year for medication records, 3 years for destruction records. 87411: no explicit period beyond general requirements. |
| **Current model gap** | The data model has no defined retention policy. No purge-after-N-years mechanism exists. Behavior when a Facility account closes is undefined — records are presumably retained in the database indefinitely, which may or may not be compliant. |
| **Risk** | If alh-tracker care records are considered resident records, the vendor may have obligations to retain them even if the facility cancels. If not, the vendor may have obligations to delete them. Either answer requires a defined policy. |
| **Counsel question** | **What retention and deletion obligations apply to alh-tracker as a software vendor (not a licensed facility) for the categories of data it stores? Who owns the records — the facility or the vendor? What must the product's Terms of Service say about record ownership, retention, and return/deletion on account termination?** |

---

### 4. Data Model Implications

> PRELIMINARY RESEARCH — PENDING COUNSEL REVIEW

#### Fields confirmed to preserve from day one (already in current model)

| Field | Entity | Rationale |
|---|---|---|
| `logged_at` timestamp | CareLogEntry | Any care record that might be referenced in a licensing review or incident context needs a precise timestamp of the observation, not just record creation |
| `created_at` timestamp | CareLogEntry | Distinguishes when the observation was recorded vs. when it occurred (logged_at) |
| `created_by` user reference | CareLogEntry | Caregiver identity on every record supports 87465 accountability and general audit requirements |
| `resident_id` | CareLogEntry | All records must be linkable to a specific resident; required for any future compliance context |
| `shift_id` | CareLogEntry | Shift reference provides temporal and operational context for any record review |
| `is_active` soft-delete | Resident | Hard-deleting resident records would conflict with any retention obligation; soft-delete preserves the record while removing operational presence |
| Append-only constraint | AuditTrail | Regulatory records require edit history preservation; an append-only audit trail is the correct pattern for any data that might be reviewed by a licensing agency |
| `previous_value` JSON snapshot | AuditTrail | Preserving the prior state of any edited record satisfies the "correct and current" record requirements implied by 87506 |

#### Fields confirmed NOT to add at MVP (intentional omissions)

| Omitted field | Why it must stay omitted |
|---|---|
| Medication name / drug name | Adding this to ObservedCareTask moves the entity toward MAR territory (87465). Requires compliance review before any form of medication identification is captured. |
| Medication dosage | Same — 87465 MAR territory. Intentionally absent. |
| Resident age, sex, admission date | These are resident record fields (87506) that belong in the Resident entity or a separate clinical record — not in the operational shift log. Adding to CareLogEntry would create confusion about record purpose. |
| Physician name / physician findings | 87211 requires these in a formal incident report. alh-tracker should not capture them — doing so implies it is an incident reporting system. |
| Formal "disposition" field on incidents | Same — 87211 incident report territory. |

#### Fields or policies requiring counsel/design partner validation before task 0005 (data model finalization)

| Item | What needs resolution |
|---|---|
| Retention period enforcement | Define the retention policy (minimum duration per record type) and whether enforcement is the vendor's responsibility or the facility's. Must be in ToS and data model before commercial launch. |
| Account closure behavior | Define what happens to all record types when a Facility account closes. Are records deleted, exported to the operator, held for a defined period, or held indefinitely? |
| Caregiver account termination | When a User account is deactivated, their action records must remain in the AuditTrail. Clarify whether the User entity (identity) must also be retained or may be anonymized. |
| 87465 medication record applicability | Counsel must determine whether ObservedCareTask records constitute medication records. This affects both retention policy and whether a HIPAA BAA is required. |
| 87506 resident record applicability | Counsel must determine whether CareLogEntry records constitute resident records. This affects retention period, confidentiality obligations, and account closure behavior. |

---

### 5. Product Boundary Implications

> PRELIMINARY RESEARCH — PENDING COUNSEL REVIEW

#### Terms and phrases to avoid in UI and marketing copy

The following extend the list already in `compliance_notes.md`. These are additional terms identified through the regulatory mapping above.

| Term to avoid | Why |
|---|---|
| "Incident Report" | Implies 87211 compliance; this is a shift log entry, not a CDSS incident report |
| "Incident Record" | Same — implies regulatory record status |
| "Reportable Incident" | Implies the product knows what is reportable under 87211; it does not |
| "Medication Record" | Implies 87465 compliance; the product explicitly does not provide medication records |
| "Medication Log" or "Med Log" | Same |
| "Med Pass Record" | Same |
| "Medication Administration" | Implies the product records actual administration, not caregiver observation |
| "Required Documentation" | Implies the product satisfies a regulatory documentation requirement |
| "Complete Record" | Implies 87506 completeness; the product does not provide complete resident records |
| "Official Record" | Implies legal or regulatory authority |
| "Resident Record" | Unless specifically defined as a non-regulatory operational record in ToS; avoid in product UI |
| "Compliant" (any variant) | No compliance claim of any kind without counsel review |
| "Title 22 documentation" | Implies the product provides documentation required by Title 22 |
| "CDSS documentation" | Same |
| "Required care record" | Implies legal sufficiency |

#### Required in-product disclosures (preliminary list — counsel must review)

These disclosures should appear in the ToS, and where noted, in the product UI at the relevant interaction point.

1. **General product disclaimer** (ToS and About/Help screen):
   > "alh-tracker is a care observation and shift log tool. It is not a compliance system, medication administration record (MAR), electronic MAR (eMAR), clinical documentation system, or official regulatory record. It does not satisfy documentation requirements under California Title 22 or any other law or regulation. Facilities remain responsible for maintaining all required records and fulfilling all reporting obligations."

2. **Incident log entry notice** (in-product, when caregiver logs an `incident` category entry):
   > "This note is for your internal shift log only. It does not satisfy any incident reporting requirement under Title 22 or applicable law. Contact your administrator immediately for required reporting procedures."

3. **Observed care task notice** (in-product, visible in the observed care task logging flow):
   > "Observed care tasks are caregiver observations only. They are not a medication administration record and do not satisfy medication documentation requirements under Title 22 or applicable law."

#### Vendor incident reporting obligation — preliminary answer

The preliminary desk research finding is that Section 87211 places incident reporting obligations on the **licensee** (the facility operator), not on vendors or contractors. The regulation identifies the licensee as the responsible reporting party and does not explicitly extend independent reporting obligations to software vendors.

**However:** This preliminary finding does not resolve the question. A vendor in possession of an incident record who knows the licensee has not fulfilled a mandatory reporting obligation may face risk under other legal theories not addressed in 87211 itself. This question must be answered by counsel before commercial launch. See Section 6 (Counsel Review Packet) for the specific question formulation.

**Interim product posture:** Until counsel answers this question, alh-tracker should: (a) include the in-product incident notice described above; (b) not provide any feature that substitutes for or implies compliance with the 87211 reporting workflow; (c) not store incident records in any way that could create an inference that the vendor reviewed and assessed the incident.

---

### 6. Counsel Review Packet

This section is formatted for direct use in briefing compliance/privacy counsel.

#### Specific questions for counsel — in priority order

**Priority 1 — Must be answered before commercial launch**

1. Do alh-tracker CareLogEntry records (care log entries created by caregivers during shifts) constitute "resident records" under Title 22, § 87506? If so:
   - Does the 3-year post-service retention requirement apply to the software vendor?
   - What are the vendor's confidentiality obligations for these records?
   - What must the Terms of Service specify about record ownership, retention, and return/deletion on account termination?

2. Do alh-tracker ObservedCareTask records (caregiver observations of medication-related care events, without dosage or medication name) constitute "medication records" under Title 22, § 87465? If so:
   - Does the 1-year retention requirement apply to the vendor?
   - Does the product's storage of medication-adjacent observations require a HIPAA Business Associate Agreement?

3. Does logging an incident note in alh-tracker create any mandatory reporting obligation for the software vendor — independent of the facility licensee's obligations under § 87211? Under what circumstances, if any, would a vendor's possession of an incident record create legal or regulatory exposure if the licensee has not filed a required report?

4. What are the vendor's obligations when a facility account closes — with respect to retention, destruction, export, and notice of all record categories (care logs, audit trail, user accounts, resident records)?

**Priority 2 — Must be answered before task 0005 (data model finalization)**

5. Does alh-tracker's User entity and AuditTrail constitute a "personnel record" under § 87411 or any related regulation? If so, what retention and purge obligations apply?

6. When a caregiver's User account is deactivated (employment ends), must alh-tracker retain the User identity record linked to their historical AuditTrail entries — or may those entries be anonymized?

7. Does the product's Terms of Service need to include a specific data processing agreement or Business Associate Agreement template for California RCFE operators? If yes, what must it include?

**Priority 3 — Must be answered before Phase 3 (MAR-adjacent workflow consideration)**

8. Under what conditions, if any, could alh-tracker add medication name and dosage fields to the observed care task model without the product becoming a medication administration record system requiring separate regulatory treatment?

9. What product design constraints (UI language, data model scope, disclaimer language) would allow alh-tracker to move toward stronger RCFE documentation support without triggering MAR/eMAR classification or clinical documentation obligations?

#### Documents counsel should review before answering

- This task document (full Outcome section)
- `compliance_notes.md` (current version, post-task-0004 update)
- The ToS draft (not yet written — needs to be produced before counsel review)
- alh-tracker data model (`data_model.md`) — specifically the CareLogEntry, ObservedCareTask, AuditTrail, and Resident entities
- The in-product disclosure text drafted in Section 5 above

#### Decisions that cannot close without counsel

| Decision | Blocked by |
|---|---|
| Retention period policy for care log records | Questions 1 and 2 |
| Account closure behavior and record disposition | Question 4 |
| HIPAA BAA posture | Question 2 (medication records) and Question 7 |
| Incident logging UI language (final approved text) | Question 3 |
| Whether the data model can add medication name/dosage in future | Question 8 |
| Terms of Service — data handling and record ownership provisions | Questions 1, 4, and 7 |
| Commercial launch readiness sign-off | All Priority 1 questions |

---

### 7. Acceptance Criteria Status

| Criterion | Status |
|---|---|
| 1. Documented list of Title 22 documentation categories relevant to MVP log categories | ✅ Complete — Section 3 (§ 87506, 87211, 87465, 87411 all mapped) |
| 2. For each category: what Title 22 requires and data model compatibility assessment | ✅ Complete — Section 3, sub-tables for each section |
| 3. Language to avoid in product UI | ✅ Complete — Section 5, extended terms list + required disclosures |
| 4. Data model fields/constraints to preserve for future compliance path | ✅ Complete — Section 4, preserve/omit/validate tables |
| 5. Vendor incident reporting obligation answer | ⚠️ Preliminary only — desk research suggests obligation rests with licensee; counsel must confirm (Section 5, Question 3) |
| 6. Counsel sign-off | ❌ Not yet — Section 6 counsel packet is ready to route |
| 7. `compliance_notes.md` updated with confirmed findings | ⚠️ Updated with preliminary research label; final update pending counsel confirmation |

---

**Remaining to close this task:**
- [ ] Route `0004-counsel-handoff-packet.md` plus supporting documents (compliance_notes.md, data_model.md, task 0004 Outcome) to Compliance / Privacy Counsel
- [ ] Receive counsel answers to Priority 1 and Priority 2 questions
- [ ] Update `compliance_notes.md` with counsel-confirmed findings (remove preliminary labels where confirmed)
- [ ] Confirm or revise vendor incident reporting obligation answer based on counsel response
- [ ] Confirm or revise HIPAA BAA posture based on counsel response
- [ ] Remove resolved open questions from `ai_memory.md`
- [ ] Confirm task 0005 (data model finalization) may proceed with retention policy defined

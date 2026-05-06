# alh-tracker — Compliance Notes

This file documents the compliance and legal posture for alh-tracker. It is a product and design reference, not legal advice. Qualified counsel should review final workflows, data handling practices, consent language, Terms of Service, and any launch-blocking compliance decisions before they are finalized.

---

## What alh-tracker Is and Is Not

### What it is (MVP)

- A shift log and handoff tool for small RCFE operators.
- A care observation record system: who did what, when, for whom, in which shift.
- An operational productivity tool for caregivers, med techs, house managers, and owners.
- A product designed to not block a future path toward stronger documentation or MAR-adjacent workflows.

### What it is not (MVP)

- A medication administration record (MAR) or electronic MAR (eMAR) system.
- A clinical monitoring or clinical decision support system.
- A diagnosis, risk detection, or medical advice product.
- A regulatory compliance system or official RCFE documentation system under Title 22.
- A certified HIPAA Business Associate — BAA posture is an open question (see below).

This distinction must appear in the Terms of Service, product marketing copy, and where appropriate in-app language, before any facility uses the product with real resident data.

---

## California RCFE / Title 22 Context

California RCFE facilities are licensed and regulated by the California Department of Social Services (CDSS) under Title 22 of the California Code of Regulations (Division 6, Chapter 8).

**This section identifies relevant Title 22 areas for design awareness only. It does not interpret legal requirements. A qualified regulatory or legal reviewer must confirm applicability and scope before any compliance claims are made. See task 0004.**

### Relevant Documentation Categories

| Area | Relevance to alh-tracker |
|---|---|
| Incident reporting | RCFE operators must report certain incidents (falls, injuries, hospitalizations) to CDSS within defined timeframes. Logging an incident in alh-tracker does not satisfy CDSS incident reporting requirements. In-app language must not imply that it does. |
| Resident records | Title 22 specifies content and retention requirements for resident health and service records. alh-tracker care logs are not a substitute for required resident records. |
| Medication management | Title 22 has specific requirements for medication assistance and administration documentation. Observed care tasks in alh-tracker do not satisfy these requirements. This boundary must be explicit in the ToS and in-app UI. |
| Staffing and shift documentation | Shift logs have implications for CDSS compliance. alh-tracker shift logs may serve as useful supporting documentation but are not a substitute for any required staffing records. |

### Design Language Guidance

Do not use the following words or phrases in the product UI or marketing without counsel review and confirmed accuracy:

- "Compliant," "CDSS-compliant," "Title 22 compliant"
- "Regulatory record" or "official documentation"
- "Required documentation"
- "CDSS-approved"
- "Clinical record"

---

## Medication Boundary Language

The following language (or equivalent reviewed by counsel) should appear in the Terms of Service and where appropriate in the product UI:

> alh-tracker is a care observation and shift log tool. Observed care tasks, including medication-related observations, are caregiver observations only. They do not constitute a medication administration record (MAR), an electronic MAR (eMAR), or a clinical documentation system. alh-tracker does not provide dose validation, prescribing guidance, drug interaction checking, or medication safety assurance. Facilities remain responsible for maintaining any medication administration records required by applicable law or regulation.

---

## HIPAA Posture

Many small RCFE and adult family home operators are not themselves HIPAA-covered entities. However:

- If any residents receive Medicare or Medicaid, the facility may have compliance obligations that flow to software vendors handling their data.
- The product stores health-related information about identified individuals.
- A Business Associate Agreement (BAA) posture must be determined before commercial launch.
- This is an open question — see `ai_memory.md`.

Do not make HIPAA claims (positive or negative) in product marketing or ToS without counsel confirmation.

---

## Data Handling Posture

| Practice | Status |
|---|---|
| Audit trail on all care log entries | Required from day one — non-negotiable |
| Role-based access control | Required from day one |
| Edit history preserved in AuditTrail | Required from day one — AuditTrail is append-only |
| Resident care data not sent to ad/analytics platforms | Required — no exceptions |
| Resident/family sharing requires explicit consent | Required — even though the family portal is deferred |
| Data boundary between alh-tracker and AssistedLivingHelp | Required — resident care data must not flow to the placement side |
| HIPAA BAA posture | Open — must be resolved before commercial launch |
| Retention policy for resident care records | Open — must be defined before launch (task 0004 / counsel) |

---

## Privacy Language (Minimum Before Launch)

The following practices must be operational before any real resident data is stored under a commercial relationship:

- Notice at collection: what data is collected, why, and how it is used.
- Facility operator acknowledgment: resident data is tied to the specific facility's account. It is not pooled, aggregated, or used to train models without explicit consent.
- Account termination policy: what happens to resident care records if the facility cancels the service.
- California privacy law (CPPA/CCPA): if operators or family contacts are California residents, consumer rights handling (access, deletion, portability) must be operational at or before commercial launch.

---

## Open Compliance Questions

See `ai_memory.md` for the working list of unresolved items. Key items requiring resolution before commercial launch:

- HIPAA BAA posture for RCFE operators whose residents may be Medicare/Medicaid beneficiaries.
- Whether incident/fall log entries create any mandatory reporting obligations for the product vendor (preliminary desk research: obligation appears to rest with licensee; counsel must confirm — see task 0004 Section 6, Question 3).
- Counsel review and approval of Terms of Service and medication boundary language before any resident data is stored.
- Retention and deletion policy for resident care records — specifically: whether CareLogEntry and ObservedCareTask records constitute "resident records" (§ 87506, 3-year retention) or "medication records" (§ 87465, 1-year retention), and what the vendor's obligations are in each case.
- Account closure behavior: what happens to all record categories when a facility account closes.

---

## Title 22 Preliminary Research Summary

> **PRELIMINARY RESEARCH — NOT LEGAL ADVICE — PENDING COUNSEL REVIEW**
> This section was produced by desk research under task 0004 and has not been reviewed by qualified California compliance/privacy counsel. Do not treat any finding below as authoritative. All items are pending counsel confirmation before they are used in product decisions, ToS language, or marketing copy.

### Sections Researched

| Section | Topic | Key Finding (Preliminary) |
|---|---|---|
| § 87506 | Resident Records | Separate, current, complete record required per resident. Includes medical assessments, mental/social condition documentation, medication records (current meds and PRN orders), records of illness/injury affecting function. Retention: **3 years** post-service. Confidential; accessible to licensing agency. |
| § 87211 | Incident Reporting | Licensee must report defined incident categories to CDSS, Ombudsman, law enforcement, and/or family contacts within defined timeframes (2 hours to 7 days depending on severity). Written format with specified fields (resident name/age/sex/admission date, nature of event, physician findings, disposition). No specific state form mandated; no explicit vendor reporting obligation in regulation text. |
| § 87465 | Medication Management | Staff may assist with resident self-administration only (not administer). Medication assistance must be documented: date, time, dosage, resident response. Retention: **1 year** (records), **3 years** (destruction records). No separate MAR form explicitly mandated, but required content is specific. |
| § 87411 | Personnel Records | Training documentation, LIC 500 (Personnel Report-Roster), LIC 508 (Criminal Record Statement) required. No explicit shift-schedule or duty-record requirement in § 87411 itself. |

### Data Model Findings (Preliminary)

**Preserve from day one (already in current model — rationale confirmed by research):**
- `logged_at` and `created_at` timestamps on CareLogEntry (timeliness of observation matters in any care record context)
- `created_by` user reference on all record types (caregiver identity accountability)
- Soft-delete (`is_active`) on Resident — hard-deleting resident records would conflict with any retention obligation
- Append-only AuditTrail with `previous_value` JSON snapshots — required pattern for any data subject to regulatory review

**Intentional omissions confirmed correct:**
- Medication name / drug name: must NOT be added to ObservedCareTask without compliance review; adding it approaches MAR territory (§ 87465)
- Medication dosage: same — intentional absence protects the non-MAR boundary
- Physician name / findings: must NOT be added to incident log entries; implies formal incident report (§ 87211) status

**Gaps requiring counsel resolution before task 0005 (data model finalization):**
- Retention period policy: not yet defined in data model; must specify minimum retention per record type
- Account closure behavior: undefined; what happens to all records when a facility account closes
- Caregiver account termination: when a User is deactivated, must identity be retained in AuditTrail or may it be anonymized

### Incident Logging — Preliminary Risk Assessment

The `incident` log category is the highest-risk category from a regulatory misunderstanding perspective. An operator who logs an incident in alh-tracker may believe they have satisfied § 87211 reporting requirements. They have not. The in-product UI must include a plain-language notice at the point of logging an incident entry (see task 0004, Section 5 for approved notice text — pending counsel review).

### Observed Care Task — Preliminary Risk Assessment

The `observed_care_task` category is high-risk from a MAR/eMAR misrepresentation perspective. The current model captures date, time, status, and optional note — but not dosage, medication name, or "response to treatment" in the § 87465 sense. This gap is intentional and protective. The product must not imply that observed care task records satisfy § 87465 documentation requirements.

### Extended Language Avoidance List

In addition to the list in the Design Language Guidance section above, do not use in UI or marketing copy:

- "Incident Report" or "Incident Record" (implies § 87211 compliance)
- "Reportable Incident" (implies the product determines reportability)
- "Medication Record," "Med Log," "Med Pass Record," or "Medication Administration" (implies § 87465 MAR compliance)
- "Required Documentation" or "Required Record" (implies legal sufficiency)
- "Complete Record" or "Official Record" (implies § 87506 completeness)
- "Resident Record" in a regulatory sense (implies § 87506 status)
- "Title 22 documentation" or "CDSS documentation" (implies regulatory record status)

Preferred product language:
- "Shift log entry" or "care observation" (not "record" or "documentation")
- "Incident note" (not "incident report")
- "Observed care task note" (not "medication record" or "med log")
- "Handoff summary" (not "official handoff" or "required handoff document")

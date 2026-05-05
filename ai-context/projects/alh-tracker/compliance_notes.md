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
- Exact Title 22 documentation categories that affect MVP data model design and retention policy (task 0004).
- Whether incident/fall log entries create any mandatory reporting obligations for the product vendor.
- Counsel review and approval of Terms of Service and medication boundary language before any resident data is stored.
- Retention and deletion policy for resident care records.

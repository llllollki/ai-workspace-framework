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

- [ ] Identify relevant Title 22 sections for RCFE operations documentation (resident records — Section 87506, incident reporting — Section 87211, medication management — Section 87465, staffing — Section 87411)
- [ ] Map alh-tracker log categories to relevant Title 22 sections
- [ ] For each mapped category: document the regulatory requirement, retention period, and data model compatibility assessment
- [ ] Identify UI and marketing language to avoid (see initial list in `compliance_notes.md`)
- [ ] Identify data model constraints: fields that must exist, retention periods to plan for, soft-delete requirements
- [ ] Answer the incident reporting obligation question for the product vendor
- [ ] Route findings to Compliance / Privacy Counsel for review and sign-off
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

<!-- To be filled when the task is completed. -->

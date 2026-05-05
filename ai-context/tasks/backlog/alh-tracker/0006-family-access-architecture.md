# Task 0006 — Family Access Architecture

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Technical Architect
**Reviewers:** Product / Program Lead, Compliance / Privacy Counsel

---

## Goal

Make the deferred-but-architectural decision about how family members will eventually access resident care information, and encode the necessary data model stubs before MVP implementation begins.

The family portal is not an MVP feature. However, building the MVP data model without this consideration risks a significant schema rewrite when family access is added in Phase 2.

---

## Acceptance Criteria

1. A documented model for resident-family association: what entity links a resident to a family member or authorized contact.
2. A documented consent model: who grants consent (operator, resident, or both), what categories of data are shared, how consent is recorded, and how it is revoked.
3. A documented access scope: what can a family member see — read-only summary, real-time log, or selected categories only.
4. A documented data handling model: does family access use the same database, a derived view, or a filtered summary?
5. A documented note on resident autonomy: how the model handles cases where a competent resident may not want family to see all care notes.
6. Data model stubs present in the MVP schema (even if tables are empty at launch) so the main schema does not require structural changes when Phase 2 begins.
7. Compliance / Privacy Counsel review of the consent model before any family-facing data access is built.
8. `data_model.md` updated with finalized family access stubs.
9. `compliance_notes.md` updated with family consent posture.

---

## Plan

- [ ] Review the current family access stubs in `data_model.md` (ResidentContact, FamilyAccessConsent)
- [ ] Research comparable family access models in elder care and healthcare apps (how do apps like CareLinx, Carely, or similar handle this?)
- [ ] Define the resident-family association entity: fields, relationship types, authorization levels
- [ ] Define the consent record: grantor, scope (which log categories), consent timestamp, revocation handling
- [ ] Define the access scope: is family access always read-only? Full shift log, daily summary, or specific category visibility only?
- [ ] Define the data handling model: same database with row-level access control, or a separate summary layer?
- [ ] Define how resident autonomy is respected: can a competent resident restrict family access?
- [ ] Define stub migration plan: which fields must exist in the MVP schema today?
- [ ] Compliance / Privacy Counsel review of the consent model
- [ ] Update `data_model.md` with finalized stubs
- [ ] Update `compliance_notes.md` with family consent posture
- [ ] Update `ai_memory.md`: remove resolved open questions

---

## Notes

- Family access is a significant privacy and consent surface. Even a read-only summary of care observations shared with a third party (even a family member) requires explicit consent.
- California privacy law (CPPA/CCPA) may apply. If family members are California residents whose data is collected or processed, privacy disclosures and rights handling must be considered.
- Do not assume "family" equals legal authority over the resident. A competent RCFE resident has autonomy over their own care information. Consent models that ignore resident autonomy may create liability.
- The design partner relationship (task 0002) could surface whether and how current operators share care information with families today — a useful baseline for this design.
- Even if the family portal ships as Phase 2, the consent record must be designed at MVP time. Retroactively obtaining consent from all residents and families after launch is operationally difficult.

---

## Outcome

<!-- To be filled when the task is completed. -->

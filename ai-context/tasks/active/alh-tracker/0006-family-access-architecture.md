# Task 0006 — Family Access Architecture

**Project:** alh-tracker
**Status:** active
**Created:** 2026-05-05
**Activated:** 2026-05-09
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

- [x] Review the current family access stubs in `data_model.md` (ResidentContact, FamilyAccessConsent)
- [x] Define the resident-family association entity: fields, relationship types, authorization levels
- [x] Define the consent record: grantor, scope (which log categories), consent timestamp, revocation handling
- [x] Define the access scope: is family access always read-only? Full shift log, daily summary, or specific category visibility only?
- [x] Define the data handling model: same database with row-level access control, or a separate summary layer?
- [x] Define how resident autonomy is respected: can a competent resident restrict family access?
- [x] Define stub migration plan: which fields must exist in the MVP schema today?
- [x] Update `data_model.md` with finalized stubs
- [x] Update `compliance_notes.md` with family consent posture (preliminary — pending counsel review)
- [x] Update `ai_memory.md`: remove resolved open questions
- [x] Record durable architectural decisions in ADR 0004
- [ ] Compliance / Privacy Counsel review of the consent model before any family-facing feature is built
- [ ] Validate family-sharing expectations with design partner (task 0002): how do current operators share care information with families today?

---

## Notes

- Family access is a significant privacy and consent surface. Even a read-only summary of care observations shared with a third party (even a family member) requires explicit consent.
- California privacy law (CPPA/CCPA) may apply. If family members are California residents whose data is collected or processed, privacy disclosures and rights handling must be considered.
- Do not assume "family" equals legal authority over the resident. A competent RCFE resident has autonomy over their own care information. Consent models that ignore resident autonomy may create liability.
- The design partner relationship (task 0002) could surface whether and how current operators share care information with families today — a useful baseline for this design.
- Even if the family portal ships as Phase 2, the consent record must be designed at MVP time. Retroactively obtaining consent from all residents and families after launch is operationally difficult.

---

## Planning Notes

**Activated 2026-05-09.** This task is not blocked by design partner or counsel for the architectural decision phase. The architecture can be locked now as a conservative, consent-first model. Counsel review is required before any family-facing feature is built in Phase 2.

**Design direction confirmed at activation:**
- Family access is structurally deferred from MVP; stubs exist in schema, tables are empty.
- Conservative by default: read-only, summary-level, explicit dual authorization (operator + resident autonomy noted), category-scoped.
- Same primary database with strict row-level authorization — no derived summary layer at this stage.
- Family contacts are not Users — they authenticate separately via a future portal.

---

## Outcome

### 1. Resident-Family Association Model

The **ResidentContact** entity links a named external contact to a specific resident at a specific facility. A ResidentContact represents a person — not an access grant. Having a ResidentContact record does not automatically authorize that person to view care data.

Authorization to view care data is a separate, explicit step documented in the **FamilyAccessConsent** entity. The ResidentContact is the identity record; FamilyAccessConsent is the access grant.

This separation matters because:
- A family member may be a known emergency contact but not authorized to view care logs.
- Authorization can be granted, scoped, and revoked independently of whether the contact identity is known.
- Multiple contacts may share one level of authorization, or each may have a different scope.

#### Contact types

| Type | Description |
|---|---|
| `family_member` | Son, daughter, spouse, sibling — common case |
| `legal_guardian` | Legally appointed guardian; may have formal authority over care decisions |
| `power_of_attorney` | Holds healthcare or durable POA — distinct from family relationship |
| `emergency_contact` | Emergency contact only; not necessarily a family member or authorized viewer |
| `other` | Any contact relationship not captured by the above |

Contact type does not automatically determine access level. A legal guardian receives no more access than a family member unless explicitly authorized via FamilyAccessConsent.

---

### 2. Consent Model

Family access to resident care data requires **dual acknowledgment** before any data is shared:

**Step 1 — Facility operator authorization (owner or admin):** The operator creates a FamilyAccessConsent record for a specific contact, resident, and scope. The operator is the data controller for the facility. Only an `owner` or `admin` role user may grant, modify, or revoke access. Caregivers cannot grant family access.

**Step 2 — Resident autonomy noted:** Before granting access, the operator should consider and document the resident's preferences. A competent RCFE resident has autonomy over their personal care information. The data model records whether the operator noted the resident's preference (`resident_autonomy_noted` field). The software cannot verify actual resident consent — that is the operator's responsibility — but it creates a record that the operator addressed the question.

**What happens when a resident declines:** If `resident_autonomy_noted = false` (operator recorded that the resident declined or restricted access), the system should surface a warning and require the operator to confirm they understand they are granting access against the resident's expressed preference. The system does not hard-block this action at MVP — that determination requires counsel guidance — but the divergence must be visible and logged.

**Revocation:** Either the operator or (in Phase 2) the resident themselves (if the portal supports it) can revoke access at any time. Revocation is recorded with a timestamp and user reference (`revoked_at`, `revoked_by`). Revocation is immediate — any active family portal session is invalidated on next request.

**Scope of consent:** Each FamilyAccessConsent specifies:
- Which log categories are shared (`category_scope` — JSON array of category enum values)
- What level of detail is shared (`access_level` — `summary` or `full_notes`)

---

### 3. Access Scope

**Family access is always read-only.** Family contacts cannot create, edit, or delete any care log entry, resident record, or facility record. This is a hard constraint — not configurable.

**Default access level: summary.** A family contact with `access_level = summary` sees a filtered, human-readable summary of the permitted log categories. They do not see raw caregiver notes. Examples:

| Raw caregiver note | Summary view |
|---|---|
| "Ate about half her breakfast; seemed tired, didn't want to talk" | "Had breakfast — partial" |
| "Refused morning meds again, pretty agitated this morning" | "Morning care task — not completed" |
| "Good walk in the garden, lifted spirits a lot" | "Activity completed" |

**Full notes access level.** A family contact with `access_level = full_notes` can see the raw caregiver note text. This requires explicit operator authorization and should be used sparingly. Full notes may contain caregiver language about resident behavior or health that is appropriate for care team context but not for family reading without context. Counsel must review the full notes access model before it is built.

**Category scope.** The operator specifies which log categories the family contact may see. Example scopes:
- `["meal", "activity"]` — can see meal and activity observations only
- `["meal", "hydration", "activity", "general"]` — broader but excludes pain/mood and incident notes
- `["meal", "hydration", "sleep", "pain_mood", "activity", "general"]` — all non-incident, non-medication categories
- Incident notes (`incident`) and observed care tasks (`observed_care_task`) should require explicit opt-in — they are not included in default scopes.

---

### 4. Data Handling Model

**Same primary database with row-level authorization. No separate summary layer at this stage.**

All family-accessible data lives in the same database as caregiver and owner data. Family portal queries are filtered at the query layer by:
1. Which residents the authenticated family contact has a valid, non-revoked FamilyAccessConsent for.
2. Which log categories are in that consent's `category_scope`.
3. Whether the content returned is the raw note or a summary (determined by `access_level`).

This approach is:
- Simpler to maintain — one source of truth
- Less risky than dual-write to a summary store — no sync lag or divergence
- Compatible with the existing data model — no structural changes needed beyond the stubs

The summary generation (raw note → human-readable summary) is a read-time transformation. For Phase 2 MVP, this may be a simple rule-based summary (e.g., status label only, no note text). AI-generated summaries are explicitly deferred — they introduce new privacy and accuracy risks and require separate counsel review.

**Family contact authentication** is separate from the facility-facing User entity. Family contacts do not have User records. In Phase 2, family portal authentication will use a separate mechanism (e.g., email magic link, dedicated family portal login). This avoids mixing caregiver/owner auth with family access auth in the same session management system.

**Audit trail.** All family portal access events must be recorded in the AuditTrail: which contact accessed which resident's records, at what time, and what category scope was active. This is required for accountability and must be implemented in Phase 2 before the first family portal user is given access.

---

### 5. Resident Autonomy

RCFE residents, unless adjudicated incompetent, have autonomy over their personal information. This is both an ethical obligation and a potential legal one (California privacy law, HIPAA implications depending on resident's coverage status).

**The product's posture:**
- Assume resident autonomy is present unless the operator has documented otherwise (e.g., the resident has a legal guardian with full authority).
- The `resident_autonomy_noted` field on FamilyAccessConsent records whether the operator considered this before granting access. It is the operator's responsibility to determine and honor the resident's preferences — the software records that the operator addressed the question.
- The product must not represent itself as the arbiter of whether a resident's information can be shared. That determination is the operator's (and potentially counsel's) responsibility.
- In Phase 2, the family portal UI should include a visible resident consent context: "The facility operator has indicated [resident name] has been informed of this access" or similar. The exact language requires counsel review.

**Non-negotiable UI constraint:** The family portal must never display a resident's identity (full name, room, photo) in any context that the resident has not consented to or that the operator has not explicitly authorized. Default behavior is to use display-safe naming (first name only, or "Resident A") until explicit operator configuration is confirmed.

---

### 6. What This Architecture Does Not Resolve

The following questions require counsel review and/or design partner input before the Phase 2 family portal can be built:

| Question | Why it is open |
|---|---|
| Does the consent model satisfy California privacy law (CPPA/CCPA) for family contacts who are California residents? | Counsel must confirm what rights handling is required for family contacts as data subjects |
| What notice must be given to residents about family access at account creation? | Requires counsel guidance on consent and notice language |
| Can a resident actively revoke a family contact's access through the product — or only the operator can? | Resident-side access control requires Phase 2 design; counsel may require it |
| What happens to family access grants when a resident is transferred or deceased? | Revocation-at-transfer/death policy is undefined; counsel must confirm obligations |
| Does `full_notes` access require separate consent language or a higher authorization threshold? | Counsel must confirm before full-notes access is built |
| Does sharing incident notes with family create any independent regulatory or legal obligation for the vendor? | Incident notes are high-risk; same counsel question as task 0004 Question 3 |

---

### 7. Acceptance Criteria Status

| Criterion | Status |
|---|---|
| 1. Resident-family association model | ✅ Complete — Section 1; ResidentContact updated in data_model.md |
| 2. Consent model | ✅ Complete — Section 2; FamilyAccessConsent updated in data_model.md |
| 3. Access scope | ✅ Complete — Section 3; read-only, summary default, category-scoped |
| 4. Data handling model | ✅ Complete — Section 4; same database, row-level authorization |
| 5. Resident autonomy | ✅ Complete — Section 5; `resident_autonomy_noted` field; operator responsibility |
| 6. Data model stubs | ✅ Complete — data_model.md updated (2026-05-09) |
| 7. Counsel review | ❌ Not yet — required before Phase 2 family portal is built |
| 8. data_model.md updated | ✅ Complete |
| 9. compliance_notes.md updated | ✅ Complete — preliminary posture section added, labeled pending counsel review |

---

**Remaining to close this task:**
- [ ] Compliance / Privacy Counsel review of the consent model (Section 2) and resident autonomy posture (Section 5) before Phase 2 family portal implementation begins
- [ ] Validate design assumptions with design partner site visit: how do current operators share care information with families today? What do families expect to see?
- [ ] Counsel review of `full_notes` access level before it is built
- [ ] Counsel guidance on resident-side revocation requirements
- [ ] Confirm notice and disclosure language for Phase 2 family portal (required before launch)

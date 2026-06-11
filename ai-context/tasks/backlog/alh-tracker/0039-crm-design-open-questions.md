# Task 0039 — CRM Design and Open Questions

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-16
**Owner role:** Product / Program Lead
**Reviewers:** Technical Architect

---

## Goal

Resolve the open questions identified in ADR 0005 and `ai_memory.md` that must be answered before CRM design or implementation work begins. The Internal CRM is one of three product surfaces (see ADR 0005) — a desktop-only tool for ALH Tracker business/admin staff to manage commercial relationships, onboarding, subscriptions, and communications. None of these questions can be answered without explicit product decisions from the owner.

---

## Acceptance Criteria

1. All nine open questions listed below are answered and documented.
2. The CRM MVP scope is defined: what feature set ships first, in what order, for whom.
3. Entity schemas are defined for the CRM's core entities (CRMCustomer, CRMContact, OnboardingRecord, SubscriptionRecord, AdminNote, CommunicationLog) — at minimum, field names, types, and key constraints.
4. The CRM-to-tracker provisioning handshake mechanism is specified (conceptual design, not implementation).
5. The CRM user authentication model is selected.
6. Durable decisions recorded as ADR(s) in `decisions\`.

---

## Plan

- [ ] Answer Q1: Allowable resident count distinction — licensed capacity vs. subscription limit vs. active count. Are these one, two, or three separate tracked fields?
- [ ] Answer Q2: App delivery model — native iOS/Android app store, PWA with install prompt, or web app with mobile redirect? (This also unblocks the family app authentication design and onboarding instructions.)
- [ ] Answer Q3: Onboarding ownership split — which steps are owned by internal ALH Tracker staff vs. facility owner self-serve? Which steps are tracked in CRM vs. tracker app?
- [ ] Answer Q4: Payment provider selection — which provider? What metadata is stored in CRM vs. held at the provider? (Hard constraint: raw card/bank details must never be stored in the CRM.)
- [ ] Answer Q5: CRM roles — what roles exist within the internal CRM (e.g., sales, onboarding, support, billing, admin)? What access does each have?
- [ ] Answer Q6: CRM user authentication model — what mechanism do ALH Tracker business/admin staff use to authenticate to the CRM?
- [ ] Answer Q7: CRM-to-tracker provisioning handshake — what is the exact mechanism by which a CRM-provisioned facility account becomes a usable tracker app account? (Principle already decided in ADR 0005: opaque reference only, no care data flows to CRM.)
- [ ] Answer Q8: CRM communications log definition — what constitutes a "communication" in the CRM? Email thread, call log, in-app message, or multiple channels?
- [ ] Answer Q9: Desktop access policy for facility owners — hard block or soft redirect for desktop access to the facility tracker app? Does any facility owner/admin workflow require desktop access?
- [ ] Define CRM MVP scope: which feature areas ship first?
- [ ] Define entity schemas for core CRM entities
- [ ] Document provisioning handshake design
- [ ] Record durable decisions as ADR(s) in `decisions\`

---

## Notes

- Nine open questions from ADR 0005 (2026-05-16) must be resolved before any CRM design or implementation work begins. These questions block commercial operations entirely: without a CRM, onboarding cannot be managed at scale, subscriptions cannot be tracked, and the ALH partner pilot cannot operate beyond manual workarounds.
- Question Q2 (app delivery model) also unblocks: (a) the onboarding instructions CRM staff send to facility owners, (b) the family app authentication design (ADR 0004 open question), and (c) the PWA manifest and install UX work. It should be resolved as soon as possible even if the full CRM design is deferred.
- The CRM does NOT expose resident wellness/care logs — that boundary is a hard constraint per ADR 0005 and ADR 0001. Any entity schema defined in this task must respect that constraint.
- Internal support staff access to resident care data through the CRM must not be enabled by default. Any future support-access policy requires legal review and a formal ADR.

---

## Open Questions (from ADR 0005 and ai_memory.md)

1. Allowable resident count: licensed capacity vs. subscription limit vs. active count?
2. App delivery model: native app store, PWA, or web + redirect?
3. Onboarding ownership split: staff vs. self-serve, CRM vs. tracker app tracking?
4. Payment provider: which one? What metadata in CRM vs. at provider?
5. CRM roles: what roles, what access?
6. CRM user authentication model: what mechanism?
7. CRM-to-tracker provisioning handshake: what mechanism (opaque reference; no care data)?
8. CRM communications log: what counts as a "communication"?
9. Desktop access policy for facility owners: hard block or soft redirect?

---

## Dependencies

- **Informs:** CRM implementation (no task number yet — implementation not approved).
- **Q2 also informs:** Family app authentication design (ADR 0004 open question), PWA manifest and install UX.
- **Informs:** Facility owner provisioning workflow operational runbook (no task number yet).

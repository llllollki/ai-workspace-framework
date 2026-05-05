# Task 0007 — Logging UX Principles and Prototype

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Product / Program Lead
**Reviewers:** Operations / Concierge Workflow Lead, Developer

---

## Goal

Validate the logging UX principles in practice by building a low-fidelity prototype and testing it with real caregivers at the design partner facility.

The under-10-second, 1–2-tap logging target is only meaningful when tested against real caregivers performing real logging scenarios on real devices.

---

## Acceptance Criteria

1. A documented interaction model for all core logging scenarios:
   - Normal routine event (one tap)
   - Exception routine event (status + optional quick reason + optional note)
   - Batch logging ("all residents did X" with exceptions)
   - Observed care task (deliberate flow)
   - Undo/correction of a logged entry
   - Offline state indicator behavior
   - Shift close and handoff generation flow
2. A low-fidelity prototype or clickable mockup covering the phone caregiver experience (the highest-priority device).
3. At least one test session with a real caregiver at the design partner facility.
4. Timing data for each logging scenario: was the 10-second target met?
5. Documented findings: what worked, what was confusing, and what should change.
6. Revised logging UX principles in `features.md` reflecting validated choices.

---

## Plan

Sequence dependency: task 0002 (design partner confirmed and site visit complete) must be done before this task can be tested.

- [ ] Review and finalize the logging UX principles in `features.md`
- [ ] Define the full interaction model for each logging scenario (see Acceptance Criteria above)
- [ ] Define the status button set per log category (not all statuses apply to all categories)
- [ ] Define the quick reason options per exception status (e.g., Low appetite / Nausea / Sleeping / Refused / Away for meals)
- [ ] Build a low-fidelity prototype: Figma mockup or a minimal HTML/JS prototype that runs on a phone browser
- [ ] Define the test protocol: which logging scenarios will the caregiver attempt, in what order?
- [ ] Run a test session at the design partner facility with at least two participants: one caregiver and one house manager or owner
- [ ] Observe and time each scenario — measure whether the 10-second target is achievable per scenario
- [ ] Specifically test: batch logging, undo/correction, observed care task flow, shift close flow
- [ ] Document findings
- [ ] Revise UX principles in `features.md` based on validated choices

---

## Notes

- Testing on a real phone in a real caregiver environment is the only reliable way to validate the 10-second target. Desktop prototypes will not surface the right friction points.
- The batch logging flow ("all residents ate breakfast") is high-value but risky — a careless batch can create inaccurate records for multiple residents simultaneously. Test this scenario with particular attention to how quickly caregivers notice and correct an accidental batch.
- The undo behavior must be tested explicitly. Caregivers will tap wrong. What happens next is a critical trust moment.
- If the design partner has a shared tablet, test both phone and tablet scenarios. Touch target sizing differs significantly.
- The observed care task flow should feel more deliberate than a routine event tap. Test whether this perceived friction is acceptable or whether it causes caregivers to rush through it.

---

## Outcome

<!-- To be filled when the task is completed. -->

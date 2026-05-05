# alh-tracker — Features and Product Capabilities

## MVP Scope

The MVP is a shift log and handoff tool for California RCFE operators. The goal is to replace the paper binder.

### Included in MVP

1. **Resident and routine setup** — Owner/admin adds residents and configures their routine schedule per shift period. Required before any logging can happen. Unglamorous but must work well — failed onboarding kills adoption before the first shift.

2. **Resident roster** — Active residents visible to caregivers per shift. Simple and scannable.

3. **Shift log** — Caregivers log routine events and ad-hoc observations for residents during their shift. Logging must take under 10 seconds per event.

4. **Handoff summary** — Auto-generated from shift log data. Exceptions (missed, refused, pain notes, incidents, follow-ups) surface first. Normal events are summarized by category, not listed individually. Caregivers do not write handoffs from scratch.

5. **Routine and event tracking** — Core log categories:
   - Meals (intake observation)
   - Hydration
   - Sleep note
   - Pain / mood / behavior note
   - Activity / exercise
   - General note
   - Observed care tasks (meds/supplements as care-task observations only — see boundary below)
   - Incidents / falls (when relevant to handoff)

6. **Thin owner/admin review** — Owner sees a day-level summary: shifts logged, exception count, open follow-up items. Ability to drill into a shift or resident. Polished analytics dashboard is phase 2.

7. **Audit trail from day one** — Every care log entry records who logged it, when, for which resident, and in which shift. Edits preserve the prior state via AuditTrail. Non-negotiable.

### Medication and Supplement Boundary

For MVP, medication and supplement items are treated only as observed care tasks:

- "Caregiver noted medications given this shift" → logged as a care task with status
- No dose tracking, no medication schedule management, no administration record (MAR)
- No drug interaction checking, prescribing guidance, or clinical monitoring
- No MAR/eMAR compliance claims

The system may evolve toward MAR-adjacent workflows in a later phase — only after compliance and legal review confirms a safe, appropriate path. See `compliance_notes.md`.

---

## Explicitly Deferred (Not MVP)

- Family portal / family-facing summary product
- Rich owner/admin analytics dashboard
- True MAR/eMAR compliance or pharmacy integration
- Clinical alerts, risk detection, or AI-generated clinical interpretation
- Diagnosis, medication safety guarantees, or clinical decision support
- Billing, payroll, or staffing workflows
- EHR integrations
- Wearable or device integrations
- Multi-state support (California only at MVP)

---

## Device Support

| Priority | Device | Primary use |
|---|---|---|
| 1 | Caregiver phone | Fastest shift logging |
| 2 | Shared tablet | Shift board, handoff review |
| 3 | Desktop | Owner/admin setup, reports, export |

All three device classes must be usable. Responsive web/PWA-first, offline-tolerant. See task 0008 for full device and offline behavior spec.

---

## Logging UX Principles

These principles govern every logging interaction in the product. The 10-second target is validated against real caregivers in real shifts — see task 0007.

- Routine event logging should take under 10 seconds, ideally 1–2 taps.
- Default to quick status buttons, not forms.
- Resident and shift context are pre-loaded — caregivers should not repeatedly select them.
- Common statuses: Done, Partial, Refused, Skipped, Needs Follow-up, Unknown, Not Applicable (use the appropriate subset per category).
- Notes are optional. Prompt for a note only on abnormal statuses.
- Normal events should be one tap where safe.
- Support batch logging where appropriate (e.g., "all residents ate breakfast" with exceptions noted).
- Observed care tasks should be slightly more deliberate than routine events — this is a product guard against accidental one-tap medication observations. Still simple, but not one tap.
- Provide a visible undo/correction path for one-tap actions.
- Show offline state visibly (e.g., "saved locally, will sync") — never silently lose work.
- Shift close and handoff generation must have a named, explicit flow.
- One-handed phone use must be considered in all touch target sizing.

### Example Logging Flow — Breakfast

Normal: Tap resident → Tap "Ate Well" → Done.

Exception: Tap "Partial" → Optional quick reason (Low appetite / Nausea / Sleeping / Refused / Away) → Optional note → Done.

### Handoff Auto-Generation

The handoff summary is generated from the shift log. Exceptions rise to the top automatically:

- Missed or refused events
- Pain notes
- Incidents or falls
- Follow-up items flagged during the shift
- Observed care tasks with non-Done status

Normal events are summarized by category (e.g., "All 8 residents — Breakfast: 7 Ate Well, 1 Partial — see follow-up").

Caregivers do not write the handoff from scratch.

---

## Recommended Implementation Phases

### Phase 0: Discovery and Setup (Before Any App Code)

- Lock business model and ALH relationship (task 0001)
- Find and engage first design partner (task 0002)
- Define shift model and caregiver authentication (task 0003)
- Conduct Title 22 documentation review (task 0004)
- Finalize MVP data model (task 0005)
- Resolve family access architecture stubs (task 0006)
- Define and validate logging UX with prototype (task 0007)
- Define device and offline behavior requirements (task 0008)

### Phase 1: MVP

- Resident and routine setup flow (owner/admin)
- Shift board with resident roster
- Routine event logging — normal and exception flows
- Observed care task logging
- Handoff summary auto-generation
- Shift close flow
- Thin owner/admin review
- Audit trail on all writes
- Responsive PWA with offline tolerance

### Phase 2: Visibility and Retention

- Family access portal (pending task 0006 architecture)
- Richer owner/admin analytics and export
- Follow-up resolution tracking
- Push/SMS notifications for follow-up items

### Phase 3: Compliance Path

- Evaluate MAR-adjacent workflow requirements
- Compliance/legal review before building
- Structured medication schedules and administration records (only if a compliant path is confirmed)
- Export formats aligned with RCFE documentation requirements

### Phase 4: Expansion

- Multi-state support
- Broader facility type support (adult family homes, board-and-care)
- EHR or pharmacy integration (only after compliance review)

# alh-tracker — User Flows

This file describes the primary user flows for alh-tracker at a task level. Screen-level UI design and component layout are separate concerns.

---

## Flow 1: Facility and Resident Setup (Owner / Admin)

**Actor:** Owner or admin
**Device:** Desktop or tablet

1. Owner creates a facility account (or is onboarded via ALH partner workflow).
2. Owner configures shift periods (e.g., Morning 7am–3pm, Evening 3pm–11pm, Night 11pm–7am). Whether periods are fixed or operator-configured is an open design question — see `ai_memory.md` and task 0003.
3. Owner adds active residents: display name and room number.
4. Owner configures each resident's routine: which event categories to track per shift period.
5. Owner creates caregiver and admin accounts and assigns roles.
6. Caregivers receive login credentials (or shared tablet PIN — see task 0003).

**Exit:** Caregivers can open a shift and begin logging.

---

## Flow 2: Starting a Shift (Caregiver / Med Tech)

**Actor:** Caregiver or med tech
**Device:** Phone or shared tablet

1. Caregiver logs in (individual account or shared tablet PIN).
2. Caregiver selects or confirms the current shift period (or the shift auto-detects based on time).
3. Caregiver sees the shift board: all active residents with their scheduled routines for this shift period.
4. Caregiver begins logging events.

---

## Flow 3: Logging a Routine Event — Normal Path

**Actor:** Caregiver
**Device:** Phone

1. Caregiver taps a resident on the shift board.
2. Caregiver sees the resident's scheduled routines for this shift.
3. Caregiver taps a routine item (e.g., Breakfast).
4. Caregiver taps a status button (e.g., "Ate Well" / "Done").
5. Entry is saved with timestamp, caregiver ID, shift ID, and resident ID.
6. UI returns to the resident routine list or the shift board.

**Target:** Under 10 seconds total.

---

## Flow 4: Logging a Routine Event — Exception Path

**Actor:** Caregiver
**Device:** Phone

1–3. Same as Flow 3 (normal path).
4. Caregiver taps an exception status (e.g., "Partial", "Refused", "Needs Follow-up").
5. UI presents optional quick reason buttons (e.g., Low appetite / Nausea / Sleeping / Refused / Away).
6. Caregiver optionally taps a quick reason.
7. Caregiver optionally adds a short free-text note.
8. Entry is saved. A follow-up flag may be auto-set depending on the status and category.
9. UI returns to the resident routine list or the shift board.

---

## Flow 5: Correcting a Logged Entry

**Actor:** Caregiver (within a time window) or admin (anytime)
**Device:** Any

1. Caregiver taps an already-logged event (or a brief undo toast appears immediately after logging).
2. UI shows the current logged status with a visible "Edit" or "Undo" option.
3. Caregiver changes the status or note.
4. System saves the corrected entry and writes an AuditTrail record preserving the previous value.
5. The original entry is not deleted — only the current value changes, and the history is preserved.

**Design note:** A quick undo action (e.g., a dismissible toast immediately after logging) prevents the need to hunt for the edit path in most correction cases.

---

## Flow 6: Logging an Observed Care Task

**Actor:** Caregiver or med tech
**Device:** Phone

1. Caregiver opens a resident's observed care task list.
2. Caregiver taps a task (e.g., "Morning Medications").
3. Caregiver selects a status (e.g., Done, Partial, Refused, Needs Follow-up).
4. UI prompts for a note — required or optional depending on status. Observed care tasks are slightly more deliberate than routine events: the note prompt is a product guard against casual one-tap medication observations.
5. Entry is saved as an ObservedCareTask linked to a CareLogEntry.

**Design note:** This flow is intentionally more deliberate than a routine event tap. The caregiver should feel they are making a meaningful record, not a reflex tap. Still simple — not a form.

---

## Flow 7: Batch Logging — Normal Path

**Actor:** Caregiver
**Device:** Phone or tablet

1. Caregiver selects a routine event category from the shift board (e.g., Breakfast).
2. Caregiver sees all residents scheduled for that routine in this shift period.
3. Caregiver taps "All Ate Well" (or equivalent batch action).
4. UI prompts: "Any exceptions?" Caregiver flags exceptions by tapping individual resident names.
5. Exceptions are logged individually via Flow 4.
6. Remaining residents are batch-logged as "Done".

**Design note:** Batch logging is high-value but carries a risk of creating inaccurate records if used carelessly. Test this flow specifically with real caregivers during task 0007.

---

## Flow 8: Closing a Shift and Generating the Handoff

**Actor:** Shift lead or house manager
**Device:** Tablet or phone

1. Shift lead taps "Close Shift" or "Generate Handoff".
2. System checks for any routines that have not been logged for active residents this shift.
3. If unresolved items exist, system prompts the shift lead to review or explicitly dismiss them.
4. System generates the handoff summary:
   - Exceptions surface first: refused events, pain notes, incidents, open follow-up items, observed care tasks with non-Done status.
   - Normal events are summarized by category (not individually listed).
5. Shift lead reviews the handoff summary.
6. Shift lead confirms and submits the handoff.
7. Handoff becomes visible to incoming shift caregivers.
8. Shift record is marked closed with a `closed_at` timestamp and `closed_by` user reference.

---

## Flow 9: Reviewing the Incoming Handoff

**Actor:** Incoming caregiver or house manager
**Device:** Tablet or phone

1. Incoming caregiver logs in (or opens the shared tablet).
2. System presents the latest closed handoff for their shift period.
3. Caregiver reviews exceptions and follow-up items.
4. Caregiver acknowledges the handoff (optional acknowledgment record — design decision pending).

---

## Flow 10: Owner / Admin Daily Review

**Actor:** Owner or admin
**Device:** Desktop or tablet

1. Owner opens the admin review view.
2. Owner sees a day-level summary: shifts logged, exception count, open follow-up items.
3. Owner can drill into a specific shift or a specific resident's log for the day.
4. Owner can view and export the audit trail for a date range.
5. Owner can review and resolve or escalate open follow-up items.

---

## Out of Scope for MVP

- Family portal or family-facing views (deferred — see task 0006 for architecture)
- External notifications to families (SMS/email)
- Clinical reporting formats
- MAR administration record review or verification

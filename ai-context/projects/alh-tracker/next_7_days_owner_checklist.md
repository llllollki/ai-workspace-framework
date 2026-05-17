# alh-tracker — Next 7 Days: Owner Action Checklist

**Created:** 2026-05-10
**Audience:** Product / Program Lead
**Purpose:** Operational execution guide for the next 7 days. Each item is a concrete human action with a specific source file, expected time, and a clear completion signal. This is not strategic guidance — that is in `phase_0_owner_action_packet.md`.

> Items are ordered by leverage: complete them top to bottom. Items 1 and 3 are the highest-leverage actions available right now.

---

## Day 1–2

### Item 1 — Populate the ALH warm contact list in the tracker

**Owner:** Product / Program Lead
**Time:** 2–4 hours
**Source file:** [design_partner_tracker.md](design_partner_tracker.md) — open Section A

**What to do:**
1. Open your ALH facility partner contact list or CRM.
2. Filter for: RCFE license type, Temecula / Murrieta / Menifee / SW Riverside County, capacity 6–20.
3. For each match, fill in one row in Section A of `design_partner_tracker.md`:
   - Facility name, City, Capacity, ALH tier (Starter/Growth/Concierge), Owner name and phone/email
   - Note any known disqualifiers (existing software, under license action, capacity < 6)
4. For any Section A facility that also appears in Section B or C, mark it as "ALH partner — Warm" in Section B/C and note the duplication.

**Completion signal:** Section A has at least 3 rows with a real owner name and contact method.

**Why this first:** The warm list is the fastest path to a committed design partner and the only way to find Priority 1 and 2 candidates. Public directory data (Sections B/C) yields only Priority 3 candidates. Nothing else opens without a committed partner.

---

### Item 2 — Verify CCLD capacity and license status for public-directory candidates

**Owner:** Product / Program Lead
**Time:** 1–2 hours (batch lookup)
**Source file:** [design_partner_tracker.md](design_partner_tracker.md) — Sections B and C

**What to do:**
1. Go to: **https://www.ccld.dss.ca.gov/carefacilitysearch/**
2. For each Section B/C row: search by facility name or address, confirm:
   - License status = Licensed (active)
   - Capacity (update the "Capacity" column in the tracker if different from directory data)
3. Delete any row where license status is not active.
4. Flag any row where confirmed capacity is fewer than 6 — these are disqualified.
5. If CCLD shows a facility at capacity 7–20 that is not currently in the tracker, add it.

**Completion signal:** Every Section B/C row has a confirmed CCLD status in the Disqualifiers column ("CCLD confirmed active — [date]") or has been removed.

**Note:** Third-party directory data (what Session 4 seeded) may be 6–18 months out of date. CCLD is the authoritative source. Do not send outreach to any facility until its license status is confirmed.

---

## Day 2–3

### Item 3 — Route the counsel packet

**Owner:** Product / Program Lead (routes); Compliance / Privacy Counsel (answers)
**Time:** 30–45 minutes to assemble and send
**Source files:**
- [0004-counsel-handoff-packet.md](../../../ai-workspace-framework/ai-context/tasks/active/alh-tracker/0004-counsel-handoff-packet.md) — primary brief; contains the suggested email cover note at the bottom
- [tos_draft_for_counsel.md](tos_draft_for_counsel.md) — preliminary ToS draft; send alongside the packet
- Supporting files listed in the packet's "What to send counsel" section

**What to do:**
1. Open `0004-counsel-handoff-packet.md` and scroll to "Suggested Email Cover Note to Counsel" at the bottom.
2. Copy and adapt the suggested email. Fill in your name and counsel's name.
3. Attach all five documents listed in the packet's Supporting Documents table.
4. Send to California compliance/privacy counsel.
5. Record the date sent in `phase_0_owner_action_packet.md`, Section 4, Action 3 checklist.

**Completion signal:** Email sent. Date noted. Counsel has acknowledged receipt (follow up in 2 business days if no acknowledgment).

**Why routing is Item 3 not Item 1:** Priority 1 counsel questions (Q1–Q4) block commercial launch and task 0005. They cannot be answered without counsel. Every week of delay is a week of schedule risk. Route now, even if the ToS and data model are still evolving — counsel can engage with draft materials.

**Hard stops:** Do not tell counsel that any of the preliminary findings are final. Do not ask counsel to confirm any compliance claim. The ask is written answers to specific questions only.

---

### Item 4 — Send first warm outreach to one ALH contact

**Owner:** Product / Program Lead
**Time:** 30 minutes
**Source file:** [design_partner_tracker.md](design_partner_tracker.md) — Section A, row 1 (highest priority score)

**What to do:**
1. After completing Item 1 (warm list) and scoring your Section A candidates, identify the highest-priority row (Priority 1 preferred; Priority 2 acceptable).
2. Send the warm-introduction email using the approved script from task 0002, Section 3:

> *Subject: Quick question — shift handoff tool collaboration*
>
> *Hi [Owner Name], I'm [Name] with AssistedLivingHelp. We're early in building a simple shift log and handoff tool specifically for small RCFE operators like yours. Right now it's in the design stage — no product exists yet. We're looking for one or two facilities willing to share how their current process works and give us feedback as we build. There's no cost — this is a design collaboration, not a product launch. Is this something you'd be open to talking about?*

3. Record in the tracker: facility name, contact, date sent, Status = "Contacted."

**Completion signal:** One message sent. Tracker updated. Calendar reminder set for 5 business days (follow-up window).

**Hard stops in any outreach:**
- Do not name a launch date
- Do not quote any pricing
- Do not promise specific features or compliance support
- Do not imply the product exists yet

---

## Day 3–5

### Item 5 — Confirm or revise the $49/month ALH founding partner rate

**Owner:** Product / Program Lead (sole decision-maker — no market validation required)
**Time:** Under 5 minutes once decided
**Source file:** [decisions/0003-business-model-alh-pricing.md](decisions/0003-business-model-alh-pricing.md) — records $49/month as the recommended founding rate

**What to do:**
1. Read ADR 0003 (or the summary in `phase_0_owner_action_packet.md`, Section 5).
2. Decide: confirm $49/month, or revise to a different number.
3. If confirmed: update ADR 0003's status note to "Owner confirmed [date]."
4. If revised: update the rate in ADR 0003 and note the revised rate and rationale. This is an ADR revision — record it as such.
5. Brief the BD team: they may use "founding partner rate to be confirmed" language in current outreach; they must not quote a number until this step is done.

**Completion signal:** ADR 0003 has an "Owner confirmed" or "Owner revised" note with today's date. BD team briefed.

**Why now:** The ALH founding rate must be locked before any ALH pilot conversation concludes. Repricing existing design partners after the fact is operationally hard. This is a 5-minute decision with high downstream leverage.

---

## Day 5–7

### Item 6 — Schedule human Technical Architect review of the offline spec

**Owner:** Product / Program Lead (schedules); Technical Architect (reviews)
**Time:** 10 minutes to schedule; 60–90 minutes for the TA review session
**Source file:** [0008-device-and-offline-behavior.md](../../../ai-workspace-framework/ai-context/tasks/active/alh-tracker/0008-device-and-offline-behavior.md) — the spec to review; includes an AI-assisted review note added in Session 4

**What to do:**
1. Share `0008-device-and-offline-behavior.md` with the Technical Architect before the meeting.
2. Ask them to focus on the AI-assisted review note (near the end of the file) — the note identifies no blocking issues and includes 4 implementation notes. The TA should confirm or challenge those findings.
3. During the review session, the TA must confirm (in writing, even a brief email) that:
   - The IndexedDB queue, dual-timestamp model, and conflict-flagging approach are compatible with Phase 1 architecture plans.
   - The no-Background-Sync-API decision is confirmed given the target device class.
   - The minimum browser targets (Android 9+/Chrome 80+, iOS 14+/Safari) are acceptable.
4. Record the TA's written confirmation (or any objections) by updating task 0008's acceptance criterion 6 in the file.

**Completion signal:** TA has sent a written response (email acceptable). Criterion 6 in task 0008 is checked off or updated with TA objections/changes.

**Note:** The AI-assisted review in Session 4 found the spec technically coherent, but it is not a substitute for human TA sign-off. Acceptance criterion 6 of task 0008 requires human confirmation before Phase 1 implementation begins. This does not block any current Phase 0 work — but must happen before Phase 1 kickoff.

---

## Summary Table

| # | Item | Time | Source file | Done when |
|---|---|---|---|---|
| 1 | Populate ALH warm contact list in tracker | 2–4 hrs | `design_partner_tracker.md` Section A | ≥3 rows with real contact info |
| 2 | Verify CCLD status for public-directory candidates | 1–2 hrs | `design_partner_tracker.md` Sections B/C | Every row has CCLD-confirmed status or removed |
| 3 | Route counsel packet | 30–45 min | `0004-counsel-handoff-packet.md` + `tos_draft_for_counsel.md` | Email sent; date logged |
| 4 | Send first warm outreach | 30 min | `design_partner_tracker.md` Section A (top row) | One message sent; tracker updated |
| 5 | Confirm $49/month ALH founding rate | <5 min | `decisions/0003-business-model-alh-pricing.md` | ADR 0003 updated; BD team briefed |
| 6 | Schedule TA review of offline spec | 10 min to schedule | `0008-device-and-offline-behavior.md` | Meeting on calendar; spec shared with TA |

---

**What is not on this list:**
- Application code — do not start
- Tech stack selection — do not start
- Database schema — do not start
- Family portal or family-facing features — do not start
- Tasks 0003, 0005, 0007 — remain blocked; do not attempt to activate

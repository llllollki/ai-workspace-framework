# Architectural Decision Records (ADRs)

This directory stores durable architectural and product decisions for alh-tracker.

## When to Create an ADR

Create a numbered ADR file only when a real, durable decision has been made — one that:

- is non-obvious and worth explaining to a future contributor
- has meaningful consequences if reversed
- has a clear date and status (proposed, accepted, superseded, deprecated)

Do not create placeholder ADR files in advance of real decisions.

## ADR Format

Each ADR file should follow this structure:

```markdown
# [NNNN] — [Decision Title]

**Date:** YYYY-MM-DD
**Status:** proposed | accepted | superseded | deprecated
**Supersedes:** [link to prior ADR, if applicable]
**Superseded by:** [link to newer ADR, if applicable]

## Context

[What problem or question prompted this decision? What constraints existed?]

## Decision

[What was decided?]

## Consequences

[What does this decision make easier? What does it make harder or constrain?]
```

## Naming Convention

Files are named `NNNN-short-title.md`, where `NNNN` is a zero-padded sequential number starting at `0001`.

Example: `0001-shift-model.md`, `0002-caregiver-auth.md`

## What Belongs Here vs. Elsewhere

| Content | Where it goes |
|---|---|
| Durable architectural decisions | `decisions\NNNN-title.md` (this directory) |
| Temporary working context and open questions | `ai_memory.md` |
| Framework structure changes | `ai-context\CHANGELOG.md` |
| Post-task retrospective patterns | `reflection.md` |

## ADRs Created

| ADR | Title | Date | Status |
|---|---|---|---|
| 0001 | Data boundary — alh-tracker vs. AssistedLivingHelp | 2026-05-05 | Accepted |
| 0002 | Pricing model type (flat monthly per-facility) | 2026-05-05 | Accepted |
| 0003 | Business model and ALH partner pricing | 2026-05-09 | Accepted |
| 0004 | Family access architecture | 2026-05-09 | Accepted |
| 0005 | CRM and mobile distribution strategy (three-surface model) | 2026-05-16 | Accepted |
| 0006 | CRM owner provisioning and family account approval | 2026-05-18 | Accepted |
| 0007 | CRM owner provisioning token mechanism | 2026-05-18 | Accepted |
| 0008 | CRM-to-tracker provisioning API authentication | 2026-05-19 | Accepted |
| 0009 | Tracker Facility record creation during CRM provisioning | 2026-05-19 | Accepted |

## Pending Future ADRs

Once the relevant Phase 0 tasks are resolved, the following decisions are likely candidates for ADRs:

- Shift model (fixed windows vs. operator-configured) — from task 0003
- Caregiver authentication model — from task 0003
- App delivery model (PWA vs. native vs. web + redirect) — from task 0009/CRM open questions. Note: ADR 0006 describes App Store / Google Play routing as the proposed/assumed provisioning flow for the owner activation deep link, but the app delivery model decision (native vs. PWA) has not been formalized. This ADR candidate remains open and must be resolved before Phase 2 implementation.
- Data retention and archive policy — from task 0009

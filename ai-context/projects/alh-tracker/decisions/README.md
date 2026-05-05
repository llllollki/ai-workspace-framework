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

## Expected First ADRs

Once the Phase 0 discovery tasks are complete, the following decisions are likely candidates for ADRs:

- Shift model (fixed windows vs. operator-configured) — from task 0003
- Caregiver authentication model — from task 0003
- Tech stack selection — when decided
- Business model and ALH pricing relationship — from task 0001

# Planning Rules

## Responsibility

This file defines how agents should decompose tasks into subtasks before beginning implementation.

## What Belongs Here

- Task decomposition patterns
- Acceptance criteria requirements
- Scope validation steps before starting work
- How to structure a plan within a task document

## What Does Not Belong Here

- Skill selection logic (see `routing_rules.md`)
- Context loading sequences (see `context_rules.md`)
- Runtime behavior (see `execution_rules.md`)

## Related Files

- `routing_rules.md` — which skill to use for each subtask type
- `context_rules.md` — what context to load before planning
- `tasks\active\AssistedLivingHelp\` — active task documents

---

## Planning Process

1. Read the task document to understand the goal and acceptance criteria.
2. Load project context using the sequence in `context_rules.md`.
3. Decompose the task into a numbered list of discrete subtasks.
4. For each subtask, identify: owner role, input dependencies, output artifact, and acceptance check.
5. Identify which skills apply to each subtask (see `routing_rules.md`).
6. Write the plan into the task document under a `## Plan` section before beginning.
7. Do not begin implementation until the plan is written and scope is confirmed.

## Task Document Structure

Each task document should contain:

```
Status:
Created:
Owner role:
Reviewers:

## Goal
## Acceptance Criteria
## Plan
  - [ ] subtask 1
  - [ ] subtask 2
## Notes
## Outcome
```

### Plan section format: checklist vs. narrative

Use the `- [ ] subtask` checklist format when subtasks are independently executable and need progress tracking (e.g., a multi-file migration, a feature with distinct layers). This format works well for tasks where items can be checked off as work proceeds.

Use a narrative or headed subsection format (e.g., `### API behavior`, `### Data persistence`) when the plan is primarily reference material — spec details, field tables, error response shapes — that needs to be consulted during implementation rather than checked off. This was validated during the `POST /api/leads` implementation, where the plan sections served as implementation guidance rather than a progress checklist.

Both formats may appear in the same document if parts of the plan are executable and other parts are reference.

<!-- TODO: Refine these rules based on real task patterns as the project evolves. -->

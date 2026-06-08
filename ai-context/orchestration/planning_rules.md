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
3. Apply the subagent planning gate from `global\agent_rules.md`, even if the user did not request subagents.
4. Decompose the task into a numbered list of discrete subtasks.
5. For each subtask, identify: owner role, input dependencies, output artifact, acceptance check, tests needed, and whether it is safe to delegate to a subagent or parallel worker.
6. If at least two subtasks can run independently and the runtime supports subagents, assign those subtasks to subagents by default.
7. Identify which skills apply to each subtask (see `routing_rules.md`).
8. Write the plan into the task document under a `## Plan` section before beginning.
9. Do not begin implementation until the plan is written and scope is confirmed.

## Subagent Planning Gate

Before implementation on any existing or new project, the main agent must answer these questions:

- Are there two or more independent workstreams?
- Can those workstreams be assigned non-overlapping file ownership or read-only investigation scopes?
- Would delegation reduce risk, improve coverage, or speed up verification?
- Does the runtime expose subagent, Task, worker, or parallel-agent tooling?

If the answer is yes, use subagents or parallel workers by default.

If the answer is no, proceed serially and briefly record the reason in the plan or working notes. Valid reasons include: the task is small, single-file, tightly coupled, design-sensitive, or the runtime has no subagent capability.

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

- Acceptance criteria should include a required line item for tests covering the new behavior. Use `templates\test_file_v1.md` as the coverage-doc format when describing the planned test artifacts.

Use a narrative or headed subsection format (e.g., `### API behavior`, `### Data persistence`) when the plan is primarily reference material — spec details, field tables, error response shapes — that needs to be consulted during implementation rather than checked off. This was validated during the `POST /api/leads` implementation, where the plan sections served as implementation guidance rather than a progress checklist.

Both formats may appear in the same document if parts of the plan are executable and other parts are reference.

<!-- TODO: Refine these rules based on real task patterns as the project evolves. -->

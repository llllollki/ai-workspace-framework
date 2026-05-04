# Execution Rules

## Responsibility

This file defines runtime behavior rules for agents during task execution.

## What Belongs Here

- Output discipline rules during implementation
- How to handle ambiguity or missing information
- When to stop and ask vs. proceed
- Documentation update requirements after task completion

## What Does Not Belong Here

- Planning logic (see `planning_rules.md`)
- Context loading (see `context_rules.md`)
- Cross-project scope guardrails (see `global\agent_rules.md`)

---

## Output Discipline

- Implement only what the task requires. Do not add unrequested features, abstractions, or cleanup.
- Do not add comments that explain what code does. Add a comment only when the reason is non-obvious.
- Do not modify files outside the task's defined scope.
- If a required input is missing, add a TODO rather than inventing content.

## Handling Ambiguity

- If requirements are unclear, stop and ask before writing code.
- If two sources conflict, stop and report — do not choose silently.
- If implementation would touch a file outside the allowed scope, stop and report.

## After Task Completion

_Substitute `<project>` with the current project name at runtime._

- Update the task document status to done.
- Move the completed task to `tasks\done\<project>\`.
- Update `projects\<project>\ai_memory.md` if the task resolved an open question.
- Update `projects\<project>\execution_log.md` with a one-line summary of the mechanical action taken.
- Write retrospective notes to `projects\<project>\reflection.md` if the task revealed a pattern worth remembering.

<!-- TODO: Refine execution rules as team workflow patterns become established. -->

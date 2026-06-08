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

## Subagent Execution

- Follow the subagent policy in `global\agent_rules.md` for every task, whether or not the user prompt mentions subagents.
- For broad implementation, assessment, migration, review, deployment, or verification tasks, pause before editing and split independent workstreams across subagents when the runtime supports it.
- The main agent owns coordination: define each subagent's scope, avoid overlapping write areas, review results, integrate changes, run checks, commit, push, and deploy when deployment is part of the task.
- Prefer worktree isolation for any subagent that writes files or runs builds/migrations (see `global\agent_rules.md`), so failed or conflicting work never touches the live tree or the enforcement files.
- If subagents would help but the runtime has no subagent tool, say so explicitly and continue serially.
- If subagents are intentionally not used, keep the reason brief and concrete.

## Handling Ambiguity

- If requirements are unclear, stop and ask before writing code.
- If two sources conflict, stop and report — do not choose silently.
- If implementation would touch a file outside the allowed scope, stop and report.

## Definition-of-Done Gate (hard precondition)

- A task may NOT move to `tasks\done\` until the Definition-of-Done gate in
  `orchestration\definition_of_done.md` passes: every `DEFINED` gate step ran and passed,
  acceptance criteria are met, and (if deploy is in scope) post-deploy smoke passed.
- Run the gate via the `verify-and-ship` skill (`skills\core\verify_and_ship_v1.md`). Never mark
  `done` on any failure; a failed task stays in `active\` with the failing step recorded.
- Deploy and migration steps obey the permission policy in `global\enforcement_design.md`.

## After Task Completion

_Substitute `<project>` with the current project name at runtime._

- Confirm the Definition-of-Done gate passed (above) before any of the steps below.
- Update the task document status to done.
- Move the completed task to `tasks\done\<project>\`.
- Update `projects\<project>\ai_memory.md` if the task resolved an open question.
- Update `projects\<project>\execution_log.md` with a one-line summary of the mechanical action taken.
- If a fix re-addresses a class of problem already seen or resolves a non-obvious trap, proactively ask the user before closing the task whether to save it to the project's `gotchas.md`. Prompt only when either (a) the same failure class has appeared before, or (b) the root cause was non-obvious and cost real debugging time. Do not prompt for routine, self-explanatory fixes.
- Write retrospective notes to `projects\<project>\reflection.md` if the task revealed a pattern worth remembering.

<!-- TODO: Refine execution rules as team workflow patterns become established. -->

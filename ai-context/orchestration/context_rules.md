# Context Rules

## Responsibility

This file defines what context to load and when.

## What Belongs Here

- Required context for each major task type
- Rules for which project files to load before starting a task
- Rules for what to skip when context would be too large

## What Does Not Belong Here

- Planning logic (see `planning_rules.md`)
- Skill selection (see `routing_rules.md`)

## Related Files

- `projects\AssistedLivingHelp\` — AssistedLivingHelp project context files
- `projects\alh-tracker\` — alh-tracker project context files
- `global\` — shared standards

---

## Default Context Loading Sequence

For any task on `<project>`:

1. `ai-context\README.md` — framework orientation
2. `ai-context\projects\<project>\overview.md` — project purpose, positioning, compliance constraints

Load additional files based on task type (see project-specific tables below).

## Task-Type Context Table — AssistedLivingHelp

| Task type | Load additionally |
|---|---|
| UI / frontend work | `global\design_system.md`, `global\ui_components.md`, `global\coding_standards.md` |
| API / backend work | `global\api_patterns.md`, `global\coding_standards.md`, `projects\AssistedLivingHelp\api_spec.md` |
| Data model work | `projects\AssistedLivingHelp\data_model.md` |
| Feature work | `projects\AssistedLivingHelp\features.md`, `projects\AssistedLivingHelp\user_flows.md` |
| BD / partner work | `projects\AssistedLivingHelp\business_development.md` |
| Active task | `tasks\active\AssistedLivingHelp\<task-file>.md` |
| Working context / open questions | `projects\AssistedLivingHelp\ai_memory.md` |

## Task-Type Context Table — alh-tracker

| Task type | Load additionally |
|---|---|
| UI / frontend work | `global\design_system.md`, `global\ui_components.md`, `global\coding_standards.md` |
| API / backend work | `global\api_patterns.md`, `global\coding_standards.md` |
| Data model work | `projects\alh-tracker\data_model.md` |
| Feature work | `projects\alh-tracker\features.md`, `projects\alh-tracker\user_flows.md` |
| Compliance / regulatory work | `projects\alh-tracker\compliance_notes.md` |
| Active task | `tasks\active\alh-tracker\<task-file>.md` |
| Working context / open questions | `projects\alh-tracker\ai_memory.md` |

## Rules

- Load only what the task requires. Do not load all project files for every task.
- Always load `overview.md` first — it contains compliance and scope constraints.
- Before modifying `ai_memory.md`, check for stale entries and remove resolved items.

<!-- TODO: Refine context loading sequences as task patterns become clearer. -->

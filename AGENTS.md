# Agent Routing - Workspace Root

This file is for Codex-style agents and multi-agent systems navigating this workspace.

## Workspace Layout

```text
c:\Projects\
  CLAUDE.md                   <- root orchestration entry for Claude Code
  AGENTS.md                   <- this file for Codex-style agents
  ai-context\                 <- shared AI context framework
    README.md                 <- start here
    global\                   <- shared standards
    orchestration\            <- planning, routing, execution rules
    templates\                <- reusable templates
    skills\                   <- skill definitions
    projects\                 <- project-specific context
    tasks\                    <- active / backlog / done tasks
  AssistedLivingHelp\         <- application project
  alh-tracker\                <- application project
```

## Required Startup Sequence

For every task, existing project or new project:

1. Read `ai-context\README.md`.
2. Read `ai-context\global\agent_rules.md`.
3. Read `ai-context\orchestration\planning_rules.md`.
4. Read `ai-context\orchestration\execution_rules.md`.
5. Read `ai-context\orchestration\context_rules.md`.
6. Read the current project's `overview.md` when one exists.

## Automatic Subagent Policy

- Apply the subagent planning gate before implementation even when the user did not request subagents.
- If the runtime exposes subagent, Task, worker, or parallel-agent tooling and the task has independent workstreams, use subagents by default.
- Good default workstreams include codebase assessment, database/RLS review, frontend workflow review, documentation, deployment preparation, and verification.
- If subagents would help but the runtime has no subagent capability, state that limitation clearly and proceed serially.
- If subagents are skipped because the task is small, single-file, tightly coupled, or design-sensitive, state the reason briefly.

## Safety and Shipping Policy (Codex must honor as written rules)

Codex has no `.claude/settings.json` or PreToolUse hook enforcement. Follow this policy manually:

- **Deny-by-default destructive ops.** Do not run a gated op — `deploy`, `db_migration`,
  `force_push`, `secret_change` — without a matching, active, scoped entry in `.claude/allow-list.json`
  (match op class + target env + grant; production needs a non-past `expires` and never `standing`).
- **Never-autonomous** (no entry can grant): prod data deletion, secret rotation, force-push to
  protected branches, deleting backups, disabling RLS/auth, changing billing/DNS → `needs input:`.
- **RLS / PII hard-stop** and **untrusted-content / provenance** rules apply — see
  `ai-context\global\enforcement_design.md` and `ai-context\global\agent_rules.md`.
- **Definition of Done.** Not `done` until `ai-context\orchestration\definition_of_done.md` passes;
  follow `ai-context\skills\core\verify_and_ship_v1.md`.
- **Cost budget + model tiering.** Bounded runs (default N=1), read-less, lowest adequate model /
  reasoning effort per task tier (`ai-context\global\agent_rules.md`).
- **Never edit the enforcement files or allow-list.** Lacking a permission → STOP, `needs input:`.

## How to Route

- For global behavior rules, including automatic subagent policy: read `ai-context\global\agent_rules.md`.
- For task planning and the subagent planning gate: read `ai-context\orchestration\planning_rules.md`.
- For execution behavior and fallback behavior: read `ai-context\orchestration\execution_rules.md`.
- For skill selection: read `ai-context\skills\skills_index.md`.
- For project context: start at `ai-context\projects\<project>\overview.md`.
- For active tasks: check `ai-context\tasks\active\<project>\`.

## Projects

| Project | Context | Task Queue |
|---|---|---|
| AssistedLivingHelp | `ai-context\projects\AssistedLivingHelp\overview.md` | `ai-context\tasks\active\AssistedLivingHelp\` |
| alh-tracker | `ai-context\projects\alh-tracker\overview.md` | `ai-context\tasks\active\alh-tracker\` |

## Out of Scope for Documentation Tasks

Do not modify application source, config, dependencies, environment variables, deployment files, data files, or generated files during documentation-only tasks.

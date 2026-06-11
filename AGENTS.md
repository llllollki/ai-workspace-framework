# Assisted Living Help — Workspace Root (Agent Entry Point)

This file is the root orchestration entry point for the `c:\Projects\` multi-project
workspace, read by every agent runtime (Claude Code, Codex, and others). `CLAUDE.md` and
`AGENTS.md` carry identical agent-neutral content; a change to one requires the same change
to the other (`setup\lint_framework.ps1` enforces byte-identity).

## AI Context Framework

All shared and project-specific AI context is under `c:\Projects\ai-context\`. The
canonical, version-controlled home of the framework is the `ai-workspace-framework` repo —
see `ai-context\source_of_truth.md`.

```text
c:\Projects\
  CLAUDE.md / AGENTS.md       <- this entry point (identical content)
  ai-context\
    core_rules.md             <- per-task digest of the must-know rules (load first)
    README.md                 <- navigation index
    global\                   <- shared standards
    orchestration\            <- planning, routing, execution rules
    templates\                <- reusable templates
    skills\                   <- skill definitions
    projects\                 <- project-specific context
    tasks\                    <- active / backlog / done tasks
  AssistedLivingHelp\         <- application project
  alh-tracker\                <- application project
```

## Projects In This Workspace

| Project | Application Path | Context Path |
|---|---|---|
| AssistedLivingHelp | `AssistedLivingHelp\` | `ai-context\projects\AssistedLivingHelp\` |
| alh-tracker | `alh-tracker\` | `ai-context\projects\alh-tracker\` |

## How to Start Working on a Task

Default for every task:

1. Read `ai-context\core_rules.md` — compact digest of the enforced rules (subagent gate,
   safety layer, Definition of Done, escalation).
2. Read `ai-context\projects\<project>\overview.md` for the current project.
3. Load additional files by task type per `ai-context\orchestration\context_rules.md`.

Load the full rule files (`ai-context\README.md`, `ai-context\global\agent_rules.md`,
`ai-context\orchestration\planning_rules.md`, `ai-context\orchestration\execution_rules.md`)
when the task is planning-heavy or safety-sensitive: it spans 3+ files or 2+ layers
(db/api/ui), includes verification or deploy, touches RLS/auth/secrets/PII, or involves any
destructive operation. The digest summarizes the full files; it does not weaken them.

## Subagent Policy

- Subagent consideration is mandatory for every task, even when the user does not mention
  subagents.
- The full subagent planning gate (`ai-context\orchestration\planning_rules.md`) applies
  when a task spans 3+ files, 2+ layers (db/api/ui), or includes verification/deploy. For
  smaller tasks, a one-line `serial: small task` note suffices.
- If the runtime exposes subagent, Task, worker, or parallel-agent tooling and independent
  workstreams exist, use them by default with non-overlapping ownership.
- If subagents would help but the runtime has no subagent tooling, say so explicitly and
  proceed serially.

## Safety, Shipping, and Cost Enforcement

- **Safety is enforced, not advisory.** For runtimes with harness enforcement (Claude Code),
  `.claude\settings.json` (permissions) and `.claude\hooks\pretooluse-guard.ps1` (PreToolUse
  gate) block destructive ops unless a scoped, active entry exists in
  `.claude\allow-list.json`. Runtimes without harness enforcement (Codex and others) must
  honor the same policy as written. Policy + op classes:
  `ai-context\global\enforcement_design.md`.
- **Definition of Done.** A task is not `done` until the gate in
  `ai-context\orchestration\definition_of_done.md` passes; run it via the `verify_and_ship`
  skill (`ai-context\skills\core\verify_and_ship_v1.md`).
- **Cost budget + model tiering.** See `ai-context\global\agent_rules.md` — bounded runs
  (default N=1 task/run), read-less, lowest adequate model tier per task.
- **Never edit your own enforcement files** (`.claude\settings.json`, `.claude\hooks\**`,
  `.claude\allow-list.json`, audit log). If you lack a permission, STOP and write
  `needs input:`.
- **Agent-via-PR.** Never push to `main`/`master`. Work on a feature branch, push it, and
  open a PR for owner review.

## Allowed Write Scope for Documentation and Context Tasks

Documentation and AI context work is limited to:

- `c:\Projects\CLAUDE.md`
- `c:\Projects\AGENTS.md`
- `c:\Projects\ai-context\**`
- `c:\Projects\AssistedLivingHelp\CLAUDE.md`
- `c:\Projects\AssistedLivingHelp\AGENTS.md`
- `c:\Projects\alh-tracker\CLAUDE.md`
- `c:\Projects\alh-tracker\AGENTS.md`

Do not write to application source, config, dependency, environment, deployment, data, or
generated files during documentation-only tasks.

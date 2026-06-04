# Assisted Living Help - Workspace Root

This file is the root orchestration entry point for the `c:\Projects\` multi-project workspace.

## AI Context Framework

All shared and project-specific AI context is under:

```text
c:\Projects\ai-context\
```

Read `ai-context\README.md` first for the full navigation map.

Subagent orchestration is automatic workspace behavior. For every task, even when the user does not mention subagents, read the framework rules and apply the subagent planning gate before implementation.

## Projects In This Workspace

| Project | Application Path | Context Path |
|---|---|---|
| AssistedLivingHelp | `AssistedLivingHelp\` | `ai-context\projects\AssistedLivingHelp\` |
| alh-tracker | `alh-tracker\` | `ai-context\projects\alh-tracker\` |

## How to Start Working on a Task

1. Read `ai-context\README.md` - framework overview and directory map.
2. Read `ai-context\global\agent_rules.md` - global behavior rules, including automatic subagent policy.
3. Read `ai-context\orchestration\planning_rules.md` - task decomposition and subagent planning gate.
4. Read `ai-context\orchestration\execution_rules.md` - runtime behavior and subagent fallback rules.
5. Read `ai-context\orchestration\context_rules.md` - what to load and when.
6. Read `ai-context\projects\<project>\overview.md` for the current project.
7. Load additional project files based on task type (see `context_rules.md`).

## Safety, Shipping, and Cost Enforcement

- **Safety is enforced, not advisory.** `.claude\settings.json` (permissions) and
  `.claude\hooks\pretooluse-guard.ps1` (PreToolUse gate) block destructive ops unless a scoped,
  active entry exists in `.claude\allow-list.json`. Policy + op classes: `ai-context\global\enforcement_design.md`.
- **Definition of Done.** A task is not `done` until the gate in
  `ai-context\orchestration\definition_of_done.md` passes; run it via the `verify-and-ship` skill
  (`.claude\skills\verify-and-ship\SKILL.md`, auto-invoked).
- **Cost budget + model tiering.** See `ai-context\global\agent_rules.md` — bounded runs (default
  N=1 task/run), read-less, and Tier-1 work on Haiku 4.5.
- **Never edit your own enforcement files** (`.claude\settings.json`, `.claude\hooks\**`,
  `.claude\allow-list.json`, audit log). If you lack a permission, STOP and write `needs input:`.

## Subagent Requirement

- At the start of every task, decide whether at least two independent workstreams exist.
- If Claude Code exposes subagent or Task tooling and independent workstreams exist, use subagents by default.
- If subagents would help but the runtime has no available subagent tool, say so explicitly and proceed serially.
- If subagents are not used because the task is small, single-file, tightly coupled, or design-sensitive, state that briefly in the plan or working notes.

## Allowed Write Scope for Documentation and Context Tasks

Documentation and AI context work is limited to:

- `c:\Projects\CLAUDE.md`
- `c:\Projects\AGENTS.md`
- `c:\Projects\ai-context\**`
- `c:\Projects\AssistedLivingHelp\CLAUDE.md`
- `c:\Projects\AssistedLivingHelp\AGENTS.md`
- `c:\Projects\alh-tracker\CLAUDE.md`
- `c:\Projects\alh-tracker\AGENTS.md`

Do not write to application source, config, dependency, environment, deployment, data, or generated files during documentation-only tasks.

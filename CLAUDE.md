# Assisted Living Help — Workspace Root

This file is the root orchestration entry point for the `c:\Projects\` multi-project workspace.

## AI Context Framework

All shared and project-specific AI context is under:

```
c:\Projects\ai-context\
```

Read `ai-context\README.md` first for the full navigation map.

## Projects In This Workspace

| Project | Application Path | Context Path |
|---|---|---|
| AssistedLivingHelp | `AssistedLivingHelp\` | `ai-context\projects\AssistedLivingHelp\` |

## How to Start Working on a Task

1. Read `ai-context\README.md` — framework overview and directory map.
2. Read `ai-context\global\agent_rules.md` - global behavior rules, including when to use subagents or parallel workers.
3. Read `ai-context\orchestration\context_rules.md` - what to load and when.
4. Read `ai-context\projects\AssistedLivingHelp\overview.md` — project purpose, positioning, and constraints.
5. Load additional project files based on task type (see `context_rules.md`).

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

## Allowed Write Scope for Documentation and Context Tasks

Documentation and AI context work is limited to:

- `c:\Projects\CLAUDE.md`
- `c:\Projects\AGENTS.md`
- `c:\Projects\ai-context\**`
- `c:\Projects\AssistedLivingHelp\CLAUDE.md`
- `c:\Projects\AssistedLivingHelp\AGENTS.md`

Do not write to application source, config, dependency, environment, deployment, data, or generated files.

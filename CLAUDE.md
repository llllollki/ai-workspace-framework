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

## Allowed Write Scope for Documentation and Context Tasks

Documentation and AI context work is limited to:

- `c:\Projects\CLAUDE.md`
- `c:\Projects\AGENTS.md`
- `c:\Projects\ai-context\**`
- `c:\Projects\AssistedLivingHelp\CLAUDE.md`
- `c:\Projects\AssistedLivingHelp\AGENTS.md`

Do not write to application source, config, dependency, environment, deployment, data, or generated files.

# Agent Routing — Workspace Root

This file is for Codex-style agents and multi-agent systems navigating this workspace.

## Workspace Layout

```
c:\Projects\
  CLAUDE.md                   ← root orchestration entry (Claude Code)
  AGENTS.md                   ← this file
  ai-context\                 ← shared AI context framework
    README.md                 ← start here
    global\                   ← shared standards
    orchestration\            ← planning, routing, execution rules
    templates\                ← reusable templates
    skills\                   ← skill definitions
    projects\                 ← project-specific context
    tasks\                    ← active / backlog / done tasks
  AssistedLivingHelp\         ← application project
    CLAUDE.md                 ← original project source brief (retained)
    AGENTS.md                 ← project-level agent pointer
```

## How to Route

- For global behavior rules, including when Codex-style agents should use subagents or parallel workers: read `ai-context\global\agent_rules.md`
- For task planning: read `ai-context\orchestration\planning_rules.md`
- For skill selection: read `ai-context\skills\skills_index.md`
- For AssistedLivingHelp context: start at `ai-context\projects\AssistedLivingHelp\overview.md`
- For active tasks: check `ai-context\tasks\active\AssistedLivingHelp\`

## Projects

| Project | Context | Task Queue |
|---|---|---|
| AssistedLivingHelp | `ai-context\projects\AssistedLivingHelp\overview.md` | `ai-context\tasks\active\AssistedLivingHelp\` |

## Out of Scope for Documentation Tasks

Do not modify application source, config, dependencies, environment variables, deployment files, data files, or generated files.

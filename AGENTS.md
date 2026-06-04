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

# AI Context Framework — Navigation Index

This directory is the shared AI context framework for the `c:\Projects\` workspace.

It is read by Claude Code, Codex, and other agents to understand project context, coding standards, task routing, and execution rules.

## Directory Map

| Directory | Responsibility |
|---|---|
| `global\` | Shared standards that apply across all projects in this workspace |
| `orchestration\` | Rules for planning tasks, routing to skills, loading context, and runtime behavior |
| `templates\` | Reusable documentation and code-generation templates, versioned |
| `skills\` | Skill definitions (versioned), organized by core / domain / project |
| `projects\` | Project-specific business and technical context |
| `tasks\` | Task documents in `active\`, `backlog\`, and `done\` |

## Start Here by Use Case

| What you are doing | Read first |
|---|---|
| Starting a new task | `orchestration\planning_rules.md` |
| Selecting a skill | `skills\skills_index.md` |
| Understanding AssistedLivingHelp | `projects\AssistedLivingHelp\overview.md` |
| Understanding alh-tracker | `projects\alh-tracker\overview.md` |
| Loading context for a task | `orchestration\context_rules.md` |
| Understanding execution behavior | `orchestration\execution_rules.md` |
| Understanding global agent behavior, including subagent usage | `global\agent_rules.md` |
| Verifying / shipping / deploying / marking a task done | `orchestration\definition_of_done.md` + `skills\core\verify_and_ship_v1.md` |
| Understanding safety enforcement and the allow-list | `global\enforcement_design.md` (live: `.claude\settings.json` + `.claude\hooks\`) |
| Deploying / rolling back a project | `global\deployment.md` |
| Which framework tree is canonical (repo vs working copy) | `source_of_truth.md` |
| Checking framework structural consistency (references, task IDs, CLAUDE/AGENTS sync) | `setup\lint_framework.ps1` (docs: `setup\lint_framework.md`) |
| Checking coding standards | `global\coding_standards.md` |
| Checking API patterns | `global\api_patterns.md` |
| Checking UI components | `global\ui_components.md` |

## Framework Files

| File | Responsibility |
|---|---|
| `README.md` | This file — navigation index |
| `CHANGELOG.md` | Framework-level documentation structure changes only (not business or code changes) |

## Projects Index

| Project | Path | Overview |
|---|---|---|
| AssistedLivingHelp | `projects\AssistedLivingHelp\` | `projects\AssistedLivingHelp\overview.md` |
| alh-tracker | `projects\alh-tracker\` | `projects\alh-tracker\overview.md` |

## Rules for Adding to This Framework

- Before adding a new file, check this README and the relevant subdirectory to see if the content belongs elsewhere.
- Framework files (orchestration, global, templates, skills) contain structural guidance only — no project-specific business facts.
- Project-specific context belongs under `projects\<project-name>\`.
- Task documents belong under `tasks\`.
- Version new templates and skills using `_vN` suffixes. See `orchestration\versioning_rules.md`.

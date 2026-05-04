# Skills Index

This file is the manifest for all skills in this framework.

A skill is a reusable, versioned set of instructions for completing a specific type of task.

## How to Use

1. Identify the task type.
2. Find the matching skill in this index.
3. Load the skill file and follow its instructions.
4. If no skill matches, see `orchestration\routing_rules.md` for fallback behavior.

---

## Core Skills

General-purpose skills that apply across projects.

| Skill | Version | File | Purpose |
|---|---|---|---|
| `generate_ui_component` | v1 | `core\generate_ui_component_v1.md` | Generate a new UI component |
| `write_api_endpoint` | v1 | `core\write_api_endpoint_v1.md` | Write a new API endpoint |
| `debug_issue` | v1 | `core\debug_issue_v1.md` | Debug and diagnose an issue |

## Domain Skills

Skills for specific problem domains.

| Skill | Version | File | Purpose |
|---|---|---|---|
| `design_dashboard` | v1 | `domain\design_dashboard_v1.md` | Design an internal dashboard layout |
| `build_auth_flow` | v1 | `domain\build_auth_flow_v1.md` | Build an authentication flow |

## Project Skills

Skills specific to a project.

### AssistedLivingHelp

| Skill | Version | File | Purpose |
|---|---|---|---|
| `custom_logic` | v1 | `project\AssistedLivingHelp\custom_logic_v1.md` | Custom matching and workflow logic for AssistedLivingHelp |

---

## Versioning

See `orchestration\versioning_rules.md` for rules on creating and deprecating skill versions.

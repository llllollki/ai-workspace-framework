# Routing Rules

## Responsibility

This file defines how to match task types to skills.

## What Belongs Here

- Task type to skill mapping
- Rules for when to use a core skill vs. a domain skill vs. a project skill
- Fallback rules when no skill matches

## What Does Not Belong Here

- Skill definitions (see `skills\`)
- Planning logic (see `planning_rules.md`)

## Related Files

- `skills\skills_index.md` — full skill manifest
- `planning_rules.md` — how tasks are decomposed before routing

---

## Routing Table

| Task type | Skill | Location |
|---|---|---|
| Generate a UI component | `generate_ui_component_v1` | `skills\core\generate_ui_component_v1.md` |
| Write an API endpoint | `write_api_endpoint_v1` | `skills\core\write_api_endpoint_v1.md` |
| Debug an issue | `debug_issue_v1` | `skills\core\debug_issue_v1.md` |
| Design a dashboard | `design_dashboard_v1` | `skills\domain\design_dashboard_v1.md` |
| Build an auth flow | `build_auth_flow_v1` | `skills\domain\build_auth_flow_v1.md` |
| AssistedLivingHelp custom logic | `custom_logic_v1` | `skills\project\AssistedLivingHelp\custom_logic_v1.md` |

## Fallback

If no skill matches, apply the relevant global standards (`global\coding_standards.md`, `global\api_patterns.md`) and proceed with explicit reasoning about approach.

<!-- TODO: Expand the routing table as new skills are added. -->

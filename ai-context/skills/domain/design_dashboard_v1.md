# Skill: Design Dashboard — v1

## Purpose

Design a new internal dashboard layout or view.

## When to Use

Use this skill when designing or implementing a new internal operations dashboard page.

## Inputs Required

- Dashboard purpose and primary user (e.g., internal staff, admin)
- Data entities and fields to display
- Key actions the user needs to perform
- Relevant user flow (`projects\AssistedLivingHelp\user_flows.md`)
- Relevant functional requirements (`projects\AssistedLivingHelp\features.md`)
- UI component conventions (`global\ui_components.md`)
- Design system (`global\design_system.md`)

## Steps

1. Define the primary goal and user of this dashboard.
2. List the data entities and fields needed on screen.
3. Define the key actions (create, edit, update status, etc.).
4. Sketch the information hierarchy: list view → detail view → action panels.
5. Implement following coding standards and component conventions.
6. Ensure the dashboard is staff-only with the appropriate access check.

## Notes

- Internal admin features must be staff-only. See `projects\AssistedLivingHelp\overview.md` — Security And Access Control section.
- Do not expose sensitive intake fields beyond what the staff role requires.

<!-- TODO: Refine with AssistedLivingHelp admin dashboard conventions as the UI is built out. -->

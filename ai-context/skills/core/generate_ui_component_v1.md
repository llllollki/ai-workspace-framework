# Skill: Generate UI Component — v1

## Purpose

Generate a new UI component for the project.

## When to Use

Use this skill when tasked with creating a new reusable or page-level UI component.

## Inputs Required

- Component name and purpose
- Props / interface definition
- States and variants needed
- Relevant design system context (`global\design_system.md`)
- Relevant component conventions (`global\ui_components.md`)
- Coding standards (`global\coding_standards.md`)

## Steps

1. Load design system and component conventions.
2. Define the component interface (props, types).
3. Implement the component following coding standards.
4. Add accessible markup and ARIA attributes as needed.
5. Write or update a test file using `templates\test_file_v1.md`.
6. Document the component using `templates\component_v1.md`.

## Output

- Component file in the project's `components\` directory.
- Test file.
- Component documentation (optional, if adding to the shared component library).

<!-- TODO: Refine with AssistedLivingHelp-specific component conventions once established. -->

# Skill: AssistedLivingHelp Custom Logic — v1

## Purpose

Implement matching, outreach, scheduling, and other custom business logic specific to the AssistedLivingHelp platform.

## When to Use

Use this skill when implementing:

- Lead-to-facility matching logic
- Facility outreach and scheduling workflows
- Lead status transitions
- Partner account lifecycle operations

## Inputs Required

- `projects\AssistedLivingHelp\overview.md` — project scope and constraints
- `projects\AssistedLivingHelp\features.md` — feature requirements and matching logic
- `projects\AssistedLivingHelp\data_model.md` — domain model and data source notes
- `projects\AssistedLivingHelp\user_flows.md` — user and workflow flows
- `projects\AssistedLivingHelp\ai_memory.md` — open questions and current working context

## Key Domain Rules

- Matching must prefer dependable fields (city, ZIP, county, facility type, capacity, licensing status).
- Partner or premium status may influence visibility only within trust-preserving rules.
- Sponsored or prioritized placement must never override core safety, fit, or compliance constraints.
- Use `ca_ccld_registry` as the primary Phase 1 facility data source. See `data_model.md`.
- Phase 1 scope is limited to the five hospital-anchored launch markets.

Source: `projects\AssistedLivingHelp\overview.md` (and the other project context files listed under Inputs Required); originally migrated from the project brief.

<!-- TODO: Expand with concrete matching algorithm rules and outreach workflow rules once the implementation phase begins. -->

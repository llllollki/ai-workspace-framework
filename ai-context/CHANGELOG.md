# AI Context Framework — Changelog

This file records framework-level documentation structure changes only.

It does not track application code changes, business logic changes, or project-specific content updates.
For project-specific documentation activity, see `projects\AssistedLivingHelp\execution_log.md`.

---

## v0.1 — 2026-05-02

**Initial framework scaffold created.**

### Created

- `ai-context\` directory and full subdirectory structure
- `ai-context\README.md` — navigation index
- `ai-context\CHANGELOG.md` — this file
- `ai-context\global\` — shared standards stubs: design_system, ui_components, coding_standards, api_patterns, agent_rules
- `ai-context\orchestration\` — planning_rules, routing_rules, context_rules, execution_rules, versioning_rules
- `ai-context\templates\` — component_v1, api_endpoint_v1, test_file_v1
- `ai-context\skills\skills_index.md` and skill stubs under `core\`, `domain\`, `project\AssistedLivingHelp\`
- `ai-context\projects\AssistedLivingHelp\` — overview, features, user_flows, data_model, api_spec, business_development, ai_memory, execution_log, reflection, decisions\README.md
- `ai-context\tasks\active\AssistedLivingHelp\`, `backlog\AssistedLivingHelp\`, `done\AssistedLivingHelp\`
- `c:\Projects\CLAUDE.md` — root orchestration entry point
- `c:\Projects\AGENTS.md` — root agent routing pointer
- `AssistedLivingHelp\AGENTS.md` — project-level agent pointer

### Source documents used

- `AssistedLivingHelp\CLAUDE.md` — primary migration source for all project context files
- `AssistedLivingHelp\BUSINESS_DEVELOPMENT.md` — source for `business_development.md` unique content (pricing, add-ons, contract concepts, partner segmentation, launch offer, BD metrics, compliant language)
- `AssistedLivingHelp\README.md` — referenced for stack and setup notes

### Not changed

- `AssistedLivingHelp\CLAUDE.md` — retained as original source of truth, unchanged
- `AssistedLivingHelp\PROJECT_CONTEXT.md` — retained; verified near-identical duplicate of CLAUDE.md
- `AssistedLivingHelp\BUSINESS_DEVELOPMENT.md` — retained as original source document
- `AssistedLivingHelp\README.md` — retained as developer setup document
- All application source, config, dependency, environment, deployment, data, and generated files — unchanged

---

## v0.1.1 — 2026-05-03

**Documentation review fixes.**

### Changed

- `ai-context\projects\AssistedLivingHelp\business_development.md` — Added missing "Sample Compliant Language By Package" section (source: `BUSINESS_DEVELOPMENT.md` lines 256–289); added missing "Sales Principles" subsection (source: `CLAUDE.md` lines 466–472); added missing "If The Facility Says They Are Too Busy" objection (source: `CLAUDE.md` lines 433–435).
- `ai-context\projects\AssistedLivingHelp\overview.md` — Replaced invisible HTML comment under "Pinned Versions" with visible markdown TODO.
- `ai-context\orchestration\execution_rules.md` — Replaced hardcoded `AssistedLivingHelp` paths in post-task checklist with `<project>` placeholders.

### Not changed

- All source documents — unchanged
- All application source, config, dependency, environment, deployment, data, and generated files — unchanged

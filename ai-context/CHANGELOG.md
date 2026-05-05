# AI Context Framework — Changelog

This file records framework-level documentation structure changes only.

It does not track application code changes, business logic changes, or project-specific content updates.
For project-specific documentation activity, see the relevant project's `execution_log.md`.

---

## v0.2 — 2026-05-05

**Added alh-tracker project context.**

### Created

- `ai-context\projects\alh-tracker\` — new project context directory
- `ai-context\projects\alh-tracker\overview.md` — product purpose, persona split, positioning, MVP boundary, compliance stance, and ALH relationship
- `ai-context\projects\alh-tracker\data_model.md` — entity design reference: Facility, User, Resident, Routine, Shift, CareLogEntry, ObservedCareTask, FollowUp, AuditTrail, and family access stubs
- `ai-context\projects\alh-tracker\features.md` — MVP scope, explicit defer list, logging UX principles, and implementation phases
- `ai-context\projects\alh-tracker\user_flows.md` — ten primary user flows from facility setup through owner review
- `ai-context\projects\alh-tracker\compliance_notes.md` — RCFE/Title 22 context, medication boundary language, HIPAA posture, data handling requirements
- `ai-context\projects\alh-tracker\ai_memory.md` — open questions across business model, design partner, shift model, caregiver auth, family access, HIPAA, and Title 22
- `ai-context\projects\alh-tracker\execution_log.md` — project documentation activity log
- `ai-context\projects\alh-tracker\decisions\README.md` — ADR format guide for alh-tracker
- `ai-context\tasks\active\alh-tracker\README.md`
- `ai-context\tasks\backlog\alh-tracker\README.md` — includes Phase 0 dependency table
- `ai-context\tasks\done\alh-tracker\README.md`
- `ai-context\tasks\backlog\alh-tracker\0001-business-model-and-alh-relationship.md`
- `ai-context\tasks\backlog\alh-tracker\0002-design-partner-criteria-and-outreach.md`
- `ai-context\tasks\backlog\alh-tracker\0003-shift-model-and-caregiver-auth.md`
- `ai-context\tasks\backlog\alh-tracker\0004-title-22-documentation-review.md`
- `ai-context\tasks\backlog\alh-tracker\0005-mvp-data-model.md`
- `ai-context\tasks\backlog\alh-tracker\0006-family-access-architecture.md`
- `ai-context\tasks\backlog\alh-tracker\0007-logging-ux-principles-and-prototype.md`
- `ai-context\tasks\backlog\alh-tracker\0008-device-and-offline-behavior.md`

### Changed

- `ai-context\README.md` — added alh-tracker to Start Here use-case table and Projects Index
- `ai-context\orchestration\context_rules.md` — generalized Default Context Loading Sequence step 2 from hardcoded `AssistedLivingHelp` to `<project>` placeholder; added alh-tracker Task-Type Context Table; split AssistedLivingHelp table into named section; updated Related Files to reference both projects; updated CHANGELOG reference to use generic `execution_log.md`

### Not changed

- All AssistedLivingHelp project context files — unchanged
- All application source, config, dependency, environment, deployment, data, and generated files — unchanged

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

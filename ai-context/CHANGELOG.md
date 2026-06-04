# AI Context Framework — Changelog

This file records framework-level documentation structure changes only.

It does not track application code changes, business logic changes, or project-specific content updates.
For project-specific documentation activity, see the relevant project's `execution_log.md`.

---

## v0.6 — 2026-06-04

**Worktree isolation for write-capable subagents** (catalog-informed hardening: git-worktree
isolation is the recurring safe-agent pattern in awesome-ai-coding-tools).

### Changed

- `ai-context\global\agent_rules.md` — added a rule to run write-capable / build-or-migrate /
  parallel subagents on an isolated git worktree (Claude Code `isolation: "worktree"`; others
  `git worktree add`) so they cannot corrupt the live tree, `.claude/**`, or another worker's edits.
- `ai-context\orchestration\execution_rules.md` — Subagent Execution now prefers worktree isolation
  for any file-writing or build/migration subagent.

### Not changed

- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.5 — 2026-06-04

**Completed the ship & safety upgrade (items 4–6 of task framework/0001): deployment runbook,
source-of-truth reconciliation, and stale-pointer fixes.**

### Created

- `ai-context\global\deployment.md` — deployment runbook: environments, canonical deploy sequence
  (migrate → RLS-verify → deploy → smoke), rollback, and per-project sections (alh-tracker
  concrete; AssistedLivingHelp TODO pending path confirmation).
- `ai-context\source_of_truth.md` — documents the two-tree duplication (canonical repo
  `ai-workspace-framework` vs working copy `ai-context\`), recommends consolidation, records the
  `CLAUDE.md`/`AGENTS.md` "update together" rule, and flags `printing\` as outside the projects table.

### Changed

- Root `CLAUDE.md` / `AGENTS.md` — reconciled so the repo and live workspace trees are identical.
- `ai-context\skills\domain\build_auth_flow_v1.md`,
  `ai-context\skills\project\AssistedLivingHelp\custom_logic_v1.md` — repointed stale
  `Source: AssistedLivingHelp\CLAUDE.md` references to `projects\AssistedLivingHelp\overview.md`.
- `ai-context\README.md` — added the deployment runbook and source-of-truth to navigation.

### Not changed

- Migration-provenance notes ("Migrated from `AssistedLivingHelp\CLAUDE.md`") retained as
  historical record.
- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.4 — 2026-06-04

**Added ship + safety layer so Claude Code and Codex can autonomously reach production-ready +
deployed with real (harness-enforced) guardrails and a cost budget.** (Task: framework/0001;
items 1–3 of 6 — deploy-blocker floor. Items 4–6 are the next batch.)

### Created

- `ai-context\global\enforcement_design.md` — human/Codex reference for the permission policy:
  op classes, scoped/expiring allow-list semantics, never-autonomous list, RLS/PII hard-stop,
  audit, and the out-of-model backstops the human must configure.
- `ai-context\orchestration\definition_of_done.md` — the DoD gate, typed command-variable status
  model (DEFINED/TODO/N/A), per-project `REQUIRED_FLOOR`, and per-project command scaffolding.
- `ai-context\skills\core\verify_and_ship_v1.md` — Codex-readable mirror of the verify-and-ship
  skill (step order, retry policy, prod-deploy gate, smoke assertions, logging).
- `.claude\settings.json`, `.claude\hooks\pretooluse-guard.ps1`, `.claude\allow-list.json`,
  `.claude\skills\verify-and-ship\SKILL.md` — Claude Code enforcement + auto-invoked skill.
  **Outside the documented Allowed Write Scope**; created under explicit owner authorization as the
  enforcement seatbelt (see task framework/0001).

### Changed

- `ai-context\global\agent_rules.md` — added Safety Layer (enforced) and Token/Cost Budget +
  Model Tiering sections.
- `ai-context\orchestration\execution_rules.md` — added the Definition-of-Done gate as a hard
  precondition before any task moves to `tasks\done\`.
- `ai-context\skills\skills_index.md`, `ai-context\orchestration\routing_rules.md` — registered
  `verify_and_ship_v1`.
- `ai-context\README.md`, `CLAUDE.md`, `AGENTS.md` — pointers to the enforcement + DoD layer.

### Not changed

- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.3 - 2026-05-16

**Added global subagent guidance for Claude Code and Codex.**

### Changed

- `ai-context\global\agent_rules.md` - added workspace-wide rules for when to use subagents or parallel workers, when to avoid them, and how the main agent should coordinate delegated work.
- `CLAUDE.md` - updated the Claude Code start sequence to load global agent rules before task context.
- `AGENTS.md` - updated Codex-style routing to point at global agent rules.
- `ai-context\README.md` - added global agent behavior to the Start Here table.

### Not changed

- Project-specific business context - unchanged
- Application source, config, dependency, environment, deployment, data, and generated files - unchanged

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

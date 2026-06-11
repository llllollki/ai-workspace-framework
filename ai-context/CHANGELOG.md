# AI Context Framework — Changelog

This file records framework-level documentation structure changes only.

It does not track application code changes, business logic changes, or project-specific content updates.
For project-specific documentation activity, see the relevant project's `execution_log.md`.

---

## v0.12 — 2026-06-11

**Framework lint, task ID remediation, core rules digest, proportional subagent gate, and staleness fixes** (external assessment follow-up).

### Created

- `setup\lint_framework.ps1` + `setup\lint_framework.md` — structural lint (exits nonzero with a per-finding report): `REF` referenced files exist; `ID` no task ID collisions; `DUP` no stale lifecycle duplicates; `SYNC` root `CLAUDE.md`/`AGENTS.md` byte-identical. Referenced from `ai-context\README.md`.
- `ai-context\core_rules.md` — one-page digest of the must-know rules (subagent gate, safety/never-autonomous summary, DoD precondition, cost budget, escalation), cutting the default per-task preamble from 5+ files to 2.
- `ai-context\skills\project\alh-tracker\mobile_tablet_ui_v1.md` — restored from the working copy; it was indexed but had never been mirrored into the repo. Matching row added to `orchestration\routing_rules.md`.

### Changed

- Task ID remediation (alh-tracker): renumbered `0004-counsel-handoff-packet` → `0038`, backlog `0010-crm-design-open-questions` → `0039`, backlog `0011-resident-profile-data-model-expansion` → `0040`, done `0028-adr-0011-architecture-review` → `0041`, done `0029-accept-adr-0011` → `0042` (provisioning tasks 0028/0029 keep their IDs — referenced by ADRs 0012/0013). Deleted stale lifecycle duplicates: backlog `0006`/`0008`/`0009`/`0032` copies and done `0027-provisioning-schema-and-rls-migrations` (superseded by done `0030`). Current references updated; historical log entries left as written.
- `orchestration\planning_rules.md` — task ID allocation rule (next unused number across all three lifecycle dirs, never reused); subagent gate proportionality.
- `global\agent_rules.md` — subagent gate proportionality: full gate only for tasks spanning 3+ files, 2+ layers (db/api/ui), or verification/deploy; smaller tasks record a one-line `serial: small task` note.
- Root `CLAUDE.md`/`AGENTS.md` — rewritten as one identical agent-neutral entry point; byte-identity now enforced by the lint `SYNC` check.
- `orchestration\context_rules.md` + `ai-context\README.md` — default loading sequence is now `core_rules.md` + project `overview.md`; full rule files load only for planning-heavy or safety-sensitive work.
- `global\enforcement_design.md` — backstop checklist re-verified 2026-06-11 (`c:\Projects` still not a git repo; `gh` still not installed).
- `orchestration\definition_of_done.md` — `RLS_VERIFY_CMD` flagged as the priority TODO for alh-tracker with the exact anon-SELECT-denied check spec (to be wired in a follow-up code task, then moved to `DEFINED` + `REQUIRED_FLOOR`).
- `source_of_truth.md` — new "Open owner decisions" section (AssistedLivingHelp `PROJECT_PATH`, `printing\` scope, source-of-truth option 1) with a needs-input line for each.

### Agent-neutral

- All new and amended rule text is runtime-neutral; `CLAUDE.md` and `AGENTS.md` now carry identical content by construction.

---

## v0.11 — 2026-06-07

**Added durable project gotchas support and strengthened test planning and DoD coverage rules.**

### Created

- `ai-context\projects\alh-tracker\gotchas.md` — recall-first registry of durable technical traps
  (Supabase SIGNED_IN on tab refocus, ALT+Tab modal close, RLS GRANT 403s, auth redirect loops),
  distinct from `ai_memory.md` (volatile) and `reflection.md` (post-task retrospective).

### Changed

- `ai-context\orchestration\context_rules.md` — added optional per-project `gotchas.md` support and loaded it for alh-tracker debugging, auth, and RLS/provisioning task types only.
- `ai-context\orchestration\execution_rules.md` — added a proactive save rule for non-obvious or repeat failure-class fixes, with anti-nag trigger criteria.
- `ai-context\orchestration\planning_rules.md` — required "tests for this change" as a planning line item and acceptance criteria item, with `templates\test_file_v1.md` as the coverage-doc format.
- `ai-context\orchestration\definition_of_done.md` — clarified that feature tasks cannot be done without tests covering the new behavior and defined what broadened `TEST_CMD` means for alh-tracker.
- `ai-context\global\agent_rules.md` — added the principle to write tests with the feature, not after.

### Agent-neutral

- All new rule text is runtime-neutral (no Claude Code / Codex-specific tool names), so both runtimes read identical rules.

---

## v0.10 — 2026-06-04

**Added a wellness / health-tracking app design skill** — energetic fresh green-to-yellow gradient
aesthetic for consumer fitness/wellness trackers (reference: a health-tracking app + a lime/yellow
gradient palette).

### Created

- `.claude\skills\design-wellness-tracker-app\SKILL.md` — Claude-auto-invoked aesthetic skill: fresh
  green-yellow color system (with hard contrast guardrails — deep ink on light, yellow decorative
  only, status colors kept distinct from the brand green/yellow), activity-ring signature element,
  motivational/gamification patterns with reduced-motion restraint. **Builds on**
  `design_health_mobile_app` (inherits its tokens / a11y / data-viz honesty / PHI / DoD rules rather
  than duplicating them).
- `ai-context\skills\domain\design_wellness_tracker_app_v1.md` — Codex-readable mirror.

### Changed

- `ai-context\skills\skills_index.md`, `ai-context\orchestration\routing_rules.md` — registered
  `design_wellness_tracker_app_v1`.

### Not changed

- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.9 — 2026-06-04

**Added a health/care mobile & tablet app design skill** — calm, accessible, PHI-safe UI design for
phones and tablets (reference: AI health app design).

### Created

- `.claude\skills\design-health-mobile-app\SKILL.md` — Claude-auto-invoked design skill, cleanly
  sectioned (design-language statement, token system, layout/navigation, touch/type/contrast,
  components, health data-viz honesty contract, status/color model, AI-feature UX, accessibility,
  data entry & offline, shared-tablet/kiosk, PHI/PII guardrails, anti-overclaim copy rules,
  anti-generic, Definition of Done, self-verify checklist).
- `ai-context\skills\domain\design_health_mobile_app_v1.md` — Codex-readable mirror.

### Changed

- `ai-context\skills\skills_index.md`, `ai-context\orchestration\routing_rules.md` — registered
  `design_health_mobile_app_v1`. The skill defers to the project skill
  `project\alh-tracker\mobile_tablet_ui_v1.md` for alh-tracker screens.

### Not changed

- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.8 — 2026-06-04

**Added a luxury / immersive brand-site design skill** (reference class: Cartier *Watches & Wonders*).

### Created

- `.claude\skills\build-luxury-site\SKILL.md` — Claude-auto-invoked design skill: editorial luxury
  design language, scroll-driven motion system (Lenis + GSAP/ScrollTrigger), recommended stack,
  section blueprint, performance budget (LCP/CLS), accessibility (`prefers-reduced-motion` required)
  + i18n, and a Definition-of-Done tie-in.
- `ai-context\skills\domain\build_luxury_site_v1.md` — Codex-readable mirror of the same skill.

### Changed

- `ai-context\skills\skills_index.md`, `ai-context\orchestration\routing_rules.md` — registered
  `build_luxury_site_v1`.

### Not changed

- Application source, config, dependency, environment, deployment, data, and generated files —
  unchanged.

---

## v0.7 — 2026-06-04

**Egress control (data-exfiltration defense)** — catalog-informed hardening: "egress control" is a
top isolation feature across awesome-ai-coding-tools; here it protects resident/PII data.

### Created

- `.claude\hooks\egress-guard.ps1` — PreToolUse hook (matcher `WebFetch`) that blocks fetches to any
  host not in the egress allowlist.
- `.claude\egress-allowlist.txt` — domain allowlist for WebFetch (trusted documentation sources).

### Changed

- `.claude\settings.json` — deny raw network CLI (`curl`/`wget`/`iwr`/`irm`/`nc`/`scp`/`rsync`),
  allow WebFetch only to allowlisted documentation domains, and register the egress hook.
- `ai-context\global\enforcement_design.md` — added the Egress control section.
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

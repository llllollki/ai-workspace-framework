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
| `verify_and_ship` | v1 | `core\verify_and_ship_v1.md` | Run the Definition-of-Done gate (preflight→typecheck→lint→test→build→migrate→RLS→deploy→smoke) before marking done/deploying. Claude Code auto-invokes the mirror at `.claude/skills/verify-and-ship/SKILL.md` |

## Domain Skills

Skills for specific problem domains.

| Skill | Version | File | Purpose |
|---|---|---|---|
| `design_dashboard` | v1 | `domain\design_dashboard_v1.md` | Design an internal dashboard layout |
| `build_auth_flow` | v1 | `domain\build_auth_flow_v1.md` | Build an authentication flow |
| `build_luxury_site` | v1 | `domain\build_luxury_site_v1.md` | Build a luxury / immersive brand-experience site (cinematic scroll storytelling, refined motion). Claude Code auto-invokes the mirror at `.claude/skills/build-luxury-site/SKILL.md` |
| `design_health_mobile_app` | v1 | `domain\design_health_mobile_app_v1.md` | Design a calm, accessible, PHI-safe mobile/tablet health/care app UI (tokens, light/dark, health data viz, AI-feature UX, offline, a11y). Claude Code auto-invokes the mirror at `.claude/skills/design-health-mobile-app/SKILL.md`. For alh-tracker screens, defer to `mobile_tablet_ui_v1` |
| `design_wellness_tracker_app` | v1 | `domain\design_wellness_tracker_app_v1.md` | Design a consumer wellness/fitness TRACKING app UI (energetic fresh green-yellow gradient, activity rings, streaks). Builds on `design_health_mobile_app`. Claude Code auto-invokes the mirror at `.claude/skills/design-wellness-tracker-app/SKILL.md` |

## Project Skills

Skills specific to a project.

### AssistedLivingHelp

| Skill | Version | File | Purpose |
|---|---|---|---|
| `custom_logic` | v1 | `project\AssistedLivingHelp\custom_logic_v1.md` | Custom matching and workflow logic for AssistedLivingHelp |

### alh-tracker

| Skill | Version | File | Purpose |
|---|---|---|---|
| `mobile_tablet_ui` | v1 | `project\alh-tracker\mobile_tablet_ui_v1.md` | Keep Facility Tracker App mobile/tablet UI changes consistent |

---

## Versioning

See `orchestration\versioning_rules.md` for rules on creating and deprecating skill versions.

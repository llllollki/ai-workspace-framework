# Task 0001 — Framework Ship & Safety Upgrade

**Scope:** workspace framework (spans AssistedLivingHelp + alh-tracker)
**Status:** done
**Started:** 2026-06-04
**Completed:** 2026-06-04
**Owner role:** Technical Architect
**Reviewers:** Security / DevOps, Compliance / Privacy Counsel

---

## Goal

Enable Claude Code and Codex to autonomously iterate the task queue to production-ready +
deployed, with **real (harness-enforced) safety**, a **Definition-of-Done gate**, and a
**verify-and-ship** pipeline — without exceeding the per-run token/cost budget.

## Acceptance Criteria

1. A safety layer exists and is **enforced**, not just documented: untrusted-content rule,
   allow-list integrity (no self-edit), scoped/expiring grants, never-autonomous list, RLS/PII
   hard-stop, append-only audit, secrets hygiene.
2. Enforcement lives in real Claude Code locations: `.claude/settings.json` (permissions) +
   `.claude/hooks/` (PreToolUse gate). Codex parity via plain-Markdown rules in `AGENTS.md`.
3. A Definition-of-Done gate exists with typed per-project command variables and a
   `REQUIRED_FLOOR`; `execution_rules.md` makes it a hard precondition for `done`.
4. A `verify-and-ship` skill exists at `.claude/skills/verify-and-ship/SKILL.md` (auto-invoked by
   Claude) with a Codex-readable mirror at `ai-context/skills/core/verify_and_ship_v1.md`.
5. All changes apply to both Claude Code and Codex; `CLAUDE.md` and `AGENTS.md` stay in sync.

## Plan

This run delivers the **deploy-blocker floor (items 1–3)**, then STOPS per the TOKEN/COST BUDGET
(N=1). Items 4–6 are the next batch.

- [x] 0. Inspect current state (`.claude/`, CHANGELOG, task format) — no `.claude/` existed
- [x] 1. Safety layer — `agent_rules.md` + `enforcement_design.md` + `.claude/settings.json` +
      `.claude/hooks/pretooluse-guard.ps1` + `.claude/allow-list.json`
- [x] 2. Definition of Done — `definition_of_done.md` + `execution_rules.md` precondition
- [x] 3. Verify-and-ship skill — `.claude/skills/verify-and-ship/SKILL.md` + ai-context mirror +
      `skills_index.md` + `routing_rules.md` registration
- [x] Cross-compat — `CLAUDE.md` / `AGENTS.md` enforcement pointers + `README.md` + `CHANGELOG.md`
- [x] 4. Deployment runbook (`global/deployment.md`) — env, deploy sequence, rollback, per-project
- [x] 5. Single source of truth — `source_of_truth.md` (repo canonical; reconciled CLAUDE/AGENTS; flagged `printing\`)
- [x] 6. Fix stale pointers — `build_auth_flow_v1.md` + `custom_logic_v1.md` repointed to `overview.md`

### subagent_fallback

Ran serially (no subagents). Reason: the doc edits are tightly coupled and cross-referential
(skills_index ↔ routing_rules ↔ CHANGELOG ↔ execution_rules), and item 1 is design-sensitive
(Tier 3). Delegation would add fresh-context cost without parallelism — per the TOKEN/COST BUDGET.

## Notes

- Workspace is **not a git repo** (verified): the protected-branch + CODEOWNERS backstop for
  allow-list integrity is **not yet available**. Recorded as a human-owned TODO in
  `enforcement_design.md`.
- `.claude/settings.json`, `.claude/hooks/**`, `.claude/skills/**`, and `.claude/allow-list.json`
  are **outside** the documented "Allowed Write Scope" in `c:\Projects\CLAUDE.md`. Created under
  explicit owner authorization as the enforcement seatbelt. Flagged here for the record.

## Outcome

**2026-06-04 — Floor (items 1–3) implemented and pushed** to `ai-workspace-framework` (commit
`34ec527`). Enforcement hook tested (gated/never ops blocked; valid scoped entry allowed + audited).

**2026-06-04 — Items 4–6 completed.** Deployment runbook (`global/deployment.md`), source-of-truth
recommendation (`source_of_truth.md`), and skill stale-pointer fixes. Root `CLAUDE.md`/`AGENTS.md`
reconciled across both trees (commit `b4d6290`).

**Remaining out-of-model backstops (owner-owned):** branch protection done; still open — a
least-privilege Supabase role (can't disable RLS / read PII) and an append-only/external audit sink.

# Agent Rules

## Responsibility

This file defines behavioral rules for AI agents (Claude Code, Codex, and others) operating in this workspace.

## What Belongs Here

- Rules that apply to all agents across all projects
- Output discipline rules (what to write, what not to write)
- Scope guardrails (what files agents are allowed to touch)
- Escalation rules (when to stop and ask)
- Context-loading requirements

## What Does Not Belong Here

- Project-specific task or skill routing (see `orchestration\routing_rules.md`)
- Context-loading sequences for specific task types (see `orchestration\context_rules.md`)

## Related Files

- `orchestration\execution_rules.md` — runtime behavior rules
- `orchestration\context_rules.md` — what to load and when

---

## Core Rules

### Scope

- Documentation and context tasks are limited to the allowed write scope defined in `c:\Projects\CLAUDE.md`.
- Do not modify application source, config, dependency, environment, deployment, data, or generated files during documentation tasks.

### Output Discipline

- Do not invent business facts, API routes, data models, or product decisions.
- If source material is missing, add a clearly marked TODO.
- If existing documents conflict, stop and report the conflict rather than choosing silently.
- Do not reinterpret, modernize, or reconcile existing business context.
- Preserve exact wording from source documents when migrating content.

### Escalation

- Stop and report if a target file already has nontrivial content that was not accounted for.
- Stop and report if two source documents provide conflicting facts about the same subject.
- Stop and report if a task would require touching files outside the allowed write scope.

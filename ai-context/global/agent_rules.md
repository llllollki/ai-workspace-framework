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

### Subagents and Parallel Workers

These rules apply to Claude Code, Codex, and any other agent runtime that supports subagents, parallel workers, or delegated agent tasks.

- Subagent consideration is mandatory for every task, even when the user prompt does not mention subagents.
- At the start of each task, decide whether at least two parts of the work can run independently and be merged safely.
- If the runtime supports subagents or parallel workers and independent workstreams exist, use them by default.
- Good default workstreams include independent codebase exploration, database/RLS work, frontend implementation, documentation updates, deployment preparation, and verification or build-failure investigation.
- Do not create subagents for small, single-file, tightly coupled, or design-sensitive changes where coordination overhead is greater than the work itself. This is an explicit exception, not the default.
- When subagents are used, assign each one a clear ownership area, avoid overlapping file edits, and have the main agent review, integrate, run checks, and deploy when deployment is part of the task.
- If the runtime does not support subagents or parallel workers, proceed serially and state that limitation clearly when the task is broad enough that subagents would otherwise have been used.
- These rules apply across existing projects, new projects, and framework maintenance tasks.

Recommended prompt language:

```text
Follow the workspace subagent policy automatically. At task start, evaluate whether independent workstreams exist. If the runtime supports subagents or parallel workers, use them by default for independent codebase exploration, database/RLS work, frontend implementation, docs, deployment preparation, and verification. If subagents are unavailable or not warranted, state the reason briefly and proceed serially.
```

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

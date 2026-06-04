# Source of Truth (Framework Duplication)

## The situation

The framework currently exists in **two trees**:

| Tree | Role |
|---|---|
| `github.com/llllollki/ai-workspace-framework` ≙ `c:\Projects\ai-workspace-framework\` | **Canonical**, version-controlled, portable home of the framework |
| `c:\Projects\ai-context\` (+ root `CLAUDE.md`/`AGENTS.md`) | **Working copy** that Claude Code actually reads in this workspace |

These are separate directories kept in sync **by hand**, so they drift. Observed drift (2026-06-04):
the working copy was ahead on framework structure (root `CLAUDE.md`/`AGENTS.md`, the safety layer);
the repo was ahead on alh-tracker project/task content. Root `CLAUDE.md`/`AGENTS.md` have since been
reconciled (identical in both trees); broader `ai-context\` content drift remains.

## Recommendation (do not delete anything)

**Pick one of these and adopt it as policy:**

1. **(Preferred) Make the working copy a checkout of the repo.** Turn `c:\Projects\` (or
   `c:\Projects\ai-context\`) into a git clone of `ai-workspace-framework`, so there is exactly one
   source. Edits are committed once and consumed in place — no copy step, no drift.
2. **One-way sync discipline.** If two trees must remain, declare the **repo canonical**, edit there
   first, and treat `c:\Projects\ai-context\` as a generated mirror refreshed from the repo. Never
   edit the working copy directly.

Until one is adopted, every framework change must be applied to **both** trees in the same change
(as was done for this upgrade).

## Standing rules

- **`CLAUDE.md` and `AGENTS.md` are updated together** — a change to one requires the matching change
  to the other so Claude Code and Codex never read divergent rules.
- `c:\Projects\ai-workspace-framework\` is **canonical, not stale** — do not treat it as a duplicate
  to be removed.

## Other directories to confirm

- **`c:\Projects\printing\`** carries its own `CLAUDE.md`/`AGENTS.md` but is **not** in the workspace
  Projects table (`CLAUDE.md` root). Decide: add it to the workspace projects, or confirm it is an
  independent project outside this framework's scope. _TODO — owner decision._

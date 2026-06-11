# Framework Lint

`setup\lint_framework.ps1` runs structural consistency checks over the framework and exits
nonzero with a per-finding report when anything is broken. It runs under Windows PowerShell 5.1.

## Usage

```text
powershell -NoProfile -File setup\lint_framework.ps1
powershell -NoProfile -File setup\lint_framework.ps1 -RepoRoot c:\path\to\checkout
```

`-RepoRoot` defaults to the parent of `setup\` (the repo root).

## Checks

| Code | Check |
|---|---|
| `REF` | Every file referenced (backtick-quoted relative path) by `ai-context\skills\skills_index.md`, `ai-context\orchestration\routing_rules.md`, `ai-context\orchestration\context_rules.md`, or `ai-context\README.md` exists on disk. Placeholders containing `<`/`>` and bare filenames without a path component are skipped. |
| `ID` | Within `ai-context\tasks\active|backlog|done`, a task ID number does not appear on two files with different slugs for the same project (an ID collision). Project dirs are discovered generically. |
| `DUP` | The same task ID+slug does not exist in two lifecycle dirs (a stale lifecycle duplicate left behind by a task move). |
| `SYNC` | Root `CLAUDE.md` and `AGENTS.md` are byte-identical (the enforceable definition of "updated together"). |

## When to run

- Before opening a framework PR (part of the framework Definition of Done for documentation tasks).
- After moving a task between lifecycle dirs.
- After adding or renaming a skill, or editing any index/routing file.

## Fixing findings

- `REF` — restore the missing file or remove the stale index/routing entry.
- `ID` — renumber one of the colliding tasks to the next unused number across all three
  lifecycle dirs for that project (see the task ID allocation rule in
  `ai-context\orchestration\planning_rules.md`). Never renumber a file referenced by
  ADRs/decisions; prefer renumbering the less-referenced or backlog copy.
- `DUP` — the more advanced lifecycle dir wins; verify the surviving copy is current,
  merge any unique content from the stale copy, then delete the stale copy.
- `SYNC` — apply the same change to both `CLAUDE.md` and `AGENTS.md` so they are identical.

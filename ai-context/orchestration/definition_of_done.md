# Definition of Done

## Responsibility

Defines when a task may move to `tasks\done\`. This is a **hard precondition** enforced by
`execution_rules.md`, not advisory.

## The gate

A task is `done` only when:

1. Every **DEFINED** gate step (below) ran and **passed**.
2. Acceptance criteria in the task doc are met.
3. If deploy is in scope, **post-deploy smoke passed** (see `skills\core\verify_and_ship_v1.md`).

Run the gate via the `verify-and-ship` skill. Never mark `done` on any failure.

## Command-variable status model

Each variable has exactly one status:

| Status | Meaning | Gate behavior |
|---|---|---|
| `DEFINED` | a concrete command string is given | run it; it MUST pass |
| `TODO` | capability intended, not wired yet | record `SKIPPED (TODO)`; allowed **only if not on `REQUIRED_FLOOR`**; must emit a `tech-debt:` line |
| `N/A` | does not apply to this project (justify inline) | skipped; not tech debt |

A variable on the project's **`REQUIRED_FLOOR`** that is `TODO` **fails the gate** (`needs input`),
so the floor can never be silently skipped.

## Variables

`TARGET_ENV`, `PREFLIGHT_CMD`, `TYPECHECK_CMD`, `LINT_CMD`, `TEST_CMD`, `BUILD_CMD`, `MIGRATE_CMD`,
`RLS_VERIFY_CMD`, `DEPLOY_CMD`, `SMOKE_CMD`.

Do not guess commands. Unknown = `TODO`, never invented.

## Per-project scaffolding

### alh-tracker (Vite + React + TS + Supabase; deploy: Vercel)

```text
TARGET_ENV     = preview            # production requires a matching allow-list entry
PREFLIGHT_CMD  = npm run verify:secrets        # DEFINED
TYPECHECK_CMD  = N/A (covered by BUILD_CMD: build runs `tsc && vite build`)
LINT_CMD       = TODO  # no ESLint configured -> tech-debt
TEST_CMD       = npm run test:provisioning     # DEFINED but PARTIAL (only tests/provisioning); TODO broaden
BUILD_CMD      = npm run build                 # DEFINED [FLOOR]
MIGRATE_CMD    = supabase db push              # DEFINED; forward-only; NEVER auto-retry; precondition: project linked + SUPABASE_* env
RLS_VERIFY_CMD = TODO  # add: anon client SELECT on protected table -> 0 rows/denied
DEPLOY_CMD     = TODO  # confirm exact Vercel CLI/flags (preview vs --prod)
SMOKE_CMD      = TODO  # GET / ->200; auth round-trip; RLS positive; RLS anon-denied
REQUIRED_FLOOR = [BUILD_CMD]        # TEST_CMD joins floor once a real `test` script exists
```

### AssistedLivingHelp (Next.js-ish web+API, SQLite) — PATH NOT CONFIRMED

`c:\Projects\AssistedLivingHelp` is empty/absent; a `c:\Projects\alh\` dir may be it. **Do not
invent commands.** Until `PROJECT_PATH` is confirmed, the gate returns `needs input`.

```text
PROJECT_PATH   = TODO  # confirm location + package manager first
PREFLIGHT_CMD  = TODO
TYPECHECK_CMD  = TODO  # likely tsc --noEmit / next typecheck — confirm
LINT_CMD       = TODO  # likely next lint — confirm
TEST_CMD       = TODO  # no test framework -> "not yet enforced", off floor, tech-debt
BUILD_CMD      = TODO  # likely next build [FLOOR once path known]
MIGRATE_CMD    = N/A   # SQLite is read-only data load — confirm
DEPLOY_CMD     = TODO
SMOKE_CMD      = TODO  # GET /api/health ->200 + one route proving SQLite loaded (count>0)
REQUIRED_FLOOR = [BUILD_CMD]        # gate returns `needs input` until PROJECT_PATH confirmed
```

## Related

- `skills\core\verify_and_ship_v1.md` — the executable gate (Codex mirror of the Claude skill)
- `global\enforcement_design.md` — permission/allow-list policy the deploy step obeys
- `orchestration\execution_rules.md` — makes this gate a precondition for `done`

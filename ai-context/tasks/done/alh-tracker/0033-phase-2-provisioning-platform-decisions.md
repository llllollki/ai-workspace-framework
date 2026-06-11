# Task 0033 — Phase 2 Provisioning Platform Decisions (ADR 0012)

Status: done
Created: 2026-05-20
Owner role: AI agent (main)
Reviewers: n/a

---

## Goal

Create ADR 0012 to resolve the four Phase 2 provisioning blockers that prevent backlog task
0028 (provisioning endpoint) from beginning, plus clarify or explicitly defer the remaining
open TODOs from ADRs 0007, 0008, and 0009 that were not resolved by Phase 1 migrations
(task 0030).

Scope: architecture/documentation only. No application code, migrations, environment files,
dependency changes, or generated files changed.

---

## Acceptance Criteria

- [x] New ADR 0012 created at `decisions/0012-phase-2-provisioning-platform-decisions.md`.
- [x] ADR contains: options considered, decision, rationale, consequences, implementation notes,
      and remaining TODOs for each of the eight items.
- [x] ADR status: `proposed`.
- [x] `ai_memory.md` updated: four Phase 2 provisioning blockers marked resolved (or narrowed
      if partially resolved) by ADR 0012.
- [x] `decisions/README.md` updated with ADR 0012 row.
- [x] `execution_log.md` updated with one-line summary.
- [x] Task doc created under `tasks/done/alh-tracker/` with Goal, Acceptance Criteria, Plan,
      Notes, and Outcome sections.
- [x] All ai-context changes mirrored to `c:\Projects\ai-workspace-framework\ai-context\`.
- [x] No application source, config, dependency, migration, env, or generated files changed.

---

## Plan

- [x] Read all required startup context (workspace + project rules + ADRs 0007–0011 + task 0030)
- [x] Evaluate the four Phase 2 blockers and make decisions (endpoint hosting, idempotency storage,
      email service, users.created_by)
- [x] Evaluate and resolve/defer remaining items (retry conflict, re-provision, token_expired_passive,
      alert delivery)
- [x] Write ADR 0012
- [x] Update ai_memory.md
- [x] Update decisions/README.md
- [x] Update execution_log.md
- [x] Write this task doc
- [x] Mirror all changes to ai-workspace-framework

---

## Subagent Policy

Not used. This task is design-sensitive (all ADR decisions must be authored coherently) and
all writes depend sequentially on ADR 0012 content. No independent workstreams exist. Proceeding
serially per the workspace policy exception for tightly coupled, single-author design tasks.

---

## Notes

### Decision reasoning summary

**Endpoint hosting — Supabase Edge Function:**
The tracker is a Vite SPA with no existing Vercel API layer. Adding Vercel API routes would
require `vercel.json` restructuring and introduces a Node.js runtime alongside a pure SPA build.
Supabase Edge Functions are the natural tracker-side backend extension point: the service-role key
stays within the Supabase environment, the Deno Web Crypto API covers all cryptographic requirements,
and Supabase's scheduling primitives (pg_cron, Scheduled Functions) support the `token_expired_passive`
sweep without external infrastructure.

**Idempotency storage — Supabase table:**
At MVP provisioning volume (single-digit to low-tens of new facilities per month), a PostgreSQL
table read is negligible overhead. The provisioning flow is already entirely within Supabase;
keeping idempotency co-located simplifies the stack, provides audit co-location, and eliminates
an external service dependency (vs. Upstash Redis). No additional credentials, billing, or
service account required.

**Email service — Resend:**
Zero cost at MVP volume (free tier: 3,000 emails/month). Deno-compatible via REST API. SPF/DKIM/DMARC
domain verification supported. Postmark documented as the preferred fallback if deliverability
proves insufficient — migration is a client call swap, not an architectural change.

**`users.created_by` — nullable UUID:**
CRM staff are not tracker users (ADR 0005/0006). Creating a sentinel tracker User for CRM
violates principal separation. NULL is semantically correct: no tracker User created the account.
Full provenance is recoverable from `ProvisioningEvent` (event_type = 'provisioned', actor_id =
CRM staff ID). No schema migration needed — the column already supports NULL.

**Retry payload conflict — ignore conflicting fields, log:**
Conflicting data on a retry indicates a CRM-side inconsistency, not an intent to update. The owner
corrects facility data during post-activation setup. Silently overwriting with retry data risks
corrupting correct data; returning 409 adds operational burden on CRM for a CRM bug scenario.

**Re-provision disabled User — permitted, reset to invited:**
Revocation + re-provisioning is a legitimate CRM workflow. Reusing the existing Facility record
is correct (the CRM relationship is unchanged). Returning a new `provisioning_reference` signals
a fresh provisioning attempt to the CRM.

**`token_expired_passive` — add back via migration:**
The Phase 1 migration omitted it (per ADR 0007's "remove if no cleanup job" guidance). Now that
the endpoint hosting decision commits to Supabase Edge Functions with scheduling support, the
sweep is feasible. Passive expiry events improve audit completeness — they identify which invited
owners never activated.

**Alert delivery — deferred:**
The threshold counter and rate limiting are implemented in the endpoint; the delivery channel
(email, Slack) requires operational setup beyond the provisioning code. Deferred to a monitoring
task that must be closed before production launch.

### Stale active/backlog tasks

Task `0026-provisioning-readiness-audit.md` remains in `tasks/active/alh-tracker/`. It documented
the Phase 1 blockers, four of which are now resolved by ADR 0012 (proposed). This task was
effectively completed by tasks 0027–0030 and now 0033. It could be moved to done; however, this
is outside the scope of the current task (the prompt scope says "note it but do not delete unless
clearly within scope"). Noted here for the next task queue cleanup pass.

Backlog tasks `0028-provisioning-api-endpoint.md` and `0029-activation-endpoint-and-page.md`
remain in backlog and are now the immediate implementation targets once ADR 0012 is accepted.

---

## Outcome

ADR 0012 created (`decisions/0012-phase-2-provisioning-platform-decisions.md`) with status
`proposed`. Resolves all four Phase 2 provisioning blockers. Clarifies two edge-case behaviors
(retry conflict, re-provision). Resolves `token_expired_passive` enum decision. Defers alert
delivery to a pre-production monitoring task. `ai_memory.md` updated, `decisions/README.md`
updated, `execution_log.md` updated. All changes mirrored to `ai-workspace-framework`.
No application code or schema files changed.

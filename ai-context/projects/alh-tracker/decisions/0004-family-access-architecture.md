# 0004 — Family Access Architecture

**Date:** 2026-05-09
**Status:** accepted
**Supersedes:** n/a
**Superseded by:** n/a

## Context

The alh-tracker MVP does not include a family portal, but the Phase 2 roadmap includes family access to care summaries. Building the MVP data model without a durable family access architecture decision risks a significant schema migration when Phase 2 begins. The current data model already contains ResidentContact and FamilyAccessConsent stubs; this decision finalizes the architectural posture those stubs encode.

Key tensions to resolve:
- Family members want care visibility; residents have autonomy over their personal information. These interests do not always align.
- Operational simplicity (one database) vs. privacy separation (a derived summary store).
- Low-friction family access vs. the consent and liability obligations that come with sharing health-adjacent information about identified individuals.

This decision covers the architecture and data model only. The family portal product design, exact UI language, consent notices, and legal sufficiency of the consent model require Compliance / Privacy Counsel review before Phase 2 implementation.

## Decision

### 1. Family access is deferred from MVP

ResidentContact and FamilyAccessConsent table stubs are present in the MVP schema but empty. No family-facing feature is built in Phase 1. This prevents schema migrations when Phase 2 begins.

### 2. Family access is always read-only

Family contacts cannot create, edit, or delete any care log entry, resident record, or facility record. This is a hard architectural constraint — not operator-configurable.

### 3. Dual acknowledgment before any access is granted

Two conditions must be recorded before a family contact may access resident care data:
1. **Operator authorization:** An `owner` or `admin` role user creates a FamilyAccessConsent record. Caregivers cannot grant family access.
2. **Resident autonomy noted:** The operator records whether they considered the resident's preference (`resident_autonomy_noted` field on FamilyAccessConsent). The software cannot verify actual resident consent — that is the operator's responsibility — but it creates an auditable record that the question was addressed. If the operator records that the resident declined or restricted access, the system surfaces a warning before completing the grant.

### 4. Access defaults to summary level; full notes require explicit authorization

Each FamilyAccessConsent record has an `access_level` of either `summary` or `full_notes`.

- `summary` (default): family contact sees status-level observations — no raw caregiver note text. Summary generation is a read-time transformation (rule-based at Phase 2 MVP; AI-generated summaries are explicitly deferred and require separate review before use).
- `full_notes`: raw caregiver note text is visible. This requires explicit operator selection and must be reviewed by counsel before the feature is built.

### 5. Access is scoped to specific log categories

Each FamilyAccessConsent record specifies a `category_scope` (JSON array of log category values). Incident notes (`incident`) and observed care tasks (`observed_care_task`) are not included in any default scope — they require explicit opt-in.

### 6. Same primary database; row-level authorization at query layer

Family portal queries are filtered at the query layer by: (a) which residents the contact has a valid, non-revoked FamilyAccessConsent for; (b) which log categories are in scope; (c) access level. There is no separate derived summary store at this stage.

Rationale: a separate summary store would require dual-write logic, introduces sync lag and divergence risk, and is premature optimization before Phase 2 validates demand. Row-level authorization in a single database is simpler to maintain and audit.

### 7. Family contacts are not User entity records

Family contacts authenticate via a separate mechanism (email magic link or dedicated family portal login). They do not have User records in the facility-facing User table. This prevents session and permission scope overlap between caregiver/owner sessions and family sessions.

### 8. All family access events are logged in AuditTrail

Every family portal read event must be recorded: which contact, which resident, which categories, at what time, under which consent record. This is required before any family contact is given access.

## Consequences

**Easier:** Phase 2 family portal can be built without schema migration. Privacy posture is conservative by default — no access is granted without explicit operator action. Resident autonomy is structurally acknowledged in the data model. Audit trail enforced from day one. Category-level scoping gives operators fine-grained control.

**Harder:** Summary generation requires a read-time transformation layer (some implementation complexity). Dual acknowledgment model requires a multi-step operator flow (slightly more friction than a single checkbox). Full notes access is blocked pending counsel review — operators who want family to see caregiver notes must wait for Phase 2 counsel sign-off. The architecture explicitly defers resident-side access control (resident actively revoking a family contact's access via the product) — this may need to be revisited based on counsel guidance or regulatory requirements.

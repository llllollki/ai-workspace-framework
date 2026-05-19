# 0030 — CRM UI: Provisioning Integration

Status: backlog
Created: 2026-05-19
Depends on: 0028 (provisioning API endpoint live)
Parallel with: 0031 (tracker auth changes)
Blocks: 0032
Audit source: 0026

## Goal

Update the internal CRM UI to surface provisioning status and enable ALH Tracker staff
to provision, resend, and revoke tracker facility owner accounts. This task covers type
changes, CRM Zustand store updates, and UI components. The CRM calls the tracker
provisioning endpoint server-side (CRM server → tracker API — never browser-direct).

## Current State (from audit 0026)

- `CrmFacility` type: no `provisioning_status` or `provisioning_reference` fields.
- `useCrmStore`: no provisioning actions; `addFacility`, `updateFacility`, `archiveFacility` exist.
- `CrmFacilityDetail.tsx`: onboarding checklist checkboxes are disabled (TODO at line 395);
  no provision/resend/revoke buttons.
- `CrmFacilities.tsx`: no provisioning status column.
- `CrmDashboard.tsx`: no provisioning metrics.

## Scope

### 1. Type Changes (`src/types/crm.ts`)

Add to `CrmFacility`:
```typescript
provisioning_status?: 'not_provisioned' | 'pending_setup' | 'active' | 'suspended' | 'closed';
provisioning_reference?: string; // opaque UUID returned by tracker API
```

Update `CrmOnboardingStage` enum: remove or replace `install_instructions_sent` with
provisioning-model milestones per `features.md` TODO. The new milestones should reflect
the actual ADR 0009 lifecycle: `provisioned`, `activation_pending`, `active`.

### 2. Store Updates (`src/store/useCrmStore.ts`)

Add actions:
- `provisionFacility(facilityId: string): Promise<void>` — calls tracker provisioning endpoint with `action: 'provision'`; updates local facility with returned `provisioning_status` and `provisioning_reference`
- `resendProvisioningInvite(facilityId: string): Promise<void>` — calls tracker with `action: 'resend'`
- `revokeProvisioningInvite(facilityId: string): Promise<void>` — calls tracker with `action: 'revoke'`

**Important:** The CRM must call the tracker provisioning endpoint server-side (CRM's
backend makes the HTTP call with the raw API key in the Authorization header). The raw
API key (`CRM_TRACKER_PROVISIONING_KEY`) must never appear in CRM client-side code or
be sent to the browser. If the CRM is a SPA without a backend, this call must go through
a CRM API route or a BFF (backend-for-frontend) pattern — this is a CRM architecture
decision, not a tracker concern.

The CRM receives back from the tracker: `{ status, provisioning_reference }` only.
The CRM stores `provisioning_reference` for correlation (opaque — not a tracker ID).

### 3. CrmFacilityDetail Updates (`src/pages/crm/CrmFacilityDetail.tsx`)

**Provisioning status display:**
Show provisioning status badge near facility header:
- Not provisioned → grey badge "Not provisioned"
- pending_setup → yellow badge "Invitation sent"
- active → green badge "Active"
- suspended/closed → red badge

**Provision button:**
- Show when `provisioning_status` is undefined/null or `not_provisioned`.
- Label: "Provision tracker account"
- On click: confirm modal → call `provisionFacility` → show success/error.
- Disable with spinner while request is in-flight.

**Resend invitation button:**
- Show when `provisioning_status = 'pending_setup'`.
- Label: "Resend invitation"
- On click: confirm modal → call `resendProvisioningInvite` → show success/error.

**Revoke invitation button:**
- Show when `provisioning_status = 'pending_setup'`.
- Label: "Revoke invitation"
- On click: confirm modal ("This will invalidate the owner's activation link") → call
  `revokeProvisioningInvite` → show success/error.

**Onboarding checklist:**
- Enable the checklist checkboxes (currently disabled at line 395 — the TODO).
- Update checklist items to align with provisioning-model lifecycle milestones.

### 4. CrmFacilities List Updates (`src/pages/crm/CrmFacilities.tsx`)

Add "Provisioning" status column to the facilities table:
- Same badge design as CrmFacilityDetail.
- Sort/filter by provisioning status.

### 5. CrmDashboard Updates (`src/pages/crm/CrmDashboard.tsx`)

Add provisioning metrics section:
- Count of facilities by provisioning_status bucket (not provisioned, pending_setup, active).
- Facilities with pending_setup > 48h (invitation aging alert).

## Acceptance Criteria

- [ ] `CrmFacility` type includes `provisioning_status` and `provisioning_reference`.
- [ ] `CrmOnboardingStage` enum updated to match provisioning lifecycle.
- [ ] `provisionFacility`, `resendProvisioningInvite`, `revokeProvisioningInvite` actions exist in store.
- [ ] CRM calls tracker provisioning endpoint server-side (raw API key never in browser).
- [ ] "Provision tracker account" button appears and works for unprovisioned facilities.
- [ ] "Resend invitation" and "Revoke invitation" appear and work for `pending_setup` facilities.
- [ ] Buttons disabled/loading during in-flight requests.
- [ ] Confirm modals shown before resend and revoke.
- [ ] Provisioning status badge visible in CrmFacilityDetail.
- [ ] Provisioning status column added to CrmFacilities list.
- [ ] Onboarding checklist enabled (line 395 TODO resolved).
- [ ] Provisioning metrics visible in CrmDashboard.
- [ ] No tracker IDs, raw tokens, or care data ever visible in CRM UI.

## Dependencies

- 0028 must be complete (tracker provisioning API endpoint live)
- CRM server-side call architecture must be confirmed (CRM BFF or API route)

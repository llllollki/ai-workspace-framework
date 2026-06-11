# 0036 — CRM UI: Provisioning Integration

Status: done
Created: 2026-05-19
Completed: 2026-05-20
Depends on: 0028 (provisioning API endpoint live)
Blocks: 0032
Audit source: 0026
Note: Backlog task was numbered 0030; renumbered 0036 to avoid collision with done task
      0030-provisioning-schema-rls-migrations.md.

## Goal

Update the internal CRM UI to surface provisioning status and enable ALH Tracker staff to
provision, resend, and revoke tracker facility owner accounts. Implement type changes, CRM
Zustand store updates, and UI components. CRM calls the tracker provisioning endpoint via a
clearly-isolated adapter stub that documents the required server-side CRM call architecture.

## Security Constraints

- `CRM_TRACKER_PROVISIONING_KEY` must never appear in browser code.
- `provisioning_reference` is opaque only — never interpreted as a tracker ID.
- No tracker `Facility.id`, `User.id`, raw tokens, token hashes, or activation URLs in CRM state or UI.
- Client code does not directly call the tracker Edge Function.
- Adapter stub documents the server-side requirement with explicit TODO comments.

## Deliverables

1. **`src/types/crm.ts`** — Added `CrmProvisioningStatus` type and `CRM_PROVISIONING_STATUS_LABELS`
   record. Renamed `CrmOnboardingStage` value `install_instructions_sent` → `tracker_provisioned`.
   Added `provisioning_status?: CrmProvisioningStatus` and `provisioning_reference?: string` (opaque)
   to `CrmFacility`. Renamed `CrmOnboardingChecklist.installInstructionsSent` → `trackerProvisioned`.

2. **`src/lib/crmProvisioningAdapter.ts`** (new) — Demo stub with `provisionFacility`,
   `resendProvisioningInvite`, `revokeProvisioningInvite`. Each function body has explicit TODO
   comments explaining that production calls must be server-side with `CRM_TRACKER_PROVISIONING_KEY`
   held server-side only. Simulates state changes locally in demo mode with 700ms delay.

3. **`src/store/useCrmStore.ts`** — Added `provisioningLoading: Record<string, boolean>`,
   `provisioningError: Record<string, string | null>` state. Added `provisionFacility`,
   `resendProvisioningInvite`, `revokeProvisioningInvite`, `clearProvisioningError` actions that
   call the adapter and update facility `provisioning_status`/`provisioning_reference` in-store.
   `addFacility` now sets `provisioning_status: 'not_provisioned'` and `trackerProvisioned: false`
   on new facilities.

4. **`src/data/crm-seed.ts`** — All `installInstructionsSent` checklist keys renamed to
   `trackerProvisioned`. All 7 seed facilities given `provisioning_status` values:
   crm-fac-001/002/005/007 → `active`; crm-fac-003 → `pending_setup`; crm-fac-004/006 → `not_provisioned`.
   Active and pending_setup facilities given opaque `provisioning_reference` placeholder UUIDs.

5. **`src/pages/crm/CrmFacilityDetail.tsx`** — `ProvisioningBadge` component. Provisioning row
   in facility header card: status badge, Provision/Resend/Revoke buttons (context-sensitive),
   spinner during in-flight requests, error display with dismiss, demo-mode notice, truncated
   `provisioning_reference` display. Three confirm modals (provision/resend/revoke) with demo
   disclaimer banners. Onboarding checklist made editable (click-to-toggle for non-archived
   facilities; read-only for archived). Checklist item label updated: "Install instructions sent"
   → "Tracker provisioned".

6. **`src/pages/crm/CrmFacilities.tsx`** — `ONBOARDING_BADGE` record updated:
   `install_instructions_sent` → `tracker_provisioned`. New `PROVISIONING_BADGE` record added.
   "Tracker" column added to facilities table (hidden at xl breakpoint).

7. **`src/pages/crm/CrmDashboard.tsx`** — Provisioning metrics section added between "Onboarding
   Status" and the follow-ups/notes grid: Not Provisioned / Invitation Sent / Tracker Active counts
   from active facilities. Demo-mode disclaimer note.

## Acceptance Criteria Met

- [x] `CrmFacility` type includes `provisioning_status` and `provisioning_reference`.
- [x] `CrmOnboardingStage` enum updated: `install_instructions_sent` → `tracker_provisioned`.
- [x] `provisionFacility`, `resendProvisioningInvite`, `revokeProvisioningInvite` actions exist in store.
- [x] CRM client code never directly calls tracker Edge Function with API key.
- [x] `CRM_TRACKER_PROVISIONING_KEY` appears only in adapter TODO comments — not as a value.
- [x] "Provision tracker account" button appears for unprovisioned facilities.
- [x] "Resend invitation" and "Revoke invitation" appear for `pending_setup` facilities.
- [x] Buttons disabled/loading during in-flight requests (spinner state).
- [x] Confirm modals shown before provision, resend, and revoke.
- [x] Provisioning status badge visible in CrmFacilityDetail header.
- [x] Provisioning status column added to CrmFacilities list.
- [x] Onboarding checklist enabled and editable (TODO at line 395 resolved).
- [x] Provisioning metrics visible in CrmDashboard.
- [x] No tracker IDs, raw tokens, token hashes, or care data in CRM UI or state.
- [x] `tsc --noEmit` clean, `vite build` clean.
- [x] Forbidden-string grep (`CRM_TRACKER_PROVISIONING_KEY`, `SERVICE_ROLE`, `token_hash`,
      `activation_url`) — matches only in adapter TODO comments; no actual secrets in browser code.

## Notes

- The CRM SPA has no backend; the adapter is a local demo stub. Production integration requires
  a CRM server-side route (Vercel API route or similar) that holds `CRM_TRACKER_PROVISIONING_KEY`
  and proxies the call to `supabase/functions/provision-owner`.
- `FacilityFormModal.tsx` required no changes — it uses `Object.keys(CRM_ONBOARDING_STAGE_LABELS)`
  dynamically, so `tracker_provisioned` is automatically included after the type update.
- Demo revoke clears `provisioning_reference` locally; production revoke must call the tracker API
  which will also expire the ProvisioningToken.

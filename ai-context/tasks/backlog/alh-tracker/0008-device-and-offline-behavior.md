# Task 0008 — Device and Offline Behavior

**Project:** alh-tracker
**Status:** backlog
**Created:** 2026-05-05
**Owner role:** Technical Architect
**Reviewers:** Product / Program Lead, Developer

---

## Goal

Define the responsive PWA device strategy and offline/flaky-network behavior requirements before implementation begins.

The product must work on caregiver phones, shared tablets, and desktop. Network conditions in small residential care homes are often unreliable. The product must never silently lose a log entry.

---

## Acceptance Criteria

1. A device-tier matrix: what features and interaction patterns are required, recommended, or optional for each device class (phone, tablet, desktop).
2. An offline behavior specification:
   - How does the app detect offline or degraded network state?
   - How does it communicate this state to the user (e.g., "saved locally, will sync")?
   - What data is available offline (shift board, resident roster, routine list)?
   - How does sync work when connectivity returns?
   - What happens if two caregivers log the same event while offline?
3. A PWA specification: is a service worker required for offline storage? What caching strategy is used for shift board and resident data?
4. A minimum network requirement documented: what is the minimum connection spec, and what is the graceful degradation behavior below it?
5. Sync conflict scenario documented: two caregivers log the same routine for the same resident simultaneously while offline — how is this resolved?
6. These requirements are reflected in the technical architecture before Phase 1 implementation begins.
7. Non-functional requirements section in `features.md` updated with offline behavior spec.

---

## Plan

- [ ] Define the three device tiers and their distinct UX requirements:
  - Phone: one-handed, fastest logging, portrait-primary
  - Tablet (shared): shift board overview, handoff display, landscape-friendly
  - Desktop: owner/admin setup, reports, export, full keyboard/mouse
- [ ] Define the offline event queue: how are log entries queued locally when the network is unavailable?
- [ ] Define the sync strategy: optimistic writes, conflict resolution, sync-on-reconnect
- [ ] Define what resident and shift data must be pre-fetched and cached for offline use
- [ ] Define the visual offline state indicator for each device tier
- [ ] Define the sync conflict resolution scenario: last-write-wins, flag for review, or merge?
- [ ] Define PWA requirements: service worker scope, local storage strategy (IndexedDB vs. Cache API), background sync support
- [ ] Check background sync API compatibility for older Android browsers (common among caregivers)
- [ ] Document minimum browser and OS requirements for caregiver phones
- [ ] Update `features.md` non-functional requirements section with offline behavior spec

---

## Notes

- Small RCFE homes vary significantly in WiFi quality. A realistic target environment: one shared WiFi router serving a 10-room residential house, with inconsistent signal in back bedrooms.
- The offline event queue must survive the user closing and reopening the browser tab before sync occurs. In-memory state only is not sufficient — the queue must be persisted to local storage.
- The "saved locally, will sync" indicator is a trust feature as much as a technical one. Caregivers must never have to guess whether their log entry was recorded.
- If Background Sync API (part of the Service Worker spec) is used, verify compatibility on common low-cost Android devices before committing to it. Fallback to manual sync-on-reconnect may be more reliable for the target device range.
- The design partner site visit (task 0002) should include a WiFi quality observation: what is the actual network environment at the facility? Are there dead spots?

---

## Outcome

<!-- To be filled when the task is completed. -->

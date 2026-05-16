# Task 0008 — Device and Offline Behavior

**Project:** alh-tracker
**Status:** active
**Created:** 2026-05-05
**Activated:** 2026-05-09
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

- [x] Define the three device tiers and their distinct UX requirements
- [x] Define the offline event queue: how are log entries queued locally when the network is unavailable?
- [x] Define the sync strategy: optimistic writes, conflict resolution, sync-on-reconnect
- [x] Define what resident and shift data must be pre-fetched and cached for offline use
- [x] Define the visual offline state indicator for each device tier
- [x] Define the sync conflict resolution scenario: flag for review
- [x] Define PWA requirements: service worker scope, local storage strategy (IndexedDB), background sync posture
- [x] Check background sync API compatibility for older Android browsers (common among caregivers) — see note below
- [x] Document minimum browser and OS requirements for caregiver phones
- [x] Update `features.md` non-functional requirements section with offline behavior spec
- [ ] Validate offline behavior assumptions at design partner site visit (task 0002): what is actual WiFi quality at the facility? Are there dead spots?

---

## Notes

- Small RCFE homes vary significantly in WiFi quality. A realistic target environment: one shared WiFi router serving a 10-room residential house, with inconsistent signal in back bedrooms.
- The offline event queue must survive the user closing and reopening the browser tab before sync occurs. In-memory state only is not sufficient — the queue must be persisted to local storage.
- The "saved locally, will sync" indicator is a trust feature as much as a technical one. Caregivers must never have to guess whether their log entry was recorded.
- Background Sync API compatibility is limited on low-cost Android devices (Xiaomi, Samsung entry-level lines common in this caregiver demographic). Decision: do not require it. Use foreground sync with visible progress instead.
- The design partner site visit (task 0002) should include a WiFi quality observation: what is the actual network environment at the facility? Are there dead spots? This is the one item that requires real-world validation.

---

## Planning Notes

**Activated 2026-05-09.** This task is not blocked by design partner or counsel. The offline behavior spec can be locked as a conservative PWA model now and validated against real facility WiFi conditions during the design partner site visit (task 0002).

**Design direction confirmed at activation:**
- Conservative PWA model: visible offline state, local queue, explicit sync status, no silent loss, conflict handling that flags for review rather than overwrites care notes.
- Do not build for optimistic silent conflict resolution. A flagged duplicate is always safer than a silently discarded care observation.
- No Background Sync API dependency due to compatibility concerns on the target device class.
- IndexedDB-backed queue for durability across tab close/reopen.

---

## Outcome

### 1. Device Tier Matrix

| Device | Priority | Primary role | Required features |
|---|---|---|---|
| **Caregiver phone** | 1 (highest) | Shift logging | Fastest log path, one-handed portrait use, large touch targets (min 44px), <10 seconds per log entry, offline badge clearly visible, resident/routine pre-loaded |
| **Shared tablet** | 2 | Shift board overview, handoff display, shared station | Landscape-friendly layout, multi-resident roster view, shared session awareness (visible current user), handoff summary readable at a glance |
| **Desktop** | 3 | Owner/admin setup, reports, export | Full keyboard/mouse, no mobile UX constraints, rich review and export flows |

All three tiers use the same PWA — responsive layout adapts to device class. No native app is built.

#### Device-specific UX notes

**Phone (Priority 1):**
- Portrait-primary layout; landscape is supported but not required to be optimized at MVP
- Resident context and shift period must be visible without scrolling
- Quick status buttons must be reachable without repositioning the hand
- Undo path for any one-tap action (visible for 5 seconds after logging)
- Offline indicator must not require scrolling to see

**Shared tablet (Priority 2):**
- Shift board may be left open on the shared tablet as a station display
- Session must show the current active user's name visibly (not just logged-in — named)
- Quick per-shift PIN switch is needed if multiple caregivers share the tablet without logging out (see task 0003 — auth model not yet finalized; the offline spec should not presuppose the auth model but must be compatible with both individual accounts and shared-tablet session models)
- Handoff summary display should be optimized for a tablet propped on a counter

**Desktop (Priority 3):**
- Owner/admin-focused: resident setup, routine configuration, shift review, data export
- Standard web forms and keyboard navigation
- No specific offline logging optimization required for desktop (owners typically have stable network)

---

### 2. Offline Behavior Specification

#### 2A — Offline Detection

**Method:** Two-signal detection.

1. `navigator.onLine` browser property — fires immediately on network drop; not always reliable on its own (may report "online" on a captive portal or degraded connection).
2. Periodic lightweight ping to a known health endpoint (e.g., `/api/ping`) — every 30 seconds. If two consecutive pings fail within a 60-second window, enter offline mode regardless of `navigator.onLine` value.

**Transition to offline mode:** Enter offline mode when either (a) `navigator.onLine` becomes `false` or (b) two consecutive pings fail. Do not wait for the caregiver to notice something is wrong.

**Transition back to online:** When `navigator.onLine` becomes `true` AND a ping succeeds, restore online mode and begin sync.

---

#### 2B — Visual Offline State Indicator

Offline state must always be visible. Caregivers must never have to guess whether their entry was saved.

**Persistent offline banner:** A fixed-position banner at the top of the screen (below the nav bar) displaying:

> "No connection — entries saved locally. Will sync automatically when connected."

Banner color: amber/orange (not red — red implies an error, not a temporary state).

**Per-entry sync badge:** Every entry logged while offline receives a small "clock" or "pending sync" badge visible in the shift log list. Badge disappears when the entry is confirmed synced to the server.

**Sync progress on reconnect:** When online mode is restored and sync begins:
- Banner changes to: "Syncing [N] saved entries..."
- When complete: "All synced" confirmation (green) for 3 seconds, then banner hides.

**Sync failure state:** If sync fails (server returns an error for a queued entry), display a persistent warning:
> "Sync error — tap to review [N] entries that could not be saved."
This state requires active caregiver or admin acknowledgment before it can be dismissed.

---

#### 2C — Local Event Queue

**Storage:** IndexedDB. The queue must survive:
- Tab close and reopen
- Browser refresh
- App backgrounded on a phone
- Device sleep/wake cycle

In-memory state only is explicitly not sufficient.

**Queue structure:** Each queued entry stores:
- Full CareLogEntry payload (resident_id, routine_id, category, status, note, logged_at, shift_id)
- Optimistic local ID (UUID generated client-side)
- Queued-at timestamp
- Sync status: `pending` | `syncing` | `synced` | `error`
- Retry count (capped at 3 before surfacing as sync error)

**Queue capacity:** Designed to hold up to 200 entries before sync. This covers a full 8-hour shift across 20 residents at 1 entry per resident per shift event — a realistic worst-case offline period.

**Queue persistence guarantee:** The queue is never cleared until the server returns HTTP 201 (or 200) confirming the write. Client-side display of the entry as "saved" is optimistic; the server confirmation clears the queue.

---

#### 2D — Pre-Cached Data (Available Offline)

The following must be pre-fetched and cached (via Cache API or IndexedDB) when the app loads or when the caregiver begins their shift:

| Data | Why cached | Staleness tolerance |
|---|---|---|
| Current shift's resident roster (names, rooms, is_active) | Required to log any entry | Refresh at shift start; stale after 8 hours |
| Active routines for current shift period | Required to surface routine logging prompts | Refresh at shift start |
| Today's open shift record (shift_id, shift_period, started_at) | Required to associate entries to a shift | Refresh at shift start |
| Current user's profile and role | Required for auth context offline | Refresh at login |
| Previous shift's handoff summary (read-only) | Provides incoming caregiver context at shift start | Refresh at shift start; acceptable if stale |

The following are **NOT** cached for offline use at MVP:
- Historical care log data beyond the current shift
- Other users' offline queues
- Owner/admin analytics and reports
- Resident setup and routine configuration (these require network; an offline caregiver cannot modify resident records)

---

#### 2E — Sync Strategy

**Optimistic writes:** When a caregiver logs an entry, it is saved to IndexedDB immediately and displayed in the local shift log. The caregiver does not wait for server confirmation. The entry is marked as pending sync.

**On reconnect:** The sync queue is flushed in chronological order (FIFO by `logged_at`). Entries are sent one at a time or in small batches (max 10 per request) to avoid overwhelming a slow reconnection.

**Timestamp handling:** The `logged_at` timestamp (when the caregiver recorded the observation) is set client-side at the moment of logging and is preserved through sync. The `created_at` timestamp (when the record is written to the database) is set server-side at the moment of successful sync. Both timestamps must be retained — `logged_at` reflects the care event timing; `created_at` reflects when it entered the server record.

**Automatic sync:** Sync fires automatically when online mode is restored. No manual trigger is required from the caregiver. A "Sync now" button is available as a manual fallback but should not be the primary mechanism.

**Sync retry:** Failed entries are retried up to 3 times with exponential backoff (2s, 8s, 30s). After 3 failures, the entry is surfaced as a sync error requiring acknowledgment.

---

#### 2F — Sync Conflict Resolution

**Scenario: Two caregivers log the same routine for the same resident while offline simultaneously.**

This can occur when two caregivers share a shift and both log the same event (e.g., both log "Breakfast — Done" for Resident A) while offline.

**Resolution policy: Flag for review. Do not auto-discard either entry.**

Both entries are written to the server when each caregiver's queue syncs. The system detects the duplicate pattern (same resident_id, same routine_id, same shift_id, status logged within a short window — e.g., 15 minutes) and surfaces a "Review needed" notice to the shift owner or admin:

> "Two log entries were recorded for [Resident Name] — [Routine] on this shift. Please review and confirm which entry is accurate."

The owner or admin resolves the duplicate via the shift review interface. Both entries remain in the AuditTrail permanently. The resolution action (confirming one, marking the other as duplicate) is also audited.

**What not to do:**
- Do NOT auto-merge (there is no safe merge strategy for care observations)
- Do NOT auto-discard the later entry (the later entry may be the more accurate one)
- Do NOT block the caregiver's logging action because a potential duplicate might exist — blocking logging during an offline period causes more harm than a duplicate that gets reviewed later

**Scenario: Same caregiver logs the same routine twice in an offline period.**

When that caregiver's queue syncs, the system detects the duplicate (same user, same resident, same routine, same shift, within a short window). Surface a warning to the caregiver on the sync completion screen:

> "It looks like you logged [Routine] for [Resident Name] twice during your offline session. Please review and confirm."

The caregiver can dismiss one or confirm both (if they intentionally logged twice). Both entries remain in the AuditTrail.

---

### 3. PWA Specification

**Service worker:** Required. Scope: the entire alh-tracker application.

**App shell caching (Cache API):** Cache the application shell (HTML, CSS, JS bundles) for instant load on poor connections. This ensures the app opens even before server contact is established. Cache update strategy: stale-while-revalidate for the app shell.

**Data caching (IndexedDB):** All shift data, resident roster, and the offline event queue are stored in IndexedDB. Do not use Cache API for dynamic data — it is designed for static assets, not structured care records.

**Background Sync API:** Do not depend on it. Compatibility on low-cost Android devices (common caregiver demographic) is inconsistent. Fallback: foreground sync fires automatically when the app is in the foreground and network restores. If the app is closed or backgrounded during an offline period, the IndexedDB queue persists; sync runs when the app is next opened.

**Install prompt:** The app should be installable as a PWA (manifest.json, service worker registered). Display the install prompt opportunistically — not on first visit. Do not require installation to use the app.

**Push notifications:** Deferred. Not MVP. Do not build notification infrastructure as part of this spec.

---

### 4. Minimum Network and Browser Requirements

**Minimum browser/OS for caregivers (phone):**
- Android: Chrome 80+ on Android 9+ (2019 or newer); Samsung Internet 12+ acceptable
- iOS: Safari on iOS 14+ (2020 or newer); Chrome for iOS acceptable
- Required capabilities: Service Worker API, IndexedDB, Cache API

**Minimum browser for desktop:**
- Chrome 80+, Firefox 75+, Edge 80+ (any major browser released 2020+)
- IE11 and legacy WebView: not supported

**Minimum network for full functionality:**
- No minimum — the app degrades gracefully to full offline mode at any network level including zero
- Sync requires a working connection of any speed; bulk sync of a large queue may be slow on 2G but will complete

**Graceful degradation below minimum:**
- No connection: full offline mode (queue, cache, no data loss)
- Intermittent connection: partial sync where possible; remaining items queued
- Slow connection: sync takes longer; progress is visible; caregiver is not blocked

---

### 5. Acceptance Criteria Status

| Criterion | Status |
|---|---|
| 1. Device-tier matrix | ✅ Complete — Section 1 |
| 2. Offline behavior specification | ✅ Complete — Section 2 (detection, indicator, queue, cached data, sync, conflict) |
| 3. PWA specification | ✅ Complete — Section 3 |
| 4. Minimum network requirement | ✅ Complete — Section 4 |
| 5. Sync conflict scenario | ✅ Complete — Section 2F |
| 6. Requirements reflected in technical architecture | ⏳ Pending — must be confirmed by Technical Architect at Phase 1 kickoff |
| 7. `features.md` updated | ✅ Complete — offline behavior spec added to non-functional requirements |

---

---

## AI-Assisted Technical Review Note

**Reviewed:** 2026-05-10
**Reviewer:** AI technical review (Claude, acting as Technical Architect surrogate)
**Status:** Preliminary — **human Technical Architect must confirm before Phase 1 implementation begins.** This review was produced by AI-assisted analysis, not a human TA. It identifies no blocking issues but cannot substitute for a qualified TA's sign-off on the Phase 1 architecture.

---

### Assessment

The offline behavior spec is **technically coherent** for Phase 1. Each key design decision is evaluated below.

**IndexedDB queue** — Correct choice for structured care data that must survive tab close, browser refresh, and device sleep/wake. IndexedDB is supported on all minimum browser targets listed in Section 4 (Chrome 80+, Safari iOS 14+, Firefox 75+). Using IndexedDB for dynamic data and Cache API for static assets (app shell) is the correct separation of concerns. No issues.

**Explicit offline banner** — The two-signal detection approach (navigator.onLine + 30-second periodic ping; offline mode after two consecutive ping failures within 60 seconds) is a sound and well-established pattern. Minor timing observation: a caregiver on a degraded connection that passes navigator.onLine but fails pings could log entries for up to 60 seconds before the offline banner appears. These entries are written to IndexedDB immediately, so there is no data loss — but the caregiver's perceived state may lag by up to one detection cycle. This is acceptable for Phase 1 care logging. Banner design (amber, not red, fixed position, per-entry sync badge) is appropriate and handles the trust dimension well.

**Reconnect sync** — FIFO queue flush on network restore, max 10 entries per request, exponential backoff retry (2s → 8s → 30s, 3-attempt cap, then surface as sync error requiring acknowledgment) is a correct and standard pattern. The timestamp architecture is the most important detail: `logged_at` set client-side at observation time, `created_at` set server-side at sync write. Both timestamps preserved in the database. This dual-timestamp model is architecturally necessary for audit integrity in a care record context. Do not allow this to be simplified to a single timestamp during implementation.

**Conflict flagging** — Flag-for-review (not auto-merge, not auto-discard) is the correct policy for care observations. The duplicate detection window (same resident_id + routine_id + shift_id, within 15 minutes) is a reasonable heuristic. Both entries persist in AuditTrail; resolution action is audited. This is appropriately conservative.

**No Background Sync API dependency** — Correct decision. Background Sync API availability is inconsistent on Android 9 (Chrome 80) and some Samsung Internet builds. The foreground sync approach (fires automatically when app is in foreground, IndexedDB queue persists across session closures) is the right fallback and is compatible with all minimum targets.

**Minimum browser targets** — Android 9+/Chrome 80+ (2019 baseline) and iOS 14+/Safari (2020 baseline) provide all three required APIs (Service Worker, IndexedDB, Cache API). These targets are well-established for a 2026 launch. IE11 and legacy WebView are correctly excluded.

---

### Implementation Notes for Phase 1

These are not blocking issues — they are patterns the implementation team should establish from the start:

1. **Service worker registration:** Register after the initial page load event, not as a blocking head script. Avoids delaying initial parse on slow connections.
2. **IndexedDB schema versioning:** Define the IndexedDB schema with an explicit `db.version` field from the start. Schema migrations are needed as the product evolves; versioning now prevents data corruption on future updates.
3. **Stale-while-revalidate awareness:** The app shell caching strategy (stale-while-revalidate) means users may briefly see a stale UI build while the new version downloads in the background. For a care log tool with infrequent app shell changes, this is acceptable — but the deployment process should include a cache-busting strategy (content-hash filenames in the build) so stale shells expire as soon as the new build is fetched.
4. **Queue capacity observation:** The 200-entry maximum queue capacity covers one 8-hour shift across 20 residents at 1 entry per resident per event. If a caregiver's device remains offline across multiple shifts, queue capacity could be exceeded. For Phase 1, surfaces this as a visible warning rather than silently dropping entries.

---

### Verdict

No blocking technical issues identified. Spec is suitable for Phase 1 implementation. The human Technical Architect must confirm that these requirements are reflected in the Phase 1 technical architecture before implementation begins (Acceptance Criterion 6).

---

**Remaining to close this task:**
- [ ] Technical Architect (human) confirms offline behavior spec is reflected in Phase 1 architecture decisions — the AI-assisted review above identifies no blocking issues but does not satisfy this criterion
- [ ] Design partner site visit (task 0002) validates WiFi quality assumptions — update if real facility conditions differ significantly from the modeled environment
- [ ] If design partner site visit reveals Background Sync API is available and reliable on the specific devices used by that facility, revisit the no-Background-Sync decision

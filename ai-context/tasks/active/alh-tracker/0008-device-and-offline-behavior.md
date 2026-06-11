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

**Spec refined 2026-05-23:** Idempotency key terminology clarified in queue structure; queue item validation rules documented. Design partner WiFi/site validation checklist (Section 6) and implementation test plan (Section 7) added. Task remains active pending human TA confirmation (AC #6) and design partner site visit.

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
- Idempotency key (UUID v4, generated client-side at the moment of queue write; used to prevent duplicate server writes on retry)
- Queued-at timestamp
- Sync status: `pending` | `syncing` | `synced` | `error`
- Retry count (capped at 3 before surfacing as sync error)

**Queue capacity:** Designed to hold up to 200 entries before sync. This covers a full 8-hour shift across 20 residents at 1 entry per resident per shift event — a realistic worst-case offline period.

**Queue persistence guarantee:** The queue is never cleared until the server returns HTTP 201 (or 200) confirming the write. Client-side display of the entry as "saved" is optimistic; the server confirmation clears the queue.

**Queue item validation:** Before a queue write is accepted, the following fields must pass validation. If any check fails, the entry is rejected immediately — no queue write occurs — and the caregiver is shown an error.

| Field | Validation rule |
|---|---|
| `resident_id` | Non-null UUID |
| `routine_id` | Non-null UUID |
| `category` | Non-null; must be a valid CareLogCategory enum value |
| `status` | Non-null; must be a valid CareLogStatus enum value |
| `logged_at` | Non-null ISO 8601 timestamp; must be within ±24 hours of current device clock (guard against extreme clock skew) |
| `shift_id` | Non-null UUID |
| `note` | Optional; if present, max 2000 characters |
| `idempotency_key` | Must be a valid UUID v4 (36-character, version 4 confirmed) |

The `idempotency_key` is passed to the server with every sync request. The server must respond to a duplicate `idempotency_key` idempotently (HTTP 200/201 with the existing record, or HTTP 409 treated as success by the client) rather than with a server error. This ensures a retried sync request never produces a duplicate care log record.

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
| 2. Offline behavior specification | ✅ Complete — Section 2 (detection, indicator, queue + idempotency keys + item validation, cached data, sync, conflict) |
| 3. PWA specification | ✅ Complete — Section 3 |
| 4. Minimum network requirement | ✅ Complete — Section 4 |
| 5. Sync conflict scenario | ✅ Complete — Section 2F |
| 6. Requirements reflected in technical architecture | ⏳ Pending — must be confirmed by Technical Architect at Phase 1 kickoff |
| 7. `features.md` updated | ✅ Complete — offline behavior spec added to non-functional requirements |

---

### 6. Design Partner WiFi/Site Validation Checklist

This checklist must be completed during each design partner site visit (task 0002). It informs whether the offline detection thresholds, queue capacity, and sync strategy are correctly calibrated for the actual facility environment. Findings may require updating the 30-second ping interval, 200-entry queue capacity, or the no-Background-Sync decision.

**Before the visit:**
- [ ] Confirm WiFi access will be available during the visit (or that the facility has WiFi at all)
- [ ] Confirm which device types caregivers actually use: personal phones, facility-provided phones, shared tablet, or a mix

**During the visit — WiFi coverage:**
- [ ] Walk all areas where caregivers work: common room, individual resident rooms, kitchen, back bedrooms. Note any areas where a phone loses or drops signal.
- [ ] Test signal in the areas caregivers most frequently use. The modeled scenario is: strong in common areas, weak in back bedrooms — confirm or correct this.
- [ ] Ask caregivers: does WiFi ever cause problems during a shift? Do entries or messages ever fail to send?
- [ ] Ask: has any record or note ever been lost because the phone went offline?
- [ ] Ask: is there a mobile data fallback (personal hotspot, cellular data on caregiver phones) if facility WiFi fails?

**During the visit — device and browser:**
- [ ] Note caregiver device brands and approximate ages. Flag any device that appears older than Android 9 / iOS 14 (minimum browser baseline).
- [ ] If a shared tablet is present: note brand, OS version, and how many caregivers share it per shift.
- [ ] Open a browser on a caregiver device and confirm Chrome or Safari is available; note the version.
- [ ] Confirm whether caregivers use personal phones or facility-provided devices. Facility-provided devices may have MDM profiles that affect PWA install behavior.

**During the visit — offline posture validation:**
- [ ] With WiFi disabled on a test device, confirm the offline banner appears within approximately 60 seconds (two ping cycles).
- [ ] Log a test entry in offline mode. Confirm it persists after a tab close and reopen.
- [ ] Re-enable WiFi. Confirm the sync banner appears and the queued entry clears.

**Post-visit — findings to record:**
- [ ] Document any dead spots found. Dead spots in caregiver work areas are load-bearing for the 30-second ping interval and 200-entry queue capacity.
- [ ] Note whether any observed devices fall below the minimum browser baseline. Flag as a risk if found.
- [ ] Check whether Background Sync API is available on the observed devices (Chrome DevTools → Application → Service Workers → Background Sync capability). Do not assume availability; this decision is currently locked as "no dependency" and should only be revisited if reliably confirmed at the facility.
- [ ] Record the visit date, facility name, and primary caregiver contact in the design partner tracker (task 0002 Section 4b). Update this spec if real-world conditions differ materially from the modeled environment.

---

### 7. Implementation Test Plan

No offline support is implemented yet (confirmed: package.json has no service worker library, no IndexedDB wrapper, no `vite-plugin-pwa`). This section defines the test coverage required before offline behavior can be marked production-ready. All items are prospective — tests are to be written in parallel with implementation, not after.

#### 7A — Unit Tests (queue operations, validation, sync logic)

Run in isolation; no browser, network, or Supabase connection required.

| Test | What it verifies |
|---|---|
| Queue write — valid entry | Valid CareLogEntry writes to IndexedDB; idempotency key is a valid UUID v4; all required fields present |
| Queue write — null resident_id rejected | Entry with null `resident_id` is rejected before queue write; error surfaced to caller |
| Queue write — null routine_id rejected | Entry with null `routine_id` is rejected |
| Queue write — invalid status enum rejected | Entry with unrecognized `status` value is rejected |
| Queue write — note too long rejected | Entry with `note` > 2000 characters is rejected |
| Queue write — clock skew rejected | Entry with `logged_at` more than 24 hours from current device clock is rejected |
| Idempotency key — uniqueness | Each queue write generates a new UUID v4; no two queue entries share an idempotency key |
| Idempotency key — format | Generated key passes UUID v4 format check (8-4-4-4-12 hex, version nibble = 4) |
| Duplicate idempotency key — blocked | Attempting to enqueue a second entry with an existing idempotency key does not produce a second queue row |
| Queue capacity at 200 | At 200 entries, the next write triggers a visible warning; no silent drop |
| Status transition: pending → syncing → synced | Entry moves through all three states on a successful sync |
| Status transition: syncing → error | Entry moves to error state after 3 retry failures |
| Retry count increment | Each failure increments retry count by 1; count reaches 3 before error state is set |
| Retry backoff schedule | Retry fires at 2s, 8s, 30s in order; no earlier retry fires |
| FIFO flush order | Queue flushes in ascending `logged_at` order |
| logged_at preserved through sync | `logged_at` set at queue write time equals the value in the outgoing sync payload |
| created_at absent from payload | No `created_at` field in the outgoing sync payload; server sets it on write |
| Batch cap at 10 | Queue of 11+ entries sends as two batches: 10 then the remainder |

#### 7B — Integration Tests (queue + sync against test server)

Require a running Supabase local instance or configured test double.

| Test | What it verifies |
|---|---|
| Single entry syncs successfully | Entry sent; server returns 201; `logged_at` preserved on server record; entry cleared from queue |
| Batch of 10 syncs completely | All 10 entries cleared from queue on success |
| Batch of 11 splits correctly | Two batches (10 + 1); both complete without error |
| Idempotent replay | Entry sent twice (simulated retry before first response received); server returns 200/201; no duplicate database row created |
| Server 500 — retry and surface | Server returns 500; client retries at 2s, 8s, 30s; after 3 failures, entry enters error state and sync error banner is shown |
| Server 409 — treated as success | Server returns 409 (duplicate idempotency key already accepted); client clears the queue entry; no duplicate in database |
| Auth token expired during sync | Session token expires mid-sync; sync halts; queue preserved; caregiver prompted to re-authenticate |
| Duplicate pair flagged for review | Two entries: same resident_id + routine_id + shift_id + within 15 minutes, different user_id — both written to database; "review needed" flag set |
| Same-user duplicate — caregiver warned | Same user submits the same routine twice in one offline session; both written; sync completion screen shows review prompt |
| Conflict resolution audited | Admin resolves a flagged duplicate; resolution action recorded in AuditTrail |

#### 7C — Browser and Manual Tests (real device, real offline simulation)

Require physical devices at the minimum browser baseline (Android 9+/Chrome 80+; iOS 14+/Safari).

| Test | Device | What it verifies |
|---|---|---|
| Offline banner appears within 60s | Android phone, iOS phone | WiFi disabled; banner appears within two ping cycles |
| Banner does not obscure log path | Phone (portrait) | Log entry touch targets remain ≥44px with banner visible |
| Per-entry sync badge — appears offline | Phone | Entry logged offline shows pending badge immediately |
| Per-entry sync badge — clears on sync | Phone | Badge clears after server confirmation |
| Queue survives tab close | Phone | Entry logged offline; tab closed and reopened; entry still in queue |
| Queue survives app background | Phone | Entry logged offline; app backgrounded 5 minutes; foregrounded; sync fires automatically |
| Sync progress banner | Any | WiFi restored: "Syncing N entries..." then "All synced" for 3 seconds then hidden |
| Sync error — requires acknowledgment | Any | Persistent server error: sync error banner requires explicit tap to dismiss |
| Undo path — 5-second window | Phone | Log an entry; undo button visible for 5 seconds; tap removes entry from display and queue |
| Shared tablet — current user visible | Tablet | Active user name visible without scrolling |
| Desktop offline mode | Desktop | Banner and queue behave consistently on desktop |
| PWA install prompt | Phone | Install prompt appears after first meaningful session; does not block use if dismissed |

#### 7D — Failure and Retry Scenarios

| Scenario | Expected behavior |
|---|---|
| Network drops mid-batch sync | Entire batch is re-queued and retried; no partial write accepted |
| IndexedDB quota exceeded | Write rejected before it reaches the queue; explicit error shown to caregiver; no silent drop |
| Device clock skew > 24 hours | Entry fails field validation before queue write; error surfaced to caregiver immediately |
| Browser closed during active sync | On next app open, entries with status `syncing` reset to `pending` and retried |
| Device sleep/wake during sync | On wake, `syncing` entries reset to `pending`; sync resumes cleanly |
| All retries exhausted for one entry | That entry is marked `error`; sync continues for all other entries in the queue |
| Queue near capacity after long offline period | All ≤200 entries sync in FIFO order; no capacity error; progress visible throughout |
| Rapid reconnect/disconnect cycle | Transitions are debounced; no thrash loop between offline/online mode |

#### 7E — Privacy and Security Checks

| Check | What it verifies |
|---|---|
| No PHI in app shell cache | Cache API cache (static assets) contains no resident names, care observations, or health notes |
| IndexedDB restricted to app origin | Queue is not readable from other browser origins |
| Queue cleared on logout | Signing out clears or makes inaccessible the local queue; no residual PHI readable by the next user on the same device |
| No cross-user queue visibility on shared tablet | After user A logs out and user B logs in, user B cannot see user A's unsynced entries in UI or DevTools |
| No PHI in browser console | Resident names, note text, and routine details are never written to the browser console during queue operations |
| Sync requests authenticated | All sync HTTP requests use the active session token; no unauthenticated sync path |
| Token expiry halts sync (does not drop queue) | Expired session token causes sync to pause and prompt re-auth; queued entries are preserved |

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

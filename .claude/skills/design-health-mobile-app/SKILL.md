---
name: design-health-mobile-app
description: Design or implement a calm, accessible, PHI-safe mobile or tablet health/care app UI — design tokens, light/dark, navigation, health data visualization, AI-feature UX, offline, motion, and accessibility. Use when building or reviewing any mobile or tablet screen that shows health, wellness, or care data, or an AI feature over that data; for alh-tracker Facility Tracker App screens, defer to the project skill mobile_tablet_ui_v1.
allowed-tools: Read, Glob, Grep, Edit
---

# Design a Health / Care Mobile & Tablet App UI

## Purpose & when to use

The general skill for calm, accessible, PHI-safe health/care UIs on phones and tablets: a token
system, light/dark, navigation, honest health data visualization, AI-feature UX, offline-first data
entry, motion, and accessibility. Not for internal desktop dashboards (use `design_dashboard`).

## Relationship to other skills

`ai-context/skills/project/alh-tracker/mobile_tablet_ui_v1.md` is the project-specific application of
this skill and **takes precedence for any alh-tracker (Facility Tracker App) screen** — its bottom-
nav + Log CTA, demo/pilot banner, hidden family-sharing, no-MAR/clinical rules, and its React 18 /
Vite / Tailwind / Zustand stack + build verification. Use THIS skill only for general guidance the
project skill doesn't cover; on conflict the project skill wins; do not fork its stack/nav/
verification. alh-tracker is a PWA on the existing stack — React Native/Expo and Flutter are for new
greenfield apps only.

## 1. Design language statement

Write this FIRST, in words, before any token or screen (3–5 sentences): the neutral temperature
(warm / cool / true-grey), one brand hue + its personality, the type pairing, ONE signature element,
and the motion idiom. Everything downstream derives from it.

## 2. Token system

- Single source-of-truth token file; three tiers: **primitives → semantic → component**. Light/dark
  is implemented by remapping **semantic** tokens only.
- **Type scale** (named): `display, title-lg, title, body-lg, body, label, caption`; body ≥ 16px;
  **tabular numerals** for all metrics and aligned columns.
- **Spacing** 4px base: `2,4,8,12,16,20,24,32,40,48,64`. **Radius**: `xs4 / sm8 / md12 / lg16 /
  xl24 / full`; pick one card radius; nested radius ≤ outer.
- **Elevation, dual-mode:** light = soft tinted shadow (never pure black); dark = surface-**tint**
  stepping + 1px hairline (do not reuse light shadows on dark).
- **Semantic colors:** `bg, surface, surface.raised, border, text.primary/secondary/tertiary,
  brand, accent`; status `{positive, caution, critical, info, neutral}` each with `.fg/.bg/.border`;
  interaction states `default/hover/pressed/focus/disabled` with a visible non-color focus ring.
- **Data-viz tokens** in a separate namespace (categorical, sequential, grid, axis, ring track,
  normal-range band) — never drawn from status/brand colors.
- **Hard rule:** no raw hex / px / shadow in components. If a value repeats, it's a token.

## 3. Layout & navigation

Mobile-first → tablet-adaptive. Breakpoints (dp, orientation-aware): **<600** phone (single pane,
bottom tabs); **600–839** medium (nav rail may replace tabs); **≥840** tablet (two-pane master-
detail, list 320–360dp, detail flexible). Cap content measure ~640dp / ~70ch; never stretch phone
columns full-width on tablet; bottom tabs → nav rail on large tablets; support split-screen / multi-
window and recompute on configuration change. Primary actions in the bottom thumb arc; nav and
confirmation at the bottom, not the top.

## 4. Touch, type & contrast

- Targets ≥ **44×44pt** iOS / **48×48dp** Android *including hit-slop*; ≥ 8dp between targets; 56dp
  for destructive/primary; nothing in the bottom 12dp edge; every swipe action has a tap equivalent.
- Text body ≥ 16pt, never < 12pt; support Dynamic Type `xSmall → AX5` (~310%) and Android scale to
  2.0× with **reflow** (no clip/truncation — verify at 200% & AX5); primary numerics ≥ 28pt.
- Contrast: **4.5:1** normal text, **3:1** large text / UI / focus, **7:1 (AAA)** for health numbers
  & clinical thresholds — in both themes.

## 5. Components & states

Cards, metric tiles, lists, charts/rings, progress, bottom sheets, modals, forms — each with
**distinct** empty / sparse / loading (skeleton, not spinner-over-card) / stale / error states.

## 6. Health data visualization

Honesty contract:

- **Chart choice:** single reading → big number + unit + timestamp + state (+ optional sparkline,
  not a lone bar); trend → line/bar **with a normal band**; goal → ring/linear **with the number AND
  target**; composition → stacked bar (no pie > 3 categories); variability → range/whiskers.
- **Axis honesty:** bars start y = 0; lines may use a non-zero baseline only when min/max are
  annotated and a band is shown; real timestamps; always label units.
- **Dual-encode:** never hue alone — pair status/series with icon/shape/position/label + status text
  ("High"); must survive deuteranopia / protanopia / tritanopia.
- **Precision/units/time:** clinically meaningful rounding (no `72.4318 bpm`); unit adjacent to
  value; timestamp + timezone (relative + absolute). Distinguish measured / estimated / user-entered
  / missing — **never interpolate across gaps**; show "—" for missing, not 0.

## 7. Status & color model

Calm baseline, urgent exception — serene when all is well; saturated/critical color is rare. No
red/green as the sole differentiator; "below goal" = `caution`, not `critical` red; reserve red for
safety-critical. Dark mode ≠ inverted light (elevated dark surfaces, not `#000`; desaturate brand
~10–15%; `text.primary` ≈ 0.90 white; re-tune the viz palette for dark). Everything derives from one
`brand.hue` for re-skinning.

## 8. AI-feature UX

AI output is **visually distinct** from human-entered data (badge/tint/border, not a rainbow "AI"
gradient), labeled "AI-generated — may be inaccurate", shows qualitative uncertainty (not a raw %),
offers one-tap Edit / Wrong / Dismiss, never auto-fills a clinical field, and is never silently
merged into the record. A persistent "not medical advice / not a clinical decision tool" disclaimer
sits where AI output appears. AI must **not** produce diagnoses, triage, risk scores, dose guidance,
or drug-interaction output.

## 9. Accessibility

- Screen reader: labels + roles/traits + state + grouping; icon-only buttons named; decorative chart
  chrome hidden; switch/keyboard operable; focus visible at 3:1; explicit focus order per form;
  focus moves on screen change and returns on sheet close.
- **Live regions:** any value updating without navigation (sync status, just-logged entry, new
  vital) announces politely; save/sync success AND failure are announced (not color-only).
- **Reduced motion:** replace slides/parallax/spring with cross-fade or instant, disable autoplay /
  ring-fill, cap non-essential motion ~200–300ms, respect Reduce Transparency, never convey state by
  motion alone.

## 10. Data entry & offline

- Prefer selection over free entry (steppers / segmented / presets; numeric keypad
  `inputMode=decimal`); plausibility **soft-warnings** (warn, don't block); no auto-submit on blur;
  undoable saves (≥ 5s snackbar); unit inside the field; timestamp defaults to "now", one-tap
  editable.
- **Offline-first:** local-write-first with a per-item sync state (Saved locally / Syncing / Synced
  / Failed — text + icon, never color-only); never block entry or trap a spinner; queue + auto-retry
  + manual retry; global "N pending"; idempotent saves; draft autosave across crash; conflict =
  present a choice, never silent overwrite.

## 11. Shared-tablet / kiosk

Persistent active-caregiver identity in the app bar; low-friction user switch / hand-off; stamp every
log with author + device; auto-lock after 2–5 min idle to a neutral "who's logging?" state; no PHI
readable after switch; a visible "end my session / hand off" action.

## 12. PHI / PII guardrails

Hard rules — tie to `global/enforcement_design.md` and alh-tracker `compliance_notes.md`:

- **No resident/PII/PHI to analytics, ad, attribution, or A/B SDKs, or to crash/error reporting** —
  scrub breadcrumbs; disable automatic screenshot / view-hierarchy capture.
- **Block screenshots & screen recording** on resident-data screens (Android `FLAG_SECURE`; iOS
  app-switcher blur). State plainly: this is a UX/security measure, **not** a compliance/privacy
  guarantee.
- **No sensitive content in notifications / lock-screen previews** (neutral copy; detail after
  unlock).
- PHI fields marked sensitive (no autocorrect/predictive learning; no clipboard caching). **No PHI
  in localStorage / URLs / deep-links / logs** — the offline queue is a transient cache cleared after
  server confirm; deep-link tokens opaque / expiring / one-time.
- Surface **consent** (family-visibility opt-in per entry, never default; not exposed to staff in
  MVP) and that edits/grants are **audited** (append-only AuditTrail).
- Any new third-party SDK / endpoint that could receive resident data is an **egress decision** —
  flag for human review; never add silently.

## 13. Anti-overclaim & copy rules

The app is **not a medical device**; no diagnosis, monitoring, or medical advice. Make **no HIPAA /
Title-22 / BAA claims in either direction** (compliant OR exempt — both need counsel). Banned UI /
marketing words: "Compliant / Title 22 compliant," "Regulatory / Official / Required documentation,"
"Clinical record," "Incident Report / Reportable Incident," "Medication Record / Med Pass / MAR /
eMAR," "Resident Record" (regulatory sense), "fall / elopement risk," "dysphagia," "ADL assessment,"
"care plan." Prefer "shift log entry / care observation," "incident note," "handoff summary."
*Not legal advice; counsel reviews compliance language.*

## 14. Anti-generic / signature

Commit to ONE signature element repeated throughout (ring/gauge treatment, metric-tile anatomy,
card+shadow recipe); a deliberate type pairing (characterful humanist sans for display/numbers +
neutral readable body — not system-ui/Inter/Roboto by default); content-led asymmetric summary
layouts (tile size by data importance, not identical full-width cards); one restrained motion idiom.
**Forbidden defaults:** pure-black text/shadows, Bootstrap / `#007AFF` blue, red/green-only status,
full-width-card monotony, donut for precise data, spinner-over-card loading, purple-gradient "AI"
cliché.

## 15. Definition of Done

Invoke `verify-and-ship` (`orchestration/definition_of_done.md`); smoke uses **synthetic fixtures
only**, never resident/PII data. Plus mobile manual verify: phone (~360px) AND tablet (~768–1024px)
with no clipping; light AND dark legible; reduced-motion honored; offline queue persists → syncs →
cache clears; accessibility (AA / 7:1 health numbers, ≥ 44–48 targets, SR labels + live regions, AX5
reflow); PHI spot-checks (app-switcher obscured, a test notification shows no resident detail,
nothing PHI in analytics/crash payloads).

## Self-verify checklist

- [ ] No raw hex/px in components
- [ ] Bar charts y-axis at zero
- [ ] Every status has icon + label (never hue alone)
- [ ] Dark mode uses surface-tint elevation
- [ ] Every metric shows unit + timestamp
- [ ] No interpolation across data gaps
- [ ] AI content visually labeled + disclaimer present
- [ ] Layout reflows at 200% / AX5
- [ ] 7:1 contrast on health numbers/thresholds
- [ ] Primary actions reachable one-handed
- [ ] Offline save persists and syncs
- [ ] Color-blind simulation passes

## Inputs & outputs

**Inputs:** brand (fonts / hue / tone), platform target, screens. Missing assets → `TODO`, never
invent brand fonts/colors. **Outputs:** the design-language statement, the token file, screens /
components, and a documented reduced-motion + accessibility + offline approach.

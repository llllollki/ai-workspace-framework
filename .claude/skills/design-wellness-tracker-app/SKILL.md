---
name: design-wellness-tracker-app
description: Design or implement a consumer health/fitness/wellness TRACKING app UI on mobile or tablet — energetic, fresh green-to-yellow gradient aesthetic with activity rings, streaks, goals, and progress. Use when building a step / sleep / heart-rate / workout / hydration / nutrition tracker or a motivational wellness dashboard. Builds on design_health_mobile_app for tokens, accessibility, health-data honesty, and PHI safety; for alh-tracker care screens use mobile_tablet_ui_v1 instead.
allowed-tools: Read, Glob, Grep, Edit
---

# Design a Wellness / Health-Tracking App UI (fresh green aesthetic)

A focused **aesthetic + interaction** skill for consumer health/fitness *tracking* apps: bright,
energetic, motivational, with a fresh green-to-yellow gradient look. It **builds on**
`design_health_mobile_app` — inherit all of that skill's rigor and only specialize the visual
direction, color system, and motivational patterns here.

## Purpose & when to use

Consumer wellness/fitness trackers (steps, sleep, heart rate, workouts, hydration, nutrition,
mindfulness) and motivational wellness dashboards. Energetic and optimistic, not clinical/calm. NOT
for care/clinical logging — that is `design_health_mobile_app` (general) or `mobile_tablet_ui_v1`
(alh-tracker).

## Relationship to other skills

- **Builds on `design_health_mobile_app`.** Inherit, do not restate: the 3-tier token system,
  touch/type/contrast minimums, accessibility (SR, live regions, reduced motion), the health
  data-viz honesty contract, data-entry & offline rules, PHI/PII guardrails, anti-overclaim copy
  rules, Definition of Done, and the self-verify checklist. This skill ADDS the aesthetic layer.
- **alh-tracker:** use `ai-context/skills/project/alh-tracker/mobile_tablet_ui_v1.md` — it takes
  precedence and is calm/care-oriented, not this energetic aesthetic.
- On conflict, the inherited PHI/a11y/honesty rules from `design_health_mobile_app` WIN over any
  aesthetic choice here. Never trade contrast, legibility, or PHI safety for the look.

## 1. Visual direction

Fresh, energetic, optimistic "vitality" mood — sunlit lime-to-yellow gradients, soft glow, airy
whitespace, rounded friendly forms. Reference palette: bright lime green → chartreuse → soft yellow,
with a white top-light glow and a deep-green accent. Gradient-forward but used as *accent and
celebration*, never behind dense data or body text.

## 2. Color system (with hard contrast guardrails)

Concrete starting palette (tune to brand; keep the relationships):

```
brand.gradient   : linear-gradient(135deg, #9BDE49 0%, #C7EC5C 45%, #ECF07A 100%)  /* lime→yellow */
brand.primary    : #6FBF3B   /* fresh green — fills, primary buttons (on light only) */
brand.deep       : #2E6B36   /* forest green — text/icon emphasis that needs contrast */
accent.lime      : #B6E85A
accent.yellow    : #EDEE7E   /* decorative ONLY — never small text or status */
bg               : #FBFDF3   /* warm off-white */
surface          : #FFFFFF
surface.tint     : #F0F7E4   /* light mint card */
text.primary     : #1E2A17   /* deep green-charcoal — the workhorse ink */
text.secondary   : #4A5742
```

**Contrast guardrails (this palette fails easily — non-negotiable):**
- **Never** put body text or numbers on the lime/yellow gradient or on pastel hues. Text lives as
  deep ink (`text.primary`/`brand.deep`) on white/`surface.tint`. If text must sit on the gradient,
  add a solid scrim or use white/deep-ink and verify **≥4.5:1 body, ≥7:1 health numbers**.
- **Yellow is decorative only** — never small text, never a status text color (illegible).
- Restrict the gradient to hero headers, ring fills, celebration moments, and large brand surfaces.

**Status colors must stay DISTINCT from the brand green/yellow** (a green/yellow brand cannot also
mean "good"/"warning"): `positive = teal #1FA98F` (not lime), `caution = amber #E8A33D`,
`critical = #E0533D` (+ icon), `info = blue #3B82C4`. As always, pair every status with icon + label
(inherit "never hue alone").

**Dark mode:** deep green-charcoal surfaces (e.g. `#161A12`, not `#000`); keep brand vivid but
desaturate ~10–15%; use the gradient sparingly as an accent, not a full background; re-tune the
viz palette for dark per the inherited rules.

## 3. Signature elements & components

- **Signature element: the activity ring / arc** with a green→yellow gradient fill — repeat it as
  the through-line (dashboard hero, metric tiles, goal cards). A ring always shows its number AND
  target (inherit the viz rule); de-emphasize the unfilled track.
- Gradient hero header with the day's headline metric; rounded metric tiles sized by importance
  (one dominant metric, smaller secondaries — content-led, not identical full-width cards).
- Trend sparklines/area charts with a soft gradient fill under the line; streak calendar; goal
  progress bars/rings.

## 4. Motivational UX & gamification (with restraint)

- Streaks, goal completion, milestones, gentle celebrations (a brief ring-fill + count-up, optional
  confetti) — but **respect `prefers-reduced-motion`** (instant/cross-fade fallback, no essential
  info conveyed by motion) and keep the celebration restrained, not toy-like.
- Positive, encouraging copy. **Do not** make medical/clinical claims, give medical advice, or imply
  diagnosis — inherit the anti-overclaim & banned-words rules from `design_health_mobile_app`.
- Goals/insights from AI must follow the inherited AI-feature UX (labeled, uncertainty shown, not
  medical advice).

## 5. Data viz for tracking

Use the inherited honesty contract: rings/goals show number + target; trends use real timestamps and
a reference/normal band; bars start at y=0; distinguish measured vs estimated vs missing (no
interpolation across gaps); units + timestamps always present; dual-encode beyond color. The gradient
is a *fill aesthetic* on honest charts — it never replaces axes, labels, or honest scaling.

## 6. Inherited from design_health_mobile_app (apply in full)

Token tiers · touch ≥44/48 + hit-slop · type ≥16 / AX5 reflow · contrast 4.5:1 / 7:1 health numbers ·
accessibility (SR labels + roles + live regions, focus management) · reduced motion · data entry &
offline (local-write-first, sync states) · PHI/PII guardrails (no PHI to analytics/crash SDKs,
FLAG_SECURE/app-switcher blur, no PHI in notifications/URLs/logs, consent + audit) · anti-overclaim /
banned-words · Definition of Done (phone + tablet, light + dark, reduced-motion, offline, a11y, PHI
spot-checks; smoke on synthetic fixtures only).

## Self-verify (delta — in addition to the inherited checklist)

- [ ] No body text or numbers placed on the gradient or pastel hues (deep ink on light only)
- [ ] Yellow used decoratively only (no yellow text / yellow status)
- [ ] Health numbers meet 7:1 against their actual background (verify on the bright palette)
- [ ] Status colors are teal/amber/red/blue — distinct from brand green/yellow, each with icon+label
- [ ] Gradient confined to hero/ring/celebration surfaces, not behind dense data
- [ ] Activity-ring signature element used consistently; rings show number + target
- [ ] Celebrations respect reduced-motion; no medical/clinical claims in motivational copy

## Inputs & outputs

**Inputs:** brand (may override the palette — keep the contrast & status-distinction rules), platform
target, tracked metrics, screens. Missing assets → `TODO`, never invent. **Outputs:** the
design-language statement, a token file (with this color system), screens/components, and the
inherited documented a11y + reduced-motion + offline approach.

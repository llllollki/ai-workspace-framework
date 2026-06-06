# Skill: Design a Wellness / Health-Tracking App UI (fresh green aesthetic) — v1

> Codex-readable mirror of `.claude/skills/design-wellness-tracker-app/SKILL.md` (which Claude Code
> auto-invokes). Keep the two in sync. Codex: read and follow this file.
>
> Trigger (matches the SKILL.md frontmatter `description`): *Design or implement a consumer health/
> fitness/wellness TRACKING app UI on mobile or tablet — energetic, fresh green-to-yellow gradient
> aesthetic with activity rings, streaks, goals, and progress. Use when building a step / sleep /
> heart-rate / workout / hydration / nutrition tracker or a motivational wellness dashboard. Builds
> on design_health_mobile_app for tokens, accessibility, health-data honesty, and PHI safety; for
> alh-tracker care screens use mobile_tablet_ui_v1 instead.*

A focused aesthetic + interaction skill that **builds on** `design_health_mobile_app` — inherit all
of that skill's rigor; specialize only the visual direction, color system, and motivational patterns.

## Purpose & when to use

Consumer wellness/fitness trackers (steps, sleep, heart rate, workouts, hydration, nutrition,
mindfulness) and motivational dashboards — energetic and optimistic, not clinical/calm. NOT for
care/clinical logging (use `design_health_mobile_app` general, or `mobile_tablet_ui_v1` for
alh-tracker).

## Relationship to other skills

- Builds on `design_health_mobile_app`: inherit (do not restate) the 3-tier tokens, touch/type/
  contrast minimums, accessibility, the health data-viz honesty contract, data-entry & offline,
  PHI/PII guardrails, anti-overclaim copy rules, Definition of Done, and self-verify checklist.
- alh-tracker: use `project/alh-tracker/mobile_tablet_ui_v1.md` (takes precedence, calm/care-
  oriented, not this aesthetic).
- On conflict, inherited PHI/a11y/honesty rules WIN over any aesthetic choice. Never trade contrast,
  legibility, or PHI safety for the look.

## 1. Visual direction

Fresh, energetic, optimistic "vitality" — sunlit lime-to-yellow gradients, soft glow, airy
whitespace, rounded friendly forms. Reference palette: bright lime green → chartreuse → soft yellow,
white top-light glow, deep-green accent. Gradient-forward but used for accent/celebration, never
behind dense data or body text.

## 2. Color system (with hard contrast guardrails)

```
brand.gradient   : linear-gradient(135deg, #9BDE49 0%, #C7EC5C 45%, #ECF07A 100%)
brand.primary    : #6FBF3B   /* fresh green — fills/buttons on light only */
brand.deep       : #2E6B36   /* forest green — text/icon emphasis needing contrast */
accent.lime      : #B6E85A
accent.yellow    : #EDEE7E   /* decorative ONLY — never small text or status */
bg               : #FBFDF3
surface          : #FFFFFF
surface.tint     : #F0F7E4
text.primary     : #1E2A17   /* deep green-charcoal ink */
text.secondary   : #4A5742
```

Contrast guardrails (non-negotiable — this palette fails easily):
- Never put body text/numbers on the gradient or pastel hues. Text = deep ink on white/`surface.tint`.
  If text must sit on the gradient, add a solid scrim or deep-ink/white and verify ≥4.5:1 body,
  ≥7:1 health numbers.
- Yellow is decorative only — never small text, never a status text color.
- Confine the gradient to hero headers, ring fills, celebrations, large brand surfaces.

Status colors stay DISTINCT from brand green/yellow: `positive = teal #1FA98F` (not lime),
`caution = amber #E8A33D`, `critical = #E0533D` (+icon), `info = blue #3B82C4`; pair every status
with icon + label (never hue alone).

Dark mode: deep green-charcoal surfaces (`#161A12`, not `#000`); keep brand vivid but desaturate
~10–15%; gradient sparingly as accent; re-tune viz palette for dark.

## 3. Signature elements & components

Signature = the activity ring/arc with a green→yellow gradient fill, repeated throughout (dashboard
hero, metric tiles, goal cards); a ring always shows number AND target; de-emphasize the unfilled
track. Gradient hero header with the headline metric; rounded metric tiles sized by importance
(one dominant, smaller secondaries); trend sparklines/area charts with soft gradient fill; streak
calendar; goal progress.

## 4. Motivational UX & gamification (with restraint)

Streaks, goal completion, milestones, gentle celebrations (brief ring-fill + count-up, optional
confetti) — respect `prefers-reduced-motion` (instant/cross-fade fallback; no essential info via
motion); keep restrained, not toy-like. Positive copy, but no medical/clinical claims, no medical
advice, no implied diagnosis (inherit anti-overclaim & banned words). AI goals/insights follow the
inherited AI-feature UX (labeled, uncertainty shown, not medical advice).

## 5. Data viz for tracking

Use the inherited honesty contract: rings/goals show number + target; trends use real timestamps +
reference band; bars start y=0; distinguish measured/estimated/missing (no interpolation across
gaps); units + timestamps always; dual-encode beyond color. The gradient is a fill aesthetic on
honest charts — it never replaces axes, labels, or honest scaling.

## 6. Inherited from design_health_mobile_app (apply in full)

Token tiers · touch ≥44/48 + hit-slop · type ≥16 / AX5 reflow · contrast 4.5:1 / 7:1 health numbers ·
accessibility (SR labels + roles + live regions, focus management) · reduced motion · data entry &
offline (local-write-first, sync states) · PHI/PII guardrails (no PHI to analytics/crash SDKs,
FLAG_SECURE/app-switcher blur, no PHI in notifications/URLs/logs, consent + audit) · anti-overclaim /
banned-words · Definition of Done (phone + tablet, light + dark, reduced-motion, offline, a11y, PHI
spot-checks; smoke on synthetic fixtures only).

## Self-verify (delta — in addition to the inherited checklist)

No body text/numbers on gradient or pastel hues (deep ink on light only) · yellow decorative only ·
health numbers meet 7:1 against actual background · status colors teal/amber/red/blue distinct from
brand green/yellow, each with icon+label · gradient confined to hero/ring/celebration · activity-ring
signature used consistently (number + target) · celebrations respect reduced-motion; no medical/
clinical claims in copy.

## Inputs & outputs

Inputs: brand (may override palette — keep contrast & status-distinction rules), platform target,
tracked metrics, screens; missing assets → `TODO`, never invent. Outputs: design-language statement,
token file (with this color system), screens/components, and the inherited a11y + reduced-motion +
offline approach.

<!-- v1. See orchestration\versioning_rules.md for when to create a v2. -->

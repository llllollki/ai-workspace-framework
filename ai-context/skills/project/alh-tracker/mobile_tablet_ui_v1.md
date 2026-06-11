# alh-tracker Skill: Mobile / Tablet UI Consistency

Version: v1

## Purpose

Use this skill when designing, implementing, reviewing, or QAing Facility Tracker App UI changes that affect mobile or tablet layouts, event logging, dashboard, residents, resident detail, handoff, or caregiver workflow screens.

## Required Context

Load the standard project startup files, then load:

- `projects\alh-tracker\overview.md`
- `projects\alh-tracker\features.md`
- `projects\alh-tracker\user_flows.md`
- `global\design_system.md`
- `global\ui_components.md`
- `global\coding_standards.md`

## Scope

- Facility Tracker App only.
- Do not modify `/crm`, `CrmLayout.tsx`, or CRM pages.
- Treat family portal work as out of scope unless explicitly requested.
- Preserve the demo/pilot warning banner on every screen.
- Keep incident and observed-care-task notices visible where relevant.
- Keep observed care tasks more deliberate than routine events; do not make them a one-tap flow.
- Keep incident and observed-care-task entries non-shareable with family (no family-visibility checkbox).
- Never add MAR/eMAR, clinical monitoring, medication-safety, or compliance-certification claims.

## UI Rules

- Design mobile/tablet first: phone for quick event logging, tablet for shared shift board and review.
- Make event tracking resident-centered and fast enough to replace the paper binder.
- Prefer persistent mobile bottom navigation with a prominent Log/Add action.
- Use compact, scannable summaries for today, recent events, resident alerts, and follow-ups.
- Use tablet split views or denser two-column layouts only when they improve scanning.
- Use existing stack and local patterns: React 18, TypeScript, Vite, Tailwind CSS, Zustand, React Router v6, lucide-react, date-fns.
- Keep touch targets comfortable for one-handed phone use.
- Keep text readable at roughly 360px phone width and 768-1024px tablet width.
- Use the "Vitality" green design language (the going-forward standard, shipped in commit `caa5fe6` / PR #1): a `bg-brand-gradient` (lime→yellow) hero on Dashboard, ResidentDetail, and Handoff, each with a signature activity ring driven by **real, derivable coverage data** (no invented goals/streaks). Confine the gradient to hero / ring fill / Log FAB / celebration surfaces — never behind body text, numbers, dense lists, or forms. Still avoid nested cards.
- Status colors stay DISTINCT from the brand green and yellow: success/positive = **teal**, attention = amber, urgent = red, hydration/info = blue — each paired with an icon + text label. Brand green is an accent/identity color, **not** a "success" signal; yellow (the gradient end) is decorative only, never text or a status color. Tokens live in `tailwind.config.js` (`brand` 50–900 ramp, `bg-brand-gradient`); on the light gradient use deep-ink text (`brand-900`/`brand-800`) and verify ≥4.5:1 body / ≥7:1 health numbers.

## Typical Files

- `src\components\Layout.tsx`
- `src\pages\Dashboard.tsx`
- `src\pages\ActivityLog.tsx`
- `src\pages\Residents.tsx`
- `src\pages\ResidentDetail.tsx`
- `src\pages\HandoffSummary.tsx`

**Baseline (commit `406eaf6`):** Bottom tab bar, category icon grid, Log CTA, and per-resident quick-log button are already implemented. New work should build from this state.

**Vitality theme baseline (commit `caa5fe6`, PR #1, 2026-06-06):** Green brand ramp + `bg-brand-gradient`, gradient heroes with coverage rings on Dashboard/ResidentDetail/Handoff, gradient Log FAB (deep-ink icon), and teal/amber/red/blue status palette. New screens should follow this language. The shared `brand` palette intentionally recolors `/crm` and SignIn too (not isolated, per owner). Honest-ring rule: rings show value + target + unit, de-emphasized track, "—" for missing; a true shift-streak is deferred until shift-close history is persisted (see `TODO(theme)` in `Dashboard.tsx`).

## Verification

Run `npm run build`.

When feasible, inspect phone, tablet, and desktop widths. Verify:

- no overlapping text or controls
- bottom navigation does not hide content or the demo banner
- Dashboard -> Log New Event -> save entry -> today's entry appears
- incident and observed-care-task warnings still appear
- family sharing remains hidden for incident and observed-care-task entries
- `/crm` still uses its separate CRM layout

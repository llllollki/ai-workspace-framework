# Skill: Build Luxury / Immersive Brand Site — v1

> Codex-readable mirror of `.claude/skills/build-luxury-site/SKILL.md` (which Claude Code
> auto-invokes). Keep the two in sync. Codex: read and follow this file.

## Purpose

Design and build a luxury / immersive brand-experience website or landing page — cinematic
scroll-driven storytelling, refined editorial typography, parallax and reveal-on-scroll motion,
full-bleed video/imagery (reference class: Cartier *Watches & Wonders*, Apple product pages,
high-jewellery / automotive microsites).

## When to Use

A high-end marketing site, brand campaign page, product showcase, or any "make it feel premium /
animated / immersive" front-end. **Not** for internal dashboards/admin UIs — use `design_dashboard_v1`.

## Defining principle

Restraint + cinematic motion: few elements, generous space, slow deliberate animation tied to
scroll. Pair with `global\design_system.md`, `global\ui_components.md`, the `generate_ui_component`
skill, and ship via `verify_and_ship_v1` (`global\deployment.md`).

## 1. Design language (editorial luxury)

- Typography: refined display face (serif e.g. Canela/Ogg/GT-Super, or a couture sans) for
  headlines + clean sans for body; large airy headings, tight display tracking, generous body
  leading. License real fonts; system fallbacks are not the final state.
- Palette: restrained, high-contrast — typically near-black / ivory-cream / one metallic or brand
  accent; ≤ ~3 colors. Dark sections common — verify contrast.
- Whitespace & grid: heavy negative space; asymmetric editorial grid; full-bleed sections
  alternating with centered text moments.
- Imagery: cinematic, color-graded, consistent art direction. Hero is usually autoplay/muted/looping
  video (with poster) or a large still; product shots on seamless backgrounds.

## 2. Motion system (the differentiator)

Slow, smooth, intentional — never bouncy.

- Smooth scroll with inertia (Lenis).
- Scroll-driven storytelling: pin sections, scrub animation to scroll (GSAP + ScrollTrigger;
  Framer Motion `useScroll` for lighter React needs).
- Reveal on enter: fade + rise (~20–40px, 600–1000ms, ease `cubic-bezier(.16,1,.3,1)`), staggered.
- Parallax: subtle differential movement (5–15%).
- Horizontal galleries: collection rows scrolling sideways on vertical scroll.
- Transitions: crossfades / masked image reveals, not hard cuts.
- Micro-interactions: restrained hover; custom cursor only if it adds elegance.

## 3. Recommended stack

- Framework: Next.js (App Router) for SEO + image optimization, or Astro for content-heavy sites.
- Motion: GSAP + ScrollTrigger (+ Lenis); or Framer Motion for simpler React.
- Styling: Tailwind or CSS Modules; design tokens for type scale, spacing, color.
- Media: `next/image` (AVIF/WebP, responsive `sizes`); `<video>` with `poster`; preload hero only;
  lazy-load below the fold.

## 4. Section blueprint

Cinematic hero → brand statement → collection showcase (horizontal/pinned) → product spotlight(s)
with scrubbed reveals → craftsmanship/story chapter (parallax) → editorial image grid → CTA →
refined footer + newsletter.

## 5. Performance budget (non-negotiable)

- LCP < 2.5s — hero media is the LCP; preload, poster, compress hard.
- CLS ~0 — reserve media dimensions; avoid font/image layout shift (`font-display: swap` +
  size-adjust).
- Lazy-load offscreen media; start/stop autoplay video via `IntersectionObserver`; keep JS lean.

## 6. Accessibility & i18n (do not trade away for aesthetics)

- `prefers-reduced-motion: reduce` is REQUIRED — disable parallax/scrub/auto-motion, show static
  states; wire into every animation.
- Keyboard navigable; visible (styled) focus states.
- Verify WCAG contrast (≥ 4.5:1 body) — dark luxury palettes often fail.
- Video muted autoplay only; captions/controls where there's speech; meaningful `alt`.
- Locale/region routing, currency, RTL-awareness.

## 7. Guardrails / Definition of Done

- Mobile-first — hero and scroll story must work on a phone.
- Passes the DoD gate (`orchestration\definition_of_done.md`): typecheck/lint/build + deployed-URL
  smoke check.
- Reduced-motion path verified; LCP/CLS within budget; no console errors; fonts/images licensed.
- If the site collects leads, honor PII / marketing-analytics rules (`global\enforcement_design.md`).

## Inputs / Outputs

- Inputs: brand guidelines (fonts, palette, tone), art direction / media, target locales, IA,
  conversion goal. Missing assets → `TODO`; never invent brand fonts/colors.
- Outputs: the site/landing page, a documented motion + reduced-motion approach, and design tokens.

<!-- v1. See orchestration\versioning_rules.md for when to create a v2. -->

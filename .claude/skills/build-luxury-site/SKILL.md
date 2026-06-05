---
name: build-luxury-site
description: Design and build a luxury / immersive brand-experience website or landing page — cinematic scroll-driven storytelling, refined editorial typography, parallax and reveal-on-scroll motion, full-bleed video/imagery (e.g. a Cartier "Watches & Wonders"–class microsite). Use when the task is a high-end marketing site, brand campaign page, product showcase, or any "make it feel premium / animated / immersive" front-end. Not for internal dashboards/admin UIs (use design_dashboard).
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# Build a Luxury / Immersive Brand Site

Reference class: Cartier *Watches & Wonders*, Apple product pages, high-jewellery/automotive microsites.
The defining trait is **restraint + cinematic motion**: very few elements, generous space, slow
deliberate animation tied to scroll. Pair this with `global\design_system.md`, `global\ui_components.md`,
the `generate_ui_component` skill, and ship via `verify_and_ship` (`global\deployment.md`).

## 1. Design language (editorial luxury)

- **Typography:** a refined display face (serif like Canela/Ogg/GT-Super, or a couture sans) for
  headlines + a clean sans for body. Large, airy headings; tight tracking on display, generous
  leading on body. Type *is* the brand — license real fonts; don't ship system fallbacks as final.
- **Palette:** restrained and high-contrast. Typically near-black / ivory-cream / one metallic or
  brand accent (gold, oxblood). Avoid more than ~3 colors. Dark sections are common — verify contrast.
- **Whitespace & grid:** lots of negative space; asymmetric editorial grid; full-bleed sections
  alternating with centered text moments. Let single hero images/products breathe.
- **Imagery:** cinematic, color-graded, consistent art direction. Hero is usually an autoplay,
  muted, looping video (with a static poster) or a large still. Product photography on seamless
  backgrounds.

## 2. Motion system (the differentiator)

Motion is slow, smooth, and intentional — never bouncy or playful.

- **Smooth scroll:** add inertia/easing (e.g. **Lenis**) so the whole page glides.
- **Scroll-driven storytelling:** pin sections and scrub animations to scroll (**GSAP + ScrollTrigger**
  is the industry standard; Framer Motion `useScroll` for lighter React needs).
- **Reveal on enter:** headings/images fade + rise (~20–40px, 600–1000ms, ease like
  `cubic-bezier(.16,1,.3,1)`), staggered.
- **Parallax:** background/foreground move at different rates; subtle (5–15%).
- **Horizontal galleries:** collection rows that scroll sideways as you scroll down.
- **Page/section transitions:** crossfades and masked image reveals, not hard cuts.
- **Micro-interactions:** restrained hover states, custom cursor only if it adds elegance.

## 3. Recommended stack

- **Framework:** Next.js (App Router) for SEO + image optimization, or Astro for content-heavy sites.
- **Motion:** GSAP + ScrollTrigger (+ Lenis for smooth scroll); or Framer Motion for simpler React.
- **Styling:** Tailwind or CSS Modules; design tokens for type scale, spacing, color.
- **Media:** `next/image` (AVIF/WebP, responsive `sizes`), `<video>` with `poster`, `preload` hero
  only, lazy-load everything below the fold.

## 4. Section blueprint

Cinematic hero → brand statement (one line, big) → collection showcase (horizontal or pinned) →
product spotlight(s) with scrubbed detail reveals → craftsmanship/story chapter (parallax) →
editorial image grid → CTA (discover / book appointment / locator) → refined footer + newsletter.

## 5. Performance budget (non-negotiable)

- **LCP < 2.5s:** hero media is the LCP — preload it, serve a poster, compress hard.
- **CLS ~0:** reserve dimensions for all media; no layout shift from fonts (`font-display: swap` +
  size-adjust) or late-loading images.
- Lazy-load offscreen media; cap autoplay video weight; use `IntersectionObserver` to start/stop.
- Keep JS lean — GSAP/Lenis are fine; avoid stacking redundant animation libs.

## 6. Accessibility & i18n (do not trade away for aesthetics)

- **`prefers-reduced-motion: reduce` is REQUIRED** — disable parallax/scrub/auto-motion and show
  static states. Wire it into every animation, not as an afterthought.
- Keyboard navigable; visible focus styles (style them to match the luxury look, don't remove them).
- Dark/low-contrast luxury palettes frequently fail WCAG — check text contrast (≥ 4.5:1 body).
- Video: muted autoplay only; provide captions/controls where there's speech; meaningful `alt`.
- Internationalization: locale/region routing, currency, RTL-awareness (Cartier ships many locales).

## 7. Guardrails / Definition of Done

A luxury site is not "done" because it looks good in a desktop demo:

- **Mobile-first:** the hero and scroll story must work on a phone (most luxury traffic is mobile).
- Passes the DoD gate (`orchestration\definition_of_done.md`): typecheck/lint/build, and a smoke
  check on the deployed URL.
- Reduced-motion path verified; LCP/CLS within budget; no console errors; images/fonts licensed.
- No PII/marketing-analytics violations if the site collects leads (see `enforcement_design.md`).

## Inputs / Outputs

**Inputs:** brand guidelines (fonts, palette, tone), art direction / media assets, target locales,
sections/IA, conversion goal. If assets are missing, mark `TODO` — do not invent brand fonts/colors.
**Outputs:** the site/landing page, a documented motion/reduced-motion approach, and design tokens.

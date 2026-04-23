---
name: design-tokens
description: Defines all design token values including colors, typography, spacing, shadows, borders, CTA styles, and brand invariants. Single source of truth for the visual identity. Use when applying design tokens, setting up brand colors, typography, or spacing for any landing page.
version: "5.4.0"
---

# Design Guide — Token Authority

> **v5.0 note:** All {PLACEHOLDER} values in this file are now filled by design-tokens/token-values.md — the centralized token value file. Read design-tokens/token-values.md alongside this file in every session.

This file is the single source of truth for all design token values. No other skill file defines token values — they reference this file.

→ For how tokens are expressed in CSS: see `css-js-generator/SKILL.md`
→ For how tokens are applied to components: see `component-library/SKILL.md`
→ For how tokens are overridden by trends: see `trend-adapter/SKILL.md`
→ For how token values are extracted from various sources: see `design-tokens/token-sources.md`

---

## 1 — Brand Invariants

These values are locked. No trend adaptation, variation, or override may change them. The agent must verify these after any modification pipeline.

| Invariant | Value | Notes |
|---|---|---|
| Brand primary color | `{PLACEHOLDER}` | Dominant brand theme color — the visual identity of the site |
| CTA color | `{PLACEHOLDER}` | Action button color — may or may not equal brand primary |
| Brand font (headings) | `{PLACEHOLDER}` | Heading font family |
| Body font | `{PLACEHOLDER}` | System font stack or brand-specified body font |
| CTA hierarchy | Primary (filled action) → Secondary (filled brand) → Highlight (filled accent) → Outline → Outline-inverse | Order and visual weight must be maintained |

→ Additional invariants enforced in code output: see `css-js-generator/SKILL.md` (breakpoints, file format, naming conventions)

---

## 2 — Color Palette

### 2.1 — Brand Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-primary` | `{PLACEHOLDER}` | Dominant brand theme color — headers, nav accents, section tints, feature highlights. This is the site's visual identity (50%+ of branded areas). |
| `color-secondary` | `{PLACEHOLDER}` | Complementary brand color — supports primary, used sparingly |

### 2.2 — CTA Colors

CTA color is separated from brand primary because many brands use a contrasting action color (e.g. red CTAs on a blue-themed site). When CTA and primary happen to be the same color, both tokens hold the same value.

| Token Name | Value | Usage |
|---|---|---|
| `color-cta` | `{PLACEHOLDER}` | Primary action button background. May equal `color-primary` or be a distinct contrasting color. |
| `color-cta-hover` | `{PLACEHOLDER}` | Primary CTA hover state (typically `color-cta` darkened ~10%) |
| `color-cta-active` | `{PLACEHOLDER}` | Primary CTA active/pressed state (typically `color-cta` darkened ~15%) |

### 2.3 — Neutral Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-text-primary` | `{PLACEHOLDER}` | Headings, primary body text |
| `color-text-secondary` | `{PLACEHOLDER}` | Descriptions, supporting text |
| `color-text-tertiary` | `{PLACEHOLDER}` | Captions, metadata, muted text |
| `color-text-inverse` | `{PLACEHOLDER}` | Text on dark backgrounds |
| `color-border-default` | `{PLACEHOLDER}` | Default borders on cards, inputs, dividers |
| `color-border-light` | `{PLACEHOLDER}` | Subtle borders, section separators |
| `color-bg-page` | `{PLACEHOLDER}` | Page background |
| `color-bg-surface` | `{PLACEHOLDER}` | Card and component backgrounds |
| `color-bg-elevated` | `{PLACEHOLDER}` | Elevated surfaces (modals, dropdowns) |

### 2.4 — Semantic Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-success` | `{PLACEHOLDER}` | Success states, positive indicators |
| `color-warning` | `{PLACEHOLDER}` | Warning states, caution indicators |
| `color-error` | `{PLACEHOLDER}` | Error states, destructive actions |
| `color-info` | `{PLACEHOLDER}` | Informational highlights |

### 2.5 — Section Surfaces

Surfaces are named section backgrounds chosen by **semantic role**, not by position. The builder picks a surface based on what the section *means*, not where it falls on the page.

| Surface Name | Token | Value | Role |
|---|---|---|---|
| **Brand** | `surface-brand` | `{PLACEHOLDER}` | Bold brand sections — hero banners, feature showcases |
| **Brand Strong** | `surface-brand-strong` | `{PLACEHOLDER}` | Deeper emphasis — reinforcement sections, pricing highlights |
| **Subtle** | `surface-subtle` | `{PLACEHOLDER}` | Light tinted break — feature overviews, FAQ, social proof |
| **Brand Subtle** | `surface-brand-subtle` | `{PLACEHOLDER}` | Alternate light tint — same visual weight as Subtle, used to avoid repeating the same surface |
| **Inverse** | `surface-inverse` | `{PLACEHOLDER}` | Dark sections — hero, footer, closing CTA, dark testimonials |
| **Default** | `surface-default` | `{PLACEHOLDER}` | White/page-default — standard content sections |

**Surface assignment rules:**
- Surfaces alternate to create visual rhythm — never place two of the same surface adjacent
- **Default** and **Subtle/Brand Subtle** alternate for the main page body
- **Brand** and **Inverse** are reserved for high-impact sections (hero, CTA, pricing highlight)
- **Brand Strong** is used sparingly — max 1–2 per page for deep emphasis
- Text on Brand/Brand Strong/Inverse surfaces must use `color-text-inverse` (white)
- Text on Default/Subtle/Brand Subtle surfaces uses `color-text-primary`

→ For surface assignment by section type: see `layout-patterns/SKILL.md` Section 2.2
→ For surface CSS implementation: see `css-js-generator/SKILL.md`

---

## 3 — Color Placement Map

This section defines **where** each color token is applied on the page. Placements are split into two categories: hardcoded (always follow the rule) and AI-flexible (the builder selects from token options, validated by WCAG).

### 3.1 — Color Application Model

- **Primary color** is the dominant brand color — 50%+ of branded areas (theme backgrounds, accents). Visual identity of the site.
- **CTA color** is the action button color — may equal primary or be a distinct contrasting color (e.g., red CTA on a blue-themed site).
- **Surfaces** are section backgrounds chosen by semantic role (§2.5): Brand, Brand Strong, Subtle, Brand Subtle, Inverse, Default.
- **Text color** follows surface: dark text on light surfaces, inverse text on dark/brand surfaces.

→ Color extraction: `design-tokens/token-sources.md`

### 3.2 — Hardcoded Placements

No AI discretion — follow exactly.

| Placement Area | Token | Rule |
|---|---|---|
| Primary button background | `button-primary-bg` | Action color (typically CTA red) |
| Primary button hover | `button-primary-bg-hover` | Always |
| Primary button text | `button-primary-text` | From DS (typically white) |
| Secondary button background | `button-secondary-bg` | Brand color (typically blue) |
| Secondary button hover | `button-secondary-bg-hover` | Always |
| Secondary button text | `button-secondary-text` | From DS (typically white) |
| Highlight button background | `button-highlight-bg` | Accent color (typically yellow/gold) |
| Highlight button hover | `button-highlight-bg-hover` | Always |
| Highlight button text | `button-highlight-text` | From DS (typically dark) |
| Outline button border | `button-primary-bg` | CTA-colored border, transparent fill |
| Outline button text | `button-primary-bg` | Matches border color |
| Outline-inverse border | `color-neutral-700` | Neutral border for dark surfaces |
| Body text | `color-text-primary` | All paragraph text, list items |
| Description / supporting text | `color-text-secondary` | Subtitles, metadata, card descriptions |
| Caption / muted text | `color-text-tertiary` | Timestamps, footnotes, helper text |
| Text on Brand/Inverse surfaces | `color-text-inverse` | Any text over Brand, Brand Strong, or Inverse surfaces |
| Page background | `color-bg-page` | `<body>` and `surface-default` sections |
| Card / component surface | `color-bg-surface` | Card backgrounds, modal backgrounds |
| Default borders | `color-border-default` | Card borders, input borders, dividers |

### 3.3 — AI-Flexible Placements

The builder selects a **surface** (§2.5) based on section purpose. Every choice must pass WCAG validation (§3.4).

| Section Type | Surface Options | Guidance |
|---|---|---|
| Hero banner | `surface-brand`, `surface-inverse`, `surface-default` + image | Brand/Inverse for impact; Default if hero has a background image |
| Feature overview / grid | `surface-default`, `surface-subtle` | Light surfaces — content is the focus |
| How it works / value props | `surface-subtle`, `surface-brand-subtle` | Gentle visual break from Default sections |
| Social proof / testimonials | `surface-subtle`, `surface-default` | Subtle differentiation |
| Trust signals / logos | `surface-subtle`, `surface-brand-subtle` | Light tint to group logos visually |
| Statistics / metrics | `surface-brand`, `surface-brand-strong` | Bold surface draws attention to numbers |
| Pricing | `surface-default`, `surface-subtle` | Clean background; use `surface-brand` only for the highlighted tier card |
| FAQ | `surface-subtle`, `surface-default` | Low-emphasis section |
| Closing CTA | `surface-brand`, `surface-brand-strong`, `surface-inverse` | High-impact — match or complement hero surface |
| Footer | `surface-inverse` | Dark footer is standard for marketing sites |
| Feature icon color | `color-primary`, `color-secondary` | Match brand emphasis |
| Nav active state | `color-primary` | Active link indicator |
| Tag / badge background | `surface-subtle` or `color-primary` at low opacity | Labels, category tags |

### 3.4 — WCAG Validation Rules

Every color placement — hardcoded or AI-flexible — must satisfy WCAG 2.1 AA contrast requirements before final output.

| Content Type | Minimum Contrast Ratio | Against |
|---|---|---|
| Normal text (< 18px regular, < 14px bold) | 4.5 : 1 | Its background color |
| Large text (≥ 18px regular, ≥ 14px bold) | 3 : 1 | Its background color |
| UI components (buttons, inputs, icons) | 3 : 1 | Adjacent background color |
| Focus indicators | 3 : 1 | Surrounding background |
| Non-text contrast (graphical objects, charts) | 3 : 1 | Adjacent colors |

**Validation process for AI-flexible placements:**
1. Choose a token from the options column
2. Calculate contrast ratio between text/element color and its background
3. If it passes → apply
4. If it fails → try next token option from the list
5. If all options fail → adjust opacity or lightness to meet ratio, flag with `/* WCAG-adjusted */`
6. Never skip validation — every color pair in the final output must pass

**Text hierarchy proximity check (pre-build):**

After extracting `color-text-primary` and `color-text-secondary`, verify they are visually distinguishable. If too similar, the heading/body hierarchy is invisible.

```
Approximate perceptual distance (simplified):
  ΔR = R1 - R2,  ΔG = G1 - G2,  ΔB = B1 - B2
  distance = sqrt(ΔR² + ΔG² + ΔB²)

  distance < 30  → FLAG: "text-primary and text-secondary are near-identical
                    (distance {N}). Hierarchy will be invisible. Confirm with
                    user or lighten text-secondary by +40 on lightness."
  distance 30–60 → OK but subtle — note in Build Card
  distance > 60  → good separation
```

Run this check once after token extraction, before any frame creation. If flagged, ask the user before proceeding.

---

## 4 — Typography Scale

### 4.1 — Font Families

| Token Name | Value | Usage |
|---|---|---|
| `font-heading` | `{PLACEHOLDER}` | All headings (H1–H6), display text |
| `font-body` | `{PLACEHOLDER}` | Body text, descriptions, UI elements |
| `font-mono` | `{PLACEHOLDER}` | Code snippets, technical content (if applicable) |

**CDN reference for heading font:** `{PLACEHOLDER}` (if applicable)

### 4.2 — Size Scale

| Token Name | Value | Usage |
|---|---|---|
| `font-size-display` | `{PLACEHOLDER}` | Hero H1, oversized display headings |
| `font-size-h1` | `{PLACEHOLDER}` | Page-level H1 (if not display) |
| `font-size-h2` | `{PLACEHOLDER}` | Section headings |
| `font-size-h3` | `{PLACEHOLDER}` | Sub-section headings, card titles |
| `font-size-h4` | `{PLACEHOLDER}` | Minor headings, feature names |
| `font-size-body-lg` | `{PLACEHOLDER}` | Lead paragraphs, hero subheadlines |
| `font-size-body` | `{PLACEHOLDER}` | Default body text |
| `font-size-body-sm` | `{PLACEHOLDER}` | Captions, metadata, small print |

### 4.3 — Weight Scale

| Token Name | Value | Usage |
|---|---|---|
| `font-weight-bold` | `{PLACEHOLDER}` | Headings, emphasis |
| `font-weight-semibold` | `{PLACEHOLDER}` | Sub-headings, button labels |
| `font-weight-regular` | `{PLACEHOLDER}` | Body text, descriptions |
| `font-weight-light` | `{PLACEHOLDER}` | Display text (if light style is used) |

### 4.4 — Line Heights

| Token Name | Value | Usage |
|---|---|---|
| `line-height-heading` | `{PLACEHOLDER}` | All headings |
| `line-height-body` | `{PLACEHOLDER}` | Body text, descriptions |
| `line-height-tight` | `{PLACEHOLDER}` | Display text, compact headings |

### 4.5 — Letter Spacing

| Token Name | Value | Usage |
|---|---|---|
| `letter-spacing-heading` | `{PLACEHOLDER}` | Headings (typically negative for large text) |
| `letter-spacing-body` | `normal` | Body text (default) |
| `letter-spacing-caps` | `{PLACEHOLDER}` | Uppercase labels, overlines |

---

## 5 — Spacing Scale

### 5.1 — Base Scale

A consistent spacing scale used across all components and layouts. All spacing values are derived from a base unit.

| Token Name | Value | Usage |
|---|---|---|
| `space-unit` | `{PLACEHOLDER}` | Base unit (e.g., 4px or 8px) |
| `space-xs` | `{PLACEHOLDER}` | Tightest spacing — inline elements, icon gaps |
| `space-sm` | `{PLACEHOLDER}` | Small gaps — within components |
| `space-md` | `{PLACEHOLDER}` | Medium gaps — between related elements |
| `space-lg` | `{PLACEHOLDER}` | Large gaps — between component groups |
| `space-xl` | `{PLACEHOLDER}` | Extra large — section internal padding |
| `space-2xl` | `{PLACEHOLDER}` | Section top/bottom padding |
| `space-3xl` | `{PLACEHOLDER}` | Maximum spacing — hero sections, major breaks |

### 5.2 — Layout-Specific Spacing

| Token Name | Value | Usage |
|---|---|---|
| `section-padding-y` | `{PLACEHOLDER}` | Vertical padding for standard sections |
| `section-padding-y-lg` | `{PLACEHOLDER}` | Vertical padding for hero / emphasis sections |
| `content-max-width` | `{PLACEHOLDER}` | Maximum content width within sections |
| `content-max-width-narrow` | `{PLACEHOLDER}` | Narrow content width (text-heavy sections) |
| `sidebar-width` | `{PLACEHOLDER}` | Fixed width of sidebar in sidebar layout types |
| `grid-gutter` | `{PLACEHOLDER}` | Gap between grid columns |
| `card-padding` | `{PLACEHOLDER}` | Internal padding of card components |

→ For responsive adjustments to spacing: see `css-js-generator/SKILL.md`

---

## 6 — Shadows & Elevation

| Token Name | Value | Usage |
|---|---|---|
| `shadow-sm` | `{PLACEHOLDER}` | Subtle depth — hover states, light cards |
| `shadow-md` | `{PLACEHOLDER}` | Default card elevation |
| `shadow-lg` | `{PLACEHOLDER}` | Prominent elevation — modals, featured cards |
| `shadow-none` | `none` | Flat elements, no elevation |

---

## 7 — Border Radius

| Token Name | Value | Usage |
|---|---|---|
| `radius-sm` | `{PLACEHOLDER}` | Buttons, inputs, small elements |
| `radius-md` | `{PLACEHOLDER}` | Cards, containers |
| `radius-lg` | `{PLACEHOLDER}` | Large cards, hero images, featured elements |
| `radius-full` | `9999px` | Circular elements (avatars, badges) |
| `radius-none` | `0` | Sharp corners when needed |

---

## 8 — Button Styles

Five button styles, ordered by visual weight. Every page must respect this hierarchy — Primary carries the strongest emphasis, Outline-inverse the lightest.

### 8.1 — Primary (Filled Action)
The main conversion button. Uses the CTA/action color (typically red or a high-contrast action tone).

| Property | Token | Notes |
|---|---|---|
| Background | `button-primary-bg` | Action color — distinct from brand primary |
| Hover bg | `button-primary-bg-hover` | Darkened ~10% |
| Text | `button-primary-text` | Typically white |
| Font weight | `font-weight-semibold` | |
| Border radius | `radius-sm` or `radius-pill` | From DS — pill (`9999px`) if DS uses rounded buttons |
| Min height | `{PLACEHOLDER}` | e.g., 48px |
| Padding | `{PLACEHOLDER}` | e.g., `12px 32px` |

### 8.2 — Secondary (Filled Brand)
Supporting action button. Uses the brand primary color to reinforce identity without competing with Primary.

| Property | Token | Notes |
|---|---|---|
| Background | `button-secondary-bg` | Brand primary color |
| Hover bg | `button-secondary-bg-hover` | Darkened ~10% |
| Text | `button-secondary-text` | Typically white |
| Font weight | `font-weight-semibold` | |
| Border radius | Same as Primary | |
| Min height | Same as Primary | |
| Padding | Same as Primary | |

### 8.3 — Highlight (Filled Accent)
Attention-drawing button for promotions, special offers, or pricing tier CTAs. Uses an accent color (typically yellow/gold) that contrasts with both Primary and Secondary.

| Property | Token | Notes |
|---|---|---|
| Background | `button-highlight-bg` | Accent color (e.g., yellow/gold) |
| Hover bg | `button-highlight-bg-hover` | Darkened ~10% |
| Text | `button-highlight-text` | Typically dark text (for light accent bg) |
| Font weight | `font-weight-semibold` | |
| Border radius | Same as Primary | |
| Min height | Same as Primary | |
| Padding | Same as Primary | |

### 8.4 — Outline (Ghost Action)
Low-emphasis action button for light surfaces. Transparent fill with a CTA-colored border.

| Property | Token | Notes |
|---|---|---|
| Background | `transparent` | |
| Border | `2px solid button-primary-bg` | Uses CTA color for border |
| Hover bg | `button-primary-bg` at 8–10% opacity | Subtle fill on hover |
| Text | `button-primary-bg` | Matches border color |
| Font weight | `font-weight-semibold` | |
| Border radius | Same as Primary | |
| Min height | Same as Primary | |
| Padding | Same as Primary | |

### 8.5 — Outline-inverse (Ghost on Dark)
Low-emphasis button for dark/inverse surfaces. Neutral light border with white text.

| Property | Token | Notes |
|---|---|---|
| Background | `transparent` | |
| Border | `2px solid color-neutral-700` | Light neutral border |
| Hover bg | `color-text-inverse` at 10% opacity | Subtle white fill |
| Text | `color-text-inverse` | White |
| Font weight | `font-weight-semibold` | |
| Border radius | Same as Primary | |
| Min height | Same as Primary | |
| Padding | Same as Primary | |

### 8.6 — Button Placement Rules

| Context | Recommended Styles | Avoid |
|---|---|---|
| Hero CTA (primary action) | Primary | Highlight, Outline-inverse |
| Hero CTA (secondary action) | Outline, Outline-inverse (on dark hero) | Highlight |
| Pricing — highlighted tier | Primary or Highlight | Outline |
| Pricing — other tiers | Secondary or Outline | |
| Closing CTA section | Primary | Outline (too subtle for closing) |
| Card actions | Secondary, Outline | Primary (too heavy per-card) |
| Nav CTA | Primary or Secondary | Highlight |
| Form submit | Primary | Outline (too subtle for conversion) |
| Banner / promo | Highlight | Outline-inverse |

---

## 9 — Iconography Guidelines

| Property | Value |
|---|---|
| Default icon size | `{PLACEHOLDER}` |
| Feature icon size | `{PLACEHOLDER}` |
| Icon color (on light bg) | `{PLACEHOLDER}` |
| Icon color (on dark bg) | `{PLACEHOLDER}` |
| Icon style | `{PLACEHOLDER}` (e.g., outlined, filled, duotone) |
| Icon stroke width | `{PLACEHOLDER}` (if outlined) |

---

## 10 — Form & Input Tokens

Tokens for the Form component and all input fields. Applied consistently across contact, registration, newsletter, and download-gate form variants.

| Token Name | Value | Usage |
|---|---|---|
| `input-height` | `{PLACEHOLDER}` | Height of single-line text inputs and selects |
| `input-bg` | `{PLACEHOLDER}` | Input field background color |
| `input-border` | `{PLACEHOLDER}` | Input border (e.g. `1px solid {color-border-default}`) |
| `input-border-focus` | `{PLACEHOLDER}` | Border color on focus state |
| `input-radius` | `{PLACEHOLDER}` | Border radius of input fields |
| `input-placeholder-color` | `{PLACEHOLDER}` | Placeholder text color |
| `input-padding` | `{PLACEHOLDER}` | Internal padding within input fields |

---

## 11 — Image Treatment

| Property | Value |
|---|---|
| Product screenshot border | `{PLACEHOLDER}` |
| Product screenshot shadow | `{PLACEHOLDER}` |
| Product screenshot radius | `{PLACEHOLDER}` |
| Hero image max height | `{PLACEHOLDER}` |
| Thumbnail aspect ratio | `{PLACEHOLDER}` |
| Avatar size | `{PLACEHOLDER}` | Square size for person headshots (Team Card, Author Bio, Speaker Card) |
| Map embed height | `{PLACEHOLDER}` | Default height of Map Embed component container |

---

## 12 — Token Sources

Token values can be supplied from 7 different sources. The agent detects which source is available (see `pipeline-workflow` — Token Source Detection) and extracts values accordingly. All sources produce the same output: resolved values in `token-values.md` format.

| # | Source | Recognition Signal |
|---|---|---|
| 1 | Product token file (`.md`) | A `{product}-design-tokens.md` file is attached or referenced |
| 2 | Manual fill | `token-values.md` already has values filled in |
| 3 | Website URL | A website URL is provided alongside the brief |
| 4 | Figma Design System | A Figma library or design system reference is provided |
| 5 | Figma Design Frame | A Figma frame URL or dev link is provided |
| 6 | Screenshot | A `.png` / `.jpg` image is attached |
| 7 | JSON token file | A `.json` file is attached or referenced |

→ Full extraction protocols, token name normalization rules, and gap handling: see `design-tokens/token-sources.md`

---

## 13 — Token Override Protocol

When `trend-adapter/SKILL.md` produces a Trend Adaptation Brief, it contains a Token Override Sheet — a set of replacement values for tokens defined in this file.

**Override rules:**
- Overrides apply as a layer on top of base values — this file is never modified directly
- Only tokens listed in the override sheet change; unlisted tokens retain their base values
- Brand invariants (Section 1) cannot be overridden — the agent must reject any override that attempts to change them
- The agent applies overrides after reading this file and before generating output

**Override format example:**
```css
/* Trend Override: Modern SaaS profile */
/* These replace the corresponding base tokens from design-tokens/SKILL.md */

--{product}-section-padding-y: 64px;    /* overrides base value */
--{product}-font-size-display: 4.2rem;  /* overrides base value */
--{product}-shadow-md: 0 4px 24px rgba(0, 0, 0, 0.08); /* overrides base value */
```

→ Full trend dimension definitions and profiles: see `trend-adapter/SKILL.md`
→ For how overrides are expressed as CSS custom properties: see `css-js-generator/SKILL.md`

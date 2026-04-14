---
name: design-tokens
description: Defines all design token values including colors, typography, spacing, shadows, borders, CTA styles, and brand invariants. Single source of truth for the visual identity. Use when applying design tokens, setting up brand colors, typography, or spacing for any landing page.
version: "5.0.5"
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
| Primary CTA color | `{PLACEHOLDER}` | Brand primary — used for all primary action buttons |
| Brand font (headings) | `{PLACEHOLDER}` | Heading font family |
| Body font | `{PLACEHOLDER}` | System font stack or brand-specified body font |
| CTA hierarchy | Primary (filled) → Secondary (outlined/ghost) → Tertiary (text link) | Order and visual weight must be maintained |

→ Additional invariants enforced in code output: see `css-js-generator/SKILL.md` (breakpoints, file format, naming conventions)

---

## 2 — Color Palette

### 2.1 — Brand Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-primary` | `{PLACEHOLDER}` | Primary CTA backgrounds, key accent elements |
| `color-primary-hover` | `{PLACEHOLDER}` | Primary CTA hover state |
| `color-primary-active` | `{PLACEHOLDER}` | Primary CTA active/pressed state |
| `color-secondary` | `{PLACEHOLDER}` | Secondary brand color if applicable |

### 2.2 — Neutral Colors

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

### 2.3 — Semantic Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-success` | `{PLACEHOLDER}` | Success states, positive indicators |
| `color-warning` | `{PLACEHOLDER}` | Warning states, caution indicators |
| `color-error` | `{PLACEHOLDER}` | Error states, destructive actions |
| `color-info` | `{PLACEHOLDER}` | Informational highlights |

### 2.4 — Tinted Section Colors

The tinted section pattern system uses matched surface/border color pairs. Each tint is used as a section background to create visual rhythm down the page.

| Tint Name | Surface Color | Border Color | Usage |
|---|---|---|---|
| `tint-1` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | First alternate section background |
| `tint-2` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | Second alternate section background |
| `tint-3` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | Third alternate section background |
| `tint-4` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | Fourth alternate section background (if needed) |

**Tint application rule:** Tinted sections alternate with white/default background sections to create visual separation. A tinted section's internal components (cards, borders) use the matched border color from the same tint pair, never a border color from a different tint.

→ For how tinted sections are structured in HTML: see `html-generator/SKILL.md`
→ For how tint pairs are expressed as CSS custom properties: see `css-js-generator/SKILL.md`

---

## 3 — Color Placement Map

This section defines **where** each color token is applied on the page. Placements are split into two categories: hardcoded (always follow the rule) and AI-flexible (the builder selects from token options, validated by WCAG).

### 3.1 — Color Application Model

When a reference site is analyzed, the color system works as follows:
- **Primary color** is the dominant brand color — it covers 50%+ of all brand-colored areas across the site (theme backgrounds, CTAs, accent elements). It is the visual identity of the site.
- **Secondary color** is the complementary color that supports the primary — used sparingly for differentiation.
- **Tertiary/accent** is rare — a third chromatic color if present at all.
- **Surfaces** are the backgrounds that sections sit on. A surface is either: page-default (white/light), primary-tinted (primary at low opacity), secondary-tinted, neutral-tinted (gray), or dark (inverted).

→ For how colors are extracted from reference sources: see `design-tokens/token-sources.md`

### 3.2 — Hardcoded Placements

These placements always map to the specified token. No AI discretion — the builder must follow these exactly.

| Placement Area | Token | Rule |
|---|---|---|
| Primary CTA background | `color-primary` | Brand signature — always primary |
| Primary CTA hover | `color-primary-hover` | Always |
| Primary CTA active | `color-primary-active` | Always |
| Primary CTA text | Auto-calculated | White (`#FFFFFF`) or dark (`color-text-primary`) — whichever passes WCAG 4.5:1 against `color-primary` |
| Secondary CTA border | `color-primary` or `color-border-default` | Must be visually distinct from primary CTA |
| Body text | `color-text-primary` | All paragraph text, list items |
| Description / supporting text | `color-text-secondary` | Subtitles, metadata, card descriptions |
| Caption / muted text | `color-text-tertiary` | Timestamps, footnotes, helper text |
| Text on dark backgrounds | `color-text-inverse` | Any text over dark or primary-colored surfaces |
| Page background | `color-bg-page` | `<body>` and default section background |
| Card / component surface | `color-bg-surface` | Card backgrounds, modal backgrounds |
| Elevated surface | `color-bg-elevated` | Dropdowns, tooltips, popovers |
| Default borders | `color-border-default` | Card borders, input borders, dividers |
| Subtle borders | `color-border-light` | Section separators, light dividers |

### 3.3 — AI-Flexible Placements

The builder selects from the listed token options based on content context. Every choice **must** pass WCAG validation (Section 3.4) before output.

| Placement Area | Token Options | Guidance |
|---|---|---|
| Hero banner background | `color-primary` (solid), `tint-1` (subtle), dark surface, image, `color-bg-page` | Depends on hero variant and content tone |
| Section alternate background | `tint-1`, `tint-2`, `tint-3`, `tint-4` | Alternate with `color-bg-page` for visual rhythm — do not use same tint consecutively |
| Feature icon color | `color-primary`, `color-secondary` | Match brand emphasis; primary for key features |
| Highlight / special text | `color-primary`, `color-secondary` | Use sparingly — only for drawing attention to key phrases |
| Footer background | Dark surface, neutral surface, `tint-1` | Context-dependent; dark footer is common for marketing sites |
| Sidebar background | `color-bg-surface`, `tint-1` | Subtle differentiation from main content |
| Pricing highlight card | `color-primary` background, `tint-1` background | Recommended/featured plan gets visual emphasis |
| Testimonial / quote section | `tint-1`, `tint-2`, `color-bg-page` | Gentle visual break; avoid heavy tints |
| Nav active state / underline | `color-primary` | Active link indicator |
| Tag / badge background | `color-primary` at low opacity, `tint-1` | Labels, category tags |
| Stat / metric highlight | `color-primary`, `color-secondary` | Draw attention to key numbers |
| Form section background | `color-bg-surface`, `tint-1`, `color-bg-page` | Visually group the form area |

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

---

## 4 — Typography Scale

### 3.1 — Font Families

| Token Name | Value | Usage |
|---|---|---|
| `font-heading` | `{PLACEHOLDER}` | All headings (H1–H6), display text |
| `font-body` | `{PLACEHOLDER}` | Body text, descriptions, UI elements |
| `font-mono` | `{PLACEHOLDER}` | Code snippets, technical content (if applicable) |

**CDN reference for heading font:** `{PLACEHOLDER}` (if applicable)

### 3.2 — Size Scale

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

### 3.3 — Weight Scale

| Token Name | Value | Usage |
|---|---|---|
| `font-weight-bold` | `{PLACEHOLDER}` | Headings, emphasis |
| `font-weight-semibold` | `{PLACEHOLDER}` | Sub-headings, button labels |
| `font-weight-regular` | `{PLACEHOLDER}` | Body text, descriptions |
| `font-weight-light` | `{PLACEHOLDER}` | Display text (if light style is used) |

### 3.4 — Line Heights

| Token Name | Value | Usage |
|---|---|---|
| `line-height-heading` | `{PLACEHOLDER}` | All headings |
| `line-height-body` | `{PLACEHOLDER}` | Body text, descriptions |
| `line-height-tight` | `{PLACEHOLDER}` | Display text, compact headings |

### 3.5 — Letter Spacing

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

## 8 — CTA Styles

CTA hierarchy defines three levels. Every page must respect this visual weight order.

### Primary CTA
| Property | Value |
|---|---|
| Background | `color-primary` |
| Text color | `{PLACEHOLDER}` |
| Font weight | `font-weight-semibold` |
| Border radius | `radius-sm` |
| Padding | `{PLACEHOLDER}` |
| Hover background | `color-primary-hover` |
| Active background | `color-primary-active` |

### Secondary CTA
| Property | Value |
|---|---|
| Background | `transparent` |
| Border | `{PLACEHOLDER}` (typically 1–2px solid, brand or neutral color) |
| Text color | `{PLACEHOLDER}` |
| Font weight | `font-weight-semibold` |
| Border radius | `radius-sm` |
| Padding | Same as primary |
| Hover | `{PLACEHOLDER}` |

### Tertiary CTA (Text Link)
| Property | Value |
|---|---|
| Background | `none` |
| Text color | `{PLACEHOLDER}` |
| Font weight | `font-weight-semibold` |
| Text decoration | `{PLACEHOLDER}` |
| Hover | `{PLACEHOLDER}` |

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

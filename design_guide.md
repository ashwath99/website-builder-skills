<!-- meta
name: design_guide
title: Design Guide
version: 3.0
status: active
purpose: Define all design token values — colors, typography, spacing, surfaces — that form the visual identity of ManageEngine landing pages.
owns:
  - Color palette (brand, neutral, semantic, tint pairs)
  - Typography scale (sizes, weights, line-heights)
  - Spacing scale (section padding, content gaps, component spacing)
  - Tinted section pattern system (surface/border color pairs)
  - Brand invariants (locked values no trend or variant may override)
  - CTA hierarchy (primary, secondary, tertiary styles)
  - Shadow and elevation scale
  - Border radius scale
requires:
  - workflow
depends_on: []
referenced_by:
  - components
  - layout_patterns
  - css_js_rules
  - trend_adaptation
  - variation_generator
  - agent_execution_prompt
  - figma_capture
modes:
  mode_a: required
  mode_b: required
  mode_c: required
layer: design_decision
last_updated: 2026-03-16
-->

# Design Guide — Token Authority

This file is the single source of truth for all design token values. No other skill file defines token values — they reference this file.

→ For how tokens are expressed in CSS: see `css_js_rules.md`
→ For how tokens are applied to components: see `components.md`
→ For how tokens are overridden by trends: see `trend_adaptation.md`

---

## 1 — Brand Invariants

These values are locked. No trend adaptation, variation, or override may change them. The agent must verify these after any modification pipeline.

| Invariant | Value | Notes |
|---|---|---|
| Primary CTA color | `#E9142B` | ManageEngine red — used for all primary action buttons |
| Brand font (headings) | ZohoPuvi | Loaded from Zoho CDN |
| Body font | `{PLACEHOLDER}` | System font stack or brand-specified body font |
| CTA hierarchy | Primary (red filled) → Secondary (outlined/ghost) → Tertiary (text link) | Order and visual weight must be maintained |

→ Additional invariants enforced in code output: see `css_js_rules.md` (breakpoints, file format, naming conventions)

---

## 2 — Color Palette

### 2.1 — Brand Colors

| Token Name | Value | Usage |
|---|---|---|
| `color-primary` | `#E9142B` | Primary CTA backgrounds, key accent elements |
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

→ For how tinted sections are structured in HTML: see `html_structure.md`
→ For how tint pairs are expressed as CSS custom properties: see `css_js_rules.md`

---

## 3 — Typography Scale

### 3.1 — Font Families

| Token Name | Value | Usage |
|---|---|---|
| `font-heading` | `'ZohoPuvi', sans-serif` | All headings (H1–H6), display text |
| `font-body` | `{PLACEHOLDER}` | Body text, descriptions, UI elements |
| `font-mono` | `{PLACEHOLDER}` | Code snippets, technical content (if applicable) |

**CDN reference for ZohoPuvi:** `{PLACEHOLDER — Zoho CDN URL}`

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

## 4 — Spacing Scale

### 4.1 — Base Scale

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

### 4.2 — Layout-Specific Spacing

| Token Name | Value | Usage |
|---|---|---|
| `section-padding-y` | `{PLACEHOLDER}` | Vertical padding for standard sections |
| `section-padding-y-lg` | `{PLACEHOLDER}` | Vertical padding for hero / emphasis sections |
| `content-max-width` | `{PLACEHOLDER}` | Maximum content width within sections |
| `content-max-width-narrow` | `{PLACEHOLDER}` | Narrow content width (text-heavy sections) |
| `grid-gutter` | `{PLACEHOLDER}` | Gap between grid columns |
| `card-padding` | `{PLACEHOLDER}` | Internal padding of card components |

→ For responsive adjustments to spacing: see `css_js_rules.md`

---

## 5 — Shadows & Elevation

| Token Name | Value | Usage |
|---|---|---|
| `shadow-sm` | `{PLACEHOLDER}` | Subtle depth — hover states, light cards |
| `shadow-md` | `{PLACEHOLDER}` | Default card elevation |
| `shadow-lg` | `{PLACEHOLDER}` | Prominent elevation — modals, featured cards |
| `shadow-none` | `none` | Flat elements, no elevation |

---

## 6 — Border Radius

| Token Name | Value | Usage |
|---|---|---|
| `radius-sm` | `{PLACEHOLDER}` | Buttons, inputs, small elements |
| `radius-md` | `{PLACEHOLDER}` | Cards, containers |
| `radius-lg` | `{PLACEHOLDER}` | Large cards, hero images, featured elements |
| `radius-full` | `9999px` | Circular elements (avatars, badges) |
| `radius-none` | `0` | Sharp corners when needed |

---

## 7 — CTA Styles

CTA hierarchy defines three levels. Every page must respect this visual weight order.

### Primary CTA
| Property | Value |
|---|---|
| Background | `color-primary` (`#E9142B`) |
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

## 8 — Iconography Guidelines

| Property | Value |
|---|---|
| Default icon size | `{PLACEHOLDER}` |
| Feature icon size | `{PLACEHOLDER}` |
| Icon color (on light bg) | `{PLACEHOLDER}` |
| Icon color (on dark bg) | `{PLACEHOLDER}` |
| Icon style | `{PLACEHOLDER}` (e.g., outlined, filled, duotone) |
| Icon stroke width | `{PLACEHOLDER}` (if outlined) |

---

## 9 — Image Treatment

| Property | Value |
|---|---|
| Product screenshot border | `{PLACEHOLDER}` |
| Product screenshot shadow | `{PLACEHOLDER}` |
| Product screenshot radius | `{PLACEHOLDER}` |
| Hero image max height | `{PLACEHOLDER}` |
| Thumbnail aspect ratio | `{PLACEHOLDER}` |

---

## 10 — Token Override Protocol

When `trend_adaptation.md` produces a Trend Adaptation Brief, it contains a Token Override Sheet — a set of replacement values for tokens defined in this file.

**Override rules:**
- Overrides apply as a layer on top of base values — this file is never modified directly
- Only tokens listed in the override sheet change; unlisted tokens retain their base values
- Brand invariants (Section 1) cannot be overridden — the agent must reject any override that attempts to change them
- The agent applies overrides after reading this file and before generating output

**Override format example:**
```css
/* Trend Override: Modern SaaS profile */
/* These replace the corresponding base tokens from design_guide.md */

--{product}-section-padding-y: 64px;    /* overrides base value */
--{product}-font-size-display: 4.2rem;  /* overrides base value */
--{product}-shadow-md: 0 4px 24px rgba(0, 0, 0, 0.08); /* overrides base value */
```

→ Full trend dimension definitions and profiles: see `trend_adaptation.md`
→ For how overrides are expressed as CSS custom properties: see `css_js_rules.md`

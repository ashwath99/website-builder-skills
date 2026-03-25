<!-- meta
name: design_system_prompt
title: Design System Prompt
version: 1.0
status: active
purpose: Single source of truth for all production token values referenced as {PLACEHOLDER} across the skill file system. Update this file per-task to inject real values without modifying core skill files.
owns:
  - All production token values (colors, typography, spacing, shadows, radii, CTAs, iconography, images)
  - ZohoPuvi CDN URL
  - Body font stack
  - All tinted section color pairs
requires:
  - workflow
depends_on:
  - design_guide
referenced_by:
  - design_guide
  - components
  - layout_patterns
  - css_js_rules
  - figma_capture
  - figma_to_code
  - agent_execution_prompt
modes:
  mode_a: required
  mode_b: required
  mode_c: required
layer: design_decision
last_updated: 2026-03-25
-->

# Design System Prompt — Token Values

This file fills every `{PLACEHOLDER}` in the skill file system. When running any mode, read this file alongside `design_guide.md` — values here override `{PLACEHOLDER}` entries in that file and any other skill file that references them.

**Usage:** Update this file per product or per task. The core skill files remain unchanged.

→ For token structure and rules: see `design_guide.md`
→ For how tokens become CSS custom properties: see `css_js_rules.md`

---

## 1 — Brand Fonts

| Token | Placeholder In | Value |
|---|---|---|
| ZohoPuvi CDN URL | `design_guide.md` Section 3.1 | `{PLACEHOLDER}` |
| Body font (`font-body`) | `design_guide.md` Section 1, 3.1 | `{PLACEHOLDER}` |
| Monospace font (`font-mono`) | `design_guide.md` Section 3.1 | `{PLACEHOLDER}` |

---

## 2 — Brand Colors

| Token | Placeholder In | Value |
|---|---|---|
| `color-primary-hover` | `design_guide.md` Section 2.1 | `{PLACEHOLDER}` |
| `color-primary-active` | `design_guide.md` Section 2.1 | `{PLACEHOLDER}` |
| `color-secondary` | `design_guide.md` Section 2.1 | `{PLACEHOLDER}` |

---

## 3 — Neutral Colors

| Token | Placeholder In | Value |
|---|---|---|
| `color-text-primary` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-text-secondary` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-text-tertiary` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-text-inverse` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-border-default` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-border-light` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-bg-page` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-bg-surface` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |
| `color-bg-elevated` | `design_guide.md` Section 2.2 | `{PLACEHOLDER}` |

---

## 4 — Semantic Colors

| Token | Placeholder In | Value |
|---|---|---|
| `color-success` | `design_guide.md` Section 2.3 | `{PLACEHOLDER}` |
| `color-warning` | `design_guide.md` Section 2.3 | `{PLACEHOLDER}` |
| `color-error` | `design_guide.md` Section 2.3 | `{PLACEHOLDER}` |
| `color-info` | `design_guide.md` Section 2.3 | `{PLACEHOLDER}` |

---

## 5 — Tinted Section Color Pairs

| Tint | Surface Color | Border Color | Placeholder In |
|---|---|---|---|
| `tint-1` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | `design_guide.md` Section 2.4 |
| `tint-2` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | `design_guide.md` Section 2.4 |
| `tint-3` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | `design_guide.md` Section 2.4 |
| `tint-4` | `{PLACEHOLDER}` | `{PLACEHOLDER}` | `design_guide.md` Section 2.4 |

---

## 6 — Typography Scale

### Sizes

| Token | Placeholder In | Value |
|---|---|---|
| `font-size-display` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-h1` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-h2` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-h3` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-h4` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-body-lg` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-body` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |
| `font-size-body-sm` | `design_guide.md` Section 3.2 | `{PLACEHOLDER}` |

### Weights

| Token | Placeholder In | Value |
|---|---|---|
| `font-weight-bold` | `design_guide.md` Section 3.3 | `{PLACEHOLDER}` |
| `font-weight-semibold` | `design_guide.md` Section 3.3 | `{PLACEHOLDER}` |
| `font-weight-regular` | `design_guide.md` Section 3.3 | `{PLACEHOLDER}` |
| `font-weight-light` | `design_guide.md` Section 3.3 | `{PLACEHOLDER}` |

### Line Heights

| Token | Placeholder In | Value |
|---|---|---|
| `line-height-heading` | `design_guide.md` Section 3.4 | `{PLACEHOLDER}` |
| `line-height-body` | `design_guide.md` Section 3.4 | `{PLACEHOLDER}` |
| `line-height-tight` | `design_guide.md` Section 3.4 | `{PLACEHOLDER}` |

### Letter Spacing

| Token | Placeholder In | Value |
|---|---|---|
| `letter-spacing-heading` | `design_guide.md` Section 3.5 | `{PLACEHOLDER}` |
| `letter-spacing-caps` | `design_guide.md` Section 3.5 | `{PLACEHOLDER}` |

---

## 7 — Spacing Scale

### Base Scale

| Token | Placeholder In | Value |
|---|---|---|
| `space-unit` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-xs` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-sm` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-md` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-lg` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-xl` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-2xl` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |
| `space-3xl` | `design_guide.md` Section 4.1 | `{PLACEHOLDER}` |

### Layout Spacing

| Token | Placeholder In | Value |
|---|---|---|
| `section-padding-y` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |
| `section-padding-y-lg` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |
| `content-max-width` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |
| `content-max-width-narrow` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |
| `grid-gutter` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |
| `card-padding` | `design_guide.md` Section 4.2 | `{PLACEHOLDER}` |

---

## 8 — Shadows & Elevation

| Token | Placeholder In | Value |
|---|---|---|
| `shadow-sm` | `design_guide.md` Section 5 | `{PLACEHOLDER}` |
| `shadow-md` | `design_guide.md` Section 5 | `{PLACEHOLDER}` |
| `shadow-lg` | `design_guide.md` Section 5 | `{PLACEHOLDER}` |

---

## 9 — Border Radius

| Token | Placeholder In | Value |
|---|---|---|
| `radius-sm` | `design_guide.md` Section 6 | `{PLACEHOLDER}` |
| `radius-md` | `design_guide.md` Section 6 | `{PLACEHOLDER}` |
| `radius-lg` | `design_guide.md` Section 6 | `{PLACEHOLDER}` |

---

## 10 — CTA Styles

### Primary CTA

| Property | Placeholder In | Value |
|---|---|---|
| Text color | `design_guide.md` Section 7 | `{PLACEHOLDER}` |
| Padding | `design_guide.md` Section 7 | `{PLACEHOLDER}` |

### Secondary CTA

| Property | Placeholder In | Value |
|---|---|---|
| Border | `design_guide.md` Section 7 | `{PLACEHOLDER}` |
| Text color | `design_guide.md` Section 7 | `{PLACEHOLDER}` |
| Hover state | `design_guide.md` Section 7 | `{PLACEHOLDER}` |

### Tertiary CTA (Text Link)

| Property | Placeholder In | Value |
|---|---|---|
| Text color | `design_guide.md` Section 7 | `{PLACEHOLDER}` |
| Text decoration | `design_guide.md` Section 7 | `{PLACEHOLDER}` |
| Hover state | `design_guide.md` Section 7 | `{PLACEHOLDER}` |

---

## 11 — Iconography

| Property | Placeholder In | Value |
|---|---|---|
| Default icon size | `design_guide.md` Section 8 | `{PLACEHOLDER}` |
| Feature icon size | `design_guide.md` Section 8 | `{PLACEHOLDER}` |
| Icon color (light bg) | `design_guide.md` Section 8 | `{PLACEHOLDER}` |
| Icon color (dark bg) | `design_guide.md` Section 8 | `{PLACEHOLDER}` |
| Icon style | `design_guide.md` Section 8 | `{PLACEHOLDER}` |
| Icon stroke width | `design_guide.md` Section 8 | `{PLACEHOLDER}` |

---

## 12 — Image Treatment

| Property | Placeholder In | Value |
|---|---|---|
| Screenshot border | `design_guide.md` Section 9 | `{PLACEHOLDER}` |
| Screenshot shadow | `design_guide.md` Section 9 | `{PLACEHOLDER}` |
| Screenshot radius | `design_guide.md` Section 9 | `{PLACEHOLDER}` |
| Hero image max height | `design_guide.md` Section 9 | `{PLACEHOLDER}` |
| Thumbnail aspect ratio | `design_guide.md` Section 9 | `{PLACEHOLDER}` |

---

## 13 — Component-Level Placeholders

These appear in `components.md` and reference tokens from above.

| Property | Placeholder In | Value |
|---|---|---|
| Hero full-bleed min-height | `components.md` Section 2.2 | `{PLACEHOLDER}` |
| Mobile side margin | `layout_patterns.md` Section 1.1 | `{PLACEHOLDER}` |

---

## How to Use This File

### Per-task workflow
1. Copy this file into your project folder
2. Fill in the `Value` column with production values for the specific product
3. The agent reads this file at session start and substitutes values wherever `{PLACEHOLDER}` appears in other skill files

### Per-product overrides
If different ManageEngine products use different token values (e.g., different secondary colors), maintain one copy of this file per product:
- `msp-design-tokens.md`
- `edr-design-tokens.md`
- `sdp-design-tokens.md`

The agent reads the product-specific file based on the `{product}` prefix in the prompt.

### What stays locked
These values are hardcoded in `design_guide.md` and are NOT in this file because they never change:
- Primary CTA color: `#E9142B`
- Heading font family: `ZohoPuvi`
- CTA hierarchy order: Primary → Secondary → Tertiary
- `radius-full`: `9999px`
- `radius-none`: `0`
- `shadow-none`: `none`
- `letter-spacing-body`: `normal`

---

## Placeholder Count Summary

| Category | Count |
|---|---|
| Brand fonts (CDN URL, body, mono) | 3 |
| Brand colors (hover, active, secondary) | 3 |
| Neutral colors | 9 |
| Semantic colors | 4 |
| Tinted section pairs (4 tints × 2 values) | 8 |
| Typography sizes | 8 |
| Typography weights | 4 |
| Line heights | 3 |
| Letter spacing | 2 |
| Spacing base scale | 8 |
| Spacing layout | 6 |
| Shadows | 3 |
| Border radius | 3 |
| CTA styles (primary + secondary + tertiary) | 8 |
| Iconography | 6 |
| Image treatment | 5 |
| Component-level | 2 |
| **Total** | **85** |

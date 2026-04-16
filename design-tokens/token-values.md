# Token Values — Centralized Placeholder Fill

→ Reference for `design-tokens/SKILL.md`

Fills every `{PLACEHOLDER}` in the skill system. Read alongside `design-tokens/SKILL.md` — values here override placeholders.

**Priority levels:** P1 = must extract (build breaks without), P2 = extract if available (sensible default exists), P3 = always use standard default (skip extraction).

→ Token structure/rules: `design-tokens/SKILL.md` | CSS custom properties: `css-js-generator/SKILL.md`

---

## 1 — Brand Fonts

| Token | Priority | Value |
|---|---|---|
| `font-heading` | **P1** | `{PLACEHOLDER}` |
| `font-body` | **P1** | `{PLACEHOLDER}` |
| Heading font CDN URL | P3 | `{PLACEHOLDER}` |
| `font-mono` | P3 | `{PLACEHOLDER}` |

---

## 2 — Brand Colors

| Token | Priority | Value |
|---|---|---|
| `color-primary` | **P1** | `{PLACEHOLDER}` |
| `color-secondary` | P2 | `{PLACEHOLDER}` |

---

## 2b — CTA Colors

| Token | Priority | Value |
|---|---|---|
| `color-cta` | **P1** | `{PLACEHOLDER}` |
| `color-cta-hover` | **P1** | `{PLACEHOLDER}` |
| `color-cta-active` | P2 | `{PLACEHOLDER}` |

---

## 3 — Neutral Colors

| Token | Priority | Value |
|---|---|---|
| `color-text-primary` | **P1** | `{PLACEHOLDER}` |
| `color-text-secondary` | **P1** | `{PLACEHOLDER}` |
| `color-text-tertiary` | P2 | `{PLACEHOLDER}` |
| `color-text-inverse` | P2 | `{PLACEHOLDER}` |
| `color-border-default` | P2 | `{PLACEHOLDER}` |
| `color-border-light` | P2 | `{PLACEHOLDER}` |
| `color-bg-page` | **P1** | `{PLACEHOLDER}` |
| `color-bg-surface` | **P1** | `{PLACEHOLDER}` |
| `color-bg-elevated` | P2 | `{PLACEHOLDER}` |

---

## 4 — Semantic Colors

| Token | Priority | Value |
|---|---|---|
| `color-success` | P3 | `{PLACEHOLDER}` |
| `color-warning` | P3 | `{PLACEHOLDER}` |
| `color-error` | P3 | `{PLACEHOLDER}` |
| `color-info` | P3 | `{PLACEHOLDER}` |

---

## 5 — Tinted Section Color Pairs

| Tint | Priority | Surface | Border |
|---|---|---|---|
| `tint-1` | P2 | `{PLACEHOLDER}` | `{PLACEHOLDER}` |
| `tint-2` | P2 | `{PLACEHOLDER}` | `{PLACEHOLDER}` |
| `tint-3` | P3 | `{PLACEHOLDER}` | `{PLACEHOLDER}` |
| `tint-4` | P3 | `{PLACEHOLDER}` | `{PLACEHOLDER}` |

---

## 6 — Typography Scale

### Sizes

| Token | Priority | Value |
|---|---|---|
| `font-size-display` | P2 | `{PLACEHOLDER}` |
| `font-size-h1` | P2 | `{PLACEHOLDER}` |
| `font-size-h2` | P2 | `{PLACEHOLDER}` |
| `font-size-h3` | P2 | `{PLACEHOLDER}` |
| `font-size-h4` | P3 | `{PLACEHOLDER}` |
| `font-size-body-lg` | P2 | `{PLACEHOLDER}` |
| `font-size-body` | P2 | `{PLACEHOLDER}` |
| `font-size-body-sm` | P3 | `{PLACEHOLDER}` |

### Weights

| Token | Priority | Value |
|---|---|---|
| `font-weight-bold` | P2 | `{PLACEHOLDER}` |
| `font-weight-semibold` | P2 | `{PLACEHOLDER}` |
| `font-weight-regular` | P2 | `{PLACEHOLDER}` |
| `font-weight-light` | P3 | `{PLACEHOLDER}` |

### Line Heights

| Token | Priority | Value |
|---|---|---|
| `line-height-heading` | P2 | `{PLACEHOLDER}` |
| `line-height-body` | P2 | `{PLACEHOLDER}` |
| `line-height-tight` | P3 | `{PLACEHOLDER}` |

### Letter Spacing

| Token | Priority | Value |
|---|---|---|
| `letter-spacing-heading` | P3 | `{PLACEHOLDER}` |
| `letter-spacing-caps` | P3 | `{PLACEHOLDER}` |

---

## 7 — Spacing Scale

### Base Scale

| Token | Priority | Value |
|---|---|---|
| `space-unit` | P2 | `{PLACEHOLDER}` |
| `space-xs` | P3 | `{PLACEHOLDER}` |
| `space-sm` | P2 | `{PLACEHOLDER}` |
| `space-md` | P2 | `{PLACEHOLDER}` |
| `space-lg` | P2 | `{PLACEHOLDER}` |
| `space-xl` | P3 | `{PLACEHOLDER}` |
| `space-2xl` | P3 | `{PLACEHOLDER}` |
| `space-3xl` | P3 | `{PLACEHOLDER}` |

### Layout Spacing

| Token | Priority | Value |
|---|---|---|
| `section-padding-y` | **P1** | `{PLACEHOLDER}` |
| `section-padding-y-lg` | P3 | `{PLACEHOLDER}` |
| `content-max-width` | **P1** | `{PLACEHOLDER}` |
| `content-max-width-narrow` | P3 | `{PLACEHOLDER}` |
| `sidebar-width` | P3 | `{PLACEHOLDER}` |
| `grid-gutter` | P2 | `{PLACEHOLDER}` |
| `card-padding` | P2 | `{PLACEHOLDER}` |

---

## 8 — Shadows & Elevation

| Token | Priority | Value |
|---|---|---|
| `shadow-sm` | P3 | `{PLACEHOLDER}` |
| `shadow-md` | **P1** | `{PLACEHOLDER}` |
| `shadow-lg` | P3 | `{PLACEHOLDER}` |

---

## 9 — Border Radius

| Token | Priority | Value |
|---|---|---|
| `radius-sm` | P2 | `{PLACEHOLDER}` |
| `radius-md` | **P1** | `{PLACEHOLDER}` |
| `radius-lg` | P3 | `{PLACEHOLDER}` |

---

## 10 — CTA Styles

### Primary CTA

| Property | Priority | Value |
|---|---|---|
| Text color | P2 | `{PLACEHOLDER}` |
| Padding | P2 | `{PLACEHOLDER}` |

### Secondary CTA

| Property | Priority | Value |
|---|---|---|
| Border | P3 | `{PLACEHOLDER}` |
| Text color | P3 | `{PLACEHOLDER}` |
| Hover state | P3 | `{PLACEHOLDER}` |

### Tertiary CTA (Text Link)

| Property | Priority | Value |
|---|---|---|
| Text color | P3 | `{PLACEHOLDER}` |
| Text decoration | P3 | `{PLACEHOLDER}` |
| Hover state | P3 | `{PLACEHOLDER}` |

---

## 11 — Iconography

| Property | Priority | Value |
|---|---|---|
| Default icon size | P3 | `{PLACEHOLDER}` |
| Feature icon size | P3 | `{PLACEHOLDER}` |
| Icon color (light bg) | P3 | `{PLACEHOLDER}` |
| Icon color (dark bg) | P3 | `{PLACEHOLDER}` |
| Icon style | P3 | `{PLACEHOLDER}` |
| Icon stroke width | P3 | `{PLACEHOLDER}` |

---

## 12 — Form & Input Tokens

| Token | Priority | Value |
|---|---|---|
| `input-height` | P3 | `{PLACEHOLDER}` |
| `input-bg` | P3 | `{PLACEHOLDER}` |
| `input-border` | P3 | `{PLACEHOLDER}` |
| `input-border-focus` | P3 | `{PLACEHOLDER}` |
| `input-radius` | P3 | `{PLACEHOLDER}` |
| `input-placeholder-color` | P3 | `{PLACEHOLDER}` |
| `input-padding` | P3 | `{PLACEHOLDER}` |

---

## 13 — Image Treatment

| Property | Priority | Value |
|---|---|---|
| Screenshot border | P3 | `{PLACEHOLDER}` |
| Screenshot shadow | P3 | `{PLACEHOLDER}` |
| Screenshot radius | P3 | `{PLACEHOLDER}` |
| Hero image max height | P3 | `{PLACEHOLDER}` |
| Thumbnail aspect ratio | P3 | `{PLACEHOLDER}` |
| Avatar size | P3 | `{PLACEHOLDER}` |
| Map embed height | P3 | `{PLACEHOLDER}` |

---

## 14 — Component-Level Placeholders

| Property | Priority | Value |
|---|---|---|
| Hero full-bleed min-height | P3 | `{PLACEHOLDER}` |
| Mobile side margin | P3 | `{PLACEHOLDER}` |

---

## How to Use

1. Copy per product → fill Value column → agent reads at session start
2. Per-product overrides: `{product-a}-design-tokens.md`, `{product-b}-design-tokens.md`
3. **P1 tokens:** Agent must extract or ask user. Build breaks without them.
4. **P2 tokens:** Extract if source provides. Use sensible defaults if not.
5. **P3 tokens:** Skip extraction. Use standard defaults from `design-tokens/SKILL.md`.

### Locked Values (not in this file — universal constants)

CTA hierarchy: Primary → Secondary → Tertiary | `radius-full`: 9999px | `radius-none`: 0 | `shadow-none`: none | `letter-spacing-body`: normal

---

## Priority Summary

| Priority | Count | Action |
|---|---|---|
| **P1** (must extract) | 15 | Extract or ask user — build breaks without |
| **P2** (extract if available) | 30 | Use source if available, else sensible default |
| **P3** (standard default) | 53 | Skip extraction — use defaults |
| **Total** | **98** |  |

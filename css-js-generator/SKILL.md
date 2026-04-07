---
name: css-js-generator
description: Defines all CSS and JavaScript output rules including custom property syntax, responsive desktop-first implementation, file organization, tinted section and bento grid CSS, jQuery interaction patterns, animation standards, and code quality rules. Use when generating styles.css and script.js for any landing page.
version: "5.0"
---

# CSS & JS Rules — Code Output Standards

This file defines how `styles.css` and `script.js` are generated. It is the authority on code output format, CSS syntax, responsive behavior, and interaction scripting.

→ For token *values*: see `design-tokens/SKILL.md` (this file defines how to *express* them, not what they are)
→ For HTML markup patterns: see `html-generator/SKILL.md`
→ For component specs: see `component-library/SKILL.md`

---

## 1 — Output Format

Every code generation produces exactly 3 files:

| File | Contains | Notes |
|---|---|---|
| `index.html` | Markup | → Rules in `html-generator/SKILL.md` |
| `styles.css` | All styles | No CSS-in-JS, no CSS modules, single file |
| `script.js` | All JavaScript | jQuery only, single file |

No additional files. No build tools. No preprocessors. The output must work by opening `index.html` in a browser.

---

## 2 — CSS Custom Properties

### 2.1 — Naming Syntax

All design tokens are expressed as CSS custom properties following this pattern:

```
--{product}-{category}-{name}
```

| Category | Examples |
|---|---|
| `color` | `--msp-color-primary`, `--msp-color-text-secondary` |
| `font` | `--msp-font-heading`, `--msp-font-body` |
| `font-size` | `--msp-font-size-h1`, `--msp-font-size-body` |
| `font-weight` | `--msp-font-weight-bold`, `--msp-font-weight-regular` |
| `line-height` | `--msp-line-height-heading`, `--msp-line-height-body` |
| `space` | `--msp-space-sm`, `--msp-space-lg`, `--msp-space-section` |
| `radius` | `--msp-radius-sm`, `--msp-radius-md` |
| `shadow` | `--msp-shadow-sm`, `--msp-shadow-md` |
| `tint` | `--msp-tint-1-surface`, `--msp-tint-1-border` |

### 2.2 — Declaration Block

All custom properties are declared in a `:root` block at the top of `styles.css`:

```css
:root {
  /* Colors — values from design-tokens/SKILL.md */
  --{product}-color-primary: {value};
  --{product}-color-primary-hover: {value};
  --{product}-color-text-primary: {value};
  --{product}-color-text-secondary: {value};
  --{product}-color-bg-page: {value};
  --{product}-color-bg-surface: {value};

  /* Tinted Sections — surface/border pairs from design-tokens/SKILL.md */
  --{product}-tint-1-surface: {value};
  --{product}-tint-1-border: {value};
  --{product}-tint-2-surface: {value};
  --{product}-tint-2-border: {value};

  /* Typography — values from design-tokens/SKILL.md */
  --{product}-font-heading: {value};
  --{product}-font-body: {value};
  --{product}-font-size-display: {value};
  --{product}-font-size-h1: {value};
  --{product}-font-size-h2: {value};
  --{product}-font-size-h3: {value};
  --{product}-font-size-body: {value};
  --{product}-font-size-body-sm: {value};

  /* Spacing — values from design-tokens/SKILL.md */
  --{product}-space-xs: {value};
  --{product}-space-sm: {value};
  --{product}-space-md: {value};
  --{product}-space-lg: {value};
  --{product}-space-xl: {value};
  --{product}-space-section: {value};
  --{product}-content-max-width: {value};
  --{product}-grid-gutter: {value};

  /* Elevation — values from design-tokens/SKILL.md */
  --{product}-shadow-sm: {value};
  --{product}-shadow-md: {value};
  --{product}-shadow-lg: {value};
  --{product}-radius-sm: {value};
  --{product}-radius-md: {value};
  --{product}-radius-lg: {value};
}
```

### 2.3 — Usage Rules

- **Never hardcode** a color, font size, spacing, shadow, or radius value in a ruleset. Always use `var(--{product}-*)`.
- The `:root` block is the only place raw values appear.
- If a Trend Adaptation Brief provides overrides, the overridden values replace the base values in the `:root` block. The rest of the CSS stays unchanged.

---

## 3 — CSS File Organization

`styles.css` is organized in this section order:

```css
/* ==========================================================================
   1. Custom Properties (:root)
   ========================================================================== */

/* ==========================================================================
   2. Reset / Base
   ========================================================================== */

/* ==========================================================================
   3. Typography
   ========================================================================== */

/* ==========================================================================
   4. Layout (containers, grid, content width)
   ========================================================================== */

/* ==========================================================================
   5. Components (one subsection per component block)
   ========================================================================== */

/* --- Hero --- */
/* --- Feature Grid --- */
/* --- Feature Row --- */
/* --- Tab Panel --- */
/* --- Accordion --- */
/* --- Testimonial --- */
/* --- Logo Bar --- */
/* --- Metrics Bar --- */
/* --- CTA Section --- */
/* --- Sticky Bar --- */
/* --- FAQ --- */
/* --- Pricing --- */
/* --- Buttons --- */

/* ==========================================================================
   6. Tinted Sections
   ========================================================================== */

/* ==========================================================================
   7. Utilities
   ========================================================================== */

/* ==========================================================================
   8. Responsive — Tablet (max-width: 1024px)
   ========================================================================== */

/* ==========================================================================
   9. Responsive — Mobile (max-width: 480px)
   ========================================================================== */
```

### Rules
- Components are ordered by their position on the page (hero first, CTA last)
- All responsive styles are grouped in sections 8 and 9 — not scattered after each component
- Section comments use the `===` banner format for scannability

---

## 4 — Responsive Implementation

### 4.1 — Approach: Desktop-First

Base styles (outside any media query) target desktop. Media queries handle smaller screens.

```css
/* Base = desktop */
.msp-feature-grid__content {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--msp-grid-gutter);
}

/* Tablet override */
@media (max-width: 1024px) {
  .msp-feature-grid__content {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Mobile override */
@media (max-width: 480px) {
  .msp-feature-grid__content {
    grid-template-columns: 1fr;
  }
}
```

### 4.2 — Breakpoints

| Breakpoint | Media Query | Target |
|---|---|---|
| Tablet | `@media (max-width: 1024px)` | Tablets, small laptops |
| Mobile | `@media (max-width: 480px)` | Phones |

**Only these two breakpoints.** No additional breakpoints unless explicitly requested.

### 4.3 — Responsive Token Adjustments

At each breakpoint, certain tokens are scaled down. These overrides go inside the media query blocks:

```css
@media (max-width: 1024px) {
  :root {
    --{product}-font-size-display: {reduced value};
    --{product}-font-size-h1: {reduced value};
    --{product}-space-section: {reduced value};
    --{product}-grid-gutter: {reduced value};
  }
}

@media (max-width: 480px) {
  :root {
    --{product}-font-size-display: {further reduced};
    --{product}-font-size-h1: {further reduced};
    --{product}-font-size-h2: {reduced value};
    --{product}-space-section: {reduced value};
  }
}
```

→ For base token values: see `design-tokens/SKILL.md`

### 4.4 — Common Responsive Patterns

| Pattern | Desktop | Tablet | Mobile |
|---|---|---|---|
| Multi-column grid | 3–4 columns | 2 columns | 1 column |
| Side-by-side (hero, feature row) | Two columns | Stack vertically | Stack vertically |
| Horizontal tabs | Tab bar | Scrollable tab bar | Convert to accordion |
| Logo bar | Single row | Wrap to 2 rows | 2-column grid or scroll |
| CTA buttons | Inline side by side | Inline side by side | Stack vertically, full width |
| Section padding | Full `space-section` | Reduced | Further reduced |
| Content max-width | `content-max-width` | With side padding | Full width with side padding |

---

## 5 — Tinted Section CSS

Tinted sections use the surface/border color pairs from `design-tokens/SKILL.md`.

```css
/* Tinted section modifier */
.{product}-section--tinted-1 {
  background-color: var(--{product}-tint-1-surface);
}
.{product}-section--tinted-1 .{product}-feature-card {
  border-color: var(--{product}-tint-1-border);
}

.{product}-section--tinted-2 {
  background-color: var(--{product}-tint-2-surface);
}
.{product}-section--tinted-2 .{product}-feature-card {
  border-color: var(--{product}-tint-2-border);
}
```

**Rule:** Components inside a tinted section use the border color from the same tint pair. Never mix tint-1 surface with tint-2 border.

→ For tint alternation rules (which sections get which tint): see `layout-patterns/SKILL.md`
→ For tint color values: see `design-tokens/SKILL.md`

---

## 6 — Bento Grid CSS

When the bento grid layout is selected (via `trend-adapter/SKILL.md` or `variation-explorer/SKILL.md`):

```css
.{product}-bento-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--{product}-grid-gutter);
}

/* Cell size variants */
.{product}-bento-grid__cell--2x1 {
  grid-column: span 2;
}
.{product}-bento-grid__cell--1x2 {
  grid-row: span 2;
}
.{product}-bento-grid__cell--3x1 {
  grid-column: span 3;
}

/* Responsive collapse */
@media (max-width: 1024px) {
  .{product}-bento-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .{product}-bento-grid__cell--3x1 {
    grid-column: span 2;
  }
}

@media (max-width: 480px) {
  .{product}-bento-grid {
    grid-template-columns: 1fr;
  }
  .{product}-bento-grid__cell--2x1,
  .{product}-bento-grid__cell--1x2,
  .{product}-bento-grid__cell--3x1 {
    grid-column: span 1;
    grid-row: span 1;
  }
}
```

→ For bento layout rules and cell arrangement: see `layout-patterns/SKILL.md`

→ For jQuery interaction patterns, animation standards, and code quality rules: see jquery-patterns.md

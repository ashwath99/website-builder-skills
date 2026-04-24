---
name: css-js-generator
description: Defines all CSS and JavaScript output rules including custom property syntax, responsive desktop-first implementation, file organization, section surface and button style CSS, bento grid CSS, jQuery interaction patterns, animation standards, and code quality rules. Use when generating styles.css and script.js for any landing page.
version: "5.4.0"
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
| `surface` | `--msp-surface-brand`, `--msp-surface-subtle` |
| `button` | `--msp-button-primary-bg`, `--msp-button-highlight-text` |

### 2.2 — Declaration Block

All custom properties are declared in a `:root` block at the top of `styles.css`:

```css
:root {
  /* Colors — values from design-tokens/SKILL.md */
  --{product}-color-primary: {value};
  --{product}-color-cta: {value};
  --{product}-color-cta-hover: {value};
  --{product}-color-text-primary: {value};
  --{product}-color-text-secondary: {value};
  --{product}-color-bg-page: {value};
  --{product}-color-bg-surface: {value};

  /* Section Surfaces — semantic backgrounds from design-tokens/SKILL.md §2.5 */
  --{product}-surface-brand: {value};
  --{product}-surface-brand-strong: {value};
  --{product}-surface-subtle: {value};
  --{product}-surface-brand-subtle: {value};
  --{product}-surface-inverse: {value};
  --{product}-surface-default: {value};

  /* Button Styles — from design-tokens/SKILL.md §8 */
  --{product}-button-primary-bg: {value};
  --{product}-button-primary-bg-hover: {value};
  --{product}-button-primary-text: {value};
  --{product}-button-secondary-bg: {value};
  --{product}-button-secondary-bg-hover: {value};
  --{product}-button-secondary-text: {value};
  --{product}-button-highlight-bg: {value};
  --{product}-button-highlight-bg-hover: {value};
  --{product}-button-highlight-text: {value};

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
   6. Section Surfaces + Button Styles
   ========================================================================== */

/* ==========================================================================
   7. Utilities
   ========================================================================== */

/* ==========================================================================
   8. Accessibility
   ========================================================================== */

/* ==========================================================================
   9. Responsive — Tablet (max-width: 1024px)
   ========================================================================== */

/* ==========================================================================
   10. Responsive — Mobile (max-width: 480px)
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

## 5 — Section Surface CSS + Button Styles

### 5.1 — Surface Modifiers

Each section gets a surface modifier class that sets its background and text color.

```css
/* Surface modifiers — applied to section elements */
.{product}-section--brand {
  background-color: var(--{product}-surface-brand);
  color: var(--{product}-color-text-inverse);
}
.{product}-section--brand-strong {
  background-color: var(--{product}-surface-brand-strong);
  color: var(--{product}-color-text-inverse);
}
.{product}-section--subtle {
  background-color: var(--{product}-surface-subtle);
  color: var(--{product}-color-text-primary);
}
.{product}-section--brand-subtle {
  background-color: var(--{product}-surface-brand-subtle);
  color: var(--{product}-color-text-primary);
}
.{product}-section--inverse {
  background-color: var(--{product}-surface-inverse);
  color: var(--{product}-color-text-inverse);
}
.{product}-section--default {
  background-color: var(--{product}-surface-default);
  color: var(--{product}-color-text-primary);
}
```

**Rule:** Surface modifier sets both background and text color. Components inside the section inherit text color. Never override section text color in a component unless explicitly needed.

### 5.2 — Button Style Classes

Five button styles, each with background, text, hover, and border tokens.

```css
/* Primary — filled action */
.{product}-btn--primary {
  background-color: var(--{product}-button-primary-bg);
  color: var(--{product}-button-primary-text);
  border: none;
}
.{product}-btn--primary:hover {
  background-color: var(--{product}-button-primary-bg-hover);
}

/* Secondary — filled brand */
.{product}-btn--secondary {
  background-color: var(--{product}-button-secondary-bg);
  color: var(--{product}-button-secondary-text);
  border: none;
}
.{product}-btn--secondary:hover {
  background-color: var(--{product}-button-secondary-bg-hover);
}

/* Highlight — filled accent */
.{product}-btn--highlight {
  background-color: var(--{product}-button-highlight-bg);
  color: var(--{product}-button-highlight-text);
  border: none;
}
.{product}-btn--highlight:hover {
  background-color: var(--{product}-button-highlight-bg-hover);
}

/* Outline — ghost action (light surfaces) */
.{product}-btn--outline {
  background-color: transparent;
  color: var(--{product}-button-primary-bg);
  border: 2px solid var(--{product}-button-primary-bg);
}
.{product}-btn--outline:hover {
  background-color: rgba(var(--{product}-button-primary-bg-rgb), 0.08);
}

/* Outline-inverse — ghost on dark surfaces */
.{product}-btn--outline-inverse {
  background-color: transparent;
  color: var(--{product}-color-text-inverse);
  border: 2px solid var(--{product}-color-border-light);
}
.{product}-btn--outline-inverse:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
```

**Shared button base:**
```css
.{product}-btn {
  font-weight: var(--{product}-font-weight-semibold);
  border-radius: var(--{product}-radius-sm);
  padding: 12px 32px;
  min-height: 48px;
  cursor: pointer;
  transition: background-color 0.2s ease, border-color 0.2s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
}
```

→ For surface assignment rules: see `layout-patterns/SKILL.md` §2.2
→ For surface token values: see `design-tokens/SKILL.md` §2.5
→ For button placement rules: see `design-tokens/SKILL.md` §8.6

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

---

## 7 — Accessibility CSS (Mandatory)

Every output MUST include these accessibility rules in the Accessibility section of `styles.css`:

```css
/* ==========================================================================
   8. Accessibility
   ========================================================================== */

/* Reduced motion — disable all transitions and animations */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

/* Focus visible — keyboard-only focus ring */
:focus-visible {
  outline: 2px solid var(--{product}-color-primary);
  outline-offset: 2px;
}

/* Skip link — hidden until focused */
.{product}-skip-link {
  position: absolute;
  top: -100%;
  left: 50%;
  transform: translateX(-50%);
  background: var(--{product}-surface-inverse);
  color: var(--{product}-color-text-inverse);
  padding: 8px 16px;
  z-index: 9999;
  border-radius: var(--{product}-radius-sm);
}
.{product}-skip-link:focus {
  top: 8px;
}
```

**Rules:**
- `prefers-reduced-motion` is mandatory — never ship without it
- `:focus-visible` replaces browser defaults — must use brand primary color
- Skip link markup goes as the first child of `<body>`: `<a href="#main-content" class="{product}-skip-link">Skip to main content</a>`
- The `#main-content` target goes on the first `<main>` or first content section

→ For jQuery interaction patterns, animation standards, and code quality rules: see jquery-patterns.md

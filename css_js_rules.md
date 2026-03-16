<!-- meta
name: css_js_rules
title: CSS & JS Rules
version: 3.0
status: active
purpose: Define all CSS and JavaScript output rules — custom property syntax, responsive implementation, file output format, jQuery interaction patterns, and code quality standards.
owns:
  - CSS custom property naming syntax (--{product}-*)
  - 3-file output format (index.html, styles.css, script.js)
  - Responsive implementation (desktop-first, media query structure)
  - Breakpoint definitions (480px, 1024px)
  - jQuery interaction patterns (tabs, accordion, scroll, sticky)
  - CSS file organization and section ordering
  - Animation and transition standards
  - Code quality rules (no !important, no inline styles, no hardcoded values)
  - Asset path convention (./assets/)
  - Tinted section CSS implementation
  - Bento grid CSS implementation
requires:
  - workflow
  - design_guide
depends_on:
  - html_structure
  - components
referenced_by:
  - figma_to_code
  - agent_execution_prompt
  - trend_adaptation
modes:
  mode_a: not_used
  mode_b: required
  mode_c: required
layer: code_generation
last_updated: 2026-03-16
-->

# CSS & JS Rules — Code Output Standards

This file defines how `styles.css` and `script.js` are generated. It is the authority on code output format, CSS syntax, responsive behavior, and interaction scripting.

→ For token *values*: see `design_guide.md` (this file defines how to *express* them, not what they are)
→ For HTML markup patterns: see `html_structure.md`
→ For component specs: see `components.md`

---

## 1 — Output Format

Every code generation produces exactly 3 files:

| File | Contains | Notes |
|---|---|---|
| `index.html` | Markup | → Rules in `html_structure.md` |
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
  /* Colors — values from design_guide.md */
  --{product}-color-primary: #E9142B;
  --{product}-color-primary-hover: {value};
  --{product}-color-text-primary: {value};
  --{product}-color-text-secondary: {value};
  --{product}-color-bg-page: {value};
  --{product}-color-bg-surface: {value};

  /* Tinted Sections — surface/border pairs from design_guide.md */
  --{product}-tint-1-surface: {value};
  --{product}-tint-1-border: {value};
  --{product}-tint-2-surface: {value};
  --{product}-tint-2-border: {value};

  /* Typography — values from design_guide.md */
  --{product}-font-heading: 'ZohoPuvi', sans-serif;
  --{product}-font-body: {value};
  --{product}-font-size-display: {value};
  --{product}-font-size-h1: {value};
  --{product}-font-size-h2: {value};
  --{product}-font-size-h3: {value};
  --{product}-font-size-body: {value};
  --{product}-font-size-body-sm: {value};

  /* Spacing — values from design_guide.md */
  --{product}-space-xs: {value};
  --{product}-space-sm: {value};
  --{product}-space-md: {value};
  --{product}-space-lg: {value};
  --{product}-space-xl: {value};
  --{product}-space-section: {value};
  --{product}-content-max-width: {value};
  --{product}-grid-gutter: {value};

  /* Elevation — values from design_guide.md */
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

→ For base token values: see `design_guide.md`

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

Tinted sections use the surface/border color pairs from `design_guide.md`.

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

→ For tint alternation rules (which sections get which tint): see `layout_patterns.md`
→ For tint color values: see `design_guide.md`

---

## 6 — Bento Grid CSS

When the bento grid layout is selected (via `trend_adaptation.md` or `variation_generator.md`):

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

→ For bento layout rules and cell arrangement: see `layout_patterns.md`

---

## 7 — jQuery Interaction Patterns

All JS uses jQuery. No other libraries. Wrapped in a ready handler.

### 7.1 — File Structure

```javascript
$(document).ready(function() {
  // Tab functionality
  initTabs();

  // Accordion functionality
  initAccordion();

  // Scroll-triggered behaviors
  initScrollEffects();

  // Sticky bar
  initStickyBar();
});
```

### 7.2 — Tab Switcher

```javascript
function initTabs() {
  $('.{product}-tab-panel__tab').on('click', function() {
    var $this = $(this);
    var targetPanel = $this.attr('aria-controls');

    // Update tab states
    $this.closest('.{product}-tab-panel__tabs')
      .find('.{product}-tab-panel__tab')
      .removeClass('{product}-tab-panel__tab--active')
      .attr('aria-selected', 'false');
    $this.addClass('{product}-tab-panel__tab--active')
      .attr('aria-selected', 'true');

    // Update panel visibility
    $this.closest('.{product}-tab-panel')
      .find('.{product}-tab-panel__panel')
      .removeClass('{product}-tab-panel__panel--active');
    $('#' + targetPanel).addClass('{product}-tab-panel__panel--active');
  });
}
```

### 7.3 — Accordion Toggle

```javascript
function initAccordion() {
  $('.{product}-accordion__trigger').on('click', function() {
    var $item = $(this).closest('.{product}-accordion__item');
    var isOpen = $item.hasClass('{product}-accordion__item--open');

    // Close all items (single-open mode)
    $item.closest('.{product}-accordion__items')
      .find('.{product}-accordion__item')
      .removeClass('{product}-accordion__item--open')
      .find('.{product}-accordion__trigger')
      .attr('aria-expanded', 'false');

    // Open clicked item (if it was closed)
    if (!isOpen) {
      $item.addClass('{product}-accordion__item--open');
      $(this).attr('aria-expanded', 'true');
    }
  });
}
```

### 7.4 — Scroll-Triggered Animations

```javascript
function initScrollEffects() {
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        $(entry.target).addClass('{product}-animate--visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  $('.{product}-animate').each(function() {
    observer.observe(this);
  });
}
```

**CSS for scroll animations:**
```css
.{product}-animate {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}
.{product}-animate--visible {
  opacity: 1;
  transform: translateY(0);
}
```

### 7.5 — Sticky CTA Bar

```javascript
function initStickyBar() {
  var $stickyBar = $('.{product}-sticky-bar');
  if (!$stickyBar.length) return;

  var heroBottom = $('.{product}-hero').offset().top + $('.{product}-hero').outerHeight();

  $(window).on('scroll', function() {
    if ($(window).scrollTop() > heroBottom) {
      $stickyBar.addClass('{product}-sticky-bar--visible');
    } else {
      $stickyBar.removeClass('{product}-sticky-bar--visible');
    }
  });
}
```

### 7.6 — Animated Metrics Counter

```javascript
function initCounters() {
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        var $el = $(entry.target);
        var target = parseInt($el.data('count'), 10);
        $({ count: 0 }).animate({ count: target }, {
          duration: 1500,
          easing: 'swing',
          step: function() {
            $el.text(Math.floor(this.count).toLocaleString());
          },
          complete: function() {
            $el.text(target.toLocaleString());
          }
        });
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  $('.{product}-metrics-bar__value[data-count]').each(function() {
    observer.observe(this);
  });
}
```

---

## 8 — Animation & Transition Standards

| Property | Standard Value |
|---|---|
| Default transition duration | `0.3s` |
| Scroll animation duration | `0.6s` |
| Easing function (UI) | `ease-in-out` |
| Easing function (scroll) | `ease-out` |
| Hover transitions | `transition: {property} 0.3s ease-in-out` |
| No animation on page load | Animations only trigger on scroll or interaction |

**Rule:** Never use `transition: all`. Always specify the exact property being transitioned.

---

## 9 — Code Quality Rules

| Rule | Detail |
|---|---|
| No `!important` | Unless absolutely necessary — document with comment explaining why |
| No inline styles | All styles in `styles.css` |
| No inline scripts | All JS in `script.js` |
| No hardcoded values in rulesets | Everything references `var(--{product}-*)` |
| No ID selectors for styling | IDs are for JS hooks and anchor links only |
| No vendor prefixes manually | Unless targeting a specific known issue (documented with comment) |
| No `float` for layout | Use flexbox or grid |
| No `@import` in CSS | Single file, no imports |
| jQuery version | 3.7.x (latest stable 3.x) |
| No other JS libraries | jQuery only — no Slick, no GSAP, no other plugins |

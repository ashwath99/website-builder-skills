<!-- meta
name: html_structure
title: HTML Structure
version: 4.0
status: active
purpose: Define all HTML generation rules — semantic structure, BEM class naming, section markup patterns, accessibility, and the product class prefix system.
owns:
  - Semantic HTML5 document structure
  - BEM class naming convention and rules
  - Product class prefix system ({product}-)
  - Section markup patterns (HTML for each component type)
  - Heading hierarchy rules
  - Accessibility markup (ARIA, alt text, landmark roles)
  - HTML comment convention (TODOs, section markers)
  - Image tag conventions (paths, alt text, lazy loading)
requires:
  - workflow
  - design_guide
  - components
depends_on:
  - layout_patterns
  - css_js_rules
referenced_by:
  - figma_to_code
  - agent_execution_prompt
modes:
  mode_a: not_used
  mode_b: required
  mode_c: required
layer: code_generation
last_updated: 2026-03-25
-->

# HTML Structure — Markup Rules

This file defines how every HTML element is structured, named, and organized in the generated `index.html` file. It is the authority on markup — `css_js_rules.md` handles how that markup is styled and scripted.

→ For CSS/JS implementation: see `css_js_rules.md`
→ For component specs (content slots, variants): see `components.md`
→ For section sequencing and rhythm: see `layout_patterns.md`
→ For design token values: see `design_guide.md`

---

## 1 — Document Structure

Every generated `index.html` follows this skeleton:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{Page Title}</title>
  <meta name="description" content="{Meta description from brief}">
  <link rel="stylesheet" href="styles.css">
  <!-- TODO: Add heading font CDN link (if applicable) -->
</head>
<body>

  <!-- Navigation (if applicable) -->
  <header class="{product}-header">
    <nav class="{product}-nav">
      <!-- Navigation content -->
    </nav>
  </header>

  <!-- Page Content -->
  <main class="{product}-main">

    <!-- Section: Hero -->
    <section class="{product}-hero">
      <!-- Hero content -->
    </section>

    <!-- Section: {Type} -->
    <section class="{product}-{section-name}">
      <!-- Section content -->
    </section>

    <!-- ...additional sections... -->

  </main>

  <!-- Footer (if applicable) -->
  <footer class="{product}-footer">
    <!-- Footer content -->
  </footer>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="script.js"></script>
</body>
</html>
```

### Rules
- `<main>` wraps all page sections between header and footer
- Each page section is a `<section>` element
- jQuery is loaded from CDN before `script.js`
- No inline styles anywhere — all styling lives in `styles.css`
- No inline scripts — all JS lives in `script.js`

---

## 2 — BEM Class Naming

All classes follow Block Element Modifier (BEM) convention with the product prefix.

### Pattern

```
{product}-{block}__{element}--{modifier}
```

### Components

| Part | Rule | Example |
|---|---|---|
| **Prefix** | Always `{product}-` derived from the content brief | `msp-`, `edr-`, `sdp-` |
| **Block** | The component or section name, lowercase, hyphen-separated | `msp-hero`, `msp-feature-card` |
| **Element** | A child part of the block, separated by `__` | `msp-hero__title`, `msp-feature-card__icon` |
| **Modifier** | A variant or state, separated by `--` | `msp-hero--full-bleed`, `msp-feature-card--highlighted` |

### Naming Rules
- All lowercase, no camelCase
- Hyphens for multi-word names: `feature-card`, not `featureCard` or `feature_card`
- Blocks are never nested in class names: `msp-hero__cta` not `msp-hero__content__cta`
- Maximum one level of element depth: `{block}__{element}` — if deeper nesting is needed, create a new block
- Modifiers can apply to blocks or elements: `msp-hero--dark` (block modifier), `msp-hero__title--large` (element modifier)

### Common Block Names

| Component | Block Name |
|---|---|
| Hero section | `{product}-hero` |
| Feature card | `{product}-feature-card` |
| Feature grid | `{product}-feature-grid` |
| Feature row | `{product}-feature-row` |
| Tabbed panel | `{product}-tab-panel` |
| Accordion | `{product}-accordion` |
| Testimonial card | `{product}-testimonial` |
| Testimonial carousel | `{product}-testimonial-carousel` |
| Logo bar | `{product}-logo-bar` |
| Metrics bar | `{product}-metrics-bar` |
| CTA section | `{product}-cta-section` |
| Sticky CTA bar | `{product}-sticky-bar` |
| FAQ | `{product}-faq` |
| Pricing table | `{product}-pricing` |
| Integration grid | `{product}-integration-grid` |

### Common Element Names

| Element Purpose | Element Name |
|---|---|
| Section/component title | `__title` |
| Section description | `__description` |
| Section content wrapper | `__content` |
| Individual item in a list/grid | `__item` |
| Image element | `__image` |
| Icon element | `__icon` |
| CTA button | `__cta` |
| Text link | `__link` |
| Label/caption | `__label` |
| Wrapper/container | `__wrapper` |

---

## 3 — Section Markup Patterns

### 3.1 — Generic Section Wrapper

Every section follows this base pattern. Specific components nest inside.

```html
<section class="{product}-{section-name} {product}-section--tinted" id="{section-id}">
  <div class="{product}-{section-name}__container">
    <!-- Optional: section heading block -->
    <div class="{product}-{section-name}__header">
      <h2 class="{product}-{section-name}__title">{Section Title}</h2>
      <p class="{product}-{section-name}__description">{Section description}</p>
    </div>
    <!-- Section body content -->
    <div class="{product}-{section-name}__content">
      <!-- Components go here -->
    </div>
  </div>
</section>
```

- `__container` constrains content to `content-max-width`
- `--tinted` modifier is added for tinted background sections
- `id` attribute enables in-page anchor linking

### 3.2 — Hero: Split Image

```html
<section class="{product}-hero {product}-hero--split">
  <div class="{product}-hero__container">
    <div class="{product}-hero__content">
      <h1 class="{product}-hero__title">{Headline}</h1>
      <p class="{product}-hero__description">{Subheadline}</p>
      <div class="{product}-hero__actions">
        <a href="{url}" class="{product}-btn {product}-btn--primary">{Primary CTA}</a>
        <a href="{url}" class="{product}-btn {product}-btn--secondary">{Secondary CTA}</a>
      </div>
    </div>
    <div class="{product}-hero__media">
      <img src="./assets/{image}" alt="{descriptive alt text}" class="{product}-hero__image">
    </div>
  </div>
</section>
```

### 3.3 — Hero: Full Bleed

```html
<section class="{product}-hero {product}-hero--full-bleed">
  <div class="{product}-hero__overlay"></div>
  <div class="{product}-hero__container">
    <h1 class="{product}-hero__title">{Headline}</h1>
    <p class="{product}-hero__description">{Subheadline}</p>
    <div class="{product}-hero__actions">
      <a href="{url}" class="{product}-btn {product}-btn--primary">{Primary CTA}</a>
    </div>
  </div>
</section>
```

### 3.4 — Hero: Product Centered

```html
<section class="{product}-hero {product}-hero--product-centered">
  <div class="{product}-hero__container">
    <h1 class="{product}-hero__title">{Headline}</h1>
    <p class="{product}-hero__description">{Subheadline}</p>
    <div class="{product}-hero__actions">
      <a href="{url}" class="{product}-btn {product}-btn--primary">{Primary CTA}</a>
    </div>
    <div class="{product}-hero__media">
      <div class="{product}-hero__browser-frame">
        <img src="./assets/{image}" alt="{descriptive alt text}" class="{product}-hero__image">
      </div>
    </div>
  </div>
</section>
```

### 3.5 — Hero: Text Bold

```html
<section class="{product}-hero {product}-hero--text-bold">
  <div class="{product}-hero__container">
    <h1 class="{product}-hero__title">{Headline}</h1>
    <p class="{product}-hero__description">{Subheadline}</p>
    <div class="{product}-hero__actions">
      <a href="{url}" class="{product}-btn {product}-btn--primary">{Primary CTA}</a>
    </div>
  </div>
</section>
```

### 3.6 — Feature Grid

```html
<section class="{product}-feature-grid {product}-section--tinted" id="features">
  <div class="{product}-feature-grid__container">
    <div class="{product}-feature-grid__header">
      <h2 class="{product}-feature-grid__title">{Section Title}</h2>
      <p class="{product}-feature-grid__description">{Section description}</p>
    </div>
    <div class="{product}-feature-grid__content {product}-feature-grid__content--3-col">
      
      <div class="{product}-feature-card">
        <div class="{product}-feature-card__icon">
          <!-- Icon: inline SVG or img tag -->
        </div>
        <h3 class="{product}-feature-card__title">{Feature Name}</h3>
        <p class="{product}-feature-card__description">{Feature description}</p>
      </div>

      <!-- Repeat for each feature -->

    </div>
  </div>
</section>
```

Column modifier classes: `--2-col`, `--3-col`, `--4-col`

### 3.7 — Feature Row (Alternating)

```html
<section class="{product}-feature-row {product}-feature-row--image-right" id="feature-{name}">
  <div class="{product}-feature-row__container">
    <div class="{product}-feature-row__content">
      <h3 class="{product}-feature-row__title">{Feature Name}</h3>
      <p class="{product}-feature-row__description">{Feature description}</p>
      <a href="{url}" class="{product}-feature-row__link">{Learn more}</a>
    </div>
    <div class="{product}-feature-row__media">
      <img src="./assets/{image}" alt="{descriptive alt text}" class="{product}-feature-row__image">
    </div>
  </div>
</section>
```

Alternation: odd rows get `--image-right`, even rows get `--image-left`.

### 3.8 — Tabbed Feature Panel

```html
<section class="{product}-tab-panel" id="features-detail">
  <div class="{product}-tab-panel__container">
    <h2 class="{product}-tab-panel__title">{Section Title}</h2>
    
    <div class="{product}-tab-panel__tabs" role="tablist">
      <button class="{product}-tab-panel__tab {product}-tab-panel__tab--active" 
              role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
        {Tab Label 1}
      </button>
      <button class="{product}-tab-panel__tab" 
              role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">
        {Tab Label 2}
      </button>
      <!-- Repeat for each tab -->
    </div>

    <div class="{product}-tab-panel__panels">
      <div class="{product}-tab-panel__panel {product}-tab-panel__panel--active" 
           role="tabpanel" id="panel-1" aria-labelledby="tab-1">
        <div class="{product}-tab-panel__panel-content">
          <h3>{Feature Name}</h3>
          <p>{Feature description}</p>
        </div>
        <div class="{product}-tab-panel__panel-media">
          <img src="./assets/{image}" alt="{alt text}">
        </div>
      </div>
      <!-- Repeat for each panel -->
    </div>
  </div>
</section>
```

→ For tab switching JS: see `css_js_rules.md`

### 3.9 — Accordion

```html
<section class="{product}-accordion" id="{section-id}">
  <div class="{product}-accordion__container">
    <h2 class="{product}-accordion__title">{Section Title}</h2>
    
    <div class="{product}-accordion__items">
      <div class="{product}-accordion__item {product}-accordion__item--open">
        <button class="{product}-accordion__trigger" aria-expanded="true" aria-controls="acc-1">
          <span class="{product}-accordion__trigger-text">{Trigger Text}</span>
          <span class="{product}-accordion__trigger-icon" aria-hidden="true"></span>
        </button>
        <div class="{product}-accordion__content" id="acc-1" role="region">
          <p>{Content text}</p>
        </div>
      </div>
      <!-- Repeat for each item -->
    </div>
  </div>
</section>
```

→ For accordion toggle JS: see `css_js_rules.md`

### 3.10 — Testimonial Card

```html
<div class="{product}-testimonial">
  <blockquote class="{product}-testimonial__quote">
    <p>{Quote text}</p>
  </blockquote>
  <div class="{product}-testimonial__attribution">
    <img src="./assets/{avatar}" alt="{Name}" class="{product}-testimonial__avatar">
    <div class="{product}-testimonial__info">
      <cite class="{product}-testimonial__name">{Name}</cite>
      <span class="{product}-testimonial__role">{Title, Company}</span>
    </div>
  </div>
</div>
```

### 3.11 — Logo Bar

```html
<section class="{product}-logo-bar" id="trusted-by">
  <div class="{product}-logo-bar__container">
    <p class="{product}-logo-bar__label">{Trusted by leading companies}</p>
    <div class="{product}-logo-bar__logos">
      <img src="./assets/{logo}" alt="{Company Name}" class="{product}-logo-bar__logo">
      <!-- Repeat for each logo -->
    </div>
  </div>
</section>
```

### 3.12 — Metrics Bar

```html
<section class="{product}-metrics-bar" id="key-stats">
  <div class="{product}-metrics-bar__container">
    <div class="{product}-metrics-bar__item">
      <span class="{product}-metrics-bar__value">{99.9%}</span>
      <span class="{product}-metrics-bar__label">{Uptime}</span>
    </div>
    <!-- Repeat for each metric -->
  </div>
</section>
```

### 3.13 — CTA Section

```html
<section class="{product}-cta-section {product}-section--tinted" id="get-started">
  <div class="{product}-cta-section__container">
    <h2 class="{product}-cta-section__title">{CTA Headline}</h2>
    <p class="{product}-cta-section__description">{Supporting text}</p>
    <div class="{product}-cta-section__actions">
      <a href="{url}" class="{product}-btn {product}-btn--primary">{Primary CTA}</a>
      <a href="{url}" class="{product}-btn {product}-btn--secondary">{Secondary CTA}</a>
    </div>
  </div>
</section>
```

### 3.14 — FAQ Accordion

Uses the same markup pattern as Section 3.9 (Accordion) with block name `{product}-faq`:

```html
<section class="{product}-faq" id="faq">
  <!-- Same accordion structure with {product}-faq prefix -->
</section>
```

---

## 4 — Heading Hierarchy

| Level | Usage | Rule |
|---|---|---|
| `<h1>` | Hero headline | Exactly one per page |
| `<h2>` | Section headings | One per section |
| `<h3>` | Component-level headings (feature names, testimonial sections) | Multiple per section |
| `<h4>` | Sub-component headings (tab labels used as headings, step titles) | As needed |
| `<h5>`, `<h6>` | Rarely used | Only for deeply nested content |

**Rule:** Never skip heading levels. If a section has an H2 title and needs sub-headings, they must be H3, not H4.

---

## 5 — Accessibility

### Landmark Roles
- `<header>` — site header / navigation
- `<main>` — primary page content
- `<footer>` — site footer
- `<nav>` — navigation blocks
- `<section>` with heading — content sections

### ARIA Attributes

| Component | Required ARIA |
|---|---|
| Tabs | `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`, `aria-controls`, `aria-labelledby` |
| Accordion | `aria-expanded`, `aria-controls`, `role="region"` |
| Carousel | `role="group"`, `aria-label`, `aria-roledescription="slide"` |
| Icons (decorative) | `aria-hidden="true"` |
| Icons (meaningful) | `aria-label="{description}"` |
| Buttons | Meaningful text or `aria-label` if icon-only |

### Image Alt Text

| Image Type | Alt Text Rule |
|---|---|
| Product screenshot | Describe what the screenshot shows: `alt="Dashboard showing real-time network monitoring alerts"` |
| Hero image | Describe the scene or purpose: `alt="IT team collaborating on service desk management"` |
| Decorative image | Empty alt: `alt=""` |
| Logo | Company name: `alt="Acme Corporation"` |
| Icon (meaningful) | Action or concept: `alt="Download"` |
| Icon (decorative) | Empty alt: `alt=""` with `aria-hidden="true"` |

---

## 6 — HTML Comment Convention

### Section Markers
```html
<!-- Section: Hero -->
<section class="{product}-hero">...</section>

<!-- Section: Features -->
<section class="{product}-feature-grid">...</section>
```

### TODO Comments
```html
<!-- TODO: Verify asset path — source unclear from brief -->
<img src="./assets/feature-icon-monitoring.svg" alt="Monitoring">

<!-- TODO: Missing content — brief did not provide testimonial #3 -->

<!-- TODO: Confirm CTA URL with marketing team -->
<a href="#" class="{product}-btn {product}-btn--primary">Start Free Trial</a>
```

### Deviation Comments
```html
<!-- DEVIATION: Figma shows 22px padding, snapped to token --{product}-space-md -->
```

---

## 7 — Image Conventions

| Rule | Detail |
|---|---|
| Path format | Always `./assets/{filename}` |
| Lazy loading | Add `loading="lazy"` on all images below the fold |
| Hero images | No lazy loading (above the fold) |
| Width/height attributes | Include `width` and `height` attributes to prevent layout shift |
| Format preference | SVG for icons/logos, PNG for screenshots, JPG for photos |
| Uncertain mappings | Add `<!-- TODO: verify asset -->` comment above the `<img>` tag |

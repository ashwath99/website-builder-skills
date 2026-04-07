---
name: html-generator
description: Defines all HTML generation rules including semantic document structure, BEM class naming with product prefix, section markup patterns for every component type, heading hierarchy, accessibility markup, and image conventions. Use when generating index.html for any landing page.
version: "5.0"
---

# HTML Structure — Markup Rules

This file defines how every HTML element is structured, named, and organized in the generated `index.html` file. It is the authority on markup — `css-js-generator/SKILL.md` handles how that markup is styled and scripted.

→ For CSS/JS implementation: see `css-js-generator/SKILL.md`
→ For component specs (content slots, variants): see `component-library/SKILL.md`
→ For section sequencing and rhythm: see `layout-patterns/SKILL.md`
→ For design token values: see `design-tokens/SKILL.md`

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

→ For tab switching JS: see `css-js-generator/SKILL.md`

→ For accordion, testimonial, logo bar, metrics, CTA, FAQ markup patterns, heading hierarchy, accessibility, and image conventions: see markup-patterns.md

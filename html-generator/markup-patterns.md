# Additional Markup Patterns, Heading Hierarchy, Accessibility & Image Conventions

→ This file is a reference for html-generator/SKILL.md

---

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

→ For accordion toggle JS: see `css-js-generator/SKILL.md`

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
<section class="{product}-cta-section {product}-section--brand" id="get-started">
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
| Width/height attributes | Include `width` and `height` attributes to prevent layout shift |
| Format preference | SVG for icons/logos, PNG for screenshots, JPG for photos |
| Uncertain mappings | Add `<!-- TODO: verify asset -->` comment above the `<img>` tag |

### Lazy Loading (Mandatory)

**All `<img>` tags below the fold MUST have `loading="lazy"`.**

```html
<!-- Hero (above fold) — NO lazy loading -->
<img src="./assets/hero-screenshot.png" alt="..." width="720" height="450" class="{product}-hero__image">

<!-- Below fold — ALWAYS lazy load -->
<img src="./assets/feature-dashboard.png" alt="..." width="560" height="350" loading="lazy" class="{product}-feature-row__image">
```

**Rules:**
- Hero section images: never lazy (above the fold, must render immediately)
- All other section images: always `loading="lazy"`
- Logo bar images: `loading="lazy"` (even though they may be near the fold — browser handles the threshold)
- Placeholder images (`[IMAGE NEEDED]`): still add `loading="lazy"` so the attribute is in place when real assets swap in

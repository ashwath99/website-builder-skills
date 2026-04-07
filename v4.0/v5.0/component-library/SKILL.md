---
name: component-library
description: Defines every reusable UI component for landing page construction including hero variants, feature components, social proof blocks, and CTA elements. Specifies content slots, configuration variants, responsive behavior, and composition rules for each component type.
version: "5.0"
---

# Components — UI Block Library

This file defines every reusable component available for landing page construction. Each component specifies its content slots, configuration variants, and responsive behavior.

→ For token values applied to components: see `design-tokens/SKILL.md`
→ For HTML markup patterns: see `html-generator/SKILL.md`
→ For CSS implementation rules: see `css-js-generator/SKILL.md`
→ For how components are arranged into page layouts: see `layout-patterns/SKILL.md`

---

## 1 — Component Selection Logic

When the agent maps content from a parsed brief to page components, it uses these rules:

### By Content Type

| Content from Brief | Component | Condition |
|---|---|---|
| Primary headline + subheadline + CTA | Hero | Always — every page has one |
| Feature name + description (short) | Feature Card | When description is ≤ 2 sentences |
| Feature name + description (long) + screenshot | Feature Row | When description is 2+ paragraphs with image |
| Multiple features (4–6, short) | Feature Grid | Grid of Feature Cards |
| Multiple features (7+) | Tabbed Feature Panel | Or Accordion, based on variation axis |
| Testimonial quote + attribution | Testimonial Card | Single quote |
| Multiple testimonials | Testimonial Carousel or Grid | 3+ quotes |
| Customer/partner logos | Logo Bar | Any number of logos |
| Statistic + context label | Metric Item | Single stat |
| Multiple statistics | Metrics Bar | Row of Metric Items |
| Question + answer pairs | FAQ Accordion | Any number of Q&A pairs |
| CTA headline + button(s) | CTA Section | Used as closing section and optionally mid-page |
| Pricing tiers | Pricing Table | Comparison table or card layout |
| Integration/tool logos + descriptions | Integration Grid | Grid of integration cards |

### By Feature Count

| Count | Recommended Component | Layout |
|---|---|---|
| 1–3 | Feature Row (alternating) | Full-width, one per row, image alternating L/R |
| 4–6 | Feature Grid | 2 or 3 columns of Feature Cards |
| 7–9 | Tabbed Feature Panel | Tab bar + detail panel per feature |
| 10+ | Accordion or Multi-section | Grouped into categories, each with its own grid or list |

---

## 2 — Hero Components

### 2.1 — Hero: Split Image

Two-column layout. Text content on one side, image/screenshot on the other.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — primary page headline | Yes |
| `subheadline` | Supporting text, 1–2 sentences | Yes |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary button or text link | Optional |
| `image` | Product screenshot, illustration, or hero image | Yes |
| `trust_badge` | Small logo row or "trusted by" text below CTA | Optional |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `image-right` | Text left, image right (default) |
| `image-left` | Image left, text right |

**Responsive Behavior:**
- Desktop: Two equal columns side by side
- Tablet (≤1024px): Image stacks below text, full width
- Mobile (≤480px): Image scales to full width, CTA becomes full-width button

---

### 2.2 — Hero: Full Bleed

Full-width background (image, gradient, or color) with centered text overlay.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — centered, display scale | Yes |
| `subheadline` | Supporting text, centered | Yes |
| `primary_cta` | Primary button, centered | Yes |
| `secondary_cta` | Secondary button, centered | Optional |
| `background` | Image, gradient, or solid color | Yes |
| `overlay` | Semi-transparent overlay for text readability | Optional (required if background is an image) |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `dark-bg` | Dark background, light text (uses `color-text-inverse`) |
| `light-bg` | Light background, dark text (default) |
| `gradient-bg` | Gradient background, text color based on contrast |

**Responsive Behavior:**
- Desktop: Full viewport width, min-height `{PLACEHOLDER}`
- Tablet / Mobile: Height reduces, text size scales down per typography responsive rules

---

### 2.3 — Hero: Product Centered

Large product screenshot or UI mockup as the focal point. Minimal text.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — above or overlapping the product image | Yes |
| `subheadline` | Brief supporting text | Optional |
| `primary_cta` | Primary button | Yes |
| `product_image` | Large product screenshot in browser/device frame | Yes |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `browser-frame` | Screenshot inside a browser window mockup |
| `device-frame` | Screenshot inside a device mockup (laptop, tablet) |
| `raw` | Screenshot without frame, with shadow |

**Responsive Behavior:**
- Desktop: Product image at full content width below text
- Tablet / Mobile: Image scales proportionally, device frame may be removed for clarity

---

### 2.4 — Hero: Text Bold

No image. Oversized typography dominates. Strong value proposition.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — display scale, oversized | Yes |
| `subheadline` | Supporting text | Optional |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary action | Optional |

**Responsive Behavior:**
- Desktop: Display-size heading, generous vertical padding
- Mobile: Heading scales down but remains dominant; CTA full-width

---

### 2.5 — Hero: Mini

Compact hero with reduced height. Content begins above the fold.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — standard scale (not display) | Yes |
| `subheadline` | Brief text, 1 sentence | Optional |
| `primary_cta` | Primary button | Yes |

**Responsive Behavior:**
- Desktop: Reduced vertical padding, content starts quickly
- Mobile: Behaves like a standard mobile hero

---

## 3 — Feature Components

### 3.1 — Feature Card

A single feature block with icon, heading, and description.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `icon` | Feature icon (SVG or image) | Optional |
| `heading` | H3 or H4 — feature name | Yes |
| `description` | 1–3 sentences describing the feature | Yes |
| `link` | "Learn more" text link | Optional |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `icon-top` | Icon above heading (default for grids) |
| `icon-left` | Icon left of heading/description (inline layout) |
| `no-icon` | Heading + description only |

**Responsive Behavior:**
- Desktop: Maintains grid position (controlled by Feature Grid)
- Mobile: Full-width stack, one card per row

---

### 3.2 — Feature Grid

A grid container for multiple Feature Cards.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Yes |
| `section_description` | Supporting text for the section | Optional |
| `cards` | Array of Feature Card components | Yes (min 2) |

**Configuration Variants:**

| Variant | Columns (Desktop) | Best For |
|---|---|---|
| `2-col` | 2 columns | 2 or 4 features |
| `3-col` | 3 columns | 3, 6, or 9 features |
| `4-col` | 4 columns | 4 or 8 features (compact) |

**Responsive Behavior:**
- Desktop: Specified column count
- Tablet (≤1024px): 2 columns max
- Mobile (≤480px): 1 column, full-width stacked

---

### 3.3 — Feature Row (Alternating)

Full-width row with image on one side and text content on the other. Multiple rows alternate image position.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `heading` | H3 — feature name | Yes |
| `description` | 1–3 paragraphs, detailed feature description | Yes |
| `image` | Product screenshot or illustration | Yes |
| `link` | CTA or "Learn more" link | Optional |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `image-right` | Image right, text left (odd rows) |
| `image-left` | Image left, text right (even rows) |

**Alternation rule:** When multiple Feature Rows are stacked, they automatically alternate image position. First row: image-right, second row: image-left, and so on.

**Responsive Behavior:**
- Desktop: Two columns, ~50/50 split
- Tablet / Mobile: Image stacks above text, full width

---

### 3.4 — Tabbed Feature Panel

Tab bar with one detail panel visible at a time. Each tab shows a feature deep-dive.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `tabs` | Array of tab items, each containing: | Yes (min 3) |
| ↳ `tab_label` | Short label for the tab | Yes |
| ↳ `heading` | H3 — feature name | Yes |
| ↳ `description` | Detailed description | Yes |
| ↳ `image` | Screenshot or illustration | Optional |

**Responsive Behavior:**
- Desktop: Horizontal tab bar above content panel
- Tablet: Tab bar may become scrollable horizontally
- Mobile: Tabs convert to accordion (stacked expandable sections)

→ For tab interaction JS pattern: see `css-js-generator/SKILL.md`

---

### 3.5 — Accordion

Expandable sections, one open at a time.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `items` | Array of accordion items, each containing: | Yes (min 2) |
| ↳ `trigger` | Clickable heading text | Yes |
| ↳ `content` | Expandable body — text, images, or nested components | Yes |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `single-open` | Only one item open at a time (default) |
| `multi-open` | Multiple items can be open simultaneously |
| `first-open` | First item open on load |
| `all-closed` | All items closed on load |

**Responsive Behavior:**
- Consistent across all breakpoints — accordion works at any width

→ For accordion interaction JS pattern: see `css-js-generator/SKILL.md`

---

## 4 — Social Proof Components

### 4.1 — Testimonial Card

A single customer quote with attribution.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `quote` | Customer quote text | Yes |
| `name` | Customer name | Yes |
| `title` | Job title / role | Optional |
| `company` | Company name | Optional |
| `avatar` | Customer photo | Optional |
| `company_logo` | Company logo | Optional |

---

### 4.2 — Testimonial Carousel

Horizontally scrollable or auto-rotating testimonial cards.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `cards` | Array of Testimonial Cards | Yes (min 3) |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `auto-rotate` | Cards cycle automatically with pause on hover |
| `manual` | User-controlled navigation (arrows/dots) |
| `static-grid` | No carousel — cards displayed in a grid (fallback) |

**Responsive Behavior:**
- Desktop: 2–3 cards visible, navigation arrows
- Mobile: 1 card visible, swipe-enabled or stacked

---

### 4.3 — Logo Bar

Horizontal row of partner/customer logos.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `label` | "Trusted by" or similar text above logos | Optional |
| `logos` | Array of logo images | Yes (min 3) |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `static` | Logos displayed in a fixed row |
| `scrolling` | Logos scroll horizontally in an infinite loop |
| `grayscale` | Logos displayed in grayscale, color on hover |

**Responsive Behavior:**
- Desktop: Single row, evenly spaced
- Mobile: Wrap to 2 rows or scroll horizontally

---

### 4.4 — Metrics Bar

Row of key statistics with large numbers and context labels.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `items` | Array of metric items, each containing: | Yes (min 2) |
| ↳ `value` | Large number or stat (e.g., "99.9%", "10K+") | Yes |
| ↳ `label` | Context label (e.g., "Uptime", "Customers") | Yes |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `inline` | Metrics in a single horizontal row |
| `with-dividers` | Vertical dividers between metrics |
| `animated` | Numbers count up on scroll into view |

**Responsive Behavior:**
- Desktop: Single row, evenly distributed
- Mobile: 2-column grid or stacked vertically

---

→ For CTA components, content components, and composition rules: see component-specs.md

---
name: component-library
description: Defines every reusable UI component for marketing website construction including hero variants, feature components, social proof, CTA, content, people/profile, timeline, navigation/index, form, and media components. Specifies content slots, configuration variants, and responsive behavior for each component. Use when mapping brief content to components, selecting component variants, or understanding component composition rules.
version: "5.0.2"
---

# Components — UI Block Library

This file defines every reusable component available for marketing website construction. Each component specifies its content slots, configuration variants, and responsive behavior. Components cover all 14 page types supported by the layout system.

**Boundary note:** This file owns what a component IS — its content slots, purpose, and presentation variants. How a component is spatially arranged on a page (split, grid, sidebar, etc.) is owned by `layout-patterns/SKILL.md`. The same component can be placed in different layout types depending on the page context.

→ For how components are arranged into page layouts: see `layout-patterns/SKILL.md`
→ For token values applied to components: see `design-tokens/SKILL.md`
→ For HTML markup patterns: see `html-generator/SKILL.md`
→ For CSS implementation rules: see `css-js-generator/SKILL.md`
→ For people/profile, timeline, navigation/index, form, media components and composition rules: see `component-specs.md`

---

## 1 — Component Selection Logic

### By Content Type

| Content from Brief | Component | Condition |
|---|---|---|
| Primary headline + subheadline + CTA | Hero | Always — every page has one |
| Feature name + description (short) | Feature Card | Description ≤ 2 sentences |
| Feature name + description (long) + screenshot | Feature Row | Description 2+ paragraphs with image |
| Multiple features (4–6, short) | Feature Grid | Grid of Feature Cards |
| Multiple features (7+) | Tabbed Feature Panel | Or Accordion, based on variation axis |
| Testimonial quote + attribution | Testimonial Card | Single quote |
| Multiple testimonials (3+) | Testimonial Carousel or Grid | Based on variation axis |
| Customer / partner logos | Logo Bar | Any number of logos |
| Single statistic + label | Metric Item | Inline within Metrics Bar |
| Multiple statistics | Metrics Bar | Row of Metric Items |
| Question + answer pairs | FAQ Accordion | Any number of Q&A pairs |
| CTA headline + button(s) | CTA Section | Closing section and optionally mid-page |
| Pricing tiers with names + prices | Pricing Table | Comparison table or card layout |
| Integration / tool logos + descriptions | Integration Grid | Grid of integration cards |
| Large pull quote or highlighted text | Pull Quote | Mid-page editorial emphasis |
| Long-form article body paragraphs | Rich Text Block | Blog article, documentation, case study body |
| Downloadable asset + description | Download Card | Gated or direct download |
| Person photo + name + role + bio | Team Card | About page, company sections |
| Event speaker + photo + title + company | Speaker Card | Event / webinar pages |
| Author + photo + role + short bio | Author Bio | Blog article footer |
| Article title + excerpt + date + author | Article Card | Blog index, resource library, case studies |
| Sequential dated events or milestones | Timeline | Company history, case study journey, roadmap |
| Agenda sessions with times + speakers | Agenda List | Event / webinar pages |
| Live countdown to a future date | Countdown Timer | Event pages |
| Event name + date + time + format | Event Details Block | Event / webinar pages |
| Form fields (contact, registration, etc.) | Form | Contact, event, newsletter, gated download |
| Category / topic filter row | Filter Bar | Blog index, integration catalog, resource library |
| Keyword search input | Search Bar | Documentation hub, resource catalog |
| Page navigation or load more | Pagination | Blog index, catalog pages |
| Grid of images / screenshots / videos | Media Gallery | Portfolio, event highlights, product screenshots |
| Embedded map + location | Map Embed | Contact page with office locations |

### By Feature Count

| Count | Recommended Component | Layout Type (from layout-patterns) |
|---|---|---|
| 1–3 | Feature Row (alternating) | `split-50` or `split-60-40` |
| 4–6 | Feature Grid | `grid-3col` or `grid-2col` |
| 7–9 | Tabbed Feature Panel | `tab-panel` |
| 10+ | Accordion or multi-section | `accordion-stack` |

### By Page Type (Form and Index Selection)

| Page Type | Form Variant | Index/Listing Component |
|---|---|---|
| Contact | `contact` | — |
| Event / Webinar | `registration` | — |
| Resource / Download | `download-gate` | Article Card |
| Blog Index | `newsletter` (optional) | Article Card |
| Partner / Integrations | — | Integration Grid or Article Card |
| Documentation Hub | — | Article Card |

---

## 2 — Hero Components

The Hero component is the page header section. Its spatial arrangement (split, full-bleed, centered) is applied from `layout-patterns` — the variants below define the presentation style and content configuration.

### 2.1 — Hero: Split

Two-column layout. Text content one side, visual the other.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — primary page headline | Yes |
| `subheadline` | Supporting text, 1–2 sentences | Yes |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary button or text link | Optional |
| `image` | Product screenshot, illustration, or hero image | Yes |
| `trust_badge` | Small logo row or "trusted by" text below CTA | Optional |

**Variants:** `image-right` (default) / `image-left`

**Responsive:** Image stacks below text on tablet/mobile. CTA becomes full-width button on mobile.

---

### 2.2 — Hero: Full Bleed

Full-width background (image, gradient, or color) with text overlay.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — centered, display scale | Yes |
| `subheadline` | Supporting text, centered | Yes |
| `primary_cta` | Primary button, centered | Yes |
| `secondary_cta` | Secondary button, centered | Optional |
| `background` | Image, gradient, or solid color | Yes |
| `overlay` | Semi-transparent overlay for readability | Optional (required if background is image) |

**Variants:** `dark-bg` / `light-bg` (default) / `gradient-bg`

**Responsive:** Height reduces; text scales down per typography responsive rules.

---

### 2.3 — Hero: Product Centered

Large product screenshot or UI mockup as focal point. Minimal text above.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — above the product image | Yes |
| `subheadline` | Brief supporting text | Optional |
| `primary_cta` | Primary button | Yes |
| `product_image` | Large product screenshot in browser/device frame | Yes |

**Variants:** `browser-frame` / `device-frame` / `raw` (shadow only)

**Responsive:** Image scales proportionally; device frame may be hidden on mobile.

---

### 2.4 — Hero: Text Bold

No image. Oversized typography dominates. Strong value proposition or brand statement.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — display scale, oversized | Yes |
| `subheadline` | Supporting text | Optional |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary action | Optional |

**Responsive:** Heading scales down on mobile but remains dominant; CTA full-width.

---

### 2.5 — Hero: Mini

Compact header with reduced height. Used when content should begin close to the top — pricing pages, inner pages, error pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `headline` | H1 — standard scale (not display) | Yes |
| `subheadline` | Brief text, 1 sentence | Optional |
| `primary_cta` | Primary button | Optional |

**Responsive:** Behaves like a standard mobile hero.

---

## 3 — Feature Components

### 3.1 — Feature Card

Single feature block with icon, heading, and description. Used inside Feature Grid.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `icon` | Feature icon (SVG or image) | Optional |
| `heading` | H3 or H4 — feature name | Yes |
| `description` | 1–3 sentences | Yes |
| `link` | "Learn more" text link | Optional |

**Variants:** `icon-top` (default) / `icon-left` / `no-icon`

**Responsive:** Full-width stack on mobile.

---

### 3.2 — Feature Grid

Grid container for multiple Feature Cards.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Yes |
| `section_description` | Supporting text | Optional |
| `cards` | Array of Feature Cards | Yes (min 2) |

**Variants:** `2-col` / `3-col` (default) / `4-col`

**Responsive:** 4-col → 2-col tablet → 1-col mobile. 3-col → 2-col tablet → 1-col mobile.

---

### 3.3 — Feature Row

Full-width row with image one side and text the other. Multiple rows alternate image position.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `heading` | H3 — feature name | Yes |
| `description` | 1–3 paragraphs | Yes |
| `image` | Product screenshot or illustration | Yes |
| `link` | CTA or "Learn more" link | Optional |

**Variants:** `image-right` (default, odd rows) / `image-left` (even rows)

**Alternation rule:** When multiple Feature Rows are stacked, image position alternates automatically — image-right first, image-left second, and so on.

**Responsive:** Image stacks above text on tablet/mobile.

---

### 3.4 — Tabbed Feature Panel

Tab bar with one detail panel visible at a time. Each tab is a feature deep-dive.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `tabs` | Array of tab items | Yes (min 3) |
| ↳ `tab_label` | Short label for the tab | Yes |
| ↳ `heading` | H3 — feature name | Yes |
| ↳ `description` | Detailed description | Yes |
| ↳ `image` | Screenshot or illustration | Optional |

**Responsive:** Horizontal tabs on desktop → accordion on mobile.

→ For tab interaction JS pattern: see `css-js-generator/SKILL.md`

---

### 3.5 — Accordion

Expandable sections. Used for FAQ, feature specs, and progressive disclosure of content.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `items` | Array of accordion items | Yes (min 2) |
| ↳ `trigger` | Clickable heading | Yes |
| ↳ `content` | Expandable body — text, images, or nested content | Yes |

**Variants:** `single-open` (default) / `multi-open` / `first-open` / `all-closed`

**Responsive:** Consistent at all breakpoints.

→ For accordion interaction JS pattern: see `css-js-generator/SKILL.md`

---

## 4 — Social Proof Components

### 4.1 — Testimonial Card

Single customer quote with attribution.

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

Horizontally scrollable or auto-rotating set of Testimonial Cards.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `cards` | Array of Testimonial Cards | Yes (min 3) |

**Variants:** `auto-rotate` / `manual` / `static-grid`

**Responsive:** 2–3 cards visible on desktop → 1 card on mobile with swipe or stacked.

---

### 4.3 — Logo Bar

Horizontal row of partner/customer logos.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `label` | "Trusted by" or similar label | Optional |
| `logos` | Array of logo images | Yes (min 3) |

**Variants:** `static` / `scrolling` (infinite loop) / `grayscale`

**Responsive:** Single row on desktop → wrap to 2 rows or horizontal scroll on mobile.

---

### 4.4 — Metrics Bar

Row of key statistics with large numbers and context labels.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `items` | Array of metric items | Yes (min 2) |
| ↳ `value` | Large number or stat (e.g. "99.9%", "10K+") | Yes |
| ↳ `label` | Context label (e.g. "Uptime", "Customers") | Yes |

**Variants:** `inline` / `with-dividers` / `animated` (count up on scroll)

**Responsive:** Single row on desktop → 2-column grid or vertical stack on mobile.

---

## 5 — CTA Components

### 5.1 — CTA Section

Dedicated conversion section. Used as the closing section and optionally mid-page.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `heading` | H2 — action-oriented headline | Yes |
| `description` | Supporting text, 1–2 sentences | Optional |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary button or link | Optional |

**Variants:** `centered` (default) / `with-background` / `split` (text left, CTA right)

**Responsive:** All variants collapse to centered stack on mobile; CTA full-width.

---

### 5.2 — Sticky CTA Bar

Persistent bottom bar visible throughout scrolling.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `text` | Short reinforcement line | Optional |
| `primary_cta` | Primary button | Yes |

**Behavior:** Hidden on initial load. Appears after scrolling past hero. Fixed to bottom of viewport. Dismissible or persistent per configuration.

**Responsive:** Full width at all breakpoints; CTA centered and full-width on mobile.

→ For sticky bar JS pattern: see `css-js-generator/SKILL.md`

---

## 6 — Content Components

### 6.1 — FAQ Accordion

Specialized accordion for question/answer pairs.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Frequently Asked Questions" or similar | Yes |
| `items` | Array of Q&A pairs | Yes (min 3) |
| ↳ `question` | Question text (accordion trigger) | Yes |
| ↳ `answer` | Answer text | Yes |

Same interaction pattern and responsive behavior as Accordion (Section 3.5).

---

### 6.2 — Pricing Table

Feature comparison across pricing tiers.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Pricing" or similar | Yes |
| `tiers` | Array of pricing tiers | Yes (min 2) |
| ↳ `name` | Tier name | Yes |
| ↳ `price` | Price text (e.g. "$29/mo") | Yes |
| ↳ `description` | Brief tier description | Optional |
| ↳ `features` | List of included features | Yes |
| ↳ `cta` | Tier-specific CTA button | Yes |
| ↳ `highlighted` | Boolean — visually emphasize this tier | Optional |

**Variants:** `cards` / `table` (feature comparison grid)

**Responsive:** Cards stack vertically on mobile; table becomes card-per-tier view.

---

### 6.3 — Integration Grid

Grid of compatible tools/platforms with logos and descriptions.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Integrations" or similar | Yes |
| `section_description` | Supporting text | Optional |
| `items` | Array of integration items | Yes (min 3) |
| ↳ `logo` | Integration logo | Yes |
| ↳ `name` | Tool/platform name | Yes |
| ↳ `description` | Brief description | Optional |

**Responsive:** 4–6 col desktop → 3 col tablet → 2 col mobile.

---

### 6.4 — Pull Quote

Large-format highlighted quote or key statement. Used for mid-page editorial emphasis.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `quote` | The highlighted text | Yes |
| `attribution` | Name + role/company of the speaker | Optional |

**Variants:** `centered` (default) / `left-border` (large left border accent) / `full-bleed` (colored background)

**Responsive:** Text scales down on mobile; full-bleed variant retains background color.

---

### 6.5 — Rich Text Block

Long-form content container for article body, documentation, and case study narrative. Handles structured prose with inline headings, lists, and images.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `body` | Structured body content with H2/H3 headings, paragraphs, lists, inline images | Yes |
| `table_of_contents` | Auto-generated or manual TOC (links to H2/H3 anchors) | Optional |

**Variants:** `article` (standard blog/editorial width) / `docs` (monospace-friendly, wider code blocks)

**Responsive:** Narrow width at all breakpoints. Images go full-width within container on mobile.

---

### 6.6 — Download Card

Represents a gated or direct downloadable asset.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `thumbnail` | Asset preview image or icon | Optional |
| `title` | Asset name | Yes |
| `description` | Brief description of what's inside | Optional |
| `file_type` | Format label (e.g. "PDF", "XLSX", "ZIP") | Optional |
| `cta` | "Download" or "Get Access" button | Yes |

**Variants:** `direct` (no gate, immediate download) / `gated` (CTA opens Form)

**Responsive:** Full-width stack on mobile.

---

→ For people/profile, timeline, navigation/index, form, and media components, and composition rules: see `component-specs.md`

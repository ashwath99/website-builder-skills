---
name: layout-patterns
description: Page layout system for all marketing website page types. Defines section layout types (split, sidebar, grid, bento, timeline, etc.), page type inference from content signals, and assembly logic for arranging sections into full pages. Use when identifying the page type from a brief, selecting layout types for sections, or assembling a complete page structure.
version: "5.4.0"
---

# Layout Patterns — Page Layout System

This file is the authority for how content is spatially arranged — at page level (what sections appear and in what order) and at section level (how content is laid out within each section). It works with all marketing website page types, not just landing pages.

→ For individual component definitions and variants: see `component-library`
→ For design token values (spacing, widths, colors): see `design-tokens`
→ For HTML section markup and BEM class patterns: see `html-generator`
→ For CSS implementation of layout types: see `css-js-generator`
→ For layout modifications from trend profiles: see `trend-adapter`
→ For layout variation across multiple page arrangements: see `variation-explorer`

---

## 1 — Grid System

### 1.1 — Column Grid

All page content sits within a column grid constrained by a max content width.

| Property | Value | Source |
|---|---|---|
| Max content width | `content-max-width` | `design-tokens` |
| Narrow content width | `content-max-width-narrow` | `design-tokens` |
| Sidebar width | `sidebar-width` | `design-tokens` |
| Grid columns (desktop) | 12 | — |
| Grid gutter | `grid-gutter` | `design-tokens` |
| Side margin (desktop) | Auto (centered) | — |
| Side margin (mobile) | `{PLACEHOLDER}` | `design-tokens` |

### 1.2 — Content Width Modes

| Mode | Width | Typical Use |
|---|---|---|
| `full-bleed` | 100% viewport, no side constraints | Hero backgrounds, full-width image bands, banner sections |
| `contained` | `content-max-width`, centered | Feature grids, pricing tables, most body sections |
| `narrow` | `content-max-width-narrow`, centered | Blog articles, long-form copy, FAQs, legal pages |
| `sidebar` | `content-max-width` split into main + sidebar | Docs, blog article with sidebar, resource pages |

**Rule:** A section's background width and its content width are independent. A full-bleed background section can have contained or narrow internal content.

### 1.3 — Responsive Grid Behavior

| Breakpoint | Columns | Behavior |
|---|---|---|
| Desktop (>1024px) | 12 | Full layout as specified |
| Tablet (481–1024px) | 8 | Sidebar collapses below content; multi-column grids reduce to 2-col |
| Mobile (≤480px) | 4 | All layouts stack to single column; sidebars become accordions or tabs |

→ For exact responsive CSS rules: see `css-js-generator`

---

## 2 — Section Rhythm

### 2.1 — Vertical Spacing

| Between | Spacing Token | Notes |
|---|---|---|
| Sections | `section-padding-y` | Applied as top and bottom padding on each section |
| Hero / emphasis sections | `section-padding-y-lg` | Extra vertical space |
| Content groups within a section | `space-xl` | Between heading block and content block |
| Components within a group | `space-lg` | Between cards, between rows |

### 2.2 — Surface Assignment by Section Purpose

Section backgrounds use **semantic surfaces** from `design-tokens` §2.5. The builder picks a surface based on what the section *means*, not where it falls on the page.

**Available surfaces:** Brand, Brand Strong, Subtle, Brand Subtle, Inverse, Default

**Assignment by section type:**

| Section Type | Recommended Surface | Rationale |
|---|---|---|
| Hero (bold/branded) | `surface-brand`, `surface-inverse` | High-impact opening statement |
| Hero (image-led) | `surface-default` + background image | Image carries the weight |
| Trust signals / logos | `surface-subtle`, `surface-brand-subtle` | Light tint groups logos visually |
| Feature overview / grid | `surface-default`, `surface-subtle` | Content is the focus |
| Value props / how it works | `surface-subtle`, `surface-brand-subtle` | Gentle visual break |
| Statistics / metrics | `surface-brand`, `surface-brand-strong` | Bold surface draws attention |
| Social proof / testimonials | `surface-subtle`, `surface-default` | Subtle differentiation |
| Pricing | `surface-default`, `surface-subtle` | Clean; use `surface-brand` for highlighted tier card only |
| FAQ | `surface-subtle`, `surface-default` | Low-emphasis section |
| Closing CTA | `surface-brand`, `surface-brand-strong`, `surface-inverse` | High-impact — match or complement hero |
| Footer | `surface-inverse` | Dark footer is standard |

**Alternation rules:**
- Never place two of the same surface adjacent
- **Default** and **Subtle/Brand Subtle** alternate for the main page body
- **Brand** and **Inverse** are reserved for high-impact sections (hero, CTA, pricing highlight) — max 2–3 per page
- **Brand Strong** is used sparingly — max 1–2 per page
- Use **Subtle** vs **Brand Subtle** to avoid repeating the same tint when adjacent light sections are needed

**Pattern example:**
```
Hero              → surface-brand (bold opening)
Trust Signals     → surface-subtle (light break)
Feature Overview  → surface-default (clean content)
Value Pillars     → surface-brand-subtle (alternate light tint)
Feature Grid      → surface-default
Integrations      → surface-subtle
Why Choose Us     → surface-default
Pricing           → surface-brand-subtle
Testimonials      → surface-default
Closing CTA       → surface-inverse (dark closing impact)
```

**Text color on surfaces:** Brand/Brand Strong/Inverse → `color-text-inverse` (white). Default/Subtle/Brand Subtle → `color-text-primary`.

→ For surface token values: see `design-tokens` §2.5
→ For surface CSS implementation: see `css-js-generator`
→ For HTML surface class naming: see `html-generator`

### 2.3 — Visual Weight Pacing

Visual weight should pulse across the page — heavy and light sections should alternate to maintain reading tempo.

```
Heavy (hero) → Medium (features) → Light (proof/logos) → Medium (deep-dive) → Light (FAQ) → Heavy (closing CTA)
```

Aim for alternation between visually dense sections (feature grids, pricing tables, bento grids, tabbed panels) and visually lighter sections (testimonials, logo bars, text CTAs, FAQs).

---

## 3 — Section Layout Types

A section layout type defines the spatial relationship between content elements within a section. It is independent of the component — the same layout type can be applied to a hero, a feature section, a case study, or a blog section.

The agent selects a layout type for each section based on the content signals in that section (content volume, asset availability, content type).

### 3.1 — Horizontal Layouts

Used when content has two meaningful halves — text and visual, or two content blocks.

| Layout Type | Structure | Best For |
|---|---|---|
| `split-50` | Two equal columns, text left / visual right (or reversed) | Hero with product image, feature highlight with screenshot |
| `split-60-40` | 60% content / 40% visual | Feature sections where text is primary |
| `split-40-60` | 40% content / 60% visual | Visual-led sections, media-forward features |
| `split-reverse` | Visual left / text right | Alternating content rows to break monotony |
| `asymmetric` | ~70% main content / ~30% secondary content | Announcement bars, call-out sections with secondary info |
| `full-bleed-text` | Full-width section, text centered or left-aligned, no visual split | Brand statement sections, simple CTAs, closing sections |

**Responsive rule:** All horizontal splits collapse to stacked single column on mobile. Visual goes below text by default unless `visual-first` is specified.

### 3.2 — Grid Layouts

Used when the section contains multiple parallel items — features, cards, team members, blog posts, integrations.

| Layout Type | Structure | Best For |
|---|---|---|
| `grid-2col` | 2-column symmetric grid | Comparison items, large feature cards, team pairs |
| `grid-3col` | 3-column symmetric grid | Feature icons, benefit cards, pricing plans, team members |
| `grid-4col` | 4-column symmetric grid | Small feature badges, logo bars, stat items |
| `grid-auto` | Auto-fill grid (min-width per card) | Integration catalogs, tag-heavy content, flexible item count |
| `masonry` | Variable-height card grid, Pinterest-style | Blog index, portfolio, mixed-length testimonials |
| `card-index` | Grid of uniform cards with image, title, meta, CTA | Blog index, resource library, case study listings |
| `bento` | Asymmetric mixed-size card grid | Editorial layouts, product feature showcases, visual-heavy content |

**Responsive rules:** 4-col → 2-col on tablet → 1-col on mobile. 3-col → 2-col on tablet → 1-col on mobile. Masonry → 2-col on tablet → 1-col on mobile.

### 3.3 — Sidebar Layouts

Used for content-heavy pages where navigation or metadata lives alongside the main reading flow.

| Layout Type | Structure | Best For |
|---|---|---|
| `sidebar-left` | Fixed-width left sidebar + main content | Documentation navigation, filter panels, glossary |
| `sidebar-right` | Main content + fixed-width right sidebar | Blog articles (table of contents, related posts), resource pages |
| `sticky-sidebar` | Sidebar scrolls with page until fixed position | Long-form articles, documentation with in-page nav |

**Responsive rule:** Sidebar collapses to a top-anchored dropdown or accordion on tablet and below. Main content takes full width.

### 3.4 — Linear Layouts

Used when content has a defined sequence or progression.

| Layout Type | Structure | Best For |
|---|---|---|
| `timeline` | Vertical or horizontal sequence of dated events | Company history, product roadmap, case study journey |
| `step-flow` | Numbered steps, horizontal on desktop | How It Works, onboarding flows, setup guides (3–5 steps) |
| `step-flow-vertical` | Numbered steps, vertical stack with connectors | Long processes (6+ steps), detailed workflows |
| `accordion-stack` | Collapsed sections, one expands at a time | FAQ, detailed feature specs, glossary terms |
| `tab-panel` | Horizontal tabs switching content panels | Feature categories, use case scenarios, plan comparisons |

**Responsive rules:** Horizontal step-flow collapses to vertical stack on mobile. Tab panels collapse to accordion on mobile.

### 3.5 — Specialty Layouts

Used for specific content types that don't fit standard grid or split patterns.

| Layout Type | Structure | Best For |
|---|---|---|
| `comparison-table` | Rows of features, columns of plans/products | Pricing pages, competitive comparison, plan picker |
| `media-gallery` | Full-width or grid image/video display | Product screenshots, portfolio works, event photos |
| `form-focused` | Centered form with minimal surrounding content | Contact pages, demo request, newsletter signup, event registration |
| `map-content` | Embedded map alongside contact or location info | Contact pages with office locations |
| `stat-band` | Full-width horizontal band of metrics/stats | Social proof bar, results section |
| `logo-bar` | Single row of partner/customer logos | Trust signals, integration partners |
| `quote-callout` | Large centered pull quote or testimonial | Mid-page social proof, editorial emphasis |

---

## 4 — Page Type Inference

The agent infers the page type from content signals in the parsed brief. Page type determines which sections are applicable and which layout types are preferred — but does not lock the agent into a fixed sequence.

### 4.1 — Content Signals → Page Type

Read the parsed brief and identify which signals are present. Match to the most probable page type.

| Page Type | Strong Signals | Supporting Signals |
|---|---|---|
| **Product Landing** | Primary headline + feature list + CTA + product description | Hero image, testimonials, pricing mention, integrations |
| **Feature Detail** | Single feature deep-dive, screenshots per sub-feature, use case scenarios | Comparison to alternatives, technical specs, demo CTA |
| **Pricing** | Pricing tiers with names + prices, plan comparison table, FAQ about billing | Feature checklist per plan, enterprise contact CTA |
| **Home Page** | Multiple product/service references, brand-level headline, varied audience signals | Navigation-first structure, news/announcements, broad CTA |
| **About / Company** | Team members, company mission/values, founding story, culture content | Office locations, press mentions, investor info |
| **Case Study** | Customer name + industry, problem statement, solution description, results/metrics | Quotes from customer, before/after data, implementation timeline |
| **Blog Article** | Author name + date, body copy in paragraph form, structured headings, reading time | Tags/categories, related articles, comments |
| **Blog Index** | List of article titles + excerpts + dates + authors | Category filters, featured post, pagination |
| **Event / Webinar** | Event name + date + time, speaker names + bios, agenda/schedule | Registration CTA, countdown, replay link |
| **Contact** | Contact form fields, email/phone, office address | Map, support channels, response time |
| **Partner / Integrations** | Integration or partner names + logos + descriptions, filterable catalog | Categories, connection instructions, marketplace-style layout |
| **Resource / Download** | Downloadable asset titles, file types, form gate for access | Topic categories, related resources, asset previews |
| **Documentation Hub** | Structured navigation hierarchy, technical instructions, code examples | Search bar, version selector, breadcrumbs |
| **Error (404 / 500)** | Error code or message, no structured content sections | Search or navigation fallback, friendly redirect CTA |

### 4.2 — Ambiguous Brief Handling

When signals point to more than one page type:
- If a brief has both a product feature list and pricing tiers → infer **Product Landing** (pricing is a section, not the page type)
- If a brief has team content alongside product features → infer **Product Landing** with an About section, not an About page
- If the brief explicitly states a page name or URL slug, use that to resolve ambiguity
- If the page type cannot be confidently inferred, flag it as ambiguous in the parsed brief output and default to **Product Landing**

### 4.3 — Multi-Page Briefs

If the brief contains content for multiple distinct page types (e.g. a full site brief), parse each page separately. Confirm with the user which page to build first before proceeding.

---

## 5 — Page Assembly Logic

Once the page type is inferred, the agent assembles the page by selecting applicable sections and assigning a layout type to each. This is not a fixed template — it is a set of applicable sections and constraints for each page type.

### 5.1 — Product Landing Page

**Goal:** Convert visitors who are evaluating the product.

**Applicable sections (in rough priority order):**

| Section | Layout Types | Required |
|---|---|---|
| Hero | `split-50`, `split-60-40`, `full-bleed-text` | Yes |
| Trust Signals | `logo-bar`, `stat-band` | Recommended |
| Feature Overview | `grid-3col`, `grid-2col`, `split-50` (alternating rows) | Yes |
| Feature Deep-Dive | `tab-panel`, `accordion-stack`, `split-60-40` | Optional |
| Social Proof | `grid-2col`, `grid-3col`, `quote-callout` | Recommended |
| Use Cases | `grid-2col`, `tab-panel`, `split-50` | Optional |
| Integration / Ecosystem | `grid-4col`, `grid-auto`, `logo-bar` | Optional |
| Pricing Snapshot | `grid-3col` | Optional |
| FAQ | `accordion-stack` | Optional |
| Closing CTA | `full-bleed-text`, `split-50` | Yes |

**Sequencing constraints:**
- Hero is always first
- Trust Signals appear in the first three sections if present
- FAQ appears after all feature sections
- Closing CTA is always last

**Over-budget merge priority** (when brief produces more sections than the max):

Drop or merge in this order — highest number = first to cut:

| Priority | Action | Sections |
|---|---|---|
| 5 (cut first) | Merge into adjacent section | Device/OS support + Integration/Ecosystem → combined "Platform" section |
| 4 | Merge into adjacent section | Stats/Metrics + Testimonials → combined "Social Proof" section |
| 3 | Drop entirely | Feature Deep-Dive (if Feature Overview covers enough) |
| 2 | Drop entirely | Use Cases (if features imply use cases) |
| 1 (cut last) | Simplify, never drop | Trust Signals → reduce to inline logo row within Hero or Feature Overview |

**Rules:** Never drop Hero, Feature Overview, or Closing CTA. Never merge FAQ into another section (accordion needs its own container). Pricing Snapshot is kept if the brief includes pricing data.

---

### 5.2 — Feature Detail Page

**Goal:** Give a technical or evaluative audience a complete picture of one feature.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Hero (feature headline + CTA) | `split-60-40`, `full-bleed-text` | Yes |
| Feature Overview (what it does) | `split-50`, `full-bleed-text` | Yes |
| How It Works | `step-flow`, `step-flow-vertical` | Recommended |
| Sub-features / Capabilities | `tab-panel`, `grid-3col`, `accordion-stack` | Yes |
| Screenshots / Demo | `media-gallery`, `split-60-40` | Recommended |
| Use Case Scenarios | `grid-2col`, `tab-panel` | Optional |
| Comparison (vs alternatives) | `comparison-table` | Optional |
| Social Proof | `quote-callout`, `grid-2col` | Optional |
| Related Features | `grid-3col`, `grid-auto` | Optional |
| Closing CTA | `full-bleed-text` | Yes |

---

### 5.3 — Pricing Page

**Goal:** Help visitors understand plans and choose one.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Page Headline + context | `full-bleed-text`, `narrow` | Yes |
| Plan Comparison | `comparison-table`, `grid-3col` | Yes |
| Feature Highlights per Plan | `grid-3col`, `accordion-stack` | Optional |
| Social Proof / Trust | `logo-bar`, `quote-callout`, `stat-band` | Recommended |
| FAQ (billing-focused) | `accordion-stack` | Recommended |
| Enterprise Contact CTA | `split-50`, `full-bleed-text` | Optional |
| Closing CTA | `full-bleed-text` | Yes |

**Note:** Never put a trust signals / logo bar above the pricing table — it distracts from the primary conversion action.

---

### 5.4 — Home Page

**Goal:** Orient visitors to the brand and route them to the right product or page.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Hero (brand-level statement) | `full-bleed-text`, `split-50` | Yes |
| Product / Service Overview | `grid-2col`, `grid-3col`, `bento` | Yes |
| Brand Trust Signals | `logo-bar`, `stat-band` | Recommended |
| Featured Use Cases or Audiences | `grid-3col`, `tab-panel` | Optional |
| News / Announcements | `card-index`, `grid-2col` | Optional |
| Social Proof | `quote-callout`, `grid-2col` | Optional |
| Closing CTA / Newsletter | `full-bleed-text`, `form-focused` | Yes |

---

### 5.5 — About / Company Page

**Goal:** Build credibility and human connection with the brand.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Mission / Vision Statement | `full-bleed-text`, `split-50` | Yes |
| Company Story / History | `timeline`, `split-50` (alternating) | Recommended |
| Team Members | `grid-3col`, `grid-4col`, `masonry` | Optional |
| Values / Culture | `grid-3col`, `grid-2col`, `bento` | Optional |
| Office Locations | `map-content`, `grid-2col` | Optional |
| Press / Awards | `logo-bar`, `grid-4col` | Optional |
| Investor / Partners | `logo-bar` | Optional |
| Open Roles CTA | `full-bleed-text`, `split-50` | Optional |
| Closing CTA | `full-bleed-text` | Yes |

---

### 5.6 — Case Study Page

**Goal:** Demonstrate real-world results for a specific customer.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Customer + Headline (results-led) | `split-60-40`, `full-bleed-text` | Yes |
| Challenge / Problem | `split-50`, `full-bleed-text` | Yes |
| Solution Description | `split-50`, `step-flow`, `tab-panel` | Yes |
| Results / Metrics | `stat-band`, `grid-3col` | Yes |
| Customer Quote | `quote-callout` | Recommended |
| Implementation Timeline | `timeline`, `step-flow` | Optional |
| Related Case Studies | `card-index`, `grid-3col` | Optional |
| Closing CTA | `full-bleed-text`, `split-50` | Yes |

**Sequencing rule:** Challenge always precedes Solution, which always precedes Results.

---

### 5.7 — Blog Article Page

**Goal:** Deliver a readable, focused piece of long-form content.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Article Header (title, author, date) | `narrow`, `full-bleed-text` | Yes |
| Article Body | `narrow` with `sidebar-right` (table of contents) | Yes |
| Pull Quotes / Callouts | `quote-callout` | Optional |
| Inline Images / Media | `media-gallery`, `full-bleed-text` | Optional |
| Related Articles | `card-index`, `grid-3col` | Recommended |
| Author Bio | `split-40-60` | Optional |
| Newsletter / CTA | `form-focused`, `full-bleed-text` | Optional |

**Layout note:** The primary layout for blog body content is always `narrow`. The sidebar (sticky table of contents) is optional but recommended for articles over 1000 words.

---

### 5.8 — Blog Index Page

**Goal:** Let visitors browse and discover articles.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Page Header + Filters | `full-bleed-text` with filter bar | Yes |
| Featured Article | `split-60-40`, `full-bleed-text` | Optional |
| Article Listing | `card-index`, `masonry`, `grid-3col` | Yes |
| Category Navigation | `grid-auto`, sidebar | Optional |
| Newsletter Signup | `form-focused`, `full-bleed-text` | Optional |
| Pagination / Load More | Inline at bottom of listing | Yes |

---

### 5.9 — Event / Webinar Page

**Goal:** Drive registrations for a specific event.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Event Hero (name, date, format, CTA) | `split-50`, `full-bleed-text` | Yes |
| Countdown Timer | `stat-band`, `full-bleed-text` | Optional |
| About the Event | `split-50`, `full-bleed-text` | Yes |
| Speakers | `grid-3col`, `grid-2col` | Recommended |
| Agenda / Schedule | `accordion-stack`, `timeline` | Optional |
| Registration Form | `form-focused`, `split-60-40` | Yes |
| Sponsors / Partners | `logo-bar` | Optional |
| Past Event Highlights | `media-gallery`, `grid-3col` | Optional |

**Sequencing rule:** Registration form appears prominently early (within first 3 sections) and again as closing section.

---

### 5.10 — Contact Page

**Goal:** Give visitors a clear path to reach the team.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Page Headline + intro | `full-bleed-text`, `narrow` | Yes |
| Contact Form | `form-focused`, `split-50` | Yes |
| Alternative Contact Options | `grid-3col`, `split-50` | Optional |
| Office Location(s) | `map-content`, `grid-2col` | Optional |
| Support / Help Links | `grid-3col`, `grid-auto` | Optional |

---

### 5.11 — Partner / Integrations Page

**Goal:** Showcase the ecosystem of integrations or partners.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Page Headline + context | `full-bleed-text` | Yes |
| Filter / Category Bar | `grid-auto`, inline filter row | Recommended |
| Integration / Partner Catalog | `grid-auto`, `grid-4col`, `card-index` | Yes |
| Featured Integrations | `grid-3col`, `bento` | Optional |
| Become a Partner CTA | `full-bleed-text`, `split-50` | Optional |

---

### 5.12 — Resource / Download Page

**Goal:** Offer gated or ungated assets for download.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Page Headline + category nav | `full-bleed-text` | Yes |
| Resource Listing | `card-index`, `grid-3col` | Yes |
| Featured Resource | `split-60-40`, `full-bleed-text` | Optional |
| Download / Access Form | `form-focused`, `split-50` | Conditional (gated assets) |
| Related Resources | `grid-3col`, `card-index` | Optional |

---

### 5.13 — Documentation Hub

**Goal:** Help users find and navigate technical documentation.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Search Bar + Overview | `full-bleed-text`, `narrow` | Yes |
| Topic / Category Grid | `grid-3col`, `grid-2col` | Yes |
| Quick Start / Getting Started | `step-flow`, `split-50` | Recommended |
| Full Documentation Body | `sidebar-left` (nav) + `narrow` (content) | For article pages |
| API Reference | `sidebar-left` + `narrow` with code blocks | Optional |
| Support / Community CTA | `full-bleed-text`, `grid-3col` | Optional |

---

### 5.14 — Error Page (404 / 500)

**Goal:** Recover the visitor gracefully.

**Applicable sections:**

| Section | Layout Types | Required |
|---|---|---|
| Error Message + friendly copy | `full-bleed-text`, `narrow` | Yes |
| Navigation / Search fallback | `grid-3col`, `form-focused` | Yes |
| Popular Pages | `grid-3col`, `card-index` | Optional |

---

## 6 — Universal Sequencing Rules

Regardless of page type and layout selection, these rules always apply.

### Hard Rules (Must Follow)
- Hero / page header is always the first section
- Closing CTA or primary conversion section is always the last section
- Trust signals (logo bar, stat band) appear in the first three sections if present
- FAQ appears after all feature or information sections, never before
- Pricing content appears after at least one section establishing value

### Soft Rules (Follow Unless Variation or Trend Overrides)
- Social proof works best immediately after a feature or capability section
- Forms should appear early on conversion-focused pages (event, contact, resource)
- Navigation-heavy sections (sidebars, filter bars) appear at the top of their page, not mid-page
- Media galleries work best mid-page as a visual break, not as an opening section
- Comparison tables should be preceded by at least one section establishing the value of what is being compared

### Variation Override
If `variation-explorer` has produced a Variation Spec and a variant is selected, the variant's Narrative Flow axis may override section sequencing. The variant specifies the section sequence directly.

→ For variation flow options: see `variation-explorer`

### Trend Override
If `trend-adapter` has produced a Trend Adaptation Brief, its layout modifications may adjust visual weight distribution and density — but not the inferred page type or section applicability.

→ For trend layout modifications: see `trend-adapter`

---

## 7 — Bento Grid Layout

Bento is a specialty section layout type (`bento` from Section 3.2) that replaces the traditional stacked equal-row approach with an asymmetric mixed-size card grid. It can be applied to any section containing multiple parallel content items.

### Structure

```
┌──────────┬─────┐
│  2×1     │ 1×1 │
│  Feature │ Stat│
├────┬─────┼─────┤
│1×1 │ 1×1 │ 2×1 │
│Icon│Quote│ CTA │
├────┴─────┴─────┤
│    3×1 Image   │
└────────────────┘
```

**Cell sizes:** 1×1 (square), 2×1 (wide), 1×2 (tall), 3×1 (full-row)

**Rules:**
- Each cell contains one component unit (feature card, testimonial, metric, image, CTA)
- No cell contains a full section — bento breaks sections into individual component units
- Visual variety is mandatory: no two adjacent cells should be the same size
- Responsive: collapse to 2-column at tablet, single-column stack at mobile

### When to Use
- `trend-adapter` specifies `weight_distribution: bento`
- `variation-explorer` specifies `bento-grid` as the feature presentation axis value
- Brief content has high visual variety and an editorial or modern feel is appropriate

→ For bento grid CSS implementation: see `css-js-generator`

---

## 8 — Step Flow Layout

A common layout for explaining a process in sequential steps. Applies to How It Works sections, onboarding guides, and setup instructions.

### Structure

```
Step 1          Step 2          Step 3
[Icon/Number]   [Icon/Number]   [Icon/Number]
Heading (H4)    Heading (H4)    Heading (H4)
Description     Description     Description
    ────────────────────────────────────
```

**3 steps:** Use `step-flow` (horizontal). **4–5 steps:** Use two rows of `step-flow`. **6+ steps:** Switch to `step-flow-vertical` or `accordion-stack`.

**Visual connector:** Horizontal line, arrow, or dotted path between steps on desktop. Hidden on mobile (steps stack vertically as numbered list).

**Responsive:** Desktop → 3-column horizontal. Tablet → 3-column simplified connectors. Mobile → vertical numbered stack, no connectors.

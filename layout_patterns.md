<!-- meta
name: layout_patterns
title: Layout Patterns
version: 3.0
status: active
purpose: Define page-level layout patterns — section sequencing, grid systems, content width rules, and pattern selection logic based on brief content and audience.
owns:
  - Page layout pattern definitions
  - Section sequencing rules and valid orderings
  - Grid system (column counts, breakpoints behavior)
  - Content width rules (full-width vs contained vs narrow)
  - Section rhythm and visual pacing
  - Pattern selection logic (which pattern for which brief)
  - Tinted section alternation rules
requires:
  - workflow
  - design_guide
  - components
depends_on:
  - content_brief
referenced_by:
  - variation_generator
  - trend_adaptation
  - html_structure
  - figma_capture
  - agent_execution_prompt
modes:
  mode_a: required
  mode_b: optional
  mode_c: required
layer: design_decision
last_updated: 2026-03-16
-->

# Layout Patterns — Page Structure

This file defines how components are arranged into full page layouts. It governs section order, grid systems, content width, and the visual rhythm of a landing page.

→ For individual component specs: see `components.md`
→ For token values (spacing, widths): see `design_guide.md`
→ For HTML section markup: see `html_structure.md`
→ For variation axis options that modify layout: see `variation_generator.md`

---

## 1 — Grid System

### 1.1 — Column Grid

All page content sits within a column grid constrained by a max content width.

| Property | Value | Source |
|---|---|---|
| Max content width | `content-max-width` | `design_guide.md` |
| Narrow content width | `content-max-width-narrow` | `design_guide.md` |
| Grid columns (desktop) | 12 | — |
| Grid gutter | `grid-gutter` | `design_guide.md` |
| Side margin (desktop) | Auto (centered) | — |
| Side margin (mobile) | `{PLACEHOLDER}` | `design_guide.md` |

### 1.2 — Content Width Modes

Different sections use different content widths depending on their purpose.

| Mode | Width | Used By |
|---|---|---|
| `full-width` | 100% viewport, no side constraints | Hero backgrounds, full-bleed sections, Logo Bar |
| `contained` | `content-max-width`, centered | Feature Grid, Pricing Table, Integration Grid, most body sections |
| `narrow` | `content-max-width-narrow`, centered | Text-heavy sections, FAQ, single-column content |

**Rule:** A section's background can be `full-width` while its content is `contained` or `narrow`. These are independent. For example, a tinted section has a full-width background color but contained-width internal content.

### 1.3 — Responsive Grid Behavior

| Breakpoint | Columns | Gutter | Content Width |
|---|---|---|---|
| Desktop (>1024px) | 12 | `grid-gutter` | `content-max-width` |
| Tablet (481–1024px) | 8 | `grid-gutter` reduced | `content-max-width` with side padding |
| Mobile (≤480px) | 4 | `grid-gutter` reduced | Full width with side padding |

→ For exact responsive token adjustments: see `css_js_rules.md`

---

## 2 — Section Rhythm

Section rhythm defines the vertical pacing of a page — how sections flow, how they're visually separated, and how they create a reading tempo.

### 2.1 — Vertical Spacing

| Between | Spacing Token | Notes |
|---|---|---|
| Sections | `section-padding-y` | Applied as top and bottom padding on each section |
| Hero section | `section-padding-y-lg` | Hero gets extra vertical space |
| Content groups within a section | `space-xl` | Between heading block and content block within same section |
| Components within a group | `space-lg` | Between cards in a grid, between rows |

### 2.2 — Tinted Section Alternation

Tinted backgrounds create visual separation between sections without relying on borders or dividers.

**Rules:**
- Tinted and untinted (white/default) sections alternate down the page
- Never place two tinted sections adjacent to each other
- Never place three or more untinted sections in a row (the page loses rhythm)
- The hero section is always untinted (or uses its own background treatment independent of the tint system)
- The closing CTA section may use a tinted background or a distinct brand-colored background

**Pattern example:**
```
Hero          → untinted (own background)
Section 2     → tinted (tint-1)
Section 3     → untinted
Section 4     → tinted (tint-2)
Section 5     → untinted
Closing CTA   → tinted (tint-1 or brand background)
```

**Tint assignment:** Tints from `design_guide.md` are assigned in order. If the page has more tinted sections than available tint pairs, cycle back to tint-1.

→ For tint color values: see `design_guide.md` Section 2.4
→ For HTML tint class naming: see `html_structure.md`

### 2.3 — Visual Weight Pacing

The page should not front-load all visually heavy sections or back-load them all. Visual weight should pulse:

```
Heavy (hero) → Medium (features) → Light (proof/logos) → Medium (deep-dive) → Light (FAQ) → Heavy (closing CTA)
```

This is a guideline, not a strict rule. The agent should aim for alternation between visually dense sections (feature grids, tabbed panels, pricing) and visually lighter sections (testimonials, logo bars, CTAs).

---

## 3 — Page Layout Patterns

A layout pattern is a complete section sequence for a landing page. The agent selects a pattern based on the parsed brief's content, audience, and section count.

### 3.1 — Pattern: Standard Product Page

**Best for:** Most ManageEngine product landing pages. Balanced approach for mixed audiences.

**Section sequence:**
```
1. Hero (split-image or product-centered)
2. Trust Signals (logo bar — hero-adjacent)
3. Feature Overview (grid or alternating rows)
4. Feature Deep-Dive (tabbed panel or accordion) [optional]
5. Social Proof (testimonials)
6. Use Cases / Scenarios [optional]
7. Integration / Ecosystem [optional]
8. Closing CTA
```

**Content requirements:** Hero content, 4+ features, at least one form of social proof.

**Audience fit:** IT administrators, business decision-makers, mixed personas.

---

### 3.2 — Pattern: Feature-Heavy Page

**Best for:** Products with extensive feature sets that need detailed presentation.

**Section sequence:**
```
1. Hero (split-image or text-bold)
2. Feature Overview (grid — highlight top 4–6 features)
3. Feature Deep-Dive Section 1 (tabbed panel — category A)
4. Social Proof (mid-page testimonial break)
5. Feature Deep-Dive Section 2 (tabbed panel — category B) [optional]
6. Integration / Ecosystem
7. FAQ
8. Closing CTA
```

**Content requirements:** 7+ features (ideally categorizable), screenshots for deep-dives.

**Audience fit:** Technical evaluators who need comprehensive feature information.

---

### 3.3 — Pattern: Trust-First Page

**Best for:** Competitive markets where credibility must be established before features.

**Section sequence:**
```
1. Hero (text-bold or full-bleed — strong claim)
2. Trust Signals (logo bar — immediately below hero)
3. Metrics Bar (key stats — uptime, users, etc.)
4. Social Proof (testimonials — prominent placement)
5. Feature Overview (grid or rows)
6. Use Cases / Scenarios
7. Closing CTA
```

**Content requirements:** Strong social proof (logos, testimonials, metrics). Features can be lighter.

**Audience fit:** Business decision-makers, skeptical audiences, crowded markets.

---

### 3.4 — Pattern: Conversion-Focused Page

**Best for:** Pages with a single strong CTA goal (free trial, demo request). Minimal distractions.

**Section sequence:**
```
1. Hero (text-bold or mini — strong headline + immediate CTA)
2. Value Proposition (3 key benefits, concise)
3. Feature Overview (compact grid — top 3–4 features only)
4. Social Proof (1–2 testimonials or metrics bar)
5. Closing CTA
```

**Content requirements:** Clear single CTA, concise feature set, strong headline.

**Audience fit:** SMB owners, users who already understand the category and want to act fast.

---

### 3.5 — Pattern: Outcome-First Page

**Best for:** ROI-driven audiences who care about results before features.

**Section sequence:**
```
1. Hero (text-bold or full-bleed — outcome statement)
2. Metrics Bar (key results — cost savings, efficiency gains)
3. How It Works (3-step process or visual workflow)
4. Feature Overview (features framed as enablers of outcomes)
5. Social Proof (case study-style testimonials with results)
6. Pricing / Plans [optional]
7. Closing CTA
```

**Content requirements:** Quantifiable outcomes or metrics, process description.

**Audience fit:** Executives, ROI-driven decision-makers.

---

### 3.6 — Pattern: Minimal / Launch Page

**Best for:** New product launches, beta signups, single-purpose pages.

**Section sequence:**
```
1. Hero (full-bleed or product-centered — high visual impact)
2. Feature Overview (3 key highlights only)
3. Closing CTA (strong, singular action)
```

**Content requirements:** Minimal — a headline, 3 features, one CTA.

**Audience fit:** Any — simplicity is the strategy.

---

## 4 — Pattern Selection Logic

When the agent has a parsed brief, it selects a pattern using these rules in order:

### Step 1: Filter by Content Availability

| If the brief has... | Exclude patterns... |
|---|---|
| Fewer than 4 features | Feature-Heavy |
| No social proof (no testimonials, no logos) | Trust-First |
| No quantifiable outcomes or metrics | Outcome-First |
| Extensive feature set (7+) | Minimal / Launch, Conversion-Focused |

### Step 2: Match Audience to Pattern

| Audience Type | Preferred Pattern | Fallback Pattern |
|---|---|---|
| IT administrators / technical evaluators | Feature-Heavy | Standard Product |
| Business decision-makers / executives | Outcome-First | Trust-First |
| Developers / DevOps engineers | Feature-Heavy | Standard Product |
| SMB owners / non-technical users | Conversion-Focused | Standard Product |
| Mixed / multi-persona | Standard Product | — |

### Step 3: Apply Variation (if active)

If `variation_generator.md` has produced a Variation Spec and a variant is selected, the variant's **Narrative Flow** axis overrides the pattern selection. The variant specifies the section sequence directly.

→ For variation flow options: see `variation_generator.md` Section 2.2

### Step 4: Apply Trend Modifications (if active)

If `trend_adaptation.md` has produced a Trend Adaptation Brief, its layout modifications may adjust:
- Visual weight distribution (hero-dominant vs distributed vs bento)
- Section divider style
- Density profile (affects section padding and content gap)

These modify the selected pattern's spacing and visual treatment, not its section sequence.

→ For trend layout modifications: see `trend_adaptation.md` Section 3.4, 3.6

---

## 5 — Section Sequencing Rules

Regardless of which pattern is selected, these sequencing rules always apply:

### Hard Rules (Must Follow)
- Hero is always the first section
- Closing CTA is always the last section
- Trust Signals (logo bar) must appear in the first three sections if present
- FAQ must appear after all feature sections, never before
- Pricing must appear after at least one feature section

### Soft Rules (Follow Unless Variation Overrides)
- Social Proof works best immediately after a feature section (reinforces claims)
- Integration / Ecosystem works best near the bottom (supporting detail, not primary content)
- Metrics Bar works well adjacent to hero (hero-adjacent proof) or adjacent to Social Proof
- Use Cases / Scenarios work best between Feature Overview and Feature Deep-Dive (bridges general to specific)

---

## 6 — Bento Grid Layout

Bento grid is a non-linear layout that replaces the traditional stacked-section approach. It's selected when the **Visual Weight Distribution** trend dimension is set to `bento` (see `trend_adaptation.md`).

### Structure

Instead of full-width stacked sections, content is arranged in an asymmetric card grid:

```
┌──────────┬─────┐
│  2×1     │ 1×1 │
│  Feature │ Stat│
├────┬─────┼─────┤
│1×1 │ 1×1 │ 2×1 │
│Icon│Quote │ CTA │
├────┴─────┴─────┤
│    3×1 Image   │
└────────────────┘
```

**Cell sizes:** 1×1 (square), 2×1 (wide), 1×2 (tall), 3×1 (full-row)

**Rules:**
- Each cell contains one component (Feature Card, Testimonial Card, Metric Item, image, CTA)
- No cell may contain a full section — bento breaks sections into individual component units
- Grid must be responsive: at tablet, collapse to 2-column; at mobile, collapse to single-column stack
- Visual variety is mandatory: no two adjacent cells should be the same size

### When to Use
- `trend_adaptation.md` specifies `weight_distribution: bento`
- Or `variation_generator.md` specifies bento-grid as the feature presentation axis value

→ For bento grid CSS implementation: see `css_js_rules.md`

---

## 7 — How It Works Section

A common mid-page section that explains the product's process in steps. Not a standalone component in `components.md` but a layout pattern for combining simple elements.

### Structure

```
Section Heading: "How It Works" (H2)

Step 1          Step 2          Step 3
[Icon/Number]   [Icon/Number]   [Icon/Number]
Heading (H4)    Heading (H4)    Heading (H4)
Description     Description     Description
```

**Typically 3 steps.** If the brief has 4–5 steps, use 2 rows. If more than 5, consider an accordion or timeline instead.

**Visual connector:** A horizontal line, arrow, or dotted path connecting steps on desktop. Hidden on mobile (steps stack vertically).

**Responsive:**
- Desktop: 3 columns with connectors
- Tablet: 3 columns, connectors simplified
- Mobile: Vertical stack, numbered steps, no connectors

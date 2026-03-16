<!-- meta
name: variation_generator
title: Variation Generator
version: 3.0
status: active
purpose: Given a single content brief, produce multiple distinct landing page arrangements using only components and layouts already defined in the skill file system.
owns:
  - Variation axis definitions (6 axes)
  - Axis option values
  - Variation constraint filters
  - Variant spec output format
  - Variant naming and intent heuristics
  - Minimum-difference rule (≥2 axes must differ between variants)
requires:
  - workflow
  - content_brief
  - components
  - layout_patterns
depends_on:
  - design_guide
  - trend_adaptation
referenced_by:
  - agent_execution_prompt
  - workflow
modes:
  mode_a: optional
  mode_b: not_used
  mode_c: optional
layer: exploration
last_updated: 2026-03-16
-->

# Variation Generator — Multi-Variant Exploration

This file defines how the agent generates multiple meaningfully different page arrangements from a single content brief, using only existing components and layout patterns.

→ For component types referenced in axis options: see `components.md`
→ For layout patterns referenced in flow options: see `layout_patterns.md`
→ For token values used across variants: see `design_guide.md`
→ For trend modifications applied before variation: see `trend_adaptation.md`

---

## 1 — Purpose

A content brief typically maps to one "obvious" page layout. This file breaks that assumption. It defines the axes of variation available within the existing design system and provides a method for generating meaningfully different arrangements — each using the same content, the same components, and the same brand tokens.

The goal is divergent exploration *within* the system, not outside it.

---

## 2 — Variation Axes

Six independent axes along which a landing page can differ. Each axis has named options drawn from existing skill file definitions.

### 2.1 — Hero Strategy

How the page opens. Sets the first impression and primary conversion entry point.

| Option | Description | Component Used |
|---|---|---|
| `split-image` | Two-column: headline + CTA left, product screenshot right | Hero: Split Image |
| `full-bleed` | Background image/gradient with centered text overlay | Hero: Full Bleed |
| `product-centered` | Large product screenshot as focal point, text minimal | Hero: Product Centered |
| `text-bold` | No image — oversized typography, strong value proposition | Hero: Text Bold |
| `mini-hero` | Compact hero, content starts above the fold | Hero: Mini |

→ Hero component specs: see `components.md` Section 2

### 2.2 — Narrative Flow

The order in which content sections appear after the hero.

| Option | Sequence Logic | Best When |
|---|---|---|
| `problem-first` | Pain points → Solution → Features → Proof → CTA | Audience is problem-aware but not solution-aware |
| `product-first` | Features → Use cases → Proof → Pricing → CTA | Audience knows the category, comparing options |
| `trust-first` | Social proof / logos → Features → Differentiators → CTA | Audience is skeptical or in a crowded market |
| `outcome-first` | Results / metrics → How it works → Features → Proof → CTA | Audience is ROI-driven |
| `story-first` | Scenario / day-in-the-life → Problem → Solution → CTA | Top-of-funnel, awareness-stage audience |

→ Section sequencing rules and hard constraints: see `layout_patterns.md` Section 5

### 2.3 — Feature Presentation

How the product's feature set is displayed.

| Option | Layout Pattern | Density |
|---|---|---|
| `icon-grid` | 3- or 4-column grid, icon + heading + short description | High — many features visible at once |
| `alternating-rows` | Left-right alternating image + text blocks | Medium — one feature per viewport height |
| `tabbed-deep-dive` | Tab bar with detailed feature panels | Low density, high depth per feature |
| `accordion` | Expandable sections, one open at a time | Compact — progressive disclosure |
| `card-carousel` | Horizontally scrollable feature cards | Medium — implies more content |
| `bento-grid` | Mixed-size cards in masonry/grid layout | High visual variety, editorial feel |

→ Component specs for each: see `components.md` Sections 3.1–3.5
→ Bento grid layout: see `layout_patterns.md` Section 6

### 2.4 — CTA Strategy

How and where conversion actions appear throughout the page.

| Option | Behavior |
|---|---|
| `single-hero` | One CTA in hero; one in closing; nothing between |
| `contextual` | Each major section has its own relevant CTA |
| `sticky-bar` | Persistent bottom bar with CTA visible at all scroll positions |
| `progressive` | CTA appears only after scroll threshold or key content consumed |
| `dual-action` | Primary + secondary CTA paired throughout |

→ CTA component specs: see `components.md` Section 5
→ Sticky bar JS pattern: see `css_js_rules.md` Section 7.5
→ Composition exclusion: sticky-bar and contextual should not be combined — see `components.md` Section 7

### 2.5 — Density Profile

Overall spacing and content volume. Controlled by token overrides, not structural changes.

| Option | Effect |
|---|---|
| `breathing` | `space-section` increased, fewer total sections (max 5–6), generous whitespace |
| `standard` | Default token values from `design_guide.md` |
| `comprehensive` | `space-section` reduced, 8–10+ sections, tighter vertical rhythm |

→ Spacing tokens: see `design_guide.md` Section 4
→ If a Trend Adaptation Brief is active, its spatial density setting becomes the default for this axis

### 2.6 — Social Proof Placement

Where trust-building content lives in the page structure.

| Option | Position |
|---|---|
| `hero-adjacent` | Logo bar or quote directly below hero, before feature content |
| `mid-page` | Dedicated testimonial section between feature blocks |
| `distributed` | Small proof elements embedded inline within feature sections |
| `closing` | All social proof consolidated near bottom, before final CTA |

→ Social proof components: see `components.md` Section 4

---

## 3 — Generating Variants

### 3.1 — Input

The agent receives:
- A completed parsed brief (from `content_brief.md`)
- Number of variants requested (default: 3, max: 5)
- Optional: active Trend Adaptation Brief (modifies available options)

### 3.2 — Process

**Step 1: Filter by brief constraints.**

Not all axis options are valid for every brief:

| Constraint | Exclude |
|---|---|
| No product screenshots available | `product-centered` hero, `alternating-rows` features |
| Fewer than 4 features | `icon-grid`, `bento-grid` |
| Target: technical evaluators | Deprioritize `story-first` flow |
| Target: executive / business buyers | Prefer `outcome-first` or `trust-first` |
| No video assets | `video-hero` (if added as future option) |
| No testimonials or case studies | `trust-first` flow, `distributed` proof |
| Single CTA goal | Prefer `single-hero` or `sticky-bar` over `contextual` |
| Light content volume (< 5 sections) | `comprehensive` density |

**Step 2: Select axis values for each variant.**

Each variant must differ from every other on **at least 2 axes**. This prevents near-duplicate variants.

Use this heuristic:
- **Variant A** — "Default": most conventional, safe layout for this audience
- **Variant B** — "Conversion-optimized": prioritizes CTA visibility and trust signals early
- **Variant C** — "Content-rich": prioritizes depth, exploration, and feature detail
- **Variant D** (if requested) — "Bold/editorial": unconventional structure, visual-forward
- **Variant E** (if requested) — "Minimal": fewest sections, maximum focus

**Step 3: Name and describe each variant.**

Each variant gets:
- A short name (2–3 words, evocative)
- A one-sentence intent statement
- The axis values table
- A section-by-section page structure outline
- A tradeoffs note

### 3.3 — Output Format

```markdown
## Variation Spec: {Product Name} Landing Page

**Brief:** {brief filename}
**Variants generated:** {N}
**Date:** {YYYY-MM-DD}
**Trend profile applied:** {name or "None"}

---

### Variant A: "{Name}"

**Intent:** {One sentence — who is this for, what does it optimize for}

| Axis | Value |
|---|---|
| Hero | {option} |
| Flow | {option} |
| Features | {option} |
| CTA | {option} |
| Density | {option} |
| Proof | {option} |

**Page Structure:**

1. **Hero** — {description of hero content and layout}
2. **Section 2** — {section type + content summary}
3. **Section 3** — {section type + content summary}
4. ...
5. **Closing** — {final CTA section description}

**Tradeoffs:** {What this variant sacrifices}

---

### Variant B: "{Name}"
...
```

---

## 4 — Validation Checklist

Before presenting the Variation Spec:

- [ ] Every component referenced exists in `components.md`
- [ ] Every layout pattern referenced exists in `layout_patterns.md`
- [ ] No variant introduces a component or pattern not in the skill file system
- [ ] Each variant differs from every other on ≥ 2 axes
- [ ] Brief constraints from Step 1 are respected
- [ ] All variants use the same content — only arrangement differs
- [ ] Brand compliance: all invariants from `design_guide.md` Section 1 and `trend_adaptation.md` Section 1 maintained
- [ ] Each variant includes a Tradeoffs note
- [ ] Section sequencing hard rules from `layout_patterns.md` Section 5 are followed in every variant

---

## 5 — After Selection

Once a variant is selected:

1. The variant's **Page Structure** becomes the section sequence input for the active mode
2. The **Density** axis value feeds into spacing token selection (or overrides, if trend is active)
3. The **Feature Presentation** and **CTA Strategy** values determine component configurations from `components.md`
4. Proceed to standard pipeline: Mode A, B, or C

Unchosen variants are archived for future A/B testing or alternate campaign use.

---

## 6 — Integration with Trend Adaptation

When `trend_adaptation.md` produces a Trend Adaptation Brief *before* the Variation Generator runs:

- The trend's **spatial density** becomes the default for the Density axis (variants can still override it)
- The trend's **interaction pattern** influences which feature presentation options are preferred (e.g., `progressive-disclosure` trend makes `tabbed-deep-dive` and `accordion` preferred)
- The trend's **visual weight distribution** may add or restrict hero options (e.g., `bento` weight adds `mini-hero` as preferred)
- Token override values from the trend brief apply to all variants equally — variants differ in structure, not in visual tokens

---

## 7 — Extending This File

### Adding new axis options
When a new component or layout pattern is added to `components.md` or `layout_patterns.md`, add the corresponding option to the relevant axis table in Section 2.

### Adding new axes
If a meaningful dimension of variation is discovered that isn't captured, add as Section 2.7+. Must be truly independent of existing axes.

### Trend integration updates
As new trend profiles are added to `trend_adaptation.md`, review Section 6 to ensure integration rules still hold.

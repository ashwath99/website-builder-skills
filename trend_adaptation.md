<!-- meta
name: trend_adaptation
title: Trend Adaptation
version: 4.0
status: active
purpose: Ingest external design trends and translate them into concrete, brand-safe token overrides and layout modifications that the existing skill file system can execute.
owns:
  - Trend dimension definitions (7 dimensions)
  - Named trend profiles
  - Token override sheet format
  - Layout modification format
  - Brand invariant gate (verification process)
  - Trend discovery and competitor scan process
  - Audience-to-trend alignment mapping
requires:
  - workflow
  - design_guide
depends_on:
  - components
  - layout_patterns
  - css_js_rules
referenced_by:
  - variation_generator
  - agent_execution_prompt
  - workflow
modes:
  mode_a: optional
  mode_b: optional
  mode_c: optional
layer: exploration
last_updated: 2026-03-25
-->

# Trend Adaptation — Token Overrides & Layout Modifications

This file gives the agent a method for identifying design trends, mapping them to specific token and layout changes within the ManageEngine design system, and enforcing brand compliance throughout.

→ For base token values being overridden: see `design_guide.md`
→ For how overrides are expressed in CSS: see `css_js_rules.md`
→ For layout patterns being modified: see `layout_patterns.md`
→ For component specs affected by trend changes: see `components.md`
→ For how trend output feeds into variation exploration: see `variation_generator.md`

---

## 1 — Brand Invariants (Never Modified)

Before any trend is applied, these elements are locked. No trend override may touch them.

| Invariant | Value | Defined In |
|---|---|---|
| Primary CTA color | `#E9142B` | `design_guide.md` |
| Brand font (headings) | ZohoPuvi (Zoho CDN) | `design_guide.md` |
| Body font | Per `design_guide.md` | `design_guide.md` |
| CTA hierarchy | Primary → Secondary → Tertiary | `design_guide.md` |
| Class prefix pattern | `{product}-` | `html_structure.md` |
| Responsive breakpoints | 480px, 1024px | `css_js_rules.md` |
| Output format | `index.html`, `styles.css`, `script.js` | `css_js_rules.md` |
| BEM naming convention | Block__element--modifier | `html_structure.md` |
| Image path convention | `./assets/` with TODO flags | `css_js_rules.md` |
| Code stack | Vanilla HTML/CSS/JS; jQuery for UI interactions only | `css_js_rules.md` |

**Rule:** If a trend adaptation would require changing any invariant, that adaptation is rejected. The trend must be re-expressed within invariant constraints or skipped entirely.

---

## 2 — Trend Dimensions

Seven independent, parametric dimensions along which trends can be observed and applied. Each maps to specific tokens or layout rules.

### 2.1 — Spatial Density

How much breathing room exists between and within sections.

| Position | Token Changes | Visual Effect |
|---|---|---|
| `airy` | `space-section` increased ~40%; `grid-gutter` increased ~30%; `content-max-width` reduced | Luxurious whitespace, slower scroll pace, premium feel |
| `standard` | Default values from `design_guide.md` | Current ManageEngine baseline |
| `compact` | `space-section` reduced ~35%; `grid-gutter` reduced ~20% | Information-dense, SaaS-dashboard feel, more content above fold |

→ Spacing tokens being modified are defined in `design_guide.md` Section 4

### 2.2 — Typography Scale

The ratio between heading sizes and body text.

| Position | Token Changes | Visual Effect |
|---|---|---|
| `display-forward` | `font-size-display` and `font-size-h1` scaled up 30–40%; `line-height-heading` tightened to ~1.1; negative `letter-spacing-heading` | Bold, editorial, statement-making |
| `balanced` | Default type scale from `design_guide.md` | Current baseline |
| `content-forward` | `font-size-h1` scaled down 10–15%; `font-size-body` increased to 18px; `line-height-body` loosened; `content-max-width-narrow` reduced | Readability-first, long-form friendly |

**Invariant check:** Font family never changes. Only size, weight, line-height, and letter-spacing are adjustable.

→ Typography tokens being modified are defined in `design_guide.md` Section 3

### 2.3 — Color Temperature

Warmth or coolness of surface colors and section backgrounds.

| Position | Token Changes | Visual Effect |
|---|---|---|
| `warm` | Tint surface/border pairs shift toward warm neutrals (beige, warm gray, soft amber) | Approachable, human, less "tech-corporate" |
| `neutral` | Default tint palette from `design_guide.md` | Current baseline |
| `cool` | Tint surface/border pairs shift toward cool neutrals (blue-gray, slate) | Technical precision, enterprise-grade |
| `dark-mode` | Section backgrounds use dark surfaces; text inverts to light; cards get subtle light borders; CTA red remains | High contrast, modern SaaS aesthetic |

**Invariant check:** `#E9142B` remains the primary CTA color in all temperature modes.

→ Tint pair values being modified are defined in `design_guide.md` Section 2.4

### 2.4 — Visual Weight Distribution

Where the visual emphasis falls on the page.

| Position | Layout Changes | Visual Effect |
|---|---|---|
| `hero-dominant` | Hero section takes 80–100vh; subsequent sections visually quieter | Strong first impression, single-scroll-stop conversion |
| `distributed` | Hero reduced to 50–60vh; each section carries its own visual anchor | Sustained engagement, more scroll motivation |
| `bento` | Hero minimal or absent; content organized in asymmetric card grid | Modern, editorial, non-linear browsing |

→ For bento grid layout rules: see `layout_patterns.md` Section 6
→ For bento grid CSS: see `css_js_rules.md` Section 6

### 2.5 — Interaction Pattern

How interactive elements behave.

| Position | Implementation | Notes |
|---|---|---|
| `static` | All content visible on load; no JS-driven show/hide | Simplest; best for SEO; fastest load |
| `scroll-activated` | Sections animate in on scroll; counters animate on visibility | Uses IntersectionObserver pattern |
| `progressive-disclosure` | Tabbed sections, accordions, expandable cards | Compact above-fold; rewards exploration |
| `micro-interactions` | Hover states on cards; button animations; cursor-following effects | Polished, premium; higher dev time |

→ For jQuery interaction patterns: see `css_js_rules.md` Section 7
→ For component interaction specs: see `components.md`

### 2.6 — Section Divider Style

How sections transition into each other visually.

| Position | CSS Implementation | Visual Effect |
|---|---|---|
| `clean-cut` | Flat background color change; no decorative elements | Minimal, professional |
| `subtle-gradient` | Gradient transitions at section top/bottom edges | Smooth, cohesive |
| `shaped-divider` | CSS `clip-path` or SVG shapes at boundaries | Dynamic, energetic; careful mobile handling needed |
| `bordered` | Thin horizontal rule between sections | Structured, editorial |

### 2.7 — Card & Component Style

Visual treatment of cards, feature blocks, and contained components.

| Position | Token Changes | Visual Effect |
|---|---|---|
| `flat` | `shadow-*: none`; border only (`1px solid`); `radius-*` minimal (4px) | Clean, utilitarian |
| `elevated` | `shadow-md` applied; `radius-md` at 12–16px; slight background contrast | Modern, material-inspired, "lifted" |
| `glassmorphic` | Semi-transparent backgrounds; `backdrop-filter: blur(10px)`; subtle border | Premium, layered; performance consideration |
| `outlined` | Prominent border (`2px solid`); no shadow; generous padding; `radius-sm` to `radius-md` | Structured, defined |

→ Shadow and radius tokens being modified are defined in `design_guide.md` Sections 5–6

---

## 3 — Trend Profiles

Named profiles — common trend bundles observed in the current landscape.

### Profile: "Modern SaaS"
```
spatial_density:      compact
typography_scale:     display-forward
color_temperature:    cool
weight_distribution:  hero-dominant
interaction_pattern:  scroll-activated
section_dividers:     clean-cut
component_style:      elevated
```
**Reference:** Linear, Vercel, Notion landing pages.

### Profile: "Enterprise Trust"
```
spatial_density:      standard
typography_scale:     balanced
color_temperature:    neutral
weight_distribution:  distributed
interaction_pattern:  static
section_dividers:     bordered
component_style:      outlined
```
**Reference:** Salesforce, ServiceNow, traditional B2B SaaS.

### Profile: "Editorial Product"
```
spatial_density:      airy
typography_scale:     display-forward
color_temperature:    warm
weight_distribution:  bento
interaction_pattern:  micro-interactions
section_dividers:     subtle-gradient
component_style:      flat
```
**Reference:** Apple product pages, Stripe, premium DTC brands.

### Profile: "Dark Mode Technical"
```
spatial_density:      compact
typography_scale:     content-forward
color_temperature:    dark-mode
weight_distribution:  distributed
interaction_pattern:  progressive-disclosure
section_dividers:     clean-cut
component_style:      glassmorphic
```
**Reference:** Developer tools, API platforms, DevOps products.

### Profile: "Approachable SaaS"
```
spatial_density:      standard
typography_scale:     balanced
color_temperature:    warm
weight_distribution:  hero-dominant
interaction_pattern:  scroll-activated
section_dividers:     shaped-divider
component_style:      elevated
```
**Reference:** Mailchimp, Slack, mid-market SaaS for non-technical users.

---

## 4 — Applying a Trend

### 4.1 — Input

The agent receives one of:
- A named **Trend Profile** from Section 3
- A set of individual **dimension values** (partial or complete)
- A **reference URL or description** — the agent maps this to the closest profile

### 4.2 — Process

**Step 1: Resolve to dimension values.**
If a profile name is given, expand to its 7 values. If a reference is given, identify the closest profile and confirm with the user. If individual values are given, fill missing dimensions with `standard`/`balanced`/`neutral` defaults.

**Step 2: Generate the Token Override Sheet.**
For each non-default dimension value, list the exact CSS custom property changes. Use the naming syntax from `css_js_rules.md` Section 2.1 and override the values defined in `design_guide.md`.

```css
/* Trend Override: Modern SaaS profile */
--{product}-space-section: 64px;
--{product}-grid-gutter: 20px;
--{product}-font-size-display: 4.2rem;
--{product}-font-size-h1: 3.6rem;
--{product}-line-height-heading: 1.1;
--{product}-letter-spacing-heading: -0.02em;
--{product}-tint-1-surface: #f0f4f8;
--{product}-tint-1-border: #cbd5e1;
--{product}-shadow-md: 0 4px 24px rgba(0, 0, 0, 0.08);
--{product}-radius-md: 14px;
```

**Step 3: Run the Invariant Gate.**
Check every override against Section 1:
- Does any override change `#E9142B`? → Reject
- Does any override change the font-family? → Reject
- Does any override alter breakpoints? → Reject
- Does any override introduce a new file or dependency? → Reject
- Does any override require a CSS feature with browser support concerns? → Flag for review

**Step 4: Generate the Layout Modification List.**
For non-token changes (layout structure, interaction patterns), list specific modifications:

```markdown
### Hero Section
- Height: 100vh (hero-dominant)
- Animation: fade-up on load (scroll-activated)

### Feature Sections
- Grid gutter: tightened per compact density
- Cards: elevated style (shadow, radius from override sheet)

### Section Transitions
- Divider style: clean-cut (flat background change)

### Interactions
- IntersectionObserver for scroll-triggered section animations
- Fade-up with 30px translate, 0.6s ease-out
- Stagger child elements by 100ms
```

→ For interaction JS patterns referenced here: see `css_js_rules.md` Section 7

**Step 5: Produce the Trend Adaptation Brief.**

### 4.3 — Output Format

```markdown
## Trend Adaptation Brief: {Product Name}

**Profile applied:** {Profile name or "Custom"}
**Date:** {YYYY-MM-DD}

### Dimension Values

| Dimension | Value | Default? |
|---|---|---|
| Spatial Density | {value} | {yes/no} |
| Typography Scale | {value} | {yes/no} |
| Color Temperature | {value} | {yes/no} |
| Weight Distribution | {value} | {yes/no} |
| Interaction Pattern | {value} | {yes/no} |
| Section Dividers | {value} | {yes/no} |
| Component Style | {value} | {yes/no} |

### Token Override Sheet
{CSS custom property block from Step 2}

### Layout Modifications
{Modification list from Step 4}

### Invariant Check
✓ Passed / ✗ {list violations}

### Browser/Performance Notes
{Any flags from Step 3}

### Impact on Variation Generator
{Which axis options in variation_generator.md are added, removed, or modified}
```

---

## 5 — Trend Discovery (Research Phase)

When the agent is asked to *recommend* a trend rather than apply a specified one.

### 5.1 — Competitor Scan

Using web search, examine 3–5 landing pages from:
- Direct competitors in the same product category
- Aspirational peers (products the target audience also uses)
- Design-forward SaaS companies setting current visual standards

For each page, note observed dimension values across the 7 dimensions.

### 5.2 — Audience Alignment

Match observed trends to the target audience from the content brief:

| Audience Type | Tends to Respond To | Tends to Distrust |
|---|---|---|
| IT administrators / technical evaluators | `compact`, `content-forward`, `cool`/`dark-mode`, `progressive-disclosure` | `airy`, `display-forward`, `shaped-divider` |
| Business decision-makers / executives | `standard`, `balanced`, `neutral`, `hero-dominant`, `static`/`scroll-activated` | `dark-mode`, `glassmorphic`, `micro-interactions` |
| Developers / DevOps engineers | `compact`, `dark-mode`, `progressive-disclosure`, `flat`/`glassmorphic` | `warm`, `shaped-divider`, `display-forward` |
| SMB owners / non-technical users | `standard`/`airy`, `warm`, `hero-dominant`, `scroll-activated`, `elevated` | `compact`, `dark-mode`, `content-forward` |

→ Audience classification comes from `content_brief.md` Step 2

### 5.3 — Recommendation

Present 2 profile options to the stakeholder:
- **Safe choice:** Closest to what competitors are doing
- **Bold choice:** Differentiates while still matching audience expectations

Include rationale referencing specific competitor observations.

---

## 6 — Integration with Pipeline

### With `variation_generator.md`
The Trend Adaptation Brief is applied *before* the Variation Generator runs. It modifies available axis options and default token values within which variations are explored.

### With `design_guide.md`
Token overrides layer *on top of* base values. The base file is never modified.

→ For override protocol: see `design_guide.md` Section 10

### With `css_js_rules.md`
Overridden token values replace base values in the `:root` block. Interaction pattern selections determine which jQuery patterns from `css_js_rules.md` Section 7 are included in `script.js`.

### Pipeline Position
```
Content Brief
  → Trend Adaptation Brief (this file)
  → Variation Spec (variation_generator.md)
  → Execute Mode A, B, or C
```

---

## 7 — Extending This File

### Adding new profiles
Each profile must specify all 7 dimensions. Include 2–3 reference examples.

### Adding new dimensions
Must map to specific, overridable CSS tokens or layout rules. Must not conflict with any brand invariant. Must be independent of existing dimensions. Add as Section 2.8+.

### Refreshing audience alignment
Review the audience-to-trend mapping in Section 5.2 every 6–12 months as expectations shift.

---
name: figma-code-extractor
description: "Converts finalized Figma frames into production HTML/CSS/JS through a 4-phase pipeline: inspect, plan, generate, self-review. Handles spec extraction, asset export, variable-first token mapping, and Code Connect integration. Use when generating code from Figma designs (Mode B)."
version: "5.0"
---

# Figma to Code — Inspection & Conversion Pipeline

This file defines how the agent reads a finalized Figma frame and converts it into production code. It is used exclusively in Mode B (Figma → Code).

→ For the reverse direction (pushing to Figma): see `figma-frame-builder/SKILL.md`
→ For HTML output rules: see `html-generator/SKILL.md`
→ For CSS/JS output rules: see `css-js-generator/SKILL.md`
→ For component specs to verify against: see `component-library/SKILL.md`

---

## 1 — Prerequisites

Before starting the Figma-to-Code pipeline, the agent must have:

| Input | Source | Required |
|---|---|---|
| Figma dev link (with node ID) or frame selected in desktop app | User-specified in prompt | Yes |
| Product class prefix | User-specified in prompt | Yes |
| Skill files loaded | `design-tokens/SKILL.md`, `component-library/SKILL.md`, `html-generator/SKILL.md`, `css-js-generator/SKILL.md` | Yes |
| Remote MCP server connected | `mcp.figma.com/mcp` authenticated | Yes |
| Pre-exported assets (if any) | User-specified, in project assets folder | Optional |

### MCP Server Setup

The remote Figma MCP server is the default connection method. No local bridge or desktop app is required for link-based inspection.

| Method | How It Works |
|---|---|
| **Remote server (recommended)** | Link-based — provide a Figma URL to extract context. Works from any MCP client. |
| **Desktop server** | Selection-based — select a frame in the Figma desktop app and the agent reads the selection. Requires Figma desktop. |

→ For setup instructions per agent: see `figma-frame-builder/SKILL.md` Section 1

---

## 2 — Figma MCP Tool Selection

The tool set is smaller and more focused than v3.0. Three read tools cover all inspection needs, plus `use_figma` for any modifications during review.

### Read Tools

| Tool | Purpose | Notes |
|---|---|---|
| `Figma:get_design_context` | **Primary inspection tool** — returns structured representation of a frame including layout, spacing, colors, typography, component references, and a screenshot | Replaces `figma_get_component_for_development`. Output is React + Tailwind by default; agent translates to vanilla HTML/CSS per skill file rules. Includes style bindings where present. |
| `Figma:search_design_system` | Find components, variables, and styles across connected libraries by text query | Replaces `figma_search_components`, `figma_get_component_details`. Use to identify which library components were used in the frame. |
| `Figma:use_figma` (read mode) | Extract variables, styles, and detailed token values via Plugin API scripts | Replaces `figma_get_variables`, `figma_get_styles`, `figma_browse_tokens`. Use the variable extraction script from the Master Reference when you need CSS-formatted token values. |

### Write Tool (for review fixes)

| Tool | Purpose | Notes |
|---|---|---|
| `use_figma` | Modify the Figma frame during self-review if discrepancies are found between frame and generated code | Requires `/figma-use` skill. Used only in Phase 4 if the agent needs to annotate or flag issues back in Figma. |

### Code-to-Canvas Tool

| Tool | Purpose | Notes |
|---|---|---|
| `generate_figma_design` | Push generated HTML back into Figma as editable layers for visual comparison | Optional — useful for comparing generated code output against the original frame side-by-side. |

### Deprecated Tools (v3.0 → v4.0)

These individual tools are no longer needed. Their functionality is consolidated into the tools above.

| Deprecated Tool | Replaced By |
|---|---|
| `figma_get_component_for_development` | `Figma:get_design_context` |
| `figma_capture_screenshot` | `Figma:use_figma` (`node.exportAsync()`) |
| `figma_take_screenshot` | `Figma:use_figma` (`node.exportAsync()`) |
| `figma_get_variables` | `Figma:use_figma` (Plugin API variable read script — see Master Reference) |
| `figma_browse_tokens` | `Figma:use_figma` (Plugin API variable read script) |
| `figma_get_component_details` | `Figma:search_design_system` |
| `figma_get_component_image` | `Figma:use_figma` (`node.exportAsync()`) |
| `figma_get_file_data` | `Figma:get_design_context` (scoped to frame) |
| `figma_get_styles` | `Figma:use_figma` (`figma.getLocalPaintStyles()`, etc.) |
| `figma_get_status` | MCP connection verified at session start |

**Priority order:** Start with `get_design_context` — it returns the most useful data per call. Use `get_variable_defs` for detailed token extraction. Use `search_design_system` to identify library components used in the frame.

---

## 3 — Phase 1: Inspect

**Goal:** Extract all design specifications from the Figma frame.

### Step 1: Verify Connection and Load Frame

```
Confirm remote MCP server is connected
Call get_design_context with the dev link node ID (or use desktop selection)
→ Returns: structured layout representation, spacing, colors, typography, component references
```

### Step 2: Extract Token Bindings

```
Call Figma:use_figma with the variable extraction script (see Master Reference)
→ Returns: all local variables formatted as CSS custom properties
  - Color variables (fills, strokes, text colors)
  - Spacing variables (padding, gaps)
  - Typography styles (font, size, weight, line-height)

Alternatively, get_design_context includes style references in its output —
use these for mapping when full variable extraction is not needed.
```

Map returned variable names to `design-tokens/SKILL.md` tokens. If Figma variables use different naming than the skill file tokens, create a mapping table for Phase 2.

### Step 3: Identify Design System Components

```
Call search_design_system with component types found in the frame
→ Returns: library components used, their properties, and variant configurations
```

Record which components are library instances (reusable) vs. local overrides (custom).

### Step 4: Extract Section Structure

From the `get_design_context` output, identify:

| What to Capture | How to Identify |
|---|---|
| Section boundaries | Top-level child frames within the page frame |
| Section types | Layer name prefixes (e.g., `Section: Hero`, `Section: Features`) or visual analysis |
| Component types | Component instance names from `search_design_system` results or layer prefixes |
| Section order | Top-to-bottom order of child frames |
| Tinted sections | Background fill colors / variable bindings on section frames |

### Step 5: Extract Design Specs Per Section

For each section, capture from the `get_design_context` and `get_variable_defs` output:

| Spec | What to Record |
|---|---|
| **Layout** | Column count, alignment, gap between items, content width |
| **Spacing** | Padding (top, right, bottom, left), margins, gaps — prefer variable names over raw values |
| **Typography** | Font family, size, weight, line-height, color for each text element — prefer style references |
| **Colors** | Background fills, text colors, border colors, CTA colors — prefer variable references |
| **Shadows** | Box shadows on cards and elevated elements |
| **Border radius** | Corner radius on cards, buttons, images |
| **Images** | Image names, dimensions, aspect ratios, file format |
| **Interactions** | Any prototype interactions (tabs, hover states) — infer JS behavior |

### Step 6: Extract and Export Assets

**Check the project assets folder first.** The user may have pre-exported some assets.

For remaining assets, use `use_figma` to export:

| Asset Type | Export Format | Notes |
|---|---|---|
| Product screenshots | PNG, highest quality | Use `use_figma` export capability |
| Icons | SVG preferred | Inline SVG when simple enough |
| Illustrations | PNG or SVG based on complexity | SVG for flat illustrations, PNG for complex |
| Logos | SVG preferred | Always SVG for crisp scaling |
| Hero images | PNG/JPG based on source | JPG for photographic, PNG for graphic |

**Compression rules:**
- SVG: Remove unnecessary metadata, minify paths
- PNG: Lossless compression — do not reduce quality
- JPG: Quality 85–90%, progressive encoding
- Target: Reduce file size without visible quality loss

**Output:** All assets saved to `./assets/` folder in the project directory.

### Handling Frames from generate_figma_design

When Mode B receives a frame that was created via `generate_figma_design` (the C → HTML → Figma path), the layer structure will mirror rendered HTML rather than the structured naming convention from `figma-frame-builder/SKILL.md` Section 4.

In this case:
- Layer names may be HTML element names (`div`, `section`, `h1`) rather than type-prefixed labels
- Auto-layout may not be present — layers may use absolute positioning
- Variables may not be bound — colors and spacing may be raw values

**Agent behavior:** Treat these frames the same as any non-standard frame (Section 7). Use visual analysis to identify sections and components. The `get_design_context` output still provides the structural data needed for code generation.

---

## 4 — Phase 2: Plan

**Goal:** Map Figma layers to HTML structure and CSS architecture before writing code.

### Step 1: Map Sections to HTML Landmarks

| Figma Layer | HTML Element |
|---|---|
| Top-level frame | `<body>` content (or `<main>`) |
| Section frames | `<section>` elements |
| Navigation (if present) | `<header>` with `<nav>` |
| Footer (if present) | `<footer>` |
| Hero section | `<section>` with hero-specific class |

### Step 2: Map Components to HTML Patterns

For each component identified in Phase 1, match it to the HTML markup pattern defined in `html-generator/SKILL.md`:

| Component Type | HTML Pattern Reference |
|---|---|
| Hero (any variant) | → `html-generator/SKILL.md` hero markup |
| Feature Card | → `html-generator/SKILL.md` card markup |
| Feature Grid | → `html-generator/SKILL.md` grid container markup |
| Feature Row | → `html-generator/SKILL.md` alternating row markup |
| Tabbed Panel | → `html-generator/SKILL.md` tab markup |
| Accordion | → `html-generator/SKILL.md` accordion markup |
| Testimonial | → `html-generator/SKILL.md` testimonial markup |
| Logo Bar | → `html-generator/SKILL.md` logo bar markup |
| CTA Section | → `html-generator/SKILL.md` CTA markup |

### Step 3: Plan CSS Token Mapping

Map extracted Figma values to CSS custom properties:

| Figma Value | CSS Custom Property Pattern |
|---|---|
| Variable-bound colors | Use the variable name → `--{product}-color-*` |
| Variable-bound spacing | Use the variable name → `--{product}-space-*` |
| Unbound fill colors | Match to closest `design-tokens/SKILL.md` token → `--{product}-color-*` |
| Unbound text sizes | Match to closest `design-tokens/SKILL.md` token → `--{product}-font-size-*` |
| Unbound spacing | Match to closest `design-tokens/SKILL.md` token → `--{product}-space-*` |
| Shadows | → `--{product}-shadow-*` |
| Border radius | → `--{product}-radius-*` |

**Variable-first approach (new in v4.0):** When `get_variable_defs` returns variable names bound to frame elements, use those names directly as the basis for CSS custom property naming. This is more reliable than matching raw pixel values to token tables.

For unbound values that don't match any defined token, flag as a potential deviation:

```css
/* TODO: This value (17px) doesn't match any token in design-tokens/SKILL.md.
   Closest match: --{product}-space-md ({PLACEHOLDER}).
   Verify with designer. Using extracted value for now. */
```

### Step 4: Plan JS Interactions

Identify interactive components and plan the jQuery implementation:

| Figma Indicator | JS Behavior Needed |
|---|---|
| Tabbed layout with multiple states | Tab switcher (show/hide panels) |
| Accordion with expand/collapse indicators | Accordion toggle |
| Carousel with multiple frames | Slide/scroll behavior |
| Scroll-position-dependent elements | IntersectionObserver triggers |
| Sticky elements | Scroll-based position locking |

→ For JS interaction patterns: see `css-js-generator/SKILL.md`

---

## 5 — Phase 3: Generate

**Goal:** Produce the three output files.

### File 1: `index.html`
Generate following all rules in `html-generator/SKILL.md`:
- Semantic HTML5 structure
- BEM class naming with `{product}-` prefix
- Section order matching Figma frame (top to bottom)
- All text content from Figma placed in correct elements
- Image tags with `./assets/` paths
- `<!-- TODO -->` comments for uncertain image mappings or deviations

### File 2: `styles.css`
Generate following all rules in `css-js-generator/SKILL.md`:
- CSS custom properties block at `:root` level for all tokens
- Variable-bound values from Figma map directly to custom property names
- Desktop-first responsive approach
- Media queries at 480px and 1024px breakpoints only
- Tinted section classes using surface/border color pairs
- No hardcoded values in rulesets — everything references custom properties
- Component styles matching Figma specs

### File 3: `script.js`
Generate following all rules in `css-js-generator/SKILL.md`:
- jQuery only (no other JS libraries)
- Interactive component handlers (tabs, accordion, carousel)
- Scroll-triggered behaviors (sticky bar, animations)
- Wrapped in `$(document).ready()` or equivalent

→ Full code generation rules are owned by `html-generator/SKILL.md` and `css-js-generator/SKILL.md`. This file defines the pipeline; those files define the output format.

---

## 6 — Phase 4: Self-Review

**Goal:** Validate the generated code against both skill file rules and Figma source specs.

### 6.1 — Automated Checklist

**HTML checks:**
- [ ] Semantic structure: `<section>`, `<header>`, `<footer>`, `<nav>`, `<main>` used correctly
- [ ] All classes follow BEM naming with `{product}-` prefix
- [ ] No inline styles
- [ ] All text content from Figma is present — nothing omitted
- [ ] All images reference `./assets/` paths
- [ ] Uncertain image mappings have `<!-- TODO -->` comments
- [ ] Heading hierarchy is correct (H1 → H2 → H3, no skips)
- [ ] Alt text on all images

**CSS checks:**
- [ ] All design values are CSS custom properties — no hardcoded colors, sizes, or spacing
- [ ] Custom property names follow `--{product}-*` pattern
- [ ] Variable-bound Figma values map to matching custom property names
- [ ] Desktop-first: base styles are desktop, media queries handle smaller screens
- [ ] Only two breakpoints: 1024px and 480px
- [ ] Tinted sections use matched surface/border pairs from `design-tokens/SKILL.md`
- [ ] No `!important` unless absolutely necessary (and documented with comment)

**JS checks:**
- [ ] jQuery only — no other libraries imported
- [ ] Interactive components work: tabs switch, accordions toggle, carousels slide
- [ ] Scroll behaviors fire at correct thresholds
- [ ] No console errors

**Figma fidelity checks:**
- [ ] Section order matches Figma frame order
- [ ] Spacing values match extracted specs (or closest token match)
- [ ] Color values match extracted specs (or closest token match)
- [ ] Typography matches extracted specs
- [ ] Layout (columns, alignment, gaps) matches Figma structure
- [ ] Responsive behavior degrades gracefully (even if Figma only shows desktop)

### 6.2 — Visual Comparison (Optional)

When higher fidelity is required, use `generate_figma_design` to push the generated HTML back into Figma for side-by-side comparison:

```
1. Serve the generated HTML locally or in a preview environment
2. Call generate_figma_design → creates editable Figma layers from the rendered HTML
3. Place the generated layers next to the original frame in Figma
4. Compare visually — spacing, alignment, color, typography
5. Log discrepancies as deviations
```

This step is optional but recommended for high-stakes pages or when the original frame has complex layouts.

### 6.3 — Deviation Log

If any generated value doesn't match the Figma spec exactly, log it:

```markdown
## Deviations from Figma

| Element | Figma Value | Generated Value | Reason |
|---|---|---|---|
| Feature card padding | 22px | 24px (--{product}-space-md) | Snapped to nearest token |
| H3 font size | 19px | 20px (--{product}-font-size-h3) | Snapped to nearest token |
```

Present this log to the user alongside the generated code.

---

## 7 — Handling Non-Standard Figma Frames

Not all Figma frames follow the layer naming convention from `figma-frame-builder/SKILL.md` (e.g., frames designed manually, by other designers, or created via `generate_figma_design`).

### Recognition Strategy

| If layers are... | Agent behavior |
|---|---|
| Named per `figma-frame-builder/SKILL.md` convention | Direct mapping — use prefixes to identify sections and components |
| Named descriptively but non-standard | Infer section types from names + `get_design_context` structure |
| Generic names (`Frame 1`, `Group 47`, `div`, `section`) | Rely on `get_design_context` structured output + visual analysis |
| Flat structure (no section grouping) | Group by spacing gaps and background changes in the design context data |
| Created via `generate_figma_design` | HTML-mirror structure — layer names may be element types; use visual analysis |

### Visual Analysis Fallbacks

When layer names are not informative, `get_design_context` still provides:
- **Layout structure** — auto-layout direction, padding, gaps, alignment
- **Component references** — which library components were instantiated
- **Style bindings** — which variables are applied to which elements
- **Hierarchy** — parent-child nesting that implies section boundaries

Use this structured data first. Fall back to visual pattern matching only when the structured data is ambiguous:
- **Section boundaries:** Look for vertical spacing gaps larger than component spacing, or background color changes
- **Component types:** Match visual patterns (grid of cards = Feature Grid, alternating image-text = Feature Rows)
- **Heading levels:** Largest text in a section = section heading, next largest = component headings
- **CTA identification:** Colored button-shaped elements with short text labels

---

## 8 — Code Connect Integration (Optional)

If the Figma design system uses Code Connect to map components to code implementations, the agent can leverage this for higher-quality output.

### What Code Connect Provides

Code Connect links Figma library components to their corresponding code implementations. When available, the agent receives:
- **Code component path** — file location in the codebase
- **Property mapping** — how Figma component properties map to code props
- **Framework-specific code** — the exact code snippet for each component variant

### How to Use in the Pipeline

```
1. During Phase 1 (Inspect), check if Code Connect mappings exist for identified components
2. If mappings exist, use the code component references instead of generating from scratch
3. In Phase 3 (Generate), import or reference the mapped code components
4. Flag any components that have Figma instances but no Code Connect mapping
```

**Note:** The current pipeline generates vanilla HTML/CSS/JS, not framework components. Code Connect mappings are useful as a reference for correct property usage and naming, even if the output format differs from the connected code.

→ For Code Connect setup: see Figma developer docs at `developers.figma.com/docs/figma-mcp-server/tools-and-prompts/`

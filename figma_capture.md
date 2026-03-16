<!-- meta
name: figma_capture
title: Figma Capture
version: 3.0
status: active
purpose: Define how the agent generates and pushes Figma design frames from design specs, including layer naming, frame structure, and MCP tool usage for frame creation.
owns:
  - Figma frame generation workflow
  - Layer naming conventions for generated frames
  - Frame structure and hierarchy rules
  - Figma MCP push workflow (brief/blueprint → Figma)
  - Auto-layout and constraint rules for generated frames
  - Figma page and file targeting
requires:
  - workflow
  - design_guide
  - components
  - layout_patterns
depends_on:
  - content_brief
  - figma_to_code
referenced_by:
  - agent_execution_prompt
modes:
  mode_a: required
  mode_b: not_used
  mode_c: not_used
layer: figma
last_updated: 2026-03-16
-->

# Figma Capture — Frame Generation

This file governs how the agent creates Figma design frames from design specs (parsed brief, selected layout, mapped components, applied tokens). It is used exclusively in Mode A (Brief → Figma) and in the C → A escalation path (Blueprint → Figma).

→ For the reverse direction (reading from Figma): see `figma_to_code.md`
→ For component specs being placed in frames: see `components.md`
→ For token values applied to frame elements: see `design_guide.md`
→ For section sequencing in the frame: see `layout_patterns.md`

---

## 1 — Prerequisites

Before generating a Figma frame, the agent must have:

| Input | Source | Required |
|---|---|---|
| Parsed brief or Page Blueprint | `content_brief.md` parsing output or `{product}-blueprint.md` | Yes |
| Selected layout pattern | `layout_patterns.md` selection logic | Yes |
| Component mapping | `components.md` section-to-component table | Yes |
| Design tokens | `design_guide.md` (with optional trend overrides) | Yes |
| Target Figma file and page | User-specified in prompt | Yes |
| Product class prefix | User-specified in prompt | Yes |
| MCP bridge running | `npx figma-developer-mcp` active | Yes |

---

## 2 — Figma MCP Tool Selection

Use the most specific tool for each task. Avoid broad file-level fetches when targeted tools exist.

| Task | Preferred MCP Tool | Notes |
|---|---|---|
| Push complete frame to Figma | `figma_execute` | Executes the frame generation script |
| Create a new child node | `figma_create_child` | For building frame hierarchy |
| Set text content on a node | `figma_set_text` | For populating text layers |
| Set fill colors on a node | `figma_set_fills` | For applying color tokens |
| Set image fill on a node | `figma_set_image_fill` | For hero images, screenshots |
| Set strokes/borders on a node | `figma_set_strokes` | For card borders, dividers |
| Resize a node | `figma_resize_node` | For adjusting dimensions |
| Move a node within parent | `figma_move_node` | For positioning layers |
| Rename a node | `figma_rename_node` | For correcting layer names |
| Clone an existing node | `figma_clone_node` | For duplicating repeated components |
| Get current selection | `figma_get_selection` | For inspecting what's selected |
| Take screenshot of result | `figma_capture_screenshot` | For visual verification after generation |
| Instantiate a library component | `figma_instantiate_component` | For using existing design system components |
| Search for existing components | `figma_search_components` | For finding reusable components before creating new ones |
| Check connection status | `figma_get_status` | Verify MCP bridge is connected before starting |

**Rule:** Always check `figma_get_status` at the start of Mode A. If the bridge is not connected, stop and instruct the user to start it.

---

## 3 — Frame Structure

### 3.1 — Top-Level Frame

The agent creates one top-level frame per landing page on the specified Figma page.

| Property | Value |
|---|---|
| Frame name | `{Product Name} — Landing Page` |
| Width | `1440px` (standard desktop canvas) |
| Height | Auto (grows with content) |
| Layout mode | Vertical auto-layout |
| Padding | `0` (sections handle their own padding) |
| Fill | `color-bg-page` from `design_guide.md` |

### 3.2 — Section Frames

Each page section is a child frame within the top-level frame.

| Property | Value |
|---|---|
| Frame name | `Section: {Section Type}` (e.g., `Section: Hero`, `Section: Feature Grid`) |
| Width | Fill parent (100% of top-level frame) |
| Height | Hug contents |
| Layout mode | Vertical auto-layout |
| Padding top/bottom | `section-padding-y` from `design_guide.md` |
| Padding left/right | Calculated to center content at `content-max-width` |
| Fill | Based on tinted section alternation rules from `layout_patterns.md` |

### 3.3 — Component Frames

Individual components within a section.

| Property | Value |
|---|---|
| Frame name | `{Component Type}: {Content Label}` (e.g., `Feature Card: Network Monitoring`) |
| Width | Based on grid column span |
| Height | Hug contents |
| Layout mode | Vertical or horizontal auto-layout (based on component spec) |
| Padding | `card-padding` from `design_guide.md` (for card-type components) |

---

## 4 — Layer Naming Convention

Consistent layer names enable Mode B to parse the frame reliably when generating code later.

### Naming Pattern

```
{Layer Type}: {Descriptive Label}
```

### Layer Types

| Type Prefix | Used For | Examples |
|---|---|---|
| `Section` | Page-level sections | `Section: Hero`, `Section: Features`, `Section: Closing CTA` |
| `Hero` | Hero variant | `Hero: Split Image`, `Hero: Full Bleed` |
| `Feature Card` | Individual feature block | `Feature Card: Real-time Alerts` |
| `Feature Grid` | Feature card container | `Feature Grid: Core Features` |
| `Feature Row` | Alternating image-text row | `Feature Row: Dashboard Analytics` |
| `Tab Panel` | Tabbed feature section | `Tab Panel: Advanced Features` |
| `Testimonial` | Customer quote | `Testimonial: John Smith, Acme Corp` |
| `Logo Bar` | Logo row | `Logo Bar: Trusted By` |
| `Metrics Bar` | Statistics row | `Metrics Bar: Key Numbers` |
| `CTA` | Call-to-action block | `CTA: Closing`, `CTA: Mid-page` |
| `FAQ` | FAQ section | `FAQ: Common Questions` |
| `Pricing` | Pricing section | `Pricing: Plans` |
| `Text` | Text elements | `Text: H1`, `Text: Body`, `Text: Caption` |
| `Image` | Image placeholders | `Image: Hero Screenshot`, `Image: Feature Icon` |
| `Button` | CTA buttons | `Button: Primary`, `Button: Secondary` |
| `Divider` | Section separators | `Divider: Line`, `Divider: Shaped` |

### Rules
- Every layer must have a type prefix — no unnamed or generic layers (e.g., no `Frame 47` or `Group 12`)
- Text layers include their heading level: `Text: H1`, `Text: H2 — Section Title`, `Text: Body`
- Image layers indicate content purpose: `Image: Hero Screenshot` not just `Image`
- Button layers indicate hierarchy: `Button: Primary CTA`, `Button: Secondary CTA`

---

## 5 — Content Population

### 5.1 — Text Content

All text from the parsed brief or blueprint is placed in the frame using actual copy, not placeholder "Lorem ipsum" text.

| Element | Content Source |
|---|---|
| Hero H1 | `headline` from parsed brief hero section |
| Hero subheadline | `subheadline` from parsed brief hero section |
| CTA button labels | `primary_cta` and `secondary_cta` from parsed brief |
| Feature headings | Feature `name` from parsed brief |
| Feature descriptions | Feature `description` from parsed brief |
| Testimonial quotes | `quote` + `attribution` from parsed brief |
| Section headings | Generated from section type (e.g., "Why Choose {Product}") or from brief if provided |

**Rule:** If the brief has content gaps (flagged in parsing), place a visual indicator in the frame:
- Missing text → Red placeholder text: `[MISSING: {description of what's needed}]`
- Missing image → Red-bordered rectangle with label: `[IMAGE NEEDED: {description}]`

### 5.2 — Images and Assets

| Asset Type | Frame Treatment |
|---|---|
| Available (from brief attachments) | Placed directly using `figma_set_image_fill` |
| Referenced but not provided | Gray placeholder rectangle with label and TODO note |
| Icons (not provided) | Placeholder circle or square with icon description label |

### 5.3 — Design Tokens

All visual properties are applied using values from `design_guide.md`:

| Property | Token Applied |
|---|---|
| Text colors | `color-text-primary`, `color-text-secondary`, etc. |
| Background fills | `color-bg-page`, tint surface colors |
| Button colors | `color-primary`, CTA style tokens |
| Spacing | `section-padding-y`, `space-*` scale |
| Typography | `font-heading`, `font-body`, size/weight/line-height tokens |
| Shadows | `shadow-sm`, `shadow-md`, etc. |
| Border radius | `radius-sm`, `radius-md`, etc. |

If a Trend Adaptation Brief is active, apply the token overrides from the trend brief instead of base values for any overridden tokens.

---

## 6 — Generation Process

### Step 1: Verify Connection
```
Call figma_get_status → confirm bridge is connected
```

### Step 2: Search for Existing Components
```
Call figma_search_components → check if design system components exist
that match the required component types
```
If reusable components exist, use `figma_instantiate_component` instead of building from scratch.

### Step 3: Create Top-Level Frame
```
Create frame on target page with properties from Section 3.1
```

### Step 4: Build Section Frames (Top to Bottom)
For each section in the layout pattern's sequence:
```
Create section frame → set dimensions, padding, fill
  → Create component frames within section
    → Populate text content
    → Place images or placeholders
    → Apply token values to all properties
```

### Step 5: Apply Tinted Section Alternation
```
Walk through sections → assign tint pairs per layout_patterns.md rules
```

### Step 6: Verify and Screenshot
```
Call figma_capture_screenshot → capture the generated frame
Present screenshot to user for review
```

---

## 7 — Post-Generation

After the frame is generated:

1. **Present to user:** Show a screenshot of the generated frame and summarize what was built (section count, component types used, any content gaps flagged)
2. **Flag issues:** List any content gaps, missing images, or decisions the agent made that the user should review
3. **Next steps:** Remind the user of their options:
   - Review and correct in Figma, then run Mode B for code
   - Accept as-is and run Mode B immediately
   - Request specific changes in the current session

---

## 8 — Blueprint → Figma (C → A Escalation)

When Mode C escalates to Figma, the input is a Page Blueprint (`{product}-blueprint.md`) instead of a parsed brief.

**Difference from standard Mode A:**
- The agent does NOT re-parse a content brief or re-run pattern selection
- The blueprint already contains all design decisions: section sequence, component choices, token values
- The agent reads the blueprint and executes Steps 3–6 from Section 6 directly
- The blueprint's asset manifest determines image placement (available vs placeholder)

**Prompt recognition:** If the user's prompt includes a blueprint file reference and says "do not re-analyze" or "use this as the design spec," the agent follows this escalation path.

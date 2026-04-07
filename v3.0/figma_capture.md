<!-- meta
name: figma_capture
title: Figma Capture
version: 4.0
status: active
purpose: Define how the agent generates and pushes Figma design frames from design specs, including the use_figma tool workflow, layer naming, frame structure, skills integration, and self-healing verification loop.
owns:
  - Figma frame generation workflow
  - Layer naming conventions for generated frames
  - Frame structure and hierarchy rules
  - Figma MCP write workflow (brief/blueprint → Figma)
  - Auto-layout and constraint rules for generated frames
  - Figma page and file targeting
  - Self-healing verification loop (generate → screenshot → compare → fix)
  - Skills integration for canvas writes
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
last_updated: 2026-03-25
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
| Remote MCP server connected | `mcp.figma.com/mcp` authenticated | Yes |
| `/figma-use` skill installed | Foundational skill for canvas writes | Yes |

### MCP Server Setup

The remote Figma MCP server (`mcp.figma.com/mcp`) is the default connection method. No local bridge is required.

| Agent | Setup |
|---|---|
| **Claude Code** | Install the Figma plugin: includes MCP server config + skills automatically |
| **Cursor AI** | Install the Figma plugin via agent chat, or add MCP server manually in Settings → MCP |
| **Codex** | Run `codex mcp add figma --url https://mcp.figma.com/mcp` and authenticate |

**Verification:** At session start, confirm the MCP server is connected and the `/figma-use` skill is available before proceeding.

---

## 2 — Figma MCP Tool Selection

The new Figma MCP server consolidates write operations into a single unified tool. Use targeted tools only for specific read tasks.

### Primary Write Tool

| Tool | Purpose | Notes |
|---|---|---|
| `use_figma` | **All write operations** — create, edit, delete, and inspect pages, frames, components, variants, variables, styles, text, and images | Always invoke the `/figma-use` skill before calling. Auto-searches connected design libraries for existing components before creating new ones. |

### Read & Search Tools

| Tool | Purpose | Notes |
|---|---|---|
| `search_design_system` | Find existing components, variables, and styles across connected libraries | Use before creating anything — reuse existing assets first |
| `get_design_context` | Get structured representation of a frame or selection | Returns layout, spacing, colors, typography in one call |
| `get_variable_defs` | Extract variables and styles used in a selection | For reading token values from existing frames |

### Code-to-Canvas Tool

| Tool | Purpose | Notes |
|---|---|---|
| `generate_figma_design` | Push live HTML into Figma as editable design layers | Used in C → Figma escalation path as an alternative to building frames from scratch |

### Skills

| Skill | Purpose | Required |
|---|---|---|
| `/figma-use` | Foundational skill — teaches the agent Plugin API rules, gotchas, and script templates | **Required before every `use_figma` call** |
| Custom skills | Your team's conventions packaged as installable skills | Optional — enhances consistency |

**Rule:** Always pass `skillNames` when calling `use_figma` for logging and workflow tracking.

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
| Available (from brief attachments) | Placed directly via `use_figma` |
| Referenced but not provided | Gray placeholder rectangle with label and TODO note |
| Icons (not provided) | Placeholder circle or square with icon description label |

**Note:** Image support in `use_figma` is expanding. If image placement fails, flag it for manual placement and continue with placeholder rectangles.

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

### 5.4 — Design System Reuse

Before creating any element, the agent must check for existing design system assets:

```
1. Call search_design_system with the component type (e.g., "button", "card")
2. If a matching library component exists → use it via use_figma (instantiate)
3. If variables exist for the token → bind to the variable, don't hardcode values
4. Only create from scratch when no library match exists
```

This is a behavioral change from v3.0 — `use_figma` encourages reuse by default, but the agent must explicitly search first for existing design system components.

---

## 6 — Generation Process

### Step 1: Verify Connection and Skills
```
Confirm remote MCP server is connected
Confirm /figma-use skill is available
```
If either is missing, stop and instruct the user to set up the Figma MCP plugin.

### Step 2: Search for Existing Components
```
Call search_design_system → check if design system components exist
that match the required component types (buttons, cards, etc.)
```
Catalog available components for reuse. Note any gaps that require building from scratch.

### Step 3: Create Top-Level Frame
```
Invoke /figma-use skill
Call use_figma → create frame on target page with properties from Section 3.1
```

### Step 4: Build Section Frames (Top to Bottom)
For each section in the layout pattern's sequence:
```
Call use_figma → create section frame → set dimensions, padding, fill
  → Create component frames within section (reuse library components where possible)
    → Populate text content
    → Place images or placeholders
    → Apply token values (bind to variables when available)
```

### Step 5: Apply Tinted Section Alternation
```
Walk through sections → assign tint pairs per layout_patterns.md rules
```

### Step 6: Self-Healing Verification Loop

This replaces the single-pass screenshot of v3.0 with an iterative verification cycle.

```
LOOP (max 3 iterations):
  1. Take screenshot of the generated frame via use_figma
  2. Compare screenshot against design spec:
     - Section order matches layout pattern?
     - Tinted sections alternate correctly?
     - Text content is present and complete?
     - Component spacing looks correct?
     - No broken layouts or overlapping elements?
  3. If mismatches found:
     - Log each mismatch with description
     - Fix via use_figma (adjust spacing, reorder, fix text, etc.)
     - Continue to next iteration
  4. If all checks pass → exit loop
```

**Exit conditions:**
- All visual checks pass → proceed to Step 7
- Max iterations reached → proceed to Step 7 with deviation log
- Critical failure (frame didn't generate, MCP error) → stop and report

### Step 7: Final Screenshot and Report
```
Take final screenshot via use_figma
Present to user with summary
```

---

## 7 — Post-Generation

After the frame is generated:

1. **Present to user:** Show a screenshot of the generated frame and summarize what was built (section count, component types used, library components reused, any content gaps flagged)
2. **Verification summary:** Report results from the self-healing loop — how many iterations, what was fixed, any remaining deviations
3. **Flag issues:** List any content gaps, missing images, or decisions the agent made that the user should review
4. **Next steps:** Remind the user of their options:
   - Review and correct in Figma, then run Mode B for code
   - Accept as-is and run Mode B immediately
   - Request specific changes in the current session

---

## 8 — Blueprint → Figma (C → A Escalation)

Two escalation paths are available when Mode C output needs to become a Figma frame.

### Path A: Blueprint → use_figma (Structured Build)

When Mode C escalates to Figma using the blueprint as a pre-decided spec, the agent executes Steps 3–7 from Section 6 directly — no brief re-parsing or pattern selection.

**When to use:** When you want a structured Figma frame built from the blueprint with proper layer naming, auto-layout, and design system bindings. Best for frames that will be edited further in Figma.

**Prompt recognition:** If the user's prompt includes a blueprint file reference and says "do not re-analyze" or "use this as the design spec," the agent follows this path.

### Path B: HTML → generate_figma_design (Quick Visual)

When Mode C has already produced working HTML, the agent can push the rendered HTML directly into Figma as editable layers.

```
1. Serve the Mode C HTML output (index.html + styles.css + script.js)
2. Call generate_figma_design with the live URL or localhost
3. Figma receives editable layers matching the rendered HTML
4. User corrects in Figma as needed
5. Run Mode B against the corrected frame for final production code
```

**When to use:** When you want a fast visual representation in Figma without building structured frames from scratch. The output layers mirror the rendered HTML rather than following the Section 4 naming convention. Best for quick review cycles.

**Tradeoff:** Path B layers won't have the structured naming and auto-layout of Path A. If extensive Figma editing is planned, Path A is preferred. If the goal is visual review followed by Mode B code generation, Path B is faster.

→ For Mode B code generation from either path: see `figma_to_code.md`

---

## 9 — Custom Skill Packaging (Optional)

Your skill files can be packaged as installable Figma skills for sharing across teams or the Figma Community.

### Converting figma_capture.md to a Figma Skill

The Figma skill format uses YAML frontmatter instead of HTML comment metadata:

```markdown
---
name: me-generate-landing-page
description: "Generate a landing page frame from a content brief using the UX Skill File Architecture. Use when building new product landing pages that follow the design system standards."
compatibility: Requires the figma-use skill to be installed alongside this skill
metadata:
  mcp-server: figma
  version: 4.0
  author: "{PLACEHOLDER}"
---

# Generate landing page

**Always pass `skillNames: "me-generate-landing-page"` when calling `use_figma` as part of this skill.**

**You MUST invoke the `figma-use` skill before every `use_figma` call.**

## When to use
- Creating new product landing pages from a content brief
- Escalating a Mode C Page Blueprint into a Figma frame
- Rebuilding an existing landing page with updated content

## Instructions
1. Read the content brief and parse using content_brief.md rules
2. Search connected libraries for existing design system components
3. Select layout pattern from layout_patterns.md
4. Create the top-level frame at 1440px width
5. Build sections top to bottom, reusing library components
6. Apply design tokens from design_guide.md
7. Run the self-healing verification loop (screenshot → compare → fix)
8. Present final screenshot with summary

## Examples
**Input:** "Generate a landing page for MSP Central using the attached brief"
**Output:** A 1440px Figma frame with 7 sections (Hero, Trust Signals, Feature Grid, Feature Deep-Dive, Testimonials, Integration Grid, Closing CTA), all text populated from the brief, library buttons and cards reused, tinted sections alternating correctly.
```

### Supporting Files

A packaged skill can include:
- `scripts/` — Reusable Plugin API scripts for common frame operations
- `references/` — Token value tables, component spec summaries
- `assets/` — Template frames or starter components

→ For skill authoring details: see Figma developer docs at `developers.figma.com/docs/figma-mcp-server/create-skills/`

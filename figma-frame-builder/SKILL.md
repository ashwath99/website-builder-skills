---
name: figma-frame-builder
description: Generates and pushes Figma design frames from design specs using the remote MCP server. Handles frame structure, layer naming, content population, design system reuse, and self-healing verification. Use when creating Figma frames from content briefs (Mode A) or escalating blueprints to Figma.
version: "5.0.7"
---

# Figma Capture — Frame Generation

This file governs how the agent creates Figma design frames from design specs (parsed brief, selected layout, mapped components, applied tokens). It is used exclusively in Mode A (Brief → Figma) and in the C → A escalation path (Blueprint → Figma).

→ For the reverse direction (reading from Figma): see `figma-code-extractor`
→ For component specs being placed in frames: see `component-library`
→ For token values applied to frame elements: see `design-tokens`
→ For section sequencing in the frame: see `layout-patterns`

---

## 1 — Prerequisites

Before generating a Figma frame, the agent must have:

| Input | Source | Required |
|---|---|---|
| Parsed brief or Page Blueprint | `brief-parser` parsing output or `{product}-blueprint.md` | Yes |
| Selected layout pattern | `layout-patterns` selection logic | Yes |
| Component mapping | `component-library` section-to-component table | Yes |
| Design tokens | `design-tokens` (with optional trend overrides) | Yes |
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
| Fill | `color-bg-page` from `design-tokens` |

### 3.2 — Section Frames

Each page section is a child frame within the top-level frame.

| Property | Value |
|---|---|
| Frame name | `Section: {Section Type}` (e.g., `Section: Hero`, `Section: Feature Grid`) |
| Width | Fill parent (100% of top-level frame) |
| Height | Hug contents (with min-height — see below) |
| Layout mode | Vertical auto-layout |
| Padding top/bottom | `section-padding-y` from `design-tokens` |
| Padding left/right | Calculated to center content at `content-max-width` |
| Fill | Based on tinted section alternation rules from `layout-patterns` |

**Collapsed Frame Prevention:** "Hug contents" alone can produce visually collapsed sections when child frames don't push enough height. Every section frame must have a `min-height` set:

| Section Type | Min-Height |
|---|---|
| Hero | `500px` |
| Feature Grid / Feature Row | `300px` |
| Testimonial / Logo Bar / Metrics Bar | `200px` |
| CTA / Pricing | `250px` |
| FAQ / Accordion | `200px` |
| All other sections | `200px` |

After creating a section, the agent must verify the rendered height exceeds min-height. If it doesn't, the section is collapsed and needs fixing (see Section 6, Step 6).

### 3.3 — Component Frames

Individual components within a section.

| Property | Value |
|---|---|
| Frame name | `{Component Type}: {Content Label}` (e.g., `Feature Card: Network Monitoring`) |
| Width | Based on grid column span |
| Height | Hug contents (with min-height — see below) |
| Layout mode | Vertical or horizontal auto-layout (based on component spec) |
| Padding | `card-padding` from `design-tokens` (for card-type components) |

**Collapsed Frame Prevention:** Card and component frames also collapse when inner text or image layers don't have explicit sizing. Every component frame must have a `min-height` set:

| Component Type | Min-Height |
|---|---|
| Feature Card | `150px` |
| Testimonial Card | `120px` |
| Pricing Card | `200px` |
| Tab Panel content area | `200px` |
| All other card/component frames | `100px` |

**Root cause fix:** When populating content inside a component frame, ensure every text layer has `textAutoResize: "HEIGHT"` (width fixed, height grows with content) and every image placeholder has an explicit height set. These two properties are the most common cause of collapsed frames.

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

All visual properties are applied using values from `design-tokens`:

| Property | Token Applied |
|---|---|
| Text colors | `color-text-primary`, `color-text-secondary`, etc. |
| Background fills | `color-bg-page`, tint surface colors |
| Button colors | `color-cta`, `color-cta-hover`, `color-cta-active` |
| Spacing | `section-padding-y`, `space-*` scale |
| Typography | `font-heading`, `font-body`, size/weight/line-height tokens |
| Shadows | `shadow-sm`, `shadow-md`, etc. |
| Border radius | `radius-sm`, `radius-md`, etc. |

If a Trend Adaptation Brief is active, apply the token overrides from the trend brief instead of base values for any overridden tokens.

### 5.4 — Design System Reuse

Before creating any element, the agent should check for existing design system components — but only for **structural components** (buttons, cards, nav bars), not for token values.

```
1. Call search_design_system with the component type (e.g., "button", "card")
   — Limit to ONE search call per component type, max 3 calls total per session
2. If a matching library component exists → use it via use_figma (instantiate)
3. Only create from scratch when no library match exists
```

**Restriction: Do NOT search Figma for design token values.** The agent already has all token values collected from `design-tokens/token-values.md` (via the token source selected at session start). Searching Figma for colors, fonts, spacing, or other token values wastes time and risks conflicting with the already-collected tokens. Apply tokens directly from the collected values — never from Figma variable lookups during frame generation.

| Allowed | Not Allowed |
|---|---|
| `search_design_system("button")` — reuse a button component | `search_design_system("colors")` — tokens already collected |
| `search_design_system("card")` — reuse a card component | `search_design_system("typography")` — tokens already collected |
| `search_design_system("navigation")` — reuse a nav component | `get_variable_defs` for token values — tokens already collected |

---

## 6 — Generation Process

### Step 1: Verify Connection and Skills
```
Confirm remote MCP server is connected
Confirm /figma-use skill is available
```
If either is missing, stop and instruct the user to set up the Figma MCP plugin.

### Step 2: Search for Existing Components (Structural Only)
```
Call search_design_system → check for reusable structural components
(buttons, cards, nav bars) — max 3 search calls total
```
Catalog available components for reuse. Note any gaps that require building from scratch.

**Do NOT search for token values** (colors, fonts, spacing). All tokens are already collected from the token source selected at session start. Apply them directly.

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
Walk through sections → assign tint pairs per layout_patterns rules
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
     - **Collapsed frame check** (CRITICAL — see below)
  3. If mismatches found:
     - Log each mismatch with description
     - Fix via use_figma (adjust spacing, reorder, fix text, etc.)
     - Continue to next iteration
  4. If all checks pass → exit loop
```

**Collapsed Frame Detection (mandatory in every iteration):**

A "collapsed frame" is a section or component that renders with near-zero visible height despite having content inside. This is the most common visual defect and must be checked every iteration.

Detection method:
1. In the screenshot, check each section — does it occupy visible vertical space proportional to its content?
2. Any section that appears as a thin strip, blank band, or is visually absent is collapsed
3. Any card/component within a section that shows only a sliver or no visible content is collapsed

Fix procedure for collapsed sections:
```
1. Read the collapsed frame via get_design_context → check actual height
2. If height < min-height from Section 3.2/3.3 → collapsed confirmed
3. Check child layers:
   a. Text layers missing textAutoResize: "HEIGHT" → fix
   b. Image placeholders missing explicit height → set height
   c. Inner frames set to "Hug contents" with no min-height → set min-height
   d. Auto-layout spacing set to 0 or negative → fix to design token spacing
4. After fixing children, if section still below min-height → set explicit min-height
5. Re-screenshot to verify fix
```

**Rule:** Never mark the verification loop as passed if any section or card appears collapsed in the screenshot. This check takes priority over all other checks.

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

→ For Mode B code generation from either path: see `figma-code-extractor`

---

## 9 — Custom Skill Packaging (Optional)

Your skill files can be packaged as installable Figma skills for sharing across teams or the Figma Community.

### Converting figma-frame-builder to a Figma Skill

The Figma skill format uses YAML frontmatter instead of HTML comment metadata:

```markdown
---
name: me-generate-landing-page
description: "Generate a landing page frame from a content brief using the UX Skill File Architecture. Use when building new product landing pages that follow the design system standards."
compatibility: Requires the figma-use skill to be installed alongside this skill
metadata:
  mcp-server: figma
  version: 5.0
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
1. Read the content brief and parse using brief-parser rules
2. Search connected libraries for existing design system components
3. Infer page type and select section layout types from layout-patterns
4. Create the top-level frame at 1440px width
5. Build sections top to bottom, reusing library components
6. Apply design tokens from design-tokens
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

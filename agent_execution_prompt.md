<!-- meta
name: agent_execution_prompt
title: Agent Execution Prompt
version: 4.0
status: active
purpose: Master prompt templates for executing the landing page pipeline through AI coding agents, covering all three execution modes, remote Figma MCP server configuration, skills integration, and new combined workflows.
owns:
  - Mode A/B/C prompt templates
  - Shared preamble format
  - Page Blueprint format and rules
  - Agent-specific notes (Claude Code, Cursor AI, Codex)
  - Prompt modifiers (trend, variation, density, section focus)
  - Validation checklist (all modes)
  - Blueprint source-of-truth rules
  - C → A and C → Figma escalation prompts
  - Combined workflow guidance
requires:
  - workflow
depends_on:
  - content_brief
  - design_guide
  - components
  - layout_patterns
  - figma_capture
  - figma_to_code
  - html_structure
  - css_js_rules
  - trend_adaptation
  - variation_generator
referenced_by:
  - workflow
modes:
  mode_a: required
  mode_b: required
  mode_c: required
layer: orchestration
last_updated: 2026-03-25
-->

# Agent Execution Prompt — Master Templates

This file contains prompt templates for all three execution modes across all supported agents. It is the orchestration layer — it references every other skill file but defines none of their content.

→ For pipeline and mode definitions: see `workflow.md`
→ For all other skill file content: see the respective files referenced in each mode's required file list

---

## 1 — Execution Modes

| Mode | Pipeline | Input | Output | When to Use |
|---|---|---|---|---|
| **A: Brief → Figma** | Parse brief → select layout → map components → search design system → generate Figma frame → self-healing loop | Content brief + skill files | Figma design frame | Design review needed before code |
| **B: Figma → Code** | Inspect Figma via `get_design_context` → extract specs → generate production code | Figma dev link + skill files | `index.html`, `styles.css`, `script.js` | Finalized Figma frame exists |
| **C: Brief → Code** | Parse brief → select layout → map components → generate code directly | Content brief + skill files | Page Blueprint + `index.html`, `styles.css`, `script.js` | Speed matters, Figma review unnecessary |

**Combined workflows:**
- **A → correct → B:** Mode A, manual Figma edits, then Mode B against corrected frame
- **C → iterate:** Mode C, review in browser, iterate on blueprint + code
- **C → A (structured):** Escalate Mode C blueprint into a structured Figma frame via `use_figma`
- **C → Figma (quick visual):** Push Mode C HTML into Figma as editable layers via `generate_figma_design`
- **C → Figma → correct → B:** Quick visual to Figma, correct, then Mode B for final code
- **C → A → correct → B:** Full loop from quick draft to polished output

→ Full workflow definitions: see `workflow.md`

---

## 2 — Shared Preamble (All Modes)

Every execution prompt begins with this context block. Copy and adapt for the specific task.

```
I am a UX designer.

Read the skill files in the project folder:
- workflow.md          → Pipeline context and mode definitions
- content_brief.md     → How to parse the content brief
- design_guide.md      → Design tokens and brand rules
- components.md        → Component library and specs
- layout_patterns.md   → Section types and layout patterns
- html_structure.md    → HTML generation rules
- css_js_rules.md      → CSS/JS output rules and constraints

Product class prefix: {product}
```

**Optional additions to the preamble (include when relevant):**

```
Trend Adaptation Brief: {filename}       ← if trend_adaptation.md was used
Variation Spec: {filename}               ← if variation_generator.md was used; specify selected variant
```

---

## 3 — Mode A: Brief → Figma

### Purpose
Parse a marketing content brief and generate a complete landing page as a Figma design frame.

### Required Skill Files
`workflow.md`, `content_brief.md`, `design_guide.md`, `components.md`, `layout_patterns.md`, `figma_capture.md`

### MCP Requirements
Remote Figma MCP server connected (`mcp.figma.com/mcp`), `/figma-use` skill installed.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read: figma_capture.md → Figma frame generation rules

Content Brief: {brief-filename}
{Attach any reference images: hero images, product screenshots, etc.}

Using these skill files:
1. Parse the brief using content_brief.md — confirm sections and flag any content gaps
2. Select the best layout pattern from layout_patterns.md for this content and audience
3. Map each content section to components from components.md
4. Apply design tokens from design_guide.md
5. Search the connected design system for reusable components before creating new ones

Generate the landing page as a Figma design frame using use_figma
(invoke the /figma-use skill before each call).
Target Figma file: {figma-file-url}

Run the self-healing verification loop after generation:
screenshot → compare against spec → fix mismatches → repeat (max 3 iterations).

START — Deploy Figma design
```

### What the Agent Does
1. Reads all referenced skill files
2. Confirms MCP server connection and `/figma-use` skill availability
3. Parses the content brief — identifies sections, flags gaps, classifies audience
4. Selects a layout pattern — matches brief content to patterns in `layout_patterns.md`
5. Maps content to components — assigns each section a component from `components.md`
6. Searches design system for existing library components to reuse
7. Resolves design tokens — applies values from `design_guide.md`, binds to Figma variables when available
8. Pushes the assembled frame to Figma via `use_figma` following `figma_capture.md` rules
9. Runs self-healing loop — screenshots, compares, fixes, re-screenshots until passing or max iterations

### Post-Execution
- Review the generated Figma frame
- Make manual corrections if needed
- If proceeding to code: run Mode B against the corrected frame

---

## 4 — Mode B: Figma → Code

### Purpose
Take a finalized Figma design and generate production-ready HTML/CSS/JS.

### Required Skill Files
`workflow.md`, `design_guide.md`, `components.md`, `figma_to_code.md`, `html_structure.md`, `css_js_rules.md`

### MCP Requirements
Remote Figma MCP server connected.

### Critical Rule: Figma Link Is Sole Source of Truth
If Mode B follows a Mode A run (with or without manual corrections), the agent MUST treat the Figma dev link as the only source of truth. Any design decisions, layout plans, or component mappings from a prior Mode A session (or earlier in the same session) are discarded. The agent inspects the frame fresh — what's in Figma is what gets built, nothing else.

This ensures that manual corrections made between Mode A and Mode B are always respected.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- figma_to_code.md     → Figma inspection and code generation pipeline
- html_structure.md    → HTML markup rules
- css_js_rules.md      → CSS/JS output rules

Figma Dev Link: {figma-dev-link-with-node-id}

Additional context:
- Pre-exported assets are in the project assets folder: {list any pre-exported images}
- Export any remaining icons/images I missed from the Figma frame
- Compress all assets without affecting visual quality

Execute the Figma-to-Code pipeline defined in figma_to_code.md:
Phase 1: Inspect — Extract specs using get_design_context; extract variables via use_figma Plugin API script
Phase 2: Plan — Map Figma layers to HTML structure and CSS architecture
Phase 3: Generate — Produce index.html, styles.css, script.js
Phase 4: Self-review — Validate output against skill file rules

Use variable names from get_design_context style references and use_figma
variable extraction as the basis for CSS custom property naming where available.

Output: 3 files in the project output folder
START
```

### What the Agent Does
1. Connects to Figma via remote MCP server and inspects the dev link (fresh inspection — no prior assumptions)
2. Extracts all design specs via `get_design_context` following `figma_to_code.md` Phase 1
3. Extracts token values via `use_figma` Plugin API variable extraction script
4. Identifies library components via `search_design_system`
5. Identifies and exports missing assets, compresses all assets
6. Plans HTML/CSS mapping following `figma_to_code.md` Phase 2
7. Generates 3 files following `html_structure.md` and `css_js_rules.md`
8. Self-reviews following `figma_to_code.md` Phase 4
9. Optionally pushes generated HTML to Figma via `generate_figma_design` for visual comparison

### Asset Handling
- Agent checks the project assets folder first for pre-exported files
- Exports missing assets from Figma via `use_figma`
- Compresses all assets (SVG optimization, PNG/JPG compression)
- References as `./assets/{filename}` with TODO comments for uncertain mappings

→ Full asset export rules: see `figma_to_code.md` Section 3, Step 6

---

## 5 — Mode C: Brief → Code

### Purpose
Go directly from a content brief to production code, skipping Figma. Produces a Page Blueprint as the persistent source of truth.

### Required Skill Files
`workflow.md`, `content_brief.md`, `design_guide.md`, `components.md`, `layout_patterns.md`, `html_structure.md`, `css_js_rules.md`

### MCP Requirements
None — Mode C does not touch Figma unless escalating.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- html_structure.md    → HTML markup rules
- css_js_rules.md      → CSS/JS output rules

Content Brief: {brief-filename}
{Attach any reference images: hero images, product screenshots, etc.}

Using these skill files, execute the full pipeline from brief to production code:

1. Parse the brief using content_brief.md — confirm sections and flag gaps
2. Select layout pattern from layout_patterns.md
3. Map content to components from components.md
4. Apply design tokens from design_guide.md
5. Write the Page Blueprint as {product}-blueprint.md
6. Generate production code following html_structure.md and css_js_rules.md

Output: {product}-blueprint.md + index.html, styles.css, script.js in the project output folder
Asset references: ./assets/ with TODO flags for all image placeholders

START — Generate landing page code
```

### What the Agent Does
1. Reads all skill files
2. Parses the content brief — same as Mode A
3. Makes all design decisions and records them in the Page Blueprint (Section 5.1)
4. Saves the blueprint as `{product}-blueprint.md` in the project folder
5. Generates HTML, CSS, JS from the blueprint — same quality as Mode B output
6. Self-reviews against all skill file rules

### 5.1 — Page Blueprint Format

Since Mode C has no Figma frame, the blueprint serves as the persistent, editable source of truth — the text equivalent of a Figma frame.

```markdown
# Page Blueprint: {Product Name} Landing Page

**Brief:** {brief-filename}
**Generated:** {YYYY-MM-DD}
**Class prefix:** {product}-
**Trend profile:** {profile name or "Default"}
**Variant:** {variant name or "N/A"}

---

## Page Structure

### Section 1: Hero
- **Component:** {component name from components.md}
- **Variant:** {component variant}
- **Layout:** {pattern from layout_patterns.md}
- **Content:** {headline, subheadline, CTA text — actual copy from brief}
- **Image:** {asset reference or placeholder path}
- **Tokens:** {hero height, background color, text alignment}

### Section 2: {Section Name}
- **Component:** ...
- **Variant:** ...
- **Layout:** ...
- **Content:** ...
- **Tokens:** ...

[...repeat for all sections]

---

## Token Values Applied

```css
/* Key token decisions for this page */
--{product}-hero-height: 90vh;
--{product}-space-section: 80px;
--{product}-feature-columns: 3;
--{product}-radius-md: 12px;
/* ...all non-default values */
```

## Interaction Patterns
- {e.g., "Feature tabs: jQuery tab switcher per css_js_rules.md Section 7.2"}
- {e.g., "Scroll animation: fade-up per css_js_rules.md Section 7.4"}

## Asset Manifest

### Content Images (supplied by user — never agent-generated)
| Filename | Description | Source | Status |
|---|---|---|---|
| hero-dashboard.png | Product screenshot for hero | Brief attachment | Available |
| customer-logo-1.png | Partner/customer logo | Brief attachment | Available |

### Icons & Illustrations (require sourcing decision)
| Filename | Description | Method | Status |
|---|---|---|---|
| feature-icon-monitoring.svg | Server monitoring icon | Inline SVG (simple shape) | Agent will generate in code |
| feature-illustration-workflow.svg | Complex workflow diagram | Manual supply needed | TODO — add to ./assets/ |

### CSS-Only Graphics (no files needed)
| Element | Implementation |
|---|---|
| Section backgrounds | Gradient or solid via CSS custom properties |
| Section dividers | clip-path or border — defined in tokens |
| Card shadows/borders | box-shadow and border via component tokens |
```

### Blueprint Usage Rules

**During initial generation:** The agent writes the blueprint first, then generates code from it. Code matches the blueprint exactly.

**During iteration:** When changes are requested, the agent updates the blueprint *first*, then modifies code to match. The blueprint always reflects the current state.

**On session reset:** Point the agent to the blueprint:
```
Read the page blueprint: {product}-blueprint.md
Read skill files: [list]
Continue from this blueprint — apply the following changes: {edits}
Update the blueprint and regenerate the affected code files.
```

**Critical rule:** Same principle as Mode B's Figma rule — when iterating, the agent reads the current blueprint file as source of truth, not its memory of what it generated previously. If the blueprint was manually edited, those changes are respected.

### Escalation Paths from Mode C

**Path 1: Blueprint → Figma Structured Build (C → A)**
Feed the blueprint into Mode A as a pre-decided spec:

```
Read the page blueprint: {product}-blueprint.md
Read skill files: design_guide.md, components.md, layout_patterns.md, figma_capture.md

Do not re-analyze or re-decide layout.
The blueprint is the finalized design spec — generate a Figma frame
that matches it exactly using use_figma.

Search connected design system for reusable components first.
Run the self-healing verification loop after generation.

Target Figma file: {figma-file-url}
START
```

The agent skips brief-parsing and decision-making, acts purely as a renderer. Useful when:
- You iterated in Mode C and now want a visual artifact
- A stakeholder needs a Figma frame for review
- You want Figma documentation with structured layers and variable bindings

**Path 2: HTML → Figma Quick Visual (C → Figma)**
Push Mode C's rendered HTML directly into Figma:

```
The Mode C output (index.html + styles.css + script.js) is ready.

Use generate_figma_design to push the rendered HTML into Figma
as editable design layers.

Target Figma file: {figma-file-url}
START
```

Useful when:
- You want a fast visual in Figma without building structured frames
- The goal is quick stakeholder review, not extensive Figma editing
- You plan to follow up with Mode B against the corrected frame

**Path 3: Full Escalation (C → Figma → correct → B)**
Run Mode C → push HTML to Figma via `generate_figma_design` → make manual corrections → run Mode B against corrected frame.

**Path 4: Full Structured Escalation (C → A → correct → B)**
Run Mode C → escalate blueprint to Figma via `use_figma` (Path 1) → make manual corrections → run Mode B against corrected frame. Full loop from quick draft to polished output.

---

## 6 — Agent-Specific Notes

### Claude Code (Terminal Agent)
- **File access:** Reads skill files directly from the project directory
- **Figma MCP:** Install Figma plugin — bundles MCP server config + foundational skills automatically
- **Setup command:** Plugin installation is initiated from the Claude Code terminal
- **Output:** Writes files directly to the specified output folder
- **Strengths:** Full filesystem control, can run asset compression commands (`svgo`, `imagemin`), can chain operations
- **Token note:** Long pipeline runs may approach context limits; if this happens, split into separate sessions per mode

### Cursor AI (IDE Agent)
- **File access:** Reads skill files from the workspace/project folder open in the IDE
- **Figma MCP:** Install Figma plugin via agent chat — bundles MCP server config + skills
- **Output:** Creates/modifies files in the workspace; changes visible immediately
- **Strengths:** Inline editing, easy iteration, visual diff
- **Workspace tip:** Keep skill files in a `_skills/` folder to avoid clutter
- **Reference syntax:** Use `@filename` to point the agent to specific files (e.g., `@figma_to_code.md`, `@hero-image.png`)

### Codex (CLI Agent)
- **File access:** Reads from the project directory like Claude Code
- **Figma MCP:** Run `codex mcp add figma --url https://mcp.figma.com/mcp` and authenticate
- **Skills:** Install skills manually — download from Figma's mcp-server-guide repository and place in the project
- **Output:** Writes files to specified output path
- **Note:** If the agent stalls between phases, break the prompt into per-phase instructions

### All Agents — Skills Setup
The `/figma-use` foundational skill is **required** before any `use_figma` call. It contains Plugin API rules and script templates that prevent failures. When using the Figma plugin for Claude Code or Cursor, this skill is included automatically. For other agents, install manually from the Figma MCP server guide.

---

## 7 — Prompt Modifiers

Optional additions appended to any mode's prompt template.

### With Trend Adaptation
```
Also read: trend_adaptation.md

Apply the Trend Adaptation Brief: {trend-brief-filename}
Use the token overrides and layout modifications specified in the trend brief.
All brand invariants must still pass — verify after applying overrides.
```

### With Variation Selection
```
Also read: variation_generator.md

Use Variation Spec: {variation-spec-filename}
Selected variant: {variant-name} (e.g., "Trust Fortress")
Follow the section sequence and axis values defined for this variant.
```

### With Both Trend + Variation
```
Also read: trend_adaptation.md, variation_generator.md

Apply Trend Adaptation Brief: {trend-brief-filename}
Use Variation Spec: {variation-spec-filename}, selected variant: {variant-name}
Trend overrides take precedence for token values; variant defines page structure.
```

### Density Override
```
Override density profile: {breathing | standard | comprehensive}
Adjust section padding and content gap tokens per trend_adaptation.md Section 2.1.
```

### Specific Section Focus
```
Generate only the following sections (not full page):
- Hero section
- Feature grid section
- Final CTA section
Apply all skill file rules to these sections as if building the full page.
```

### With Visual Comparison (Mode B)
```
After generating code, push the rendered HTML back into Figma using
generate_figma_design for side-by-side comparison with the original frame.
Log any visual discrepancies in the deviation report.
```

---

## 8 — Validation Checklist (All Modes)

After any execution, the agent self-checks against this list.

### Code Output (Modes B and C)
- [ ] Output is exactly 3 files: `index.html`, `styles.css`, `script.js`
- [ ] All classes use BEM naming with `{product}-` prefix
- [ ] All design tokens are CSS custom properties (no hardcoded values in rulesets)
- [ ] Variable-bound Figma tokens map to matching CSS custom property names (Mode B — from get_design_context or use_figma extraction)
- [ ] Primary CTA uses `color-primary` from `design_system_prompt.md`
- [ ] Headings use `font-heading` from `design_system_prompt.md`
- [ ] Responsive breakpoints at 480px and 1024px only
- [ ] Desktop-first responsive approach
- [ ] jQuery used only for UI interactions — no other JS libraries
- [ ] Image paths use `./assets/` convention
- [ ] Uncertain image mappings have `<!-- TODO -->` comments
- [ ] Tinted sections follow matched surface/border color pair system
- [ ] No inline styles in HTML
- [ ] Heading hierarchy is correct (H1 → H2 → H3, no skips)
- [ ] Alt text on all images
- [ ] CSS file follows section ordering from `css_js_rules.md` Section 3
- [ ] JS wrapped in `$(document).ready()`

→ Full code quality rules: see `css_js_rules.md` Section 9
→ Full HTML rules: see `html_structure.md`
→ Full Figma-to-code review checklist: see `figma_to_code.md` Section 6

### Figma Output (Mode A)
- [ ] Frame pushed to correct file and page via `use_figma`
- [ ] Layer naming follows convention from `figma_capture.md` Section 4
- [ ] Design tokens match `design_guide.md` — bound to Figma variables when available
- [ ] Library components reused where possible (searched via `search_design_system`)
- [ ] All text content from brief is present — nothing omitted
- [ ] Content gaps flagged visually (red placeholders)
- [ ] Tinted section alternation follows `layout_patterns.md` Section 2.2
- [ ] Self-healing loop completed — verification summary included

→ Full Figma generation rules: see `figma_capture.md`

### Blueprint Output (Mode C)
- [ ] Blueprint saved as `{product}-blueprint.md` in project folder
- [ ] All sections from parsed brief are represented
- [ ] Component and variant selections reference `components.md` names
- [ ] Token values listed match `design_guide.md` (with trend overrides if applicable)
- [ ] Asset manifest categorizes all images into three types
- [ ] Interaction patterns reference specific `css_js_rules.md` sections

### General (All Modes)
- [ ] All referenced skill files were read before execution began
- [ ] Content brief was parsed and sections confirmed before design decisions
- [ ] If trend or variation modifiers were applied, brand invariants still pass
- [ ] Deviations from expected values are logged and presented to user
- [ ] MCP server connection verified before any Figma operations

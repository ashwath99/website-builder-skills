<!-- meta
name: agent_execution_prompt
title: Agent Execution Prompt
version: 3.0
status: active
purpose: Master prompt templates for executing the landing page pipeline through AI coding agents, covering all three execution modes and agent-specific configurations.
owns:
  - Mode A/B/C prompt templates
  - Shared preamble format
  - Page Blueprint format and rules
  - Agent-specific notes (Claude Code, Cursor AI, Codex)
  - Prompt modifiers (trend, variation, density, section focus)
  - Validation checklist (all modes)
  - Blueprint source-of-truth rules
  - C → A escalation prompt
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
last_updated: 2026-03-16
-->

# Agent Execution Prompt — Master Templates

This file contains prompt templates for all three execution modes across all supported agents. It is the orchestration layer — it references every other skill file but defines none of their content.

→ For pipeline and mode definitions: see `workflow.md`
→ For all other skill file content: see the respective files referenced in each mode's required file list

---

## 1 — Execution Modes

| Mode | Pipeline | Input | Output | When to Use |
|---|---|---|---|---|
| **A: Brief → Figma** | Parse brief → select layout → map components → generate Figma frame | Content brief + skill files | Figma design frame | Design review needed before code |
| **B: Figma → Code** | Inspect Figma → extract specs → generate production code | Figma dev link + skill files | `index.html`, `styles.css`, `script.js` | Finalized Figma frame exists |
| **C: Brief → Code** | Parse brief → select layout → map components → generate code directly | Content brief + skill files | Page Blueprint + `index.html`, `styles.css`, `script.js` | Speed matters, Figma review unnecessary |

**Combined workflows:**
- **A → correct → B:** Mode A, manual Figma edits, then Mode B against corrected frame
- **C → iterate:** Mode C, review in browser, iterate on blueprint + code
- **C → A:** Escalate Mode C blueprint into a Figma frame for visual review
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

Generate the landing page as a Figma design frame using the MCP tools
defined in figma_capture.md.
Target Figma file: {figma-file-name} > page: {page-name}

START — Deploy Figma design
```

### What the Agent Does
1. Reads all referenced skill files
2. Parses the content brief — identifies sections, flags gaps, classifies audience
3. Selects a layout pattern — matches brief content to patterns in `layout_patterns.md`
4. Maps content to components — assigns each section a component from `components.md`
5. Resolves design tokens — applies values from `design_guide.md`
6. Pushes the assembled frame to Figma via MCP following `figma_capture.md` rules

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
Phase 1: Inspect — Extract specs from the Figma dev link
Phase 2: Plan — Map Figma layers to HTML structure and CSS architecture
Phase 3: Generate — Produce index.html, styles.css, script.js
Phase 4: Self-review — Validate output against skill file rules

Output: 3 files in the project output folder
START
```

### What the Agent Does
1. Connects to Figma via MCP and inspects the dev link (fresh inspection — no prior assumptions)
2. Extracts all design specs following `figma_to_code.md` Phase 1
3. Identifies and exports missing assets, compresses all assets
4. Plans HTML/CSS mapping following `figma_to_code.md` Phase 2
5. Generates 3 files following `html_structure.md` and `css_js_rules.md`
6. Self-reviews following `figma_to_code.md` Phase 4

### Asset Handling
- Agent checks the project assets folder first for pre-exported files
- Exports missing assets from Figma via MCP
- Compresses all assets (SVG optimization, PNG/JPG compression)
- References as `./assets/{filename}` with TODO comments for uncertain mappings

→ Full asset export rules: see `figma_to_code.md` Section 3, Step 4

---

## 5 — Mode C: Brief → Code

### Purpose
Go directly from a content brief to production code, skipping Figma. Produces a Page Blueprint as the persistent source of truth.

### Required Skill Files
`workflow.md`, `content_brief.md`, `design_guide.md`, `components.md`, `layout_patterns.md`, `html_structure.md`, `css_js_rules.md`

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

**Path 1: Blueprint → Figma (C → A)**
Feed the blueprint into Mode A as a pre-decided spec:

```
Read the page blueprint: {product}-blueprint.md
Read skill files: design_guide.md, components.md, layout_patterns.md, figma_capture.md

Do not re-analyze or re-decide layout.
The blueprint is the finalized design spec — generate a Figma frame
that matches it exactly.

Target Figma file: {file} > page: {page}
START
```

The agent skips brief-parsing and decision-making, acts purely as a renderer. Useful when:
- You iterated in Mode C and now want a visual artifact
- A stakeholder needs a Figma frame for review
- You want Figma documentation for future reference

**Path 2: Full Escalation (C → A → correct → B)**
Run Mode C → iterate on blueprint + code → escalate blueprint to Figma (Path 1) → make manual corrections in Figma → run Mode B against corrected frame. Full loop from quick draft to polished output.

---

## 6 — Agent-Specific Notes

### Claude Code (Terminal Agent)
- **File access:** Reads skill files directly from the project directory
- **Figma MCP:** Connects via `npx figma-developer-mcp`; ensure bridge is running before Modes A or B
- **Output:** Writes files directly to the specified output folder
- **Strengths:** Full filesystem control, can run asset compression commands (`svgo`, `imagemin`), can chain operations
- **Token note:** Long pipeline runs may approach context limits; if this happens, split into separate sessions per mode

### Cursor AI (IDE Agent)
- **File access:** Reads skill files from the workspace/project folder open in the IDE
- **Figma MCP:** Same bridge as Claude Code; ensure running and accessible
- **Output:** Creates/modifies files in the workspace; changes visible immediately
- **Strengths:** Inline editing, easy iteration, visual diff
- **Workspace tip:** Keep skill files in a `_skills/` folder to avoid clutter
- **Reference syntax:** Use `@filename` to point the agent to specific files (e.g., `@figma_to_code.md`, `@hero-image.png`)

### Codex (CLI Agent)
- **File access:** Reads from the project directory like Claude Code
- **Figma MCP:** Verify bridge compatibility; may require explicit connection setup
- **Output:** Writes files to specified output path
- **Note:** If the agent stalls between phases, break the prompt into per-phase instructions

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

---

## 8 — Validation Checklist (All Modes)

After any execution, the agent self-checks against this list.

### Code Output (Modes B and C)
- [ ] Output is exactly 3 files: `index.html`, `styles.css`, `script.js`
- [ ] All classes use BEM naming with `{product}-` prefix
- [ ] All design tokens are CSS custom properties (no hardcoded values in rulesets)
- [ ] Primary CTA uses `#E9142B`
- [ ] Headings use ZohoPuvi font family
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
- [ ] Frame pushed to correct file and page
- [ ] Layer naming follows convention from `figma_capture.md` Section 4
- [ ] Design tokens match `design_guide.md`
- [ ] All text content from brief is present — nothing omitted
- [ ] Content gaps flagged visually (red placeholders)
- [ ] Tinted section alternation follows `layout_patterns.md` Section 2.2

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

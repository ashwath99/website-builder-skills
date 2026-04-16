---
name: execution-prompts
description: Master prompt templates for executing the landing page pipeline through AI coding agents. Contains Mode A/B/C templates, shared preamble, Page Blueprint format, prompt modifiers, and validation checklists. Use when starting any execution mode, writing agent prompts, or validating output.
version: "5.2.0"
---

# Agent Execution Prompt — Master Templates

This file contains prompt templates for all three execution modes across all supported agents. It is the orchestration layer — it references every other skill file but defines none of their content.

→ For pipeline and mode definitions: see `pipeline-workflow/SKILL.md`
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

→ Full workflow definitions: see `pipeline-workflow/SKILL.md`

---

## 2 — Shared Preamble (All Modes)

Every execution prompt begins with this context block. Copy and adapt for the specific task.

```
I am a UX designer.

Read the skill files in the project folder:
- pipeline-workflow/SKILL.md   → Pipeline context and mode definitions
- brief-parser/SKILL.md        → How to parse the content brief
- design-tokens/SKILL.md       → Design tokens and brand rules
- component-library/SKILL.md   → Component library and specs
- layout-patterns/SKILL.md     → Section types and layout patterns
- html-generator/SKILL.md      → HTML generation rules
- css-js-generator/SKILL.md    → CSS/JS output rules and constraints

Product class prefix: {product}
```

**Optional additions to the preamble (include when relevant):**

```
Trend Adaptation Brief: {filename}       ← if trend-adapter/SKILL.md was used
Variation Spec: {filename}               ← if variation-explorer/SKILL.md was used; specify selected variant
```

---

## 3 — Mode A: Brief → Figma

### Purpose
Parse a marketing content brief and generate a complete landing page as a Figma design frame.

### Required Skill Files (MUST read ALL before any Figma calls)

**CRITICAL — Read order matters. The agent MUST read these files in this order before making any `use_figma` call:**

1. `figma-frame-builder/SKILL.md` — Figma runtime rules, API pitfalls, frame construction patterns, batching strategy. **This file prevents the most common build failures. Skipping it costs 30–40% of build time in debugging.**
2. `figma-frame-builder/figma-code-patterns.md` — Copy-paste code snippets for every frame operation
3. `figma-frame-builder/layout-code-templates.md` — Layout-specific Figma code templates

Then the standard pipeline files: `pipeline-workflow/SKILL.md`, `brief-parser/SKILL.md`, `design-tokens/SKILL.md`, `component-library/SKILL.md`, `layout-patterns/SKILL.md`

### MCP Requirements
Remote Figma MCP server connected (`mcp.figma.com/mcp`), `/figma-use` skill installed.

### Prompt Template

```
[Shared Preamble — Section 2]

BEFORE ANY FIGMA CALLS — read these three files first (they contain critical API rules
that prevent the most common build failures):
- figma-frame-builder/SKILL.md          → Figma runtime rules, API pitfalls, batching
- figma-frame-builder/figma-code-patterns.md  → Code snippets for every frame operation
- figma-frame-builder/layout-code-templates.md → Layout-specific Figma code

Content Brief: {brief-filename}
{Attach any reference images: hero images, product screenshots, etc.}

Using these skill files:
1. Parse the brief using brief-parser/SKILL.md — confirm sections and flag any content gaps
2. Infer the page type and select layout types from layout-patterns/SKILL.md for this content and audience
3. Map each content section to components from component-library/SKILL.md
4. Apply design tokens from design-tokens/SKILL.md
5. Search the connected design system for reusable components before creating new ones
6. Write the Build Card to a file (MANDATORY — see Build Card section below)

Generate the landing page as a Figma design frame using use_figma
(invoke the /figma-use skill before each call).
Target Figma file: {figma-file-url}

Run the self-healing verification loop after generation:
programmatic checks + screenshot → compare → fix → repeat (max 3 iterations).

START — Deploy Figma design
```

### What the Agent Does
1. **Reads Figma skill files FIRST** — `figma-frame-builder/SKILL.md`, `figma-code-patterns.md`, `layout-code-templates.md` (these contain API rules that prevent 30–40% of build failures)
2. Reads remaining skill files (pipeline-workflow, brief-parser, design-tokens, component-library, layout-patterns)
3. Confirms MCP server connection and `/figma-use` skill availability
4. Discovers MCP tool prefix (see `figma-frame-builder/SKILL.md` Section 1)
5. Parses the content brief — identifies sections, flags gaps, classifies audience
6. Infers page type and selects layout types — reads content signals from parsed brief, maps to page type, assigns section layout types from `layout-patterns/SKILL.md`
7. Maps content to components — assigns each section a component from `component-library/SKILL.md`
8. Searches design system for existing library components to reuse (max 3 calls)
9. Resolves design tokens — applies values from `design-tokens/SKILL.md`, binds to Figma variables when available
10. **Writes the Build Card to a file** (MANDATORY — see below)
11. Pushes the assembled frame to Figma via `use_figma` following `figma-frame-builder/SKILL.md` rules
12. Runs self-healing loop — programmatic checks + screenshots, compares, fixes until passing or max iterations

### Post-Execution
- Review the generated Figma frame
- Make manual corrections if needed
- If proceeding to code: run Mode B against the corrected frame

### Build Phase Quick Reference Card (MANDATORY)

**Context window pressure is real.** Reading 8–10 skill files (200–400 lines each) plus the brief plus token-values.md can consume 40%+ of context before the build even starts. After the preparation phase (steps 1–9 above), the agent MUST write a Build Card to a file and use it as the primary reference during the build phase.

**This is not optional.** The Build Card must be written to a file (`{product}-build-card.md`) — not kept in-context only. When context compacts, in-context cards are summarized and degraded, but a file persists and can be re-read. The card must be updated after each batch with new node IDs.

**Write this card to `{product}-build-card.md` after token extraction and brief parsing, before the first `use_figma` call:**

```markdown
# Build Card — {Product Name}

## Figma Target
- File: {figma-file-url}
- Page: {page-name}
- MCP prefix: {discovered prefix, e.g., mcp__Figma__}

## Resolved Fonts
- Heading: {font-family} {styles available}
- Body: {font-family} {styles available}
- (Fallback applied: yes/no — original was {original-font})

## Resolved Colors (0-1 range for Figma)
- Primary: r={R} g={G} b={B} | hex={HEX}
- CTA: r={R} g={G} b={B} | hex={HEX}
- CTA hover: r={R} g={G} b={B} | hex={HEX}
- Text primary: r={R} g={G} b={B}
- Text secondary: r={R} g={G} b={B}
- BG page: r={R} g={G} b={B}
- BG surface: r={R} g={G} b={B}
- Tint-1 surface: r={R} g={G} b={B} | border: r={R} g={G} b={B}
- Tint-2 surface: r={R} g={G} b={B} | border: r={R} g={G} b={B}

## Spacing (px)
- Section padding Y: {N}
- Grid gutter: {N}
- Card padding: {N}
- Content max-width: {N}
- Space scale: xs={N} sm={N} md={N} lg={N} xl={N}

## Elevation
- Shadow MD: {value} (remember blendMode: 'NORMAL')
- Radius MD: {N}px

## Section Plan
| # | Section Type | Layout | Tint | Component | Min-Height |
|---|---|---|---|---|---|
| 1 | Hero | split-50 | none | Hero: Split Image | 500px |
| 2 | Trust Signals | logo-bar | tint-1 | Logo Bar | 200px |
| 3 | Feature Grid | grid-3col | none | Feature Card ×6 | 300px |
| ... | ... | ... | ... | ... | ... |

## Batching Plan
- Batch 1: Main frame + sections 1-2 → returns {mainFrameId}
- Batch 2: Sections 3-4
- Batch 3: Sections 5-6
- Batch 4: Sections 7-9
- Batch 5: Verification + fixes

## DS Components to Import
- Button Primary: key={key} (or: build from primitives)
- (list any others found via search_design_system)

## Frame-Finder Preamble
Page: "{page-name}" | Main frame ID: {to be filled after Batch 1}

## Asset Placeholders
- Hero: gray rect 1440×500 labeled "Hero Screenshot"
- Feature icons: gray circles 48×48 labeled per feature
- Logos: gray rects 120×40 per company
```

**Rules:**
- This card replaces the need to re-read full skill files during the build phase
- **Update the file after each batch** with new node IDs, section IDs, and any corrections
- After Batch 1 completes, immediately update the Main Frame ID field
- If context compacts mid-build, re-read this file to recover all state

### Session Recovery Protocol

When context compacts mid-build (long conversations, large sessions), the agent loses in-context state. This protocol prevents the most common post-compaction failure: creating a duplicate frame.

**On resuming after context compaction:**

1. **Re-read the Build Card file** (`{product}-build-card.md`) — this has all node IDs, colors, fonts, and the section plan
2. **Look up the main frame by ID, NEVER by name** — `figma.getNodeById("{MAIN_FRAME_ID}")`. Name-based search (`findOne(n => n.name === ...)`) will find the wrong frame if duplicates exist
3. **Verify frame integrity** — count the child sections in the main frame. Compare against the Build Card's section plan to determine which batches completed successfully
4. **Resume from the next incomplete batch** — don't restart from scratch

**Recovery code (paste at top of first `use_figma` call after resuming):**

```javascript
// === Session Recovery — verify frame integrity ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
await figma.setCurrentPageAsync(targetPage);

const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame {MAIN_FRAME_ID} not found — may need to rebuild" };

const sections = mainFrame.children.map(c => ({ id: c.id, name: c.name, height: c.height }));
return {
  frameId: mainFrame.id,
  frameName: mainFrame.name,
  sectionCount: sections.length,
  sections: sections,
  summary: "Frame integrity check — compare section count against Build Card"
};
// === End Recovery ===
```

**Critical rule:** If `getNodeById` returns null for the stored main frame ID, the frame was deleted or the ID is stale. Check the Build Card for the Figma file URL, open it, and verify. Do NOT create a new frame without confirming the old one is gone.

---

## 4 — Mode B: Figma → Code

### Purpose
Take a finalized Figma design and generate production-ready HTML/CSS/JS.

### Required Skill Files
`pipeline-workflow/SKILL.md`, `design-tokens/SKILL.md`, `component-library/SKILL.md`, `figma-code-extractor/SKILL.md`, `html-generator/SKILL.md`, `css-js-generator/SKILL.md`

### MCP Requirements
Remote Figma MCP server connected.

### Critical Rule: Figma Link Is Sole Source of Truth
If Mode B follows a Mode A run (with or without manual corrections), the agent MUST treat the Figma dev link as the only source of truth. Any design decisions, layout plans, or component mappings from a prior Mode A session (or earlier in the same session) are discarded. The agent inspects the frame fresh — what's in Figma is what gets built, nothing else.

This ensures that manual corrections made between Mode A and Mode B are always respected.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- figma-code-extractor/SKILL.md  → Figma inspection and code generation pipeline
- html-generator/SKILL.md        → HTML markup rules
- css-js-generator/SKILL.md      → CSS/JS output rules

Figma Dev Link: {figma-dev-link-with-node-id}

Additional context:
- Pre-exported assets are in the project assets folder: {list any pre-exported images}
- Export any remaining icons/images I missed from the Figma frame
- Compress all assets without affecting visual quality

Execute the Figma-to-Code pipeline defined in figma-code-extractor/SKILL.md:
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
2. Extracts all design specs via `get_design_context` following `figma-code-extractor/SKILL.md` Phase 1
3. Extracts token values via `use_figma` Plugin API variable extraction script
4. Identifies library components via `search_design_system`
5. Identifies and exports missing assets, compresses all assets
6. Plans HTML/CSS mapping following `figma-code-extractor/SKILL.md` Phase 2
7. Generates 3 files following `html-generator/SKILL.md` and `css-js-generator/SKILL.md`
8. Self-reviews following `figma-code-extractor/SKILL.md` Phase 4
9. Optionally pushes generated HTML to Figma via `generate_figma_design` for visual comparison

### Asset Handling
- Agent checks the project assets folder first for pre-exported files
- Exports missing assets from Figma via `use_figma`
- Compresses all assets (SVG optimization, PNG/JPG compression)
- References as `./assets/{filename}` with TODO comments for uncertain mappings

→ Full asset export rules: see `figma-code-extractor/SKILL.md` Section 3, Step 6

---

## 5 — Mode C: Brief → Code

### Purpose
Go directly from a content brief to production code, skipping Figma. Produces a Page Blueprint as the persistent source of truth.

### Required Skill Files
`pipeline-workflow/SKILL.md`, `brief-parser/SKILL.md`, `design-tokens/SKILL.md`, `component-library/SKILL.md`, `layout-patterns/SKILL.md`, `html-generator/SKILL.md`, `css-js-generator/SKILL.md`

### MCP Requirements
None — Mode C does not touch Figma unless escalating.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- html-generator/SKILL.md    → HTML markup rules
- css-js-generator/SKILL.md  → CSS/JS output rules

Content Brief: {brief-filename}
{Attach any reference images: hero images, product screenshots, etc.}

Using these skill files, execute the full pipeline from brief to production code:

1. Parse the brief using brief-parser/SKILL.md — confirm sections and flag gaps
2. Infer page type and select layout types from layout-patterns/SKILL.md
3. Map content to components from component-library/SKILL.md
4. Apply design tokens from design-tokens/SKILL.md
5. Write the Page Blueprint as {product}-blueprint.md
6. Generate production code following html-generator/SKILL.md and css-js-generator/SKILL.md

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
- **Component:** {component name from component-library/SKILL.md}
- **Variant:** {component variant}
- **Layout:** {pattern from layout-patterns/SKILL.md}
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

` ``css
/* Key token decisions for this page */
--{product}-hero-height: 90vh;
--{product}-space-section: 80px;
--{product}-feature-columns: 3;
--{product}-radius-md: 12px;
/* ...all non-default values */
` ``

## Interaction Patterns
- {e.g., "Feature tabs: jQuery tab switcher per css-js-generator/SKILL.md Section 7.2"}
- {e.g., "Scroll animation: fade-up per css-js-generator/SKILL.md Section 7.4"}

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
Read skill files: design-tokens/SKILL.md, component-library/SKILL.md, layout-patterns/SKILL.md, figma-frame-builder/SKILL.md

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

→ For agent-specific notes, prompt modifiers, and validation checklists: see prompt-templates.md

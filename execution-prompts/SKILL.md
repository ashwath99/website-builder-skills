---
name: execution-prompts
description: Master prompt templates for executing the landing page pipeline through AI coding agents. Contains Mode A/B/C templates, shared preamble, Page Blueprint format, prompt modifiers, and validation checklists. Use when starting any execution mode, writing agent prompts, or validating output.
version: "5.4.0"
---

# Agent Execution Prompt — Master Templates

Orchestration layer — references every other skill file but defines none of their content.

→ Pipeline/mode definitions: `pipeline-workflow/SKILL.md`

---

## 1 — Execution Modes

| Mode | Input → Output | When to Use |
|---|---|---|
| **A: Brief → Figma** | Content brief → Figma design frame | Design review needed before code |
| **B: Figma → Code** | Figma dev link → `index.html`, `styles.css`, `script.js` | Finalized Figma frame exists |
| **C: Brief → Code** | Content brief → Page Blueprint + HTML/CSS/JS | Speed matters, Figma unnecessary |

**Combined:** A → correct → B | C → iterate | C → A (structured) | C → Figma (quick visual) | C → Figma → correct → B | C → A → correct → B

→ Full workflow definitions: `pipeline-workflow/SKILL.md`

---

## 2 — Shared Preamble (All Modes)

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

Optional additions: `Trend Adaptation Brief: {filename}` | `Variation Spec: {filename}`

---

## 3 — Mode A: Brief → Figma

### Required Skill Files (read ALL before any Figma calls, IN THIS ORDER)

1. `figma-frame-builder/SKILL.md` — **MUST-READ-FIRST.** Skipping costs 30–40% of build time in debugging.
2. `figma-frame-builder/figma-code-patterns.md` — Copy-paste code snippets
3. `figma-frame-builder/layout-code-templates.md` — Layout-specific Figma code
4. Then: `pipeline-workflow`, `brief-parser`, `design-tokens`, `component-library`, `layout-patterns`

MCP: Remote Figma MCP server + `/figma-use` skill required.

### Prompt Template

```
[Shared Preamble — Section 2]

BEFORE ANY FIGMA CALLS — read these three files first:
- figma-frame-builder/SKILL.md
- figma-frame-builder/figma-code-patterns.md
- figma-frame-builder/layout-code-templates.md

Content Brief: {brief-filename}
{Attach any reference images}

Using these skill files:
1. Parse the brief using brief-parser/SKILL.md — confirm sections and flag gaps
2. Infer page type and select layouts from layout-patterns/SKILL.md
3. Map content to components from component-library/SKILL.md
4. Apply design tokens from design-tokens/SKILL.md
5. Search design system for reusable components
6. Write the Build Card to file (MANDATORY — see Build Card section below)

Generate the landing page as a Figma design frame using use_figma
(invoke the /figma-use skill before each call).
Target Figma file: {figma-file-url}

Run self-healing verification after generation:
programmatic checks + screenshot → compare → fix → repeat (max 3 iterations).

START — Deploy Figma design
```

### Scope

Desktop-only (1440px). No mobile/tablet breakpoints. For responsive, use Mode C.

### Placeholder Content Tagging

- Layer names: append `[placeholder]` — e.g., `Testimonial: Jane Doe, Acme Corp [placeholder]`
- Text content: wrap in curly braces — e.g., `{99.9% Uptime SLA}`
- Post-generation report must list all fabricated content with a "Fabricated Content" section.
- **Rule:** Brief content = real. Agent-generated fill content = fabricated, always tagged.

### Build Card (MANDATORY)

**Context pressure is real.** 8–10 skill files can consume 40%+ of context. After preparation, the agent MUST write a Build Card to `{product}-build-card.md` — not in-context only. Update after each batch with new node IDs.

```markdown
# Build Card — {Product Name}

## Target
File: {url} | Page: {page-name} | MCP prefix: {prefix}

## Fonts
Heading: {family} {styles} | Body: {family} {styles}
Fallback applied: yes/no (original: {font})

## Colors (hex → 0-1 for Figma)
| Token | Hex | R | G | B |
|---|---|---|---|---|
| primary | {HEX} | {R} | {G} | {B} |
| cta | {HEX} | {R} | {G} | {B} |
| cta-hover | {HEX} | {R} | {G} | {B} |
| text-primary | {HEX} | {R} | {G} | {B} |
| text-secondary | {HEX} | {R} | {G} | {B} |
| bg-page | {HEX} | {R} | {G} | {B} |
| bg-surface | {HEX} | {R} | {G} | {B} |
| surface-brand | {HEX} | {R} | {G} | {B} |
| surface-subtle | {HEX} | {R} | {G} | {B} |
| surface-inverse | {HEX} | {R} | {G} | {B} |
| button-primary-bg | {HEX} | {R} | {G} | {B} |
| button-secondary-bg | {HEX} | {R} | {G} | {B} |

## Spacing
Section padding Y: {N} | Grid gutter: {N} | Card padding: {N} | Content max-width: {N}

## Elevation
Shadow MD: blendMode NORMAL, offset 0/{N}, radius {N} | Radius MD: {N}px

## Section Plan
| # | Type | Layout | Surface | Component | Min-H |
|---|---|---|---|---|---|
| 1 | Hero | split-50 | brand | Hero: Split Image | 500 |
| ... | ... | ... | ... | ... | ... |

## Batching
Batch 1: Main frame + sections 1-2 → Batch 2: 3-4 → ... → Final: Verify

## Frame-Finder
Page: "{page-name}" | Main frame ID: {fill after Batch 1}

## DS Components
{key: description, or "build from primitives"}
```

### Session Recovery Protocol

On resuming after context compaction:

1. Re-read `{product}-build-card.md`
2. Look up main frame **by ID, NEVER by name** — `figma.getNodeById("{MAIN_FRAME_ID}")`
3. Count child sections, compare against Build Card section plan
4. Resume from next incomplete batch

```javascript
// === Session Recovery ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
await figma.setCurrentPageAsync(targetPage);
const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame {MAIN_FRAME_ID} not found — may need to rebuild" };
const sections = mainFrame.children.map(c => ({ id: c.id, name: c.name, height: c.height }));
return {
  frameId: mainFrame.id, sectionCount: sections.length, sections,
  summary: "Frame integrity check — compare section count against Build Card"
};
```

**If `getNodeById` returns null:** frame was deleted or ID is stale. Verify in Figma before creating a new frame.

---

## 4 — Mode B: Figma → Code

Required files: `pipeline-workflow`, `design-tokens`, `component-library`, `figma-code-extractor`, `html-generator`, `css-js-generator`

MCP: Remote Figma MCP server required.

**Critical Rule:** Figma link is sole source of truth. Discard any prior Mode A decisions — inspect the frame fresh.

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- figma-code-extractor/SKILL.md  → Figma inspection and code generation pipeline
- html-generator/SKILL.md        → HTML markup rules
- css-js-generator/SKILL.md      → CSS/JS output rules

Figma Dev Link: {figma-dev-link-with-node-id}

Additional context:
- Pre-exported assets in project assets folder: {list}
- Export any remaining icons/images from the Figma frame
- Compress all assets without affecting visual quality

Execute the Figma-to-Code pipeline in figma-code-extractor/SKILL.md:
Phase 1: Inspect — Extract specs via get_design_context + use_figma variables
Phase 2: Plan — Map layers to HTML/CSS
Phase 3: Generate — index.html, styles.css, script.js
Phase 4: Self-review

Output: 3 files in project output folder
START
```

### Asset Handling
Agent checks project assets folder first → exports missing from Figma → compresses all → references as `./assets/{filename}`.

→ Full rules: `figma-code-extractor/SKILL.md` Section 3, Step 6

---

## 5 — Mode C: Brief → Code

Required files: `pipeline-workflow`, `brief-parser`, `design-tokens`, `component-library`, `layout-patterns`, `html-generator`, `css-js-generator`

MCP: None (unless escalating to Figma).

### Prompt Template

```
[Shared Preamble — Section 2]

Also read:
- html-generator/SKILL.md    → HTML markup rules
- css-js-generator/SKILL.md  → CSS/JS output rules

Content Brief: {brief-filename}
{Attach any reference images}

Execute full pipeline:
1. Parse brief → confirm sections, flag gaps
2. Infer page type → select layouts
3. Map content → components
4. Apply design tokens
5. Write Page Blueprint as {product}-blueprint.md
6. Generate code per html-generator + css-js-generator

Output: {product}-blueprint.md + index.html, styles.css, script.js
START
```

### 5.1 — Page Blueprint Format

The blueprint is Mode C's persistent source of truth (equivalent of a Figma frame).

```markdown
# Page Blueprint: {Product Name} Landing Page

**Brief:** {filename} | **Generated:** {date} | **Prefix:** {product}- | **Trend:** {profile}

---

## Page Structure

### Section 1: Hero
- **Component/Variant:** {name} / {variant}
- **Layout:** {pattern}
- **Content:** {headline, subheadline, CTA text}
- **Image:** {asset ref or placeholder}
- **Tokens:** {hero height, bg color, text alignment}

[...repeat for all sections]

---

## Token Values Applied
` ``css
--{product}-hero-height: 90vh;
--{product}-space-section: 80px;
/* ...all non-default values */
` ``

## Interaction Patterns
- {e.g., "Feature tabs: jQuery tab switcher per css-js-generator §7.2"}

## Asset Manifest

| Filename | Description | Source | Status |
|---|---|---|---|
| hero-dashboard.png | Hero screenshot | Brief | Available |
| feature-icon-*.svg | Feature icons | Inline SVG | Agent generates |
```

### Blueprint Rules

- **Initial:** Write blueprint first, then generate code from it.
- **Iteration:** Update blueprint first, then modify code to match.
- **Session reset:** Point agent to blueprint file as source of truth.
- **Critical:** Like Mode B's Figma rule — read the current file, not memory of what was generated.

### Escalation Paths

**Path 1: C → A (Structured)**
```
Read {product}-blueprint.md
Read: design-tokens, component-library, layout-patterns, figma-frame-builder
Do not re-analyze. Blueprint is finalized spec — render as Figma frame exactly.
Search DS for reusable components. Run self-healing verification.
Target Figma file: {url}
START
```

**Path 2: C → Figma (Quick Visual)**
```
Use generate_figma_design to push rendered HTML into Figma as editable layers.
Target Figma file: {url}
START
```

**Path 3:** C → Figma → correct → B (quick visual then polish)
**Path 4:** C → A → correct → B (full structured loop)

→ Agent-specific notes, prompt modifiers, validation checklists: `prompt-templates.md`

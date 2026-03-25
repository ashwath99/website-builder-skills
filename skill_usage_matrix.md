<!-- meta
name: skill_usage_matrix
title: Skill File Architecture — Master Reference
version: 4.0
status: active
purpose: Central reference document for the entire UX Skill File Architecture — file inventory, usage matrix, ownership table, dependency map, Figma MCP tool mapping, and format specification.
owns:
  - File inventory and status tracking
  - Cross-file ownership table
  - Skill usage by mode matrix
  - Architecture-level decisions and conventions
  - Figma MCP tool mapping (official remote plugin)
requires: []
depends_on: []
referenced_by: []
modes:
  mode_a: optional
  mode_b: optional
  mode_c: optional
layer: context
last_updated: 2026-03-25
-->

# UX Skill File Architecture — Master Reference

> **Version:** 4.0
> **Owner:** Ashwath — UX Designer, ManageEngine
> **Purpose:** Enable AI agents to convert marketing content briefs into Figma design frames and production-ready code automatically.

---

## File Inventory

| Filename | Layer | Version | Status |
|---|---|---|---|
| `workflow.md` | Context | 4.0 | Active |
| `content_brief.md` | Design Decision | 3.0 | Active |
| `design_guide.md` | Design Decision | 3.0 | Active (token values pending) |
| `components.md` | Design Decision | 3.0 | Active |
| `layout_patterns.md` | Design Decision | 3.0 | Active |
| `figma_capture.md` | Figma | 4.0 | Active |
| `figma_to_code.md` | Figma | 4.0 | Active |
| `html_structure.md` | Code Generation | 3.0 | Active |
| `css_js_rules.md` | Code Generation | 3.0 | Active |
| `trend_adaptation.md` | Exploration | 3.0 | Active |
| `variation_generator.md` | Exploration | 3.0 | Active |
| `agent_execution_prompt.md` | Orchestration | 4.0 | Active |
| `design_system_prompt.md` | Design Decision | 1.0 | Active |

**Total: 12 files (12 active)**

### v3.0 → v4.0 Changes

| File | Change Summary |
|---|---|
| `workflow.md` | Added Figma MCP tool overview, new combined workflows (C → Figma quick visual), remote-only MCP setup, updated agent notes |
| `figma_capture.md` | Replaced 12 individual write tools with `use_figma`, added self-healing verification loop, added `/figma-use` skill dependency, dual escalation paths, Figma skill packaging guide |
| `figma_to_code.md` | Replaced 10 read tools with `get_design_context` + `search_design_system`, variable-first token mapping, `generate_figma_design` frame handling, Code Connect integration |
| `agent_execution_prompt.md` | Updated all prompt templates for new tools, added MCP requirements per mode, new escalation prompts, visual comparison modifier, updated agent setup notes |

---

## Figma MCP Server — Tool Reference

All Figma interactions use the **official remote MCP plugin** (`Figma:`). No local bridge or desktop app required.

### Available Tools

| Tool | Purpose | Used In |
|---|---|---|
| `Figma:use_figma` | **Unified write tool** — executes JavaScript via Plugin API. Creates, edits, deletes, inspects any Figma object: pages, frames, components, variants, variables, styles, text, images. Also handles screenshots (`exportAsync`), variable reads, and annotation writes. | Mode A (primary), Mode B (review fixes) |
| `Figma:get_design_context` | **Primary read tool** — returns structured representation of a frame including layout, spacing, colors, typography, component references, and a screenshot. Output is React + Tailwind by default; agent translates to vanilla HTML/CSS per skill file rules. | Mode B (primary) |
| `Figma:search_design_system` | **Library search** — finds components, variables, and styles across all connected design libraries by text query. Returns matching assets for reuse. | Mode A (before creating), Mode B (identifying components) |
| `Figma:generate_diagram` | Generates Mermaid diagrams in FigJam. | Not part of landing page pipeline |

### Tool Capabilities via `use_figma`

Since `use_figma` executes arbitrary Plugin API JavaScript, it covers capabilities that were previously separate tools:

| Task | How via `use_figma` |
|---|---|
| Create frames, set auto-layout | `figma.createFrame()`, set `layoutMode`, `primaryAxisAlignItems`, etc. |
| Set text content | `figma.createText()`, `textNode.characters = "..."` |
| Set fills, strokes | `node.fills = [{type: 'SOLID', color: {...}}]` |
| Set image fills | `figma.createImage(bytes)`, then apply as fill |
| Resize, move nodes | `node.resize(w, h)`, `node.x = ...`, `node.y = ...` |
| Clone nodes | `node.clone()` |
| Read/create variables | `figma.variables.createVariable(...)`, `figma.variables.getLocalVariables()` |
| Bind variables to nodes | `node.setBoundVariable('fills', variable)` |
| Take screenshots | `node.exportAsync({format: 'PNG', constraint: {type: 'SCALE', value: 2}})` |
| Import library components | `figma.importComponentByKeyAsync(key)` |
| Set annotations | Via Dev Mode annotation API |
| Rename layers | `node.name = "..."` |

**Rule:** Always invoke the `/figma-use` skill before calling `use_figma`. It contains Plugin API rules, gotchas, and script templates that prevent failures. Pass `skillNames: "figma-use"` on every call.

### Tools NOT Available on Official Remote Plugin

These were available on `figma-console` (desktop bridge) but are not on the official plugin. Workarounds noted.

| Lost Tool | What It Did | Workaround |
|---|---|---|
| `figma_get_variables` (with CSS export) | Extracted variables with CSS/Tailwind/Sass code generation | Write Plugin API script in `use_figma` to read variables and format as CSS |
| `figma_get_design_system_kit` | Combined tokens + components + styles in one optimized call | Use `search_design_system` + `get_design_context` across multiple calls |
| `figma_get_styles` (with code export) | Extracted styles with code generation | Read styles via `use_figma` Plugin API: `figma.getLocalPaintStyles()`, etc. |
| `figma_capture_screenshot` (instant, plugin-side) | Captured current state from plugin runtime (not cloud) | Use `use_figma` with `node.exportAsync()` — same Plugin API, same result |
| `figma_get_component_for_development` | Combined specs + rendered image in one call | Use `get_design_context` — returns richer structured data |
| `figma_post_comment` | Pinned review comments to specific nodes | **No workaround** — comment API not available via Plugin API |
| `figma_generate_component_doc` | Auto-generated component documentation markdown | **No workaround** — this was a console-exclusive feature |
| `figma_get_selection` | Read what's selected in Figma Desktop | Must provide node IDs or links manually |
| `figma_set_annotations` (dedicated) | Wrote Dev Mode annotations | Use `use_figma` to set annotations via Plugin API |
| `figma_get_design_system_summary` | Quick design system overview | Use `search_design_system` with broad query |
| FigJam tools (stickies, tables, connectors, shapes) | Full FigJam board manipulation | `use_figma` can script FigJam via Plugin API; `generate_diagram` handles Mermaid |

### Variable Extraction Pattern (use_figma)

Since there is no dedicated variable extraction tool on the official plugin, use this `use_figma` script pattern:

```javascript
// Extract all local variables and format as CSS custom properties
const collections = figma.variables.getLocalVariableCollections();
const output = [];

for (const collection of collections) {
  for (const varId of collection.variableIds) {
    const variable = figma.variables.getVariableById(varId);
    if (!variable) continue;
    
    const modeId = collection.modes[0].modeId; // default mode
    const value = variable.valuesByMode[modeId];
    
    if (variable.resolvedType === 'COLOR' && typeof value === 'object') {
      const r = Math.round(value.r * 255);
      const g = Math.round(value.g * 255);
      const b = Math.round(value.b * 255);
      const a = value.a !== undefined ? value.a : 1;
      const hex = `#${r.toString(16).padStart(2,'0')}${g.toString(16).padStart(2,'0')}${b.toString(16).padStart(2,'0')}`;
      output.push(`--${variable.name.replace(/\//g, '-')}: ${hex};`);
    } else if (variable.resolvedType === 'FLOAT') {
      output.push(`--${variable.name.replace(/\//g, '-')}: ${value}px;`);
    } else if (variable.resolvedType === 'STRING') {
      output.push(`--${variable.name.replace(/\//g, '-')}: ${value};`);
    }
  }
}

return output.join('\n');
```

This replaces `figma-console:figma_get_variables` with `enrich: true, export_formats: ['css']` for the landing page pipeline.

---

## Execution Modes

### Mode A: Brief → Figma
Generate a Figma design frame from a content brief.

### Mode B: Figma → Code
Generate production code from a finalized Figma frame.

### Mode C: Brief → Code
Generate production code directly from a content brief. Produces a Page Blueprint as the text-based source of truth.

### Combined Workflows
| Workflow | Description |
|---|---|
| **A → correct → B** | Mode A, manual Figma edits, then Mode B against corrected frame |
| **C → iterate** | Mode C, review in browser, iterate on blueprint + code |
| **C → A (structured)** | Escalate blueprint into a structured Figma frame via `use_figma` |
| **C → Figma (quick visual)** | Push rendered HTML to Figma via `generate_figma_design` for fast review |
| **C → Figma → correct → B** | Quick visual to Figma, correct, then Mode B for final code |
| **C → A → correct → B** | Full loop: quick draft to polished output |

---

## Skill Usage by Mode

**R = Required | O = Optional | — = Not used**

| Skill File | Mode A | Mode B | Mode C |
|---|---|---|---|
| `workflow.md` | R | R | R |
| `content_brief.md` | R | — | R |
| `design_guide.md` | R | R | R |
| `components.md` | R | R | R |
| `layout_patterns.md` | R | O | R |
| `figma_capture.md` | R | — | — |
| `figma_to_code.md` | — | R | — |
| `html_structure.md` | — | R | R |
| `css_js_rules.md` | — | R | R |
| `trend_adaptation.md` | O | O | O |
| `variation_generator.md` | O | — | O |
| `agent_execution_prompt.md` | R | R | R |

### MCP Requirements by Mode

| Mode | Remote MCP Server | `/figma-use` Skill | Notes |
|---|---|---|---|
| Mode A | Required | Required | All writes via `use_figma` |
| Mode B | Required | Optional | Reads via `get_design_context`; `use_figma` only if annotating during review |
| Mode C | Not needed | Not needed | No Figma interaction unless escalating |
| C → A | Required | Required | Escalation path uses `use_figma` |
| C → Figma | Required | Not needed | Uses `generate_figma_design` (no skill required) |

---

## Ownership Table (Duplication Prevention)

Each instruction, token definition, or rule exists in exactly ONE file. Other files reference it, never redefine it.

### Design Tokens & Visual Identity

| What | Owned By | Referenced By |
|---|---|---|
| Color palette (hex values, tint pairs) | `design_guide.md` | `css_js_rules.md`, `components.md`, `trend_adaptation.md` |
| Typography scale (sizes, weights, line-heights) | `design_guide.md` | `css_js_rules.md`, `components.md`, `trend_adaptation.md` |
| Spacing scale (padding, gaps, margins) | `design_guide.md` | `css_js_rules.md`, `layout_patterns.md`, `trend_adaptation.md` |
| Shadow and elevation scale | `design_guide.md` | `css_js_rules.md`, `components.md`, `trend_adaptation.md` |
| Border radius scale | `design_guide.md` | `css_js_rules.md`, `components.md`, `trend_adaptation.md` |
| CTA styles (primary, secondary, tertiary) | `design_guide.md` | `components.md`, `html_structure.md`, `css_js_rules.md` |
| Brand invariants (locked values) | `design_guide.md` | `trend_adaptation.md`, `agent_execution_prompt.md` |
| Token override protocol | `design_guide.md` | `trend_adaptation.md` |
| Production token values (85 placeholders) | `design_system_prompt.md` | `design_guide.md`, all downstream files |
| Iconography guidelines | `design_guide.md` | `components.md` |
| Image treatment standards | `design_guide.md` | `figma_to_code.md` |

### Components & Layout

| What | Owned By | Referenced By |
|---|---|---|
| Component type definitions | `components.md` | `layout_patterns.md`, `variation_generator.md`, `html_structure.md` |
| Component content slots | `components.md` | `html_structure.md`, `figma_capture.md` |
| Component configuration variants | `components.md` | `variation_generator.md`, `html_structure.md` |
| Component selection logic | `components.md` | `content_brief.md` |
| Component responsive behavior | `components.md` | `css_js_rules.md` |
| Component composition rules | `components.md` | `variation_generator.md` |
| Section-to-component mapping | `components.md` | `layout_patterns.md` |
| Page layout pattern definitions | `layout_patterns.md` | `variation_generator.md`, `agent_execution_prompt.md` |
| Section sequencing rules | `layout_patterns.md` | `variation_generator.md` |
| Grid system | `layout_patterns.md` | `css_js_rules.md` |
| Tinted section alternation rules | `layout_patterns.md` | `css_js_rules.md`, `figma_capture.md` |
| Section rhythm and visual pacing | `layout_patterns.md` | — |
| Bento grid layout definition | `layout_patterns.md` | `css_js_rules.md`, `trend_adaptation.md` |
| Pattern selection logic | `layout_patterns.md` | `agent_execution_prompt.md` |

### Content & Brief

| What | Owned By | Referenced By |
|---|---|---|
| Brief parsing rules | `content_brief.md` | `agent_execution_prompt.md` |
| Section type identification | `content_brief.md` | `layout_patterns.md`, `components.md` |
| Content gap detection and severity | `content_brief.md` | `agent_execution_prompt.md`, `figma_capture.md` |
| Audience classification logic | `content_brief.md` | `layout_patterns.md`, `trend_adaptation.md`, `variation_generator.md` |
| Parsed brief output format | `content_brief.md` | `agent_execution_prompt.md` |

### Code Output

| What | Owned By | Referenced By |
|---|---|---|
| CSS custom property naming syntax | `css_js_rules.md` | `figma_to_code.md`, `trend_adaptation.md` |
| 3-file output format | `css_js_rules.md` | `agent_execution_prompt.md` |
| Responsive breakpoints (480/1024) | `css_js_rules.md` | `trend_adaptation.md`, `agent_execution_prompt.md` |
| Desktop-first responsive approach | `css_js_rules.md` | `agent_execution_prompt.md` |
| jQuery interaction patterns | `css_js_rules.md` | `trend_adaptation.md`, `components.md` |
| CSS file organization | `css_js_rules.md` | — |
| Animation and transition standards | `css_js_rules.md` | `trend_adaptation.md` |
| Code quality rules | `css_js_rules.md` | `agent_execution_prompt.md` |
| Tinted section CSS implementation | `css_js_rules.md` | — |
| Bento grid CSS implementation | `css_js_rules.md` | — |
| BEM class naming convention | `html_structure.md` | `css_js_rules.md` |
| Product class prefix system | `html_structure.md` | `css_js_rules.md`, `agent_execution_prompt.md` |
| Section markup patterns | `html_structure.md` | `figma_to_code.md` |
| Heading hierarchy rules | `html_structure.md` | `agent_execution_prompt.md` |
| Accessibility markup | `html_structure.md` | — |
| Image tag conventions | `html_structure.md` | `css_js_rules.md`, `agent_execution_prompt.md` |
| HTML comment convention | `html_structure.md` | `figma_to_code.md` |
| Asset path convention (./assets/) | `css_js_rules.md` | `html_structure.md`, `agent_execution_prompt.md` |

### Figma

| What | Owned By | Referenced By |
|---|---|---|
| Figma frame generation workflow | `figma_capture.md` | `agent_execution_prompt.md` |
| Layer naming convention | `figma_capture.md` | `figma_to_code.md` |
| Frame structure and hierarchy | `figma_capture.md` | — |
| MCP write workflow (via `use_figma`) | `figma_capture.md` | `agent_execution_prompt.md` |
| Self-healing verification loop | `figma_capture.md` | `agent_execution_prompt.md` |
| Design system reuse workflow | `figma_capture.md` | `figma_to_code.md` |
| C → A escalation (blueprint → Figma) | `figma_capture.md` | `agent_execution_prompt.md` |
| C → Figma escalation (HTML → Figma) | `figma_capture.md` | `agent_execution_prompt.md` |
| Figma skill packaging guide | `figma_capture.md` | — |
| Figma inspection workflow | `figma_to_code.md` | `agent_execution_prompt.md` |
| Spec extraction rules | `figma_to_code.md` | — |
| Asset export and compression | `figma_to_code.md` | `agent_execution_prompt.md` |
| MCP tool mapping for reading | `figma_to_code.md` | — |
| 4-phase pipeline (inspect → plan → generate → review) | `figma_to_code.md` | `agent_execution_prompt.md` |
| Non-standard frame handling | `figma_to_code.md` | — |
| `generate_figma_design` frame handling | `figma_to_code.md` | — |
| Code Connect integration | `figma_to_code.md` | — |
| Variable extraction script (use_figma) | Master Reference | `figma_capture.md`, `figma_to_code.md` |

### Exploration

| What | Owned By | Referenced By |
|---|---|---|
| Trend dimension definitions (7 dims) | `trend_adaptation.md` | `variation_generator.md` |
| Named trend profiles | `trend_adaptation.md` | `agent_execution_prompt.md` |
| Token override sheet format | `trend_adaptation.md` | `design_guide.md`, `css_js_rules.md` |
| Brand invariant gate (verification) | `trend_adaptation.md` | `agent_execution_prompt.md` |
| Trend discovery process | `trend_adaptation.md` | — |
| Audience-to-trend alignment | `trend_adaptation.md` | — |
| Variation axis definitions (6 axes) | `variation_generator.md` | `agent_execution_prompt.md` |
| Variant spec output format | `variation_generator.md` | `agent_execution_prompt.md` |
| Variation constraint filters | `variation_generator.md` | — |
| Minimum-difference rule (≥2 axes) | `variation_generator.md` | — |

### Orchestration

| What | Owned By | Referenced By |
|---|---|---|
| Mode A/B/C prompt templates | `agent_execution_prompt.md` | `workflow.md` |
| Shared preamble format | `agent_execution_prompt.md` | — |
| Page Blueprint format and rules | `agent_execution_prompt.md` | `workflow.md` |
| Agent-specific notes | `agent_execution_prompt.md` | — |
| Prompt modifiers | `agent_execution_prompt.md` | — |
| Validation checklists | `agent_execution_prompt.md` | — |
| Pipeline phases and reading order | `workflow.md` | All files |
| Execution mode definitions | `workflow.md` | `agent_execution_prompt.md` |
| Combined workflow definitions | `workflow.md` | `agent_execution_prompt.md` |
| Exploration layer insertion point | `workflow.md` | `trend_adaptation.md`, `variation_generator.md` |
| Ownership principle | `workflow.md` | All files |
| Figma MCP tool mapping | Master Reference | All Figma-layer files |

---

## File Dependency Map

```
CONTEXT LAYER
  workflow.md (read first — always)

DESIGN DECISION LAYER
  content_brief.md    ← requires: workflow
  design_guide.md     ← requires: workflow
  components.md       ← requires: workflow, design_guide
  layout_patterns.md  ← requires: workflow, design_guide, components

FIGMA LAYER
  figma_capture.md    ← requires: workflow, design_guide, components, layout_patterns
  figma_to_code.md    ← requires: workflow, design_guide, components

CODE GENERATION LAYER
  html_structure.md   ← requires: workflow, design_guide, components
  css_js_rules.md     ← requires: workflow, design_guide

EXPLORATION LAYER (optional, pre-mode)
  trend_adaptation.md     ← requires: workflow, design_guide
  variation_generator.md  ← requires: workflow, content_brief, components, layout_patterns

ORCHESTRATION LAYER (read last)
  agent_execution_prompt.md ← requires: workflow; depends on all others
```

---

## Skill File Format

Every skill file uses the HTML comment metadata block format:

```html
<!-- meta
name: {unique_identifier}
title: {Human-Readable Title}
version: {major.minor}
status: {active | parked | deprecated}
purpose: {One-sentence description}
owns:
  - {Thing this file authoritatively defines}
  - {Another thing}
requires:
  - {file that must be read before this one}
depends_on:
  - {file this one references}
referenced_by:
  - {file that references this one}
modes:
  mode_a: {required | optional | not_used}
  mode_b: {required | optional | not_used}
  mode_c: {required | optional | not_used}
layer: {context | design_decision | figma | code_generation | exploration | orchestration}
last_updated: {YYYY-MM-DD}
-->
```

**Rendering behavior:**
- GitHub preview: metadata hidden, markdown body renders normally
- VS Code preview: metadata hidden, markdown body renders normally
- Code editor: metadata visible as readable raw text
- AI agent: parses fields from inside the comment block

### Figma Skill Format (Optional Packaging)

For packaging skill files as installable Figma MCP skills:

```markdown
---
name: me-{skill-name}
description: "{What it does and when to use it}"
compatibility: Requires the figma-use skill
metadata:
  mcp-server: figma
  version: {version}
  author: ManageEngine UX
---
```

→ Full packaging guide: see `figma_capture.md` Section 9

---

## Agent Reading Protocol

When an agent starts a session:

1. Read `workflow.md` first (always)
2. Identify the active execution mode (A, B, or C)
3. Read the metadata block of all files in the project folder
4. Load only files where `modes.{active_mode}` is `required` or `optional`
5. For `optional` files, load only if the user's prompt references them
6. For Figma modes (A or B): confirm MCP server connection before proceeding

This minimizes token usage by avoiding unnecessary file reads.

---

## Supported Agents

| Agent | Type | File Access | Figma MCP Setup |
|---|---|---|---|
| Claude Code | Terminal agent | Filesystem direct | Install Figma plugin (bundles MCP config + skills) |
| Cursor AI | IDE agent | Workspace folder | Install Figma plugin via agent chat |
| Codex | CLI agent | Project directory | `codex mcp add figma --url https://mcp.figma.com/mcp` + manual skill install |

All three agents are interchangeable across all pipeline stages.

---

## Design System Standards

| Standard | Value | Defined In |
|---|---|---|
| Primary CTA | `#E9142B` | `design_guide.md` |
| Heading font | ZohoPuvi (Zoho CDN) | `design_guide.md` |
| Code stack | HTML5, CSS3, jQuery | `css_js_rules.md` |
| Class naming | BEM with `{product}-` prefix | `html_structure.md` |
| Output files | `index.html`, `styles.css`, `script.js` | `css_js_rules.md` |
| Responsive | Desktop-first, 480px + 1024px | `css_js_rules.md` |
| Images | `./assets/` with TODO flags | `css_js_rules.md` |
| Token format | CSS custom properties `--{product}-*` | `css_js_rules.md` |
| Figma MCP | Official remote plugin (`Figma:`) | `workflow.md` |
| Figma write tool | `Figma:use_figma` with `/figma-use` skill | `figma_capture.md` |
| Figma read tool | `Figma:get_design_context` | `figma_to_code.md` |

---

## Pending Actions

| Action | Priority | Notes |
|---|---|---|
| Fill values in `design_system_prompt.md` per product | High | 85 placeholder tokens to fill — one file controls all |
| Test Mode A with `use_figma` end-to-end | High | New tool, untested in real pipeline run |
| Test C → Figma path via `generate_figma_design` | High | New workflow, untested |
| Build reusable `use_figma` scripts for common operations | Medium | Variable extraction, screenshot, component instantiation |
| Test Mode C with a real brief | Medium | Blueprint flow previously untested |
| Package Figma-facing skill files as Figma Community skills | Low | See `figma_capture.md` Section 9 |
| Refresh trend profiles periodically | Low | Review every 6–12 months |
| Remove `figma-console` MCP connector | Done | Replaced by official `Figma:` remote plugin |
| Unpark `design_system_prompt.md` | Done | Now active at v1.0 — single source for all 85 placeholder tokens |

---
name: master-reference
description: Central reference for the website builder skill architecture. Contains file inventory, cross-skill ownership table, usage matrix by mode, Figma MCP tool mapping, dependency map, and design system standards. Use when checking which skills are needed for a mode, verifying ownership of a rule, or looking up Figma MCP tool usage.
version: "5.0.6"
---

# UX Skill File Architecture — Master Reference

> **Version:** 5.0
> **Owner:** Ashwath
> **Purpose:** Enable AI agents to convert marketing content briefs into Figma design frames and production-ready code automatically.

---

## File Inventory

| Skill Folder | SKILL.md | Layer | Version | Status |
|---|---|---|---|---|
| `pipeline-workflow` | SKILL.md | Context | 5.0 | Active |
| `brief-parser` | SKILL.md | Design Decision | 5.0 | Active |
| `design-tokens` | SKILL.md | Design Decision | 5.0 | Active (token values pending) |
| `component-library` | SKILL.md | Design Decision | 5.0 | Active |
| `layout-patterns` | SKILL.md | Design Decision | 5.0 | Active |
| `figma-frame-builder` | SKILL.md | Figma | 5.0 | Active |
| `figma-code-extractor` | SKILL.md | Figma | 5.0 | Active |
| `html-generator` | SKILL.md | Code Generation | 5.0 | Active |
| `css-js-generator` | SKILL.md | Code Generation | 5.0 | Active |
| `trend-adapter` | SKILL.md | Exploration | 5.0 | Active |
| `variation-explorer` | SKILL.md | Exploration | 5.0 | Active |
| `execution-prompts` | SKILL.md | Orchestration | 5.0 | Active |
| `master-reference` | SKILL.md | Context | 5.0 | Active |
| `design-tokens` | token-values.md | Design Decision | 5.0 | Active |

**Total: 13 skills (13 active)**

### v4.0 → v5.0 Changes

| Skill | Change Summary |
|---|---|
| `pipeline-workflow` | Updated for YAML frontmatter format, enhanced Figma MCP tool overview, new combined workflows (C → Figma quick visual), remote-only MCP setup |
| `figma-frame-builder` | Transitioned to SKILL.md format with YAML frontmatter, added Plugin API rules and gotchas reference, `/figma-use` skill dependency documentation |
| `figma-code-extractor` | Transitioned to SKILL.md format with YAML frontmatter, variable-first token mapping, `generate_figma_design` frame handling, Code Connect integration |
| `execution-prompts` | Updated all prompt templates for YAML-based skill files, added MCP requirements per mode, new escalation prompts, visual comparison modifier |

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

This replaces the legacy variable extraction tool for the landing page pipeline.

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

| Skill | Mode A | Mode B | Mode C |
|---|---|---|---|
| `pipeline-workflow` | R | R | R |
| `brief-parser` | R | — | R |
| `design-tokens` | R | R | R |
| `component-library` | R | R | R |
| `layout-patterns` | R | O | R |
| `figma-frame-builder` | R | — | — |
| `figma-code-extractor` | — | R | — |
| `html-generator` | — | R | R |
| `css-js-generator` | — | R | R |
| `trend-adapter` | O | O | O |
| `variation-explorer` | O | — | O |
| `execution-prompts` | R | R | R |

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

Each instruction, token definition, or rule exists in exactly ONE skill. Other skills reference it, never redefine it.

### Design Tokens & Visual Identity

| What | Owned By | Referenced By |
|---|---|---|
| Color palette (hex values, tint pairs) | `design-tokens` | `css-js-generator`, `component-library`, `trend-adapter` |
| Typography scale (sizes, weights, line-heights) | `design-tokens` | `css-js-generator`, `component-library`, `trend-adapter` |
| Spacing scale (padding, gaps, margins) | `design-tokens` | `css-js-generator`, `layout-patterns`, `trend-adapter` |
| Shadow and elevation scale | `design-tokens` | `css-js-generator`, `component-library`, `trend-adapter` |
| Border radius scale | `design-tokens` | `css-js-generator`, `component-library`, `trend-adapter` |
| CTA styles (primary, secondary, tertiary) | `design-tokens` | `component-library`, `html-generator`, `css-js-generator` |
| Brand invariants (locked values) | `design-tokens` | `trend-adapter`, `execution-prompts` |
| Token override protocol | `design-tokens` | `trend-adapter` |
| Production token values (98 placeholders) | `design-tokens/token-values.md` | `design-tokens`, all downstream skills |
| Token ingestion protocols (7 sources) | `design-tokens/token-sources.md` | `pipeline-workflow`, `design-tokens` |
| Token source detection logic | `pipeline-workflow` | All modes |
| Iconography guidelines | `design-tokens` | `component-library` |
| Image treatment standards | `design-tokens` | `figma-code-extractor` |

### Components & Layout

| What | Owned By | Referenced By |
|---|---|---|
| Component type definitions | `component-library` | `layout-patterns`, `variation-explorer`, `html-generator` |
| Component content slots | `component-library` | `html-generator`, `figma-frame-builder` |
| Component configuration variants | `component-library` | `variation-explorer`, `html-generator` |
| Component selection logic | `component-library` | `brief-parser` |
| Component responsive behavior | `component-library` | `css-js-generator` |
| Component composition rules | `component-library` | `variation-explorer` |
| Section-to-component mapping | `component-library` | `layout-patterns` |
| Section layout type definitions (split, grid, sidebar, linear, specialty) | `layout-patterns` | `variation-explorer`, `execution-prompts`, `html-generator` |
| Page type inference logic (content signals → page type) | `layout-patterns` | `brief-parser`, `execution-prompts` |
| Page assembly logic (section applicability per page type) | `layout-patterns` | `variation-explorer`, `execution-prompts` |
| Universal sequencing rules | `layout-patterns` | `variation-explorer`, `figma-frame-builder` |
| Grid system | `layout-patterns` | `css-js-generator` |
| Tinted section alternation rules | `layout-patterns` | `css-js-generator`, `figma-frame-builder` |
| Section rhythm and visual pacing | `layout-patterns` | — |
| Bento grid layout definition | `layout-patterns` | `css-js-generator`, `trend-adapter` |
| Step flow layout definition | `layout-patterns` | `html-generator` |

### Content & Brief

| What | Owned By | Referenced By |
|---|---|---|
| Brief parsing rules | `brief-parser` | `execution-prompts` |
| Section type identification | `brief-parser` | `layout-patterns`, `component-library` |
| Content gap detection and severity | `brief-parser` | `execution-prompts`, `figma-frame-builder` |
| Audience classification logic | `brief-parser` | `layout-patterns`, `trend-adapter`, `variation-explorer` |
| Parsed brief output format | `brief-parser` | `execution-prompts` |

### Code Output

| What | Owned By | Referenced By |
|---|---|---|
| CSS custom property naming syntax | `css-js-generator` | `figma-code-extractor`, `trend-adapter` |
| 3-file output format | `css-js-generator` | `execution-prompts` |
| Responsive breakpoints (480/1024) | `css-js-generator` | `trend-adapter`, `execution-prompts` |
| Desktop-first responsive approach | `css-js-generator` | `execution-prompts` |
| jQuery interaction patterns | `css-js-generator` | `trend-adapter`, `component-library` |
| CSS file organization | `css-js-generator` | — |
| Animation and transition standards | `css-js-generator` | `trend-adapter` |
| Code quality rules | `css-js-generator` | `execution-prompts` |
| Tinted section CSS implementation | `css-js-generator` | — |
| Bento grid CSS implementation | `css-js-generator` | — |
| BEM class naming convention | `html-generator` | `css-js-generator` |
| Product class prefix system | `html-generator` | `css-js-generator`, `execution-prompts` |
| Section markup patterns | `html-generator` | `figma-code-extractor` |
| Heading hierarchy rules | `html-generator` | `execution-prompts` |
| Accessibility markup | `html-generator` | — |
| Image tag conventions | `html-generator` | `css-js-generator`, `execution-prompts` |
| HTML comment convention | `html-generator` | `figma-code-extractor` |
| Asset path convention (./assets/) | `css-js-generator` | `html-generator`, `execution-prompts` |

### Figma

| What | Owned By | Referenced By |
|---|---|---|
| Figma frame generation workflow | `figma-frame-builder` | `execution-prompts` |
| Layer naming convention | `figma-frame-builder` | `figma-code-extractor` |
| Frame structure and hierarchy | `figma-frame-builder` | — |
| MCP write workflow (via `use_figma`) | `figma-frame-builder` | `execution-prompts` |
| Self-healing verification loop | `figma-frame-builder` | `execution-prompts` |
| Design system reuse workflow | `figma-frame-builder` | `figma-code-extractor` |
| C → A escalation (blueprint → Figma) | `figma-frame-builder` | `execution-prompts` |
| C → Figma escalation (HTML → Figma) | `figma-frame-builder` | `execution-prompts` |
| Figma skill packaging guide | `figma-frame-builder` | — |
| Figma inspection workflow | `figma-code-extractor` | `execution-prompts` |
| Spec extraction rules | `figma-code-extractor` | — |
| Asset export and compression | `figma-code-extractor` | `execution-prompts` |
| MCP tool mapping for reading | `figma-code-extractor` | — |
| 4-phase pipeline (inspect → plan → generate → review) | `figma-code-extractor` | `execution-prompts` |
| Non-standard frame handling | `figma-code-extractor` | — |
| `generate_figma_design` frame handling | `figma-code-extractor` | — |
| Code Connect integration | `figma-code-extractor` | — |
| Variable extraction script (use_figma) | Master Reference | `figma-frame-builder`, `figma-code-extractor` |

### Exploration

| What | Owned By | Referenced By |
|---|---|---|
| Trend dimension definitions (7 dims) | `trend-adapter` | `variation-explorer` |
| Named trend profiles | `trend-adapter` | `execution-prompts` |
| Token override sheet format | `trend-adapter` | `design-tokens`, `css-js-generator` |
| Brand invariant gate (verification) | `trend-adapter` | `execution-prompts` |
| Trend discovery process | `trend-adapter` | — |
| Audience-to-trend alignment | `trend-adapter` | — |
| Variation axis definitions (6 axes) | `variation-explorer` | `execution-prompts` |
| Variant spec output format | `variation-explorer` | `execution-prompts` |
| Variation constraint filters | `variation-explorer` | — |
| Minimum-difference rule (≥2 axes) | `variation-explorer` | — |

### Orchestration

| What | Owned By | Referenced By |
|---|---|---|
| Mode A/B/C prompt templates | `execution-prompts` | `pipeline-workflow` |
| Shared preamble format | `execution-prompts` | — |
| Page Blueprint format and rules | `execution-prompts` | `pipeline-workflow` |
| Agent-specific notes | `execution-prompts` | — |
| Prompt modifiers | `execution-prompts` | — |
| Validation checklists | `execution-prompts` | — |
| Pipeline phases and reading order | `pipeline-workflow` | All skills |
| Execution mode definitions | `pipeline-workflow` | `execution-prompts` |
| Combined workflow definitions | `pipeline-workflow` | `execution-prompts` |
| Exploration layer insertion point | `pipeline-workflow` | `trend-adapter`, `variation-explorer` |
| Ownership principle | `pipeline-workflow` | All skills |
| Figma MCP tool mapping | Master Reference | All Figma-layer skills |

---

## Skill Dependency Map

```
CONTEXT LAYER
  pipeline-workflow/SKILL.md (read first — always)

DESIGN DECISION LAYER
  brief-parser/SKILL.md           ← requires: pipeline-workflow
  design-tokens/SKILL.md          ← requires: pipeline-workflow
  component-library/SKILL.md      ← requires: pipeline-workflow, design-tokens
  layout-patterns/SKILL.md        ← requires: pipeline-workflow, design-tokens, component-library

FIGMA LAYER
  figma-frame-builder/SKILL.md    ← requires: pipeline-workflow, design-tokens, component-library, layout-patterns
  figma-code-extractor/SKILL.md   ← requires: pipeline-workflow, design-tokens, component-library

CODE GENERATION LAYER
  html-generator/SKILL.md         ← requires: pipeline-workflow, design-tokens, component-library
  css-js-generator/SKILL.md       ← requires: pipeline-workflow, design-tokens

EXPLORATION LAYER (optional, pre-mode)
  trend-adapter/SKILL.md          ← requires: pipeline-workflow, design-tokens
  variation-explorer/SKILL.md     ← requires: pipeline-workflow, brief-parser, component-library, layout-patterns

ORCHESTRATION LAYER (read last)
  execution-prompts/SKILL.md      ← requires: pipeline-workflow; depends on all others
```

---

## Skill File Format (v5.0)

Every skill file uses the YAML frontmatter format with Markdown body:

```yaml
---
name: {skill-id}
description: {Human-readable description in third person, max 1024 chars}
version: "5.0"
---

# Skill Title

Markdown content follows...
```

**Field specifications:**
- `name`: lowercase, hyphens, max 64 characters. Must be unique across the architecture.
- `description`: third person, action-oriented, max 1024 characters. Describe what the skill does and when to use it.
- `version`: optional, semantic versioning (e.g., "5.0"). Omit if v5.0 is assumed.

**Rendering behavior:**
- GitHub preview: frontmatter hidden, markdown body renders normally
- VS Code preview: frontmatter hidden, markdown body renders normally
- Code editor: frontmatter visible as readable YAML text
- AI agent: parses YAML fields from frontmatter block

---

## Agent Reading Protocol

When an agent starts a session:

1. Read `pipeline-workflow/SKILL.md` first (always)
2. Identify the active execution mode (A, B, or C)
3. Read the YAML frontmatter of all skills in the project folder
4. Load only skills where mode usage is marked `required` or `optional`
5. For `optional` skills, load only if the user's prompt references them
6. For Figma modes (A or B): confirm MCP server connection before proceeding

This minimizes token usage by avoiding unnecessary file reads.

---

## Supported Agents

| Agent | Type | File Access | Figma MCP Setup |
|---|---|---|---|
| Claude Code | Terminal agent | Filesystem direct | Install Figma plugin (bundles MCP config + skills) |
| Cursor AI | IDE agent | Workspace folder | Install Figma plugin via agent chat |
| VS Code / GitHub Copilot | IDE agent | Workspace folder | Configure MCP server in `.vscode/mcp.json` |
| Antigravity (Google) | Cloud agent | Project directory | Configure MCP via project settings |
| Codex CLI | CLI agent | Project directory | `codex mcp add figma --url https://mcp.figma.com/mcp` + manual skill install |
| Gemini CLI | CLI agent | Project directory | Configure MCP server in settings |

All six agents are interchangeable across all pipeline stages.

---

## Design System Standards

| Standard | Value | Defined In |
|---|---|---|
| Primary CTA | Per `design-tokens/token-values.md` | `design-tokens/SKILL.md` |
| Heading font | Per `design-tokens/token-values.md` | `design-tokens/SKILL.md` |
| Code stack | HTML5, CSS3, jQuery | `css-js-generator/SKILL.md` |
| Class naming | BEM with `{product}-` prefix | `html-generator/SKILL.md` |
| Output files | `index.html`, `styles.css`, `script.js` | `css-js-generator/SKILL.md` |
| Responsive | Desktop-first, 480px + 1024px | `css-js-generator/SKILL.md` |
| Images | `./assets/` with TODO flags | `css-js-generator/SKILL.md` |
| Token format | CSS custom properties `--{product}-*` | `css-js-generator/SKILL.md` |
| Figma MCP | Official remote plugin (`Figma:`) | `pipeline-workflow/SKILL.md` |
| Figma write tool | `Figma:use_figma` with `/figma-use` skill | `figma-frame-builder/SKILL.md` |
| Figma read tool | `Figma:get_design_context` | `figma-code-extractor/SKILL.md` |

---

## Pending Actions

| Action | Priority | Notes |
|---|---|---|
| Fill values in `design-tokens/token-values.md` per product | High | 85 placeholder tokens to fill — one file controls all |
| Test Mode A with `use_figma` end-to-end | High | New tool, untested in real pipeline run |
| Test C → Figma path via `generate_figma_design` | High | New workflow, untested |
| Build reusable `use_figma` scripts for common operations | Medium | Variable extraction, screenshot, component instantiation |
| Test Mode C with a real brief | Medium | Blueprint flow previously untested |
| Refresh trend profiles periodically | Low | Review every 6–12 months |

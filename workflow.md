---
name: workflow
title: "Workflow"
version: 4.0
status: active
purpose: >
  Establish the execution pipeline, define modes, and specify which skill files
  are read for each task. Updated for remote Figma MCP server, unified tool set,
  and new combined workflows.
owns:
  - "Pipeline phases and sequencing"
  - "Execution mode definitions (A, B, C)"
  - "Combined workflow definitions"
  - "Skill file reading order"
  - "Exploration layer insertion point"
  - "Figma MCP connection requirements"
requires: []
depends_on: []
referenced_by:
  - content_brief
  - design_guide
  - components
  - layout_patterns
  - figma_capture
  - figma_to_code
  - html_structure
  - css_js_rules
  - agent_execution_prompt
  - trend_adaptation
  - variation_generator
modes:
  mode_a: required
  mode_b: required
  mode_c: required
layer: context
last_updated: 2026-03-25
---

# Workflow — Pipeline Context

Read this file first in every session.

---

## Pipeline Overview

This skill file system enables AI agents to convert marketing content briefs into Figma design frames and/or production-ready landing page code. The pipeline is modular — agents read only the files needed for the active execution mode.

### Figma MCP Server

All Figma interactions use the **remote MCP server** (`mcp.figma.com/mcp`) by default. No local bridge or desktop app is required for most workflows.

| Capability | Tool | Notes |
|---|---|---|
| Write to Figma canvas | `use_figma` | Requires `/figma-use` skill. Creates, edits, deletes frames, components, variables, styles, text, images. |
| Read design context | `get_design_context` | Returns structured layout, spacing, colors, typography from a frame or selection. |
| Read tokens & variables | `use_figma` (Plugin API script) | Extracts variables and formats as CSS custom properties. See Master Reference for script. |
| Search design system | `search_design_system` | Finds components, variables, styles across connected libraries. |
| Push HTML to Figma | `generate_figma_design` | Converts rendered HTML into editable Figma layers. |

→ Full tool details: see `figma_capture.md` Section 2 and `figma_to_code.md` Section 2

---

## Execution Modes

### Mode A: Brief → Figma

**Goal:** Generate a Figma design frame from a content brief.

**Pipeline:**
```
Content Brief
  → Parse brief (content_brief.md)
  → Select layout (layout_patterns.md)
  → Map components (components.md)
  → Apply tokens (design_guide.md)
  → Search design system for reusable components
  → Push to Figma via use_figma (figma_capture.md)
  → Self-healing verification loop (screenshot → compare → fix)
```

**Required skill files:**
- `workflow.md`
- `content_brief.md`
- `design_guide.md`
- `components.md`
- `layout_patterns.md`
- `figma_capture.md`
- `agent_execution_prompt.md`

**Optional:**
- `trend_adaptation.md` — if applying a trend profile
- `variation_generator.md` — if exploring multiple arrangements before committing

**MCP requirements:** Remote server connected, `/figma-use` skill installed.

---

### Mode B: Figma → Code

**Goal:** Generate production code from a finalized Figma frame.

**Pipeline:**
```
Figma Dev Link (or desktop selection)
  → Inspect frame via get_design_context (figma_to_code.md)
  → Extract variables via use_figma Plugin API script
  → Identify library components via search_design_system
  → Extract specs + export assets
  → Generate HTML (html_structure.md)
  → Generate CSS/JS (css_js_rules.md)
  → Self-review (with optional visual comparison via generate_figma_design)
```

**Required skill files:**
- `workflow.md`
- `design_guide.md`
- `components.md`
- `figma_to_code.md`
- `html_structure.md`
- `css_js_rules.md`
- `agent_execution_prompt.md`

**Optional:**
- `trend_adaptation.md` — if a trend override sheet was produced earlier and should inform code token values

**Critical rule:** The Figma dev link is the sole source of truth. If Mode B follows Mode A (with or without manual corrections), the agent inspects the frame fresh — no prior assumptions from Mode A carry over.

**MCP requirements:** Remote server connected. `/figma-use` skill needed only if annotating the frame during review.

---

### Mode C: Brief → Code

**Goal:** Generate production code directly from a content brief, skipping Figma.

**Pipeline:**
```
Content Brief
  → Parse brief (content_brief.md)
  → Select layout (layout_patterns.md)
  → Map components (components.md)
  → Apply tokens (design_guide.md)
  → Write Page Blueprint ({product}-blueprint.md)
  → Generate HTML (html_structure.md)
  → Generate CSS/JS (css_js_rules.md)
  → Self-review
```

**Required skill files:**
- `workflow.md`
- `content_brief.md`
- `design_guide.md`
- `components.md`
- `layout_patterns.md`
- `html_structure.md`
- `css_js_rules.md`
- `agent_execution_prompt.md`

**Optional:**
- `trend_adaptation.md` — if applying a trend profile
- `variation_generator.md` — if exploring multiple arrangements

**MCP requirements:** None — Mode C does not touch Figma unless escalating.

**Page Blueprint:** Mode C produces a `{product}-blueprint.md` file as its source of truth (the text equivalent of a Figma frame). This file captures all design decisions, section structure, token values, and asset manifest. It survives session resets and can be edited manually between iterations.

→ See `agent_execution_prompt.md` for the full blueprint format.

---

## Combined Workflows

| Workflow | Description |
|---|---|
| **A → correct → B** | Generate Figma frame, make manual corrections, then generate code from corrected frame |
| **C → iterate** | Generate code + blueprint, review in browser, iterate on blueprint + code in subsequent prompts |
| **C → A (structured)** | Generate code + blueprint, then use the finalized blueprint as input for Mode A to produce a structured Figma frame via `use_figma` (agent skips decision-making, acts as renderer) |
| **C → Figma (quick visual)** | Generate code, push rendered HTML to Figma via `generate_figma_design` for fast visual review as editable layers |
| **C → Figma → correct → B** | Generate code, push HTML to Figma via `generate_figma_design`, make manual corrections, run Mode B against corrected frame for final production code |
| **C → A → correct → B** | Full loop: quick code draft, structured blueprint to Figma, manual refinement, final code from corrected frame |

### Choosing Between C → A and C → Figma

| Path | Method | Layer Quality | Best For |
|---|---|---|---|
| **C → A (structured)** | Blueprint → `use_figma` builds frame from scratch | Structured naming, auto-layout, variable bindings | Frames that will be extensively edited in Figma |
| **C → Figma (quick visual)** | HTML → `generate_figma_design` pushes rendered output | HTML-mirror layers, may lack auto-layout | Fast visual review, minimal Figma editing planned |

→ Both paths are detailed in `figma_capture.md` Section 8

---

## Exploration Layer (Optional, Pre-Mode)

Before running any execution mode, two optional skill files can expand the design space:

### Trend Adaptation (`trend_adaptation.md`)
Ingests external design trends and translates them into brand-safe token overrides and layout modifications. Produces a Trend Adaptation Brief — a set of CSS custom property overrides and layout changes applied on top of the base design guide.

→ Run before any mode. Modifies the token values that downstream files use.

### Variation Generator (`variation_generator.md`)
Given a content brief, produces 3–5 meaningfully different page arrangements using existing components and layout patterns. Outputs a Variation Spec — the stakeholder picks one variant before execution begins.

→ Run before Mode A or Mode C. Defines the page structure that the selected mode then implements.

**Combined exploration order:**
```
Content Brief
  → Trend Adaptation Brief (optional — modifies tokens)
  → Variation Spec (optional — explores structures)
  → Select variant
  → Execute Mode A, B, or C
```

---

## Skill File Dependency Map

Files are organized in layers. Each layer depends on the layers above it.

```
CONTEXT LAYER
  workflow.md

DESIGN DECISION LAYER
  content_brief.md
  design_guide.md
  components.md
  layout_patterns.md

FIGMA LAYER
  figma_capture.md  (Mode A — write to Figma via use_figma)
  figma_to_code.md  (Mode B — read from Figma via get_design_context)

CODE GENERATION LAYER
  html_structure.md
  css_js_rules.md

EXPLORATION LAYER
  trend_adaptation.md
  variation_generator.md

ORCHESTRATION LAYER
  agent_execution_prompt.md
```

---

## Ownership Principle

Each instruction, token, or rule is defined in exactly one skill file. Other files reference it but never redefine it. If you find the same instruction in two files, delete it from the non-owner and replace with:

```
→ See {owning_file.md} for {topic}
```

Full ownership table is maintained in the Skill File Architecture — Master Reference document.

---

## Supported Agents

All execution modes work across:
- **Claude Code** — terminal agent with filesystem access; install Figma plugin for MCP + skills
- **Cursor AI** — IDE agent with workspace access; install Figma plugin for MCP + skills
- **Codex** — CLI agent; run `codex mcp add figma --url https://mcp.figma.com/mcp`

All three agents are interchangeable across all pipeline stages. The Figma MCP plugin (available for Claude Code and Cursor) bundles the MCP server configuration and foundational skills automatically.

Agent-specific notes (file referencing, session handling) are in `agent_execution_prompt.md`.

---

## Output Standards (All Modes)

### Code Output (Modes B and C)
- 3 files: `index.html`, `styles.css`, `script.js`
- BEM class naming with `{product}-` prefix
- CSS custom properties for all design tokens
- Responsive: desktop-first, breakpoints at 480px and 1024px
- jQuery only for UI interactions
- Images: `./assets/` paths with `/* TODO */` flags for uncertain mappings

→ Full rules in `css_js_rules.md` and `html_structure.md`

### Figma Output (Mode A)
- Frame pushed to specified file and page via `use_figma`
- Layer naming follows convention from `figma_capture.md` Section 4
- Tokens match `design_guide.md` — bound to Figma variables when available
- Self-healing verification loop confirms fidelity before presenting to user

→ Full rules in `figma_capture.md`

### Page Blueprint (Mode C)
- Saved as `{product}-blueprint.md` in the project folder
- Captures all design decisions, section structure, token values, asset manifest
- Three-category asset manifest: content images, icons/illustrations, CSS-only graphics

→ Full format in `agent_execution_prompt.md`

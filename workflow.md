<!-- meta
name: workflow
title: Workflow
version: 3.0
status: active
purpose: Establish the execution pipeline, define modes, and specify which skill files are read for each task.
owns:
  - Pipeline phases and sequencing
  - Execution mode definitions (A, B, C)
  - Combined workflow definitions
  - Skill file reading order
  - Exploration layer insertion point
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
last_updated: 2026-03-16
-->

# Workflow — Pipeline Context

Read this file first in every session.

---

## Pipeline Overview

This skill file system enables AI agents to convert marketing content briefs into Figma design frames and/or production-ready landing page code. The pipeline is modular — agents read only the files needed for the active execution mode.

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
  → Push to Figma (figma_capture.md)
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

---

### Mode B: Figma → Code

**Goal:** Generate production code from a finalized Figma frame.

**Pipeline:**
```
Figma Dev Link
  → Inspect frame (figma_to_code.md)
  → Extract specs + export assets
  → Generate HTML (html_structure.md)
  → Generate CSS/JS (css_js_rules.md)
  → Self-review
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

**Page Blueprint:** Mode C produces a `{product}-blueprint.md` file as its source of truth (the text equivalent of a Figma frame). This file captures all design decisions, section structure, token values, and asset manifest. It survives session resets and can be edited manually between iterations.

→ See `agent_execution_prompt.md` for the full blueprint format.

---

## Combined Workflows

| Workflow | Description |
|---|---|
| **A → correct → B** | Generate Figma frame, make manual corrections, then generate code from corrected frame |
| **C → iterate** | Generate code + blueprint, review in browser, iterate on blueprint + code in subsequent prompts |
| **C → A** | Generate code + blueprint, then use the finalized blueprint as input for Mode A to produce a Figma frame (agent skips decision-making, acts as renderer) |
| **C → A → correct → B** | Full loop: quick code draft, blueprint to Figma, manual refinement, final code from corrected frame |

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
  figma_capture.md  (Mode A — push to Figma)
  figma_to_code.md  (Mode B — read from Figma)

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
- **Claude Code** — terminal agent with filesystem access
- **Cursor AI** — IDE agent with workspace access
- **Codex** — CLI agent

Agent-specific notes (file referencing, MCP setup, session handling) are in `agent_execution_prompt.md`.

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
- Frame pushed to specified file and page via MCP
- Layer naming follows component naming from `components.md`
- Tokens match `design_guide.md`

→ Full rules in `figma_capture.md`

### Page Blueprint (Mode C)
- Saved as `{product}-blueprint.md` in the project folder
- Captures all design decisions, section structure, token values, asset manifest
- Three-category asset manifest: content images, icons/illustrations, CSS-only graphics

→ Full format in `agent_execution_prompt.md`

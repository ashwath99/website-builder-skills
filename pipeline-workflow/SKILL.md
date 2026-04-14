---
name: pipeline-workflow
description: Establishes the execution pipeline, defines modes A/B/C, and specifies skill file reading order for converting marketing briefs into Figma designs and production code. Use when starting any website builder session, planning a new landing page, or needing to understand the execution workflow and mode definitions.
version: "5.0.5"
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

→ Full tool details: see `figma-frame-builder` Section 2 and `figma-code-extractor` Section 2

---

## Tool Permissions & Restrictions

### use_figma Tool

`use_figma` is **only** available via the remote MCP server (`mcp.figma.com/mcp`). The agent must never search for, launch, or attempt to connect to the Figma Desktop Bridge or any local Figma application. If `use_figma` is not available in the current session, the agent must:
1. Inform the user that Figma write access requires the remote MCP server
2. Suggest installing the Figma MCP plugin (available for Claude Code and Cursor)
3. Do not attempt alternative methods — no desktop bridge, no local API, no browser automation

**Hardcoded rule:** The agent must not call `search_design_system`, `get_design_context`, `get_variable_defs`, or `use_figma` unless these tools are confirmed available in the current MCP session. Do not attempt tool discovery at runtime.

### URL Access Permission

Before the agent fetches any website URL for design token extraction (Source 3 in `design-tokens/token-sources.md`), it must follow this procedure:

1. **Confirm the URL** — present the URL back to the user and ask: "I'll access this URL to extract design tokens (colors, typography, spacing). Do you confirm this URL is correct and accessible?"
2. **Wait for confirmation** — do not fetch until the user explicitly confirms
3. **If the URL requires authentication** — the agent cannot access authenticated pages. Inform the user and suggest alternatives: provide a screenshot (Source 6), export CSS manually, or provide a JSON token file (Source 7)
4. **If the fetch fails** — report the failure, do not retry silently. Offer the same alternatives as Step 3.
5. **Rate limit** — fetch the URL once. Do not re-fetch the same URL multiple times in a session unless the user explicitly requests it.

This permission step applies every time a new URL is provided, even if the user has confirmed a different URL earlier in the session.

---

## Execution Modes

### Mode A: Brief → Figma

**Goal:** Generate a Figma design frame from a content brief.

**Pipeline:**
```
Content Brief
  → Parse brief (brief-parser)
  → Detect token source → resolve token values (design-tokens/token-sources.md)
  → Select layout (layout-patterns)
  → Map components (component-library)
  → Apply tokens (design-tokens)
  → Search design system for reusable components
  → Push to Figma via use_figma (figma-frame-builder)
  → Self-healing verification loop (screenshot → compare → fix)
```

**Required skill files:**
- `pipeline-workflow`
- `brief-parser`
- `design-tokens`
- `component-library`
- `layout-patterns`
- `figma-frame-builder`
- `execution-prompts`

**Optional:**
- `trend-adapter` — if applying a trend profile
- `variation-explorer` — if exploring multiple arrangements before committing

**MCP requirements:** Remote server connected, `/figma-use` skill installed.

---

### Mode B: Figma → Code

**Goal:** Generate production code from a finalized Figma frame.

**Pipeline:**
```
Figma Dev Link (or desktop selection)
  → Inspect frame via get_design_context (figma-code-extractor)
  → Extract variables via use_figma Plugin API script
  → Identify library components via search_design_system
  → Extract specs + export assets
  → Generate HTML (html-generator)
  → Generate CSS/JS (css-js-generator)
  → Self-review (with optional visual comparison via generate_figma_design)
```

**Required skill files:**
- `pipeline-workflow`
- `design-tokens`
- `component-library`
- `figma-code-extractor`
- `html-generator`
- `css-js-generator`
- `execution-prompts`

**Optional:**
- `trend-adapter` — if a trend override sheet was produced earlier and should inform code token values

**Critical rule:** The Figma dev link is the sole source of truth. If Mode B follows Mode A (with or without manual corrections), the agent inspects the frame fresh — no prior assumptions from Mode A carry over.

**MCP requirements:** Remote server connected. `/figma-use` skill needed only if annotating the frame during review.

---

### Mode C: Brief → Code

**Goal:** Generate production code directly from a content brief, skipping Figma.

**Pipeline:**
```
Content Brief
  → Parse brief (brief-parser)
  → Detect token source → resolve token values (design-tokens/token-sources.md)
  → Select layout (layout-patterns)
  → Map components (component-library)
  → Apply tokens (design-tokens)
  → Write Page Blueprint ({product}-blueprint.md)
  → Generate HTML (html-generator)
  → Generate CSS/JS (css-js-generator)
  → Self-review
```

**Required skill files:**
- `pipeline-workflow`
- `brief-parser`
- `design-tokens`
- `component-library`
- `layout-patterns`
- `html-generator`
- `css-js-generator`
- `execution-prompts`

**Optional:**
- `trend-adapter` — if applying a trend profile
- `variation-explorer` — if exploring multiple arrangements

**MCP requirements:** None — Mode C does not touch Figma unless escalating.

**Page Blueprint:** Mode C produces a `{product}-blueprint.md` file as its source of truth (the text equivalent of a Figma frame). This file captures all design decisions, section structure, token values, and asset manifest. It survives session resets and can be edited manually between iterations.

→ See `execution-prompts` for the full blueprint format.

---

## Token Source Detection

Before any design tokens are applied, the agent identifies which token source has been provided and resolves all `{PLACEHOLDER}` values accordingly. This step runs at the start of Modes A and C (after brief parsing) and optionally in Mode B (if an override source is provided alongside the Figma link).

### Detection Logic — Read Inputs in This Order

| Priority | Signal | Source Type |
|---|---|---|
| 1 | A `.md` file attached or referenced that contains token names and values | Source 1 — Product Token File |
| 2 | A `.json` file attached or referenced | Source 7 — JSON Token File |
| 3 | A Figma library URL or design system reference provided | Source 4 — Figma Design System |
| 4 | A Figma frame or file URL provided alongside a brief | Source 5 — Figma Design Frame |
| 5 | A website URL provided alongside a brief | Source 3 — Website URL |
| 6 | A `.png`, `.jpg`, or image file attached | Source 6 — Screenshot |
| 7 | token-values.md already has values filled in | Source 2 — Manual Fill |
| 8 | No source provided — all placeholders remain | Proceed with `{PLACEHOLDER}` — flag as gap |

**When multiple sources are provided**, apply in priority order above. Values from a higher-priority source take precedence over lower ones. Any remaining gaps after extraction are flagged.

→ Full extraction protocols for each source type: see `design-tokens/token-sources.md`

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

→ Both paths are detailed in `figma-frame-builder` Section 8

---

## Exploration Layer (Optional, Pre-Mode)

Before running any execution mode, two optional skill files can expand the design space:

### Trend Adaptation (`trend-adapter`)
Ingests external design trends and translates them into brand-safe token overrides and layout modifications. Produces a Trend Adaptation Brief — a set of CSS custom property overrides and layout changes applied on top of the base design guide.

→ Run before any mode. Modifies the token values that downstream files use.

### Variation Generator (`variation-explorer`)
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
  pipeline-workflow

DESIGN DECISION LAYER
  brief-parser
  design-tokens
  component-library
  layout-patterns

FIGMA LAYER
  figma-frame-builder  (Mode A — write to Figma via use_figma)
  figma-code-extractor  (Mode B — read from Figma via get_design_context)

CODE GENERATION LAYER
  html-generator
  css-js-generator

EXPLORATION LAYER
  trend-adapter
  variation-explorer

ORCHESTRATION LAYER
  execution-prompts
```

---

## Ownership Principle

Each instruction, token, or rule is defined in exactly one skill file. Other files reference it but never redefine it. If you find the same instruction in two files, delete it from the non-owner and replace with:

```
→ See {owning_file} for {topic}
```

Full ownership table is maintained in the Master Reference document.

---

## Supported Agents

All execution modes work across:
- **Claude Code** — terminal agent with filesystem access; install Figma plugin for MCP + skills
- **Cursor AI** — IDE agent with workspace access; install Figma plugin for MCP + skills
- **Codex** — CLI agent; run `codex mcp add figma --url https://mcp.figma.com/mcp`

All three agents are interchangeable across all pipeline stages. The Figma MCP plugin (available for Claude Code and Cursor) bundles the MCP server configuration and foundational skills automatically.

Agent-specific notes (file referencing, session handling) are in `execution-prompts`.

---

## Output Standards (All Modes)

### Code Output (Modes B and C)
- 3 files: `index.html`, `styles.css`, `script.js`
- BEM class naming with `{product}-` prefix
- CSS custom properties for all design tokens
- Responsive: desktop-first, breakpoints at 480px and 1024px
- jQuery only for UI interactions
- Images: `./assets/` paths with `/* TODO */` flags for uncertain mappings

→ Full rules in `css-js-generator` and `html-generator`

### Figma Output (Mode A)
- Frame pushed to specified file and page via `use_figma`
- Layer naming follows convention from `figma-frame-builder` Section 4
- Tokens match `design-tokens` — bound to Figma variables when available
- Self-healing verification loop confirms fidelity before presenting to user

→ Full rules in `figma-frame-builder`

### Page Blueprint (Mode C)
- Saved as `{product}-blueprint.md` in the project folder
- Captures all design decisions, section structure, token values, asset manifest
- Three-category asset manifest: content images, icons/illustrations, CSS-only graphics

→ Full format in `execution-prompts`

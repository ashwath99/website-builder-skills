# Website Builder Skills

A modular skill file system that enables AI agents to convert marketing content briefs into Figma design frames and/or production-ready landing page code.

Built for **Claude Code**, **Cursor AI**, and **Codex**.

> **Current version:** 4.0 — See [CHANGELOG.md](CHANGELOG.md) for release notes.

---

## What's New in v4.0

- **Remote Figma MCP plugin** — Migrated from 23 local desktop bridge tools to 4 unified tools via `mcp.figma.com/mcp` (`use_figma`, `get_design_context`, `search_design_system`, `generate_figma_design`).
- **Self-healing verification loop** — Mode A now iterates: screenshot → compare → fix → re-screenshot (max 3 cycles) for higher frame fidelity.
- **Centralized design tokens** — New `design_system_prompt.md` fills all 85 `{PLACEHOLDER}` values from one file, enabling per-product token sets without editing core skill files.
- **Design system reuse** — Agents search for existing library components before creating new ones.
- **Variable-first token mapping** — Mode B uses Figma variable names directly as CSS custom property names.
- **4 escalation paths from Mode C** — Including quick visual review via `generate_figma_design`.
- **Code Connect integration** — Optional mapping of Figma components to code implementations.

---

## Media

- **Guide**: [`docs/GUIDE.md`](docs/GUIDE.md)
- **Changelog**: [`CHANGELOG.md`](CHANGELOG.md)
- **Deck (PDF)**: [`docs/website-builder-skills-presentation-v4.pdf`](docs/website-builder-skills-presentation-v4.pdf)
- **Infographic (PNG)**: [`infographics/website-builder-skills-infographics-v4.png`](infographics/website-builder-skills-infographics-v4.png)

---

## How It Works

The system uses three execution modes:

| Mode | Flow | Description |
|------|------|-------------|
| **A** | Brief → Figma | Generate a Figma design frame from a content brief |
| **B** | Figma → Code | Generate production code from a finalized Figma frame |
| **C** | Brief → Code | Generate production code directly, skipping Figma |

Modes can be combined: `A → correct → B` (design in Figma, refine, then generate code), `C → iterate` (rapid code drafts with a page blueprint), `C → Figma` (quick visual review), or `C → A → correct → B` (full structured escalation).

### Figma MCP Server (v4.0)

All Figma operations use the official remote MCP plugin at `mcp.figma.com/mcp`. The agent needs:

| Tool | Direction | Replaces (v3.0) |
|------|-----------|-----------------|
| `use_figma` | Write (Plugin API) | 9 individual write tools |
| `get_design_context` | Read | 3 individual read tools |
| `search_design_system` | Search | 2 individual search tools |
| `generate_figma_design` | Code → Canvas | New in v4.0 |

Setup: Install the Figma plugin — it bundles MCP server config + foundational skills automatically.

---

## Skill Files

Start with `workflow.md` — it defines the pipeline and tells you which files to read for each mode.

### Context Layer

| File | Purpose |
|------|---------|
| [workflow.md](workflow.md) | Pipeline phases, execution modes, MCP server setup, skill file reading order |
| [skill_usage_matrix.md](skill_usage_matrix.md) | File inventory, ownership table, usage-by-mode matrix, Figma MCP tool mapping |

### Design Decision Layer

| File | Purpose |
|------|---------|
| [content_brief.md](content_brief.md) | Brief parsing, section identification, content gap detection |
| [design_guide.md](design_guide.md) | Design tokens — colors, typography, spacing, surfaces (structure and rules) |
| [design_system_prompt.md](design_system_prompt.md) | **New in v4.0** — Centralized token values for all 85 `{PLACEHOLDER}` entries |
| [components.md](components.md) | Component library — every reusable UI block with variants |
| [layout_patterns.md](layout_patterns.md) | Page layout patterns and selection logic |

### Figma Layer

| File | Purpose |
|------|---------|
| [figma_capture.md](figma_capture.md) | Push design frames to Figma via `use_figma`, self-healing loop, design system reuse |
| [figma_to_code.md](figma_to_code.md) | Inspect Figma frames via `get_design_context`, variable-first token mapping |

### Code Generation Layer

| File | Purpose |
|------|---------|
| [html_structure.md](html_structure.md) | HTML rules — semantic structure, BEM naming, accessibility |
| [css_js_rules.md](css_js_rules.md) | CSS custom properties, responsive breakpoints, jQuery interactions |

### Exploration Layer (Optional)

| File | Purpose |
|------|---------|
| [trend_adaptation.md](trend_adaptation.md) | Ingest design trends, produce brand-safe token overrides |
| [variation_generator.md](variation_generator.md) | Generate 3–5 page arrangement variants for stakeholder selection |

### Orchestration Layer

| File | Purpose |
|------|---------|
| [agent_execution_prompt.md](agent_execution_prompt.md) | Master prompt templates, page blueprint format, agent-specific config, escalation paths |

---

## Architecture

Files are organized in layers. Each layer depends on the layers above it.

```
CONTEXT LAYER
  workflow.md
  skill_usage_matrix.md

DESIGN DECISION LAYER
  content_brief.md
  design_guide.md
  design_system_prompt.md       ← new in v4.0
  components.md
  layout_patterns.md

FIGMA LAYER
  figma_capture.md   (Mode A)
  figma_to_code.md   (Mode B)

CODE GENERATION LAYER
  html_structure.md
  css_js_rules.md

EXPLORATION LAYER
  trend_adaptation.md
  variation_generator.md

ORCHESTRATION LAYER
  agent_execution_prompt.md
```

**Total: 13 files (12 active + 1 new)**

---

## Code Output

Modes B and C produce three files:

- `index.html` — semantic HTML with BEM class naming
- `styles.css` — CSS custom properties for all design tokens, desktop-first responsive
- `script.js` — jQuery-based UI interactions

Responsive breakpoints: desktop-first, with breakpoints at 1024px and 480px.

---

## Usage

1. Read `workflow.md` first to understand the pipeline
2. Read `design_system_prompt.md` to load token values for the target product
3. Identify your execution mode (A, B, or C)
4. Feed the agent the skill files listed for that mode
5. Provide your content brief (Modes A and C) or Figma dev link (Mode B)

**Agent setup (v4.0):** Install the Figma plugin — it bundles the MCP server config and `/figma-use` foundational skill. No local desktop bridge needed.

---

## Ownership Principle

Each instruction, token, or rule is defined in exactly one skill file. Other files reference it but never redefine it. See the metadata block at the top of each file for ownership details. The full ownership table is in `skill_usage_matrix.md`.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

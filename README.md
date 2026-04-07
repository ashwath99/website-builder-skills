# Website Builder Skills v5.0

A modular skill file system that enables AI agents to convert marketing content briefs into Figma design frames and/or production-ready landing page code.

Built for **Claude Code**, **Cursor AI**, **VS Code / GitHub Copilot**, **Antigravity (Google)**, **Codex CLI**, and **Gemini CLI**.

> **Current version:** 5.0 — Restructured to the [Agent Skills specification](https://docs.anthropic.com) (SKILL.md format).

---

## What's New in v5.0

- **SKILL.md format** — Every skill now follows the universal Agent Skills specification with YAML frontmatter (`name`, `description`, `version`), making them discoverable and loadable across all major AI coding agents.
- **Independent skill directories** — Each skill lives in its own folder with a `SKILL.md` entry point and optional reference files for overflow content.
- **Ownership-based naming** — Skills are named by what they own: `brief-parser`, `design-tokens`, `component-library`, etc.
- **Progressive disclosure** — SKILL.md files stay under 500 lines; detailed specs overflow into reference files one level deep.
- **Cross-IDE compatibility** — Works with Claude Code, Cursor AI, VS Code, Antigravity, Codex CLI, and Gemini CLI.

---

## How It Works

The system uses three execution modes:

| Mode | Flow | Description |
|------|------|-------------|
| **A** | Brief → Figma | Generate a Figma design frame from a content brief |
| **B** | Figma → Code | Generate production code from a finalized Figma frame |
| **C** | Brief → Code | Generate production code directly, skipping Figma |

Modes can be combined: `A → correct → B`, `C → iterate`, `C → Figma`, or `C → A → correct → B`.

### Figma MCP Server

All Figma operations use the official remote MCP plugin at `mcp.figma.com/mcp`:

| Tool | Direction | Purpose |
|------|-----------|---------|
| `use_figma` | Write (Plugin API) | Create, edit, delete frames, components, variables |
| `get_design_context` | Read | Extract layout, spacing, colors, typography from frames |
| `search_design_system` | Search | Find components, variables, styles across libraries |
| `generate_figma_design` | Code → Canvas | Push rendered HTML into editable Figma layers |

---

## Skill Directory

Start with `pipeline-workflow/SKILL.md` — it defines the pipeline and tells you which skills to read for each mode.

### Context Layer

| Skill | Purpose |
|-------|---------|
| [pipeline-workflow](pipeline-workflow/) | Pipeline phases, execution modes, MCP server setup, skill reading order |
| [master-reference](master-reference/) | File inventory, ownership table, usage-by-mode matrix, Figma MCP tool mapping |

### Design Decision Layer

| Skill | Purpose |
|-------|---------|
| [brief-parser](brief-parser/) | Brief parsing, section identification, content gap detection, audience classification |
| [design-tokens](design-tokens/) | Design token definitions + centralized token values (`token-values.md`) |
| [component-library](component-library/) | UI component library with variants + overflow specs (`component-specs.md`) |
| [layout-patterns](layout-patterns/) | Page layout patterns, grid system, section rhythm, pattern selection logic |

### Figma Layer

| Skill | Purpose |
|-------|---------|
| [figma-frame-builder](figma-frame-builder/) | Push design frames to Figma via `use_figma`, self-healing verification loop |
| [figma-code-extractor](figma-code-extractor/) | Inspect Figma frames via `get_design_context`, variable-first token mapping |

### Code Generation Layer

| Skill | Purpose |
|-------|---------|
| [html-generator](html-generator/) | HTML rules, BEM naming, section markup patterns + overflow patterns (`markup-patterns.md`) |
| [css-js-generator](css-js-generator/) | CSS custom properties, responsive breakpoints + jQuery patterns (`jquery-patterns.md`) |

### Exploration Layer (Optional)

| Skill | Purpose |
|-------|---------|
| [trend-adapter](trend-adapter/) | Ingest design trends, produce brand-safe token overrides |
| [variation-explorer](variation-explorer/) | Generate 3-5 page arrangement variants for stakeholder selection |

### Orchestration Layer

| Skill | Purpose |
|-------|---------|
| [execution-prompts](execution-prompts/) | Master prompt templates, page blueprint format + prompt templates (`prompt-templates.md`) |

---

## Architecture

```
CONTEXT LAYER
  pipeline-workflow/
  master-reference/

DESIGN DECISION LAYER
  brief-parser/
  design-tokens/          (+ token-values.md)
  component-library/      (+ component-specs.md)
  layout-patterns/

FIGMA LAYER
  figma-frame-builder/    (Mode A)
  figma-code-extractor/   (Mode B)

CODE GENERATION LAYER
  html-generator/         (+ markup-patterns.md)
  css-js-generator/       (+ jquery-patterns.md)

EXPLORATION LAYER
  trend-adapter/
  variation-explorer/

ORCHESTRATION LAYER
  execution-prompts/      (+ prompt-templates.md)
```

**Total: 13 skills (18 files across 13 directories)**

---

## Code Output

Modes B and C produce three files:

- `index.html` — semantic HTML with BEM class naming (`{product}-{block}__{element}--{modifier}`)
- `styles.css` — CSS custom properties for all design tokens, desktop-first responsive
- `script.js` — jQuery-based UI interactions

Responsive breakpoints: desktop-first, with breakpoints at 1024px and 480px.

---

## Usage

1. Read `pipeline-workflow/SKILL.md` first to understand the pipeline
2. Read `design-tokens/token-values.md` to load token values for the target product
3. Identify your execution mode (A, B, or C)
4. Feed the agent the skills listed for that mode
5. Provide your content brief (Modes A and C) or Figma dev link (Mode B)

**Agent setup:** Install the Figma plugin — it bundles the MCP server config and `/figma-use` foundational skill.

---

## Ownership Principle

Each instruction, token, or rule is defined in exactly one skill. Other skills reference it but never redefine it. See the YAML frontmatter in each SKILL.md for ownership details. The full ownership table is in `master-reference/SKILL.md`.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

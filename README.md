# Website Builder Skills

A modular skill file system that enables AI agents to convert marketing content briefs into Figma design frames and/or production-ready landing page code.

Built for **Claude Code**, **Cursor AI**, and **Codex**.

---

## Media

- **Guide**: [`docs/GUIDE.md`](docs/GUIDE.md)
- **Deck (PDF)**: [`docs/website-builder-skills-presentation.pdf`](docs/website-builder-skills-presentation.pdf)
- **Deck (PPTX download)**: [`docs/website-builder-skills-presentation.pptx`](docs/website-builder-skills-presentation.pptx)
- **Infographic (PNG)**: [`infographics/website-builder-skills-infographics.png`](infographics/website-builder-skills-infographics.png)
- **Video (MP4)**: [Release asset (`v0.1.0`)](https://github.com/ashwath99/website-builder-skills/releases/download/v0.1.0/website-builder-skills-cinematic-explanatory-video.mp4)

---

## How It Works

The system uses three execution modes:

| Mode | Flow | Description |
|------|------|-------------|
| **A** | Brief → Figma | Generate a Figma design frame from a content brief |
| **B** | Figma → Code | Generate production code from a finalized Figma frame |
| **C** | Brief → Code | Generate production code directly, skipping Figma |

Modes can be combined: `A → correct → B` (design in Figma, refine, then generate code) or `C → iterate` (rapid code drafts with a page blueprint).

---

## Skill Files

Start with `workflow.md` — it defines the pipeline and tells you which files to read for each mode.

### Context Layer

| File | Purpose |
|------|---------|
| [workflow.md](workflow.md) | Pipeline phases, execution modes, skill file reading order |
| [skill_usage_matrix.md](skill_usage_matrix.md) | File inventory, ownership table, usage-by-mode matrix |

### Design Decision Layer

| File | Purpose |
|------|---------|
| [content_brief.md](content_brief.md) | Brief parsing, section identification, content gap detection |
| [design_guide.md](design_guide.md) | Design tokens — colors, typography, spacing, surfaces |
| [components.md](components.md) | Component library — every reusable UI block with variants |
| [layout_patterns.md](layout_patterns.md) | Page layout patterns and selection logic |

### Figma Layer

| File | Purpose |
|------|---------|
| [figma_capture.md](figma_capture.md) | Push design frames to Figma via MCP |
| [figma_to_code.md](figma_to_code.md) | Inspect Figma frames, extract specs for code generation |

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
| [agent_execution_prompt.md](agent_execution_prompt.md) | Master prompt, page blueprint format, agent-specific config |

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
2. Identify your execution mode (A, B, or C)
3. Feed the agent the skill files listed for that mode
4. Provide your content brief (Modes A and C) or Figma dev link (Mode B)

---

## Ownership Principle

Each instruction, token, or rule is defined in exactly one skill file. Other files reference it but never redefine it. See the metadata block at the top of each file for ownership details. The full ownership table is in `skill_usage_matrix.md`.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

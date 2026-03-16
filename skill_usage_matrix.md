<!-- meta
name: master_reference
title: Skill File Architecture — Master Reference
version: 3.0
status: active
purpose: Central reference document for the entire UX Skill File Architecture — file inventory, usage matrix, ownership table, dependency map, and format specification.
owns:
  - File inventory and status tracking
  - Cross-file ownership table
  - Skill usage by mode matrix
  - Architecture-level decisions and conventions
requires: []
depends_on: []
referenced_by: []
modes:
  mode_a: optional
  mode_b: optional
  mode_c: optional
layer: context
last_updated: 2026-03-16
-->

# UX Skill File Architecture — Master Reference

> **Version:** 3.0
> **Owner:** Ashwath — UX Designer, ManageEngine
> **Purpose:** Enable AI agents to convert marketing content briefs into Figma design frames and production-ready code automatically.

---

## File Inventory

| Filename | Layer | Version | Status |
|---|---|---|---|
| `workflow.md` | Context | 3.0 | Active |
| `content_brief.md` | Design Decision | 3.0 | Active |
| `design_guide.md` | Design Decision | 3.0 | Active (token values pending) |
| `components.md` | Design Decision | 3.0 | Active |
| `layout_patterns.md` | Design Decision | 3.0 | Active |
| `figma_capture.md` | Figma | 3.0 | Active |
| `figma_to_code.md` | Figma | 3.0 | Active |
| `html_structure.md` | Code Generation | 3.0 | Active |
| `css_js_rules.md` | Code Generation | 3.0 | Active |
| `trend_adaptation.md` | Exploration | 3.0 | Active |
| `variation_generator.md` | Exploration | 3.0 | Active |
| `agent_execution_prompt.md` | Orchestration | 3.0 | Active |
| `design_system_prompt.md` | Maintenance | — | Parked |

**Total: 12 files (11 active, 1 parked)**

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
| **C → A** | Escalate blueprint into a Figma frame for visual review |
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

### Reading This Table

**Mode A** needs brief parsing, design decisions, and Figma generation — but not HTML/CSS rules (no code output).

**Mode B** needs Figma inspection and code generation rules — but not brief parsing (Figma frame is the input, not the brief).

**Mode C** needs everything except Figma-related files — it does brief parsing, design decisions, and code generation in one pass.

**Trend adaptation** is optional in all modes — it modifies design tokens before any mode runs.

**Variation generator** is optional in Modes A and C — it produces variant specs before the mode runs. Not relevant for Mode B since Mode B works from a finalized design.

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
| MCP push workflow | `figma_capture.md` | `agent_execution_prompt.md` |
| C → A escalation (blueprint → Figma) | `figma_capture.md` | `agent_execution_prompt.md` |
| Figma inspection workflow | `figma_to_code.md` | `agent_execution_prompt.md` |
| Spec extraction rules | `figma_to_code.md` | — |
| Asset export and compression | `figma_to_code.md` | `agent_execution_prompt.md` |
| MCP tool mapping for reading | `figma_to_code.md` | — |
| 4-phase pipeline (inspect → plan → generate → review) | `figma_to_code.md` | `agent_execution_prompt.md` |
| Non-standard frame handling | `figma_to_code.md` | — |

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

---

## Agent Reading Protocol

When an agent starts a session:

1. Read `workflow.md` first (always)
2. Identify the active execution mode (A, B, or C)
3. Read the metadata block of all files in the project folder
4. Load only files where `modes.{active_mode}` is `required` or `optional`
5. For `optional` files, load only if the user's prompt references them

This minimizes token usage by avoiding unnecessary file reads.

---

## Supported Agents

| Agent | Type | File Access | Figma MCP |
|---|---|---|---|
| Claude Code | Terminal agent | Filesystem direct | `npx figma-developer-mcp` |
| Cursor AI | IDE agent | Workspace folder | Same bridge |
| Codex | CLI agent | Project directory | Verify compatibility |

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

---

## Pending Actions

| Action | Priority | Notes |
|---|---|---|
| Fill `{PLACEHOLDER}` values in `design_guide.md` | High | Production token values needed |
| Test Mode C with a real brief | High | Blueprint flow is untested |
| Build `design_system_prompt.md` | Low | Parked until maintenance tasks arise |
| Refresh trend profiles periodically | Low | Review every 6–12 months |

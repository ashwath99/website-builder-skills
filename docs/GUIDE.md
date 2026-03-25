# The Complete Guide to Website Builder Skills

A practical guide to understanding, using, and extending the Website Builder Skill File System — a modular architecture that enables AI agents to convert marketing content briefs into Figma design frames and production-ready landing page code.

> **Version:** 4.0 — See [CHANGELOG.md](../CHANGELOG.md) for what's new.

---

## Media

- **Deck (PDF)**: [`website-builder-skills-presentation.pdf`](website-builder-skills-presentation.pdf)
- **Infographic (PNG)**: [`../infographics/website-builder-skills-infographics.png`](../infographics/website-builder-skills-infographics.png)
- **Video (MP4)**: [Release asset (`v0.1.0`)](https://github.com/ashwath99/website-builder-skills/releases/download/v0.1.0/website-builder-skills-cinematic-explanatory-video.mp4)

---

## Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Understanding the Three Modes](#understanding-the-three-modes)
4. [Getting Started](#getting-started)
5. [The Exploration Layer](#the-exploration-layer)
6. [The Page Blueprint](#the-page-blueprint)
7. [Working with Agents](#working-with-agents)
8. [Extending the System](#extending-the-system)
9. [Patterns and Best Practices](#patterns-and-best-practices)
10. [Troubleshooting](#troubleshooting)
11. [Reference](#reference)

---

## Introduction

### What is this system?

The Website Builder Skill File System is a collection of markdown files that teach AI coding agents how to build landing pages. Instead of explaining your design system, component library, layout rules, and brand standards in every conversation, you teach the agent once through skill files and benefit every time.

### The problem it solves

Building a landing page with an AI agent typically goes like this:

1. You paste a content brief
2. You explain your design system
3. You describe your component library
4. You specify your code standards
5. The agent builds something — but misses your brand colors, uses the wrong class naming, picks a layout that doesn't fit your audience
6. You spend 3–4 iterations correcting

With skill files, steps 2–4 are handled permanently. The agent reads your skill files once per session and produces output that follows your exact standards from the first attempt.

### Who is this for?

- **UX designers** who work with AI agents to produce landing pages and product screens
- **Front-end developers** who want consistent, production-ready code output from AI tools
- **Design system maintainers** who need AI agents to respect token values and component specs
- **Marketing teams** who want faster turnaround from content brief to published page

### What you'll learn

- How the skill file architecture works and why it's structured the way it is
- How to run all three execution modes (Brief → Figma, Figma → Code, Brief → Code)
- How to use the exploration layer to adapt to design trends and generate layout variations
- How to extend the system with new components, patterns, and trend profiles

---

## Architecture Overview

### The layer model

Skill files are organized in six layers. Each layer has a specific responsibility, and files within a layer depend on the layers above them.

```
CONTEXT LAYER
  workflow.md                    ← Read first. Always.
  skill_usage_matrix.md          ← File inventory, MCP tool mapping

DESIGN DECISION LAYER
  content_brief.md               ← How to parse a marketing brief
  design_guide.md                ← Design tokens (structure and rules)
  design_system_prompt.md        ← Token values (fills all {PLACEHOLDER}s)
  components.md                  ← Component library
  layout_patterns.md             ← Page-level layout patterns

FIGMA LAYER
  figma_capture.md               ← Push designs to Figma (Mode A)
  figma_to_code.md               ← Read designs from Figma (Mode B)

CODE GENERATION LAYER
  html_structure.md              ← HTML markup rules
  css_js_rules.md                ← CSS/JS output rules

EXPLORATION LAYER (optional)
  trend_adaptation.md            ← Trend-based token overrides
  variation_generator.md         ← Multi-variant page arrangements

ORCHESTRATION LAYER
  agent_execution_prompt.md      ← Prompt templates for all modes
```

### The ownership principle

Every instruction, token value, or rule is defined in exactly **one** file. Other files reference it but never redefine it.

This prevents a common problem: you update a color value in one file but forget to update it in another, and the agent gets conflicting instructions. With single ownership, there's one source of truth for everything.

Example of the ownership split for design tokens:

| What | Where it's defined | Where it's used |
|---|---|---|
| Token structure and rules | `design_guide.md` | All files that use tokens |
| Token production values | `design_system_prompt.md` | `design_guide.md`, `components.md`, `css_js_rules.md` |
| Primary CTA is `#E9142B` | `design_system_prompt.md` | `css_js_rules.md`, `components.md`, `trend_adaptation.md` |
| CSS syntax is `--{product}-color-primary` | `css_js_rules.md` | `figma_to_code.md`, `trend_adaptation.md` |
| CTA button HTML uses `{product}-btn--primary` class | `html_structure.md` | `css_js_rules.md` |

If you find the same instruction written in two files, delete it from the non-owner and replace with a cross-reference:

```
→ See design_guide.md for color token definitions
```

### The metadata block

Every skill file starts with a metadata block containing structured information:

```yaml
---
name: workflow
title: "Workflow"
version: 4.0
status: active
purpose: >
  Establish the execution pipeline, define modes, and specify
  which skill files are read for each task.
owns:
  - "Pipeline phases and sequencing"
  - "Execution mode definitions (A, B, C)"
requires: []
depends_on: []
modes:
  mode_a: required
  mode_b: required
  mode_c: required
layer: context
last_updated: 2026-03-25
---
```

This block is parseable by AI agents. It tells the agent what each file does, what it owns, and when to load it — before reading a single line of the actual instructions.

> **v4.0 note:** The metadata format has been standardized to YAML frontmatter (`---` delimiters) for all new/updated files. Some files may still use HTML comment format (`<!-- meta -->`) — both are equivalent.

### Why no numbered filenames

Earlier versions used numbered prefixes (`00_workflow.md`, `01_content_brief.md`). This was dropped because:

- Numbers create a false hierarchy — not all files need to be read in sequence
- Renumbering is painful when files are added or removed
- Descriptive names are more useful when referencing files in prompts

The reading order is defined by `workflow.md` and the dependency map in each file's metadata. The filenames themselves don't need to encode sequence.

---

## Understanding the Three Modes

### Mode A: Brief → Figma

**Input:** A marketing content brief (text file)
**Output:** A Figma design frame

```
Content Brief
  → Parse brief (content_brief.md)
  → Classify audience
  → Select layout pattern (layout_patterns.md)
  → Map content to components (components.md)
  → Apply design tokens (design_guide.md + design_system_prompt.md)
  → Search design system for reusable components (search_design_system)
  → Push to Figma via use_figma (figma_capture.md)
  → Self-healing verification loop (screenshot → compare → fix, max 3 iterations)
```

**When to use:** When you need a visual design review before code is written. The agent generates a complete Figma frame that you can inspect, adjust, and share with stakeholders before proceeding to code.

**v4.0 additions:**
- The agent searches your connected design system for existing library components before creating anything from scratch.
- After generation, the self-healing loop automatically screenshots, compares against the spec, and fixes mismatches — up to 3 iterations.

**Skill files loaded:** `workflow.md`, `design_system_prompt.md`, `content_brief.md`, `design_guide.md`, `components.md`, `layout_patterns.md`, `figma_capture.md`, `agent_execution_prompt.md`

### Mode B: Figma → Code

**Input:** A Figma dev link (with node ID) or selected frame
**Output:** `index.html`, `styles.css`, `script.js`

```
Figma Dev Link
  → Inspect frame via get_design_context (figma_to_code.md)
  → Extract token bindings via use_figma (variable-first approach)
  → Identify design system components via search_design_system
  → Export and compress assets
  → Generate HTML (html_structure.md)
  → Generate CSS/JS (css_js_rules.md)
  → Self-review + optional visual comparison via generate_figma_design
```

**When to use:** When a finalized Figma frame exists — whether it came from Mode A, was designed manually, or is an existing page being rebuilt.

**Critical rule:** The Figma dev link is the sole source of truth. If you ran Mode A, then made manual corrections in Figma, Mode B reads only the corrected frame — it doesn't carry over any decisions from the Mode A session.

**v4.0 additions:**
- **Variable-first token mapping:** When Figma variables are bound to frame elements, the agent uses those variable names directly as the basis for CSS custom property naming — no more pixel-to-token guessing.
- **Optional visual comparison:** The agent can push generated HTML back to Figma via `generate_figma_design` for side-by-side comparison.

**Skill files loaded:** `workflow.md`, `design_system_prompt.md`, `design_guide.md`, `components.md`, `figma_to_code.md`, `html_structure.md`, `css_js_rules.md`, `agent_execution_prompt.md`

### Mode C: Brief → Code

**Input:** A marketing content brief
**Output:** `{product}-blueprint.md` + `index.html`, `styles.css`, `script.js`

```
Content Brief
  → Parse brief (content_brief.md)
  → Select layout + map components
  → Apply tokens (design_guide.md + design_system_prompt.md)
  → Write Page Blueprint
  → Generate HTML/CSS/JS
  → Self-review
```

**When to use:** When speed matters and you trust the agent's layout decisions, or when the brief is straightforward. Skips Figma entirely.

**Key difference:** Mode C produces a **Page Blueprint** (`{product}-blueprint.md`) — a markdown file that records all design decisions. This is the text equivalent of a Figma frame. It survives session resets, can be edited manually, and serves as the persistent source of truth during iteration.

**Skill files loaded:** `workflow.md`, `design_system_prompt.md`, `content_brief.md`, `design_guide.md`, `components.md`, `layout_patterns.md`, `html_structure.md`, `css_js_rules.md`, `agent_execution_prompt.md`

### Combined workflows

Modes can be chained:

| Workflow | Description | When to use |
|---|---|---|
| **A → correct → B** | Generate Figma frame, edit manually, generate code from corrected frame | High-stakes pages, stakeholder sign-off needed |
| **C → iterate** | Generate code + blueprint, review in browser, iterate | Everyday landing pages |
| **C → A (structured)** | Push blueprint to Figma via `use_figma` with proper layer naming and auto-layout | When you want a proper Figma deliverable from a code draft |
| **C → Figma (quick visual)** | Push generated HTML to Figma via `generate_figma_design` for fast visual review | Quick visual check without full Figma structure |
| **C → Figma → correct → B** | Quick visual in Figma, manual corrections, then code from corrected frame | Rapid iteration with visual QA |
| **C → A → correct → B** | Full loop from quick draft to polished output | Complex pages that need everything |

### Token cost comparison

| Path | Relative Cost | Notes |
|---|---|---|
| Mode A → B | Highest (~1.0×) | Skill files loaded twice (separate sessions), MCP overhead both ways |
| Mode C (no iteration) | Lowest (~0.5×) | Skill files loaded once, no Figma MCP |
| Mode C + 3–4 iterations | Medium (~0.7×) | Partial context reloads per iteration |
| Mode C → A | Medium-High (~0.8×) | Adds Figma generation but skips decision-making phase |
| Mode C → Figma (quick) | Low-Medium (~0.6×) | Single `generate_figma_design` call, no structured build |

**Biggest token expense:** Skill file loading. Every new session reads 5–7 markdown files into context. Keep sessions alive for multiple tasks when possible.

---

## Getting Started

### Prerequisites

- An AI coding agent: **Claude Code**, **Cursor AI**, or **Codex**
- For Figma modes (A and B): The Figma MCP plugin installed (remote server at `mcp.figma.com/mcp`)
- A marketing content brief (text file with page content)
- The skill files from this repository

### Step 1: Clone the repository

```bash
git clone https://github.com/ashwath99/website-builder-skills.git
```

### Step 2: Fill in your design tokens

Open `design_system_prompt.md` and replace all `{PLACEHOLDER}` values with your production design tokens — colors, font sizes, spacing values, shadows, radii.

This is the only file that requires customization before first use. You can create per-product token files (e.g., `msp-design-tokens.md`, `edr-design-tokens.md`) following the same format. The core skill files remain unchanged.

> **v3 → v4 migration note:** Token values previously went directly into `design_guide.md`. In v4, `design_guide.md` defines the token structure and rules, while `design_system_prompt.md` holds the actual values. This means you no longer need to edit `design_guide.md` when switching products.

### Step 3: Set up Figma MCP (if using Modes A or B)

Install the Figma plugin for your agent:

| Agent | Setup |
|---|---|
| **Claude Code** | Install the Figma plugin — it bundles MCP server config + foundational skills automatically |
| **Cursor AI** | Install the Figma plugin via agent chat |
| **Codex** | `codex mcp add figma --url https://mcp.figma.com/mcp` |

The plugin provides the `/figma-use` foundational skill. Always invoke this skill before calling `use_figma`.

> **v3 → v4 migration note:** The local desktop bridge (`npx figma-developer-mcp`) is no longer required. All Figma operations use the official remote MCP plugin.

### Step 4: Choose your mode

Decide based on your situation:

- **I have a content brief and need a Figma frame for review** → Mode A
- **I have a finalized Figma design and need production code** → Mode B
- **I have a content brief and want code fast** → Mode C

### Step 5: Write your prompt

Every prompt starts with a shared preamble that tells the agent to read the skill files:

```
I am a UX designer.

Read the skill files in the project folder:
- workflow.md
- design_system_prompt.md
- content_brief.md
- design_guide.md
- components.md
- layout_patterns.md
- html_structure.md
- css_js_rules.md

Product class prefix: {product}
```

Then add the mode-specific instructions. Full prompt templates for every mode are in `agent_execution_prompt.md`.

### Step 6: Run and review

Run the prompt. The agent reads the skill files, processes your input, and generates output. Review, iterate, and proceed to the next mode if needed.

---

## The Exploration Layer

Before running any execution mode, you can optionally use two skill files to expand the design space.

### Trend Adaptation

`trend_adaptation.md` lets you apply external design trends to your landing pages without breaking brand compliance.

**How it works:**

1. The agent scans competitor/peer landing pages (via web search)
2. Maps observations to 7 parametric trend dimensions:
   - Spatial density (airy ↔ compact)
   - Typography scale (display-forward ↔ content-forward)
   - Color temperature (warm ↔ cool ↔ dark-mode)
   - Visual weight distribution (hero-dominant ↔ distributed ↔ bento)
   - Interaction pattern (static ↔ scroll-activated ↔ progressive-disclosure ↔ micro-interactions)
   - Section divider style (clean-cut ↔ gradient ↔ shaped ↔ bordered)
   - Card & component style (flat ↔ elevated ↔ glassmorphic ↔ outlined)
3. Recommends two profile options (safe + bold)
4. Produces a **Trend Adaptation Brief** — a CSS token override sheet + layout modifications

**Named profiles included:**

| Profile | Character | Reference |
|---|---|---|
| Modern SaaS | Compact, cool, display-forward, scroll-animated | Linear, Vercel, Notion |
| Enterprise Trust | Standard, balanced, neutral, static | Salesforce, ServiceNow |
| Editorial Product | Airy, warm, bento, micro-interactions | Apple, Stripe |
| Dark Mode Technical | Compact, dark, progressive-disclosure, glassmorphic | Developer tools, API platforms |
| Approachable SaaS | Standard, warm, hero-dominant, elevated | Mailchimp, Slack |

**Brand safety:** Every trend application passes through an invariant gate. The primary CTA color (`#E9142B`), brand font (ZohoPuvi), responsive breakpoints, and code standards are locked — no trend can modify them.

### Variation Generator

`variation_generator.md` produces multiple meaningfully different page arrangements from a single content brief, using only existing components and layout patterns.

**How it works:**

1. The agent analyzes the brief for constraints (available content, audience type, asset availability)
2. Generates 3–5 named variants, each differing on at least 2 of 6 axes:
   - Hero strategy (split-image, full-bleed, product-centered, text-bold, mini)
   - Narrative flow (problem-first, product-first, trust-first, outcome-first, story-first)
   - Feature presentation (icon-grid, alternating-rows, tabbed, accordion, carousel, bento)
   - CTA strategy (single-hero, contextual, sticky-bar, progressive, dual-action)
   - Density profile (breathing, standard, comprehensive)
   - Social proof placement (hero-adjacent, mid-page, distributed, closing)
3. Each variant includes a section-by-section page structure and a tradeoffs note
4. You pick one, and the selected variant feeds into Mode A or C

**Combined exploration pipeline:**

```
Content Brief
  → Trend Adaptation Brief (modifies tokens)
  → Variation Spec (explores structures)
  → Select variant
  → Execute Mode A, B, or C
```

Trends modify how things look. Variations modify how things are arranged. They're orthogonal — you can use both together.

---

## The Page Blueprint

Mode C produces a unique artifact: the **Page Blueprint** (`{product}-blueprint.md`).

### Why it exists

In Mode A → B, the Figma frame is the source of truth — it survives session resets, can be edited manually, and the agent reads it fresh in each session.

Mode C has no Figma frame. Without the blueprint, all design decisions would exist only in the agent's session context — one reset and everything is lost. The blueprint captures every decision in a persistent file.

### What it contains

```markdown
# Page Blueprint: {Product Name} Landing Page

## Page Structure
### Section 1: Hero
- Component: Hero: Split Image
- Content: {actual copy from brief}
- Image: ./assets/hero-dashboard.png

### Section 2: Features
- Component: Feature Grid (3-col)
- ...

## Token Values Applied
--{product}-space-section: 80px;
--{product}-feature-columns: 3;

## Interaction Patterns
- Feature tabs: jQuery tab switcher

## Asset Manifest
### Content Images (supplied by user)
| hero-dashboard.png | Available |
### Icons (sourcing decision needed)
| feature-icon-monitoring.svg | Agent will generate inline SVG |
### CSS-Only Graphics
| Section backgrounds | Gradient via custom properties |
```

### How it's used

| Scenario | What happens |
|---|---|
| **Initial generation** | Agent writes blueprint first, then generates code from it |
| **Iteration** | Agent updates blueprint first, then modifies code to match |
| **Session reset** | Point agent to blueprint file — it reads and continues from where you left off |
| **Manual edits** | You edit the markdown directly — agent respects your changes |
| **Escalation to Figma (structured)** | Feed blueprint into `use_figma` — agent renders it with proper layer naming and auto-layout |
| **Escalation to Figma (quick visual)** | Feed generated HTML into `generate_figma_design` for fast visual review |

### Escalation paths

**Blueprint → Figma structured build (C → A):**
```
Read the page blueprint: msp-blueprint.md
Do not re-analyze or re-decide layout.
The blueprint is the finalized design spec — generate a Figma frame
that matches it exactly using use_figma with proper layer naming
and auto-layout per figma_capture.md Section 4–5.
```

**HTML → Figma quick visual (C → Figma):**
```
Push the generated HTML to Figma using generate_figma_design
for visual review. This creates a rendered frame — layer names
will mirror HTML elements, not Section 4 naming convention.
```

**Full loop (C → A → correct → B):**
Mode C draft → iterate on blueprint → push to Figma (structured) → manual corrections → Mode B for final code.

---

## Working with Agents

### Supported agents

| Agent | Type | Best for |
|---|---|---|
| **Claude Code** | Terminal | Full filesystem control, asset compression, chaining operations |
| **Cursor AI** | IDE | Inline editing, visual diff, quick iteration on specific files |
| **Codex** | CLI | Project directory access, similar to Claude Code |

All three are interchangeable across all modes and pipeline stages. The same prompt templates work across all of them.

### Figma MCP setup (v4.0)

All agents now use the official remote Figma MCP plugin at `mcp.figma.com/mcp`. No local desktop bridge needed.

| Agent | Setup command |
|---|---|
| **Claude Code** | Install Figma plugin (bundles MCP config + skills) |
| **Cursor AI** | Install Figma plugin via agent chat |
| **Codex** | `codex mcp add figma --url https://mcp.figma.com/mcp` |

**Available tools:**

| Tool | Direction | Purpose |
|---|---|---|
| `use_figma` | Write | Execute Plugin API JavaScript on the Figma canvas |
| `get_design_context` | Read | Retrieve design specs, properties, and screenshots from a frame |
| `search_design_system` | Search | Find components and styles in the connected design system |
| `generate_figma_design` | Code → Canvas | Push HTML to Figma as a rendered frame |

Always invoke the `/figma-use` foundational skill before calling `use_figma`.

### Agent-specific tips

**Claude Code:**
- Install the Figma plugin for MCP access
- Long pipeline runs may approach context limits — split into separate sessions if needed
- Can run asset compression commands directly (`svgo`, `imagemin`)

**Cursor AI:**
- Keep skill files in a `_skills/` folder to avoid cluttering the workspace
- Use `@filename` syntax to reference specific files (e.g., `@figma_to_code.md`)
- Changes are visible in the IDE immediately

**Codex:**
- If the agent stalls between phases, break the prompt into per-phase instructions
- Verify MCP connection before Figma operations

### Token efficiency tips

1. **Pick the right mode upfront.** Mode A → B when you need Figma review. Mode C when you don't. Don't default to the expensive path.
2. **Keep sessions alive.** Skill file loading is the biggest single expense. Iterate within the same session rather than starting fresh.
3. **Use the required files list.** Each mode's skill file list tells you exactly what to load. Don't load files the mode doesn't need.
4. **Mode B doesn't need brief parsing files.** Mode A doesn't need code generation files. The mode matrix prevents unnecessary loading.
5. **Use C → Figma (quick visual) for fast checks.** A single `generate_figma_design` call is cheaper than a full C → A structured build.

---

## Extending the System

### Adding a new component

1. Define the component in `components.md`:
   - Content slots (what goes inside it)
   - Configuration variants
   - Responsive behavior
2. Add the HTML markup pattern in `html_structure.md`
3. Add CSS styles and any JS interaction pattern in `css_js_rules.md`
4. If the component maps to a section type, add it to the section-to-component table in `components.md`
5. If it should be available as a variation axis option, add it to the relevant axis in `variation_generator.md`

**Do not** add token values — those belong in `design_system_prompt.md` (values) or `design_guide.md` (structure/rules).

### Adding a new layout pattern

1. Define the pattern in `layout_patterns.md`:
   - Section sequence
   - Content requirements
   - Audience fit
2. Add selection logic rules in `layout_patterns.md` Section 4
3. If the pattern should be selectable via variation, update `variation_generator.md`

### Adding a new trend profile

1. Define all 7 dimension values in `trend_adaptation.md` Section 3
2. Include 2–3 reference URLs of real sites embodying the profile
3. Ensure the profile passes the invariant gate — no locked values may change

### Adding a new trend dimension

1. Add as a new subsection in `trend_adaptation.md` Section 2
2. Must map to specific, overridable CSS tokens or layout rules
3. Must not conflict with any brand invariant
4. Must be independent of existing dimensions
5. Update the trend profile definitions to include the new dimension

### Updating design tokens

Only edit `design_system_prompt.md` for token values. Only edit `design_guide.md` for token structure and rules. Every other file references these tokens — they'll pick up the new values automatically. Never hardcode a token value in any other file.

### Creating per-product token files

Copy `design_system_prompt.md` and rename it (e.g., `msp-design-tokens.md`, `edr-design-tokens.md`). Fill in the product-specific values. Point the agent to the correct token file in your prompt preamble.

---

## Patterns and Best Practices

### Pattern 1: Start with Mode C, escalate if needed

For most landing pages, Mode C is the fastest path. Generate code, review in browser, iterate. If the page turns out to be more complex than expected, escalate to Figma — either via quick visual (`generate_figma_design`) for a fast check, or structured build (`use_figma`) for a full Figma deliverable.

### Pattern 2: Use trend adaptation for competitive positioning

Before building a new product landing page, run the trend discovery process against 3–5 competitor sites. This gives you a concrete, data-informed starting point rather than subjective aesthetic preferences. The "safe choice" keeps you current; the "bold choice" differentiates you.

### Pattern 3: Generate variations for stakeholder alignment

When stakeholders disagree about page direction, generate 3 variants and present them as a structured choice. Each variant has a named intent ("Trust Fortress", "Deep Dive", "Clean Machine"), a tradeoffs note, and a section-by-section outline. This turns subjective debates into concrete decisions.

### Pattern 4: Blueprint as handoff documentation

Even if you don't use Mode C for code generation, the blueprint format is useful as a design handoff document. It captures every decision in a scannable format that developers can reference while building.

### Pattern 5: Separate sessions for Mode A and Mode B

When running A → correct → B, always start Mode B in a new session. This guarantees the agent reads the Figma frame fresh without carrying over Mode A assumptions. Your manual corrections will be respected fully.

### Pattern 6: Leverage design system reuse

Before creating custom components in Figma (Mode A), the agent searches your connected design system via `search_design_system`. This keeps frames consistent with your existing library and reduces manual cleanup. If you maintain a robust Figma component library, this pattern becomes increasingly valuable.

### Pattern 7: Use quick visual for rapid iteration

During Mode C iteration, push your generated HTML to Figma via `generate_figma_design` after each major change. This gives you a quick visual check without the overhead of a full structured Figma build.

---

## Troubleshooting

### Agent doesn't follow skill file rules

**Symptom:** Output uses wrong class names, hardcoded colors, or incorrect breakpoints.

**Causes and fixes:**
- **Skill files not loaded:** Check that the prompt preamble lists all required files for the active mode (including `design_system_prompt.md`)
- **Too many files loaded:** Loading unnecessary files dilutes attention. Use only the files listed for the active mode
- **Instructions buried:** Critical rules should be near the top of each file. If the agent ignores a rule, check its position — move important instructions up
- **Session too long:** After many iterations, the agent may lose track of early instructions. Start a fresh session and reload skill files

### Mode B ignores Figma corrections

**Symptom:** Generated code doesn't reflect changes you made in Figma after Mode A.

**Cause:** Mode B was run in the same session as Mode A. The agent blended its Mode A "memory" with the Figma inspection.

**Fix:** Always run Mode B in a new session. The critical rule in `agent_execution_prompt.md` explicitly instructs the agent to discard prior context, but a fresh session eliminates the risk entirely.

### Trend adaptation violates brand

**Symptom:** A trend override changes the primary CTA color or font family.

**Cause:** The invariant gate didn't catch the violation.

**Fix:** Check the Trend Adaptation Brief's "Invariant Check" section. If it shows "✗", the trend must be re-expressed within brand constraints. The locked values are listed in `trend_adaptation.md` Section 1 and `design_guide.md` Section 1.

### Variation generator produces near-duplicate variants

**Symptom:** Two variants look almost identical — different names but same structure.

**Cause:** Variants differ on only one axis.

**Fix:** The minimum-difference rule requires ≥2 axes to differ between any two variants. If the agent produces near-duplicates, point it to `variation_generator.md` Section 3.2 and ask it to regenerate with more contrast.

### Blueprint out of sync with code

**Symptom:** After several iterations, the blueprint says one thing but the code does another.

**Cause:** The agent modified code without updating the blueprint first.

**Fix:** Remind the agent: "Update the blueprint first, then modify code to match." The blueprint must always reflect the current state. If they've diverged, regenerate code from the blueprint.

### Token values show {PLACEHOLDER}

**Symptom:** CSS output contains `{PLACEHOLDER}` instead of actual values.

**Cause:** `design_system_prompt.md` hasn't been filled in with production token values.

**Fix:** Open `design_system_prompt.md` and replace all `{PLACEHOLDER}` entries with your actual design system values. This is a one-time setup step per product.

> **v3 → v4 migration note:** If you previously filled placeholders directly in `design_guide.md`, move those values to `design_system_prompt.md` instead.

### Figma MCP connection fails

**Symptom:** Agent can't push to or read from Figma.

**Checklist:**
1. Is the Figma plugin installed for your agent?
2. Is the remote MCP server accessible? (Check `mcp.figma.com/mcp`)
3. Is the `/figma-use` skill available? (Required before any `use_figma` call)
4. For Mode B: Do you have a valid Figma dev link with a node ID?

> **v3 → v4 migration note:** The local desktop bridge (`npx figma-developer-mcp`) is no longer needed. If you're still using it, switch to the official remote plugin.

---

## Reference

### Skill file quick reference

| File | One-line purpose |
|---|---|
| `workflow.md` | Pipeline modes, MCP server setup, reading order |
| `skill_usage_matrix.md` | File inventory, ownership table, MCP tool mapping |
| `content_brief.md` | Parse briefs, identify sections, flag gaps |
| `design_guide.md` | Design token structure and rules |
| `design_system_prompt.md` | Centralized token values (fills all `{PLACEHOLDER}`s) |
| `components.md` | Component library with slots, variants, responsive behavior |
| `layout_patterns.md` | Page layouts, section sequencing, grid system |
| `figma_capture.md` | Push frames to Figma via `use_figma`, self-healing loop |
| `figma_to_code.md` | Read frames via `get_design_context`, variable-first mapping |
| `html_structure.md` | Semantic HTML, BEM naming, accessibility |
| `css_js_rules.md` | CSS custom properties, responsive, jQuery patterns |
| `trend_adaptation.md` | 7 trend dimensions, 5 profiles, token overrides |
| `variation_generator.md` | 6 variation axes, constraint filters, variant specs |
| `agent_execution_prompt.md` | Prompt templates, blueprint format, escalation paths, validation |

### Figma MCP tool reference (v4.0)

| Tool | Direction | Purpose |
|---|---|---|
| `use_figma` | Write | Execute Plugin API JavaScript on the canvas |
| `get_design_context` | Read | Retrieve specs, properties, screenshots |
| `search_design_system` | Search | Find components and styles in design system |
| `generate_figma_design` | Code → Canvas | Push HTML to Figma as rendered frame |

### Code output standards

| Standard | Value |
|---|---|
| Output files | `index.html`, `styles.css`, `script.js` |
| Class naming | BEM with `{product}-` prefix |
| Token format | CSS custom properties `--{product}-*` |
| Responsive | Desktop-first, breakpoints at 1024px and 480px |
| JS library | jQuery only (no other libraries) |
| Images | `./assets/` paths with `<!-- TODO -->` flags |

### Brand invariants (never overridden)

| Invariant | Value |
|---|---|
| Primary CTA color | `#E9142B` |
| Heading font | ZohoPuvi (Zoho CDN) |
| Breakpoints | 480px, 1024px |
| Code stack | HTML5, CSS3, jQuery |
| Output format | 3 files (html, css, js) |
| Class prefix | `{product}-` from brief |

### Mode file requirements

| File | Mode A | Mode B | Mode C |
|---|---|---|---|
| `workflow.md` | ✓ | ✓ | ✓ |
| `design_system_prompt.md` | ✓ | ✓ | ✓ |
| `content_brief.md` | ✓ | — | ✓ |
| `design_guide.md` | ✓ | ✓ | ✓ |
| `components.md` | ✓ | ✓ | ✓ |
| `layout_patterns.md` | ✓ | ○ | ✓ |
| `figma_capture.md` | ✓ | — | — |
| `figma_to_code.md` | — | ✓ | — |
| `html_structure.md` | — | ✓ | ✓ |
| `css_js_rules.md` | — | ✓ | ✓ |
| `trend_adaptation.md` | ○ | ○ | ○ |
| `variation_generator.md` | ○ | — | ○ |
| `agent_execution_prompt.md` | ✓ | ✓ | ✓ |

✓ = Required | ○ = Optional | — = Not used

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

*Built by [Ashwath](https://github.com/ashwath99) — UX Designer, ManageEngine*

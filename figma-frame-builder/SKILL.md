---
name: figma-frame-builder
description: Generates and pushes Figma design frames from design specs using the remote MCP server. Handles frame structure, layer naming, content population, design system reuse, and self-healing verification. Use when creating Figma frames from content briefs (Mode A) or escalating blueprints to Figma.
version: "5.4.0"
---

# Figma Capture — Frame Generation

→ Code snippets: `figma-code-patterns.md` | Layout templates: `layout-code-templates.md`
→ Component specs: `component-library` | Token values: `design-tokens` | Section order: `layout-patterns`

---

## 1 — Prerequisites

| Input | Source |
|---|---|
| Parsed brief or Page Blueprint | `brief-parser` or `{product}-blueprint.md` |
| Layout pattern + component mapping | `layout-patterns` + `component-library` |
| Design tokens | `design-tokens` |
| Target Figma file URL | User prompt |
| Remote MCP server + `/figma-use` skill | `mcp.figma.com/mcp` |

### MCP Tool Prefix Discovery

Tool names have environment-specific prefixes (e.g., `mcp__Figma__use_figma` or `mcp__b5bd554a-...`). **At session start, search deferred tools for `use_figma` to discover the prefix.** All Figma tools share the same prefix.

### Screenshot Tools (try in order)

1. `{prefix}get_screenshot` — MCP remote, always available
2. `figma_take_screenshot` — Desktop Bridge, may not be connected
3. Manual — ask user to screenshot and attach

---

## 2 — Figma MCP Runtime Rules

**Every `use_figma` call runs in a fresh plugin context.** Nodes from prior calls are invisible unless found by stored ID.

### Context Reset Table

| Behavior | Rule |
|---|---|
| `figma.currentPage` resets each call | `await figma.setCurrentPageAsync(page)` at top of every call |
| Nodes from prior calls invisible | `figma.getNodeById(storedId)` after page load |
| `getPluginData`/`setPluginData` unsupported | Return node IDs — only cross-call persistence |
| `console.log` output not returned | Use `return` for all output |
| `figma.notify()`, `figma.closePlugin()` | Not available — never call |
| `loadAllPagesAsync()` | Not a real method — use `setCurrentPageAsync` |
| Async IIFE wrapping | Already auto-wrapped — don't double-wrap |

### Node ID Persistence (Mandatory)

Every `use_figma` call MUST end with:
```javascript
return { createdNodeIds: [...], mutatedNodeIds: [], summary: "..." };
```
Store returned IDs between calls. Never find nodes by name — use stored IDs only.

### Batching

~50K char limit per call. Target 2–3 sections per batch.

| Section Count | Build Batches | Total Calls (incl. verify) |
|---|---|---|
| 6–8 | 3–4 | 5–6 |
| 9–12 | 4–5 | 7–8 |

Rules: Batch 1 creates the main frame (returns ID for all subsequent batches). Every batch starts with the Frame-Finder Preamble (`figma-code-patterns.md` §1b). Every batch uses the Standard Batch Preamble helpers (`figma-code-patterns.md`).

### Plugin API Gotchas

**Colors:** 0–1 range (`{ r: 0.91, g: 0.08, b: 0.17 }`). No `a` in color — opacity at paint level. Fills/strokes/effects are read-only arrays: clone → modify → reassign.

**Shadows:** `blendMode: 'NORMAL'` REQUIRED on DROP_SHADOW/INNER_SHADOW — omitting crashes the script.

**Layout sizing (critical):**
- `primaryAxisSizingMode` defaults to `FIXED` (100px) — **always set explicitly to `'AUTO'`**
- `layoutSizingHorizontal = 'FILL'` fails silently if node isn't inside auto-layout yet
- `resize()` resets sizing modes to FIXED — call it BEFORE setting modes
- **Order:** create → `resize()` → `layoutMode` → `primaryAxisSizingMode = 'AUTO'` → `appendChild()` → child `layoutSizingHorizontal = 'FILL'`

**Text:** `loadFontAsync` before any text change. `textAutoResize = 'HEIGHT'` + `layoutSizingHorizontal = 'FILL'` after appending (default `WIDTH_AND_HEIGHT` overflows).

**Positioning:** New top-level nodes at (0,0) — offset right of existing content.

→ Full error table: `figma-code-patterns.md` Common API Errors section

---

## 3 — Frame Structure

### Top-Level Frame

| Property | Value |
|---|---|
| Name | `{Product Name} — Landing Page` |
| Width / Height | 1440px / Auto (grows) |
| Layout | Vertical auto-layout, padding 0 |
| Fill | `color-bg-page` |

### Section Frames

| Property | Value |
|---|---|
| Name | `Section: {Type}` |
| Width / Height | Fill parent / Hug + min-height |
| Padding | `section-padding-y` top/bottom, side padding to center `content-max-width` |
| Fill | Tinted section alternation from `layout-patterns` |

**Min-heights (collapse prevention):**

| Section Type | Min-Height |
|---|---|
| Hero | 500px |
| Feature Grid / Row | 300px |
| CTA / Pricing | 250px |
| All others | 200px |

### Component Frames

| Component | Min-Height |
|---|---|
| Feature Card | 150px |
| Testimonial Card | 120px |
| Pricing Card | 200px |
| Tab Panel | 200px |
| All others | 100px |

**Collapse root causes:** Text with `textAutoResize: "NONE"` → set `"HEIGHT"`. Image with no size → `resize()`. Frame with `primaryAxisSizingMode: "FIXED"` → set `"AUTO"`. `resize()` after sizing mode → call `resize()` first.

---

## 4 — Layer Naming

Pattern: `{Type}: {Label}` — every layer must have a type prefix.

| Prefix | Examples |
|---|---|
| `Section` | `Section: Hero`, `Section: Feature Grid` |
| `Feature Card` | `Feature Card: Real-time Alerts` |
| `Feature Grid/Row` | `Feature Grid: Core Features` |
| `Tab Panel` | `Tab Panel: Advanced Features` |
| `Testimonial` | `Testimonial: Jane Doe, Acme Corp` |
| `Logo Bar` / `Metrics Bar` | `Logo Bar: Trusted By` |
| `CTA` / `FAQ` / `Pricing` | `CTA: Closing` |
| `Text` | `Text: H1`, `Text: Body` |
| `Image` | `Image: Hero Screenshot` |
| `Button` | `Button: Primary`, `Button: Secondary`, `Button: Highlight`, `Button: Outline` |

Fabricated content: append `[placeholder]` — e.g., `Testimonial: Jane Doe [placeholder]`

---

## 5 — Content Population

### Text

Use actual brief copy, not Lorem ipsum. Missing text → red `[MISSING: {what}]`. Missing image → red-bordered rect `[IMAGE NEEDED: {what}]`. Fabricated content → `{curly braces}` around text.

### Images and Assets

| Source | Priority | Method |
|---|---|---|
| Brief attachments | 1 | `use_figma` image fill |
| DS icon components | 2 | `search_design_system("icon {name}")` → import |
| Placeholder | 3 | Gray rect with label (see `figma-code-patterns.md`) |

**Placeholder sizes:** Hero 720×450, Feature icon 48×48, Logo 120×40, Avatar 48×48 circle, Product screenshot 560×350.

### Design Tokens

Apply all values from `design-tokens`. Use 5 button styles from `design-tokens` §8: Primary (`button-primary-bg`), Secondary (`button-secondary-bg`), Highlight (`button-highlight-bg`), Outline, Outline-inverse. Section backgrounds use semantic surfaces from §2.5. If Trend Adaptation Brief is active, apply its overrides.

### Design System Reuse

Search for **structural components only** (buttons, icons) — max 3 `search_design_system` calls. Never search for token values.

| Import | Build from Primitives |
|---|---|
| Buttons, icons, badges, input fields | Section layouts, cards, tab panels, logo bars |

Budget: max 1 `use_figma` call on component search. If import fails, build from primitives immediately.

---

## 6 — Generation Process

### Step 1: Verify MCP + Check for Existing Build Card

Confirm MCP server + `/figma-use` skill. If a Build Card file exists from a prior session, follow Session Recovery in `execution-prompts/SKILL.md`.

### Step 2: Discover Page + Check Fonts

**Page discovery (mandatory):** Run `figma-code-patterns.md` §1a — resolves URL node-id to page name. Store in Build Card.

**Font check (mandatory):** Run `figma-code-patterns.md` §8. If unavailable, follow fallback in `token-sources.md` §9. Update Build Card.

### Step 3: Search DS Components (max 3 calls)

### Step 4: Create Main Frame (`figma-code-patterns.md` §2)

### Step 5: Build Sections (2–3 per batch, use Standard Batch Preamble helpers)

### Step 6: Apply Tinted Section Alternation

### Step 7: Self-Healing Verification

Two phases per iteration (max 3 iterations):

**Phase A — Programmatic:** Run verification script (`figma-code-patterns.md` §12). Checks: section heights ≥ min, grid sizing = AUTO, buttons ≤ 60px, FILL inside auto-layout, text overflow.

**Phase B — Visual:** Screenshot via `get_screenshot`. Check: section order, tint alternation, text presence, spacing, no overlaps.

Fix all Phase A issues before Phase B. Never pass verification if any programmatic check fails.

### Step 8: Final Screenshot + Report

---

## 7 — Post-Generation

1. Screenshot + summary (section count, components reused, gaps flagged)
2. Verification results (iterations, fixes, remaining deviations)
3. Fabricated content list (what needs user review)
4. Next steps: correct in Figma → Mode B, or accept → Mode B, or request changes

---

## 8 — Blueprint → Figma (C → A Escalation)

**Path A (Structured):** Blueprint as pre-decided spec → execute Steps 4–8 directly, skip brief parsing. Use when frame will be edited in Figma.

**Path B (Quick Visual):** Push Mode C HTML via `generate_figma_design`. Faster but layers lack structured naming. Use for quick review → Mode B.

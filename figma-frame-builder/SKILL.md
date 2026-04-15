---
name: figma-frame-builder
description: Generates and pushes Figma design frames from design specs using the remote MCP server. Handles frame structure, layer naming, content population, design system reuse, and self-healing verification. Use when creating Figma frames from content briefs (Mode A) or escalating blueprints to Figma.
version: "5.0.9"
---

# Figma Capture — Frame Generation

This file governs how the agent creates Figma design frames from design specs (parsed brief, selected layout, mapped components, applied tokens). It is used exclusively in Mode A (Brief → Figma) and in the C → A escalation path (Blueprint → Figma).

→ For the reverse direction (reading from Figma): see `figma-code-extractor`
→ For component specs being placed in frames: see `component-library`
→ For token values applied to frame elements: see `design-tokens`
→ For section sequencing in the frame: see `layout-patterns`
→ For Plugin API code snippets: see `figma-frame-builder/figma-code-patterns.md`
→ For layout-specific Figma code: see `figma-frame-builder/layout-code-templates.md`

---

## 1 — Prerequisites

Before generating a Figma frame, the agent must have:

| Input | Source | Required |
|---|---|---|
| Parsed brief or Page Blueprint | `brief-parser` parsing output or `{product}-blueprint.md` | Yes |
| Selected layout pattern | `layout-patterns` selection logic | Yes |
| Component mapping | `component-library` section-to-component table | Yes |
| Design tokens | `design-tokens` (with optional trend overrides) | Yes |
| Target Figma file and page | User-specified in prompt | Yes |
| Product class prefix | User-specified in prompt | Yes |
| Remote MCP server connected | `mcp.figma.com/mcp` authenticated | Yes |
| `/figma-use` skill installed | Foundational skill for canvas writes | Yes |

### MCP Server Setup

The remote Figma MCP server (`mcp.figma.com/mcp`) is the default connection method. No local bridge is required.

| Agent | Setup |
|---|---|
| **Claude Code** | Install the Figma plugin: includes MCP server config + skills automatically |
| **Cursor AI** | Install the Figma plugin via agent chat, or add MCP server manually in Settings → MCP |
| **Codex** | Run `codex mcp add figma --url https://mcp.figma.com/mcp` and authenticate |

**Verification:** At session start, confirm the MCP server is connected and the `/figma-use` skill is available before proceeding.

---

## 2 — Figma MCP Tool Selection

The new Figma MCP server consolidates write operations into a single unified tool. Use targeted tools only for specific read tasks.

### Primary Write Tool

| Tool | Purpose | Notes |
|---|---|---|
| `use_figma` | **All write operations** — create, edit, delete, and inspect pages, frames, components, variants, variables, styles, text, and images | Always invoke the `/figma-use` skill before calling. Auto-searches connected design libraries for existing components before creating new ones. |

### Read & Search Tools

| Tool | Purpose | Notes |
|---|---|---|
| `search_design_system` | Find existing components, variables, and styles across connected libraries | Use before creating anything — reuse existing assets first |
| `get_design_context` | Get structured representation of a frame or selection | Returns layout, spacing, colors, typography in one call |
| `get_variable_defs` | Extract variables and styles used in a selection | For reading token values from existing frames |

### Code-to-Canvas Tool

| Tool | Purpose | Notes |
|---|---|---|
| `generate_figma_design` | Push live HTML into Figma as editable design layers | Used in C → Figma escalation path as an alternative to building frames from scratch |

### Skills

| Skill | Purpose | Required |
|---|---|---|
| `/figma-use` | Foundational skill — teaches the agent Plugin API rules, gotchas, and script templates | **Required before every `use_figma` call** |
| Custom skills | Your team's conventions packaged as installable skills | Optional — enhances consistency |

**Rule:** Always pass `skillNames` when calling `use_figma` for logging and workflow tracking.

---

## 3 — Figma MCP Runtime Rules (Critical)

This section addresses the single biggest time sink in frame generation: **the Plugin API context resets between `use_figma` calls**. Every rule here is derived from Figma's official `figma-use` skill documentation and confirmed by production testing.

→ Official reference: `https://github.com/figma/mcp-server-guide/blob/main/skills/figma-use/SKILL.md`

### 3.1 — Context Reset Behavior

**Every `use_figma` call runs in a fresh plugin context.** The frame created in Call 1 is invisible to Call 2 unless explicitly re-discovered. This is by design — not a bug.

| Behavior | Implication |
|---|---|
| `figma.currentPage` resets to the first page on each call | Must call `setCurrentPageAsync` at the start of every call if targeting a non-default page |
| `figma.getNodeById(id)` works — but only after page is loaded | Must `setCurrentPageAsync` before accessing any node by ID |
| `page.children` may not be populated | Only populated after `setCurrentPageAsync` completes |
| `getPluginData()` / `setPluginData()` are NOT supported | Cannot persist data between calls via plugin data — use returned node IDs instead |
| `console.log()` output is NOT returned to the agent | Use `return` for all output — never rely on console |
| `figma.notify()` throws "not implemented" | Never use — use `return` for status messages |
| `figma.closePlugin()` must never be called | Code is auto-wrapped — calling it will error |
| Code must NOT be wrapped in async IIFE | Already auto-wrapped — wrapping again causes errors |

### 3.2 — Node ID Persistence (Mandatory)

**Every `use_figma` call MUST return all created and mutated node IDs.** This is the only reliable way to reference nodes across calls.

**Return format (required at the end of every script):**
```javascript
return {
  createdNodeIds: [mainFrame.id, heroSection.id, featureSection.id],
  mutatedNodeIds: [],
  summary: "Created main frame + 2 sections"
};
```

**Rules:**
- Store every returned ID between calls — these are the only reliable handles
- Pass stored IDs as string literals into subsequent `use_figma` calls
- Never assume a node can be found by name — name searches are unreliable across context resets
- If a `detachInstance()` call changes IDs, re-discover from a stable parent frame

### 3.3 — Frame-Finder Preamble

**Paste this pattern at the TOP of every `use_figma` call after the first one.** It navigates to the correct page and locates the main frame by its stored ID.

```javascript
// === Frame-Finder Preamble (required for all calls after initial creation) ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
if (!targetPage) return { error: "Page '{PAGE_NAME}' not found" };
await figma.setCurrentPageAsync(targetPage);

const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame not found — ID may have changed" };
// === End Preamble — mainFrame is now available ===
```

Replace `{PAGE_NAME}` with the target Figma page name and `{MAIN_FRAME_ID}` with the ID returned from the first call.

### 3.4 — Batching Strategy

With a ~50K character limit per `use_figma` call, a full landing page (8–12 sections) cannot be built in one call. Split into batches:

**Batch plan for a typical 10-section page:**

| Batch | Sections | Why This Grouping |
|---|---|---|
| Batch 1 | Main frame + Hero + Trust Signals | Foundational — establishes the frame, returns the main frame ID used by all subsequent batches |
| Batch 2 | Value Proposition + Feature Grid | Content-heavy sections with multiple child components |
| Batch 3 | Feature Deep-Dive + Testimonials | Alternating layout patterns |
| Batch 4 | Integration Grid + Metrics Bar + FAQ | Simpler sections, can fit more per call |
| Batch 5 | Closing CTA + final adjustments | Last section + any spacing/color fixes |

**Rules:**
- Batch 1 is always the main frame creation — its returned ID is used by every subsequent batch
- Every batch starts with the Frame-Finder Preamble (Section 3.3)
- Every batch ends with `return { createdNodeIds: [...], mutatedNodeIds: [...] }`
- Target 2–3 sections per batch (adjust based on component complexity)
- If a batch fails, the frame is atomic — no partial nodes are created. Retry the same batch.
- Between batches, verify the previous batch's nodes exist before proceeding

**Estimated call budget:**

| Section Count | Estimated Batches | Total `use_figma` Calls (incl. verification) |
|---|---|---|
| 6–8 sections | 3–4 build + 1–2 verify | 5–6 calls |
| 9–12 sections | 4–5 build + 2–3 verify | 7–8 calls |
| 12+ sections | 5–6 build + 2–3 verify | 8–10 calls |

### 3.5 — Plugin API Gotchas Quick Reference

These are from Figma's official docs — violating any of them causes silent failures or errors.

**Colors:**
- Use 0–1 range, not 0–255: `{ r: 0.91, g: 0.08, b: 0.17 }` for `#E9142B`
- Paint objects use `{ r, g, b }` only — no `a` field. Opacity goes at paint level: `{ type: 'SOLID', color: {r, g, b}, opacity: 0.5 }`
- Fills and strokes are read-only arrays — clone, modify, reassign. Never mutate in place.

**Layout sizing (critical for collapsed frames):**
- `layoutSizingHorizontal/Vertical = 'FILL'` must be set AFTER `parent.appendChild(child)` — setting before throws
- `resize()` must be called BEFORE setting sizing modes — `resize()` resets them to `FIXED`
- Correct order: create node → `resize()` → `appendChild()` → set sizing modes

**Text:**
- `await figma.loadFontAsync({ family, style })` BEFORE any text property change — never skip, never fire-and-forget
- `lineHeight` and `letterSpacing` use `{ unit: 'PIXELS', value: N }` format, not bare numbers
- Use `await figma.listAvailableFontsAsync()` to check font availability before loading

**Positioning:**
- New top-level nodes default to (0,0) — position them to the right of existing content
- Nested nodes are positioned by their parent's auto-layout — don't manually position them

**Variables:**
- Always set `variable.scopes` explicitly — default `ALL_SCOPES` pollutes every property picker
- Use specific scopes: `["FRAME_FILL", "SHAPE_FILL"]` for backgrounds, `["TEXT_FILL"]` for text

**Error handling:**
- On `use_figma` error, stop immediately — failed scripts are atomic (no partial execution)
- Every async call must be `await`ed — unawaited calls cause silent failures

→ For the complete code patterns reference: see `figma-frame-builder/figma-code-patterns.md`

---

## 4 — Frame Structure

### 3.1 — Top-Level Frame

The agent creates one top-level frame per landing page on the specified Figma page.

| Property | Value |
|---|---|
| Frame name | `{Product Name} — Landing Page` |
| Width | `1440px` (standard desktop canvas) |
| Height | Auto (grows with content) |
| Layout mode | Vertical auto-layout |
| Padding | `0` (sections handle their own padding) |
| Fill | `color-bg-page` from `design-tokens` |

### 3.2 — Section Frames

Each page section is a child frame within the top-level frame.

| Property | Value |
|---|---|
| Frame name | `Section: {Section Type}` (e.g., `Section: Hero`, `Section: Feature Grid`) |
| Width | Fill parent (100% of top-level frame) |
| Height | Hug contents (with min-height — see below) |
| Layout mode | Vertical auto-layout |
| Padding top/bottom | `section-padding-y` from `design-tokens` |
| Padding left/right | Calculated to center content at `content-max-width` |
| Fill | Based on tinted section alternation rules from `layout-patterns` |

**Collapsed Frame Prevention:** "Hug contents" alone can produce visually collapsed sections when child frames don't push enough height. Every section frame must have a `min-height` set:

| Section Type | Min-Height |
|---|---|
| Hero | `500px` |
| Feature Grid / Feature Row | `300px` |
| Testimonial / Logo Bar / Metrics Bar | `200px` |
| CTA / Pricing | `250px` |
| FAQ / Accordion | `200px` |
| All other sections | `200px` |

After creating a section, the agent must verify the rendered height exceeds min-height. If it doesn't, the section is collapsed and needs fixing (see Section 7, Step 6).

### 3.3 — Component Frames

Individual components within a section.

| Property | Value |
|---|---|
| Frame name | `{Component Type}: {Content Label}` (e.g., `Feature Card: Network Monitoring`) |
| Width | Based on grid column span |
| Height | Hug contents (with min-height — see below) |
| Layout mode | Vertical or horizontal auto-layout (based on component spec) |
| Padding | `card-padding` from `design-tokens` (for card-type components) |

**Collapsed Frame Prevention:** Card and component frames also collapse when inner text or image layers don't have explicit sizing. Every component frame must have a `min-height` set:

| Component Type | Min-Height |
|---|---|
| Feature Card | `150px` |
| Testimonial Card | `120px` |
| Pricing Card | `200px` |
| Tab Panel content area | `200px` |
| All other card/component frames | `100px` |

**Root cause fix:** When populating content inside a component frame, ensure every text layer has `textAutoResize: "HEIGHT"` (width fixed, height grows with content) and every image placeholder has an explicit height set. These two properties are the most common cause of collapsed frames.

**Common collapse patterns and their fixes (from production testing):**

| Pattern | Cause | Fix |
|---|---|---|
| Section shows 10–19px height | `primaryAxisSizingMode` set to `AUTO` before children appended | Set `primaryAxisSizingMode = 'AUTO'` AFTER all children are appended |
| Card shows as thin strip | `resize()` called after sizing mode set | Call `resize()` BEFORE setting any sizing modes — `resize()` resets them to `FIXED` |
| Text exists but section is blank | Text node has `textAutoResize: "NONE"` | Set `textAutoResize: "HEIGHT"` on every text node |
| Image placeholder has 0 height | Image frame created with no explicit size | Always `resize()` image placeholders to explicit dimensions |
| Frame collapses after `detachInstance()` | Instance detach changes node IDs | Re-discover nodes from stable parent, don't cache detached IDs |

**Correct operation order (critical):**
```
1. Create frame → figma.createFrame()
2. resize()     → frame.resize(width, height)     // BEFORE sizing modes
3. Layout mode  → frame.layoutMode = "VERTICAL"
4. Sizing       → frame.primaryAxisSizingMode = "AUTO"
5. Min-height   → frame.minHeight = 200
6. Add children → frame.appendChild(child)         // BEFORE FILL sizing
7. FILL sizing  → child.layoutSizingHorizontal = "FILL"  // AFTER appendChild
```

→ For complete code patterns: see `figma-frame-builder/figma-code-patterns.md`

---

## 5 — Layer Naming Convention

Consistent layer names enable Mode B to parse the frame reliably when generating code later.

### Naming Pattern

```
{Layer Type}: {Descriptive Label}
```

### Layer Types

| Type Prefix | Used For | Examples |
|---|---|---|
| `Section` | Page-level sections | `Section: Hero`, `Section: Features`, `Section: Closing CTA` |
| `Hero` | Hero variant | `Hero: Split Image`, `Hero: Full Bleed` |
| `Feature Card` | Individual feature block | `Feature Card: Real-time Alerts` |
| `Feature Grid` | Feature card container | `Feature Grid: Core Features` |
| `Feature Row` | Alternating image-text row | `Feature Row: Dashboard Analytics` |
| `Tab Panel` | Tabbed feature section | `Tab Panel: Advanced Features` |
| `Testimonial` | Customer quote | `Testimonial: John Smith, Acme Corp` |
| `Logo Bar` | Logo row | `Logo Bar: Trusted By` |
| `Metrics Bar` | Statistics row | `Metrics Bar: Key Numbers` |
| `CTA` | Call-to-action block | `CTA: Closing`, `CTA: Mid-page` |
| `FAQ` | FAQ section | `FAQ: Common Questions` |
| `Pricing` | Pricing section | `Pricing: Plans` |
| `Text` | Text elements | `Text: H1`, `Text: Body`, `Text: Caption` |
| `Image` | Image placeholders | `Image: Hero Screenshot`, `Image: Feature Icon` |
| `Button` | CTA buttons | `Button: Primary`, `Button: Secondary` |
| `Divider` | Section separators | `Divider: Line`, `Divider: Shaped` |

### Rules
- Every layer must have a type prefix — no unnamed or generic layers (e.g., no `Frame 47` or `Group 12`)
- Text layers include their heading level: `Text: H1`, `Text: H2 — Section Title`, `Text: Body`
- Image layers indicate content purpose: `Image: Hero Screenshot` not just `Image`
- Button layers indicate hierarchy: `Button: Primary CTA`, `Button: Secondary CTA`

---

## 6 — Content Population

### 5.1 — Text Content

All text from the parsed brief or blueprint is placed in the frame using actual copy, not placeholder "Lorem ipsum" text.

| Element | Content Source |
|---|---|
| Hero H1 | `headline` from parsed brief hero section |
| Hero subheadline | `subheadline` from parsed brief hero section |
| CTA button labels | `primary_cta` and `secondary_cta` from parsed brief |
| Feature headings | Feature `name` from parsed brief |
| Feature descriptions | Feature `description` from parsed brief |
| Testimonial quotes | `quote` + `attribution` from parsed brief |
| Section headings | Generated from section type (e.g., "Why Choose {Product}") or from brief if provided |

**Rule:** If the brief has content gaps (flagged in parsing), place a visual indicator in the frame:
- Missing text → Red placeholder text: `[MISSING: {description of what's needed}]`
- Missing image → Red-bordered rectangle with label: `[IMAGE NEEDED: {description}]`

### 5.2 — Images and Assets

| Asset Type | Frame Treatment |
|---|---|
| Available (from brief attachments) | Placed directly via `use_figma` |
| Referenced but not provided | Gray placeholder rectangle with label and TODO note |
| Icons (not provided) | Placeholder circle or square with icon description label |

**Note:** Image support in `use_figma` is expanding. If image placement fails, flag it for manual placement and continue with placeholder rectangles.

### 5.3 — Design Tokens

All visual properties are applied using values from `design-tokens`:

| Property | Token Applied |
|---|---|
| Text colors | `color-text-primary`, `color-text-secondary`, etc. |
| Background fills | `color-bg-page`, tint surface colors |
| Button colors | `color-cta`, `color-cta-hover`, `color-cta-active` |
| Spacing | `section-padding-y`, `space-*` scale |
| Typography | `font-heading`, `font-body`, size/weight/line-height tokens |
| Shadows | `shadow-sm`, `shadow-md`, etc. |
| Border radius | `radius-sm`, `radius-md`, etc. |

If a Trend Adaptation Brief is active, apply the token overrides from the trend brief instead of base values for any overridden tokens.

### 5.4 — Design System Reuse

Before creating any element, the agent should check for existing design system components — but only for **structural components** (buttons, cards, nav bars), not for token values.

```
1. Call search_design_system with the component type (e.g., "button", "card")
   — Limit to ONE search call per component type, max 3 calls total per session
2. If a matching library component exists → use it via use_figma (instantiate)
3. Only create from scratch when no library match exists
```

**Restriction: Do NOT search Figma for design token values.** The agent already has all token values collected from `design-tokens/token-values.md` (via the token source selected at session start). Searching Figma for colors, fonts, spacing, or other token values wastes time and risks conflicting with the already-collected tokens. Apply tokens directly from the collected values — never from Figma variable lookups during frame generation.

| Allowed | Not Allowed |
|---|---|
| `search_design_system("button")` — reuse a button component | `search_design_system("colors")` — tokens already collected |
| `search_design_system("card")` — reuse a card component | `search_design_system("typography")` — tokens already collected |
| `search_design_system("navigation")` — reuse a nav component | `get_variable_defs` for token values — tokens already collected |

---

## 7 — Generation Process

### Step 1: Verify Connection and Skills
```
Confirm remote MCP server is connected
Confirm /figma-use skill is available
```
If either is missing, stop and instruct the user to set up the Figma MCP plugin.

### Step 2: Search for Existing Components (Structural Only)
```
Call search_design_system → check for reusable structural components
(buttons, cards, nav bars) — max 3 search calls total
```
Catalog available components for reuse. Note any gaps that require building from scratch.

**Do NOT search for token values** (colors, fonts, spacing). All tokens are already collected from the token source selected at session start. Apply them directly.

### Step 3: Create Top-Level Frame
```
Invoke /figma-use skill
Call use_figma → create frame on target page with properties from Section 4.1
```

### Step 4: Build Section Frames (Top to Bottom)
For each section in the layout pattern's sequence:
```
Call use_figma → create section frame → set dimensions, padding, fill
  → Create component frames within section (reuse library components where possible)
    → Populate text content
    → Place images or placeholders
    → Apply token values (bind to variables when available)
```

### Step 5: Apply Tinted Section Alternation
```
Walk through sections → assign tint pairs per layout_patterns rules
```

### Step 6: Self-Healing Verification Loop

This replaces the single-pass screenshot of v3.0 with an iterative verification cycle.

```
LOOP (max 3 iterations):
  1. Take screenshot of the generated frame via use_figma
  2. Compare screenshot against design spec:
     - Section order matches layout pattern?
     - Tinted sections alternate correctly?
     - Text content is present and complete?
     - Component spacing looks correct?
     - No broken layouts or overlapping elements?
     - **Collapsed frame check** (CRITICAL — see below)
  3. If mismatches found:
     - Log each mismatch with description
     - Fix via use_figma (adjust spacing, reorder, fix text, etc.)
     - Continue to next iteration
  4. If all checks pass → exit loop
```

**Collapsed Frame Detection (mandatory in every iteration):**

A "collapsed frame" is a section or component that renders with near-zero visible height despite having content inside. This is the most common visual defect and must be checked every iteration.

Detection method:
1. In the screenshot, check each section — does it occupy visible vertical space proportional to its content?
2. Any section that appears as a thin strip, blank band, or is visually absent is collapsed
3. Any card/component within a section that shows only a sliver or no visible content is collapsed

Fix procedure for collapsed sections:
```
1. Read the collapsed frame via get_design_context → check actual height
2. If height < min-height from Section 4.2/4.3 → collapsed confirmed
3. Check child layers:
   a. Text layers missing textAutoResize: "HEIGHT" → fix
   b. Image placeholders missing explicit height → set height
   c. Inner frames set to "Hug contents" with no min-height → set min-height
   d. Auto-layout spacing set to 0 or negative → fix to design token spacing
4. After fixing children, if section still below min-height → set explicit min-height
5. Re-screenshot to verify fix
```

**Rule:** Never mark the verification loop as passed if any section or card appears collapsed in the screenshot. This check takes priority over all other checks.

**Exit conditions:**
- All visual checks pass → proceed to Step 7
- Max iterations reached → proceed to Step 7 with deviation log
- Critical failure (frame didn't generate, MCP error) → stop and report

### Step 7: Final Screenshot and Report
```
Take final screenshot via use_figma
Present to user with summary
```

---

## 8 — Post-Generation

After the frame is generated:

1. **Present to user:** Show a screenshot of the generated frame and summarize what was built (section count, component types used, library components reused, any content gaps flagged)
2. **Verification summary:** Report results from the self-healing loop — how many iterations, what was fixed, any remaining deviations
3. **Flag issues:** List any content gaps, missing images, or decisions the agent made that the user should review
4. **Next steps:** Remind the user of their options:
   - Review and correct in Figma, then run Mode B for code
   - Accept as-is and run Mode B immediately
   - Request specific changes in the current session

---

## 9 — Blueprint → Figma (C → A Escalation)

Two escalation paths are available when Mode C output needs to become a Figma frame.

### Path A: Blueprint → use_figma (Structured Build)

When Mode C escalates to Figma using the blueprint as a pre-decided spec, the agent executes Steps 3–7 from Section 7 directly — no brief re-parsing or pattern selection.

**When to use:** When you want a structured Figma frame built from the blueprint with proper layer naming, auto-layout, and design system bindings. Best for frames that will be edited further in Figma.

**Prompt recognition:** If the user's prompt includes a blueprint file reference and says "do not re-analyze" or "use this as the design spec," the agent follows this path.

### Path B: HTML → generate_figma_design (Quick Visual)

When Mode C has already produced working HTML, the agent can push the rendered HTML directly into Figma as editable layers.

```
1. Serve the Mode C HTML output (index.html + styles.css + script.js)
2. Call generate_figma_design with the live URL or localhost
3. Figma receives editable layers matching the rendered HTML
4. User corrects in Figma as needed
5. Run Mode B against the corrected frame for final production code
```

**When to use:** When you want a fast visual representation in Figma without building structured frames from scratch. The output layers mirror the rendered HTML rather than following the Section 5 naming convention. Best for quick review cycles.

**Tradeoff:** Path B layers won't have the structured naming and auto-layout of Path A. If extensive Figma editing is planned, Path A is preferred. If the goal is visual review followed by Mode B code generation, Path B is faster.

→ For Mode B code generation from either path: see `figma-code-extractor`

---

## 10 — Custom Skill Packaging (Optional)

Your skill files can be packaged as installable Figma skills for sharing across teams or the Figma Community.

### Converting figma-frame-builder to a Figma Skill

The Figma skill format uses YAML frontmatter instead of HTML comment metadata:

```markdown
---
name: me-generate-landing-page
description: "Generate a landing page frame from a content brief using the UX Skill File Architecture. Use when building new product landing pages that follow the design system standards."
compatibility: Requires the figma-use skill to be installed alongside this skill
metadata:
  mcp-server: figma
  version: 5.0
  author: "{PLACEHOLDER}"
---

# Generate landing page

**Always pass `skillNames: "me-generate-landing-page"` when calling `use_figma` as part of this skill.**

**You MUST invoke the `figma-use` skill before every `use_figma` call.**

## When to use
- Creating new product landing pages from a content brief
- Escalating a Mode C Page Blueprint into a Figma frame
- Rebuilding an existing landing page with updated content

## Instructions
1. Read the content brief and parse using brief-parser rules
2. Search connected libraries for existing design system components
3. Infer page type and select section layout types from layout-patterns
4. Create the top-level frame at 1440px width
5. Build sections top to bottom, reusing library components
6. Apply design tokens from design-tokens
7. Run the self-healing verification loop (screenshot → compare → fix)
8. Present final screenshot with summary

## Examples
**Input:** "Generate a landing page for MSP Central using the attached brief"
**Output:** A 1440px Figma frame with 7 sections (Hero, Trust Signals, Feature Grid, Feature Deep-Dive, Testimonials, Integration Grid, Closing CTA), all text populated from the brief, library buttons and cards reused, tinted sections alternating correctly.
```

### Supporting Files

A packaged skill can include:
- `scripts/` — Reusable Plugin API scripts for common frame operations
- `references/` — Token value tables, component spec summaries
- `assets/` — Template frames or starter components

→ For skill authoring details: see Figma developer docs at `developers.figma.com/docs/figma-mcp-server/create-skills/`

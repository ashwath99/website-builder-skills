# Agent-Specific Notes, Prompt Modifiers & Validation Checklists

→ This file is a reference for execution-prompts/SKILL.md

---

## 6 — Agent-Specific Notes

### Claude Code (Terminal Agent)
- **File access:** Reads skill files directly from the project directory
- **Figma MCP:** Install Figma plugin — bundles MCP server config + foundational skills automatically
- **Setup command:** Plugin installation is initiated from the Claude Code terminal
- **Output:** Writes files directly to the specified output folder
- **Strengths:** Full filesystem control, can run asset compression commands (`svgo`, `imagemin`), can chain operations
- **Token note:** Long pipeline runs may approach context limits; if this happens, split into separate sessions per mode

### Cursor AI (IDE Agent)
- **File access:** Reads skill files from the workspace/project folder open in the IDE
- **Figma MCP:** Install Figma plugin via agent chat — bundles MCP server config + skills
- **Output:** Creates/modifies files in the workspace; changes visible immediately
- **Strengths:** Inline editing, easy iteration, visual diff
- **Workspace tip:** Keep skill files in a `_skills/` folder to avoid clutter
- **Reference syntax:** Use `@filename` to point the agent to specific files (e.g., `@figma-code-extractor/SKILL.md`, `@hero-image.png`)

### Codex (CLI Agent)
- **File access:** Reads from the project directory like Claude Code
- **Figma MCP:** Run `codex mcp add figma --url https://mcp.figma.com/mcp` and authenticate
- **Skills:** Install skills manually — download from Figma's mcp-server-guide repository and place in the project
- **Output:** Writes files to specified output path
- **Note:** If the agent stalls between phases, break the prompt into per-phase instructions

### All Agents — Skills Setup
The `/figma-use` foundational skill is **required** before any `use_figma` call. It contains Plugin API rules and script templates that prevent failures. When using the Figma plugin for Claude Code or Cursor, this skill is included automatically. For other agents, install manually from the Figma MCP server guide.

---

## 7 — Prompt Modifiers

Optional additions appended to any mode's prompt template.

### With Trend Adaptation
```
Also read: trend-adapter/SKILL.md

Apply the Trend Adaptation Brief: {trend-brief-filename}
Use the token overrides and layout modifications specified in the trend brief.
All brand invariants must still pass — verify after applying overrides.
```

### With Variation Selection
```
Also read: variation-explorer/SKILL.md

Use Variation Spec: {variation-spec-filename}
Selected variant: {variant-name} (e.g., "Trust Fortress")
Follow the section sequence and axis values defined for this variant.
```

### With Both Trend + Variation
```
Also read: trend-adapter/SKILL.md, variation-explorer/SKILL.md

Apply Trend Adaptation Brief: {trend-brief-filename}
Use Variation Spec: {variation-spec-filename}, selected variant: {variant-name}
Trend overrides take precedence for token values; variant defines page structure.
```

### Density Override
```
Override density profile: {breathing | standard | comprehensive}
Adjust section padding and content gap tokens per trend-adapter/SKILL.md Section 2.1.
```

### Specific Section Focus
```
Generate only the following sections (not full page):
- Hero section
- Feature grid section
- Final CTA section
Apply all skill file rules to these sections as if building the full page.
```

### With Visual Comparison (Mode B)
```
After generating code, push the rendered HTML back into Figma using
generate_figma_design for side-by-side comparison with the original frame.
Log any visual discrepancies in the deviation report.
```

---

## 8 — Validation Checklist (All Modes)

After any execution, the agent self-checks against this list.

### Code Output (Modes B and C)
- [ ] Output is exactly 3 files: `index.html`, `styles.css`, `script.js`
- [ ] All classes use BEM naming with `{product}-` prefix
- [ ] All design tokens are CSS custom properties (no hardcoded values in rulesets)
- [ ] Variable-bound Figma tokens map to matching CSS custom property names (Mode B — from get_design_context or use_figma extraction)
- [ ] Primary button uses `button-primary-bg` from `design-tokens/token-values.md`
- [ ] Headings use `font-heading` from `design-tokens/token-values.md`
- [ ] Responsive breakpoints at 480px and 1024px only
- [ ] Desktop-first responsive approach
- [ ] jQuery used only for UI interactions — no other JS libraries
- [ ] Image paths use `./assets/` convention
- [ ] Uncertain image mappings have `<!-- TODO -->` comments
- [ ] Section surfaces use semantic surface modifiers (`--brand`, `--subtle`, `--inverse`, `--default`)
- [ ] No inline styles in HTML
- [ ] Heading hierarchy is correct (H1 → H2 → H3, no skips)
- [ ] Alt text on all images
- [ ] CSS file follows section ordering from `css-js-generator/SKILL.md` Section 3
- [ ] JS wrapped in `$(document).ready()`

→ Full code quality rules: see `css-js-generator/SKILL.md` Section 9
→ Full HTML rules: see `html-generator/SKILL.md`
→ Full Figma-to-code review checklist: see `figma-code-extractor/SKILL.md` Section 6

### Figma Output (Mode A)
- [ ] Frame pushed to correct file and page via `use_figma`
- [ ] Layer naming follows convention from `figma-frame-builder/SKILL.md` Section 4
- [ ] Design tokens match `design-tokens/SKILL.md` — bound to Figma variables when available
- [ ] Library components reused where possible (searched via `search_design_system`)
- [ ] All text content from brief is present — nothing omitted
- [ ] Content gaps flagged visually (red placeholders)
- [ ] Tinted section alternation follows `layout-patterns/SKILL.md` Section 2.2
- [ ] Self-healing loop completed — verification summary included

→ Full Figma generation rules: see `figma-frame-builder/SKILL.md`

### Blueprint Output (Mode C)
- [ ] Blueprint saved as `{product}-blueprint.md` in project folder
- [ ] All sections from parsed brief are represented
- [ ] Component and variant selections reference `component-library/SKILL.md` names
- [ ] Token values listed match `design-tokens/SKILL.md` (with trend overrides if applicable)
- [ ] Asset manifest categorizes all images into three types
- [ ] Interaction patterns reference specific `css-js-generator/SKILL.md` sections

### General (All Modes)
- [ ] All referenced skill files were read before execution began
- [ ] Content brief was parsed and sections confirmed before design decisions
- [ ] If trend or variation modifiers were applied, brand invariants still pass
- [ ] Deviations from expected values are logged and presented to user
- [ ] MCP server connection verified before any Figma operations

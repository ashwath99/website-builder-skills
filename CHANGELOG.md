# Changelog

All notable changes to the Website Builder Skills system are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [4.0.1] — 2026-03-26

### Added

- **v4 presentation deck** (`docs/website-builder-skills-presentation-v4.pdf`) — Updated slide deck covering remote Figma MCP, centralized tokens, self-healing loop, and all v4.0 features.
- **v4 video walkthrough** (`docs/website-builder-skills-v4.mp4`) — New video walkthrough for the v4.0 skill system.

### Changed

- **`README.md`** — Media section now links to v4 PDF and v4 video.
- **`docs/GUIDE.md`** — Media section now links to v4 PDF and v4 video.

---

## [4.0] — 2026-03-25

### Added

- **`design_system_prompt.md`** — New centralized token value file. All 85 `{PLACEHOLDER}` values across the system are now filled from this single file, enabling per-product customization without modifying core skill files.
- **Self-healing verification loop** (Mode A) — After generating a Figma frame, the agent now screenshots → compares against spec → fixes mismatches → re-screenshots, up to 3 iterations. Defined in `figma_capture.md` Section 6.
- **Design system reuse workflow** — Before creating any component in Figma, the agent must call `search_design_system` to check for existing library components. Defined in `figma_capture.md` Section 5.4.
- **Variable-first token mapping** (Mode B) — When Figma variables are bound to frame elements, their names are used directly as the basis for CSS custom property naming, replacing the pixel-to-token matching approach. Defined in `figma_to_code.md` Phase 1 Step 2 and Phase 2 Step 3.
- **Two new escalation paths from Mode C**:
  - C → Figma (quick visual): Push generated HTML to Figma via `generate_figma_design` for fast visual review.
  - C → Figma → correct → B: Quick visual review, then code generation from the corrected frame.
  - (Total: 4 escalation paths, up from 2 in v3.0)
- **Code Connect integration** (Mode B, optional) — Leverage Code Connect mappings to match Figma components to code implementations. Defined in `figma_to_code.md` Section 8.
- **Figma skill packaging guide** — Instructions for packaging `figma_capture.md` as an installable Figma skill with YAML frontmatter. Defined in `figma_capture.md` Section 9.
- **Variable extraction script** — Plugin API script for extracting Figma variable bindings, replacing the deprecated `figma_get_variables` tool. Defined in `skill_usage_matrix.md` Section 2.6.
- **MCP requirements table** — Per-mode MCP connection requirements documented in `skill_usage_matrix.md`.
- **`generate_figma_design` tool** — New code-to-canvas tool for pushing HTML to Figma as rendered frames.

### Changed

- **Figma MCP server** — Migrated from local desktop bridge (23 individual tools) to official remote Figma MCP plugin at `mcp.figma.com/mcp` with 4 unified tools:
  - Write: `use_figma` (replaces `figma_create_child`, `figma_set_text`, `figma_set_fills`, `figma_set_strokes`, `figma_set_image_fill`, `figma_resize_node`, `figma_move_node`, `figma_rename_node`, `figma_clone_node`)
  - Read: `get_design_context` (replaces `figma_get_component_for_development`, `figma_get_file_data`, `figma_take_screenshot`)
  - Search: `search_design_system` (replaces `figma_search_components`, `figma_get_component_details`)
  - Canvas: `generate_figma_design` (new)
- **`skill_usage_matrix.md`** — Expanded into a full master reference with Figma MCP tool mapping, deprecated tools list, variable extraction script, and MCP requirements by mode.
- **Agent setup** — Simplified from complex per-agent local bridge configuration to unified Figma plugin installation (bundles MCP server config + foundational skills).
- **`workflow.md`** — Updated pipeline phases to reference remote MCP server; added Figma MCP server section and combined workflow definitions.
- **`agent_execution_prompt.md`** — Updated all mode prompts for new tool names; added design system search step (Mode A), self-healing loop step (Mode A), variable extraction step (Mode B), and visual comparison modifier (Mode B).
- **All v3 files** — Bumped metadata to version 4.0 and updated `last_updated` to 2026-03-25.
- **`design_guide.md`** — Added note directing agents to read `design_system_prompt.md` for all `{PLACEHOLDER}` values.
- **Cross-references** — `components.md`, `layout_patterns.md`, and `css_js_rules.md` now reference `design_system_prompt.md` in their `referenced_by` metadata.

### Deprecated

- 13 individual Figma MCP tools from v3.0 (replaced by `use_figma`, `get_design_context`, and `search_design_system`). Full deprecation table in `skill_usage_matrix.md` Section 2.4.
- Direct `{PLACEHOLDER}` editing in `design_guide.md` — values are now managed exclusively in `design_system_prompt.md`.

---

## [3.0] — 2026-03-16

### Added

- Initial public release of the 11-file skill system.
- Three execution modes: A (Brief → Figma), B (Figma → Code), C (Brief → Code).
- Combined workflows: A → correct → B and C → iterate.
- Full component library (25+ components) in `components.md`.
- 6 page layout patterns in `layout_patterns.md`.
- 7 trend dimensions and 5 named profiles in `trend_adaptation.md`.
- 6 variation axes in `variation_generator.md`.
- BEM class naming with product prefix in `html_structure.md`.
- jQuery interaction patterns in `css_js_rules.md`.
- Agent-specific notes for Claude Code, Cursor AI, and Codex.
- Documentation: README, GUIDE, presentation PDF, infographic, video.

---

## [0.1.0] — 2026-03-10

### Added

- Initial pre-release with core skill files.
- Video walkthrough as release asset.

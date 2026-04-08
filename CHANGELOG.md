# Changelog

All notable changes to the Website Builder Skills system are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [5.0.1] — 2026-04-09

### Changed

- **`layout-patterns` — full rewrite to page layout system** — Expanded from 6 fixed landing page patterns to a full page layout system covering 14 marketing website page types. Key additions:
  - **Section Layout Types** (Section 3) — 20 named layout types across 5 categories: horizontal splits (`split-50`, `split-60-40`, `split-reverse`, etc.), grid layouts (`grid-2col` through `bento`, `masonry`, `card-index`), sidebar layouts (`sidebar-left`, `sidebar-right`, `sticky-sidebar`), linear layouts (`timeline`, `step-flow`, `accordion-stack`, `tab-panel`), and specialty layouts (`comparison-table`, `media-gallery`, `form-focused`, `map-content`, `stat-band`, `logo-bar`, `quote-callout`).
  - **Page Type Inference** (Section 4) — Content signal tables for all 14 page types (Product Landing, Feature Detail, Pricing, Home, About, Case Study, Blog Article, Blog Index, Event/Webinar, Contact, Partner/Integrations, Resource/Download, Documentation Hub, Error). Includes ambiguity resolution rules and multi-page brief handling.
  - **Page Assembly Logic** (Section 5) — Per-page-type section applicability tables with layout type options and required/optional status. Replaces the previous 6 pre-built fixed patterns.
  - **Universal Sequencing Rules** (Section 6) — Promoted from pattern-specific rules to universal hard and soft rules applying across all page types.
  - Bento grid moved to Section 7, Step Flow layout moved to Section 8 as named layout reference sections.
  - Boundary clarification: section layout types (split, sidebar, bento, etc.) now owned by `layout-patterns`; `component-library` retains component identity and content slots only.

- **`brief-parser` — targeted update for full-site scope** — Three focused changes:
  - **Step 2 split into 2a and 2b** — Added page type inference pass (2a) alongside audience classification (2b). Inference reads content signals and matches to one of 14 page types with an explicit ambiguity resolution rule.
  - **Step 3 section types expanded** — From 12 landing-page-specific types to 45+ types organised across 8 categories: Core, Product & Feature, About & Company, Case Study, Blog & Editorial, Event & Registration, Navigation & Index, Contact & Support, plus Universal utility sections.
  - **Section 5 handoff updated** — `layout-patterns` now receives inferred page type + asset availability in addition to section list + audience type + feature count.
  - Added "General / consumer" as a sixth audience type to cover non-B2B page types.
  - Frontmatter description updated to reflect full-site scope ("web page structure" replaces "landing page structure").

- **Cross-reference fixes** across 5 dependent skills to reflect new section numbering in `layout-patterns`:
  - `trend-adapter` — bento ref updated to Section 7
  - `variation-explorer` — sequencing rules ref updated to Section 6, bento ref to Section 7, validation checklist updated
  - `execution-prompts` — "select layout pattern" wording updated to "infer page type and select layout types" (3 instances)
  - `figma-frame-builder` — instruction step updated to match new inference-first flow
  - `master-reference` — ownership table updated with new `layout-patterns` responsibilities

### Removed

- **`v4.0/` folder** — Removed legacy v4.0 skill files from repository. Historical context preserved in CHANGELOG.

---

## [5.0] — 2026-04-07

### Added

- **SKILL.md format** — Every skill now follows the universal Agent Skills specification (YAML frontmatter with `name`, `description`, `version`) for cross-IDE compatibility.
- **`README.md`** — New v5.0 README documenting the restructured skill directory, architecture, and usage.

### Changed

- **Restructured into independent skill directories** — All 13 skills moved from flat files into their own folders with `SKILL.md` entry points. Files over 500 lines split into SKILL.md + reference files for progressive disclosure.
- **Ownership-based naming** — Skills renamed by what they own: `workflow.md` → `pipeline-workflow/`, `content_brief.md` → `brief-parser/`, `design_guide.md` + `design_system_prompt.md` → `design-tokens/`, `components.md` → `component-library/`, `layout_patterns.md` → `layout-patterns/`, `figma_capture.md` → `figma-frame-builder/`, `figma_to_code.md` → `figma-code-extractor/`, `html_structure.md` → `html-generator/`, `css_js_rules.md` → `css-js-generator/`, `trend_adaptation.md` → `trend-adapter/`, `variation_generator.md` → `variation-explorer/`, `agent_execution_prompt.md` → `execution-prompts/`, `skill_usage_matrix.md` → `master-reference/`.
- **All cross-references updated** — Every internal file reference now uses v5.0 skill paths instead of v4.0 filenames.
- **Cross-IDE compatibility confirmed** — Works with Claude Code, Cursor AI, VS Code / GitHub Copilot, Antigravity (Google), Codex CLI, and Gemini CLI.

### Removed

- **HTML comment metadata blocks** — Replaced with standard YAML frontmatter across all skill files.

---

## [4.0.2] — 2026-04-02

### Added

- **`CODE_OF_CONDUCT.md`** — Contributor Covenant 2.1.
- **`CONTRIBUTING.md`** — Contributing guidelines with conventions, ownership principle, and commit style.
- **`SECURITY.md`** — Security policy with supported versions and vulnerability reporting process.
- **Issue templates** (`.github/ISSUE_TEMPLATE/`) — Bug report and feature request templates.
- **Pull request template** (`.github/PULL_REQUEST_TEMPLATE.md`) — PR checklist for ownership, metadata, and changelog.

### Changed

- **Fully genericized the skill system** — Removed all brand-specific hardcoded values (`#E9142B`, `ZohoPuvi`, ManageEngine references) across 11 files. `color-primary` and `font-heading` are now placeholders filled via `design_system_prompt.md`, making the system usable for any product or brand.
- **`design_system_prompt.md`** — Added `color-primary` and `font-heading` as new placeholders; total count now 87 (up from 85). Genericized per-product override examples and locked values section.
- **`design_guide.md`** — Brand invariants now reference placeholders instead of hardcoded values.
- **`css_js_rules.md`**, **`trend_adaptation.md`**, **`agent_execution_prompt.md`**, **`figma_capture.md`**, **`skill_usage_matrix.md`**, **`html_structure.md`**, **`figma_to_code.md`**, **`layout_patterns.md`**, **`docs/GUIDE.md`** — All genericized.

### Removed

- **Video assets** — Removed all MP4 files from the repository (kept locally in `videos/`). Videos are too large for git tracking and not useful on GitHub.

---

## [4.0.1] — 2026-03-26

### Added

- **v4 presentation deck** (`docs/website-builder-skills-presentation-v4.pdf`) — Updated slide deck covering remote Figma MCP, centralized tokens, self-healing loop, and all v4.0 features.
- **v4 infographic** (`infographics/website-builder-skills-infographics-v4.png`) — Updated infographic for the v4.0 skill system.

### Changed

- **`README.md`** — Media section now links to v4 PDF and v4 infographic.
- **`docs/GUIDE.md`** — Media section now links to v4 PDF and v4 infographic.

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

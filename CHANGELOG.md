# Changelog

All notable changes to the Website Builder Skills system are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [5.2.1] — 2026-04-16

### Added

- **`figma-code-patterns.md` — Page Discovery** (#2) — New Section 1a resolves a Figma URL node-id to its parent page name. Eliminates "Page not found" errors from hardcoded/assumed page names.
- **`figma-code-patterns.md` — Common API Errors and Fixes** — Lookup table of 12 most frequent Plugin API errors: invalid enum values (`counterAxisSizingMode = "FILL"`), read-only arrays, silent FILL failures, font loading errors, etc.
- **`figma-code-patterns.md` — Standard Batch Preamble** (#3) — Complete helper function block (hex, solid, mkText, mkSection, mkSectionHeader, mkGrid) with Build Card value placeholders. Eliminates ~300 lines of duplicated boilerplate across batches.
- **`figma-frame-builder/SKILL.md` — Screenshot Tool Fallback Chain** (#5) — Priority: MCP remote `get_screenshot` → Desktop Bridge `figma_take_screenshot` → manual.
- **`figma-frame-builder/SKILL.md` — Mandatory Page Discovery Step** (#2) — Step 2 in generation process now requires page discovery before any build.
- **`figma-frame-builder/SKILL.md` — Mandatory Font Check Step** (#7) — Step 2b in generation process now requires font availability check before build. References figma-code-patterns Section 8 and token-sources Section 9.
- **`design-tokens/token-sources.md` — Minified CSS Extraction** (#4) — Detection rule (fewer than 10 lines, more than 5K chars) + bash expansion protocol + targeted grep extraction for custom properties, fonts, colors, radius, shadows.
- **`execution-prompts/SKILL.md` — Placeholder Content Tagging** (#6) — Naming convention: `[placeholder]` suffix on layer names, `{curly braces}` for fabricated text. Mandatory "Fabricated Content" section in post-generation report.
- **`execution-prompts/SKILL.md` — Mode A Desktop-Only Scope** (#8) — Explicitly states Mode A = 1440px desktop only. Mobile/tablet breakpoints are out of scope.

### Changed

- **`figma-frame-builder/SKILL.md` — Generation Process Steps Renumbered** — Steps 2–8 (was 2–7) to accommodate new page discovery (Step 2) and font check (Step 2b) steps.
- **`figma-code-patterns.md` — Section 1 Split** — Split into 1a (Page Discovery) and 1b (Frame-Finder Preamble). Preamble now references discovered page name.

---

## [5.2.0] — 2026-04-16

### Added

- **`execution-prompts/SKILL.md` — Session Recovery Protocol** — When context compacts mid-build, agent re-reads Build Card file and verifies frame integrity by ID (never by name). Includes recovery code snippet that checks frame existence and section count.
- **`figma-frame-builder/SKILL.md` — Programmatic Self-Healing Checklist** (#6) — Two-phase verification: Phase A runs a `use_figma` script that checks section heights vs min-heights, grid sizing modes, button heights, FILL-without-auto-layout-parent, and text overflow. Phase B is visual screenshot check. Programmatic checks catch collapsed frames and sizing errors that screenshots miss.
- **`figma-frame-builder/SKILL.md` — Unsupported API Methods** (#1) — Documents `loadAllPagesAsync` and `createPage` as unavailable/unreliable in the MCP plugin context.
- **`figma-code-patterns.md` — Common Defaults That Cause Failures** — Reference table of dangerous defaults: `primaryAxisSizingMode` (FIXED 100px), `textAutoResize` (WIDTH_AND_HEIGHT), `layoutSizingHorizontal` (FIXED), `layoutSizingVertical` (FIXED).
- **`brief-parser/SKILL.md` — Section Budget** (#5) — Max section count by page type (Product Landing: 7–9 recommended, 11 max). Prevents 12+ section builds that overwhelm Figma batching.
- **`brief-parser/SKILL.md` — Feature Prioritization** (#5) — Rules for selecting top features when brief has 10+ features. Selection criteria: description depth, hero mention, screenshot availability, uniqueness, audience alignment.
- **`design-tokens/token-sources.md` — Hybrid Token Resolution** (#4) — Protocol for merging explicit user values + CSS extraction + screenshot inference + defaults. Priority order with LOCKED tokens, screenshot inference rules, and source attribution report.

### Changed

- **`execution-prompts/SKILL.md` — Mode A Required Skill Files** — Figma skill files (`figma-frame-builder/SKILL.md`, `figma-code-patterns.md`, `layout-code-templates.md`) now listed as MUST-READ-FIRST with explicit warning that skipping them costs 30–40% of build time. Moved from "Also read" (easy to miss) to top of required list.
- **`execution-prompts/SKILL.md` — Build Card Mandatory File** (#7) — Changed from "should generate" to "MUST write to `{product}-build-card.md`". File persists across context compaction; in-context cards degrade when summarized.
- **`figma-frame-builder/SKILL.md` — layoutSizingVertical HUG Rule** (#1) — Added explicit rule: "After creating ANY frame with layoutMode, set `primaryAxisSizingMode = 'AUTO'` — default is FIXED (100px) which collapses every grid and card."
- **`figma-frame-builder/SKILL.md` — Text Node Sizing Rule** (#1) — Added rule: "Set `textAutoResize = 'HEIGHT'` + `layoutSizingHorizontal = 'FILL'` AFTER appending to parent. Default WIDTH_AND_HEIGHT causes horizontal overflow."
- **`figma-code-patterns.md` — Operation Order** — Added explicit warnings on steps 4 (⚠️ DEFAULT IS FIXED), 5 (counterAxisSizingMode), 9 (⚠️ DEFAULT IS WIDTH_AND_HEIGHT), 11 (fails without auto-layout parent).
- **`figma-code-patterns.md` — Section Frame Pattern** — Updated `primaryAxisSizingMode` comment to warn about FIXED default.
- **`design-tokens/token-sources.md` — Section Renumbering** — Gap Handling moved from Section 10 to Section 11 to accommodate new Hybrid Token Resolution (Section 10).

### Fixed

- **Root cause of 6.5/10 Mode A rating** — `figma-frame-builder/SKILL.md` was listed as a required file but not prominent enough in the prompt template. Agent skipped it, losing all v5.0.8–v5.1.0 Figma API rules. Fixed by making it the first file in the read order with a bold warning.

---

## [5.1.0] — 2026-04-16

### Added

- **`figma-frame-builder/SKILL.md` — MCP Tool Prefix Discovery** (#2) — Agent must discover tool prefix at runtime (e.g., `mcp__Figma__` or UUID-based) by searching deferred tools, not hardcoding.
- **`figma-frame-builder/SKILL.md` — Component Import Decision Matrix** (#5) — When to import DS components vs build from primitives. Simple components (buttons, icons) → import. Complex components (cards, section layouts) → build from primitives.
- **`figma-frame-builder/SKILL.md` — Asset Pipeline** (#8) — How to place images via `setImageFill`, sourcing strategy (brief attachments → DS icons → reference screenshots → placeholders), standard placeholder sizes for hero/icons/logos/avatars.
- **`figma-code-patterns.md` — Font Gotchas Table** (#3) — Known issues with Lato (no Semi Bold), Inter (space in "Semi Bold"), ZohoPuvi (proprietary), Segoe UI (Windows-only). Batched font check script replaces one-at-a-time checking.
- **`figma-code-patterns.md` — Effects blendMode fix** (#4) — `DROP_SHADOW` requires `blendMode: 'NORMAL'` — omitting it crashes the script. Added to gotchas quick reference.
- **`execution-prompts/SKILL.md` — Build Phase Quick Reference Card** (#7) — Condensed template generated after token extraction + brief parsing. Contains resolved colors (0-1 range), fonts, spacing, section plan, batching plan, DS component keys, and frame IDs. Replaces need to re-read full skill files during build phase — saves 40%+ context window.
- **`brief-parser/SKILL.md` — Step 1b: Content Deduplication** (#6) — When brief source is website markdown, same content appears in nav/hero/features/footer. New step strips navigation/footer content, collapses duplicate feature mentions to most detailed instance, and reduces CTA repetition.

### Changed

- **`design-tokens/token-sources.md` — Source 4 (Figma DS) rewritten** (#1) — `getLocalVariableCollectionsAsync()` only returns local variables, missing library tokens entirely. New extraction path: try local first → if 0 results, use `teamLibrary.getAvailableLibraryVariableCollectionsAsync()` or MCP tools (`get_variable_defs`, `search_design_system`) as fallback. Known limitation documented for complex alias chains.

### Why

Second Mode A test (Endpoint Central landing page) rated 7/10 — up from 6.5. Remaining friction: library token extraction returned 0 results (30% context burned on manual resolution), MCP prefix was a UUID scavenger hunt, font fallback chain had unnecessary round-trips, and context window hit compaction before Batch 1 started. All 8 items from the builder's feedback report are now addressed.

---

## [5.0.9] — 2026-04-15

### Added

- **`figma-frame-builder/SKILL.md` — Section 3: Figma MCP Runtime Rules** (new section, P0) — Addresses the #1 time sink (40% of execution time lost to context resets). Documents:
  - **Section 3.1 — Context Reset Behavior** — Every `use_figma` call runs in fresh plugin context. `figma.currentPage` resets, `getPluginData()` unsupported, `console.log()` not returned.
  - **Section 3.2 — Node ID Persistence** — Mandatory return format for all created/mutated node IDs. Only reliable way to reference nodes across calls.
  - **Section 3.3 — Frame-Finder Preamble** — Standard code snippet to paste at top of every call after creation: navigate page + find main frame by stored ID.
  - **Section 3.4 — Batching Strategy** — How to split 8–12 section pages across 4–6 `use_figma` calls. Estimated call budgets per section count.
  - **Section 3.5 — Plugin API Gotchas Quick Reference** — Colors (0–1 range, no `a` field), layout sizing order, text font loading, positioning rules, variable scopes, error handling. All from official Figma docs.
  - All subsequent sections renumbered 4–10.
- **`figma-frame-builder/figma-code-patterns.md`** (new file) — Production-ready Plugin API code snippets:
  - Sections 1–7: Frame-finder preamble, top-level frame, section frames, text nodes, feature cards, grid containers, CTA buttons
  - Section 8: Font availability check
  - Section 9: Component instantiation patterns (P1) — inspect available components, import by key, read/set variant properties (including `#nodeId` suffix gotcha), override text in instances, fallback strategy (max 2 attempts then build from scratch)
  - Section 10: Collapsed frame diagnosis
  - Section 11: Token extraction helper (P2) — Figma variable alias chain resolver for colors, typography, and multi-mode collections (handles fallback fonts like ZohoPuvi → Lato)
  - Quick Reference: correct operation order
- **`figma-frame-builder/layout-code-templates.md`** (new file, P1) — Plugin API code templates for all 12 layout types from `layout-patterns/SKILL.md`:
  - `split-50`, `split-60-40`, `grid-2col`, `grid-3col`, `grid-4col`, `full-bleed-text`, `tab-panel`, `accordion-stack`, `logo-bar`, `stat-band`, `bento`, `step-flow`
  - Each template includes auto-layout setup, sizing, child creation, and alignment
  - Layout selection quick reference with batching guidance
- **`design-tokens/token-sources.md` — Section 9: Font Availability Check** (new section) — Post-extraction font verification before frame generation. Fallback chain: same family different style → design system fallback mode → visually similar Google Font → system stack. Mandatory user report before proceeding.

### Changed

- **`figma-frame-builder/SKILL.md` — Collapsed Frame Prevention** — Added specific collapse patterns table with causes and fixes (from production testing). Added correct operation order for create → resize → layout → appendChild → FILL sizing.
- **`figma-frame-builder/SKILL.md` — Cross-references** — Added pointers to new `figma-code-patterns.md` and `layout-code-templates.md` files.

### Why

Mode A execution rated 6.5/10 in testing. Context reset between `use_figma` calls cost ~40% of build time. Builder had to discover Plugin API patterns, write every layout from scratch, and manually resolve font alias chains. All P0, P1, and P2 items from the builder's review are now addressed.

---

## [5.0.7] — 2026-04-14

### Added

- **`figma-frame-builder/SKILL.md` — Collapsed Frame Prevention** — Min-height requirements for all section frames (Hero: 500px, Feature Grid: 300px, CTA: 250px, etc.) and component frames (Feature Card: 150px, Pricing Card: 200px, etc.). Root cause fix: text layers must use `textAutoResize: "HEIGHT"` and image placeholders must have explicit height.
- **`figma-frame-builder/SKILL.md` — Collapsed Frame Detection in Verification Loop** — Mandatory check in every self-healing iteration. If any section appears collapsed in the screenshot, the agent must inspect child layers, fix sizing, and re-verify. Loop cannot pass with collapsed frames.

### Changed

- **`figma-frame-builder/SKILL.md` — Design System Search Restriction** — Agent must not search Figma for design token values (colors, fonts, spacing). Tokens are already collected from the token source at session start. `search_design_system` limited to structural components only (buttons, cards, nav), max 3 calls per session.
- **`figma-frame-builder/SKILL.md` — Button token reference** — Updated from `color-primary` to `color-cta` (aligned with v5.0.6 CTA separation).
- **`design-tokens/token-sources.md` — Curl Failure Protocol (STRICT)** — On any curl failure: stop immediately, never traverse to sub-pages on the same domain, never try alternative tools. Ask user to switch to screenshot/CSS export/token file. Known limitation documented: some domains (e.g., manageengine.com) block curl via WAF.
- **`design-tokens/token-sources.md` — Sub-page traversal restriction** — Explicitly forbidden: agent must fetch only the exact URL provided, never crawl to `/about`, `/features`, `/pricing` or any other path.

---

## [5.0.6] — 2026-04-14

### Added

- **`design-tokens/SKILL.md` — Section 2.2: CTA Colors** (new section) — Separated `color-cta`, `color-cta-hover`, and `color-cta-active` as independent tokens from `color-primary`. Many brands (e.g., ManageEngine, Zoho) use a contrasting CTA color that differs from their primary brand color.

### Changed

- **`design-tokens/SKILL.md` — Section 1 (Brand Invariants)** — "Brand primary color" and "CTA color" are now two distinct locked invariants.
- **`design-tokens/SKILL.md` — Section 2.1 (Brand Colors)** — `color-primary` redefined as dominant brand theme color (50%+ of branded areas: headers, nav, section tints). Removed `color-primary-hover` and `color-primary-active` (these were CTA states, not brand states).
- **`design-tokens/SKILL.md` — Section 3.2 (Hardcoded Placements)** — CTA button backgrounds now use `color-cta` instead of `color-primary`.
- **`design-tokens/SKILL.md` — Section 8 (CTA Styles)** — All CTA background/hover/active states reference `color-cta-*` tokens instead of `color-primary-*`.
- **`design-tokens/token-sources.md` — Source 3 (URL)** — Three independent extraction paths: Path A (brand primary from page-wide coverage), Path B (CTA from button elements), Path C (neutrals). After extraction, explicitly compares whether CTA = primary or distinct.
- **`design-tokens/token-sources.md` — Section 8 (Normalization)** — Added CTA-specific mapping rules: `btn-primary` background → `color-cta` (not `color-primary`); hex/rgb on button backgrounds → `color-cta`.
- **`design-tokens/token-sources.md` — Figma variable mapping** — Added `color/cta/primary` → `color-cta`, `color/cta/hover` → `color-cta-hover`.
- **`design-tokens/token-values.md`** — Added Section 2b (CTA Colors) with 3 new placeholder rows. Removed old `color-primary-hover/active`. Placeholder count 97 → 98.
- **`css-js-generator/SKILL.md`** — CSS custom property examples updated to use `color-cta` and `color-cta-hover`.
- **`trend-adapter/SKILL.md`** — Tint section cross-reference updated (Section 2.4 → 2.5), spacing and typography refs updated.
- **`layout-patterns/SKILL.md`** — Tint section cross-reference updated (Section 2.4 → 2.5).
- **`master-reference/SKILL.md`** — Placeholder count updated (97 → 98).

### Why

CTA color conflation with brand primary caused incorrect color assignments during testing — brands with contrasting CTA colors (red CTA on a non-red-primary site) had their entire theme incorrectly skewed toward the CTA color.

---

## [5.0.5] — 2026-04-14

### Added

- **`design-tokens/SKILL.md` — Section 3: Color Placement Map** (new section) — Defines where each color token is applied on the page:
  - **Section 3.1 — Color Application Model** — Primary color = 50%+ dominant theme (backgrounds, CTAs, accents); secondary = complement; surfaces tied to color roles (primary-tinted, secondary-tinted, neutral, dark).
  - **Section 3.2 — Hardcoded Placements** — 14 locked rules (CTA backgrounds, text colors, page/card backgrounds, borders) — no AI discretion.
  - **Section 3.3 — AI-Flexible Placements** — 12 context-dependent slots (hero bg, section tints, feature icons, footer, pricing highlights) where the builder selects from token options.
  - **Section 3.4 — WCAG Validation Rules** — Contrast ratio requirements (4.5:1 normal text, 3:1 large text/UI) with validation process for every AI-flexible placement.
  - All subsequent sections renumbered 4–13; all cross-references updated in `token-values.md`, `trend-adapter`, `variation-explorer`.

- **`pipeline-workflow/SKILL.md` — Tool Permissions & Restrictions** (new section):
  - **use_figma tool** — Hardcoded to remote MCP server only; agent must never search for or use Desktop Bridge.
  - **URL Access Permission** — Agent must confirm URL with user before fetching for token extraction; handles auth failures and rate limits.

- **`pipeline-workflow/SKILL.md` — Session Start** (new section) — Defines agent behavior when user adds skill files: read all skills → confirm readiness → ask which mode → ask about token source (if not already provided).

### Changed

- **`design-tokens/token-sources.md` — Source 3 (URL) rewritten** — Replaced CSS property-name matching with coverage-based color extraction: collect all colors → calculate % visual weight → classify as primary (50%+), secondary, bg, text. Non-color tokens (typography, spacing, shadows) keep the existing CSS property mapping. Added hero background image edge case flag.
- **`design-tokens/token-sources.md` — Source 6 (Screenshot) rewritten** — Same coverage-based visual classification. Screenshots can catch primary brand colors hidden in hero background images that CSS scraping misses.
- **`design-tokens/token-values.md`** — All section references updated to match new numbering (Sections 4–11). Component-Level Placeholders renumbered to Section 14.

---

## [5.0.4] — 2026-04-09

### Added

- **`design-tokens/token-sources.md`** (new file) — Full token ingestion protocol for all 7 supported input sources:
  1. Product token `.md` file — direct read and mapping
  2. Manual fill — existing `token-values.md` workflow
  3. Website URL — CSS fetch, custom property extraction, computed value fallback
  4. Figma Design System — variable extraction via `use_figma` Plugin API script + `search_design_system`
  5. Figma Design Frame — `get_design_context` + `get_variable_defs` extraction with variable-first priority
  6. Screenshot / image — visual extraction protocol for colors, typography estimates, spacing estimates; all values flagged as estimated
  7. JSON token file — supports Style Dictionary, W3C Design Tokens, and Figma Tokens (Tokens Studio) formats
  - **Section 8 — Token Name Normalization** — keyword matching table (40+ mapping rules) and value-type fallback matching to resolve source names to canonical token names
  - **Section 9 — Gap Handling** — severity classification (Critical / High / Medium / Low) with fallback values and gap report format

### Changed

- **`pipeline-workflow`** — Token Source Detection section added between Execution Modes and Combined Workflows. Detection priority table defines how the agent identifies the active source type when multiple inputs are provided. Pipeline diagrams for Modes A and C updated to include the detection step before token application.
- **`design-tokens/SKILL.md`** — Section 11 (new) summarises all 7 token sources with recognition signals and references `token-sources.md`. Token Override Protocol renumbered to Section 12. Reference pointer added to header cross-references.
- **`master-reference`** — Ownership table updated with `token-sources.md` and token source detection logic entries.

---

## [5.0.3] — 2026-04-09

### Changed

- **`design-tokens` — targeted additions for full-site component scope** — Three focused gaps addressed; no structural rethink:
  - **`sidebar-width`** added to Section 4.2 (Layout-Specific Spacing) — token was referenced in `layout-patterns` grid system but undefined here.
  - **Section 9 — Form & Input Tokens** (new) — 7 tokens covering input height, background, border, focus border, radius, placeholder color, and padding. Required by the new Form component in `component-library`.
  - **Section 10 — Image Treatment** extended — `avatar-size` added for person headshots (Team Card, Author Bio, Speaker Card); `map-height` added for Map Embed component. Previous section 9, renumbered to 10.
  - **Token Override Protocol** renumbered from Section 10 to Section 11.
  - **`token-values.md`** updated — new rows for all 10 added tokens. Placeholder count updated from 87 to 97.

---

## [5.0.2] — 2026-04-09

### Changed

- **`component-library` — expanded to full-site component set** — Grew from 14 landing-page components to 30 components covering all 14 marketing website page types. Key additions:
  - **People & Profile** (Section 7): Team Card, Author Bio, Speaker Card
  - **Timeline & Process** (Section 8): Timeline, Agenda List, Countdown Timer, Event Details Block
  - **Navigation & Index** (Section 9): Article Card, Filter Bar, Search Bar, Pagination
  - **Form** (Section 10): Single generic Form component with variants — `contact`, `registration`, `newsletter`, `download-gate`, `multi-step`
  - **Media** (Section 11): Media Gallery, Map Embed
  - **Content** (Section 6, extended): Pull Quote, Rich Text Block, Download Card
  - **Boundary note added** — clarifies component-library owns what a component IS (slots, purpose, variants); spatial arrangement is owned by `layout-patterns`
  - **Component Selection Logic** (Section 1) expanded — 30 content-type rows, page-type-aware form and index selection rules added
  - **Section-to-Component Mapping** (Section 12) expanded from 11 to 45+ section types across 8 categories, aligned with `brief-parser` section taxonomy

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

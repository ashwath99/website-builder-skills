#!/bin/bash
# Push v5.0 and create GitHub release
# Run from the website-builder-skills repo root

set -e

echo "=== Step 1: Stage all versioned directories and remove old root files ==="
git add v3.0/ v4.0/
git add -u
git status

echo ""
echo "=== Step 2: Commit ==="
git commit -m "Add v5.0: Restructure all skills to SKILL.md format

Archives v3.0 flat files and v4.0 intermediate files into versioned
directories. Converts all 13 skill files into the Agent Skills
specification (SKILL.md with YAML frontmatter). Each skill now lives in
its own directory with ownership-based naming. Files over 500 lines are
split into SKILL.md + reference files. All cross-references updated.
Compatible with Claude Code, Cursor AI, VS Code, Antigravity, Codex CLI,
Gemini CLI.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

echo ""
echo "=== Step 3: Push to GitHub ==="
git push origin main

echo ""
echo "=== Step 4: Create v5.0 release ==="
gh release create v5.0 \
  --title "v5.0 — SKILL.md Format Restructure" \
  --notes "## What's New in v5.0

- **SKILL.md format** — Every skill now follows the universal Agent Skills specification with YAML frontmatter (\`name\`, \`description\`, \`version\`), making them discoverable and loadable across all major AI coding agents.
- **Independent skill directories** — Each skill lives in its own folder with a \`SKILL.md\` entry point and optional reference files for overflow content.
- **Ownership-based naming** — Skills renamed by what they own: \`brief-parser\`, \`design-tokens\`, \`component-library\`, etc.
- **Progressive disclosure** — SKILL.md files stay under 500 lines; detailed specs overflow into reference files one level deep.
- **Cross-IDE compatibility** — Works with Claude Code, Cursor AI, VS Code / GitHub Copilot, Antigravity (Google), Codex CLI, and Gemini CLI.

### Structure

\`\`\`
v5.0/
├── pipeline-workflow/       (from workflow.md)
├── master-reference/        (from skill_usage_matrix.md)
├── brief-parser/            (from content_brief.md)
├── design-tokens/           (from design_guide.md + design_system_prompt.md)
├── component-library/       (from components.md — split)
├── layout-patterns/         (from layout_patterns.md)
├── figma-frame-builder/     (from figma_capture.md)
├── figma-code-extractor/    (from figma_to_code.md)
├── html-generator/          (from html_structure.md — split)
├── css-js-generator/        (from css_js_rules.md — split)
├── trend-adapter/           (from trend_adaptation.md)
├── variation-explorer/      (from variation_generator.md)
└── execution-prompts/       (from agent_execution_prompt.md — split)
\`\`\`

**13 skills • 18 skill files • 24 total files**

See [CHANGELOG.md](v4.0/v5.0/CHANGELOG.md) and [README.md](v4.0/v5.0/README.md) for full details."

echo ""
echo "=== Done! ==="
echo "Release URL: https://github.com/ashwath99/website-builder-skills/releases/tag/v5.0"

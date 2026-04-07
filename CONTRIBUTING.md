# Contributing to Website Builder Skills

Thank you for your interest in contributing! This guide explains how to get involved.

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](https://github.com/ashwath99/website-builder-skills/issues) to report bugs or suggest enhancements.
- Check existing issues before opening a new one to avoid duplicates.
- Use the provided issue templates when available.

### Suggesting Changes

1. **Fork** the repository.
2. **Create a branch** from `main` for your change (`git checkout -b my-change`).
3. **Make your edits** — follow the conventions below.
4. **Commit** with a clear message describing what changed and why.
5. **Open a Pull Request** against `main` using the PR template.

### What You Can Contribute

- **New components** — Add entries to `components.md` following the existing format (name, variants, semantic HTML, BEM classes).
- **New layout patterns** — Add entries to `layout_patterns.md` with audience-fit criteria.
- **Trend profiles** — Add named profiles to `trend_adaptation.md` with dimension overrides.
- **Bug fixes** — Correct instructions, token values, or cross-references in any skill file.
- **Documentation** — Improve `docs/GUIDE.md`, `README.md`, or inline metadata.

## Conventions

### Ownership Principle

Each instruction, token, or rule is defined in **exactly one** skill file. Other files reference it but never redefine it. Before adding a new rule, check `skill_usage_matrix.md` for the correct owner file.

### File Metadata

Every skill file starts with a YAML-style metadata block. When editing a file, update the `last_updated` field and bump the `version` if the change is substantive.

### Commit Messages

Write concise commit messages that explain the *why*, not just the *what*. Examples:

- `Add carousel component with autoplay and dot-nav variants`
- `Fix token reference in design_guide.md — border-radius was pointing to wrong variable`

### Markdown Style

- Use ATX headings (`#`, `##`, `###`).
- Use fenced code blocks with language tags.
- Wrap lines at a reasonable length for readability.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold its terms.

## Questions?

Open an issue or start a discussion — we're happy to help.

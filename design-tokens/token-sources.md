# Token Sources — Ingestion Protocols

→ Reference for `design-tokens/SKILL.md`

Extracts design tokens from 7 supported sources. Every source produces the same output: resolved values in `token-values.md` format. Unresolved tokens remain `{PLACEHOLDER}`.

**Detection order:** `pipeline-workflow/SKILL.md` — Token Source Detection.

---

## Source 1 — Product Token File (.md)

**Signal:** `.md` file with token names/values (named `{product}-tokens.md`).

1. Read file, match entries to canonical token names from `design-tokens/SKILL.md`
2. Apply token name normalization (Section 8) if naming differs
3. Flag unmatched canonical tokens as gaps

Cleanest source. Multiple product files → use the one matching active product prefix. Partial fill → combine with other source for gaps.

---

## Source 2 — Manual Fill

**Signal:** `token-values.md` already has actual values (not `{PLACEHOLDER}`).

Read file. Treat filled values as resolved. Remaining `{PLACEHOLDER}` → gaps. No extraction needed.

---

## Source 3 — Website URL

**Signal:** Website URL provided alongside brief.

**Permission:** Confirm with user before fetching. See `pipeline-workflow/SKILL.md`.

**Fetch:** `curl -s <URL>` only. Parse `<link rel="stylesheet">` tags, fetch each (max 5 stylesheets). Do NOT use WebFetch, Python, wget, or browser automation.

**Curl failure protocol:** If curl fails (403, timeout, WAF block, any non-200): stop immediately. Do not retry, navigate sub-pages, or try alternative tools. Ask user for alternative: screenshot (Source 6), CSS file (Source 3b), or token file (Source 7).

**Scope:** Fetch the exact URL only. Never crawl linked pages or sitemaps.

### Source 3b — Direct CSS File

**Signal:** User provides a CSS file directly (attached or referenced) instead of a URL.

Skip all fetch steps. If minified, apply the Minified CSS protocol below. Then proceed directly to Track A (colors) and Track B (non-color) extraction.

### Minified CSS Protocol

**Detection:** <10 lines but >5K characters → minified.

```bash
# Expand
tr ';' '\n' < {FILE}.css | tr '{' '\n' | tr '}' '\n' > {FILE}-expanded.css

# Extract tokens, fonts, colors, radius, shadows, font-sizes
grep -oE '\-\-[a-zA-Z0-9_-]+:\s*[^;]+' {FILE}-expanded.css | sort -u > tokens-raw.txt
grep -oE 'font-family:\s*[^;]+' {FILE}-expanded.css | sort -u > fonts-raw.txt
grep -oE '#[0-9a-fA-F]{3,8}' {FILE}-expanded.css | sort -u > colors-raw.txt
grep -oE 'border-radius:\s*[^;]+' {FILE}-expanded.css | sort -u > radius-raw.txt
grep -oE 'box-shadow:\s*[^;]+' {FILE}-expanded.css | sort -u > shadows-raw.txt
grep -oE 'font-size:\s*[^;]+' {FILE}-expanded.css | sort -u > font-sizes-raw.txt
```

Work from extracted files, not the full expanded CSS. Never read minified CSS directly into context.

### Track A — Color Extraction (Coverage-Based)

Colors are classified by visual weight, not CSS property names.

**Step 1 — Collect** all colors: CSS custom properties, background-color, color, border-color, gradients, SVG fill/stroke. Note `background-image` URLs on hero/banner sections.

**Step 2 — Calculate % coverage:** Weight by (element count × visual area). Group perceptually similar colors. Separate chromatic from achromatic.

**Step 3 — Classify via three independent paths:**

**Path A — Brand (page-wide, non-button elements):**

| Method | Token |
|---|---|
| Highest-coverage chromatic (headers, nav, tints, icons) | `color-primary` |
| Second chromatic (if distinct) | `color-secondary` |

**Path B — CTA (button elements only):**

| Method | Token |
|---|---|
| `background-color` on primary action buttons | `color-cta` |
| Darken CTA ~10% / ~15% | `color-cta-hover` / `color-cta-active` |

**Path C — Neutrals & text:**

| Method | Token |
|---|---|
| Largest light area | `color-bg-page` |
| Card/component light | `color-bg-surface` |
| Darkest text | `color-text-primary` |
| Medium-contrast text | `color-text-secondary` |
| Muted text | `color-text-tertiary` |
| Light on dark backgrounds | `color-text-inverse` |

If `color-cta` = `color-primary` → note "CTA uses brand primary." If different → both get own values.

**Step 4 — Derive surfaces:** Map section background colors to semantic surface tokens:

| CSS Signal | Token |
|---|---|
| Brand-tinted section backgrounds (light-medium saturation) | `surface-brand`, `surface-brand-strong` |
| Light tinted / neutral-warm section backgrounds | `surface-subtle`, `surface-brand-subtle` |
| Dark backgrounds (hero, footer, CTA) | `surface-inverse` |
| White / untinted | `surface-default` |

**Step 4b — Derive button styles:** Extract from `.btn-*` / `[class*="button"]` elements:

| CSS Signal | Token |
|---|---|
| Primary action button `background-color` | `button-primary-bg` |
| Brand/identity button `background-color` | `button-secondary-bg` |
| Accent/promo button `background-color` | `button-highlight-bg` |
| Hover variants (`button:hover`) | `*-hover` variants |
| Button text `color` | `*-text` variants |

**Step 5 — Hero image color extraction** (only if Step 1 found `background-image` on hero/banner):

Download max 2 images (hero + banner `background-image` only). Skip `<img>` tags, SVGs, icons, stock CDN images, images <400×200.

```python
from PIL import Image
from collections import Counter
import io, subprocess

img_data = subprocess.run(['curl', '-s', img_url], capture_output=True).stdout
img = Image.open(io.BytesIO(img_data)).convert('RGB').resize((150, 150))
pixels = list(img.getdata())
chromatic = [p for p in pixels if not (
    (p[0] > 230 and p[1] > 230 and p[2] > 230) or
    (p[0] < 25 and p[1] < 25 and p[2] < 25)
)]
quantized = [((r//16)*16, (g//16)*16, (b//16)*16) for r, g, b in chromatic]
dominant = Counter(quantized).most_common(1)[0][0]
hex_color = '#{:02x}{:02x}{:02x}'.format(*dominant)
```

Use result only if coverage-based extraction found no strong `color-primary`. Delete images after extraction.

### Track B — Non-Color Extraction

**Step 1 — CSS custom properties:** Scan `:root {}` for non-color `--*` variables.

**Step 2 — If no custom properties, extract computed values:**

| Token | CSS Target |
|---|---|
| `font-heading` | `h1`, `h2` font-family |
| `font-body` | `body`, `p` font-family |
| `font-size-display` | `h1` on hero |
| `font-size-h2` | `h2` font-size |
| `font-size-body` | `p`, `body` font-size |
| `space-unit` | Smallest recurring spacing |
| `section-padding-y` | Section padding-top/bottom |
| `content-max-width` | `.container`, `main` max-width |
| `radius-sm` / `radius-md` | Button / card border-radius |
| `shadow-md` | Card box-shadow |

**Step 3–4:** Apply normalization (Section 8). Verify units (prefer px/rem).

### Combined Output

Merge Track A + Track B. Flag gaps. Limitation: CSS misses image-embedded colors and may not capture all spacing scale steps.

---

## Source 4 — Figma Design System (Variables & Tokens)

**Signal:** Figma library URL or design system reference.

**Step 1 — Try local variables** via `use_figma`: Run `figma-code-patterns.md` §11.1–11.2.

**Step 2 — If 0 local variables, try library:**

```
Option A (MCP — preferred):
1. get_variable_defs on any DS frame → variable bindings
2. search_design_system("color"), ("spacing"), ("typography") → library values

Option B (Plugin API — fallback):
1. figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync()
2. For each: getLibraryVariableCollectionById(key)
3. Resolve aliases per figma-code-patterns.md §11.2
```

**Step 3:** Library values override local on conflict. **Step 4:** Flatten to `name: value` pairs. **Step 5:** Normalize (Section 8). **Step 6:** Font check (Section 9). **Step 7:** Bind CSS properties to Figma variables in Mode A. **Step 8:** Flag gaps.

**Common Figma variable → token mappings:**

| Figma Path | Token |
|---|---|
| `color/brand/primary` | `color-primary` |
| `color/cta/primary` or `color/action/primary` | `color-cta` |
| `color/text/primary` | `color-text-primary` |
| `color/bg/page` | `color-bg-page` |
| `bg/brand` | `surface-brand` |
| `bg/brand-strong` | `surface-brand-strong` |
| `bg/subtle` | `surface-subtle` |
| `bg/brand-subtle` | `surface-brand-subtle` |
| `bg/inverse` | `surface-inverse` |
| `bg/default` | `surface-default` |
| `button/primary/bg` | `button-primary-bg` |
| `button/primary/bg-hover` | `button-primary-bg-hover` |
| `button/secondary/bg` | `button-secondary-bg` |
| `button/secondary/bg-hover` | `button-secondary-bg-hover` |
| `button/highlight/bg` | `button-highlight-bg` |
| `button/highlight/bg-hover` | `button-highlight-bg-hover` |
| `button/*/text` | `button-*-text` |
| `typography/heading/family` or `font/family/Font` | `font-heading` |
| `typography/body/family` | `font-body` |
| `spacing/unit` or `space/*` | `space-unit` |
| `spacing/section/y` | `section-padding-y` |
| `radius/sm` or `radius/pill` | `radius-sm` / `radius-full` |
| `shadow/md` | `shadow-md` |

---

## Source 5 — Figma Design Frame

**Signal:** Figma frame URL or dev link.

1. `get_design_context` → layout, spacing, colors, typography
2. `get_variable_defs` → variable bindings
3. Extract: fills → colors, text styles → fonts/sizes, spacing → space tokens, radius → radius tokens, shadows
4. Prefer variable-bound values over raw values
5. Normalize (Section 8). Flag gaps.

Frame extraction is context-dependent — full-page frame gives most complete results.

---

## Source 6 — Screenshot / Image

**Signal:** `.png`, `.jpg`, `.webp` attached.

### Track A — Visual Color Extraction

Same classification logic as Source 3 Track A (Paths A/B/C), but from visual inspection instead of CSS parsing. Key advantage: screenshots capture hero/banner image colors that CSS misses.

### Track B — Visual Estimation

| Category | Extractable | Accuracy |
|---|---|---|
| Colors | Yes (color-pick) | High |
| Font family | Partial (visual match) | Medium |
| Font sizes | Partial (proportions) | Low |
| Spacing | No | Use defaults |
| Radius | Partial (visual) | Low — use nearest 4/8/12/16px |
| Shadows | Partial (visible/not) | Low — use sm/md/lg |

**Rules:** Prefix all screenshot values with `/* estimated from screenshot */`. Never infer font-family from screenshot if text-based source available. On conflicts, ask user.

---

## Source 7 — JSON Token File

**Signal:** `.json` file attached.

Three formats supported: Style Dictionary (`{ "color": { "primary": { "value": "#E9142B" } } }`), W3C Design Tokens (`{ "color-primary": { "$value": "#E9142B", "$type": "color" } }`), Figma Tokens/Tokens Studio (`{ "global": { "primary": { "value": "#E9142B", "type": "color" } } }`).

1. Flatten nested paths with `/` separator
2. Normalize to canonical tokens (Section 8)
3. Use `value` or `$value` field. Resolve aliases (e.g., `{color.brand.primary}`)
4. Flag gaps

---

## 8 — Token Name Normalization

### Keyword Matching

| Source name contains | Maps to |
|---|---|
| `primary` + color (not button) | `color-primary` |
| `secondary` + color | `color-secondary` |
| `cta` or `action` + color | `color-cta` |
| `btn-primary` + background | `color-cta` (not `color-primary`) |
| `text-primary` / `text/primary` | `color-text-primary` |
| `text-secondary` | `color-text-secondary` |
| `text-tertiary` or `muted` | `color-text-tertiary` |
| `inverse` + text | `color-text-inverse` |
| `bg-page` / `background/page` | `color-bg-page` |
| `bg-surface` / `surface/card` | `color-bg-surface` |
| `success` / `warning` / `error` + color | `color-success` / `color-warning` / `color-error` |
| `heading` + font | `font-heading` |
| `body` + font | `font-body` |
| `mono` or `code` + font | `font-mono` |
| `display` / `h1` / `h2` / `h3` + size | `font-size-display` / `-h1` / `-h2` / `-h3` |
| `body-lg` or `lead` / `body` / `body-sm` + size | `font-size-body-lg` / `-body` / `-body-sm` |
| `bold` / `semibold` / `regular` + weight | `font-weight-bold` / `-semibold` / `-regular` |
| `section-padding` | `section-padding-y` |
| `max-width` / `container-width` | `content-max-width` |
| `gutter` | `grid-gutter` |
| `card-padding` | `card-padding` |
| `shadow-sm` / `-md` / `-lg` | `shadow-sm` / `-md` / `-lg` |
| `radius-sm` / `-md` / `-lg` | `radius-sm` / `-md` / `-lg` |
| `bg/brand` / `surface/brand` | `surface-brand` |
| `bg/subtle` / `surface/subtle` | `surface-subtle` |
| `bg/inverse` / `surface/inverse` | `surface-inverse` |
| `bg/default` / `surface/default` | `surface-default` |
| `button/primary` + bg | `button-primary-bg` |
| `button/secondary` + bg | `button-secondary-bg` |
| `button/highlight` + bg | `button-highlight-bg` |
| `button/*` + hover | `button-*-bg-hover` |
| `button/*` + text | `button-*-text` |

### Value-Type Fallback

When keyword matching is inconclusive: primary action button bg → `button-primary-bg`, brand/identity button bg → `button-secondary-bg`, accent/promo button bg → `button-highlight-bg`, page bg → `color-bg-page`, card bg → `color-bg-surface`, dark text → `color-text-primary`, largest font-size → `font-size-display`, section padding → `section-padding-y`, container max-width → `content-max-width`, small radius (2–6px) → `radius-sm`, medium (8–16px) → `radius-md`, pill/rounded → `radius-full`.

**Ambiguous matches:** Don't guess → leave `{PLACEHOLDER}` with comment `/* ambiguous: {name}: {value} */`.

---

## 9 — Font Availability Check (Post-Extraction)

### Procedure

**Step 1 (Mode A):** Run `figma-code-patterns.md` §8 font check before building frames.

**Step 2 — Fallback chain:**

| Priority | Action |
|---|---|
| 1. Same family, different style | Family exists with different style name ("Regular" vs "Normal") |
| 2. DS fallback mode | Figma variable collection has a "Fallback" mode |
| 3. Visually similar Google Font | Match by characteristics (see table below) |
| 4. System font stack | `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif` |

### Font Fallback Lookup Table

| Original Font Characteristics | Fallback Candidates (try in order) |
|---|---|
| **Geometric sans-serif** (Futura, Avenir, Proxima Nova, ZohoPuvi) | Inter → Lato → Poppins |
| **Humanist sans-serif** (Frutiger, Myriad, Gill Sans, Segoe UI) | Open Sans → Source Sans Pro → Noto Sans |
| **Neo-grotesque sans-serif** (Helvetica, Arial, Univers) | Roboto → Inter → Lato |
| **Serif** (Georgia, Palatino, Book Antiqua) | Merriweather → Playfair Display → Lora |
| **Slab serif** (Rockwell, Courier, Memphis) | Roboto Slab → Zilla Slab |
| **Monospace** (Menlo, Consolas, SF Mono) | JetBrains Mono → Fira Code → Source Code Pro |
| **Display/decorative** (custom brand fonts) | Inter (safe default) → Poppins |

**Step 3 — Report** before proceeding. Never silently substitute. Never proceed to frame generation with unavailable font.

**Mode C:** Use Google Font CDN link for fallback, or `{PLACEHOLDER}` with `/* TODO: install custom font */`.

---

## 10 — Hybrid Token Resolution (Mixed Sources)

Triggered when no single source provides complete coverage.

### Source Priority

| Priority | Source | Trust |
|---|---|---|
| 1 | User-provided explicit values | Exact |
| 2 | Product token file (.md) | Exact |
| 3 | CSS/JSON file extraction | Exact |
| 4 | Figma DS variables | Exact |
| 5 | URL extraction (curl) | High |
| 6 | Screenshot inference | Approximate |
| 7 | Agent defaults (gap handling) | Fallback |

### Process

1. Start with all tokens as `{PLACEHOLDER}`
2. Apply highest-priority source → mark filled tokens as **LOCKED**
3. Apply next source → fill remaining `{PLACEHOLDER}` only, skip LOCKED
4. Repeat for all sources
5. Screenshot for remaining gaps → mark as APPROXIMATE
6. Gap handling (Section 11) for anything still unresolved

### Screenshot Inference Rules

Colors: extractable (high accuracy). Font family: partial (medium). Font sizes: partial (low). Spacing: use defaults. Radius: nearest 4/8/12/16px. Shadows: sm/md/lg estimate.

Mark all screenshot values with `(from screenshot — approximate)`. On conflict with other source, ask user.

### Report

After merging, produce source attribution: token → value → source → confidence. Present to user for verification before proceeding.

---

## 11 — Gap Handling

| Gap | Severity | Fallback |
|---|---|---|
| `color-primary` | Critical | Stop — ask user |
| `font-heading` / `font-body` | High | System font stack. See §9 fallback chain |
| `font-size-*` | High | Browser defaults + type scale ratios |
| `section-padding-y` | Medium | `space-2xl` |
| `color-text-primary` | Medium | `#1A1A1A` |
| `color-bg-page` | Medium | `#FFFFFF` |
| `surface-brand` / `surface-inverse` | High | Stop — ask user (key surfaces for page rhythm) |
| `surface-subtle` / `surface-brand-subtle` | Medium | Derive light tint from `color-primary` at 5–8% opacity |
| `button-primary-bg` | High | Fall back to `color-cta` if available |
| `button-secondary-bg` | Medium | Fall back to `color-primary` |
| `button-highlight-bg` | Medium | Omit highlight style — use Primary + Secondary only |
| Spacing scale | Low | Derive from available values |
| `shadow-*` | Low | `shadow-none` |
| Semantic colors | Low | #2E7D32 / #F57C00 / #C62828 / #1565C0 |

**Gap report:** Present `Critical → High → Medium → Low` breakdown with counts before proceeding, so user can fill critical/high gaps.

# Token Sources — Ingestion Protocols

→ This file is a reference for `design-tokens/SKILL.md`

This file defines how the agent extracts and resolves design token values from any of the 7 supported input sources. Every source produces the same output: a resolved set of token values in `token-values.md` format, ready for downstream skills.

**Detection order:** See `pipeline-workflow/SKILL.md` — Token Source Detection section.

**Output format for all sources:**
Extracted values must be mapped to the canonical token names defined in `design-tokens/SKILL.md`. The agent fills `token-values.md` (or an equivalent in-session record) with resolved values and proceeds. Any token that cannot be resolved is left as `{PLACEHOLDER}` and flagged as a gap.

---

## Source 1 — Product Token File (.md)

**Recognition signal:** A `.md` file is attached or referenced that contains token names and values — typically named `{product}-design-tokens.md` or `{product}-tokens.md`.

**Extraction steps:**
1. Read the file in full
2. Match each row or entry to a canonical token name from `design-tokens/SKILL.md`
3. Apply the value directly — no transformation needed if the file follows the `token-values.md` format
4. If the file uses different naming, apply token name normalization (see Section 8)
5. Record resolved values and flag any canonical tokens not covered

**Notes:**
- This is the cleanest source — minimal ambiguity if the file follows the standard format
- Multiple product files can coexist — the agent uses the one matching the active product prefix
- If the file is a partial fill (only some tokens filled), it is combined with any other available source for remaining gaps

---

## Source 2 — Manual Fill

**Recognition signal:** `token-values.md` already has actual values in the Value column (i.e. `{PLACEHOLDER}` entries have been replaced).

**Extraction steps:**
1. Read `token-values.md`
2. Treat all filled values as resolved
3. Remaining `{PLACEHOLDER}` entries are flagged as gaps — do not invent values

**Notes:**
- No extraction needed — values are already in the canonical format
- Agent proceeds directly to token application after reading the file

---

## Source 3 — Website URL (CSS Extraction)

**Recognition signal:** A website URL is provided alongside the brief or as a reference.

**Extraction steps:**

1. **Fetch the page CSS** — load the page and retrieve all linked stylesheets. Prioritize the main stylesheet.

2. **Extract CSS custom properties** — scan for `:root { }` declarations and collect all `--*` variables with their values:
   ```css
   :root {
     --primary-color: #E9142B;
     --font-heading: 'ZohoPuvi', sans-serif;
     --spacing-md: 16px;
   }
   ```

3. **If no custom properties exist**, extract computed values for key selectors:
   - Primary button background → `color-primary`
   - Body font-family → `font-body`
   - H1 font-size → `font-size-display` or `font-size-h1`
   - Section padding → `section-padding-y`

4. **Apply token name normalization** (see Section 8) to map CSS variable names to canonical token names.

5. **Verify values** — for color values, confirm they are valid hex, rgb(), or hsl(). For sizes, confirm units (prefer px or rem).

6. **Flag gaps** — canonical tokens with no match in the extracted CSS are left as `{PLACEHOLDER}`.

**Common extraction targets by token category:**

| Token Category | CSS Selector / Property to Target |
|---|---|
| `color-primary` | Primary button background-color, `.btn-primary`, `[class*="primary"]` background |
| `color-text-primary` | `body` or `p` color |
| `color-bg-page` | `body` background-color |
| `font-heading` | `h1`, `h2` font-family |
| `font-body` | `body`, `p` font-family |
| `font-size-display` | `h1` font-size on hero sections |
| `font-size-h2` | `h2` font-size |
| `font-size-body` | `p`, `body` font-size |
| `space-unit` | Smallest recurring spacing value |
| `section-padding-y` | Section or `.section` padding-top / padding-bottom |
| `content-max-width` | `.container`, `.wrapper`, `main` max-width |
| `radius-sm` | Button border-radius |
| `radius-md` | Card border-radius |
| `shadow-md` | Card box-shadow |

**Limitation:** CSS extraction cannot reliably recover all tokens, especially spacing scale values and tint pairs. Expect gaps and flag them.

---

## Source 4 — Figma Design System (Variables & Tokens)

**Recognition signal:** A Figma library URL, design system reference, or explicit instruction to use a connected Figma design system is provided.

**Extraction steps:**

1. **Run the variable extraction script** via `use_figma`. The script is defined in `master-reference/SKILL.md` — Variable Extraction Pattern section. It reads all local variable collections and formats them as CSS custom properties.

2. **Alternatively**, use `search_design_system` with broad queries (`"color"`, `"spacing"`, `"typography"`) to surface design system variables.

3. **Collect the output** — a flat list of variable name → value pairs:
   ```
   color/brand/primary: #E9142B
   typography/heading/font-family: ZohoPuvi
   spacing/md: 16px
   ```

4. **Apply token name normalization** (see Section 8) — Figma variable names use `/` path separators and may use nested naming conventions.

5. **Bind to Figma variables in output** — when tokens are sourced from a Figma design system, the agent should bind CSS custom properties to Figma variables in the generated frame (Mode A) rather than hardcoding values. This ensures the Figma output stays in sync with the design system.

6. **Flag gaps** — tokens with no matching Figma variable are left as `{PLACEHOLDER}`.

**Figma variable naming conventions — common patterns:**

| Figma Variable Path | Canonical Token |
|---|---|
| `color/brand/primary` | `color-primary` |
| `color/brand/primary-hover` | `color-primary-hover` |
| `color/text/primary` | `color-text-primary` |
| `color/text/secondary` | `color-text-secondary` |
| `color/bg/page` | `color-bg-page` |
| `color/bg/surface` | `color-bg-surface` |
| `typography/heading/family` | `font-heading` |
| `typography/body/family` | `font-body` |
| `typography/size/display` | `font-size-display` |
| `typography/size/h2` | `font-size-h2` |
| `spacing/unit` | `space-unit` |
| `spacing/md` | `space-md` |
| `spacing/section/y` | `section-padding-y` |
| `radius/sm` | `radius-sm` |
| `shadow/md` | `shadow-md` |

---

## Source 5 — Figma Design Frame

**Recognition signal:** A Figma frame URL or dev link is provided alongside a brief (Modes A/C) or as the sole input (Mode B).

**Extraction steps:**

1. **Run `get_design_context`** on the provided frame URL. This returns structured layout, spacing, colors, and typography from the frame.

2. **Run `get_variable_defs`** on the same node to retrieve any variable bindings on frame elements.

3. **Extract token values from the response:**
   - Fill colors → `color-primary`, `color-bg-page`, tint values
   - Text styles → `font-heading`, `font-body`, `font-size-*`
   - Spacing between elements → `space-*`, `section-padding-y`, `grid-gutter`
   - Border radius on cards/buttons → `radius-sm`, `radius-md`
   - Box shadows on cards → `shadow-md`

4. **Prefer variable-bound values** — if an element's color or spacing is bound to a Figma variable, use the variable name and value directly. This is the most reliable extraction path.

5. **For unbound values**, extract raw pixel/hex values and apply token name normalization based on context (e.g. button background color → `color-primary`, section top padding → `section-padding-y`).

6. **Apply token name normalization** (see Section 8).

7. **Flag gaps** — tokens that cannot be inferred from the frame's visible elements are left as `{PLACEHOLDER}`.

**Note:** Frame extraction is context-dependent — a hero-only frame won't yield spacing tokens for inner sections. A full-page frame produces the most complete extraction.

---

## Source 6 — Screenshot / Image

**Recognition signal:** A `.png`, `.jpg`, `.webp`, or similar image file is attached.

**Extraction steps:**

1. **Visual color extraction:**
   - Identify the dominant brand color (typically used on the primary CTA button) → `color-primary`
   - Identify the page background color → `color-bg-page`
   - Identify the primary text color → `color-text-primary`
   - Identify secondary text color (descriptions, metadata) → `color-text-secondary`
   - Identify card/surface backgrounds if distinguishable from page background → `color-bg-surface`
   - Identify any tinted section backgrounds → `tint-1`, `tint-2` surface colors

2. **Visual typography extraction:**
   - Identify heading font style (serif, sans-serif, display, weight) — describe it; do not guess the exact font name → flag `font-heading` as `{PLACEHOLDER}` with a visual description note
   - Identify body font style → same approach
   - Estimate heading font size relative to body size → `font-size-display`, `font-size-h1`, `font-size-h2`

3. **Visual spacing estimation:**
   - Estimate section vertical padding from visual breathing room → `section-padding-y`
   - Estimate content max-width from visible content column relative to viewport → `content-max-width`
   - Estimate card internal padding → `card-padding`

4. **Visual shape extraction:**
   - Identify border radius on buttons → `radius-sm`
   - Identify border radius on cards → `radius-md`
   - Identify shadow depth on cards → `shadow-sm`, `shadow-md`, `shadow-lg`, or `shadow-none`

5. **Flag all estimated values** — prefix estimated values with `/* estimated from screenshot */` comment in the output so they are clearly marked for human review before production use.

6. **Flag what cannot be extracted** — font names, exact spacing values, hover states, semantic colors (`color-success`, `color-error`), and tinted section border colors cannot be reliably extracted from a static screenshot. Flag all as `{PLACEHOLDER}`.

**Limitation:** Screenshot extraction yields approximate values only. All extracted values should be verified against the actual product before production use. This source is best used as a starting point, not a final fill.

---

## Source 7 — JSON Token File

**Recognition signal:** A `.json` file is attached or referenced.

**Extraction steps:**

1. **Identify the JSON format** — three common formats are supported:

   **Style Dictionary format:**
   ```json
   {
     "color": {
       "primary": { "value": "#E9142B" },
       "text": { "primary": { "value": "#1A1A1A" } }
     },
     "font": {
       "heading": { "value": "ZohoPuvi, sans-serif" }
     }
   }
   ```

   **W3C Design Tokens format:**
   ```json
   {
     "color-primary": { "$value": "#E9142B", "$type": "color" },
     "font-heading": { "$value": "ZohoPuvi", "$type": "fontFamily" }
   }
   ```

   **Figma Tokens (Tokens Studio) format:**
   ```json
   {
     "global": {
       "primary": { "value": "#E9142B", "type": "color" },
       "heading-font": { "value": "ZohoPuvi", "type": "fontFamilies" }
     }
   }
   ```

2. **Flatten the structure** — convert all nested paths to flat key → value pairs using `/` as separator:
   ```
   color/primary: #E9142B
   color/text/primary: #1A1A1A
   font/heading: ZohoPuvi, sans-serif
   ```

3. **Apply token name normalization** (see Section 8) to map flattened keys to canonical token names.

4. **Extract values** — use `value` or `$value` field depending on format.

5. **Resolve aliases** — if a value references another token (e.g. `{color.brand.primary}`), resolve it before mapping.

6. **Flag gaps** — canonical tokens with no JSON match are left as `{PLACEHOLDER}`.

---

## 8 — Token Name Normalization

Every source uses its own naming convention. This section defines how to map source names to canonical token names from `design-tokens/SKILL.md`.

### Step 1: Semantic Keyword Matching

Match source names to canonical tokens using keyword presence:

| If source name contains... | Map to canonical token |
|---|---|
| `primary` + color context | `color-primary` |
| `primary-hover` or `primary hover` | `color-primary-hover` |
| `secondary` + color context | `color-secondary` |
| `text-primary` or `text/primary` | `color-text-primary` |
| `text-secondary` or `text/secondary` | `color-text-secondary` |
| `text-tertiary` or `muted` | `color-text-tertiary` |
| `inverse` + text | `color-text-inverse` |
| `border-default` or `border/default` | `color-border-default` |
| `bg-page` or `background/page` or `surface/page` | `color-bg-page` |
| `bg-surface` or `background/surface` or `surface/card` | `color-bg-surface` |
| `success` + color | `color-success` |
| `warning` + color | `color-warning` |
| `error` or `danger` + color | `color-error` |
| `heading` + font | `font-heading` |
| `body` + font | `font-body` |
| `mono` or `code` + font | `font-mono` |
| `display` + size | `font-size-display` |
| `h1` + size | `font-size-h1` |
| `h2` + size | `font-size-h2` |
| `h3` + size | `font-size-h3` |
| `body-lg` or `body/lg` or `lead` | `font-size-body-lg` |
| `body` + size (default) | `font-size-body` |
| `body-sm` or `caption` or `small` | `font-size-body-sm` |
| `bold` + weight | `font-weight-bold` |
| `semibold` or `semi-bold` + weight | `font-weight-semibold` |
| `regular` + weight | `font-weight-regular` |
| `section-padding` or `section/padding` | `section-padding-y` |
| `max-width` or `container-width` | `content-max-width` |
| `narrow` + width | `content-max-width-narrow` |
| `sidebar` + width | `sidebar-width` |
| `gutter` | `grid-gutter` |
| `card-padding` or `card/padding` | `card-padding` |
| `shadow-sm` or `shadow/sm` or `shadow/subtle` | `shadow-sm` |
| `shadow-md` or `shadow/md` or `shadow/default` | `shadow-md` |
| `shadow-lg` or `shadow/lg` or `shadow/prominent` | `shadow-lg` |
| `radius-sm` or `radius/sm` or `radius/button` | `radius-sm` |
| `radius-md` or `radius/md` or `radius/card` | `radius-md` |
| `radius-lg` or `radius/lg` | `radius-lg` |
| `tint-1` or `tint/1` or `surface/tint-1` | `tint-1` (surface) |
| `tint-2` or `tint/2` or `surface/tint-2` | `tint-2` (surface) |
| `input-height` or `input/height` | `input-height` |
| `input-border` or `input/border` | `input-border` |
| `input-focus` or `input/focus` | `input-border-focus` |
| `avatar` + size | `avatar-size` |
| `map` + height | `map-height` |

### Step 2: Value-Type Matching (Fallback)

When keyword matching is inconclusive, use the value type and context:

| Value characteristics | Likely token |
|---|---|
| Hex/rgb color used as button background | `color-primary` |
| Hex/rgb color used as page/body background | `color-bg-page` |
| Hex/rgb color used as card background | `color-bg-surface` |
| Dark hex used as paragraph text color | `color-text-primary` |
| Medium-contrast hex used as description text | `color-text-secondary` |
| Font-family string containing a display/brand name | `font-heading` |
| Font-family string using system fonts | `font-body` |
| Largest font-size value on page | `font-size-display` or `font-size-h1` |
| Padding value on sections/rows | `section-padding-y` |
| Max-width on containers | `content-max-width` |
| Small border-radius (2–6px) | `radius-sm` |
| Medium border-radius (8–16px) | `radius-md` |

### Step 3: Flag Ambiguous Matches

If a source value cannot be confidently mapped to a canonical token after Steps 1 and 2:
- Do not guess — leave as `{PLACEHOLDER}`
- Add a comment: `/* ambiguous source value: {source-name}: {source-value} — review needed */`
- Include in the gap report

---

## 9 — Gap Handling

After extraction, some canonical tokens will remain as `{PLACEHOLDER}`. The agent handles gaps as follows:

### Gap Severity

| Gap Type | Severity | Action |
|---|---|---|
| `color-primary` missing | Critical | Stop — cannot generate CTAs without the primary color. Ask user to provide. |
| `font-heading` or `font-body` missing | High | Proceed with system font stack fallback (`-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`). Flag in output. |
| `font-size-*` missing | High | Proceed with browser defaults + type scale ratios. Flag in output. |
| `section-padding-y` missing | Medium | Proceed with `space-2xl` as fallback. Flag in output. |
| `color-text-primary` missing | Medium | Proceed with `#1A1A1A` as fallback. Flag in output. |
| `color-bg-page` missing | Medium | Proceed with `#FFFFFF` as fallback. Flag in output. |
| `tint-*` colors missing | Medium | Proceed without tinted sections — all sections use default background. Flag in output. |
| Spacing scale incomplete | Low | Proceed — derive missing scale steps from available values using ratio. Flag in output. |
| `shadow-*` missing | Low | Proceed with `shadow-none` as fallback. Flag in output. |
| Semantic colors (`color-success`, etc.) missing | Low | Proceed with conventional defaults (#2E7D32, #F57C00, #C62828, #1565C0). Flag in output. |

### Gap Report Format

After extraction, produce a gap summary:

```
## Token Extraction Gap Report

**Source:** {source type}
**Extracted:** {n} / 97 tokens
**Remaining gaps:** {n} tokens

### Critical
- [ ] color-primary — not found in source

### High
- [ ] font-heading — not found; using system font fallback

### Medium
- [ ] tint-1, tint-2, tint-3, tint-4 — not found; tinted sections disabled

### Low
- [ ] shadow-sm, shadow-md, shadow-lg — not found; using shadow-none fallback
```

Present this report to the user before proceeding with design decisions, so they can fill critical and high gaps if needed.

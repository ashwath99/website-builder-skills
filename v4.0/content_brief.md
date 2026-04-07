<!-- meta
name: content_brief
title: Content Brief
version: 4.0
status: active
purpose: Define how the agent parses a marketing content brief, identifies page sections, flags content gaps, and prepares structured input for downstream skill files.
owns:
  - Brief parsing rules
  - Section type identification
  - Content gap detection and severity levels
  - Audience classification logic
  - Parsed brief output format
  - Content-to-section mapping rules
requires:
  - workflow
depends_on:
  - layout_patterns
  - components
  - design_guide
referenced_by:
  - layout_patterns
  - components
  - variation_generator
  - trend_adaptation
  - agent_execution_prompt
modes:
  mode_a: required
  mode_b: not_used
  mode_c: required
layer: design_decision
last_updated: 2026-03-25
-->

# Content Brief — Parsing & Section Mapping

---

## 1 — What Is a Content Brief

A content brief is a marketing document (typically .txt, .md, .docx, or .pdf) provided by the product marketing team. It contains the raw content — headlines, descriptions, feature lists, CTAs, testimonials, and other copy — that will appear on the landing page.

The brief is **not** a design document. It does not specify layout, spacing, colors, or component types. Those decisions are made by the agent using other skill files.

The brief **may** include:
- Suggested section groupings or labels
- Target audience description
- Product screenshots or hero image references
- Competitive positioning notes
- SEO keywords or meta descriptions

---

## 2 — Parsing Process

When the agent receives a content brief, it follows these steps in order.

### Step 1: Read and Inventory

Read the entire brief. Produce a flat list of every content element found:

```
- Headlines (H1, H2, taglines)
- Body paragraphs (descriptions, explanations)
- Feature items (name + description pairs)
- CTA text (button labels, action phrases)
- Testimonials / quotes (attribution + quote text)
- Statistics / metrics (numbers with context)
- Logo/brand references (partner logos, certification badges)
- Image references (screenshots, hero images, illustrations)
- Meta content (page title, meta description, SEO keywords)
```

Do not interpret or reorganize yet — just inventory what exists.

### Step 2: Classify the Audience

Identify the target audience from the brief's context, explicit statements, or product category. Classify into one of these types:

| Audience Type | Indicators in Brief |
|---|---|
| **IT administrators / technical evaluators** | Feature specs, integration details, API mentions, deployment modes, technical comparisons |
| **Business decision-makers / executives** | ROI language, cost savings, compliance, scalability, "enterprise-grade" |
| **Developers / DevOps engineers** | Code examples, CLI references, API-first language, open-source mentions |
| **SMB owners / non-technical users** | Simple language, "easy setup", "no technical skills needed", affordability |
| **Mixed / multi-persona** | Brief contains sections clearly targeting different audiences |

The audience classification feeds into:
- `layout_patterns.md` → pattern selection logic
- `variation_generator.md` → constraint filters
- `trend_adaptation.md` → audience alignment table

### Step 3: Identify Page Sections

Group the inventoried content into page sections. Use these standard section types:

| Section Type | What It Contains | Required / Optional |
|---|---|---|
| **Hero** | Primary headline, subheadline, hero image/video, primary CTA | Required |
| **Value Proposition** | Core benefits, elevator pitch, differentiators | Optional (can merge into hero) |
| **Feature Overview** | Feature list with names, descriptions, icons/images | Required (at least one feature section) |
| **Feature Deep-Dive** | Detailed feature walkthrough with screenshots, tabs, or expandable content | Optional |
| **Social Proof** | Testimonials, customer quotes, case study excerpts | Optional but recommended |
| **Trust Signals** | Partner/customer logos, certification badges, award icons | Optional but recommended |
| **Statistics / Metrics** | Key numbers (uptime, users, savings) with context | Optional |
| **Use Cases / Scenarios** | Audience-specific use case descriptions | Optional |
| **Integration / Ecosystem** | Compatible tools, platforms, APIs | Optional |
| **Pricing / Plans** | Pricing tiers, feature comparison tables | Optional |
| **FAQ** | Common questions and answers | Optional |
| **Closing CTA** | Final conversion section with CTA + reinforcement copy | Required |

**Rules:**
- Every brief must produce at minimum: Hero + at least one Feature section + Closing CTA
- If the brief contains content that doesn't fit any standard section type, flag it as "unclassified" and note it for manual review
- If the brief groups content differently than these types, respect the brief's grouping but map each group to the closest section type

### Step 4: Flag Content Gaps

Compare the identified sections against the brief content. Flag any of these issues:

| Gap Type | Description | Severity |
|---|---|---|
| **Missing hero headline** | Brief has no clear primary headline | Critical — cannot proceed without |
| **Missing CTA text** | No button labels or action phrases | Critical — cannot proceed without |
| **No feature descriptions** | Feature names exist but descriptions are missing | High — feature sections will be shallow |
| **No social proof** | No testimonials, quotes, or customer references | Medium — page can work without, but trust is weakened |
| **No images referenced** | No screenshots, hero images, or visual assets mentioned | Medium — layout options are constrained |
| **Ambiguous audience** | Brief doesn't indicate who the page is for | Medium — affects layout and tone decisions |
| **Duplicate content** | Same copy appears in multiple places in the brief | Low — agent deduplicates during mapping |
| **SEO content missing** | No page title, meta description, or keywords | Low — can be generated from existing content |

**On critical gaps:** Stop and report to the user before proceeding. Do not invent missing content.

**On high/medium gaps:** Note the gap, proceed with available content, and flag the gap in the output (Mode A: in the Figma frame as a note; Mode C: in the Page Blueprint's asset manifest or as a comment in code).

### Step 5: Produce the Parsed Brief Output

The final output of brief parsing is a structured summary that downstream files consume:

```markdown
## Parsed Brief: {Product Name}

**Source file:** {brief-filename}
**Audience:** {audience type from Step 2}
**Date parsed:** {YYYY-MM-DD}

### Sections Identified

1. **Hero**
   - Headline: "{exact text from brief}"
   - Subheadline: "{exact text}"
   - CTA: "{button text}"
   - Image: {reference or "none"}

2. **Feature Overview**
   - Feature 1: {name} — {description}
   - Feature 2: {name} — {description}
   - ...

3. **Social Proof**
   - Quote 1: "{quote}" — {attribution}
   - ...

4. **Closing CTA**
   - Headline: "{text}"
   - CTA: "{button text}"
   - Secondary CTA: "{text}" or "none"

### Content Gaps
- {gap type}: {description} [{severity}]

### Assets Referenced
- {filename or description}: {available / TODO}

### Notes
- {any unclassified content, ambiguities, or observations}
```

---

## 3 — Content Mapping Rules

These rules govern how brief content maps to page elements.

### Headlines
- The first or most prominent headline in the brief becomes the hero H1
- Section-level headlines become H2s
- Sub-section headlines become H3s
- If the brief provides multiple headline options, use the first one and note alternatives in the parsed brief

### CTA Text
- The primary CTA (most prominent or first mentioned) maps to the hero CTA and closing CTA
- Secondary CTAs (demo requests, documentation links, secondary actions) map to contextual CTAs within sections
- If only one CTA is provided, it's used in both hero and closing sections

### Feature Content
- Each feature needs at minimum: a name and a one-line description
- If the brief provides detailed feature descriptions (2+ paragraphs), these map to a Feature Deep-Dive section
- If the brief provides only names + short descriptions, these map to a Feature Overview (grid or card layout)
- Feature count affects component selection:
  - 1–3 features → alternating rows or large cards
  - 4–6 features → icon grid (2 or 3 columns)
  - 7+ features → tabbed deep-dive, accordion, or multi-section layout

→ Component selection rules are in `components.md`
→ Layout pattern selection is in `layout_patterns.md`

### Testimonials and Social Proof
- Direct quotes with attribution → testimonial component
- Customer logos without quotes → logo bar component
- Case study references → linked card or dedicated section
- Statistics without testimonials → metrics bar component

→ Component specs are in `components.md`

### Images and Assets
- Hero images referenced in the brief → hero section background or split-image layout
- Product screenshots → feature sections or hero product display
- Icons mentioned but not provided → flagged as TODO in asset manifest
- If no images are referenced, flag this as a content gap and note that layout options are constrained (no split-image hero, no alternating image-text rows)

---

## 4 — Brief Variants

Not all briefs look the same. The agent should handle these common formats:

### Well-Structured Brief
Content is already grouped by section, with clear labels. The agent's job is mostly validation — confirm sections, flag gaps, map to section types.

### Flat Document
All content in a single flow without section labels. The agent must identify section boundaries based on content type (headlines, feature lists, quotes) and group accordingly.

### Spreadsheet / Table Format
Content organized in rows — feature name | description | icon reference. The agent extracts and restructures into the parsed brief format.

### Partial Brief
Only some sections are provided. Flag missing sections as content gaps. Proceed with available content for non-critical gaps; stop and report for critical gaps.

### Multiple Product Brief
A single document covering multiple products or pages. The agent should identify product boundaries and parse each product's content separately. Confirm with the user which product to build first.

---

## 5 — Handoff to Downstream Files

After parsing, the structured output feeds into these files based on the active mode:

| Downstream File | What It Receives | Purpose |
|---|---|---|
| `layout_patterns.md` | Section list + audience type + feature count | Selects the page layout pattern |
| `components.md` | Section types + content volume per section | Selects component configurations for each section |
| `design_guide.md` | Audience type (for tone-appropriate token selection) | Confirms token set to use |
| `variation_generator.md` | Full parsed brief + content gaps + audience type | Generates variant specs with constraint filters |
| `trend_adaptation.md` | Audience type | Aligns trend recommendations to audience expectations |

The parsed brief is consumed by these files — it is never modified after Step 5. If the brief changes, re-run the full parsing process.

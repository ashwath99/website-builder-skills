---
name: brief-parser
description: Parses marketing content briefs to infer page type, classify audiences, identify page sections, detect content gaps, and produce structured input for downstream skills. Use when processing any content brief, marketing document, or product copy that needs to be converted into a web page structure.
version: "5.1.0"
---

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

### Step 1b: Content Deduplication

**Why this step exists:** When the brief source is a website markdown export (scraped HTML converted to markdown), the same content often appears multiple times — in navigation menus, hero areas, feature sections, footer links, and sidebar elements. Without deduplication, the agent maps the same features to 3+ sections, inflating the page and creating ambiguous section boundaries.

**Process:**

1. **Identify navigation and footer content** — Text that appears in `<nav>`, header menus, footer link lists, breadcrumbs, or sidebar navigation is structural, not page content. Mark it as `[NAV]` or `[FOOTER]` and exclude from section mapping.

2. **Detect duplicate feature mentions** — If the same feature name (or near-identical phrasing) appears in 2+ locations:
   - Keep the **most detailed instance** (the one with the longest description, supporting bullet points, or accompanying image references)
   - Mark shorter mentions as duplicates: `[DUP — see {location of primary instance}]`
   - The primary instance is the one that will map to a section; duplicates are discarded

3. **Collapse repeated CTA text** — The same CTA ("Start Free Trial", "Get a Quote") may appear 5+ times across the page. Inventory it once with a count: `CTA: "Start Free Trial" (appears 6×)`.

4. **Preserve unique content** — Any content element that is NOT a duplicate of something already inventoried remains in the flat list for section mapping.

**Output:** A deduplicated inventory where each content element appears exactly once, with navigation/footer content excluded. This feeds into Step 2 and Step 3.

**Example:**
```
Before dedup: 47 content elements (including 3× "Endpoint Security" mentions,
  8× navigation links, 5× "Start Free Trial" CTAs)
After dedup: 28 unique content elements
  — 12 nav/footer items excluded
  — 7 duplicate feature mentions collapsed
```

### Step 2: Infer Page Type and Classify Audience

Run both inferences in parallel — they are independent and both feed into downstream skills.

#### 2a — Infer Page Type

Read the brief for the strongest content signals and match to the most probable page type. Do not force a match — if signals are mixed, flag as ambiguous and default to Product Landing.

| Page Type | Strong Signals |
|---|---|
| **Product Landing** | Primary headline + feature list + product CTA + product description |
| **Feature Detail** | Single feature deep-dive, per-feature screenshots, use case scenarios |
| **Pricing** | Named pricing tiers with prices, plan comparison, billing FAQ |
| **Home Page** | Multiple product or service references, brand-level headline, varied audience signals |
| **About / Company** | Team members, company mission/values, founding story, culture content |
| **Case Study** | Named customer + industry, problem statement, solution, results/metrics |
| **Blog Article** | Author name + date, paragraph-form body copy, structured headings |
| **Blog Index** | List of article titles + excerpts + dates, category filters |
| **Event / Webinar** | Event name + date + time, speaker bios, agenda, registration CTA |
| **Contact** | Contact form fields, email/phone, office address |
| **Partner / Integrations** | Integration or partner names + logos + descriptions, filterable catalog |
| **Resource / Download** | Downloadable asset titles, file types, form gate for access |
| **Documentation Hub** | Structured nav hierarchy, technical instructions, code examples |
| **Error Page** | Error code or message, navigation fallback, no structured content sections |

**Ambiguity rule:** If a brief contains pricing tiers alongside features, infer Product Landing (pricing is a section, not the page type). If it explicitly names a page or URL slug, use that to resolve ambiguity. If uncertain after applying these rules, flag as ambiguous in the output and default to Product Landing.

The page type inference feeds into:
- `layout-patterns` → page assembly logic (Section 5)

#### 2b — Classify the Audience

Identify the target audience from the brief's context, explicit statements, or product category. Classify into one of these types:

| Audience Type | Indicators in Brief |
|---|---|
| **IT administrators / technical evaluators** | Feature specs, integration details, API mentions, deployment modes, technical comparisons |
| **Business decision-makers / executives** | ROI language, cost savings, compliance, scalability, "enterprise-grade" |
| **Developers / DevOps engineers** | Code examples, CLI references, API-first language, open-source mentions |
| **SMB owners / non-technical users** | Simple language, "easy setup", "no technical skills needed", affordability |
| **General / consumer** | Non-technical tone, lifestyle language, broad appeal, no product category jargon |
| **Mixed / multi-persona** | Brief contains sections clearly targeting different audiences |

The audience classification feeds into:
- `layout-patterns` → page assembly constraints
- `variation-explorer` → constraint filters
- `trend-adapter` → audience alignment table

### Step 3: Identify Page Sections

Group the inventoried content into page sections using the section types below. The applicable set depends on the inferred page type from Step 2a — but any section type can appear on any page if the content warrants it.

#### Core Sections (apply to most page types)

| Section Type | What It Contains |
|---|---|
| **Page Hero** | Primary headline, subheadline, hero image/video, primary CTA |
| **Value Proposition** | Core benefits, elevator pitch, differentiators (can merge into hero) |
| **Feature Overview** | Feature list with names, descriptions, icons/images |
| **Feature Deep-Dive** | Detailed feature walkthrough with screenshots, tabs, or expandable content |
| **How It Works** | Step-by-step process explanation (3–6 steps with numbers/icons) |
| **Social Proof** | Testimonials, customer quotes, case study excerpts |
| **Trust Signals** | Partner/customer logos, certification badges, award icons |
| **Statistics / Metrics** | Key numbers (uptime, users, savings, results) with context |
| **Use Cases / Scenarios** | Audience-specific use case descriptions |
| **Integration / Ecosystem** | Compatible tools, platforms, APIs |
| **Pricing / Plans** | Pricing tiers, plan feature comparison |
| **FAQ** | Common questions and answers |
| **Closing CTA** | Final conversion section with CTA + reinforcement copy |

#### Product & Feature Sections

| Section Type | What It Contains |
|---|---|
| **Comparison Table** | Feature-by-feature comparison vs alternatives or across plans |
| **Screenshots / Demo Gallery** | Product screenshots, UI walkthroughs, demo video embeds |
| **Technical Specs** | Detailed spec lists, system requirements, API details |
| **Related Features** | Links or cards pointing to adjacent features |

#### About & Company Sections

| Section Type | What It Contains |
|---|---|
| **Mission / Vision** | Company mission, vision statement, brand purpose |
| **Company Story** | Founding story, history, milestones (often timeline format) |
| **Team Members** | People cards with name, role, photo, optional bio |
| **Company Values / Culture** | Value statements, culture description, workplace info |
| **Press / Awards** | Press logos, award badges, media mentions |
| **Investor / Partner Logos** | Investor names/logos, strategic partner logos |
| **Office Locations** | Address(es), map, regional contact info |
| **Open Roles CTA** | Careers link or job listing summary |

#### Case Study Sections

| Section Type | What It Contains |
|---|---|
| **Customer Overview** | Customer name, industry, company size, logo |
| **Challenge / Problem** | The problem the customer faced before the solution |
| **Solution Description** | How the product solved the problem |
| **Results / Outcomes** | Quantified results, metrics, before/after data |
| **Implementation Timeline** | How the solution was rolled out, phases or milestones |
| **Customer Quote** | Direct attributed quote from the customer contact |

#### Blog & Editorial Sections

| Section Type | What It Contains |
|---|---|
| **Article Header** | Title, author name, publish date, reading time, category tags |
| **Article Body** | Long-form paragraph content, structured with H2/H3 headings |
| **Pull Quote / Callout** | Highlighted quote or key point pulled from the article body |
| **Author Bio** | Author photo, name, role/title, brief bio |
| **Related Articles** | Cards or links to related posts |
| **Article Tags / Categories** | Topic classification for filtering and navigation |

#### Event & Registration Sections

| Section Type | What It Contains |
|---|---|
| **Event Details** | Event name, date, time, format (virtual/in-person), location |
| **Countdown Timer** | Live countdown to event date |
| **Speaker Profiles** | Speaker photo, name, title, company, bio |
| **Agenda / Schedule** | Session list with times, titles, speakers |
| **Registration Form** | Sign-up form fields, submit CTA |
| **Past Event Highlights** | Photos, video clips, or stats from previous editions |
| **Sponsor / Partner Logos** | Event sponsors displayed as logo bar |

#### Navigation & Index Sections

| Section Type | What It Contains |
|---|---|
| **Content Listing** | Grid or list of cards (articles, resources, integrations, case studies) |
| **Filter / Category Bar** | Topic or type filters for a content index |
| **Featured Item** | Highlighted single card at the top of an index |
| **Pagination / Load More** | Page navigation or infinite scroll trigger |
| **Search Bar** | Keyword search input for docs, resources, or catalog |

#### Contact & Support Sections

| Section Type | What It Contains |
|---|---|
| **Contact Form** | Name, email, message fields + submit |
| **Contact Details** | Email address, phone number, support hours |
| **Map** | Embedded map with office pin(s) |
| **Support Channels** | Links to help docs, live chat, community forum |

#### Universal Footer / Utility Sections

| Section Type | What It Contains |
|---|---|
| **Newsletter Signup** | Email input + subscribe CTA (standalone, not closing CTA) |
| **Resource Download** | Asset title, description, file type, download or gated form |
| **Error Message** | Error code, friendly copy, navigation fallback |

**Rules:**
- Map every block of content to the closest section type above
- If content doesn't fit any type, flag it as "unclassified" and note it for manual review
- Respect the brief's groupings — don't restructure content, just classify it
- A brief may produce sections from multiple categories (e.g. a product landing page can include a How It Works and a Case Study excerpt)

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
## Parsed Brief: {Product / Page Name}

**Source file:** {brief-filename}
**Page type:** {inferred page type from Step 2a} {— "ambiguous, defaulting to Product Landing" if applicable}
**Audience:** {audience type from Step 2b}
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

→ Component selection rules are in `component-library`
→ Layout pattern selection is in `layout-patterns`

### Testimonials and Social Proof
- Direct quotes with attribution → testimonial component
- Customer logos without quotes → logo bar component
- Case study references → linked card or dedicated section
- Statistics without testimonials → metrics bar component

→ Component specs are in `component-library`

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
| `layout-patterns` | Inferred page type + section list + audience type + feature count + asset availability | Selects applicable sections and layout types via page assembly logic |
| `component-library` | Section types + content volume per section | Selects component configurations for each section |
| `design-tokens` | Audience type | Confirms tone-appropriate token set |
| `variation-explorer` | Full parsed brief + inferred page type + content gaps + audience type | Generates variant specs with constraint filters |
| `trend-adapter` | Audience type | Aligns trend recommendations to audience expectations |

The parsed brief is consumed by these files — it is never modified after Step 5. If the brief changes, re-run the full parsing process.

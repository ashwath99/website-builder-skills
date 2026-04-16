---
name: brief-parser
description: Parses marketing content briefs to infer page type, classify audiences, identify page sections, detect content gaps, and produce structured input for downstream skills. Use when processing any content brief, marketing document, or product copy that needs to be converted into a web page structure.
version: "5.3.0"
---

# Content Brief — Parsing & Section Mapping

---

## 1 — What Is a Content Brief

A marketing document (.txt, .md, .docx, .pdf) with raw content for a landing page: headlines, descriptions, feature lists, CTAs, testimonials, copy. **Not** a design document — layout/spacing/colors come from other skill files. May include section groupings, audience description, screenshots, competitive notes, SEO keywords.

---

## 2 — Parsing Process

### Step 1: Read and Inventory

Produce a flat list of every content element: headlines (H1/H2/taglines), body paragraphs, feature items (name + description), CTA text, testimonials/quotes, statistics/metrics, logo/brand references, image references, meta content (title, description, keywords). Do not reorganize yet.

### Step 1b: Content Deduplication

For scraped website briefs, the same content appears in nav, hero, features, footer. Without dedup, features map to 3+ sections.

1. **Nav/footer content** — Mark as `[NAV]`/`[FOOTER]`, exclude from section mapping
2. **Duplicate features** — Same feature in 2+ locations → keep most detailed instance, mark others `[DUP]`
3. **Repeated CTAs** — Inventory once with count: `CTA: "Start Free Trial" (appears 6×)`
4. **Preserve unique content** — Everything not duplicated stays

**Output:** Deduplicated inventory. Example: 47 elements → 28 unique (12 nav excluded, 7 dupes collapsed).

### Step 2: Infer Page Type and Classify Audience

Run both in parallel — independent, both feed downstream.

#### 2a — Page Type

| Page Type | Strong Signals |
|---|---|
| **Product Landing** | Primary headline + feature list + product CTA |
| **Feature Detail** | Single feature deep-dive, per-feature screenshots |
| **Pricing** | Named tiers with prices, plan comparison, billing FAQ |
| **Home Page** | Multiple product references, brand-level headline |
| **About / Company** | Team members, mission/values, founding story |
| **Case Study** | Named customer, problem → solution → results |
| **Blog Article** | Author + date, paragraph-form body, structured headings |
| **Blog Index** | Article titles + excerpts + dates, category filters |
| **Event / Webinar** | Event name + date + time, speaker bios, registration CTA |
| **Contact** | Form fields, email/phone, office address |
| **Partner / Integrations** | Integration names + logos + descriptions |
| **Resource / Download** | Downloadable assets, form gate |
| **Documentation Hub** | Structured nav, technical instructions, code examples |
| **Error Page** | Error code/message, navigation fallback |

**Ambiguity:** Pricing tiers + features → Product Landing (pricing is a section). Explicit URL slug resolves ambiguity. Default: Product Landing.

#### 2b — Audience

| Audience Type | Indicators |
|---|---|
| **IT admins / technical evaluators** | Feature specs, integrations, API, deployment |
| **Business decision-makers** | ROI, cost savings, compliance, "enterprise-grade" |
| **Developers / DevOps** | Code examples, CLI, API-first, open-source |
| **SMB / non-technical** | Simple language, "easy setup", affordability |
| **General / consumer** | Non-technical, lifestyle, broad appeal |
| **Mixed / multi-persona** | Sections targeting different audiences |

### Step 3: Identify Page Sections

Group inventoried content into section types below. Applicable set depends on page type, but any type can appear if content warrants it.

#### Core Sections

| Section Type | Contains |
|---|---|
| **Page Hero** | Primary headline, subheadline, hero image/video, primary CTA |
| **Value Proposition** | Core benefits, differentiators (can merge into hero) |
| **Feature Overview** | Feature list: names, descriptions, icons |
| **Feature Deep-Dive** | Detailed walkthrough with screenshots, tabs, expandable |
| **How It Works** | Step-by-step process (3–6 steps) |
| **Social Proof** | Testimonials, quotes, case study excerpts |
| **Trust Signals** | Partner/customer logos, certifications, awards |
| **Statistics / Metrics** | Key numbers with context |
| **Use Cases** | Audience-specific use case descriptions |
| **Integration / Ecosystem** | Compatible tools, platforms, APIs |
| **Pricing / Plans** | Tiers, plan comparison |
| **FAQ** | Questions and answers |
| **Closing CTA** | Final CTA + reinforcement copy |

#### Extended Sections (use when content warrants)

| Category | Types |
|---|---|
| **Product** | Comparison Table, Screenshots/Demo Gallery, Technical Specs, Related Features |
| **Company** | Mission/Vision, Company Story, Team Members, Values/Culture, Press/Awards, Investor Logos, Office Locations, Open Roles CTA |
| **Case Study** | Customer Overview, Challenge/Problem, Solution, Results/Outcomes, Implementation Timeline, Customer Quote |
| **Blog** | Article Header, Article Body, Pull Quote, Author Bio, Related Articles, Tags/Categories |
| **Event** | Event Details, Countdown Timer, Speaker Profiles, Agenda, Registration Form, Past Highlights, Sponsor Logos |
| **Index/Nav** | Content Listing, Filter Bar, Featured Item, Pagination, Search Bar |
| **Contact** | Contact Form, Contact Details, Map, Support Channels |
| **Utility** | Newsletter Signup, Resource Download, Error Message |

**Rules:** Map every content block to closest type. Unclassified → flag for review. Respect brief groupings. Sections can span categories.

### Step 3b: Section Budget and Feature Prioritization

Briefs (especially scraped) often produce 12–15+ sections. This constrains the count.

#### Section Budget

| Page Type | Recommended | Max |
|---|---|---|
| Product Landing | 7–9 | 11 |
| Feature Detail | 5–7 | 9 |
| Home Page | 8–10 | 12 |
| Case Study | 5–7 | 8 |
| Pricing | 4–6 | 8 |
| About / Company | 6–8 | 10 |
| Blog Article | 3–5 | 6 |
| Event / Webinar | 5–7 | 9 |
| All others | 5–8 | 10 |

Over max → merge related sections or drop lowest-priority. Report original vs final count.

#### Feature Prioritization

| Count | Action |
|---|---|
| 1–6 | Show all in grid |
| 7–9 | Split: Grid (top 4–6) + Tabs/Row (remaining) |
| 10–15 | Select top 6–8, note rest |
| 16+ | Select top 6, categorize rest |

**Selection criteria (in order):** Most detailed description → mentioned in hero/value prop → has screenshot → unique to product (not commodity) → aligns with classified audience.

Output: `Selected (N of M): {list}` + `Deferred (N): {list}`

### Step 4: Flag Content Gaps

| Gap | Severity |
|---|---|
| Missing hero headline | Critical — stop |
| Missing CTA text | Critical — stop |
| No feature descriptions | High — sections shallow |
| No social proof | Medium — proceed, flag |
| No images referenced | Medium — layout constrained |
| Ambiguous audience | Medium — flag |
| Duplicate content | Low — deduplicate |
| SEO content missing | Low — can generate |

**Critical:** Stop, report. **High/Medium:** Proceed, flag in output.

### Step 5: Parsed Brief Output

```markdown
## Parsed Brief: {Product / Page Name}

**Source:** {filename} | **Page type:** {type} | **Audience:** {type} | **Date:** {YYYY-MM-DD}

### Sections Identified

1. **Hero** — Headline: "{text}" | Sub: "{text}" | CTA: "{text}" | Image: {ref}
2. **Feature Overview** — Feature 1: {name} — {desc} | Feature 2: ...
3. **Social Proof** — Quote 1: "{quote}" — {attribution}
4. **Closing CTA** — Headline: "{text}" | CTA: "{text}"

### Content Gaps
- {type}: {description} [{severity}]

### Assets Referenced
- {filename}: {available / TODO}

### Feature Prioritization
- **Selected (N of M):** {list}
- **Deferred (N):** {list}
```

---

## 3 — Content Mapping Rules

**Headlines:** First/most prominent → hero H1. Section headlines → H2. Sub-sections → H3. Multiple options → use first, note alternatives.

**CTAs:** Primary (first/prominent) → hero + closing CTA. Secondary → contextual within sections. Single CTA → reuse in hero and closing.

**Features:** Name + short desc → Feature Overview (grid). Name + 2+ paragraphs → Feature Deep-Dive. Count: 1–3 → large cards/rows, 4–6 → icon grid, 7+ → tabs/accordion/multi-section. → Component selection: `component-library`. Layout: `layout-patterns`.

**Social Proof:** Quotes + attribution → testimonial. Logos only → logo bar. Case study refs → linked card. Stats only → metrics bar.

**Images:** Hero image → hero background or split layout. Screenshots → feature sections. Missing icons → TODO in manifest. No images → flag gap, constrain layout.

---

## 4 — Brief Variants

| Format | Handling |
|---|---|
| **Well-structured** | Validate sections, flag gaps, classify |
| **Flat document** | Identify boundaries by content type, group |
| **Spreadsheet/table** | Extract rows, restructure to parsed format |
| **Partial** | Flag missing sections; stop on critical gaps |
| **Multi-product** | Identify boundaries, parse separately, confirm which to build |

---

## 5 — Handoff to Downstream

| File | Receives | Purpose |
|---|---|---|
| `layout-patterns` | Page type + sections + audience + feature count + assets | Section/layout selection |
| `component-library` | Section types + content volume | Component configuration |
| `design-tokens` | Audience type | Tone-appropriate tokens |
| `variation-explorer` | Full parsed brief + page type + gaps + audience | Variant generation |
| `trend-adapter` | Audience type | Audience-aligned trends |

Parsed brief is consumed, never modified. Brief changes → re-run full parse.

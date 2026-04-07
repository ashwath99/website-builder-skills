## 5 — CTA Components

### 5.1 — CTA Section

Dedicated conversion section — typically used as the closing section and optionally mid-page.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `heading` | H2 — action-oriented headline | Yes |
| `description` | Supporting text, 1–2 sentences | Optional |
| `primary_cta` | Primary button | Yes |
| `secondary_cta` | Secondary button or link | Optional |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `centered` | All content centered (default) |
| `with-background` | Tinted or colored background to visually distinguish |
| `split` | Text left, CTA right |

**Responsive Behavior:**
- Desktop: Based on variant configuration
- Mobile: All variants collapse to centered stack, CTA full-width

---

### 5.2 — Sticky CTA Bar

Persistent bottom bar visible at all scroll positions.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `text` | Short reinforcement line | Optional |
| `primary_cta` | Primary button | Yes |

**Behavior:**
- Hidden on initial load (hero CTA is visible)
- Appears after user scrolls past the hero section
- Fixed to bottom of viewport
- Dismissible or persistent based on configuration

→ For sticky bar JS pattern: see `css-js-generator/SKILL.md`

**Responsive Behavior:**
- Desktop: Bar spans full width, CTA right-aligned
- Mobile: Bar spans full width, CTA centered, full-width button

---

## 6 — Content Components

### 6.1 — FAQ Accordion

Specialized accordion for question/answer pairs.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Frequently Asked Questions" or similar | Yes |
| `items` | Array of Q&A pairs | Yes (min 3) |
| ↳ `question` | Question text (accordion trigger) | Yes |
| ↳ `answer` | Answer text (accordion content) | Yes |

Uses the same interaction pattern and responsive behavior as Accordion (Section 3.5).

---

### 6.2 — Pricing Table

Feature comparison across pricing tiers.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Pricing" or similar | Yes |
| `tiers` | Array of pricing tiers, each containing: | Yes (min 2) |
| ↳ `name` | Tier name (e.g., "Free", "Pro", "Enterprise") | Yes |
| ↳ `price` | Price text (e.g., "$29/mo") | Yes |
| ↳ `description` | Brief tier description | Optional |
| ↳ `features` | List of included features | Yes |
| ↳ `cta` | Tier-specific CTA button | Yes |
| ↳ `highlighted` | Boolean — visually emphasize this tier | Optional |

**Configuration Variants:**

| Variant | Description |
|---|---|
| `cards` | Each tier is a separate card, side by side |
| `table` | Feature comparison table with tiers as columns |

**Responsive Behavior:**
- Desktop: Cards side by side or full table visible
- Tablet: Horizontal scroll for table; cards may stack to 2-col
- Mobile: Cards stack vertically; table becomes a card-per-tier view

---

### 6.3 — Integration Grid

Grid of compatible tools/platform logos with optional descriptions.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Integrations" or similar | Yes |
| `section_description` | Supporting text | Optional |
| `items` | Array of integration items | Yes (min 3) |
| ↳ `logo` | Integration/tool logo | Yes |
| ↳ `name` | Tool/platform name | Yes |
| ↳ `description` | Brief description | Optional |

**Responsive Behavior:**
- Desktop: 4–6 column grid
- Tablet: 3 columns
- Mobile: 2 columns

---

## 7 — Composition Rules

### Nesting
- Feature Grid contains Feature Cards
- Testimonial Carousel contains Testimonial Cards
- Tabbed Feature Panel contains tab items (not standalone components)
- Accordion contains accordion items (not standalone components)
- No deeper nesting — components are max 2 levels (container → item)

### Exclusions
- A page should not use both Tabbed Feature Panel and Accordion for features — choose one
- Sticky CTA Bar should not be used alongside `contextual` CTA strategy (they compete for attention)
- Logo Bar and Metrics Bar can coexist but should not be adjacent sections (too visually similar)

### Section-to-Component Mapping

This table connects section types from `brief-parser/SKILL.md` to available components:

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Hero | Hero: Split Image | Hero: Full Bleed, Hero: Product Centered, Hero: Text Bold, Hero: Mini |
| Feature Overview | Feature Grid | Feature Row (alternating) |
| Feature Deep-Dive | Tabbed Feature Panel | Accordion, Feature Row (alternating) |
| Social Proof | Testimonial Carousel | Testimonial Card (single), static grid |
| Trust Signals | Logo Bar | Metrics Bar (if stats-focused) |
| Statistics / Metrics | Metrics Bar | Inline within other sections |
| Use Cases / Scenarios | Feature Row (alternating) | Feature Grid with use-case cards |
| Integration / Ecosystem | Integration Grid | Logo Bar (if logo-only) |
| Pricing / Plans | Pricing Table | Feature Grid (simplified) |
| FAQ | FAQ Accordion | — |
| Closing CTA | CTA Section | — |

→ For which component variants the variation axes select: see `variation-explorer/SKILL.md`

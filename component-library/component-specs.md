## 7 — People & Profile Components

### 7.1 — Team Card

Person profile card for About pages, team sections, and author listings.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `photo` | Person headshot image | Optional |
| `name` | Full name | Yes |
| `role` | Job title | Yes |
| `department` | Department or team | Optional |
| `bio` | Short bio, 1–3 sentences | Optional |
| `social_links` | LinkedIn, Twitter, or other profile links | Optional |

**Variants:** `compact` (photo + name + role only) / `full` (with bio and links, default)

**Responsive:** Full-width stack on mobile; grid controlled by layout-patterns (`grid-3col` or `grid-4col`).

---

### 7.2 — Author Bio

Author attribution block for blog articles and editorial content.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `photo` | Author headshot | Optional |
| `name` | Author full name | Yes |
| `role` | Job title or descriptor (e.g. "Senior Writer") | Optional |
| `bio` | Short bio, 1–2 sentences | Optional |
| `social_links` | Author profile links | Optional |

**Variants:** `inline` (small, at top of article) / `card` (larger block at article footer, default)

**Responsive:** Full-width at all breakpoints; photo floats left in card variant, stacks on mobile.

---

### 7.3 — Speaker Card

Event speaker profile for webinar and event pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `photo` | Speaker headshot | Yes |
| `name` | Speaker full name | Yes |
| `title` | Job title | Yes |
| `company` | Company or organization | Yes |
| `company_logo` | Company logo | Optional |
| `bio` | Speaker bio, 1–3 sentences | Optional |
| `topic` | Talk title or session topic | Optional |

**Responsive:** Grid controlled by layout-patterns (`grid-3col` or `grid-2col`). Full-width stack on mobile.

---

## 8 — Timeline & Process Components

### 8.1 — Timeline

Sequence of dated events or milestones. Used for company history, case study journeys, and product roadmaps.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `items` | Array of timeline entries | Yes (min 2) |
| ↳ `date` | Date or date range (e.g. "2021", "Q2 2023") | Yes |
| ↳ `heading` | H4 — event or milestone title | Yes |
| ↳ `description` | Brief description | Optional |
| ↳ `image` | Optional supporting image | Optional |

**Variants:** `vertical` (default — stacked with connector line) / `horizontal` (desktop only, milestone dots on a line)

**Responsive:** Horizontal variant collapses to vertical on tablet/mobile. Connector line becomes left-edge rail on vertical mobile.

---

### 8.2 — Agenda List

Schedule of sessions with times, titles, and speakers. Used on event and webinar pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — "Agenda" or "Schedule" | Yes |
| `items` | Array of agenda sessions | Yes (min 1) |
| ↳ `time` | Session start time (and optional end time) | Yes |
| ↳ `title` | Session title | Yes |
| ↳ `speaker` | Speaker name(s) | Optional |
| ↳ `description` | Brief session description | Optional |
| ↳ `type` | Session type label (e.g. "Talk", "Workshop", "Break") | Optional |

**Variants:** `simple` (time + title only) / `full` (with speaker, description, type label, default)

**Responsive:** Full-width at all breakpoints; stacked list view on mobile.

---

### 8.3 — Countdown Timer

Live countdown display to a future event date. Used on event and webinar pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `target_date` | ISO date string for the countdown target | Yes |
| `label` | Text above the timer (e.g. "Event starts in") | Optional |
| `post_event_text` | Text shown after the date has passed (e.g. "Watch the replay") | Optional |

**Behavior:** Updates in real time. On expiry, hides timer and shows `post_event_text` or a replay CTA.

**Responsive:** Digit blocks scale down on mobile; units remain legible.

→ For countdown JS implementation: see `css-js-generator/SKILL.md`

---

### 8.4 — Event Details Block

Structured display of key event information — date, time, format, location.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `date` | Event date(s) | Yes |
| `time` | Start time and optional end time, with timezone | Yes |
| `format` | "Virtual", "In-person", or "Hybrid" | Yes |
| `location` | Venue name and city, or platform name for virtual | Optional |
| `language` | Presentation language | Optional |
| `capacity` | "Limited seats" or seat count if relevant | Optional |

**Variants:** `horizontal` (details in a row, default for hero sections) / `vertical` (stacked, for sidebar or compact placement)

**Responsive:** Horizontal collapses to vertical on mobile.

---

## 9 — Navigation & Index Components

### 9.1 — Article Card

Card for listing content items — blog posts, resources, case studies, documentation articles.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `thumbnail` | Article image or cover | Optional |
| `category` | Topic tag or category label | Optional |
| `title` | Article or resource title | Yes |
| `excerpt` | Short description or article preview, 1–2 sentences | Optional |
| `author` | Author name | Optional |
| `date` | Publish date | Optional |
| `read_time` | Estimated reading time | Optional |
| `cta` | "Read more" or similar link | Yes |

**Variants:** `standard` (thumbnail + meta + title + excerpt, default) / `compact` (title + date + category, no thumbnail) / `featured` (larger card, full-width or 2-col, used for featured post at top of index)

**Responsive:** Grid controlled by layout-patterns (`card-index`, `grid-3col`). Full-width stack on mobile.

---

### 9.2 — Filter Bar

Horizontal row of category or topic filters for index and catalog pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `filters` | Array of filter items | Yes (min 2) |
| ↳ `label` | Filter label (e.g. "All", "Product", "Tutorials") | Yes |
| ↳ `value` | Filter identifier for JS matching | Yes |
| `default_active` | Which filter is active on load (default: "All") | Optional |

**Behavior:** Clicking a filter shows only matching items. Active filter is visually highlighted. "All" shows all items.

**Responsive:** Wraps to two lines or becomes a dropdown `<select>` on mobile.

→ For filter JS pattern: see `css-js-generator/SKILL.md`

---

### 9.3 — Search Bar

Keyword search input for documentation hubs, resource catalogs, and blog indexes.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `placeholder` | Input placeholder text (e.g. "Search documentation…") | Yes |
| `submit_label` | Button or icon label | Optional |

**Variants:** `inline` (embedded in a section, default) / `hero` (oversized, centered, full-width — for docs hub landing)

**Behavior:** On submit, filters visible content or navigates to a search results URL. Debounced live search if results are on the same page.

**Responsive:** Full-width at all breakpoints.

→ For search JS pattern: see `css-js-generator/SKILL.md`

---

### 9.4 — Pagination

Page navigation for content index pages.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `current_page` | Current page number | Yes |
| `total_pages` | Total number of pages | Yes |
| `prev_label` | "Previous" or "←" | Optional |
| `next_label` | "Next" or "→" | Optional |

**Variants:** `numbered` (page number buttons, default) / `load-more` (single button appends next set of items) / `infinite` (auto-loads on scroll)

**Responsive:** Numbered variant reduces to prev/next only on mobile.

---

## 10 — Form Components

### 10.1 — Form

Generic form component covering all submission contexts — contact, event registration, newsletter signup, and gated download.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `heading` | Form section title | Optional |
| `description` | Supporting text above fields | Optional |
| `fields` | Array of form fields (see Field Types below) | Yes (min 1) |
| `submit_label` | Submit button text | Yes |
| `privacy_note` | Privacy policy note below submit | Optional |
| `success_message` | Confirmation text shown on successful submission | Yes |

**Field Types:**

| Type | Use |
|---|---|
| `text` | Single-line text (name, company, job title) |
| `email` | Email address |
| `tel` | Phone number |
| `textarea` | Multi-line message or notes |
| `select` | Dropdown (country, team size, reason for inquiry) |
| `checkbox` | Single checkbox (terms agreement, newsletter opt-in) |
| `radio` | Radio group (single selection from options) |
| `hidden` | Hidden field (source tracking, page identifier) |

**Variants:**

| Variant | Use |
|---|---|
| `contact` | Name + email + message + submit. Contact page default. |
| `registration` | Name + email + company + role + submit. Event/webinar pages. |
| `newsletter` | Email only + submit. Inline in content sections. |
| `download-gate` | Name + email + company + submit. Unlocks download on success. |
| `multi-step` | Fields split across 2–3 steps with a progress indicator. For longer forms. |

**Responsive:** Single-column field stack at all breakpoints. Submit button full-width on mobile.

---

## 11 — Media Components

### 11.1 — Media Gallery

Grid or lightbox display of images, screenshots, or video thumbnails.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `section_heading` | H2 — section title | Optional |
| `items` | Array of media items | Yes (min 2) |
| ↳ `src` | Image or video thumbnail URL | Yes |
| ↳ `alt` | Alt text | Yes |
| ↳ `caption` | Optional caption below item | Optional |
| ↳ `type` | `image` or `video` | Yes |
| ↳ `video_url` | Video URL (for type: video, opens in lightbox) | Conditional |

**Variants:** `grid` (uniform grid, default) / `masonry` (variable height) / `lightbox` (click opens full-size overlay) / `carousel` (horizontally scrolling)

**Responsive:** Grid reduces to 2-col on tablet, 1-col on mobile. Lightbox is full-screen on all devices.

---

### 11.2 — Map Embed

Embedded map with location pin(s). Used on contact pages and event pages with physical locations.

**Content Slots:**

| Slot | Content | Required |
|---|---|---|
| `locations` | Array of map pins | Yes (min 1) |
| ↳ `label` | Location name (e.g. office name or city) | Yes |
| ↳ `address` | Full address | Yes |
| ↳ `coordinates` | Lat/lng for pin placement | Optional |
| `height` | Map container height in px | Optional (default `{PLACEHOLDER}`) |

**Variants:** `single` (one pin, default) / `multi` (multiple pins with a sidebar list of locations)

**Responsive:** Map goes full-width on mobile. Sidebar list stacks below map in multi variant.

---

## 12 — Composition Rules

### Nesting
- Feature Grid contains Feature Cards
- Testimonial Carousel contains Testimonial Cards
- Tabbed Feature Panel contains tab items (not standalone components)
- Accordion and FAQ Accordion contain accordion items (not standalone components)
- Media Gallery contains media items
- Agenda List contains agenda session items
- Timeline contains timeline entries
- No deeper nesting — components are max 2 levels (container → item)

### Exclusions
- A page should not use both Tabbed Feature Panel and Accordion for the same content type — choose one
- Sticky CTA Bar should not be combined with a `contextual` CTA strategy — they compete for attention
- Logo Bar and Metrics Bar should not be placed in adjacent sections — they are visually similar
- Countdown Timer only appears on event and webinar pages where a future date exists
- Pagination, Filter Bar, and Search Bar are index-page components — do not use on single-item or single-page content pages

### Section-to-Component Mapping

Connects section types from `brief-parser/SKILL.md` to available components. The layout type (from `layout-patterns/SKILL.md`) determines spatial arrangement independently.

#### Core Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Page Hero | Hero: Split | Hero: Full Bleed, Product Centered, Text Bold, Mini |
| Value Proposition | Feature Card (3-col grid) | CTA Section (`with-background` variant) |
| Feature Overview | Feature Grid | Feature Row (alternating) |
| Feature Deep-Dive | Tabbed Feature Panel | Accordion, Feature Row |
| How It Works | Step flow layout + Feature Card | Accordion (if 6+ steps) |
| Social Proof | Testimonial Carousel | Testimonial Card, static grid |
| Trust Signals | Logo Bar | Metrics Bar (if stats-focused) |
| Statistics / Metrics | Metrics Bar | Inline within another section |
| Use Cases / Scenarios | Feature Row | Feature Grid with use-case cards |
| Integration / Ecosystem | Integration Grid | Logo Bar (if logo-only) |
| Pricing / Plans | Pricing Table | Feature Grid (simplified) |
| FAQ | FAQ Accordion | — |
| Closing CTA | CTA Section | — |

#### Product & Feature Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Comparison Table | Pricing Table (`table` variant) | Feature Grid |
| Screenshots / Demo Gallery | Media Gallery | Feature Row (screenshot per feature) |
| Technical Specs | Accordion | FAQ Accordion |
| Related Features | Feature Grid (`compact` cards) | Article Card grid |

#### About & Company Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Mission / Vision | Pull Quote | CTA Section (`centered` variant) |
| Company Story | Timeline | Feature Row (alternating, milestone-style) |
| Team Members | Team Card (grid) | Author Bio |
| Company Values / Culture | Feature Card (grid) | Team Card |
| Press / Awards | Logo Bar | Metrics Bar |
| Investor / Partner Logos | Logo Bar | — |
| Office Locations | Map Embed | Feature Card (address cards) |
| Open Roles CTA | CTA Section | — |

#### Case Study Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Customer Overview | Testimonial Card | Logo Bar (customer logo only) |
| Challenge / Problem | Rich Text Block | Feature Row |
| Solution Description | Feature Row | Tabbed Feature Panel |
| Results / Outcomes | Metrics Bar | Feature Card (result cards) |
| Implementation Timeline | Timeline | Agenda List |
| Customer Quote | Pull Quote | Testimonial Card |

#### Blog & Editorial Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Article Header | Hero: Mini | — |
| Article Body | Rich Text Block | — |
| Pull Quote / Callout | Pull Quote | — |
| Author Bio | Author Bio | Team Card |
| Related Articles | Article Card (grid) | Feature Card |
| Article Tags / Categories | Filter Bar | — |

#### Event & Registration Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Event Details | Event Details Block | Metrics Bar (date/time/format as stats) |
| Countdown Timer | Countdown Timer | — |
| Speaker Profiles | Speaker Card (grid) | Team Card |
| Agenda / Schedule | Agenda List | Accordion |
| Registration Form | Form (`registration` variant) | Form (`contact` variant) |
| Past Event Highlights | Media Gallery | Feature Row |
| Sponsor / Partner Logos | Logo Bar | — |

#### Navigation & Index Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Content Listing | Article Card (grid) | Integration Grid, Feature Card |
| Filter / Category Bar | Filter Bar | — |
| Featured Item | Article Card (`featured` variant) | Feature Row |
| Pagination / Load More | Pagination | — |
| Search Bar | Search Bar | Filter Bar |

#### Contact & Support Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Contact Form | Form (`contact` variant) | — |
| Contact Details | Feature Card (details cards) | Metrics Bar |
| Map | Map Embed | — |
| Support Channels | Feature Card (channel cards) | Integration Grid |

#### Universal / Utility Sections

| Section Type | Primary Component | Alternative Components |
|---|---|---|
| Newsletter Signup | Form (`newsletter` variant) | CTA Section |
| Resource Download | Download Card | Article Card |
| Error Message | Hero: Mini | CTA Section |

→ For which component variants the variation axes select: see `variation-explorer/SKILL.md`
→ For layout types applied to each section: see `layout-patterns/SKILL.md` Section 5

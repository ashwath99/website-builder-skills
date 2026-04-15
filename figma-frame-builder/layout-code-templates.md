# Layout Code Templates — Figma Plugin API

→ This file is a reference for `figma-frame-builder/SKILL.md`
→ For layout type definitions: see `layout-patterns/SKILL.md` Section 3
→ For general Plugin API patterns: see `figma-frame-builder/figma-code-patterns.md`

Each template below builds one section layout type inside an existing section frame. All templates assume:

1. The Frame-Finder Preamble has already run (see `figma-code-patterns.md` Section 1)
2. The section frame already exists and its ID is stored
3. Fonts are already loaded via `figma.loadFontAsync()`
4. Token values (colors, spacing, fonts) are available as variables

**Placeholder key:**
- `{SECTION}` = the section frame node (from `figma.getNodeById`)
- `{H_FONT}` / `{B_FONT}` = heading/body font family strings
- `{R}`, `{G}`, `{B}` = color values in 0–1 range
- `{SPACE_*}` = spacing token values in pixels
- `{FONT_SIZE_*}` = font size values in pixels

---

## 1 — split-50 (Two Equal Columns)

**Use for:** Hero with product image, feature highlight with screenshot, alternating feature rows.

```javascript
// Content wrapper — horizontal auto-layout, two equal columns
const row = figma.createFrame();
row.name = "Split 50/50";
row.layoutMode = "HORIZONTAL";
row.primaryAxisSizingMode = "FIXED";
row.counterAxisSizingMode = "AUTO";
row.itemSpacing = {GRID_GUTTER};
row.fills = [];

{SECTION}.appendChild(row);
row.layoutSizingHorizontal = "FILL";

// Left column (text)
const leftCol = figma.createFrame();
leftCol.name = "Column: Text";
leftCol.layoutMode = "VERTICAL";
leftCol.primaryAxisSizingMode = "AUTO";
leftCol.counterAxisSizingMode = "FIXED";
leftCol.itemSpacing = {SPACE_MD};
leftCol.fills = [];
leftCol.minHeight = 200;

row.appendChild(leftCol);
leftCol.layoutSizingHorizontal = "FILL";  // Takes 50%

// Right column (visual)
const rightCol = figma.createFrame();
rightCol.name = "Column: Visual";
rightCol.layoutMode = "VERTICAL";
rightCol.primaryAxisSizingMode = "AUTO";
rightCol.counterAxisSizingMode = "FIXED";
rightCol.fills = [];
rightCol.minHeight = 200;

row.appendChild(rightCol);
rightCol.layoutSizingHorizontal = "FILL";  // Takes 50%

// Populate left column with text nodes (H1, subheadline, CTA)
// Populate right column with image placeholder
// Use figma-code-patterns.md Section 4 for text, Section 7 for CTA
```

**Reversed variant (visual left, text right):** Swap the order of `leftCol` and `rightCol` creation, or create both and use `row.insertChild(0, visualCol)`.

---

## 2 — split-60-40 (Asymmetric Split)

**Use for:** Feature deep-dive with larger image, hero with prominent visual.

```javascript
const row = figma.createFrame();
row.name = "Split 60/40";
row.layoutMode = "HORIZONTAL";
row.primaryAxisSizingMode = "FIXED";
row.counterAxisSizingMode = "AUTO";
row.itemSpacing = {GRID_GUTTER};
row.fills = [];

{SECTION}.appendChild(row);
row.layoutSizingHorizontal = "FILL";

// 60% column (wider)
const wideCol = figma.createFrame();
wideCol.name = "Column: Primary (60%)";
wideCol.resize(840, 200);  // ~60% of content width after padding
wideCol.layoutMode = "VERTICAL";
wideCol.primaryAxisSizingMode = "AUTO";
wideCol.itemSpacing = {SPACE_MD};
wideCol.fills = [];
wideCol.minHeight = 200;

row.appendChild(wideCol);
// Keep FIXED width — don't set to FILL (both would get 50%)

// 40% column (narrower)
const narrowCol = figma.createFrame();
narrowCol.name = "Column: Secondary (40%)";
narrowCol.layoutMode = "VERTICAL";
narrowCol.primaryAxisSizingMode = "AUTO";
narrowCol.itemSpacing = {SPACE_MD};
narrowCol.fills = [];
narrowCol.minHeight = 200;

row.appendChild(narrowCol);
narrowCol.layoutSizingHorizontal = "FILL";  // Takes remaining space
```

---

## 3 — grid-2col (Two-Column Grid)

**Use for:** Social proof cards, use case pairs, comparison content.

```javascript
const grid = figma.createFrame();
grid.name = "Grid: 2 Column";
grid.layoutMode = "HORIZONTAL";
grid.layoutWrap = "WRAP";
grid.primaryAxisSizingMode = "FIXED";
grid.counterAxisSizingMode = "AUTO";
grid.itemSpacing = {GRID_GUTTER};
grid.counterAxisSpacing = {GRID_GUTTER};
grid.fills = [];

{SECTION}.appendChild(grid);
grid.layoutSizingHorizontal = "FILL";

// Calculate card width: (container width - gutter) / 2
// For 1440px frame with 80px padding each side: (1280 - gutter) / 2
const cardWidth = Math.floor(({CONTENT_MAX_WIDTH} - {GRID_GUTTER}) / 2);

// Create cards and add to grid
// For each card:
//   const card = createFeatureCard(...);  // See figma-code-patterns.md Section 5
//   grid.appendChild(card);
//   card.layoutSizingHorizontal = "FIXED";
//   card.resize(cardWidth, card.height);
```

---

## 4 — grid-3col (Three-Column Grid)

**Use for:** Feature cards, benefit items, pricing plans, team members.

```javascript
const grid = figma.createFrame();
grid.name = "Grid: 3 Column";
grid.layoutMode = "HORIZONTAL";
grid.layoutWrap = "WRAP";
grid.primaryAxisSizingMode = "FIXED";
grid.counterAxisSizingMode = "AUTO";
grid.itemSpacing = {GRID_GUTTER};
grid.counterAxisSpacing = {GRID_GUTTER};
grid.fills = [];

{SECTION}.appendChild(grid);
grid.layoutSizingHorizontal = "FILL";

const cardWidth = Math.floor(({CONTENT_MAX_WIDTH} - {GRID_GUTTER} * 2) / 3);

// Create 3+ cards and add to grid
// Each card: grid.appendChild(card); card.resize(cardWidth, card.height);
// Cards beyond 3 wrap to next row automatically (layoutWrap = "WRAP")
```

---

## 5 — grid-4col (Four-Column Grid)

**Use for:** Small feature badges, logo items, stat items, integration icons.

```javascript
const grid = figma.createFrame();
grid.name = "Grid: 4 Column";
grid.layoutMode = "HORIZONTAL";
grid.layoutWrap = "WRAP";
grid.primaryAxisSizingMode = "FIXED";
grid.counterAxisSizingMode = "AUTO";
grid.itemSpacing = {GRID_GUTTER};
grid.counterAxisSpacing = {GRID_GUTTER};
grid.fills = [];

{SECTION}.appendChild(grid);
grid.layoutSizingHorizontal = "FILL";

const cardWidth = Math.floor(({CONTENT_MAX_WIDTH} - {GRID_GUTTER} * 3) / 4);

// Create 4+ items and add to grid
// Each smaller, more compact than 3col cards
```

---

## 6 — full-bleed-text (Centered Text Section)

**Use for:** Brand statements, simple CTAs, closing sections, page headlines.

```javascript
// Content container — centered, narrow width
const content = figma.createFrame();
content.name = "Full Bleed Text Content";
content.layoutMode = "VERTICAL";
content.primaryAxisSizingMode = "AUTO";
content.counterAxisSizingMode = "FIXED";
content.resize({CONTENT_MAX_WIDTH_NARROW}, 100);  // Narrow for readability
content.primaryAxisAlignItems = "CENTER";         // Center children vertically
content.counterAxisAlignItems = "CENTER";         // Center children horizontally
content.itemSpacing = {SPACE_MD};
content.fills = [];
content.minHeight = 150;

{SECTION}.appendChild(content);
// Center the content frame within the section
{SECTION}.counterAxisAlignItems = "CENTER";

// Add heading (centered)
const heading = figma.createText();
heading.fontName = { family: "{H_FONT}", style: "Bold" };
heading.characters = "{HEADING_TEXT}";
heading.fontSize = {FONT_SIZE_H1};
heading.textAlignHorizontal = "CENTER";
heading.textAutoResize = "HEIGHT";
heading.fills = [{ type: 'SOLID', color: { r: {R}, g: {G}, b: {B} } }];
content.appendChild(heading);
heading.layoutSizingHorizontal = "FILL";

// Add subtext (centered)
const subtext = figma.createText();
subtext.fontName = { family: "{B_FONT}", style: "Regular" };
subtext.characters = "{SUBTEXT}";
subtext.fontSize = {FONT_SIZE_BODY};
subtext.textAlignHorizontal = "CENTER";
subtext.textAutoResize = "HEIGHT";
subtext.fills = [{ type: 'SOLID', color: { r: {R2}, g: {G2}, b: {B2} } }];
content.appendChild(subtext);
subtext.layoutSizingHorizontal = "FILL";

// Add CTA button(s) — see figma-code-patterns.md Section 7
```

---

## 7 — tab-panel (Horizontal Tabs)

**Use for:** Feature categories, use case scenarios, plan comparisons.

```javascript
// Tab bar
const tabBar = figma.createFrame();
tabBar.name = "Tab Bar";
tabBar.layoutMode = "HORIZONTAL";
tabBar.primaryAxisSizingMode = "AUTO";
tabBar.counterAxisSizingMode = "AUTO";
tabBar.itemSpacing = 0;
tabBar.fills = [];

{SECTION}.appendChild(tabBar);
tabBar.layoutSizingHorizontal = "FILL";

// Create tab items
const tabNames = ["{TAB_1}", "{TAB_2}", "{TAB_3}"];
const tabIds = [];

for (let i = 0; i < tabNames.length; i++) {
  const tab = figma.createFrame();
  tab.name = `Tab: ${tabNames[i]}`;
  tab.layoutMode = "HORIZONTAL";
  tab.primaryAxisSizingMode = "AUTO";
  tab.counterAxisSizingMode = "AUTO";
  tab.paddingTop = {SPACE_SM};
  tab.paddingBottom = {SPACE_SM};
  tab.paddingLeft = {SPACE_MD};
  tab.paddingRight = {SPACE_MD};
  tab.primaryAxisAlignItems = "CENTER";
  tab.counterAxisAlignItems = "CENTER";

  // Active tab styling (first tab)
  if (i === 0) {
    tab.fills = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} }, opacity: 0.1 }];
  } else {
    tab.fills = [];
  }

  // Bottom border for active tab
  if (i === 0) {
    tab.strokes = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} } }];
    tab.strokeBottomWeight = 2;
    tab.strokeTopWeight = 0;
    tab.strokeLeftWeight = 0;
    tab.strokeRightWeight = 0;
  }

  const label = figma.createText();
  label.fontName = { family: "{B_FONT}", style: i === 0 ? "Bold" : "Regular" };
  label.characters = tabNames[i];
  label.fontSize = {FONT_SIZE_BODY};
  label.textAutoResize = "WIDTH_AND_HEIGHT";
  tab.appendChild(label);

  tabBar.appendChild(tab);
  tabIds.push(tab.id);
}

// Tab content panel (shows content for active tab)
const panel = figma.createFrame();
panel.name = "Tab Panel: Content";
panel.layoutMode = "VERTICAL";
panel.primaryAxisSizingMode = "AUTO";
panel.counterAxisSizingMode = "FIXED";
panel.itemSpacing = {SPACE_MD};
panel.paddingTop = {SPACE_LG};
panel.fills = [];
panel.minHeight = 200;

{SECTION}.appendChild(panel);
panel.layoutSizingHorizontal = "FILL";

// Populate panel with content for the first (active) tab
// Use split-50 or grid layout inside the panel as needed
```

---

## 8 — accordion-stack (Expandable Sections)

**Use for:** FAQ, detailed feature specs, glossary terms.

```javascript
const stack = figma.createFrame();
stack.name = "Accordion Stack";
stack.layoutMode = "VERTICAL";
stack.primaryAxisSizingMode = "AUTO";
stack.counterAxisSizingMode = "FIXED";
stack.itemSpacing = 0;  // Items touch (borders separate them)
stack.fills = [];

{SECTION}.appendChild(stack);
stack.layoutSizingHorizontal = "FILL";

const items = [
  { q: "{QUESTION_1}", a: "{ANSWER_1}" },
  { q: "{QUESTION_2}", a: "{ANSWER_2}" },
  { q: "{QUESTION_3}", a: "{ANSWER_3}" }
];

const itemIds = [];

for (let i = 0; i < items.length; i++) {
  const item = figma.createFrame();
  item.name = `Accordion: ${items[i].q.substring(0, 30)}`;
  item.layoutMode = "VERTICAL";
  item.primaryAxisSizingMode = "AUTO";
  item.counterAxisSizingMode = "FIXED";
  item.paddingTop = {SPACE_MD};
  item.paddingBottom = {SPACE_MD};
  item.paddingLeft = {SPACE_MD};
  item.paddingRight = {SPACE_MD};
  item.itemSpacing = {SPACE_SM};

  // Bottom border
  item.strokes = [{ type: 'SOLID', color: { r: {BORDER_R}, g: {BORDER_G}, b: {BORDER_B} } }];
  item.strokeBottomWeight = 1;
  item.strokeTopWeight = 0;
  item.strokeLeftWeight = 0;
  item.strokeRightWeight = 0;
  item.fills = [];

  // Question row (with expand icon placeholder)
  const qRow = figma.createFrame();
  qRow.name = "Question Row";
  qRow.layoutMode = "HORIZONTAL";
  qRow.primaryAxisSizingMode = "FIXED";
  qRow.counterAxisSizingMode = "AUTO";
  qRow.primaryAxisAlignItems = "SPACE_BETWEEN";
  qRow.counterAxisAlignItems = "CENTER";
  qRow.fills = [];
  item.appendChild(qRow);
  qRow.layoutSizingHorizontal = "FILL";

  const qText = figma.createText();
  qText.fontName = { family: "{B_FONT}", style: "Bold" };
  qText.characters = items[i].q;
  qText.fontSize = {FONT_SIZE_BODY};
  qText.textAutoResize = "HEIGHT";
  qRow.appendChild(qText);
  qText.layoutSizingHorizontal = "FILL";

  // Expand icon placeholder
  const icon = figma.createFrame();
  icon.name = "Icon: Expand";
  icon.resize(24, 24);
  icon.cornerRadius = 4;
  icon.fills = [{ type: 'SOLID', color: { r: 0.85, g: 0.85, b: 0.85 } }];
  qRow.appendChild(icon);

  // Answer (visible for first item, represents expanded state)
  if (i === 0) {
    const aText = figma.createText();
    aText.fontName = { family: "{B_FONT}", style: "Regular" };
    aText.characters = items[i].a;
    aText.fontSize = {FONT_SIZE_BODY};
    aText.textAutoResize = "HEIGHT";
    aText.fills = [{ type: 'SOLID', color: { r: {TEXT2_R}, g: {TEXT2_G}, b: {TEXT2_B} } }];
    item.appendChild(aText);
    aText.layoutSizingHorizontal = "FILL";
  }

  stack.appendChild(item);
  item.layoutSizingHorizontal = "FILL";
  itemIds.push(item.id);
}
```

---

## 9 — logo-bar (Single Row of Logos)

**Use for:** Trust signals, customer logos, integration partners.

```javascript
const bar = figma.createFrame();
bar.name = "Logo Bar";
bar.layoutMode = "HORIZONTAL";
bar.primaryAxisSizingMode = "FIXED";
bar.counterAxisSizingMode = "AUTO";
bar.primaryAxisAlignItems = "SPACE_BETWEEN";  // Even spacing
bar.counterAxisAlignItems = "CENTER";
bar.itemSpacing = {SPACE_LG};
bar.fills = [];
bar.minHeight = 80;

{SECTION}.appendChild(bar);
bar.layoutSizingHorizontal = "FILL";

// Create logo placeholders
const logoCount = {LOGO_COUNT};  // Typically 4-6
for (let i = 0; i < logoCount; i++) {
  const logo = figma.createFrame();
  logo.name = `Logo: {COMPANY_NAME_${i}}`;
  logo.resize(120, 40);  // Standard logo placeholder size
  logo.cornerRadius = 4;
  logo.fills = [{ type: 'SOLID', color: { r: 0.92, g: 0.92, b: 0.92 } }];

  // Add company name as label
  const label = figma.createText();
  label.fontName = { family: "{B_FONT}", style: "Regular" };
  label.characters = "{COMPANY_NAME}";
  label.fontSize = 10;
  label.textAlignHorizontal = "CENTER";
  label.textAutoResize = "WIDTH_AND_HEIGHT";
  label.fills = [{ type: 'SOLID', color: { r: 0.6, g: 0.6, b: 0.6 } }];

  logo.layoutMode = "VERTICAL";
  logo.primaryAxisAlignItems = "CENTER";
  logo.counterAxisAlignItems = "CENTER";
  logo.appendChild(label);

  bar.appendChild(logo);
}
```

---

## 10 — stat-band (Metrics/Stats Row)

**Use for:** Social proof numbers, key results, company stats.

```javascript
const band = figma.createFrame();
band.name = "Stats Band";
band.layoutMode = "HORIZONTAL";
band.primaryAxisSizingMode = "FIXED";
band.counterAxisSizingMode = "AUTO";
band.primaryAxisAlignItems = "SPACE_BETWEEN";
band.counterAxisAlignItems = "CENTER";
band.itemSpacing = {SPACE_LG};
band.fills = [];
band.minHeight = 100;

{SECTION}.appendChild(band);
band.layoutSizingHorizontal = "FILL";

const stats = [
  { number: "{STAT_1_NUM}", label: "{STAT_1_LABEL}" },
  { number: "{STAT_2_NUM}", label: "{STAT_2_LABEL}" },
  { number: "{STAT_3_NUM}", label: "{STAT_3_LABEL}" },
  { number: "{STAT_4_NUM}", label: "{STAT_4_LABEL}" }
];

for (const stat of stats) {
  const item = figma.createFrame();
  item.name = `Stat: ${stat.label}`;
  item.layoutMode = "VERTICAL";
  item.primaryAxisSizingMode = "AUTO";
  item.counterAxisSizingMode = "FIXED";
  item.primaryAxisAlignItems = "CENTER";
  item.counterAxisAlignItems = "CENTER";
  item.itemSpacing = {SPACE_XS};
  item.fills = [];

  // Big number
  const numText = figma.createText();
  numText.fontName = { family: "{H_FONT}", style: "Bold" };
  numText.characters = stat.number;
  numText.fontSize = {FONT_SIZE_H1};
  numText.textAlignHorizontal = "CENTER";
  numText.textAutoResize = "WIDTH_AND_HEIGHT";
  numText.fills = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} } }];
  item.appendChild(numText);

  // Label
  const labelText = figma.createText();
  labelText.fontName = { family: "{B_FONT}", style: "Regular" };
  labelText.characters = stat.label;
  labelText.fontSize = {FONT_SIZE_BODY_SM};
  labelText.textAlignHorizontal = "CENTER";
  labelText.textAutoResize = "WIDTH_AND_HEIGHT";
  labelText.fills = [{ type: 'SOLID', color: { r: {TEXT2_R}, g: {TEXT2_G}, b: {TEXT2_B} } }];
  item.appendChild(labelText);

  band.appendChild(item);
  item.layoutSizingHorizontal = "FILL";
}
```

---

## 11 — bento (Asymmetric Card Grid)

**Use for:** Product overview, editorial content, non-linear feature display.

```javascript
const bento = figma.createFrame();
bento.name = "Bento Grid";
bento.layoutMode = "HORIZONTAL";
bento.layoutWrap = "WRAP";
bento.primaryAxisSizingMode = "FIXED";
bento.counterAxisSizingMode = "AUTO";
bento.itemSpacing = {GRID_GUTTER};
bento.counterAxisSpacing = {GRID_GUTTER};
bento.fills = [];

{SECTION}.appendChild(bento);
bento.layoutSizingHorizontal = "FILL";

const colUnit = Math.floor(({CONTENT_MAX_WIDTH} - {GRID_GUTTER} * 2) / 3);

// Large card (2x1 — spans 2 columns)
const largeCard = figma.createFrame();
largeCard.name = "Bento Card: Large (2x1)";
largeCard.resize(colUnit * 2 + {GRID_GUTTER}, 280);  // 2 columns + 1 gutter
largeCard.layoutMode = "VERTICAL";
largeCard.primaryAxisSizingMode = "FIXED";  // Fixed height for bento
largeCard.cornerRadius = {RADIUS_MD};
largeCard.paddingTop = {CARD_PADDING};
largeCard.paddingBottom = {CARD_PADDING};
largeCard.paddingLeft = {CARD_PADDING};
largeCard.paddingRight = {CARD_PADDING};
largeCard.itemSpacing = {SPACE_SM};
largeCard.fills = [{ type: 'SOLID', color: { r: {SURFACE_R}, g: {SURFACE_G}, b: {SURFACE_B} } }];
bento.appendChild(largeCard);

// Regular card (1x1)
const regCard = figma.createFrame();
regCard.name = "Bento Card: Regular (1x1)";
regCard.resize(colUnit, 280);
regCard.layoutMode = "VERTICAL";
regCard.primaryAxisSizingMode = "FIXED";
regCard.cornerRadius = {RADIUS_MD};
regCard.paddingTop = {CARD_PADDING};
regCard.paddingBottom = {CARD_PADDING};
regCard.paddingLeft = {CARD_PADDING};
regCard.paddingRight = {CARD_PADDING};
regCard.itemSpacing = {SPACE_SM};
regCard.fills = [{ type: 'SOLID', color: { r: {SURFACE_R}, g: {SURFACE_G}, b: {SURFACE_B} } }];
bento.appendChild(regCard);

// Add more cards in desired pattern:
// Row 1: [2x1] [1x1]
// Row 2: [1x1] [1x1] [1x1]
// Row 3: [1x1] [2x1]
// Populate each card with text/images using figma-code-patterns.md
```

---

## 12 — step-flow (Horizontal Steps)

**Use for:** How it works, onboarding process, getting started guides.

```javascript
const flow = figma.createFrame();
flow.name = "Step Flow";
flow.layoutMode = "HORIZONTAL";
flow.primaryAxisSizingMode = "FIXED";
flow.counterAxisSizingMode = "AUTO";
flow.primaryAxisAlignItems = "SPACE_BETWEEN";
flow.itemSpacing = {SPACE_LG};
flow.fills = [];
flow.minHeight = 150;

{SECTION}.appendChild(flow);
flow.layoutSizingHorizontal = "FILL";

const steps = [
  { num: "1", title: "{STEP_1_TITLE}", desc: "{STEP_1_DESC}" },
  { num: "2", title: "{STEP_2_TITLE}", desc: "{STEP_2_DESC}" },
  { num: "3", title: "{STEP_3_TITLE}", desc: "{STEP_3_DESC}" }
];

for (const step of steps) {
  const item = figma.createFrame();
  item.name = `Step: ${step.num}. ${step.title}`;
  item.layoutMode = "VERTICAL";
  item.primaryAxisSizingMode = "AUTO";
  item.counterAxisSizingMode = "FIXED";
  item.primaryAxisAlignItems = "CENTER";
  item.counterAxisAlignItems = "CENTER";
  item.itemSpacing = {SPACE_SM};
  item.fills = [];

  // Step number circle
  const circle = figma.createEllipse();
  circle.name = `Step Number: ${step.num}`;
  circle.resize(48, 48);
  circle.fills = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} } }];
  item.appendChild(circle);

  // Step number text (overlaid — needs absolute positioning or separate approach)
  // Alternative: use a frame with centered text instead of ellipse
  const numFrame = figma.createFrame();
  numFrame.resize(48, 48);
  numFrame.layoutMode = "VERTICAL";
  numFrame.primaryAxisAlignItems = "CENTER";
  numFrame.counterAxisAlignItems = "CENTER";
  numFrame.cornerRadius = 24;  // Makes it circular
  numFrame.fills = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} } }];

  const numText = figma.createText();
  numText.fontName = { family: "{H_FONT}", style: "Bold" };
  numText.characters = step.num;
  numText.fontSize = 20;
  numText.textAutoResize = "WIDTH_AND_HEIGHT";
  numText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
  numFrame.appendChild(numText);

  // Replace ellipse with numFrame (ellipse was for illustration)
  item.insertChild(0, numFrame);
  circle.remove();

  // Title
  const title = figma.createText();
  title.fontName = { family: "{H_FONT}", style: "Bold" };
  title.characters = step.title;
  title.fontSize = {FONT_SIZE_H3};
  title.textAlignHorizontal = "CENTER";
  title.textAutoResize = "HEIGHT";
  item.appendChild(title);
  title.layoutSizingHorizontal = "FILL";

  // Description
  const desc = figma.createText();
  desc.fontName = { family: "{B_FONT}", style: "Regular" };
  desc.characters = step.desc;
  desc.fontSize = {FONT_SIZE_BODY_SM};
  desc.textAlignHorizontal = "CENTER";
  desc.textAutoResize = "HEIGHT";
  desc.fills = [{ type: 'SOLID', color: { r: {TEXT2_R}, g: {TEXT2_G}, b: {TEXT2_B} } }];
  item.appendChild(desc);
  desc.layoutSizingHorizontal = "FILL";

  flow.appendChild(item);
  item.layoutSizingHorizontal = "FILL";
}
```

---

## Layout Selection Quick Reference

| Layout Type | Template | Min Sections Per Batch |
|---|---|---|
| `split-50` | Section 1 | 1 (lightweight) |
| `split-60-40` | Section 2 | 1 (lightweight) |
| `grid-2col` | Section 3 | 1 (depends on card count) |
| `grid-3col` | Section 4 | 1 (depends on card count) |
| `grid-4col` | Section 5 | 1 (compact items) |
| `full-bleed-text` | Section 6 | 2–3 (very lightweight) |
| `tab-panel` | Section 7 | 1 (complex) |
| `accordion-stack` | Section 8 | 1 (many text nodes) |
| `logo-bar` | Section 9 | 2 (lightweight) |
| `stat-band` | Section 10 | 2 (lightweight) |
| `bento` | Section 11 | 1 (complex sizing) |
| `step-flow` | Section 12 | 1–2 (moderate) |

**Batching guidance:** Use the "Min Sections Per Batch" column with `figma-frame-builder/SKILL.md` Section 3.4 to plan how many sections fit in each `use_figma` call.

# Figma Plugin API — Code Patterns Reference

→ This file is a reference for `figma-frame-builder/SKILL.md`
→ Official source: `https://github.com/figma/mcp-server-guide/blob/main/skills/figma-use/SKILL.md`

These are tested, production-ready code snippets for common `use_figma` operations. Copy and adapt — do not write Plugin API code from scratch.

---

## 1 — Frame-Finder Preamble

**Use at the TOP of every `use_figma` call after the first one.**

```javascript
// === Frame-Finder Preamble ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
if (!targetPage) return { error: "Page '{PAGE_NAME}' not found" };
await figma.setCurrentPageAsync(targetPage);

const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame '{MAIN_FRAME_ID}' not found" };
// === End Preamble ===
```

---

## 2 — Create Top-Level Landing Page Frame

**Batch 1 — always the first call.** Creates the main frame and returns its ID.

```javascript
// Navigate to target page
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
if (!targetPage) return { error: "Page not found" };
await figma.setCurrentPageAsync(targetPage);

// Position away from existing content
const existingNodes = targetPage.children;
const rightEdge = existingNodes.length > 0
  ? Math.max(...existingNodes.map(n => n.x + n.width)) + 100
  : 100;

// Create main frame
const mainFrame = figma.createFrame();
mainFrame.name = "{Product Name} — Landing Page";
mainFrame.resize(1440, 900); // Initial height — will grow with content
mainFrame.x = rightEdge;
mainFrame.y = 0;

// Set up vertical auto-layout
mainFrame.layoutMode = "VERTICAL";
mainFrame.primaryAxisSizingMode = "AUTO"; // Height grows with children
mainFrame.counterAxisSizingMode = "FIXED"; // Width stays 1440
mainFrame.paddingTop = 0;
mainFrame.paddingBottom = 0;
mainFrame.paddingLeft = 0;
mainFrame.paddingRight = 0;
mainFrame.itemSpacing = 0;

// Page background
mainFrame.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];

return {
  createdNodeIds: [mainFrame.id],
  mainFrameId: mainFrame.id,
  summary: "Created main frame at x=" + rightEdge
};
```

---

## 3 — Create a Section Frame

**Use inside any batch after Batch 1.** Starts with the preamble, adds a section.

```javascript
// === Frame-Finder Preamble ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
await figma.setCurrentPageAsync(targetPage);
const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame not found" };
// === End Preamble ===

// Create section frame
const section = figma.createFrame();
section.name = "Section: {SECTION_TYPE}";
section.resize(1440, 100); // Temporary height

// IMPORTANT: Append to parent BEFORE setting sizing modes
mainFrame.appendChild(section);

// Now set sizing — AFTER appendChild
section.layoutSizingHorizontal = "FILL";  // Fill parent width

// Set up vertical auto-layout for section content
section.layoutMode = "VERTICAL";
section.primaryAxisSizingMode = "AUTO";   // Hug contents
section.counterAxisSizingMode = "FILL";
section.minHeight = {MIN_HEIGHT};         // Collapse prevention (see Section 4.2)
section.paddingTop = {SECTION_PADDING_Y};
section.paddingBottom = {SECTION_PADDING_Y};
section.paddingLeft = {SIDE_PADDING};     // Centers content at max-width
section.paddingRight = {SIDE_PADDING};
section.itemSpacing = {SPACE_LG};

// Section background (tinted or white)
section.fills = [{ type: 'SOLID', color: { r: {R}, g: {G}, b: {B} } }];

return {
  createdNodeIds: [section.id],
  summary: "Created section: {SECTION_TYPE}"
};
```

---

## 4 — Create a Text Node

**Font MUST be loaded before any text operation.**

```javascript
// Load font first — MANDATORY
await figma.loadFontAsync({ family: "{FONT_FAMILY}", style: "{FONT_STYLE}" });

const textNode = figma.createText();
textNode.fontName = { family: "{FONT_FAMILY}", style: "{FONT_STYLE}" };
textNode.characters = "{TEXT_CONTENT}";
textNode.fontSize = {FONT_SIZE};
textNode.lineHeight = { unit: "PIXELS", value: {LINE_HEIGHT} };
textNode.letterSpacing = { unit: "PIXELS", value: {LETTER_SPACING} };
textNode.fills = [{ type: 'SOLID', color: { r: {R}, g: {G}, b: {B} } }];

// Width fixed, height grows with content — prevents collapsed text
textNode.textAutoResize = "HEIGHT";
textNode.resize({WIDTH}, textNode.height);

// Append to parent, THEN set sizing
{PARENT_NODE}.appendChild(textNode);
textNode.layoutSizingHorizontal = "FILL";
```

---

## 5 — Create a Feature Card (Auto-Layout)

```javascript
// Load fonts first
await figma.loadFontAsync({ family: "{HEADING_FONT}", style: "Bold" });
await figma.loadFontAsync({ family: "{BODY_FONT}", style: "Regular" });

const card = figma.createFrame();
card.name = "Feature Card: {FEATURE_NAME}";
card.resize(400, 150); // Temporary — will hug content

// Card styling
card.cornerRadius = {RADIUS_MD};
card.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
card.effects = [{
  type: 'DROP_SHADOW',
  color: { r: 0, g: 0, b: 0, a: 0.08 },
  offset: { x: 0, y: 4 },
  radius: 24,
  visible: true
}];

// Auto-layout
card.layoutMode = "VERTICAL";
card.primaryAxisSizingMode = "AUTO";  // Hug contents vertically
card.counterAxisSizingMode = "FIXED";
card.minHeight = 150;                 // Collapse prevention
card.paddingTop = {CARD_PADDING};
card.paddingBottom = {CARD_PADDING};
card.paddingLeft = {CARD_PADDING};
card.paddingRight = {CARD_PADDING};
card.itemSpacing = {SPACE_SM};

// Icon placeholder
const icon = figma.createFrame();
icon.name = "Image: Feature Icon";
icon.resize(48, 48);
icon.cornerRadius = 8;
icon.fills = [{ type: 'SOLID', color: { r: 0.9, g: 0.9, b: 0.95 } }];
card.appendChild(icon);

// Heading
const heading = figma.createText();
heading.fontName = { family: "{HEADING_FONT}", style: "Bold" };
heading.characters = "{FEATURE_NAME}";
heading.fontSize = {FONT_SIZE_H3};
heading.lineHeight = { unit: "PIXELS", value: {LINE_HEIGHT_HEADING} };
heading.fills = [{ type: 'SOLID', color: { r: {TEXT_R}, g: {TEXT_G}, b: {TEXT_B} } }];
heading.textAutoResize = "HEIGHT";
card.appendChild(heading);
heading.layoutSizingHorizontal = "FILL";

// Description
const desc = figma.createText();
desc.fontName = { family: "{BODY_FONT}", style: "Regular" };
desc.characters = "{FEATURE_DESCRIPTION}";
desc.fontSize = {FONT_SIZE_BODY};
desc.lineHeight = { unit: "PIXELS", value: {LINE_HEIGHT_BODY} };
desc.fills = [{ type: 'SOLID', color: { r: {TEXT2_R}, g: {TEXT2_G}, b: {TEXT2_B} } }];
desc.textAutoResize = "HEIGHT";
card.appendChild(desc);
desc.layoutSizingHorizontal = "FILL";
```

---

## 6 — Create a Grid Container (3-Column)

```javascript
const grid = figma.createFrame();
grid.name = "Feature Grid: {SECTION_NAME}";
grid.layoutMode = "HORIZONTAL";
grid.layoutWrap = "WRAP";
grid.primaryAxisSizingMode = "FIXED";
grid.counterAxisSizingMode = "AUTO";
grid.itemSpacing = {GRID_GUTTER};
grid.counterAxisSpacing = {GRID_GUTTER};

// Append to section BEFORE setting fill
{SECTION_NODE}.appendChild(grid);
grid.layoutSizingHorizontal = "FILL";

// Add cards to grid (each card created separately)
// After adding all cards:
// grid.appendChild(card1);
// grid.appendChild(card2);
// card1.layoutSizingHorizontal = "FIXED";
// card1.resize(cardWidth, card1.height);  // cardWidth = (1440 - padding*2 - gutter*2) / 3
```

---

## 7 — Create a CTA Button

```javascript
await figma.loadFontAsync({ family: "{BODY_FONT}", style: "Bold" });

const button = figma.createFrame();
button.name = "Button: Primary CTA";
button.layoutMode = "HORIZONTAL";
button.primaryAxisSizingMode = "AUTO";  // Hug text width
button.counterAxisSizingMode = "AUTO";  // Hug text height
button.paddingTop = {BTN_PADDING_Y};
button.paddingBottom = {BTN_PADDING_Y};
button.paddingLeft = {BTN_PADDING_X};
button.paddingRight = {BTN_PADDING_X};
button.primaryAxisAlignItems = "CENTER";
button.counterAxisAlignItems = "CENTER";
button.cornerRadius = {RADIUS_MD};

// CTA color (NOT brand primary — see design-tokens Section 2.2)
button.fills = [{ type: 'SOLID', color: { r: {CTA_R}, g: {CTA_G}, b: {CTA_B} } }];

const label = figma.createText();
label.fontName = { family: "{BODY_FONT}", style: "Bold" };
label.characters = "{CTA_TEXT}";
label.fontSize = {FONT_SIZE_BODY};
label.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]; // White text on CTA bg
label.textAutoResize = "WIDTH_AND_HEIGHT";
button.appendChild(label);
```

---

## 8 — Font Availability Check

**Run this BEFORE building any frames to verify fonts are available.**

```javascript
const fonts = await figma.listAvailableFontsAsync();

const requiredFonts = [
  { family: "{HEADING_FONT}", style: "Bold" },
  { family: "{HEADING_FONT}", style: "SemiBold" },
  { family: "{BODY_FONT}", style: "Regular" },
  { family: "{BODY_FONT}", style: "Bold" }
];

const results = [];
for (const req of requiredFonts) {
  const found = fonts.some(f =>
    f.fontName.family === req.family && f.fontName.style === req.style
  );
  results.push({
    font: `${req.family} ${req.style}`,
    available: found
  });

  if (!found) {
    // Check if family exists with different styles
    const familyFonts = fonts.filter(f => f.fontName.family === req.family);
    if (familyFonts.length > 0) {
      results[results.length - 1].availableStyles =
        familyFonts.map(f => f.fontName.style);
    }
  }
}

return {
  results,
  allAvailable: results.every(r => r.available),
  summary: results.map(r =>
    `${r.font}: ${r.available ? 'OK' : 'MISSING' +
      (r.availableStyles ? ' (available: ' + r.availableStyles.join(', ') + ')' : '')}`
  ).join('\n')
};
```

---

## 9 — Component Search and Instantiation

```javascript
// Step 1: Search for existing component in connected libraries
// (Use search_design_system MCP tool — not use_figma)

// Step 2: If component key is found, instantiate it:
const component = await figma.importComponentByKeyAsync("{COMPONENT_KEY}");
const instance = component.createInstance();
instance.name = "Button: Primary CTA";

// Step 3: Set variant properties (if component has variants)
// First inspect what properties exist:
// instance.componentProperties → lists available properties

// Step 4: Override text content in the instance
// Find the text node inside the instance:
const textNode = instance.findOne(n => n.type === "TEXT" && n.name === "Label");
if (textNode) {
  await figma.loadFontAsync(textNode.fontName);
  textNode.characters = "{NEW_TEXT}";
}

// Step 5: Append and size
{PARENT_NODE}.appendChild(instance);
instance.layoutSizingHorizontal = "FILL"; // Or "FIXED" depending on layout
```

**Important:** Component instantiation is complex with variant properties and nested overrides. If the component doesn't respond to property changes as expected, fall back to building from scratch using the patterns in Sections 4–7 above. Don't spend more than 2 attempts on component instantiation per component type.

---

## 10 — Collapsed Frame Diagnosis

**Run this when a screenshot shows collapsed sections.**

```javascript
// === Frame-Finder Preamble ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
await figma.setCurrentPageAsync(targetPage);
const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
// === End Preamble ===

const diagnosis = [];

for (const child of mainFrame.children) {
  if (child.type !== "FRAME") continue;

  const info = {
    name: child.name,
    id: child.id,
    height: child.height,
    layoutMode: child.layoutMode,
    primaryAxisSizingMode: child.primaryAxisSizingMode,
    childCount: child.children ? child.children.length : 0,
    collapsed: child.height < 50
  };

  // Check children for common collapse causes
  if (child.children) {
    info.childDetails = child.children.map(c => ({
      name: c.name,
      type: c.type,
      height: c.height,
      textAutoResize: c.type === "TEXT" ? c.textAutoResize : undefined,
      layoutSizing: c.layoutSizingVertical || undefined
    }));
  }

  diagnosis.push(info);
}

return {
  sections: diagnosis,
  collapsedSections: diagnosis.filter(d => d.collapsed).map(d => d.name),
  summary: diagnosis.map(d =>
    `${d.name}: h=${d.height}px, children=${d.childCount}${d.collapsed ? ' ⚠ COLLAPSED' : ''}`
  ).join('\n')
};
```

---

## Quick Reference — Correct Operation Order

```
1. Create node          → figma.createFrame() / figma.createText()
2. resize()             → node.resize(width, height)   [BEFORE sizing modes]
3. Set layout mode      → node.layoutMode = "VERTICAL"
4. Set axis sizing      → node.primaryAxisSizingMode = "AUTO"
5. Set min-height       → node.minHeight = 200
6. Load font (text)     → await figma.loadFontAsync(...)  [BEFORE any text ops]
7. Set text properties  → node.characters, fontSize, etc.
8. textAutoResize       → node.textAutoResize = "HEIGHT"
9. appendChild          → parent.appendChild(node)        [BEFORE FILL sizing]
10. Set FILL sizing     → node.layoutSizingHorizontal = "FILL"  [AFTER appendChild]
11. Return IDs          → return { createdNodeIds: [...] }
```

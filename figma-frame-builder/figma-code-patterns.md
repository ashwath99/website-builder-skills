# Figma Plugin API — Code Patterns Reference

→ This file is a reference for `figma-frame-builder/SKILL.md`
→ Official source: `https://github.com/figma/mcp-server-guide/blob/main/skills/figma-use/SKILL.md`

These are tested, production-ready code snippets for common `use_figma` operations. Copy and adapt — do not write Plugin API code from scratch.

---

## 1 — Page Discovery + Frame-Finder Preamble

### 1a — Page Discovery (Batch 0 — run once before any build)

When given a Figma URL with `node-id`, the agent doesn't know the page name. **Always discover it first:**

```javascript
// === Page Discovery — run ONCE at session start ===
// Extract the node-id from the URL (e.g., node-id=174-2 → "174:2")
const targetNode = figma.getNodeById("{NODE_ID_FROM_URL}");
if (!targetNode) return { error: "Node {NODE_ID_FROM_URL} not found" };

// Walk up to find the page
let targetPage = targetNode;
while (targetPage && targetPage.type !== "PAGE") targetPage = targetPage.parent;
if (!targetPage) return { error: "Could not find parent page" };

await figma.setCurrentPageAsync(targetPage);

return {
  pageId: targetPage.id,
  pageName: targetPage.name,
  existingChildren: targetPage.children.map(c => ({ id: c.id, name: c.name })),
  summary: "Target page: '" + targetPage.name + "' (id: " + targetPage.id + ")"
};
// === End Page Discovery ===
```

**Store the `pageName` in the Build Card** — all subsequent calls use it.

### 1b — Frame-Finder Preamble (every call after Batch 1)

**Use at the TOP of every `use_figma` call after the main frame is created.**

```javascript
// === Frame-Finder Preamble ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
if (!targetPage) return { error: "Page '{PAGE_NAME}' not found" };
await figma.setCurrentPageAsync(targetPage);

const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame '{MAIN_FRAME_ID}' not found" };
// === End Preamble ===
```

**Rule:** Use the page name discovered in 1a. Never hardcode a page name from the URL or project name — they often don't match.

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
section.primaryAxisSizingMode = "AUTO";   // ⚠️ MUST set explicitly — default is FIXED (100px) which collapses the section
section.counterAxisSizingMode = "FIXED";  // Width controlled by resize() above
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
  blendMode: 'NORMAL',          // REQUIRED — omitting this causes script failure
  color: { r: 0, g: 0, b: 0, a: 0.08 },
  offset: { x: 0, y: 4 },
  radius: 24,
  spread: 0,
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

**Run this as a SINGLE `use_figma` call BEFORE building any frames.** This checks all required fonts and their fallback candidates in one round-trip — do not check fonts one-at-a-time.

```javascript
const fonts = await figma.listAvailableFontsAsync();

// Primary fonts (from token extraction)
const primaryFonts = [
  { family: "{HEADING_FONT}", style: "Bold" },
  { family: "{HEADING_FONT}", style: "SemiBold" },
  { family: "{BODY_FONT}", style: "Regular" },
  { family: "{BODY_FONT}", style: "Bold" }
];

// Fallback candidates (check all at once)
const fallbackFamilies = ["Inter", "Lato", "Source Sans Pro", "Roboto", "Open Sans"];

const results = [];
for (const req of primaryFonts) {
  const found = fonts.some(f =>
    f.fontName.family === req.family && f.fontName.style === req.style
  );
  const entry = {
    font: `${req.family} ${req.style}`,
    available: found
  };

  if (!found) {
    // Check if family exists with different styles
    const familyFonts = fonts.filter(f => f.fontName.family === req.family);
    if (familyFonts.length > 0) {
      entry.availableStyles = familyFonts.map(f => f.fontName.style);
    }
    // Find first available fallback with matching style
    for (const fb of fallbackFamilies) {
      if (fonts.some(f => f.fontName.family === fb && f.fontName.style === req.style)) {
        entry.suggestedFallback = `${fb} ${req.style}`;
        break;
      }
      // Try without exact style match
      const fbStyles = fonts.filter(f => f.fontName.family === fb).map(f => f.fontName.style);
      if (fbStyles.length > 0) {
        entry.suggestedFallback = `${fb} ${fbStyles[0]}`;
        entry.fallbackNote = `Exact style "${req.style}" not available; using "${fbStyles[0]}"`;
        break;
      }
    }
  }
  results.push(entry);
}

// Also preload available fallback family data for the report
const fallbackAvailability = {};
for (const fb of fallbackFamilies) {
  const styles = fonts.filter(f => f.fontName.family === fb).map(f => f.fontName.style);
  if (styles.length > 0) fallbackAvailability[fb] = styles;
}

return {
  results,
  allAvailable: results.every(r => r.available),
  fallbackFamilies: fallbackAvailability,
  summary: results.map(r =>
    `${r.font}: ${r.available ? 'OK' : 'MISSING' +
      (r.availableStyles ? ' (family exists with: ' + r.availableStyles.join(', ') + ')' : '') +
      (r.suggestedFallback ? ' → fallback: ' + r.suggestedFallback : '')}`
  ).join('\n')
};
```

### Common Font Gotchas

These are known issues encountered during production testing. Check this table when font loading fails unexpectedly:

| Font Family | Gotcha | Fix |
|---|---|---|
| **Lato** | Has no "Semi Bold" or "SemiBold" style | Use "Bold" or "Regular" only. For medium weight, use "Regular" with heavier appearance. |
| **Inter** | Uses "Semi Bold" (with space), not "SemiBold" | Match the exact style string from `listAvailableFontsAsync()` |
| **Roboto** | "Thin" and "Light" styles exist but "Book" does not | Use "Light" or "Regular" for lighter weights |
| **ZohoPuvi** | Proprietary — not in Figma cloud fonts | Use Lato or Inter as fallback (see `token-sources.md` Section 9) |
| **Segoe UI** | Available on Windows, not on Mac/Linux Figma cloud | Use Inter or Roboto as cross-platform fallback |
| **SF Pro** | Apple system font — limited availability in Figma | Use Inter as fallback |
| Any font | Style name mismatch ("Bold" vs "bold" vs "700") | Style strings are case-sensitive — always verify with `listAvailableFontsAsync()` |

**Rule:** Never assume a font style exists. Always check the output of `listAvailableFontsAsync()` for the exact `{ family, style }` pair before calling `loadFontAsync()`.

---

## 9 — Component Search and Instantiation

### 9.1 — Inspect Available Components (Run First)

Before trying to instantiate, discover what's in the connected libraries:

```javascript
// List all components on the current page (local)
const results = [];
for (const page of figma.root.children) {
  await figma.setCurrentPageAsync(page);
  page.findAll(n => {
    if (n.type === 'COMPONENT' || n.type === 'COMPONENT_SET') {
      results.push({
        page: page.name,
        name: n.name,
        type: n.type,
        id: n.id,
        key: n.key,
        // For COMPONENT_SET, list variant properties
        properties: n.type === 'COMPONENT_SET'
          ? Object.entries(n.componentPropertyDefinitions || {}).map(([k, v]) => ({
              name: k,
              type: v.type,
              options: v.type === 'VARIANT' ? v.variantOptions : undefined,
              defaultValue: v.defaultValue
            }))
          : undefined
      });
    }
    return false;
  });
}
return { components: results, count: results.length };
```

### 9.2 — Import and Instantiate a Library Component

```javascript
// Import by key (from search_design_system results)
const component = await figma.importComponentByKeyAsync("{COMPONENT_KEY}");
const instance = component.createInstance();
instance.name = "Button: Primary CTA";

// Append BEFORE setting sizing
{PARENT_NODE}.appendChild(instance);
instance.layoutSizingHorizontal = "FILL";

return { instanceId: instance.id, instanceName: instance.name };
```

### 9.3 — Read Component Properties (Before Setting Them)

```javascript
// CRITICAL: Always inspect properties first — never guess property names
const instance = figma.getNodeById("{INSTANCE_ID}");

const props = instance.componentProperties;
const propDefs = {};

// Read all property definitions
for (const [key, val] of Object.entries(props)) {
  propDefs[key] = {
    type: val.type,            // 'VARIANT', 'TEXT', 'BOOLEAN', 'INSTANCE_SWAP'
    value: val.value,          // Current value
    // For VARIANT type, preferred values come from componentPropertyDefinitions
  };
}

return { properties: propDefs };
```

### 9.4 — Set Variant Properties

```javascript
const instance = figma.getNodeById("{INSTANCE_ID}");

// Set variant property — property name MUST match exactly (case-sensitive)
// Use the key format from componentProperties, which is typically "Property Name#nodeId"
instance.setProperties({
  "{PROPERTY_KEY}": "{VARIANT_VALUE}"
  // Example: "Size#123:456": "Large"
  // Example: "Style#123:456": "Primary"
});

return { updated: true, instanceId: instance.id };
```

**Gotcha:** Variant property keys often include a `#nodeId` suffix (e.g., `"Size#123:456"`). Use the exact key from `instance.componentProperties`, not just the display name.

### 9.5 — Override Text in Component Instances

```javascript
const instance = figma.getNodeById("{INSTANCE_ID}");

// Find all text nodes inside the instance
const textNodes = instance.findAll(n => n.type === "TEXT");

const textMap = textNodes.map(t => ({
  name: t.name,
  characters: t.characters,
  id: t.id
}));

// Override a specific text node
for (const t of textNodes) {
  if (t.name === "{TEXT_LAYER_NAME}") {
    await figma.loadFontAsync(t.fontName);  // MUST load font first
    t.characters = "{NEW_TEXT}";
  }
}

return { textNodes: textMap };
```

**Important — Text property overrides vs direct text editing:**
- If the component has a TEXT-type component property (visible in `componentProperties`), use `setProperties()` instead
- If it's a nested text layer, use direct `characters` assignment as shown above
- Always `loadFontAsync()` before changing characters — even on instances

### 9.6 — Fallback

Max 2 `use_figma` calls on component instantiation. If it doesn't work, build from primitives (Sections 4–7). Raw frame construction always works.

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

## 11 — Token Extraction Helper (Figma Variable Resolver)

**Use when extracting tokens from Figma variables (Source 4).** Resolves alias chains to final values.

### 11.1 — List All Variable Collections

```javascript
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const result = [];

for (const coll of collections) {
  const vars = [];
  for (const varId of coll.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(varId);
    vars.push({
      name: v.name,
      id: v.id,
      type: v.resolvedType,  // 'COLOR', 'FLOAT', 'STRING'
      scopes: v.scopes
    });
  }
  result.push({
    collectionName: coll.name,
    collectionId: coll.id,
    modes: coll.modes.map(m => ({ name: m.name, id: m.modeId })),
    variableCount: vars.length,
    variables: vars
  });
}

return result;
```

### 11.2 — Resolve All Color Variables (With Alias Chain)

```javascript
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const resolved = [];

for (const coll of collections) {
  const modeId = coll.modes[0].modeId;  // Use first mode (or specify)

  for (const varId of coll.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(varId);
    if (v.resolvedType !== 'COLOR') continue;

    let value = v.valuesByMode[modeId];
    let aliasChain = [v.name];
    let resolvedValue = null;

    // Resolve alias chain
    while (value && value.type === 'VARIABLE_ALIAS') {
      const aliasVar = await figma.variables.getVariableByIdAsync(value.id);
      aliasChain.push(aliasVar.name);
      // Find the mode in the alias variable's collection
      const aliasColl = await figma.variables.getVariableCollectionByIdAsync(
        aliasVar.variableCollectionId
      );
      const aliasModeId = aliasColl.modes[0].modeId;
      value = aliasVar.valuesByMode[aliasModeId];
    }

    // Final value should be an RGBA object { r, g, b, a }
    if (value && typeof value === 'object' && 'r' in value) {
      const hex = '#' +
        Math.round(value.r * 255).toString(16).padStart(2, '0') +
        Math.round(value.g * 255).toString(16).padStart(2, '0') +
        Math.round(value.b * 255).toString(16).padStart(2, '0');
      resolvedValue = { rgb: value, hex: hex.toUpperCase() };
    }

    resolved.push({
      name: v.name,
      collection: coll.name,
      aliasChain: aliasChain.length > 1 ? aliasChain : undefined,
      value: resolvedValue
    });
  }
}

return {
  colorCount: resolved.length,
  colors: resolved,
  summary: resolved.map(c =>
    `${c.name}: ${c.value ? c.value.hex : 'UNRESOLVED'}` +
    (c.aliasChain ? ` (via ${c.aliasChain.join(' → ')})` : '')
  ).join('\n')
};
```

### 11.3 — Resolve Typography Variables

```javascript
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const typography = [];

for (const coll of collections) {
  const modeId = coll.modes[0].modeId;

  for (const varId of coll.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(varId);

    // Check if name suggests typography
    const isTypo = /font|type|text|heading|body|size|weight|line.?height|letter.?spacing/i
      .test(v.name);
    if (!isTypo) continue;

    let value = v.valuesByMode[modeId];
    let aliasChain = [v.name];

    // Resolve alias chain
    while (value && value.type === 'VARIABLE_ALIAS') {
      const aliasVar = await figma.variables.getVariableByIdAsync(value.id);
      aliasChain.push(aliasVar.name);
      const aliasColl = await figma.variables.getVariableCollectionByIdAsync(
        aliasVar.variableCollectionId
      );
      value = aliasVar.valuesByMode[aliasColl.modes[0].modeId];
    }

    typography.push({
      name: v.name,
      type: v.resolvedType,
      collection: coll.name,
      aliasChain: aliasChain.length > 1 ? aliasChain : undefined,
      value: value
    });
  }
}

return {
  count: typography.length,
  variables: typography,
  summary: typography.map(t =>
    `${t.name} (${t.type}): ${JSON.stringify(t.value)}` +
    (t.aliasChain ? ` (via ${t.aliasChain.join(' → ')})` : '')
  ).join('\n')
};
```

### 11.4 — Multi-Mode Resolution (Fallback Fonts)

Some collections have multiple modes (e.g., "Default" and "Fallback"). Use this to check all modes when the primary mode's font isn't available:

```javascript
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const multiMode = [];

for (const coll of collections) {
  if (coll.modes.length <= 1) continue;  // Skip single-mode collections

  for (const varId of coll.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(varId);
    if (v.resolvedType !== 'STRING') continue;  // Font families are STRING type

    const values = {};
    for (const mode of coll.modes) {
      let val = v.valuesByMode[mode.modeId];
      // Resolve if alias
      while (val && val.type === 'VARIABLE_ALIAS') {
        const alias = await figma.variables.getVariableByIdAsync(val.id);
        const aliasColl = await figma.variables.getVariableCollectionByIdAsync(
          alias.variableCollectionId
        );
        val = alias.valuesByMode[aliasColl.modes[0].modeId];
      }
      values[mode.name] = val;
    }

    multiMode.push({
      name: v.name,
      collection: coll.name,
      valuesByMode: values
    });
  }
}

return {
  count: multiMode.length,
  variables: multiMode,
  summary: multiMode.map(m =>
    `${m.name}: ${Object.entries(m.valuesByMode).map(([k, v]) => `${k}="${v}"`).join(', ')}`
  ).join('\n')
};
```

**Usage:** When `font-heading` resolves to "ZohoPuvi" (unavailable), check if a "Fallback" mode exists that resolves to "Lato" or another available font.

---

## Quick Reference — Correct Operation Order

```
1. Create node          → figma.createFrame() / figma.createText()
2. resize()             → node.resize(width, height)   [BEFORE sizing modes — resize() resets them to FIXED]
3. Set layout mode      → node.layoutMode = "VERTICAL"
4. Set axis sizing      → node.primaryAxisSizingMode = "AUTO"    [⚠️ DEFAULT IS FIXED — always set explicitly]
5. Set counter sizing   → node.counterAxisSizingMode = "FIXED"   [or "AUTO" — never leave as default]
6. Set min-height       → node.minHeight = 200
7. Load font (text)     → await figma.loadFontAsync(...)  [BEFORE any text ops]
8. Set text properties  → node.characters, fontSize, etc.
9. textAutoResize       → node.textAutoResize = "HEIGHT"          [⚠️ DEFAULT IS WIDTH_AND_HEIGHT — causes overflow]
10. appendChild         → parent.appendChild(node)                 [BEFORE FILL sizing]
11. Set FILL sizing     → node.layoutSizingHorizontal = "FILL"   [AFTER appendChild — fails without auto-layout parent]
12. Return IDs          → return { createdNodeIds: [...] }
```

## Common Defaults That Cause Failures

| Property | Default Value | Why It's Dangerous | What to Set |
|---|---|---|---|
| `primaryAxisSizingMode` | `FIXED` (100px) | Every grid and card collapses to 100px | `'AUTO'` (hug contents) |
| `textAutoResize` | `WIDTH_AND_HEIGHT` | Text overflows parent horizontally | `'HEIGHT'` (wrap + grow) |
| `layoutSizingHorizontal` | `FIXED` | Child doesn't fill parent width | `'FILL'` (after appendChild) |
| `layoutSizingVertical` | `FIXED` | Child doesn't respond to content | `'HUG'` or `'FILL'` |
| `counterAxisSizingMode` | `FIXED` | Frame width stays at creation size | `'FIXED'` (explicit) or `'AUTO'` |

---

## Common API Errors and Fixes

These are the most frequently encountered Figma Plugin API errors. Check this table before debugging.

| Error / Symptom | Cause | Fix |
|---|---|---|
| `counterAxisSizingMode = "FILL"` throws or is ignored | Only `"FIXED"` and `"AUTO"` are valid for `counterAxisSizingMode` | Use `counterAxisSizingMode = "FIXED"` on the parent. For children to fill width, set `child.layoutSizingHorizontal = "FILL"` after `parent.appendChild(child)` |
| `layoutSizing = "FILL"` — property doesn't exist | There's no `layoutSizing` property — it's split into two | Use `layoutSizingHorizontal` and `layoutSizingVertical` separately |
| `figma.currentPage = page` fails | `currentPage` is read-only | Use `await figma.setCurrentPageAsync(page)` |
| `figma.loadAllPagesAsync()` — not a function | This method doesn't exist in the Plugin API | Pages load on demand via `setCurrentPageAsync`. No bulk load needed. |
| `layoutSizingHorizontal = "FILL"` silently ignored | Node isn't a child of an auto-layout parent yet | Call `parent.appendChild(node)` first, then set FILL |
| `resize()` undoes sizing modes | `resize()` resets `layoutSizingHorizontal/Vertical` to `FIXED` | Call `resize()` before setting any sizing modes |
| `loadFontAsync` throws "Font not found" | Font family or style string doesn't match exactly | Run font check (Section 8) first. Style names are case-sensitive: "Semi Bold" not "SemiBold" |
| Shadow/effect causes script failure | Missing `blendMode` on effect object | Always include `blendMode: 'NORMAL'` on DROP_SHADOW and INNER_SHADOW |
| `node.fills[0].color = {...}` doesn't work | Fills/strokes/effects arrays are read-only | Clone: `const f = [...node.fills]; f[0] = {...f[0], color: newColor}; node.fills = f;` |
| `figma.notify("...")` throws "not implemented" | Method not available in MCP plugin context | Use `return { message: "..." }` instead |
| `figma.closePlugin()` errors | Code is auto-wrapped — closing is handled automatically | Never call `closePlugin()` |
| Frame created at (0,0) overlaps existing content | Default position is origin | Calculate `rightEdge` from existing nodes (see Section 2) |

---

## Standard Batch Preamble (Helper Functions)

Every `use_figma` batch call after Batch 0 (page discovery) needs the same set of helper functions. Because the Plugin API context resets between calls, these must be included in every batch.

**Copy this block at the top of every build batch** (after the Frame-Finder Preamble). Replace placeholder values with Build Card values.

```javascript
// === Standard Batch Preamble ===
// Frame-Finder (paste Section 1b preamble above this)

// --- Color Helpers ---
function hex(h) {
  h = h.replace('#', '');
  return {
    r: parseInt(h.substring(0, 2), 16) / 255,
    g: parseInt(h.substring(2, 4), 16) / 255,
    b: parseInt(h.substring(4, 6), 16) / 255
  };
}
function solid(hexColor, opacity) {
  const paint = { type: 'SOLID', color: hex(hexColor) };
  if (opacity !== undefined) paint.opacity = opacity;
  return [paint];
}

// --- Build Card Values (replace from {product}-build-card.md) ---
const COLORS = {
  primary: hex("{COLOR_PRIMARY}"),
  cta: hex("{COLOR_CTA}"),
  ctaHover: hex("{COLOR_CTA_HOVER}"),
  textPrimary: hex("{COLOR_TEXT_PRIMARY}"),
  textSecondary: hex("{COLOR_TEXT_SECONDARY}"),
  bgPage: hex("{COLOR_BG_PAGE}"),
  bgSurface: hex("{COLOR_BG_SURFACE}"),
  tint1Surface: hex("{COLOR_TINT1_SURFACE}"),
  tint1Border: hex("{COLOR_TINT1_BORDER}")
};
const FONTS = {
  heading: { family: "{FONT_HEADING}", style: "{FONT_HEADING_STYLE}" },
  body: { family: "{FONT_BODY}", style: "Regular" },
  bodyBold: { family: "{FONT_BODY}", style: "Bold" }
};
const SPACING = {
  sectionPaddingY: {SECTION_PADDING_Y},
  gridGutter: {GRID_GUTTER},
  cardPadding: {CARD_PADDING},
  contentMaxWidth: {CONTENT_MAX_WIDTH},
  sidePadding: (1440 - {CONTENT_MAX_WIDTH}) / 2
};
const RADIUS = { md: {RADIUS_MD} };
const SHADOW_MD = {
  type: 'DROP_SHADOW', blendMode: 'NORMAL',
  color: { r: 0, g: 0, b: 0, a: 0.12 },
  offset: { x: 0, y: 2 }, radius: 8, spread: 0, visible: true
};

// --- Font Loading (load all fonts used in this batch) ---
await figma.loadFontAsync(FONTS.heading);
await figma.loadFontAsync(FONTS.body);
await figma.loadFontAsync(FONTS.bodyBold);

// --- Text Helper ---
function mkText(parent, text, options = {}) {
  const node = figma.createText();
  node.fontName = options.font || FONTS.body;
  node.characters = text;
  node.fontSize = options.size || 16;
  node.fills = solid(options.color || "{COLOR_TEXT_PRIMARY}");
  if (options.lineHeight) node.lineHeight = { unit: 'PIXELS', value: options.lineHeight };
  parent.appendChild(node);
  node.textAutoResize = "HEIGHT";
  node.layoutSizingHorizontal = "FILL";
  return node;
}

// --- Section Helper ---
function mkSection(name, options = {}) {
  const section = figma.createFrame();
  section.name = "Section: " + name;
  section.resize(1440, 100);
  mainFrame.appendChild(section);
  section.layoutSizingHorizontal = "FILL";
  section.layoutMode = "VERTICAL";
  section.primaryAxisSizingMode = "AUTO";
  section.counterAxisSizingMode = "FIXED";
  section.minHeight = options.minHeight || 200;
  section.paddingTop = SPACING.sectionPaddingY;
  section.paddingBottom = SPACING.sectionPaddingY;
  section.paddingLeft = SPACING.sidePadding;
  section.paddingRight = SPACING.sidePadding;
  section.itemSpacing = options.itemSpacing || 32;
  section.fills = options.tint ? solid(options.tint) : solid("{COLOR_BG_PAGE}");
  return section;
}

// --- Section Header Helper ---
function mkSectionHeader(parent, title, subtitle) {
  const header = figma.createFrame();
  header.name = "Section Header";
  header.layoutMode = "VERTICAL";
  header.primaryAxisSizingMode = "AUTO";
  header.counterAxisSizingMode = "AUTO";
  header.itemSpacing = 12;
  header.fills = [];
  parent.appendChild(header);
  header.layoutSizingHorizontal = "FILL";
  header.counterAxisAlignItems = "CENTER";

  mkText(header, title, { font: FONTS.heading, size: 32, lineHeight: 40 });
  if (subtitle) mkText(header, subtitle, { size: 18, color: "{COLOR_TEXT_SECONDARY}", lineHeight: 28 });
  return header;
}

// --- Grid Helper ---
function mkGrid(parent, columns, options = {}) {
  const grid = figma.createFrame();
  grid.name = options.name || "Grid";
  grid.layoutMode = "HORIZONTAL";
  grid.layoutWrap = "WRAP";
  grid.primaryAxisSizingMode = "FIXED";
  grid.counterAxisSizingMode = "AUTO";
  grid.itemSpacing = SPACING.gridGutter;
  grid.counterAxisSpacing = SPACING.gridGutter;
  grid.fills = [];
  parent.appendChild(grid);
  grid.layoutSizingHorizontal = "FILL";
  grid._columns = columns; // Store for card width calculation
  return grid;
}
// === End Standard Batch Preamble ===
```

**Usage:** After pasting, replace all `{PLACEHOLDER}` values with the resolved values from the Build Card. The helpers are designed so that every subsequent section can be built with ~20–30 lines of section-specific code instead of 80+.

**Card width calculation from grid helper:**
```javascript
// Calculate card width based on grid columns
const cardWidth = (grid.width - SPACING.gridGutter * (grid._columns - 1)) / grid._columns;
```

---

## 12 — Programmatic Verification Script

**Run as a single `use_figma` call after all sections are built (Phase A of self-healing).** Checks the 5 most common failure modes. Fix all issues before taking a visual screenshot (Phase B).

```javascript
// === Frame-Finder Preamble ===
const targetPage = figma.root.children.find(p => p.name === "{PAGE_NAME}");
if (!targetPage) return { error: "Page '{PAGE_NAME}' not found" };
await figma.setCurrentPageAsync(targetPage);
const mainFrame = figma.getNodeById("{MAIN_FRAME_ID}");
if (!mainFrame) return { error: "Main frame not found" };
// === End Preamble ===

const MIN_HEIGHTS = {
  Hero: 500, "Feature Grid": 300, "Feature Row": 300,
  CTA: 250, Pricing: 250, FAQ: 200, Footer: 150
};
const issues = [];

function checkText(node) {
  // Check 5: Text overflow — WIDTH_AND_HEIGHT inside auto-layout parent
  // Exception: centered labels (WIDTH_AND_HEIGHT is intentional when
  // parent uses counterAxisAlignItems CENTER with FIXED sizing)
  if (node.textAutoResize !== "WIDTH_AND_HEIGHT") return;
  const parent = node.parent;
  if (!parent || parent.layoutMode === "NONE") return;
  const isCenteredLabel = parent.counterAxisSizingMode === "FIXED"
    && parent.counterAxisAlignItems === "CENTER";
  if (isCenteredLabel) return;
  issues.push({
    check: "TEXT_OVERFLOW", nodeId: node.id, name: node.name,
    actual: "WIDTH_AND_HEIGHT", expected: "HEIGHT",
    fix: "textAutoResize → HEIGHT, then layoutSizingHorizontal → FILL"
  });
}

function checkNode(node, path) {
  if (!node) return;
  // TEXT/VECTOR have no children — check text, then stop recursion
  if (node.type === "TEXT") { checkText(node); return; }
  if (node.type === "VECTOR" || !("children" in node)) return;

  const fullPath = path + " > " + (node.name || node.type);

  // Check 1: Section min-height
  if (node.name && node.name.startsWith("Section:")) {
    const sectionType = node.name.replace("Section: ", "").split(" ")[0];
    const minH = MIN_HEIGHTS[sectionType] || 200;
    if (node.height < minH) {
      issues.push({
        check: "MIN_HEIGHT", nodeId: node.id, name: node.name,
        actual: Math.round(node.height), expected: minH,
        fix: "primaryAxisSizingMode → AUTO, minHeight → " + minH
      });
    }
  }

  // Check 2: Grid/card sizing must be AUTO
  if (node.name && (node.name.startsWith("Feature Grid") || node.name.startsWith("Grid"))) {
    if (node.counterAxisSizingMode !== "AUTO") {
      issues.push({
        check: "GRID_SIZING", nodeId: node.id, name: node.name,
        actual: node.counterAxisSizingMode, expected: "AUTO",
        fix: "counterAxisSizingMode → AUTO"
      });
    }
  }

  // Check 3: Buttons shouldn't exceed 60px height
  if (node.name && node.name.startsWith("Button:")) {
    if (node.height > 60) {
      issues.push({
        check: "BUTTON_HEIGHT", nodeId: node.id, name: node.name,
        actual: Math.round(node.height), expected: "≤60",
        fix: "Check padding and font size"
      });
    }
  }

  // Check 4: FILL sizing only inside auto-layout parent
  if (node.layoutSizingHorizontal === "FILL" || node.layoutSizingVertical === "FILL") {
    const parent = node.parent;
    if (parent && parent.layoutMode === "NONE") {
      issues.push({
        check: "FILL_NO_AUTOLAYOUT", nodeId: node.id, name: node.name,
        fix: "Parent has no layoutMode — FILL is ignored. Set parent.layoutMode or use FIXED sizing."
      });
    }
  }

  // Recurse into children
  for (const child of node.children) checkNode(child, fullPath);
}

checkNode(mainFrame, "");

const sectionCount = mainFrame.children.filter(
  c => c.name && c.name.startsWith("Section:")
).length;

return {
  pass: issues.length === 0,
  sectionCount,
  issueCount: issues.length,
  issues,
  summary: issues.length === 0
    ? `✓ All checks passed (${sectionCount} sections)`
    : `✗ ${issues.length} issue(s) found:\n` +
      issues.map(i => `  [${i.check}] ${i.name} — ${i.fix}`).join('\n')
};
```

**Max 3 iterations:** Fix Phase A issues → re-run script → if clean, take screenshot (Phase B). If Phase B reveals visual issues, fix and re-run both phases. Stop after 3 total iterations regardless.

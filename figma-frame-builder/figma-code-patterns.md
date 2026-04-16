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

### 9.6 — Fallback Strategy

Component instantiation with complex design systems (like UEMS Design System 3.0) is non-trivial. Follow this escalation:

| Attempt | Action | Time Budget |
|---|---|---|
| 1 | Search library → import → instantiate → set properties | 1 `use_figma` call |
| 2 | If properties fail, inspect instance structure → try direct child overrides | 1 `use_figma` call |
| 3 (fallback) | Abandon component reuse → build from scratch using Sections 4–7 | Continue with raw frames |

**Rule:** Do not spend more than 2 `use_figma` calls trying to get a component instance working. Raw frame construction is predictable and always works.

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

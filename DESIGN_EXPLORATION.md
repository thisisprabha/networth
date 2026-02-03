# NetWorth iOS — Design Exploration (WWDC 2025 Session 359)

This document captures a **redesign approach** for NetWorth iOS, based on the ideas from Apple’s Design Evangelism session (WWDC 2025 / 359).  
Transcript reference: `wwdc2025-359.txt`.

The session’s core framing:
- **Where am I?**
- **What can I do?**
- **Where can I go from here?**

If those answers are obvious at all times, the app feels inviting, predictable, and fast.

---

## 1) Structure (Information Architecture)

### 1.1 What NetWorth is (purpose)
**A private, on-device net worth tracker** that helps people:
1) see their net worth at a glance  
2) update assets quickly  
3) understand projections / growth assumptions  
4) back up and restore safely

### 1.2 Primary jobs-to-be-done (JTBD)
Rank these by frequency and design around the top:
1) **Check net worth** (30 seconds)
2) **Add/update an asset value** (30–60 seconds)
3) **Review distribution** (what’s driving net worth)
4) **Adjust growth rates** (rare, but important for trust)
5) **Backup/restore** (rare, but critical)

### 1.3 Structure outcome: sharpen + simplify
We should actively remove or delay anything that doesn’t support the JTBD list.
- Prefer **clear “money tasks”** over decorative UI.
- Prefer **one strong primary action per screen**.
- Prefer **progressive disclosure** over showing everything at once.

---

## 2) Navigation (clarity + confidence)

### 2.1 Tab bar: keep it simple
Keep tab bar to **three** clear areas (labels + SF Symbols):
1) **Overview** (`house` or `chart.pie`)
2) **Assets** (`list.bullet` or `tray.full`)
3) **Settings** (`gearshape`)

Avoid extra tabs unless a tab is a “daily destination”.

### 2.2 Put “Add” in the right place
Instead of a global “Add” in the tab bar:
- Place **Add Asset** in the **Assets** context:
  - toolbar `+` on Assets list
  - optionally a prominent “Add asset” row in empty states

### 2.3 Toolbars always answer “Where am I / What can I do”
Each screen should have:
- A **clear title** (not branding)
- 1–2 **screen-specific actions** (not a menu dump)

Examples:
- **Overview**: optional “Today” / “As of” context, maybe “Share/Export” later (not v1)
- **Assets**: `+` add, optional search
- **Settings**: no toolbar actions (mostly Form-driven)

### 2.4 iPad navigation
Use a split layout:
- `NavigationSplitView` for Assets (categories/list → detail)
- Keep behavior aligned with iPhone so mental model stays consistent.

---

## 3) Content (organization + progressive disclosure)

### 3.1 Don’t mix content types on the same level
Avoid mixing:
- summaries (totals, projections)
- collections (assets/categories)
- configuration (growth rates, backup)

Each screen should have a primary content type.

### 3.2 Overview content proposal
Goal: **instant orientation** + the next action.

Recommended layout (top → bottom):
1) **Net worth hero** (anchor)
2) **Key insight** (1-year projection or delta)
3) **Distribution preview** (top categories or a simple chart)
4) **Top assets** (optional, short list)

Progressive disclosure:
- “See all categories” → takes you to Assets
- “See projection details” → optional later

### 3.3 Assets content proposal
Two-step progressive disclosure:
1) **Categories list** (grouped, scannable)
   - each row shows category name + total + % of net worth
2) Category detail shows assets within that category (sorted)

Why: reduces decision fatigue and helps people find what they need faster.

### 3.4 Prefer list layouts for structured information
Lists are:
- familiar
- easy to scan
- resilient to long text
- adaptable across devices and Dynamic Type sizes

Use grids only when the content is inherently visual (not the case for numbers-first finance data).

### 3.5 Grouping strategies (when lists get big)
Potential groupings:
- By **category**
- By **recently updated**
- By **largest value**
- By **trend** (up/down) later

Start with category + largest value for v1.

---

## 4) Visual Design (personality + usability)

### 4.1 Create strong anchors
Use 1–2 anchors per screen:
- Overview: **net worth hero**
- Assets: **category totals list**
- Settings: standard grouped Form (don’t over-design)

### 4.2 Typography: use system styles
Use dynamic type and system styles to scale gracefully:
- Hero value: `.largeTitle`/custom large with rounded design
- Labels: `.subheadline` / `.headline`
- Secondary: `.caption` / `.footnote`

Avoid hand-tuned pixel typography unless necessary.

### 4.3 Color: semantic first, personality second
Rules:
- Use semantic colors for text/background to stay legible.
- Use accent colors for actions, not everything.
- Use category color as a small cue (icon badge), not a full background.

### 4.4 Gradient header (optional, “personality zone”)
If we use a gradient/mesh, keep it:
- limited to the hero area
- behind high-contrast text
- consistent across sessions

This is where we can introduce “Cred-like” personality without compromising readability.

### 4.5 Motion: tasteful, purposeful
Use motion to reinforce hierarchy, not to entertain:
- staggered entrance for cards (fast)
- numeric transitions on value changes
- subtle spring on “Add asset”
- haptics on key actions (add/save/delete)

---

## 5) Redesign Experiments (what we should prototype next)

### Experiment A — Overview-first clarity
- Hero net worth with “As of” timestamp
- One projection insight only
- “See all categories” CTA

Success criteria: user can understand the app in <5 seconds.

### Experiment B — Category-first Assets
- Categories list as the main Assets screen (not all assets mixed)
- Category detail for the deeper list

Success criteria: user can add/edit an asset without hunting.

### Experiment C — Trust building
- Show growth rate assumptions plainly and consistently
- In projections, always label: “Assumptions, not guarantees”

Success criteria: projection feels trustworthy, not gimmicky.

---

## 6) Implementation Notes (so design stays “native iOS”)
- Use familiar platform components (Tab bar + toolbar + lists/forms).
- Keep tab count low; move actions into the correct context.
- Build the UI around the JTBD list (not around “cool components”).
- Use iOS 26+ glass effects only where it supports hierarchy and focus, with fallbacks.

---

## 7) Next Steps
1) Decide final tab labels + icons (Overview/Assets/Settings).
2) Sketch two wireframes each for:
   - Overview (A/B)
   - Assets (Category-first vs All-assets-first)
3) Pick one and implement it as a SwiftUI prototype.
4) Test on iPhone + iPad with Dynamic Type (including XL).


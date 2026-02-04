# NetWorth iOS — UI Improvement TODO Plan (based on `design.md`)

This is a **design-only** plan: layout, hierarchy, typography, color, motion, and accessibility.  
It **must not change app functionality**. If something needs new behavior, it’s explicitly flagged.

## Design Audit Results

**Overall assessment:** The app has a strong foundation (3-tab structure, clear data model, clean card-based overview), but it doesn’t yet feel “inevitable.” The main gaps are **hierarchy clarity on Overview**, **inconsistent rhythm across cards/lists**, **token discipline (a few rogue values/gradients)**, and **under-designed empty states + iPad adaptations**.

**Screens/components covered (code-based audit):**
- Root: `ios/NetWorthIOS/Views/RootView.swift`
- Overview: `ios/NetWorthIOS/Views/HomeView.swift`
- Assets: `ios/NetWorthIOS/Views/AssetsListView.swift`, `ios/NetWorthIOS/Views/CategoryRowView.swift`
- Category: `ios/NetWorthIOS/Views/CategoryDetailView.swift`, `ios/NetWorthIOS/Views/AssetRowView.swift`
- Add/Edit: `ios/NetWorthIOS/Views/AssetFormView.swift`
- Settings: `ios/NetWorthIOS/Views/SettingsView.swift`
- Lock: `ios/NetWorthIOS/Views/AppLockView.swift`
- Widget: `ios/NetWorthWidget/NetWorthWidgetView.swift`
- Current “design system”: `ios/NetWorthIOS/DesignSystem/Theme.swift`, `CardContainer`, `GlassCard`, `GlassStack`

**Audit limitation:** I can’t “walk the live app” here; this plan assumes current behavior as represented in code. Before implementing Phase 1, capture baseline screenshots (iPhone + iPad) to validate priorities.

---

## PHASE 1 — Critical
Issues that actively hurt clarity, usability, responsiveness, or consistency.

- **[Root / safe area]** App can feel like it’s not filling the screen (reported “small mode/black bars”) → Remove global safe-area overrides and make backgrounds intentional per screen → This is an immediate “trust” issue; a finance app must feel stable and native.
- **[Overview / primary action]** Overview shows a lot of information, but the “next step” isn’t obvious (check → update) → Establish one clear primary action in the Overview context (without adding new flows) → Clarity: “What can I do next?” should be answered instantly.
- **[Empty states]** Empty screens explain, but don’t *move the user forward* (no CTA) → Add a single, obvious CTA in each empty state (“Add asset”) using existing add flow → Removes friction; first-use experience decides retention.
- **[Consistency / card rhythm]** Cards can drift in perceived width/spacing when internal layouts differ (charts/rows) → Enforce a single card grid + consistent internal padding rules → “Premium” is mostly alignment and rhythm.
- **[iPad readiness]** Layout is iPhone-first but iPad can feel stretched/empty → Add a basic iPad layout strategy for key screens (Assets in particular) → iPhone+iPad is a requirement; iPad can’t feel accidental.

**Review (why Phase 1 first):** These items determine whether the app feels “real” and predictable. If any screen looks like it’s not fully designed for the device, everything else (colors, gradients, motion) reads as decoration.

---

## PHASE 2 — Refinement
Hierarchy, typography, spacing, alignment, and component consistency upgrades.

- **[Design system discipline]** A few hard-coded values exist (e.g., mesh/gradients) and spacing is not tokenized → Centralize: spacing scale, radii, elevation, and hero gradient stops as tokens → Prevents “one-off” styles and makes iteration fast and consistent.
- **[Overview / information architecture]** Too many cards compete; each is “medium importance” → Restructure the Overview into 3 clear blocks: **Hero**, **Insights**, **Actionable next step** (progressive disclosure) → Makes the screen understandable in ~2 seconds.
- **[Overview / hero]** Hero has strong personality but can do more “orientation” work → Add one compact secondary line in hero (e.g., “since last update” OR “1Y projection”) and remove redundancy elsewhere → One anchor, one insight, then the next action.
- **[Cards / headers]** Each card’s header pattern varies (badges/labels/secondary text are inconsistent) → Create a single `CardHeader` pattern (title + optional trailing + optional subtitle) and apply across cards → Consistency is non-negotiable.
- **[Charts]** Hiding all axes removes context; showing too many ticks adds noise → Use a consistent “minimal chart language” (2–3 ticks, subtle grid, clear labels) → Charts should be “glanceable,” not blank.
- **[Lists / rows]** Row icon shapes differ (circle vs rounded-rect), and type hierarchy can feel heavy → Standardize row icon container + typography: primary label `.body/.headline` (one choice), secondary `.caption`, value `.body` semibold → Calmer scanning and fewer competing styles.
- **[Assets screen]** Sections are clear, but could better communicate meaning (Wealth vs Liabilities vs Protection) → Add short section footers or microcopy (1 line) and consistent value styling (sign, color semantics) → Helps users interpret data without thinking.
- **[Forms]** `Form` works but can feel “default” → Apply a refined form layout: consistent field spacing, clearer numeric formatting, and projection section visual separation → Makes data entry feel intentional.
- **[Settings]** Functional but visually “utility” → Add clearer grouping, microcopy, and consistent destructive/primary emphasis (still native Form) → Settings should be calm and unambiguous.

**Review (why Phase 2 next):** Once the app fills the screen correctly and the primary action is obvious, Phase 2 makes everything feel designed as one system instead of “screens.”

---

## PHASE 3 — Polish
Motion, micro-interactions, accessibility, and “quiet premium” finishing.

- **[Motion / navigation]** Transitions are mostly default → Add subtle, purposeful motion: matched transitions where appropriate, gentle springs, no gratuitous animation → Motion should feel like physics, not decoration.
- **[Motion / numbers]** Numeric changes already transition in places; make it consistent where it matters → Use `contentTransition(.numericText())` consistently for primary values (hero, totals, projection) → Perceived quality goes up immediately.
- **[Haptics]** Key actions feel “flat” → Add light haptics for add/save/delete/import success/failure → Touch feedback = responsiveness.
- **[Empty states]** Make them feel designed, not “blank” → Use consistent empty-state visuals + CTA; no walls of text → Keeps first-use calm.
- **[Accessibility]** Verify Dynamic Type, contrast, and VoiceOver reading order → Fix any truncation, ensure hit targets, support Reduce Motion → Inclusive design also makes the UI more robust.
- **[Dark mode] (optional later)** Current theme is light-first → Define a dark palette and verify cards/gradients/shadows → Only do this when Phase 1/2 are solid.

**Review (expected impact):** Phase 3 is what makes the app feel “expensive”: responsiveness, tactility, and the absence of rough edges.

---

## DESIGN_SYSTEM updates required (before implementation)
There is no standalone `DESIGN_SYSTEM.md` in this repo. Right now, tokens live in code (`Theme.swift` + components). Before implementing phases, decide/approve:

- **Spacing scale:** e.g., `4/8/12/16/20/24/32` and a single screen horizontal inset token.
- **Radii:** card radius, icon radius, pill radius.
- **Elevation:** 1–2 shadow levels (card + hero), with a single “direction”.
- **Typography rules:** which text styles map to which semantic role (hero value, section title, row title, caption).
- **Color usage:** accent vs accentAlt vs positive/negative; define where each is allowed.
- **Hero gradient stops:** move all hero/widget gradient colors into tokens (no per-view hardcoding).
- **Component rules:** card header pattern, row icon container pattern, pill/badge pattern.

If you want, I can also create a `DESIGN_SYSTEM.md` file that mirrors the code tokens (so design + implementation stay synced).

---

## IMPLEMENTATION notes for build agent (precise, no ambiguity)
These are written as “TODOs” so we can implement them phase-by-phase only after you approve.

### Phase 1 (Critical)
- `ios/NetWorthIOS/Views/RootView.swift`: Remove global `.ignoresSafeArea()` on the `TabView`; ensure each root screen sets a background that fills the safe area (use `Theme.background`).
- `ios/NetWorthIOS/Views/HomeView.swift`: Add one primary CTA placement on Overview (e.g., a single button row under hero) that routes to existing add/update flow (no new flows).
- `ios/NetWorthIOS/Views/AssetsListView.swift`: Replace empty state with `ContentUnavailableView` that includes an action to open the existing “Add Asset” sheet.
- `ios/NetWorthIOS/Views/CategoryDetailView.swift`: When category is empty, use a consistent empty-state block + action to add within that category (existing sheet).
- `ios/NetWorthIOS/DesignSystem/CardContainer.swift`: Keep card max-width behavior; ensure any internal content (charts) respects the same horizontal padding rule as other cards.

### Phase 2 (Refinement)
- `ios/NetWorthIOS/DesignSystem/Theme.swift`: Add nested tokens (spacing, radius, elevation, gradient stops) and update views to reference those tokens instead of raw numbers/colors.
- `ios/NetWorthIOS/Views/HomeView.swift`: Rebalance card order + density:
  - Keep hero as anchor.
  - Consolidate “Insights/Drivers/Trend” presentation into fewer, clearer sections (progressive disclosure).
  - Ensure every card uses the same header pattern.
- `ios/NetWorthIOS/Views/AssetRowView.swift` + `ios/NetWorthIOS/Views/CategoryRowView.swift`: Standardize icon container shape/size and row typography hierarchy.
- `ios/NetWorthIOS/Views/AssetFormView.swift`: Improve section separation and numeric readability while staying native (avoid custom controls unless necessary).
- `ios/NetWorthIOS/Views/SettingsView.swift`: Add microcopy and consistent emphasis (accent usage only where it matters).

### Phase 3 (Polish)
- `ios/NetWorthIOS/Views/HomeView.swift`: Add subtle motion (stagger is already present) and align animation timings; ensure Reduce Motion disables non-essential motion.
- `ios/NetWorthIOS/Views/*RowView.swift`: Add light haptics on selection where appropriate (only for “commit” actions, not for every tap).
- `ios/NetWorthWidget/NetWorthWidgetView.swift`: Keep `containerBackground(for: .widget)` (iOS 17+) and align widget typography with app tokens.

---

## Baseline screenshots checklist (so we validate improvements)
- iPhone (your device): Overview, Assets, Category detail, Add asset, Settings, App lock
- iPad: Assets list + category detail (at least)
- Widget: small + medium on Home screen
- Dynamic Type: at least 2 larger sizes for Overview + Assets list


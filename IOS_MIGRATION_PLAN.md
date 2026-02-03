# NetWorth iOS (SwiftUI) Migration Plan

**Document purpose:** A thorough plan to rewrite the current JS/PWA into a native SwiftUI iOS app and publish it on the App Store.  
**Status:** Planning only (implementation starts after approval).

---

## 1) Confirmed Decisions
- **Unlock:** Face ID / Touch ID (with system passcode fallback).
- **Backups:** iCloud device backup **allowed** (default iOS behavior).
- **Targets:** **Universal** (iPhone + iPad).
- **Currency:** INR only for v1.

## 2) Open Decisions (Need final confirmation before coding)
- **Minimum iOS version:** Recommend **iOS 17+** for the cleanest SwiftUI/Charts experience; iOS 16+ if wider reach is more important.
- **App Lock behavior:** Auto‑lock immediately vs. after configurable grace period (e.g., 1–5 minutes after background).
- **Data format:** Encrypted file store (simpler) vs. SwiftData/Core Data (more scalable).

---

## 3) Current PWA Feature Inventory (Parity Targets)
**Core flows**
- PIN gate → Home summary → Assets list → Add/Edit asset → Backup/Restore.

**Data model**
- Assets with categories, fields, per‑category growth rates, and projection rules.
- Local‑only data (LocalStorage).

**Notable features**
- CSV export/import (values column contains JSON).
- Net‑worth calculations and 1‑year projection.
- Asset breakdown + top assets list.

---

## 4) Target iOS Architecture (SwiftUI)
**Principles**
- Native SwiftUI patterns aligned to iOS Human Interface Guidelines.
- Fully offline with strong on‑device protection.
- Config‑driven asset forms (mirrors JS flexibility).

**Project structure (suggested)**
- `Models/`
  - `Asset`, `AssetCategory`, `AssetField`, `Settings`, `GrowthRates`
- `Stores/`
  - `AssetStore` (actor, single source of truth)
  - `SettingsStore`
  - `AppLockStore`
- `Services/`
  - `CalculationsService`
  - `ImportExportService`
  - `CryptoService`
  - `Formatters`
- `Views/`
  - `HomeView`, `AssetsListView`, `AssetDetailView`, `AssetFormView`, `SettingsView`, `AppLockView`
- `DesignSystem/`
  - Colors, typography, spacing, asset icons (SF Symbols)

---

## 5) UI / UX Plan (SwiftUI + iOS Guidelines)
**Navigation**
- iPhone: `TabView` (Home, Assets, Settings) + `NavigationStack`.
- iPad: `NavigationSplitView` (sidebar list + detail).

**Home**
- Total net worth (large, prominent).
- 1‑year projection summary.
- Top assets list.
- Optional: native charts (Swift Charts).

**Assets**
- List sorted by value.
- Swipe actions (edit/delete).
- Tap to view/edit.

**Add/Edit Asset**
- Category picker → dynamic fields.
- Slider + numeric input combo for large values.
- Growth rate override (per category).

**Settings**
- Backup/Restore.
- App lock settings.
- Growth rate defaults.
- Reset data.

**Accessibility**
- Dynamic Type, VoiceOver labels, color contrast.
- Haptics for key actions.

---

## 6) Data & Security Plan
**Storage**
- **Option A (Recommended):** Encrypted JSON file (CryptoKit).
  - Symmetric key stored in Keychain.
  - File saved with `NSFileProtectionComplete`.
- **Option B:** SwiftData/Core Data + file protection.

**App Lock**
- Face ID/Touch ID using `LocalAuthentication`.
- Passcode fallback handled by the system.
- Optional auto‑lock on background.

**Data privacy**
- On‑device only.
- No analytics, no tracking.

---

## 7) Migration & Backup Strategy
**CSV import (v1 priority)**
- Parse headers and JSON values column.
- Validate categories and fields.
- Merge by `id` (prefer newer `updatedAt`).

**CSV export**
- Same schema as current PWA for portability.

**Future**
- Optional encrypted backup file format.

---

## 8) Development Phases (Milestones)
**Phase 1: Foundation**
- Create SwiftUI app shell + navigation.
- Define models, settings, and category definitions.

**Phase 2: Persistence + Security**
- Implement storage (encrypted file or SwiftData).
- Implement App Lock flow.

**Phase 3: Core Features**
- Asset CRUD + dynamic form fields.
- Calculations + projections.
- Home summary.

**Phase 4: Import/Export**
- CSV import/export with full parity.

**Phase 5: Polish**
- iPad layout, accessibility, animations, haptics.
- UI refinements for iOS guidelines.

---

## 9) Testing Plan
- Unit tests for calculations and projections.
- CSV import/export tests (round‑trip).
- App lock flow tests (manual + unit where possible).
- UI smoke tests (iPhone + iPad).

---

## 10) App Store Publishing Checklist
- Bundle ID, signing, App Store Connect setup.
- App icon set + launch screens.
- Screenshots (iPhone + iPad).
- Privacy policy + “Data Not Collected” if true.
- Finance category compliance + disclaimers.
- TestFlight beta → App Review submission.

---

## 11) Next Step to Start Implementation
- Confirm open decisions (min iOS version, app lock timing, storage option).
- Install and use `swiftui-expert-skill` for updated UI guidance.

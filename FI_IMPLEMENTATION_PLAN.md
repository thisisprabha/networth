# FI (Financial Freedom) — Implementation Plan (Existing NetWorth App)

This plan explains **how to add Financial Freedom metrics** (FI target, time-to-FI, emergency/insurance gaps, score) into the current app without rewriting the architecture.

Related: `FINANCIAL_FREEDOM_FORMULAS.md`

---

## 0) Current App Reality Check (What We Have Today)

### ✅ Already in the app
- **Asset store**: `localStorage["networthvault_assets"]` via `js/storage.js`
- **Asset categories & values**: `js/assetCategories.js` (stocks, mutualFunds, fixedDeposits, home, land, savings, emergencySavings, etc.)
- **Net worth + projection**: `js/calculations.js` + `js/components/dashboard.js`
- **Emergency fund amount** can be captured today via the `emergencySavings` asset category (field: `emergencyBalance`)

### ❌ Not in the app (required for FI)
- No user **profile** (income, expenses, age, dependents, target age)
- No **insurance** data (life/medical coverage)
- No **FI assumptions** (SWR, inflation/return) stored
- No **RD (Recurring Deposit)** category (you mentioned it explicitly)
- No liabilities/debt (optional but high impact)

So: we **do not** have all required data in place yet.

---

## 1) MVP Scope (What We Ship First)

Home screen shows:
- FI target (₹), FI progress %, FI gap (₹)
- Time-to-FI at current monthly investing (years)
- Required monthly investment to hit FI by target age
- Emergency fund status (months covered + gap)
- Insurance status (life + medical: present? cover amount vs target)
- A single “Next best step” card

No new backend, no accounts, privacy-first local storage only.

---

## 2) Data We Need From the User (Inputs)

### Must-have (to compute FI at all)
- `monthlyExpenses` (or annual expenses)
- `ageYears`
- `targetFIageYears` (or “goal years to FI”)
- **Either**:
  - `monthlyIncome` (then savings = income - expenses), **or**
  - `monthlyInvestment` (direct input; useful if user doesn’t want to share income)

### Protection (for the “coverage” section)
- `hasMedicalInsurance`, `medicalCoverAmount`
- `hasLifeInsurance`, `lifeCoverAmount` (especially if `dependentsCount > 0`)
- `dependentsCount` (also used for emergency fund target months)

### Assumptions (defaults are OK; user-editable later)
- `swr` (default `0.04`)
- `nominalReturn` and `inflation` (or directly `realReturn`)

### Strongly recommended (improves accuracy a lot)
- `liabilitiesTotal` (loans/credit cards)
- “Include home in FI?” toggle (many people exclude primary residence from FI math)
- `riskProfile` (Stable / Medium / Variable) → sets emergency fund target months

---

## 3) Storage Plan (Minimal & Backward-Compatible)

Add a new key:
- `localStorage["networthvault_profile"]`

In `js/storage.js`, add:
- `PROFILE_KEY`
- `getProfile()`, `saveProfile(profile)`, `getDefaultProfile()`

Suggested profile shape (MVP):
```js
{
  ageYears: null,
  dependentsCount: 0,
  monthlyIncome: null,
  monthlyExpenses: null,
  monthlyInvestmentOverride: null,
  targetFIageYears: 60,

  // Protection
  hasMedicalInsurance: false,
  medicalCoverAmount: 0,
  hasLifeInsurance: false,
  lifeCoverAmount: 0,

  // FI assumptions
  swr: 0.04,
  nominalReturn: 0.10,
  inflation: 0.06,

  // Toggles
  includeHomeInFI: false,
  includeEmergencyInFI: false
}
```

Backward compatibility:
- If no profile exists → return defaults and show “Complete setup to unlock FI”.

---

## 4) Calculation Plan (Where the Math Lives)

Option A (cleaner): add `js/financialFreedom.js` with a small `FinancialFreedomService`.
Option B (fastest): extend `js/calculations.js` with FI methods.

Either way, implement these functions (from `FINANCIAL_FREEDOM_FORMULAS.md`):
- `getCategoryTotal(categoryKey)` (sum across assets with the same category)
- `getInvestablePortfolioTotal(profile)` (sum selected asset categories; exclude `personalAssets` by default)
- `calculateFiTarget(profile)` → `fiTarget`, `fiGap`, `fiProgress`
- `calculateMonthsToFI(profile)` (closed-form)
- `calculateRequiredMonthlyInvestment(profile)`
- `calculateEmergencyMetrics(profile)` using `emergencySavings` total
- `calculateProtectionMetrics(profile)` for life + medical
- `calculateFinancialFreedomScore(profile, metrics)`
- `getNextBestStep(profile, metrics)`

Mapping investable assets (MVP default):
- Include: `stocks`, `mutualFunds`, `fixedDeposits`, `bonds`, `vpf_ppf`, `silver`, `gold`, `esop`, `privateEquity`, `savings`
- Real estate: include `home`/`land` only if user toggle `includeHomeInFI = true`
- Exclude: `personalAssets` (cars, phones, etc.)
- Emergency: include only if `includeEmergencyInFI = true` (default false)

---

## 5) UI Plan (How It Fits Existing Screens)

### 5.1 Onboarding / Profile Edit
Add a lightweight **Profile modal** (similar to asset modal):
- Triggered when FI section is tapped, or when profile is incomplete
- Fields: expenses, income (or monthlyInvestmentOverride), age, dependents, insurance
- Advanced section: SWR/return/inflation + toggles

Where:
- New component: `js/components/profileForm.js` (recommended)
- Add a container in `index.html` similar to `#asset-modal`

### 5.2 Home Dashboard Additions
In `index.html` add a new section between Net Worth and Projection:
- **Financial Freedom** card:
  - Score (0–100), progress bar
  - FI Target, Current Investable, Gap
  - Time to FI / Required monthly investment
  - “Next best step” CTA

In `js/components/dashboard.js`:
- Extend `updateSummary()` to also render FI metrics if profile is complete

### 5.3 Update Flows (“Tap any category to update”)
Recommended mapping:
- **Monthly savings** → Profile modal (income/expense or monthlyInvestment)
- **Life insurance** → Profile modal (coverage)
- **Medical insurance** → Profile modal (coverage)
- **Emergency fund** → open/edit the `emergencySavings` asset (existing category)
- **Investments** → existing Assets flow (add/edit assets)

---

## 6) Data Gaps vs Your Desired Categories

Your desired breakdown:
- Real estate ✅ (already: `home`, `land`)
- Stocks ✅ (`stocks`)
- Fixed deposits ✅ (`fixedDeposits`)
- Recurring deposits ❌ (add category)
- Other assets ✅-ish (already: mutual funds, gold/silver, bonds, ESOP, PE, savings)

Action:
- Add `recurringDeposits` to `js/assetCategories.js` (value field like RD balance)
- Ensure `js/calculations.js#getAssetValue()` supports it

---

## 7) Export/Import (Don’t Lose Profile Data)

Today CSV export/import only handles **assets**.

MVP approach:
- Add **JSON export/import** for `{ assets, settings, profile }`
- Keep CSV as “assets-only” (backward-compatible)

---

## 8) Rollout Steps (Concrete Order)

1) Add profile storage (`js/storage.js`)
2) Add FI calculation functions (`js/calculations.js` or new service)
3) Add profile modal UI + save/load
4) Add FI section to Home dashboard + render values
5) Add “Next best step” card logic
6) Add `recurringDeposits` category (optional for first release)
7) Add JSON export/import (recommended before public release)

---

## 9) Open Questions (Decide Before Coding)

1) Do you want users to enter **income** or just **monthly investment**?
2) Should **primary home** count toward FI portfolio by default? (Most FI calculators exclude it.)
3) Should the app show FI in **today’s money** (real return) or nominal? (Doc assumes real.)
4) Should we support **liabilities** in v1? (Huge accuracy improvement.)


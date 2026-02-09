# Financial Freedom (FI) — Product Metrics + Formulas

This doc proposes a **simple, explainable** “Financial Freedom” model you can ship inside NetWorth. It focuses on:
- Showing **where the user is today**
- Showing **what’s left** (gap to targets)
- Showing the **one best next step** (not guilt/gamification)

> Not financial advice. These are educational heuristics with user-editable assumptions.

---

## 1) Core Idea (What “Financial Freedom” Means in the App)

**Financial Independence (FI)** = when **investable assets** can fund **annual expenses** indefinitely without active income.

The common product-friendly approximation:
- **FI Target (today’s money)**: `annualExpenses / SWR`
- Where **SWR** = safe withdrawal rate (default `0.04` → the “25× expenses” rule)

---

## 2) Data Model (Inputs)

### Onboarding inputs (you already planned)
- `ageYears`
- `monthlyIncome` (take-home; salary + other income if applicable)
- `monthlyExpenses`
- `dependentsCount`

### Category updates (home screen tiles)
- `emergencyFund` (liquid, safe, instantly accessible)
- `medicalInsurance` → `hasMedicalInsurance`, `medicalCoverAmount`
- `lifeInsurance` → `hasLifeInsurance`, `lifeCoverAmount`
- `investments`
  - `realEstateInvestments`
  - `stocks`
  - `fixedDeposits`
  - `recurringDeposits`
  - `otherInvestments`

### Optional (high value, still simple)
These make recommendations much more accurate:
- `liabilitiesTotal` (loans/credit cards)
- `existingLifeCoverAmount` (if multiple policies)
- `oneTimeGoalsTotal` (e.g., education fund) — optional
- `targetFIageYears` (default: `60`)
- `riskProfile` (Stable / Medium / Variable income) to set emergency target months

---

## 3) Assumptions (User-Editable Defaults)

Use **real returns** to keep everything in “today’s money” and avoid inflation complexity.

Defaults (India-friendly, but user-editable):
- `swr = 0.04` (conservative option: `0.035`)
- `nominalReturn = 0.10` (blended equity/debt long-run assumption)
- `inflation = 0.06`
- `realReturn = (1 + nominalReturn) / (1 + inflation) - 1`
- Monthly real rate: `i = (1 + realReturn)^(1/12) - 1`

---

## 4) Core Calculations (Formulas)

### 4.1 Monthly surplus + savings rate
```
monthlySurplus = monthlyIncome - monthlyExpenses
savingsRate = monthlySurplus / monthlyIncome
annualIncome = monthlyIncome * 12
```
Guardrails:
- if `monthlyIncome <= 0` → set `savingsRate = 0` and hide ratio UI.

### 4.2 Emergency fund target + status
Target months (simple default):
```
if dependentsCount == 0: emergencyTargetMonths = 3
else: emergencyTargetMonths = 6
```
Optionally adjust by risk profile:
- Stable income: 3–6
- Variable income: 9–12

Then:
```
emergencyTargetAmount = monthlyExpenses * emergencyTargetMonths
emergencyMonthsCovered = emergencyFund / monthlyExpenses
emergencyGapAmount = max(emergencyTargetAmount - emergencyFund, 0)
```

### 4.3 Investable portfolio (for FI)
Decide what counts as FI-eligible. A practical default:
```
investablePortfolio =
  realEstateInvestments +
  stocks +
  fixedDeposits +
  recurringDeposits +
  otherInvestments
```
Notes:
- Keep `emergencyFund` **separate** (shown as runway), or allow a toggle to include it.
- If you add liabilities later: `netInvestable = max(investablePortfolio - liabilitiesTotal, 0)`.

### 4.4 FI target (“FI Number”) + gap
```
annualExpenses = monthlyExpenses * 12
fiTarget = annualExpenses / swr
fiGap = max(fiTarget - investablePortfolio, 0)
fiProgress = clamp(investablePortfolio / fiTarget, 0, 1)
```

### 4.5 Time to FI at current monthly investing
Define how much of the surplus is actually invested:
```
monthlyInvestment = max(monthlySurplus, 0)
```
Then compute months to FI (closed-form; no iteration needed):

If `fiTarget <= investablePortfolio` → `monthsToFI = 0`

Else if `monthlyInvestment <= 0` → `monthsToFI = Infinity` (“Not on track”)

Else if `i == 0`:
```
monthsToFI = (fiTarget - investablePortfolio) / monthlyInvestment
```

Else:
```
monthsToFI =
  ln((fiTarget + monthlyInvestment / i) / (investablePortfolio + monthlyInvestment / i)) / ln(1 + i)
```

### 4.6 Required monthly investment to hit FI by a target age
```
targetMonths = max((targetFIageYears - ageYears) * 12, 0)
```

If `targetMonths == 0`:
- required is `0` if already FI, else “impossible” (show: “Increase timeline or income”)

If `i == 0`:
```
requiredMonthlyInvestment = max((fiTarget - investablePortfolio) / targetMonths, 0)
```

Else:
```
requiredMonthlyInvestment =
  max(i * (fiTarget - investablePortfolio * (1 + i)^targetMonths) / ((1 + i)^targetMonths - 1), 0)
```

Useful UI metrics:
```
onTrackRatio = (requiredMonthlyInvestment == 0)
  ? 1
  : clamp(monthlyInvestment / requiredMonthlyInvestment, 0, 1)

monthlyInvestmentGap = max(requiredMonthlyInvestment - monthlyInvestment, 0)
```

### 4.7 “Coast FI” milestone (great motivational metric)
Coast FI = you stop investing now; portfolio growth alone reaches FI by target age.
```
coastFIrequiredToday = fiTarget / (1 + i)^targetMonths
coastProgress = clamp(investablePortfolio / coastFIrequiredToday, 0, 1)
```

---

## 5) Insurance Coverage (Practical Product Heuristics)

Insurance is *risk protection*, not net worth. Treat it as a **separate “Protection” section** with a gap indicator.

### 5.1 Medical insurance
Minimum product rule:
- If `hasMedicalInsurance == false` → show “High risk: get medical cover”

If user enters a cover amount, compute a simple adequacy ratio using a configurable target:
```
medicalCoverTarget = max(annualExpenses, annualIncome)  // default; user-editable
medicalCoverRatio = clamp(medicalCoverAmount / medicalCoverTarget, 0, 1)
```
If you don’t want to guess targets, let users pick:
- “Basic / Standard / High” medical target presets.

### 5.2 Life insurance (only if dependents exist)
Minimum product rule:
- If `dependentsCount > 0` and `hasLifeInsurance == false` → show “High risk: term insurance needed”

For a simple (but explainable) target, offer two methods and pick the **max**:
1) **Income multiple** method:
```
lifeCoverTargetA = annualIncome * 10
```
2) **Expense replacement** method (until retirement):
```
yearsToRetirement = max(targetFIageYears - ageYears, 0)
lifeCoverTargetB = annualExpenses * yearsToRetirement
```
Then:
```
lifeCoverTarget = max(lifeCoverTargetA, lifeCoverTargetB)
lifeCoverRatio = clamp(lifeCoverAmount / lifeCoverTarget, 0, 1)
```
Optional improvements (if you add these inputs):
```
lifeCoverTarget =
  max(lifeCoverTargetA, lifeCoverTargetB)
  + liabilitiesTotal
  + oneTimeGoalsTotal
  - investablePortfolio
  - existingLifeCoverAmount
```
(Clamp at `>= 0`.)

---

## 6) One “Financial Freedom Score” (Meaningful, Not Gamified)

If you show a single score, make it:
- explainable (“what’s missing?”)
- stable month-to-month (avoid noisy swings)
- tied to actions (fix the biggest gap first)

### 6.1 Sub-scores (0–100)
```
scoreFI = fiProgress * 100
scoreEmergency = clamp(emergencyFund / emergencyTargetAmount, 0, 1) * 100

scoreMedical = hasMedicalInsurance ? (medicalCoverRatio * 100) : 0
scoreLife =
  (dependentsCount == 0) ? 100 :
  (hasLifeInsurance ? (lifeCoverRatio * 100) : 0)

scoreTrack = onTrackRatio * 100  // savings vs requiredMonthlyInvestment
```

### 6.2 Weighted score
Suggested weights (tuneable):
```
financialFreedomScore =
  0.40 * scoreFI +
  0.20 * scoreTrack +
  0.15 * scoreEmergency +
  0.10 * scoreMedical +
  0.15 * scoreLife
```

Why this works:
- It rewards **progress to FI** while still blocking “fake progress” (no insurance, no emergency fund).
- It’s personalized via `requiredMonthlyInvestment` (not a fixed “save 20%” rule).

---

## 7) “Next Best Step” Logic (What to Show on the Home Screen)

Show *one card* that tells the user the most important thing to do next.

Priority order (simple, effective):
1) If `emergencyFund < emergencyTargetAmount` → “Build emergency fund: +₹X remaining (Y months)”
2) If `hasMedicalInsurance == false` → “Get medical insurance”
3) If `dependentsCount > 0` and `hasLifeInsurance == false` → “Get term insurance”
4) If `monthlyInvestment < requiredMonthlyInvestment` → “Increase monthly investing by ₹X”
5) Else → “You’re on track. Optional: reduce FI date by investing +₹X”

Optional: show a “what moved my score” explanation after updates (trust-builder).

---

## 8) Worked Example (Numbers)

Assume:
- `ageYears = 30`, `targetFIageYears = 60`
- `monthlyIncome = ₹150,000`, `monthlyExpenses = ₹70,000`
- `dependentsCount = 2`
- `investablePortfolio = ₹1,500,000`
- `emergencyFund = ₹200,000`
- `hasLifeInsurance = true`, `lifeCoverAmount = ₹5,000,000`
- `hasMedicalInsurance = true`, `medicalCoverAmount = ₹1,000,000`
- `swr = 0.04`, `nominalReturn = 0.10`, `inflation = 0.06` → `realReturn ≈ 3.77%`

Key outputs:
- `monthlySurplus = ₹80,000`
- Emergency target (6 months): `₹420,000` → gap `₹220,000`
- FI target: `(₹70,000 * 12) / 0.04 = ₹21,000,000` (₹2.1 Cr)
- FI progress: `₹1.5M / ₹21M ≈ 7.1%`
- Time to FI at ₹80k/month investing: ~`14.5 years` (FI age ~`44–45`)

---

## 9) Implementation Notes (Practical)

- Keep all calculations in **monthly** units internally; convert to annual only for display.
- Always show **assumptions** (SWR, return, inflation) with an “Edit” link.
- Store user assumptions locally (privacy-first).
- Clamp ratios, guard divide-by-zero, and explicitly represent Infinity (e.g., `null` + label “Not on track”).

---

## 10) “Research Notes” (Why These Rules Exist)

Keep this section internal (or show a short tooltip version in-app).

- **FI target = expenses / SWR**: A popular rule of thumb uses `SWR = 4%` (often described as “25× expenses”). It comes from historical retirement withdrawal research and is widely used because it’s easy to explain.
- **Conservatism matters**: Early retirement, high inflation periods, taxes/fees, and bad market timing (“sequence risk”) can require a **lower SWR** (e.g., `3–3.5%`).
- **Emergency fund = 3–6 months**: A common personal-finance guideline to handle job loss/medical surprises without liquidating long-term investments at the wrong time.
- **Insurance ≠ investment**: The product should treat insurance as “risk protection completeness” rather than a wealth metric.

---

## 11) Saving Helpers (Product Ideas That Don’t Feel Naggy)

- **“On-track” target**: show `requiredMonthlyInvestment` and a single CTA: “Set an auto-transfer of ₹X/month”.
- **Impact preview**: show “If you invest +₹5,000/month, FI date moves earlier by ~Y months” (recompute `monthsToFI` with `monthlyInvestment + 5000`).
- **Step-up plan**: if user can’t hit the target, propose: “Increase investing by ₹X every 3 months” until on-track.
- **Monthly check-in**: one reminder per month: “Last update: <date>. Want to refresh numbers?”
- **Milestones**: show the next milestone only (Emergency fund complete → Coast FI → FI).

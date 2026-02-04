# NetWorth iOS — Future Features & Experiments

This backlog lists meaningful additions (no vanity “save more” nags) focused on wealth clarity, trust, and occasional engagement (monthly cadence).

## 0) Principles
- Privacy-first, on-device by default; cloud sync opt-in and transparent.
- Show only useful signals (net worth delta, drivers, risk coverage).
- Encourage **monthly check-ins**, not daily stickiness.

## 1) Coverage Gaps (Data Model)
- **Insurance**: add Life/Term, Health/Medical, Vehicle. Track coverage amount, premium, renewal date; exclude from net worth total but show “risk coverage” completeness.
- **Liabilities** (future): home loan, car loan, credit card; net worth = assets – liabilities (optional toggle).
- **Household mode**: allow a “Household” profile that aggregates two profiles (e.g., partner). Keep per-person visibility + combined view.
- **Non-financial big items**: keep “sofa/TV/etc.” optional under Personal Assets; default off so lists stay clean.

## 2) Signals & Scoring (must be meaningful)
- **Net Worth Momentum**: % change since last update; surface after each save (“+₹X / +Y% vs previous snapshot”).
- **Coverage Score (no gamification fluff)**: show % of recommended coverage met (life/health/vehicle). Never 0–100 “credit” style; just “At risk: +₹X more needed for family cover.”
- **Concentration Signal**: top 3 categories share of total; flag if one category >60% (“Consider balancing”).

## 3) Engagement Hooks (Monthly, not daily)
- **Monthly Check-in Reminder** (push/local): “Update assets? Last updated: <date>. Net worth change since then: +Y%.”
- **Post-save micro-feedback**: after user edits/adds, show delta card: “+₹X added; total now ₹Y; +Z% vs last month.”
- **Widget**: small/medium lock-screen / home-screen widget with net worth + last-updated + monthly delta.

## 4) Sync & Backup
- **iCloud Sync (opt-in)**: encrypted sync of assets/settings; show status + last sync timestamp.
- **CSV parity**: keep import/export compatible with PWA CSV; add household/person column when household ships.
- **Encrypted backup file**: optional .networthvault export for secure offline backup.

## 5) Navigation & Layout Experiments
- **Overview**: keep hero + categories + projection; add “Since last update” chip (delta).
- **Assets**: category-first (current), add filters for “Recently updated” and “Largest”.
- **Insurance tab (optional)**: if added, integrate under Settings or Assets > Protection.

## 6) Charts & Insights
- **Net Worth Trend**: timeline of snapshots (monthly roll-up).
- **Drivers**: bar showing top contributors to change (which categories moved most since last snapshot).
- **Projection clarity**: always show assumptions; let users tweak growth rates per category inline.

## 7) Notifications (opt-in, minimal)
- Monthly check-in.
- Renewal reminders for insurance (if enabled).
- Optional “sync failed” alert for iCloud.

## 8) Technical Tasks to Enable
- Snapshot store: save a net worth snapshot per save to compute deltas.
- Widget timeline provider fed by latest snapshot.
- iCloud: CloudKit container with encryption-at-rest + user-visible toggle.
- Household: support multiple profiles and a combined computed profile; keep CSV/import forward-compatible.

## 9) Nice-to-haves (later)
- Siri Shortcut: “What’s my net worth?” (reads latest snapshot).
- PDF/CSV export with delta summary.
- Quick Add from Spotlight App Shortcut.

## 10) Out of Scope (avoid)
- Guilt-trippy savings prompts.
- Social/leaderboards.
- Ads or tracking.

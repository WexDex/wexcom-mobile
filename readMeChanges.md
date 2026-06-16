# Wexcom Mobile — change log

Newest entries at the top. See [AGENTS.md](AGENTS.md) for how this file is maintained.

## Version index

| Version | Date | Type |
|---------|------|------|
| [Finance Analytics Depth](#unreleased--2026-06-16--minor) | 2026-06-16 | Minor |
| [Unreleased](#unreleased--2026-06-15--minor) | 2026-06-15 | Minor (polish backlog) |
| Finance UX Phase 2 | 2026-06-15 | Major |

---

## [Unreleased] — 2026-06-16 — Minor

**Summary:** In-depth Expenses & Gains analytics, flexible budget periods, subscription rolling warnings + badge counts.

**Plan:** Finance Analytics Depth

**In scope:**
- Enhanced period selector: This Week / This Month / Last Month / Custom date range on both Expenses and Gains tabs
- Stat row: Period total, Daily avg, Weekly avg cards
- Trend card: current period vs previous same-length window (↑/↓ %)
- Expenses vs Gains comparison bar with net balance
- Category breakdown list: amount + % fill bar per category, replaces plain FilterChip row
- Category detail sheet: mini chart + entry list per category (tap → filter, chevron → sheet)
- Top category highlight card
- Budget period per category: Weekly / Monthly / Custom N-day rolling window (schema v14 migration)
- Budget bar label shows the active window ("this week", "this month", "last Nd")
- Subscription rolling warning state: amber border + "Needs logging" chip when overdue
- "Due soon" chip when within `warnBeforeDays` window
- `warnBeforeDays` field added to subscription editor
- Per-subscription scheduled warning notifications via `NotificationService`
- Finance tab badge count (overdue + due-soon subscriptions) on bottom nav
- App icon badge count via `flutter_app_badger` (Android)
- DB schema bumped to v14 (new columns: `budget_period`, `budget_custom_days`, `warn_before_days`)

**Not in scope:**
- Cumulative chart, bulk delete, search/sort/quick-recategorize, recurring auto-repeat

---

## [Unreleased] — 2026-06-15 — Minor

**Summary:** Polish pass — wishlist edit, notification tap routing, unified wallet tab, subscription due reminders, rate history chart.

**Plan:** Polish backlog suggestions

**In scope:**
- Wishlist item edit (`updateWishlistItem` + UI)
- Notification taps navigate via go_router (`/settings`, `/finance`, etc.)
- Wallet tab shows net worth + savings goals; removed orphaned `WalletPreviewStrip`
- Daily subscription due/overdue reminder (tap → Finance → Wishlist & Subs)
- Exchange rate history sparkline on Tags → Currencies

**Not in scope:**
- iOS widget parity
- Budget overrun notifications
- Auto-log subscriptions on due date

---

## Finance UX Phase 2 — 2026-06-15 — Major

**Summary:** Unified foreign-currency entry, JSON backup reminders, expanded audit log, and subscriptions on the Wishlist tab.

**Plan:** Finance UX Phase 2

**In scope:**
- Shared `CurrencyAmountInput` on monetary forms (transactions, finance, wishlist, wallet)
- JSON backup reminder notifications + `lastJsonExportAt` tracking
- Broader `logAction` coverage + audit log filters (Finance, Wallet, Currency, Settings, Subscriptions)
- `subscription_items` table (schema v13), schedule helpers, CRUD, manual log → expense
- Wishlist tab split: Wishlist + Subscriptions; JSON v3 export/import for subscriptions

**Not in scope:**
- Auto-charge on due date
- Subscription due push notifications (added later in polish pass)
- Cross-wallet FX transfers
- iOS widgets

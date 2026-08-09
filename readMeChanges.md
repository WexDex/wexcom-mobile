# Wexcom Mobile — change log

Newest entries at the top. See [AGENTS.md](AGENTS.md) for how this file is maintained.

## [Unreleased] — 2026-08-07 — Major

**Summary:** New LAN-only Express + Electron cloud host (`cloud_host/`) with desktop UI, QR setup, and Flutter sync compatibility fix.

**Plan:** Express Electron Cloud Host

**In scope:**
- `cloud_host/` — Express server matching Dart `cloud_server` v2 API (snapshots, clients, v9 data routes)
- Electron UI: start/stop, settings, logs, QR code, Windows Firewall prompt, snapshot management
- `CloudSyncService` parses `latest_snapshot` / `snapshot` response objects
- Correct SQLite column names (`full_name`, `archived_at`) for data endpoints

**Not in scope:**
- Internet/public access, HTTPS, port forwarding
- Replacing Dart `cloud_server/` (kept as fallback)
- Periodic sync migration off legacy `SyncService`

## Version index

| Version | Date | Type |
|---------|------|------|
| [Finance System Overhaul](#unreleased--2026-08-06--major) | 2026-08-06 | Major |
| [Finance Analytics Depth](#unreleased--2026-06-16--minor) | 2026-06-16 | Minor |
| [Unreleased](#unreleased--2026-06-15--minor) | 2026-06-15 | Minor (polish backlog) |
| Finance UX Phase 2 | 2026-06-15 | Major |

---

## [Unreleased] — 2026-08-06 — Major

**Summary:** Account-linked expenses/gains with Pocket default, period-based history, quick logging, favorites, wallet history, sticky form sheets.

**Plan:** Finance System Overhaul

**In scope:**
- `accountId` on personal finance entries; auto wallet balance sync on add/edit/delete
- Rename default wallet Cash → Pocket (`wallet-cash`)
- Period filters: Last 7 days, Last week; history list follows selected period
- Analytics tracking start date (`financeTrackingStartAt`) — stats only, history unchanged
- Quick \| Full toggle in expense/gain drop-up (amount required; category + note optional in Quick)
- Personal finance favorites — one-tap chips
- Daily finance logging reminder notification + Settings toggle/time
- Full wallet account history screen (`/finance/wallet/:accountId`)
- Shared sticky-footer bottom sheet on all add/edit forms
- DB schema v15 (`personal_finance_favorites`, `notif_finance_daily_*`)

**Not in scope:**
- App UX Phase 2 (nav cleanup, global search, sync unification, ledger filter parity)

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

# Wexcom Mobile — change log

Newest entries at the top. See [AGENTS.md](AGENTS.md) for how this file is maintained.

## Version index

| Version | Date | Type |
|---------|------|------|
| [Unreleased](#unreleased--2026-06-15--minor) | 2026-06-15 | Minor (polish backlog) |
| Finance UX Phase 2 | 2026-06-15 | Major |

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

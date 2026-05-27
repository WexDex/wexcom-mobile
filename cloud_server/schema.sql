-- ============================================================
-- Wexcom Mobile — SQLite schema v9
-- Generated from lib/data/db/app_database.dart
-- All datetime columns stored as INTEGER (Unix ms since epoch).
-- Boolean columns stored as INTEGER with CHECK (col IN (0,1)).
-- ============================================================

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ── Clients ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clients (
  id                  TEXT    NOT NULL PRIMARY KEY,
  full_name           TEXT    NOT NULL,
  phone               TEXT,
  note                TEXT,
  external_ref        TEXT,
  tags_json           TEXT,
  source              TEXT    NOT NULL DEFAULT 'manual',
  last_interaction_at INTEGER,
  balance_minor       INTEGER NOT NULL,
  created_at          INTEGER NOT NULL,
  updated_at          INTEGER NOT NULL,
  archived_at         INTEGER
);
CREATE INDEX IF NOT EXISTS idx_clients_archived_at ON clients (archived_at);

-- ── Tags ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tags (
  id         TEXT    NOT NULL PRIMARY KEY,
  name       TEXT    NOT NULL,
  color_hex  TEXT    NOT NULL DEFAULT '#4F46E5',
  scope      TEXT    NOT NULL,   -- 'client' | 'transaction'
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- ── Client ↔ Tag junction ────────────────────────────────────
CREATE TABLE IF NOT EXISTS client_tags (
  id         TEXT    NOT NULL PRIMARY KEY,
  client_id  TEXT    NOT NULL REFERENCES clients(id),
  tag_id     TEXT    NOT NULL REFERENCES tags(id),
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_client_tags_client ON client_tags (client_id);

-- ── Ledger transactions ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS ledger_transactions (
  id                           TEXT    NOT NULL PRIMARY KEY,
  client_id                    TEXT    NOT NULL REFERENCES clients(id),
  amount_minor                 INTEGER NOT NULL,
  currency_code                TEXT    NOT NULL DEFAULT 'DZD',
  created_by                   TEXT    NOT NULL DEFAULT 'manual',
  channel                      TEXT    NOT NULL DEFAULT 'other',
  reference_no                 TEXT,
  effective_at                 INTEGER,
  attachments_count            INTEGER NOT NULL DEFAULT 0,
  is_settled                   INTEGER NOT NULL DEFAULT 0 CHECK (is_settled IN (0,1)),
  settled_at                   INTEGER,
  tx_type                      INTEGER NOT NULL,   -- 0=debt, 1=payment
  tx_status                    INTEGER NOT NULL,   -- 0=active, 1=settled, 2=cancelled
  posted_balance_before_minor  INTEGER NOT NULL,
  posted_balance_after_minor   INTEGER NOT NULL,
  cancel_balance_before_minor  INTEGER,
  cancel_balance_after_minor   INTEGER,
  created_at                   INTEGER NOT NULL,
  updated_at                   INTEGER NOT NULL,
  cancelled_at                 INTEGER,
  note                         TEXT,
  due_at                       INTEGER
);
CREATE INDEX IF NOT EXISTS idx_transactions_client_created
  ON ledger_transactions (client_id, created_at);

-- ── Transaction ↔ Tag junction ───────────────────────────────
CREATE TABLE IF NOT EXISTS transaction_tags (
  id             TEXT    NOT NULL PRIMARY KEY,
  transaction_id TEXT    NOT NULL REFERENCES ledger_transactions(id),
  tag_id         TEXT    NOT NULL REFERENCES tags(id),
  created_at     INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_tx_tags_tx ON transaction_tags (transaction_id);

-- ── Transaction templates ────────────────────────────────────
CREATE TABLE IF NOT EXISTS transaction_templates (
  id            TEXT    NOT NULL PRIMARY KEY,
  label         TEXT    NOT NULL,
  amount_minor  INTEGER NOT NULL,
  tx_type       INTEGER NOT NULL,
  currency_code TEXT    NOT NULL DEFAULT 'DZD',
  note          TEXT,
  created_at    INTEGER NOT NULL
);

-- ── Quick-action usage counters ───────────────────────────────
CREATE TABLE IF NOT EXISTS quick_action_usages (
  id           TEXT    NOT NULL PRIMARY KEY,
  tx_type      INTEGER NOT NULL,
  amount_minor INTEGER NOT NULL,
  uses_count   INTEGER NOT NULL DEFAULT 0,
  last_used_at INTEGER NOT NULL
);

-- ── Audit log ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
  id          TEXT    NOT NULL PRIMARY KEY,
  action      TEXT    NOT NULL,   -- create_tx, cancel_tx, settle_tx, archive_client …
  entity_type TEXT    NOT NULL,   -- 'transaction' | 'client'
  entity_id   TEXT    NOT NULL,
  detail      TEXT,               -- JSON snapshot
  created_at  INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log (created_at);

-- ── Personal finance entries ──────────────────────────────────
CREATE TABLE IF NOT EXISTS personal_finance_entries (
  id            TEXT    NOT NULL PRIMARY KEY,
  kind          INTEGER NOT NULL,   -- 0=expense, 1=gain
  title         TEXT    NOT NULL,
  amount_minor  INTEGER NOT NULL,
  currency_code TEXT    NOT NULL DEFAULT 'DZD',
  note          TEXT,
  category_id   TEXT,               -- FK → expense_categories(id), nullable
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_personal_finance_kind_created
  ON personal_finance_entries (kind, created_at);

-- ── Expense / gain categories  (v9) ──────────────────────────
CREATE TABLE IF NOT EXISTS expense_categories (
  id                    TEXT    NOT NULL PRIMARY KEY,
  name                  TEXT    NOT NULL,
  color_hex             TEXT    NOT NULL DEFAULT '#22C55E',
  icon_code_point       INTEGER NOT NULL,
  budget_minor_per_month INTEGER,              -- NULL = no budget
  scope                 TEXT    NOT NULL,      -- 'expense' | 'gain'
  created_at            INTEGER NOT NULL
);

-- ── Wishlist items  (v9) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS wishlist_items (
  id            TEXT    NOT NULL PRIMARY KEY,
  title         TEXT    NOT NULL,
  amount_minor  INTEGER NOT NULL,
  currency_code TEXT    NOT NULL DEFAULT 'DZD',
  note          TEXT,
  category_id   TEXT,                          -- FK → expense_categories(id)
  is_purchased  INTEGER NOT NULL DEFAULT 0 CHECK (is_purchased IN (0,1)),
  created_at    INTEGER NOT NULL,
  purchased_at  INTEGER
);

-- ── Wallet accounts  (v9) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallet_accounts (
  id            TEXT    NOT NULL PRIMARY KEY,
  name          TEXT    NOT NULL,
  emoji         TEXT    NOT NULL DEFAULT '💵',
  balance_minor INTEGER NOT NULL DEFAULT 0,
  sort_order    INTEGER NOT NULL DEFAULT 0,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);

-- ── Savings goals  (v9) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS savings_goals (
  id            TEXT    NOT NULL PRIMARY KEY,
  name          TEXT    NOT NULL,
  emoji         TEXT    NOT NULL DEFAULT '🎯',
  target_minor  INTEGER NOT NULL,
  saved_minor   INTEGER NOT NULL DEFAULT 0,
  note          TEXT,
  deadline      INTEGER,
  is_completed  INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0,1)),
  created_at    INTEGER NOT NULL
);

-- ── App settings (single-row) ─────────────────────────────────
CREATE TABLE IF NOT EXISTS app_settings (
  id                              INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
  default_currency_code           TEXT    NOT NULL DEFAULT 'DZD',
  contacts_autofill_enabled       INTEGER NOT NULL DEFAULT 1 CHECK (contacts_autofill_enabled IN (0,1)),
  overdue_alert_days              INTEGER NOT NULL DEFAULT 10,
  profile_name                    TEXT,
  sync_enabled                    INTEGER NOT NULL DEFAULT 0 CHECK (sync_enabled IN (0,1)),
  sync_server_url                 TEXT,
  sync_username                   TEXT,
  sync_password                   TEXT,
  sync_interval_hours             INTEGER NOT NULL DEFAULT 24,
  sync_periodic_enabled           INTEGER NOT NULL DEFAULT 0 CHECK (sync_periodic_enabled IN (0,1)),
  last_upload_at                  INTEGER,
  last_upload_sha256              TEXT,
  last_download_at                INTEGER,
  last_server_ok_at               INTEGER,
  notif_overdue_enabled           INTEGER NOT NULL DEFAULT 0 CHECK (notif_overdue_enabled IN (0,1)),
  notif_overdue_hour              INTEGER NOT NULL DEFAULT 9,
  notif_balance_milestone_enabled INTEGER NOT NULL DEFAULT 0 CHECK (notif_balance_milestone_enabled IN (0,1)),
  notif_balance_milestone_minor   INTEGER NOT NULL DEFAULT 100000,
  notif_inactivity_enabled        INTEGER NOT NULL DEFAULT 0 CHECK (notif_inactivity_enabled IN (0,1)),
  notif_inactivity_days           INTEGER NOT NULL DEFAULT 7,
  notif_sync_enabled              INTEGER NOT NULL DEFAULT 0 CHECK (notif_sync_enabled IN (0,1))
);

-- ── Default app settings row ──────────────────────────────────
INSERT OR IGNORE INTO app_settings (id) VALUES (1);

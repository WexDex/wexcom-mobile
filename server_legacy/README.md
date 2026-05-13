# Wexcom Sync Server - Full Setup and Database Guide

This folder contains an optional sync server for `wexcom-mobile`.
The mobile app remains offline-first, and this server is used only when you want
to back up/sync exported data through HTTP.

## What this server does

- Accepts full export uploads from the app.
- Stores each raw upload as a snapshot in SQLite.
- Maintains a latest "mirror" view for fast reads (`/all` and `/client/:id`).
- Requires Basic Auth for protected endpoints.

## Requirements

- Dart SDK `3.9+`
- Windows CMD or PowerShell
- A strong username/password for Basic Auth

## Quick start (Windows)

From `server/`:

### Use a `.env` file (recommended)

1. Copy template:

```powershell
copy .env.example .env
```

2. Edit `.env` and set strong values:

```env
WEXCOM_USER=wexcom
WEXCOM_PASS=yourStrongPassword
WEXCOM_PORT=8787
WEXCOM_TUNNEL_HOST=localhost
WEXCOM_TUNNEL_MODE=named
WEXCOM_TUNNEL_NAME=wexcom
WEXCOM_TUNNEL_DOMAIN=wexcom.wexdex.online
```

3. Start with:

```bat
run.bat
```

`run.bat` auto-loads `.env` if present.
If port `8787` is busy, set `WEXCOM_PORT=8788` (or any free port).

### Access from different networks (Cloudflare tunnel)

Use a second terminal in `server/` while `run.bat` is running:

```bat
run_tunnel.bat
```

By default, `run_tunnel.bat` now uses a named tunnel and expects:

- local origin: `http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT%` (defaults to `http://localhost:8787`)
- hostname: `https://%WEXCOM_TUNNEL_DOMAIN%` (defaults to `https://wexcom.wexdex.online`)

To force temporary quick tunnels, set:

```env
WEXCOM_TUNNEL_MODE=quick
```

Then `run_tunnel.bat` falls back to random `*.trycloudflare.com` URLs.

### Example: run server from `server/`

#### PowerShell (copy/paste)

```powershell
cd E:\Projects\wexcom-mobile\server
$env:WEXCOM_USER = "wexcom"
$env:WEXCOM_PASS = "MyStrongPass123!"
dart pub get
dart run bin/server.dart --host 0.0.0.0 --port 8787 --db ".\wexcom-server.sqlite"
```

Expected output:

```text
Listening on http://0.0.0.0:8787
```

Quick test from another terminal:

```powershell
curl.exe -u wexcom:MyStrongPass123! http://localhost:8787/status
```

#### CMD (copy/paste)

```bat
cd /d E:\Projects\wexcom-mobile\server
set WEXCOM_USER=wexcom
set WEXCOM_PASS=MyStrongPass123!
dart pub get
dart run bin/server.dart --host 0.0.0.0 --port 8787 --db ".\wexcom-server.sqlite"
```

### Option 1: run manually (recommended first run)

#### CMD

```bat
set WEXCOM_USER=wexcom
set WEXCOM_PASS=yourStrongPassword
dart pub get
dart run bin/server.dart --host 0.0.0.0 --port 8787 --db ".\wexcom-server.sqlite"
```

#### PowerShell

```powershell
$env:WEXCOM_USER = "wexcom"
$env:WEXCOM_PASS = "yourStrongPassword"
dart pub get
dart run bin/server.dart --host 0.0.0.0 --port 8787 --db ".\wexcom-server.sqlite"
```

### Option 2: use the batch script

```bat
run.bat
```

`run.bat` loads `.env` (if present), defaults `WEXCOM_USER` to `wexcom`, and fails if `WEXCOM_PASS` is not set.

## Server CLI flags

`bin/server.dart` supports:

- `--host` (default: `0.0.0.0`)
- `--port` (default: `8787`)
- `--db` (default: `./wexcom-server.sqlite`)
- `--user` (default: `wexcom`, overridden by `WEXCOM_USER` if set)
- `--pass` (or set `WEXCOM_PASS`)
- `-v`, `--version`

If either username or password is missing, startup fails.

## Health check and endpoints

Base URL example: `http://localhost:8787`

- `GET /status`
  - Returns server/snapshot metadata and whether your local client hash matches.
  - Can accept `?clientSha256=<sha>` to compare with latest server snapshot hash.
- `POST /upload`
  - Body must be full export JSON payload.
  - Optional header: `x-device-name`.
- `GET /download/:id`
  - Returns raw JSON snapshot by ID.
  - Use `latest` as ID to fetch most recent snapshot.
- `GET /client/:clientId`
  - Returns single-client payload from mirror tables.
- `GET /all`
  - Returns all mirrored clients with transactions/tags.

Auth: all endpoints are protected by Basic Auth middleware.

## Database file location

By default, DB file is created at:

- `server/wexcom-server.sqlite`

You can move it anywhere by passing `--db <path>`.

## Database schema (SQLite)

The server auto-creates these tables:

### 1) `snapshots`

Stores every raw uploaded JSON payload.

```sql
CREATE TABLE IF NOT EXISTS snapshots (
  id TEXT PRIMARY KEY,
  uploaded_at TEXT NOT NULL,
  device_name TEXT,
  size_bytes INTEGER NOT NULL,
  sha256 TEXT NOT NULL,
  raw_json TEXT NOT NULL
);
```

### 2) `mirror_clients`

Latest client mirror (replaced on each upload).

```sql
CREATE TABLE IF NOT EXISTS mirror_clients (
  source_client_id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  note TEXT,
  source TEXT,
  created_at TEXT,
  last_interaction_at TEXT,
  archived_at TEXT,
  last_upload_id TEXT NOT NULL
);
```

### 3) `mirror_transactions`

Latest transaction mirror (replaced on each upload).

```sql
CREATE TABLE IF NOT EXISTS mirror_transactions (
  tx_id TEXT PRIMARY KEY,
  source_client_id TEXT NOT NULL,
  amount_minor INTEGER NOT NULL,
  currency_code TEXT,
  tx_type INTEGER NOT NULL,
  tx_status INTEGER NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL,
  effective_at TEXT,
  last_upload_id TEXT NOT NULL
);
```

### 4) `mirror_tags`

Unique tag catalog by `(name, scope)`.

```sql
CREATE TABLE IF NOT EXISTS mirror_tags (
  name TEXT NOT NULL,
  scope TEXT NOT NULL,
  color_hex TEXT,
  last_upload_id TEXT NOT NULL,
  PRIMARY KEY(name, scope)
);
```

### 5) `mirror_client_tags`

Client-to-tag links for latest upload.

```sql
CREATE TABLE IF NOT EXISTS mirror_client_tags (
  source_client_id TEXT NOT NULL,
  tag_name TEXT NOT NULL,
  scope TEXT NOT NULL,
  color_hex TEXT,
  last_upload_id TEXT NOT NULL
);
```

### 6) `mirror_transaction_tags`

Transaction-to-tag links for latest upload.

```sql
CREATE TABLE IF NOT EXISTS mirror_transaction_tags (
  tx_id TEXT NOT NULL,
  tag_name TEXT NOT NULL,
  scope TEXT NOT NULL,
  color_hex TEXT,
  last_upload_id TEXT NOT NULL
);
```

### Indexes

```sql
CREATE INDEX IF NOT EXISTS idx_snapshots_uploaded_at
ON snapshots(uploaded_at DESC);

CREATE INDEX IF NOT EXISTS idx_mirror_tx_client_effective_created
ON mirror_transactions(source_client_id, effective_at, created_at);
```

## How mirroring works

When a new upload arrives:

1. A new row is inserted into `snapshots` with raw JSON and SHA-256.
2. All mirror tables are cleared.
3. Latest payload is reinserted into `mirror_*` tables.

This makes `/all` and `/client/:id` always reflect the latest successful upload.

## DB viewer options

### Option A: SQLite command line (quick inspection)

If `sqlite3` CLI is installed:

```powershell
sqlite3 .\wexcom-server.sqlite
```

Inside the shell:

```sql
.tables
SELECT COUNT(*) FROM snapshots;
SELECT id, uploaded_at, device_name, size_bytes FROM snapshots ORDER BY uploaded_at DESC LIMIT 10;
SELECT source_client_id, full_name FROM mirror_clients LIMIT 20;
```

Exit with:

```sql
.quit
```

### Option B: DB Browser for SQLite (GUI)

1. Install **DB Browser for SQLite**.
2. Open `server/wexcom-server.sqlite`.
3. Use **Browse Data** to inspect `snapshots` and `mirror_*` tables.
4. Use **Execute SQL** for custom queries.

Tip: if the server is running and writing often, close long-running edit sessions in the GUI to avoid lock conflicts.

## Optional: expose server over Cloudflare Tunnel

### Named hostname (`wexcom.wexdex.online`) - recommended

1. Add `wexdex.online` to Cloudflare.
2. At Hostinger, replace nameservers with the two nameservers shown by Cloudflare.
3. Wait until Cloudflare marks the zone as **Active**.

Then run:

```powershell
cloudflared tunnel login
cloudflared tunnel create wexcom
cloudflared tunnel route dns wexcom wexcom.wexdex.online
cloudflared tunnel run --url http://localhost:8787 wexcom
```

Or run the one-shot helper:

```bat
setup_domain_tunnel.bat
```

Expected public endpoints:

- `https://wexcom.wexdex.online/status`
- `https://wexcom.wexdex.online/api`

You can also use the batch helper:

```bat
run_tunnel.bat
```

Optional config template:

- Copy `server/cloudflared.config.example.yml` to `%USERPROFILE%\.cloudflared\config.yml`
- Adjust hostname/service if needed.

### Temporary URL (fallback)

```powershell
cloudflared tunnel --url http://localhost:8787
```

### Named tunnel commands (reference)

```powershell
cloudflared tunnel login
cloudflared tunnel create wexcom
cloudflared tunnel route dns wexcom wexcom.wexdex.online
cloudflared tunnel run --url http://localhost:8787 wexcom
```

Set the resulting tunnel URL/hostname in app sync settings.

## Security checklist

- Use a strong `WEXCOM_PASS`.
- Do not commit credentials.
- Prefer HTTPS via Cloudflare tunnel instead of opening raw router ports.
- Rotate credentials if leaked/shared.

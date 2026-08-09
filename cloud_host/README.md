# Wexcom Cloud Host

LAN-only desktop backup server for Wexcom Mobile. Express API + Electron UI.

## Quick start (development)

```bat
cd cloud_host
npm install
npm start
```

The window opens. Click **Start server**, scan the QR code on your phone (same Wi‑Fi), then in Flutter **Settings → Cloud sync** enter the URL and credentials.

Default credentials: `admin` / `changeme` — change them in the app before syncing.

## Build Windows exe

```bat
npm run dist
```

Output: `release/Wexcom Cloud Host Setup *.exe` and portable build.

## API

Same endpoints as [`../cloud_server/`](../cloud_server/) v2:

- `GET /ping` (public)
- `GET /status`, `POST /upload`, `GET /download`, `GET /snapshots`, etc.
- HTTP Basic Auth on protected routes

Server binds `0.0.0.0:8787` by default (LAN accessible).

## Flutter connection

1. PC and phone on the **same Wi‑Fi**
2. Start server in the desktop app
3. Allow Windows Firewall when prompted (first start)
4. Scan QR or copy `http://192.168.x.x:8787`
5. In Flutter Settings: paste URL, username, password
6. Test connection → Upload / Download

## Data location

Snapshots stored in `{dataDir}/snapshots/` (configurable in Settings). Default data dir is under `%APPDATA%/wexcom-cloud-host/data`.

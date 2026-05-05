# Wexcom Optional Sync Server

This server is optional and keeps the app offline-first. You can run it on your PC when needed.

## 1) Requirements

- Dart SDK 3.9+
- A username/password pair for basic auth

## 2) Start locally

From `server/`:

```powershell
set WEXCOM_USER=wexcom
set WEXCOM_PASS=yourStrongPassword
dart pub get
dart run bin/server.dart --host 0.0.0.0 --port 8787 --db .\wexcom-server.sqlite
```

Or use:

```powershell
run.bat
```

## 3) Endpoints

- `POST /upload` - upload full export JSON
- `GET /download/:id` - download snapshot JSON (`latest` supported)
- `GET /client/:clientId` - latest mirrored single-client payload
- `GET /all` - latest mirrored full payload
- `GET /status` - health and latest upload metadata

All endpoints require Basic Auth except `/status?ping=1`.

## 4) Cloudflare Tunnel

### Option A: Quick temporary URL

```powershell
cloudflared tunnel --url http://localhost:8787
```

### Option B: Stable hostname

```powershell
cloudflared tunnel login
cloudflared tunnel create wexcom
cloudflared tunnel route dns wexcom sync.yourdomain.com
cloudflared tunnel run --url http://localhost:8787 wexcom
```

Put your tunnel URL/hostname into the app sync settings as server URL.

## 5) Security notes

- Always set a strong `WEXCOM_PASS`.
- Prefer Cloudflare HTTPS hostname over exposing direct ports.
- Rotate credentials if shared or leaked.

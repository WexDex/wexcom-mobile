# Wexcom Cloud Server

Simple backup server for Wexcom Mobile. Run it on your PC whenever you want cloud sync available.

## Quick start

```bat
:: 1. Get dependencies (once)
dart pub get

:: 2. Compile to exe (once)
dart compile exe bin/server.dart -o cloud_server.exe

:: 3. Edit start.bat and set your credentials, then:
start.bat
```

The server listens on **port 8787** by default. Make sure your router forwards port 8787 to this machine, and that `wexcom.wexdex.online` points to your home IP.

## Credentials

Set via environment variables (recommended) or in `start.bat`:

| Env var | Default | Purpose |
|---|---|---|
| `WEXCOM_USER` | `admin` | Basic Auth username |
| `WEXCOM_PASS` | `changeme` | Basic Auth password |

**Always change the defaults before exposing to the internet.**

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/status` | Server health + last backup info |
| POST | `/upload` | Upload SQLite file (`multipart/form-data`, field `db_file`) |
| GET | `/download` | Download the stored SQLite backup |

All endpoints require Basic Auth.

## Files created

- `wexcom-server.sqlite` — the stored database backup (same folder as where you run the exe)

## Stop the server

Just close the terminal window or press Ctrl+C.

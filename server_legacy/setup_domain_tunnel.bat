@echo off
setlocal

if exist ".env" (
  for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    if not "%%A"=="" (
      if not "%%A:~0,1"=="#" (
        set "%%A=%%B"
      )
    )
  )
)

if "%WEXCOM_PORT%"=="" set WEXCOM_PORT=8787
if "%WEXCOM_TUNNEL_NAME%"=="" set WEXCOM_TUNNEL_NAME=wexcom
if "%WEXCOM_TUNNEL_DOMAIN%"=="" set WEXCOM_TUNNEL_DOMAIN=wexcom.wexdex.online
if "%WEXCOM_TUNNEL_HOST%"=="" set WEXCOM_TUNNEL_HOST=127.0.0.1

where cloudflared >nul 2>&1
if errorlevel 1 (
  echo cloudflared was not found in PATH.
  echo Install from:
  echo https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
  exit /b 1
)

echo.
echo [1/4] Cloudflare login
echo If browser does not open, copy the URL shown by cloudflared and open it manually.
cloudflared tunnel login
if errorlevel 1 (
  echo Login failed.
  exit /b 2
)

echo.
echo [2/4] Create named tunnel "%WEXCOM_TUNNEL_NAME%" if missing
cloudflared tunnel info "%WEXCOM_TUNNEL_NAME%" >nul 2>&1
if errorlevel 1 (
  cloudflared tunnel create "%WEXCOM_TUNNEL_NAME%"
  if errorlevel 1 (
    echo Tunnel creation failed.
    exit /b 3
  )
) else (
  echo Tunnel already exists.
)

echo.
echo [3/4] Route DNS hostname "%WEXCOM_TUNNEL_DOMAIN%"
cloudflared tunnel route dns "%WEXCOM_TUNNEL_NAME%" "%WEXCOM_TUNNEL_DOMAIN%"
if errorlevel 1 (
  echo DNS route failed.
  echo Confirm that:
  echo - Your domain is active in Cloudflare.
  echo - Nameservers at Hostinger were changed to Cloudflare nameservers.
  exit /b 4
)

echo.
echo [4/4] Quick endpoint checks
echo Checking HTTPS endpoints...
curl.exe -k -s -o nul -w "status: %%{http_code}\n" "https://%WEXCOM_TUNNEL_DOMAIN%/status"
curl.exe -k -s -o nul -w "api: %%{http_code}\n" "https://%WEXCOM_TUNNEL_DOMAIN%/api"

echo.
echo Setup finished.
echo Start the tunnel anytime with:
echo   run_tunnel.bat
echo.
echo Expected URL:
echo   https://%WEXCOM_TUNNEL_DOMAIN%/api
exit /b 0

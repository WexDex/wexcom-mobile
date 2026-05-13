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
if "%WEXCOM_TUNNEL_HOST%"=="" set WEXCOM_TUNNEL_HOST=127.0.0.1
if "%WEXCOM_TUNNEL_MODE%"=="" set WEXCOM_TUNNEL_MODE=named
if "%WEXCOM_TUNNEL_NAME%"=="" set WEXCOM_TUNNEL_NAME=wexcom
if "%WEXCOM_TUNNEL_DOMAIN%"=="" set WEXCOM_TUNNEL_DOMAIN=wexcom.wexdex.online

powershell -NoProfile -Command "$ok=$false;try{$c=New-Object Net.Sockets.TcpClient;$a=$c.BeginConnect('%WEXCOM_TUNNEL_HOST%',[int]%WEXCOM_PORT%,$null,$null);$ok=$a.AsyncWaitHandle.WaitOne(1500,$false);if($ok){$c.EndConnect($a)};$c.Close()}catch{};if($ok){exit 0}else{exit 1}" >nul 2>&1
if errorlevel 1 (
  echo Origin http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT% is not reachable.
  echo Start the sync server first ^(run.bat^), then retry this tunnel script.
  exit /b 2
)

where cloudflared >nul 2>&1
if errorlevel 1 (
  echo cloudflared was not found in PATH.
  echo Install it first: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
  pause
  exit /b 1
)

if /I "%WEXCOM_TUNNEL_MODE%"=="quick" (
  echo Starting Cloudflare quick tunnel to http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT% ...
  echo Keep this window open while tunnel is active.
  echo.
  cloudflared tunnel --url http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT%
  set EXIT_CODE=%ERRORLEVEL%
  goto :end
)

echo Preparing named tunnel "%WEXCOM_TUNNEL_NAME%" for https://%WEXCOM_TUNNEL_DOMAIN% ...
cloudflared tunnel info "%WEXCOM_TUNNEL_NAME%" >nul 2>&1
set "INFO_EXIT=%ERRORLEVEL%"
if not "%INFO_EXIT%"=="0" (
  echo Named tunnel "%WEXCOM_TUNNEL_NAME%" was not found.
  echo Run these once, then retry:
  echo   cloudflared tunnel login
  echo   cloudflared tunnel create %WEXCOM_TUNNEL_NAME%
  echo   cloudflared tunnel route dns %WEXCOM_TUNNEL_NAME% %WEXCOM_TUNNEL_DOMAIN%
  exit /b 3
)

set "ROUTE_DNS_LOG=%TEMP%\wexcom_route_dns_%RANDOM%.log"
set "ROUTE_DNS_HEAD=(no output)"
cloudflared tunnel route dns "%WEXCOM_TUNNEL_NAME%" "%WEXCOM_TUNNEL_DOMAIN%" >"%ROUTE_DNS_LOG%" 2>&1
set "ROUTE_EXIT=%ERRORLEVEL%"
for /f "usebackq delims=" %%L in ("%ROUTE_DNS_LOG%") do (
  set "ROUTE_DNS_HEAD=%%L"
  goto :route_dns_head_done
)
:route_dns_head_done
set "ROUTE_ALREADY_EXISTS=0"
powershell -NoProfile -Command "$txt=''; try { $txt=Get-Content -Path '%ROUTE_DNS_LOG%' -Raw -ErrorAction Stop } catch {}; if ($txt -match 'code:\s*1003' -and $txt -match 'record with that host already exists') { exit 0 } else { exit 1 }" >nul 2>&1
if not errorlevel 1 set "ROUTE_ALREADY_EXISTS=1"
if exist "%ROUTE_DNS_LOG%" del /q "%ROUTE_DNS_LOG%" >nul 2>&1
if not "%ROUTE_EXIT%"=="0" if not "%ROUTE_ALREADY_EXISTS%"=="1" (
  echo DNS route check failed for %WEXCOM_TUNNEL_DOMAIN%.
  echo cloudflared output: %ROUTE_DNS_HEAD%
  echo Make sure your domain is managed in Cloudflare and retry:
  echo   cloudflared tunnel route dns %WEXCOM_TUNNEL_NAME% %WEXCOM_TUNNEL_DOMAIN%
  exit /b 4
)
if "%ROUTE_ALREADY_EXISTS%"=="1" (
  echo DNS route already exists for %WEXCOM_TUNNEL_DOMAIN%. Continuing...
)

echo Starting named Cloudflare tunnel for https://%WEXCOM_TUNNEL_DOMAIN% ...
echo Keep this window open while tunnel is active.
echo Docs URL: https://%WEXCOM_TUNNEL_DOMAIN%/api
echo.

echo Cleaning up stale connectors for "%WEXCOM_TUNNEL_NAME%" ...
cloudflared tunnel cleanup "%WEXCOM_TUNNEL_NAME%" >nul 2>&1
set "CLEANUP_EXIT=%ERRORLEVEL%"

if "%WEXCOM_TUNNEL_PROTOCOL%"=="" set WEXCOM_TUNNEL_PROTOCOL=http2

cloudflared tunnel run --protocol %WEXCOM_TUNNEL_PROTOCOL% --url http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT% "%WEXCOM_TUNNEL_NAME%"
set EXIT_CODE=%ERRORLEVEL%

:end
if not "%EXIT_CODE%"=="0" (
  echo.
  echo Tunnel stopped with exit code %EXIT_CODE%.
  pause
)
exit /b %EXIT_CODE%



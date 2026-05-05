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

echo Starting Cloudflare quick tunnel to http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT% ...
echo Keep this window open while tunnel is active.
echo.
cloudflared tunnel --url http://%WEXCOM_TUNNEL_HOST%:%WEXCOM_PORT%
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
  echo.
  echo Tunnel stopped with exit code %EXIT_CODE%.
  pause
)
exit /b %EXIT_CODE%

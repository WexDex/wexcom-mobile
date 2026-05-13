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

if "%WEXCOM_USER%"=="" set WEXCOM_USER=wexcom
if "%WEXCOM_PASS%"=="" (
  echo Please set WEXCOM_PASS before starting the server.
  echo Example: add WEXCOM_PASS to .env or run:
  echo   set WEXCOM_PASS=yourStrongPassword
  exit /b 1
)
if "%WEXCOM_PORT%"=="" set WEXCOM_PORT=8787

if not exist ".dart_tool\package_config.json" (
  echo First run detected - resolving Dart dependencies...
  dart pub get
  if errorlevel 1 (
    echo Failed to resolve dependencies.
    pause
    exit /b 1
  )
)

echo Starting Wexcom sync server on http://0.0.0.0:%WEXCOM_PORT% ...
dart run bin/server.dart --host 0.0.0.0 --port %WEXCOM_PORT% --db ".\wexcom-server.sqlite"
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
  echo.
  echo If the port is already in use, set WEXCOM_PORT in .env (example: WEXCOM_PORT=8788).
  echo Server stopped with exit code %EXIT_CODE%.
  pause
)
exit /b %EXIT_CODE%

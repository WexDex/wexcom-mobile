@echo off
setlocal

if "%WEXCOM_USER%"=="" set WEXCOM_USER=wexcom
if "%WEXCOM_PASS%"=="" (
  echo Please set WEXCOM_PASS before starting the server.
  echo Example: set WEXCOM_PASS=yourStrongPassword
  exit /b 1
)

dart pub get
if errorlevel 1 exit /b 1

dart run bin/server.dart --host 0.0.0.0 --port 8787 --db ".\wexcom-server.sqlite"

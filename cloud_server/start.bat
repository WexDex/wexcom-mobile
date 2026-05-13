@echo off
title Wexcom Cloud Server

:: Set your credentials here (or use environment variables)
if "%WEXCOM_USER%"=="" set WEXCOM_USER=admin
if "%WEXCOM_PASS%"=="" set WEXCOM_PASS=wexpass

:: Check if compiled exe exists, otherwise run via dart
if exist cloud_server.exe (
    cloud_server.exe --port 8787
) else (
    echo [INFO] Compiled exe not found, running via dart run...
    dart run bin/server.dart --port 8787
)

pause

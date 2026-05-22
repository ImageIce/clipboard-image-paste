@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "HELPER=%LOCALAPPDATA%\ClipboardImagePaste\clipboard-image-save.exe"
set "FEATURES=%LOCALAPPDATA%\ClipboardImagePaste\clipboard-image-save.features"

if exist "%HELPER%" if exist "%FEATURES%" (
  findstr /x /i "hotkey-running" "%FEATURES%" >nul 2>nul
  if not errorlevel 1 (
  "%HELPER%" --hotkey-running >nul 2>nul
  if not errorlevel 1 (
    echo Clipboard image paste hotkey already running.
    exit /b 0
  )
  )
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%start-hotkey.ps1"
exit /b %ERRORLEVEL%

@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "HELPER=%LOCALAPPDATA%\ClipboardImagePaste\clipboard-image-save.exe"
set "FORMAT=at-path"
set "HELPER_EXTRA="
set "POWERSHELL_EXTRA="

if not "%~1"=="" set "FORMAT=%~1"
if /I "%~2"=="--no-clipboard" (
  set "HELPER_EXTRA=--no-clipboard"
  set "POWERSHELL_EXTRA=-NoClipboard"
)

if exist "%HELPER%" (
  "%HELPER%" --format "%FORMAT%" %HELPER_EXTRA%
  exit /b %ERRORLEVEL%
)

powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File "%SCRIPT_DIR%paste-clipboard-image.ps1" -Format "%FORMAT%" %POWERSHELL_EXTRA%
exit /b %ERRORLEVEL%

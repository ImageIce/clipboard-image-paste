[CmdletBinding()]
param(
    [switch]$StartNow
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startupDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
if (-not $startupDir) {
    throw "Could not resolve the current user's Startup folder."
}

$buildScript = Join-Path $PSScriptRoot "build-clipboard-helper.ps1"
if (Test-Path -LiteralPath $buildScript -PathType Leaf) {
    try {
        & $buildScript | ForEach-Object { Write-Output "Built fast clipboard helper: $_" }
    }
    catch {
        Write-Warning "Fast clipboard helper build failed; the PowerShell fallback will still work. $($_.Exception.Message)"
    }
}

$startScript = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "start-hotkey.ps1")).ProviderPath
$powershellPath = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
if (-not (Test-Path -LiteralPath $powershellPath -PathType Leaf)) {
    $powershellCommand = Get-Command powershell.exe -ErrorAction Stop | Select-Object -First 1
    $powershellPath = $powershellCommand.Source
}

$linkPath = Join-Path $startupDir "Clipboard Image Paste Hotkey.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($linkPath)
$shortcut.TargetPath = $powershellPath
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$startScript`""
$shortcut.WorkingDirectory = Split-Path -Parent $startScript
$shortcut.WindowStyle = 7
$shortcut.Description = "Start the Clipboard Image Paste terminal hotkey helper."
$shortcut.Save()

Write-Output "Installed startup shortcut: $linkPath"

if ($StartNow) {
    & $startScript
}

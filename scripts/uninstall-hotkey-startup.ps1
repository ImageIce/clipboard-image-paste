[CmdletBinding()]
param(
    [switch]$StopNow
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startupDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
if (-not $startupDir) {
    throw "Could not resolve the current user's Startup folder."
}

$linkPath = Join-Path $startupDir "Clipboard Image Paste Hotkey.lnk"
if (Test-Path -LiteralPath $linkPath -PathType Leaf) {
    Remove-Item -LiteralPath $linkPath -Force
    Write-Output "Removed startup shortcut: $linkPath"
} else {
    Write-Output "Startup shortcut was not installed: $linkPath"
}

if ($StopNow) {
    $stopScript = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "stop-hotkey.ps1")).ProviderPath
    & $stopScript
}

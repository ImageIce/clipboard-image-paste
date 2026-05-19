[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-HotkeyScriptPaths {
    @(
        "clipimg-hotkey.ahk",
        "clipimg-hotkey-v2.ahk"
    ) | ForEach-Object {
        $path = Join-Path $PSScriptRoot $_
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            (Resolve-Path -LiteralPath $path).ProviderPath
        }
    }
}

$scriptPaths = @(Get-HotkeyScriptPaths)
$processes = @(Get-CimInstance Win32_Process |
    Where-Object {
        $isHotkeyProcess = $false
        if ($_.Name -match "^AutoHotkey" -and $_.CommandLine) {
            foreach ($scriptPath in $scriptPaths) {
                if ($_.CommandLine.IndexOf($scriptPath, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $isHotkeyProcess = $true
                    break
                }
            }
        }

        $isHotkeyProcess
    })

foreach ($process in $processes) {
    Stop-Process -Id $process.ProcessId -Force
}

Write-Output "Stopped $($processes.Count) clipboard image paste hotkey process(es)."

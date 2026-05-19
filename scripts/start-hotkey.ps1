[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-CommandPath {
    param([string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    return $null
}

function Get-AutoHotkeyMajorVersion {
    param(
        [string]$Path,
        [int]$DefaultMajorVersion = 0
    )

    if ($DefaultMajorVersion -in @(1, 2)) {
        return $DefaultMajorVersion
    }

    $fileName = Split-Path -Leaf $Path
    if ($Path -match "\\v2\\" -or $fileName -in @("AutoHotkey64.exe", "AutoHotkey32.exe")) {
        return 2
    }

    if ($Path -match "\\v1" -or $fileName -in @("AutoHotkeyU64.exe", "AutoHotkeyU32.exe")) {
        return 1
    }

    $version = (Get-Item -LiteralPath $Path).VersionInfo.ProductVersion
    if ($version -match "^\s*([12])\.") {
        return [int]$Matches[1]
    }

    return $null
}

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

function Get-HotkeyProcesses {
    param([string[]]$ScriptPaths)

    Get-CimInstance Win32_Process |
        Where-Object {
            $isHotkeyProcess = $false
            if ($_.Name -match "^AutoHotkey" -and $_.CommandLine) {
                foreach ($scriptPath in $ScriptPaths) {
                    if ($_.CommandLine.IndexOf($scriptPath, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                        $isHotkeyProcess = $true
                        break
                    }
                }
            }

            $isHotkeyProcess
        }
}

function Get-AutoHotkeyRuntime {
    $candidates = @(
        @{ Path = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"; MajorVersion = 2 },
        @{ Path = "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"; MajorVersion = 2 },
        @{ Path = (Resolve-CommandPath "AutoHotkey64.exe"); MajorVersion = 2 },
        @{ Path = (Resolve-CommandPath "AutoHotkey32.exe"); MajorVersion = 2 },
        @{ Path = "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe"; MajorVersion = 1 },
        @{ Path = "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe"; MajorVersion = 1 },
        @{ Path = (Resolve-CommandPath "AutoHotkeyU64.exe"); MajorVersion = 1 },
        @{ Path = (Resolve-CommandPath "AutoHotkeyU32.exe"); MajorVersion = 1 },
        @{ Path = (Resolve-CommandPath "AutoHotkey.exe"); MajorVersion = 0 },
        @{ Path = "C:\Program Files\AutoHotkey\AutoHotkey.exe"; MajorVersion = 0 }
    )

    $seen = @{}
    foreach ($candidate in $candidates) {
        $candidatePath = $candidate["Path"]
        $candidateMajorVersion = $candidate["MajorVersion"]
        if (-not $candidatePath -or -not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
            continue
        }

        $executablePath = (Resolve-Path -LiteralPath $candidatePath).ProviderPath
        if ($seen.ContainsKey($executablePath)) {
            continue
        }

        $seen[$executablePath] = $true
        $majorVersion = Get-AutoHotkeyMajorVersion -Path $executablePath -DefaultMajorVersion $candidateMajorVersion
        if ($majorVersion -notin @(1, 2)) {
            continue
        }

        $scriptName = if ($majorVersion -eq 2) { "clipimg-hotkey-v2.ahk" } else { "clipimg-hotkey.ahk" }
        $scriptPath = Join-Path $PSScriptRoot $scriptName
        if (Test-Path -LiteralPath $scriptPath -PathType Leaf) {
            return [pscustomobject]@{
                ExecutablePath = $executablePath
                MajorVersion = $majorVersion
                ScriptPath = (Resolve-Path -LiteralPath $scriptPath).ProviderPath
            }
        }
    }

    throw "AutoHotkey v1.1 or v2 was not found. Install AutoHotkey, or update this script with the correct executable path."
}

$scriptPaths = @(Get-HotkeyScriptPaths)
$existing = @(Get-HotkeyProcesses -ScriptPaths $scriptPaths) | Select-Object -First 1

if ($existing) {
    Write-Output "Clipboard image paste hotkey already running as PID $($existing.ProcessId)."
    return
}

$runtime = Get-AutoHotkeyRuntime

$process = Start-Process -FilePath $runtime.ExecutablePath -ArgumentList "`"$($runtime.ScriptPath)`"" -WindowStyle Hidden -PassThru
Start-Sleep -Milliseconds 500
$process.Refresh()
if ($process.HasExited) {
    throw "AutoHotkey exited immediately while loading $($runtime.ScriptPath). Run the script directly to inspect the AutoHotkey error."
}

Write-Output "Started clipboard image paste hotkey as PID $($process.Id) with AutoHotkey v$($runtime.MajorVersion): $($runtime.ExecutablePath)"

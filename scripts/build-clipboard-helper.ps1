[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $env:LOCALAPPDATA "ClipboardImagePaste\clipboard-image-save.exe")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-CSharpCompiler {
    $command = Get-Command csc.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"),
        (Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe"),
        (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v3.5\csc.exe"),
        (Join-Path $env:WINDIR "Microsoft.NET\Framework\v3.5\csc.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    throw "Could not find csc.exe. Install .NET Framework developer tools or use the PowerShell fallback."
}

$sourcePath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "ClipboardImageSave.cs")).ProviderPath
$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$compiler = Get-CSharpCompiler
& $compiler /nologo /target:exe /optimize+ /r:System.Windows.Forms.dll /r:System.Drawing.dll "/out:$resolvedOutputPath" "$sourcePath"
if ($LASTEXITCODE -ne 0) {
    throw "C# helper compilation failed with exit code $LASTEXITCODE."
}

$featurePath = Join-Path $outputDir "clipboard-image-save.features"
Set-Content -LiteralPath $featurePath -Value "hotkey-running" -Encoding ASCII

Write-Output $resolvedOutputPath

[CmdletBinding()]
param(
    [string]$Version = "1.0.2"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).ProviderPath
$distDir = Join-Path $repoRoot "dist"
$stagingDir = Join-Path $distDir "clipboard-image-paste"
$zipPath = Join-Path $distDir "clipboard-image-paste-$Version.zip"

if (Test-Path -LiteralPath $stagingDir) {
    Remove-Item -LiteralPath $stagingDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null

$items = @(
    ".agents",
    ".claude",
    ".claude-plugin",
    ".codex-plugin",
    "claude",
    "commands",
    "hooks",
    "scripts",
    "skills",
    ".gitignore",
    "LICENSE",
    "PUBLISHING.md",
    "README.md"
)

foreach ($item in $items) {
    $source = Join-Path $repoRoot $item
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $stagingDir -Recurse -Force
    }
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $zipPath -Force
Write-Output $zipPath

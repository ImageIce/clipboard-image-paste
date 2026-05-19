[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[A-Za-z0-9_.-]+$")]
    [string]$GitHubOwner,

    [string]$RepositoryName = "clipboard-image-paste"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoUrl = "https://github.com/$GitHubOwner/$RepositoryName"
$gitUrl = "$repoUrl.git"

$files = @(
    ".\.codex-plugin\plugin.json",
    ".\README.md",
    ".\PUBLISHING.md"
)

foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file)) {
        throw "Missing expected file: $file"
    }

    $content = Get-Content -Raw -LiteralPath $file
    $content = $content.Replace("https://github.com/YOUR_USERNAME/clipboard-image-paste.git", $gitUrl)
    $content = $content.Replace("https://github.com/YOUR_USERNAME/clipboard-image-paste", $repoUrl)
    $content = $content.Replace("YOUR_USERNAME/clipboard-image-paste", "$GitHubOwner/$RepositoryName")
    $content = $content.Replace("YOUR_USERNAME", $GitHubOwner)
    Set-Content -LiteralPath $file -Value $content -NoNewline
}

Write-Output "Updated publisher metadata to $repoUrl"

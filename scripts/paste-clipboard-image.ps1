[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path (Get-Location).ProviderPath ".clipboard-images"),

    [ValidateSet("at-path", "path", "markdown", "at-absolute", "absolute", "claude-path", "claude-prompt")]
    [string]$Format = "at-path",

    [switch]$Paste,
    [switch]$NoClipboard,
    [int]$PasteDelayMs = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Import-ClipboardAssemblies {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}

function Test-ImageExtension {
    param([string]$Path)

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    return $extension -in @(".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".tif", ".tiff")
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $resolvedBase = (Resolve-Path -LiteralPath $BasePath).ProviderPath.TrimEnd("\") + "\"
    $resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
    $baseUri = [System.Uri]::new($resolvedBase)
    $targetUri = [System.Uri]::new($resolvedTarget)

    if ($baseUri.Scheme -ne $targetUri.Scheme) {
        return $resolvedTarget
    }

    $relativeUri = $baseUri.MakeRelativeUri($targetUri).ToString()
    return [System.Uri]::UnescapeDataString($relativeUri).Replace("/", "\")
}

function Save-ClipboardImage {
    param([string]$DestinationDir)

    Import-ClipboardAssemblies

    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
    $destination = Join-Path $DestinationDir "clipboard-image-$timestamp.png"

    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if ($null -ne $image) {
        try {
            $image.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $image.Dispose()
        }
        return $destination
    }

    $dropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
    foreach ($item in $dropList) {
        if ((Test-Path -LiteralPath $item -PathType Leaf) -and (Test-ImageExtension -Path $item)) {
            Copy-Item -LiteralPath $item -Destination $destination -Force
            return $destination
        }
    }

    throw "The clipboard does not contain a bitmap image or image file."
}

function Format-ImageReference {
    param(
        [string]$ImagePath,
        [string]$ReferenceFormat
    )

    $relativePath = Get-RelativePath -BasePath (Get-Location).ProviderPath -TargetPath $ImagePath
    $absolutePath = (Resolve-Path -LiteralPath $ImagePath).ProviderPath
    $claudePath = $absolutePath.Replace("\", "/")

    switch ($ReferenceFormat) {
        "path" { return $relativePath }
        "absolute" { return $absolutePath }
        "at-absolute" { return "@$absolutePath" }
        "claude-path" { return $claudePath }
        "claude-prompt" { return "Analyze this image: $claudePath" }
        "markdown" { return "![clipboard image]($relativePath)" }
        default { return "@$relativePath" }
    }
}

function Send-CtrlV {
    if (-not ("ClipboardImagePaste.KeyboardInput" -as [type])) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace ClipboardImagePaste {
    public static class KeyboardInput {
        [StructLayout(LayoutKind.Sequential)]
        struct INPUT {
            public UInt32 type;
            public KEYBDINPUT ki;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct KEYBDINPUT {
            public UInt16 wVk;
            public UInt16 wScan;
            public UInt32 dwFlags;
            public UInt32 time;
            public IntPtr dwExtraInfo;
        }

        [DllImport("user32.dll", SetLastError = true)]
        static extern UInt32 SendInput(UInt32 nInputs, INPUT[] pInputs, Int32 cbSize);

        const UInt32 INPUT_KEYBOARD = 1;
        const UInt32 KEYEVENTF_KEYUP = 0x0002;
        const UInt16 VK_CONTROL = 0x11;
        const UInt16 VK_V = 0x56;

        static INPUT Key(UInt16 key, bool up) {
            INPUT input = new INPUT();
            input.type = INPUT_KEYBOARD;
            input.ki.wVk = key;
            input.ki.wScan = 0;
            input.ki.dwFlags = up ? KEYEVENTF_KEYUP : 0;
            input.ki.time = 0;
            input.ki.dwExtraInfo = IntPtr.Zero;
            return input;
        }

        public static void CtrlV() {
            INPUT[] inputs = new INPUT[] {
                Key(VK_CONTROL, false),
                Key(VK_V, false),
                Key(VK_V, true),
                Key(VK_CONTROL, true)
            };

            UInt32 sent = SendInput((UInt32)inputs.Length, inputs, Marshal.SizeOf(typeof(INPUT)));
            if (sent != inputs.Length) {
                throw new InvalidOperationException("SendInput did not send the full Ctrl+V sequence.");
            }
        }
    }
}
"@
    }

    try {
        [ClipboardImagePaste.KeyboardInput]::CtrlV()
    }
    catch {
        try {
            $shell = New-Object -ComObject WScript.Shell
            $shell.SendKeys("^v")
        }
        catch {
            [System.Windows.Forms.SendKeys]::SendWait("^v")
        }
    }
}

if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne "STA") {
    throw "Clipboard access requires an STA PowerShell host. Run with: powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File `"$PSCommandPath`""
}

$savedPath = Save-ClipboardImage -DestinationDir $OutputDir
$reference = Format-ImageReference -ImagePath $savedPath -ReferenceFormat $Format

if (-not $NoClipboard) {
    Import-ClipboardAssemblies
    [System.Windows.Forms.Clipboard]::SetText($reference)
}

if ($Paste) {
    Import-ClipboardAssemblies
    Start-Sleep -Milliseconds $PasteDelayMs
    Send-CtrlV
}

$reference

# Clipboard Image Paste

Clipboard Image Paste is a Windows helper for Codex CLI and Claude Code. It turns the image currently on your clipboard into a local PNG file and pastes a prompt-ready path into your terminal.

Native image paste already works in Codex and Claude Code through the terminal image-paste shortcut, usually `Alt+V`. This plugin is useful when you want a faster, repeatable local-path workflow, especially in Claude Code where native image paste can be slower.

## What You Get

- `Ctrl+V` image paste in terminal windows when the optional AutoHotkey helper is running.
- A fast compiled clipboard helper for day-to-day use.
- A PowerShell fallback that works without building anything.
- Claude Code slash commands for saving and reading the current clipboard image.
- Codex plugin metadata for installing from a local clone or GitHub marketplace source.

When the clipboard contains an image, the hotkey helper saves it under `%TEMP%\clipboard-image-paste`, replaces the clipboard with a plain absolute image path, and pastes that path. When the clipboard contains text, `Ctrl+V` behaves normally.

## Requirements

Required:

- Windows 10 or Windows 11.
- PowerShell 5.1 or newer.
- Git, if installing from GitHub.

Optional:

- AutoHotkey v1.1 or v2 for the terminal `Ctrl+V` hotkey.
- Codex CLI for Codex plugin installation.
- Claude Code for Claude plugin installation and slash commands.

## Quick Start

Clone the repo:

```powershell
git clone https://github.com/ImageIce/clipboard-image-paste.git
cd clipboard-image-paste
```

Install the fast helper and start the terminal hotkey:

```powershell
.\scripts\install-hotkey-startup.ps1 -StartNow
```

This creates a startup shortcut for your Windows user and builds:

```text
%LOCALAPPDATA%\ClipboardImagePaste\clipboard-image-save.exe
```

Now copy any image, focus a Codex or Claude Code terminal, and press `Ctrl+V`.

## Native Paste

You do not need this plugin just to paste images. In Codex and Claude Code, `Alt+V` can use the terminal's native image paste behavior.

Use this plugin when you prefer the fast local-path workflow:

- `Alt+V`: native image paste handled by the terminal/CLI.
- `Ctrl+V` with this helper running: save image locally and paste the generated image path.
- `Ctrl+Alt+V` with this helper running: run the same fast image-path paste explicitly.

## Install In Claude Code

Add this repository as a Claude Code marketplace source:

```powershell
claude plugin marketplace add ImageIce/clipboard-image-paste
```

Install the plugin:

```powershell
claude plugin install clipboard-image-paste@clipboard-image-paste
```

Restart Claude Code after installing or updating the plugin.

Use the clipboard-image command:

```text
/clipboard-image-paste:paste-image
```

The command saves the clipboard image and gives Claude Code a plain absolute image path. It does not use an `@...` file reference.

You can also manage the hotkey helper from Claude Code:

```text
/clipboard-image-paste:start-image-paste-hotkey
/clipboard-image-paste:stop-image-paste-hotkey
```

## Install In Codex

Add this repository as a Codex plugin marketplace:

```powershell
codex plugin marketplace add ImageIce/clipboard-image-paste --ref main
```

Restart Codex, open `/plugins`, choose `Clipboard Image Paste`, and install it.

For local testing before pushing to GitHub:

```powershell
$pluginRoot = (Resolve-Path .).Path
codex plugin marketplace add $pluginRoot
```

## Manual Use

To save the current clipboard image with the PowerShell fallback:

```powershell
powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File .\scripts\paste-clipboard-image.ps1
```

Expected result:

- A PNG is written under `.clipboard-images\`.
- A prompt reference is printed.
- The same reference is copied to the clipboard.

For Claude Code, use a plain image path:

```powershell
powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File .\scripts\paste-clipboard-image.ps1 -Format claude-path
```

To use the fast compiled helper directly after running the startup installer:

```powershell
& "$env:LOCALAPPDATA\ClipboardImagePaste\clipboard-image-save.exe" --format claude-path
```

## Stop Or Remove The Hotkey

Stop the current helper process:

```powershell
.\scripts\stop-hotkey.ps1
```

Remove the Windows Startup shortcut and stop the helper:

```powershell
.\scripts\uninstall-hotkey-startup.ps1 -StopNow
```

## Generated Files

The plugin can create local runtime files:

- `.clipboard-images\`
- `.clipboard-images-gui-test\`
- `dist\`
- `%TEMP%\clipboard-image-paste\`
- `%LOCALAPPDATA%\ClipboardImagePaste\clipboard-image-save.exe`

Generated images and packaged artifacts are ignored by Git and should not be committed.

## Troubleshooting

`The clipboard does not contain a bitmap image or image file.`

Copy an actual image first. Screenshots, browser image copy, Paint copy, and copied image files are supported paths.

`AutoHotkey v1.1 or v2 was not found.`

Install AutoHotkey, then rerun:

```powershell
.\scripts\install-hotkey-startup.ps1 -StartNow
```

`Ctrl+V still pastes text.`

Make sure the AutoHotkey helper is running:

```powershell
.\scripts\start-hotkey.ps1
```

The hotkey only changes behavior in terminal windows such as PowerShell, cmd, pwsh, Windows Terminal, `wt`, and OpenConsole.

`Claude Code does not show an image chip.`

That is expected for the fast path. The plugin pastes a local image path, which Claude Code can read as image input. Use native `Alt+V` if you specifically want Claude Code's image-chip paste behavior.

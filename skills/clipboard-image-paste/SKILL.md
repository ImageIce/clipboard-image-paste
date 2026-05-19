---
name: clipboard-image-paste
description: Use when the user wants to attach or paste the bitmap currently stored in the Windows clipboard into a Codex or Claude Code CLI prompt.
disable-model-invocation: true
allowed-tools: Bash(cmd.exe *) Bash(powershell.exe *) Read
---

# Clipboard Image Paste

Use the plugin script to convert the current Windows clipboard image into a project-local PNG and a prompt-safe image reference.

Generated image path:

!`cmd.exe /d /c ""${CLAUDE_SKILL_DIR}/../../scripts/paste-clipboard-image.cmd" claude-path"`

Read the image file at the generated path above and treat it as the user's provided image. If the command output is not a readable image path ending in `.png`, report that output as the failure reason.

In Codex, resolve `scripts\paste-clipboard-image.ps1` relative to this plugin's installed root, or run this repository's `.\scripts\paste-clipboard-image.ps1` while developing locally. Claude Code image input should use a plain absolute image path, not an `@` file reference.

Do not claim the image has been attached unless the script successfully saved the PNG and emitted a reference.

For terminal `Ctrl+V` interception in `cmd.exe`, PowerShell, or Windows Terminal, the AutoHotkey helper must be running. AutoHotkey v1.1 and v2 are supported. Start it with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-hotkey.ps1
```

When `Ctrl+V` is used in a hooked terminal with an image on the clipboard, the helper saves the image locally, replaces the clipboard with a plain absolute image path, and pastes that path. `Ctrl+Alt+V` uses the same fast conversion path.

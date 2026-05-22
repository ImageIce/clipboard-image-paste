---
description: Start the terminal Ctrl+V clipboard image paste hook
disable-model-invocation: true
allowed-tools: Bash(cmd.exe *) Bash(powershell.exe *)
---

Start the clipboard image paste terminal hotkey:

!`cmd.exe /d /c ""${CLAUDE_PLUGIN_ROOT}/scripts/start-hotkey.cmd""`

After this is running, pressing `Ctrl+V` in `cmd.exe`, PowerShell, or Windows Terminal with an image on the clipboard saves the image under `%TEMP%\clipboard-image-paste` and pastes a plain absolute image path. `Ctrl+Alt+V` runs the same fast path explicitly.

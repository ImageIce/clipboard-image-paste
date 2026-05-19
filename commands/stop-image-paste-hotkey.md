---
description: Stop the terminal Ctrl+V clipboard image paste hook
disable-model-invocation: true
allowed-tools: Bash(powershell.exe *)
---

Stop the clipboard image paste terminal hotkey:

!`powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/stop-hotkey.ps1"`

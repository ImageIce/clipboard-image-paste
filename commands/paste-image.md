---
description: Save the current clipboard image and read it as Claude Code image input
disable-model-invocation: true
allowed-tools: Bash(cmd.exe *) Bash(powershell.exe *) Read
---

# Clipboard Image

Generated image path:

!`cmd.exe /d /c ""${CLAUDE_PLUGIN_ROOT}/scripts/paste-clipboard-image.cmd" claude-path"`

Read the image file at the generated path above and treat it as the user's provided image. If the command output is not a readable image path ending in `.png`, report that output as the failure reason.

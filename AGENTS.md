# Repository Guidelines

## Project Structure & Module Organization

This repository contains a Windows-first plugin for converting clipboard images into local PNG references for Codex and Claude Code CLI prompts.

- `.codex-plugin/plugin.json` defines Codex plugin metadata, skills path, display text, and marketplace URLs.
- `skills/clipboard-image-paste/SKILL.md` is the Codex skill entrypoint.
- `scripts/` contains the implementation: `paste-clipboard-image.ps1`, packaging helpers, publisher updates, and the optional AutoHotkey hotkey.
- `claude/commands/` and `.claude/commands/` contain the Claude Code slash command template/project command.
- `.agents/plugins/marketplace.json` and `.claude-plugin/marketplace.json` support local marketplace loading.
- `.clipboard-images/` and `dist/` are generated outputs and should stay untracked.

## Build, Test, and Development Commands

Run commands from the repository root in PowerShell.

```powershell
powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File .\scripts\paste-clipboard-image.ps1
```

Saves the current clipboard image under `.clipboard-images/` and copies an `@path` reference.

```powershell
powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File .\scripts\paste-clipboard-image.ps1 -Paste
```

Also attempts to paste the generated reference into the focused terminal.

```powershell
.\scripts\package-plugin.ps1 -Version 1.0.2
```

Stages plugin files and writes `dist\clipboard-image-paste-1.0.2.zip`.

```powershell
.\scripts\set-publisher.ps1 -GitHubOwner ImageIce
```

Updates repository owner placeholders in plugin metadata and docs.

## Coding Style & Naming Conventions

Use PowerShell with `Set-StrictMode -Version Latest`, `$ErrorActionPreference = "Stop"`, approved verb-noun function names, and four-space indentation. Prefer explicit parameters with validation attributes, as in `-Format` and `-PasteDelayMs`. Keep generated image names in the existing `clipboard-image-yyyyMMdd-HHmmss-fff.png` pattern. Use relative Windows paths in docs unless absolute paths are required for terminal hotkey behavior.

## Testing Guidelines

There is no automated test suite yet. Validate changes manually by running `paste-clipboard-image.ps1` with a bitmap in the clipboard, with a clipboard file-drop image, and with `-Paste` when terminal focus behavior changes. After packaging changes, run `package-plugin.ps1` and inspect the staged `dist/clipboard-image-paste/` contents before publishing.

## Commit & Pull Request Guidelines

Recent commits use short imperative subjects such as `Support local marketplace loading` and `Broaden image paste hotkey to terminals`. Follow that style: one focused change per commit, no trailing punctuation. Pull requests should describe the user-facing workflow affected, list manual validation commands, mention Windows or AutoHotkey assumptions, and include screenshots only when UI or marketplace presentation changes.

After completing requested edits, run `git status`, stage the relevant files, and create a Git commit unless the user explicitly asks not to commit.

## Security & Configuration Tips

Do not commit clipboard output, release zips, personal screenshots, or local marketplace artifacts. Keep publisher metadata consistent across plugin manifests and docs.

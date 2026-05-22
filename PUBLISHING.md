# Publishing

Official public Plugin Directory publishing is not self-serve yet. Publish this as a GitHub-hosted custom Codex marketplace.

## 1. Set your GitHub owner

From this repo:

```powershell
.\scripts\set-publisher.ps1 -GitHubOwner ImageIce
```

This updates:

- `.codex-plugin\plugin.json`
- `README.md`
- `PUBLISHING.md`

## 2. Push to GitHub

Create a GitHub repo named `clipboard-image-paste` without adding a README, `.gitignore`, or license.

Then push:

```powershell
git remote add origin https://github.com/ImageIce/clipboard-image-paste.git
git push -u origin main
```

## 3. Install the marketplace in Codex

For local testing before pushing to GitHub:

```powershell
$pluginRoot = (Resolve-Path .).Path
codex plugin marketplace add $pluginRoot
```

For GitHub:

```powershell
codex plugin marketplace add ImageIce/clipboard-image-paste --ref main
```

Restart Codex, open `/plugins`, select the `Clipboard Image Paste` marketplace, and install the plugin.

## 4. Update later

After pushing plugin changes:

```powershell
codex plugin marketplace upgrade clipboard-image-paste
```

## Optional release ZIP

For a GitHub Release attachment:

```powershell
.\scripts\package-plugin.ps1 -Version 1.0.2
```

Upload the generated `dist\clipboard-image-paste-1.0.2.zip` as a release asset.

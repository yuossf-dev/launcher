# VillageDeathmatchX Launcher

This repo contains the separate Godot launcher project for VillageDeathmatchX.

Files:
- `project.godot` - launcher project
- `Scenes/Launcher.tscn` - launcher UI
- `Scripts/Launcher.gd` - update check, download, and play flow
- `manifest.json` - public version manifest for the launcher

Manifest format:
```json
{
  "version": "0.0.1",
  "download_url": "https://github.com/yuossf-dev/launcher/releases/download/v0.0.1/vdx-build.zip"
}
```

GitHub setup:
1. Enable GitHub Pages for this repo from the root branch.
2. Keep `manifest.json` in the repo root so it is served at:
   `https://yuossf-dev.github.io/launcher/manifest.json`
3. Upload release zip files to GitHub Releases and update `download_url`.

Current launcher manifest URL:
- `https://yuossf-dev.github.io/launcher/manifest.json`

# 🖥️ CineJoy Desktop — Windows app

Electron-based desktop client for [cinejoy.pk](https://cinejoy.pk/).
Portable Windows (x64) build — unzip and run, no installer needed.

## Contents

- `main.js` — app entry point: window setup, ad/tracker blocking, popup policy
- `package.json` — project metadata and dev dependencies
- `adblock-hosts.txt` — ad/tracker host blocklist (shared with the Android app)
- `icon.ico` — app icon (binary; not stored in this repo — see note below)

## Popup policy

The app is a dedicated CineJoy client, so popups are locked down: only
cinejoy.pk opens new windows. Blocklisted ad hosts and background popunders
are denied silently. Only a genuine foreground trailer link (YouTube/Vimeo)
opens in the default browser.

## Build

Requires Node.js:

```sh
npm install --ignore-scripts
npx electron-packager . CineJoy --platform=win32 --arch=x64 --icon=icon.ico --overwrite --out=dist
```

Notes:
- `electron-packager` needs Wine on Linux to stamp the exe icon via rcedit.
  Alternative used here: assemble the win32 Electron dist manually and embed
  the icon plus version metadata with `resedit-cli` (pure JS, no Wine).
- `main.js` only uses Electron/Node built-ins, so the packaged app needs no
  `node_modules`.

## Releases

Installable zips (`CineJoy-Windows-x64.zip`) are published through GitHub
Releases, created manually in the GitHub web UI.

## Note on binaries

This repo's GitHub connection is text-only, so `icon.ico` isn't stored here.
Grab it from a release zip (`resources/app/icon.ico`), or regenerate it from
the Android project's icon artwork.

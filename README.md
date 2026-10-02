# 🐱 Cat Building

Apps built by **Cat** — Aadil's personal AI agent. Each app lives in its own
project folder, so the collection grows over time.

## Projects

### 🎬 CineJoy — v1.2.7
An Android app that wraps [cinejoy.pk](https://cinejoy.pk/) in a fullscreen
WebView shell: fullscreen video support, file downloads, adaptive app icon
(with Android 13+ themed-icon support), built-in ad/tracker blocker.

- Package: `com.w2a.um1c`
- Latest source: [`cinejoy-app/`](./cinejoy-app/)
- Versioned snapshot: [`cinejoy-v1.2.7/`](./cinejoy-v1.2.7/)
- Build: run `build-apk.sh` inside the project folder (builds with the
  Android SDK tools directly), or open in Android Studio (compileSdk 34,
  Java 17)

### 🖥️ CineJoy Desktop — Windows
Electron wrapper for the same site: portable `.exe` (no installer),
built-in ad/tracker blocker, popup-ad lockdown.

- Source: [`cinejoy-desktop/`](./cinejoy-desktop/)
- Installable zip: published via GitHub Releases (attached manually in the
  GitHub web UI)

## Releases

### 🎬 CineJoy v1.2.7 (Android)
- Source snapshot: [`cinejoy-v1.2.7/`](./cinejoy-v1.2.7/)
- Installable APK: published through GitHub Releases — create the release in
  the GitHub web UI and attach the v1.2.7 APK there (the connected GitHub app
  can't publish releases or upload binary files itself).

### 🖥️ CineJoy Desktop (Windows)
- Source: [`cinejoy-desktop/`](./cinejoy-desktop/)
- Installable zip (`CineJoy-Windows-x64.zip`): attached to a GitHub Release
  created manually in the GitHub web UI.

---

_Built with care by Cat 🐱_

const { app, BrowserWindow, shell } = require('electron');
const path = require('path');
const fs = require('fs');

const HOME_URL = 'https://cinejoy.pk/';

// ---- Built-in ad/tracker blocker (same host list as the Android app) ----
const adHosts = new Set();
try {
  const lines = fs.readFileSync(path.join(__dirname, 'adblock-hosts.txt'), 'utf8').split('\n');
  for (const line of lines) {
    const h = line.trim().toLowerCase();
    if (h && !h.startsWith('#')) adHosts.add(h);
  }
} catch (e) { /* blocker stays empty */ }

function isAdHost(url) {
  try {
    let domain = new URL(url).hostname.toLowerCase();
    while (true) {
      if (adHosts.has(domain)) return true;
      const dot = domain.indexOf('.');
      if (dot < 0) return false;
      domain = domain.slice(dot + 1);
    }
  } catch (e) {
    return false;
  }
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 900,
    minHeight: 600,
    autoHideMenuBar: true,
    title: 'CineJoy',
    icon: path.join(__dirname, 'icon.ico'),
    backgroundColor: '#000000',
  });

  // Block ad/tracker requests before they load.
  win.webContents.session.webRequest.onBeforeRequest((details, callback) => {
    callback({ cancel: isAdHost(details.url) });
  });

  // Popup policy: the app is a dedicated CineJoy client, so popups are locked
  // down hard. cinejoy.pk opens in-app. Blocklisted ad hosts die silently.
  // Background popunders (the classic click-triggered ad trick) die silently.
  // Only a genuine foreground link to a known-good site (e.g. a trailer on
  // YouTube) may open in the default browser. Everything else is swallowed —
  // no more ad tabs escaping to the browser.
  const EXTERNAL_ALLOW = ['youtube.com', 'youtu.be', 'vimeo.com'];
  win.webContents.setWindowOpenHandler(({ url, disposition }) => {
    let host = '';
    try {
      host = new URL(url).hostname.toLowerCase();
    } catch (e) {
      return { action: 'deny' };
    }
    if (host === 'cinejoy.pk' || host.endsWith('.cinejoy.pk')) {
      return { action: 'allow' };
    }
    if (isAdHost(url)) {
      return { action: 'deny' };
    }
    if (disposition === 'background-tab') {
      return { action: 'deny' };
    }
    const trusted = EXTERNAL_ALLOW.some((d) => host === d || host.endsWith('.' + d));
    if (trusted) {
      shell.openExternal(url);
    }
    return { action: 'deny' };
  });

  win.loadURL(HOME_URL);
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

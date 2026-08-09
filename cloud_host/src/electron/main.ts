import { app, BrowserWindow, ipcMain, dialog, shell } from 'electron';
import path from 'path';
import fs from 'fs';
import QRCode from 'qrcode';
import { DEFAULT_CONFIG, HostConfig } from '../shared/types';
import { Logger } from '../shared/logger';
import { buildLanUrl, getLanIp } from '../shared/lan';
import { createWexcomServer, WexcomServer } from '../server';
import { addFirewallRule } from './firewall';

const logger = new Logger();
let mainWindow: BrowserWindow | null = null;
let wexcomServer: WexcomServer | null = null;
let currentConfig: HostConfig = { ...DEFAULT_CONFIG };

function configPath(): string {
  return path.join(app.getPath('userData'), 'config.json');
}

function loadConfig(): HostConfig {
  const defaults: HostConfig = {
    ...DEFAULT_CONFIG,
    dataDir: path.join(app.getPath('userData'), 'data'),
  };
  try {
    if (fs.existsSync(configPath())) {
      const raw = JSON.parse(fs.readFileSync(configPath(), 'utf8')) as Partial<HostConfig>;
      return { ...defaults, ...raw, dataDir: raw.dataDir || defaults.dataDir };
    }
  } catch {
    // use defaults
  }
  return defaults;
}

function saveConfigToDisk(config: HostConfig): void {
  fs.mkdirSync(path.dirname(configPath()), { recursive: true });
  fs.writeFileSync(configPath(), JSON.stringify(config, null, 2), 'utf8');
  currentConfig = config;
}

function broadcastServerState(running: boolean): void {
  mainWindow?.webContents.send('server-state', running);
}

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 920,
    height: 720,
    minWidth: 720,
    minHeight: 560,
    title: 'Wexcom Cloud Host',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile(path.join(__dirname, '../../renderer/index.html'));
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

async function startServerInternal(): Promise<{ ok: boolean; error?: string }> {
  if (wexcomServer?.isRunning()) {
    return { ok: true };
  }
  try {
    fs.mkdirSync(currentConfig.dataDir, { recursive: true });
    wexcomServer = createWexcomServer(currentConfig, logger);
    await wexcomServer.start();
    broadcastServerState(true);
    return { ok: true };
  } catch (e) {
    wexcomServer = null;
    const msg = e instanceof Error ? e.message : String(e);
    logger.log(`Start failed: ${msg}`);
    broadcastServerState(false);
    return { ok: false, error: msg };
  }
}

async function stopServerInternal(): Promise<void> {
  if (wexcomServer) {
    await wexcomServer.stop();
    wexcomServer = null;
  }
  broadcastServerState(false);
}

function registerIpc(): void {
  ipcMain.handle('get-config', () => currentConfig);

  ipcMain.handle('save-config', (_e, config: HostConfig) => {
    saveConfigToDisk(config);
  });

  ipcMain.handle('start-server', async () => {
    const result = await startServerInternal();
    if (result.ok && !currentConfig.firewallPromptShown) {
      mainWindow?.webContents.send('firewall-prompt', currentConfig.port);
    }
    return result;
  });

  ipcMain.handle('stop-server', async () => {
    await stopServerInternal();
  });

  ipcMain.handle('get-server-info', () => {
    const running = wexcomServer?.isRunning() ?? false;
    const snapshots = running ? wexcomServer!.getSnapshotService().list() : [];
    const latest = snapshots.length > 0 ? snapshots[snapshots.length - 1] : null;
    return {
      running,
      lanUrl: buildLanUrl(currentConfig.port),
      lanIp: getLanIp(),
      snapshotCount: snapshots.length,
      latestUpload: latest?.uploaded_at ?? null,
      latestSize: latest?.size_bytes ?? 0,
    };
  });

  ipcMain.handle('get-logs', () => logger.getLines());
  ipcMain.handle('clear-logs', () => logger.clear());

  ipcMain.handle('open-snapshots-folder', () => {
    const dir = path.join(currentConfig.dataDir, 'snapshots');
    fs.mkdirSync(dir, { recursive: true });
    shell.openPath(dir);
  });

  ipcMain.handle('pick-data-dir', async () => {
    const result = await dialog.showOpenDialog(mainWindow!, {
      properties: ['openDirectory', 'createDirectory'],
      defaultPath: currentConfig.dataDir,
    });
    if (result.canceled || result.filePaths.length === 0) return null;
    return result.filePaths[0];
  });

  ipcMain.handle('delete-snapshot', async (_e, id: string) => {
    if (!wexcomServer?.isRunning()) {
      return { ok: false, error: 'Server is not running' };
    }
    const ok = wexcomServer.getSnapshotService().delete(id);
    return ok ? { ok: true } : { ok: false, error: 'Snapshot not found' };
  });

  ipcMain.handle('list-snapshots', () => {
    if (!wexcomServer?.isRunning()) return [];
    return [...wexcomServer.getSnapshotService().list()].reverse();
  });

  ipcMain.handle('get-qr', async (_e, url: string) => {
    return QRCode.toDataURL(url, { margin: 2, width: 200 });
  });

  ipcMain.handle('add-firewall-rule', async () => {
    const result = await addFirewallRule(currentConfig.port);
    if (result.ok) {
      currentConfig.firewallPromptShown = true;
      saveConfigToDisk(currentConfig);
    }
    return result;
  });
}

app.whenReady().then(async () => {
  currentConfig = loadConfig();
  registerIpc();
  logger.on('log', (line: string) => {
    mainWindow?.webContents.send('log', line);
  });
  createWindow();

  if (currentConfig.autoStart) {
    await startServerInternal();
  }
});

app.on('window-all-closed', async () => {
  await stopServerInternal();
  app.quit();
});

app.on('before-quit', async () => {
  await stopServerInternal();
});

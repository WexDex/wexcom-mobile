import { contextBridge, ipcRenderer } from 'electron';

export interface HostConfigDto {
  port: number;
  user: string;
  pass: string;
  dataDir: string;
  autoStart: boolean;
  firewallPromptShown: boolean;
}

export interface ServerInfoDto {
  running: boolean;
  lanUrl: string;
  lanIp: string | null;
  snapshotCount: number;
  latestUpload: string | null;
  latestSize: number;
}

contextBridge.exposeInMainWorld('wexcomHost', {
  getConfig: (): Promise<HostConfigDto> => ipcRenderer.invoke('get-config'),
  saveConfig: (config: HostConfigDto): Promise<void> => ipcRenderer.invoke('save-config', config),
  startServer: (): Promise<{ ok: boolean; error?: string }> => ipcRenderer.invoke('start-server'),
  stopServer: (): Promise<void> => ipcRenderer.invoke('stop-server'),
  getServerInfo: (): Promise<ServerInfoDto> => ipcRenderer.invoke('get-server-info'),
  getLogs: (): Promise<string[]> => ipcRenderer.invoke('get-logs'),
  clearLogs: (): Promise<void> => ipcRenderer.invoke('clear-logs'),
  openSnapshotsFolder: (): Promise<void> => ipcRenderer.invoke('open-snapshots-folder'),
  pickDataDir: (): Promise<string | null> => ipcRenderer.invoke('pick-data-dir'),
  deleteSnapshot: (id: string): Promise<{ ok: boolean; error?: string }> =>
    ipcRenderer.invoke('delete-snapshot', id),
  listSnapshots: (): Promise<Array<{ id: string; uploaded_at: string; size_bytes: number; label?: string }>> =>
    ipcRenderer.invoke('list-snapshots'),
  getQrDataUrl: (url: string): Promise<string> => ipcRenderer.invoke('get-qr', url),
  addFirewallRule: (): Promise<{ ok: boolean; message: string }> =>
    ipcRenderer.invoke('add-firewall-rule'),
  onLog: (callback: (line: string) => void) => {
    const handler = (_: Electron.IpcRendererEvent, line: string) => callback(line);
    ipcRenderer.on('log', handler);
    return () => ipcRenderer.removeListener('log', handler);
  },
  onServerState: (callback: (running: boolean) => void) => {
    const handler = (_: Electron.IpcRendererEvent, running: boolean) => callback(running);
    ipcRenderer.on('server-state', handler);
    return () => ipcRenderer.removeListener('server-state', handler);
  },
  onFirewallPrompt: (callback: (port: number) => void) => {
    const handler = (_: Electron.IpcRendererEvent, port: number) => callback(port);
    ipcRenderer.on('firewall-prompt', handler);
    return () => ipcRenderer.removeListener('firewall-prompt', handler);
  },
});

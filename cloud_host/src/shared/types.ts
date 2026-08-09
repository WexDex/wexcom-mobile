export const SERVER_VERSION = '2.0.0';
export const MAX_SNAPSHOTS = 20;

export interface Snapshot {
  id: string;
  filename: string;
  uploaded_at: string;
  size_bytes: number;
  sha256: string;
  label?: string;
}

export interface HostConfig {
  port: number;
  user: string;
  pass: string;
  dataDir: string;
  autoStart: boolean;
  firewallPromptShown: boolean;
}

export const DEFAULT_CONFIG: HostConfig = {
  port: 8787,
  user: 'admin',
  pass: 'changeme',
  dataDir: '',
  autoStart: false,
  firewallPromptShown: false,
};

export interface ServerStatus {
  ok: boolean;
  version: string;
  snapshot_count: number;
  latest_snapshot: Snapshot | null;
  server_time: string;
  last_upload_at?: string | null;
  file_size_bytes?: number;
  db_ready?: boolean;
}

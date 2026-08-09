import initSqlJs, { Database, SqlValue } from 'sql.js';
import fs from 'fs';
import path from 'path';
import { Snapshot } from '../../shared/types';
import { ManifestService } from './manifest';

export type SqliteDb = Database;

export interface OpenSnapshotResult {
  db: SqliteDb | null;
  snapshotId: string | null;
  error: string | null;
}

let sqlEngine: Awaited<ReturnType<typeof initSqlJs>> | null = null;

export async function initSqliteEngine(): Promise<void> {
  if (sqlEngine) return;
  const wasmPath = findWasmPath();
  sqlEngine = await initSqlJs({ locateFile: () => wasmPath });
}

function findWasmPath(): string {
  const candidates = [
    path.join(__dirname, '../../../node_modules/sql.js/dist/sql-wasm.wasm'),
    path.join(process.cwd(), 'node_modules/sql.js/dist/sql-wasm.wasm'),
  ];
  if (process.resourcesPath) {
    candidates.push(
      path.join(process.resourcesPath, 'app.asar.unpacked/node_modules/sql.js/dist/sql-wasm.wasm'),
      path.join(process.resourcesPath, 'app/node_modules/sql.js/dist/sql-wasm.wasm')
    );
  }
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  throw new Error('sql-wasm.wasm not found — run npm install in cloud_host');
}

export class SqliteReader {
  private manifest: ManifestService;

  constructor(private snapshotsDir: string) {
    this.manifest = new ManifestService(snapshotsDir);
  }

  openLatest(): OpenSnapshotResult {
    if (!sqlEngine) {
      return { db: null, snapshotId: null, error: 'SQLite engine not initialized' };
    }
    const snap = this.manifest.latest();
    if (!snap) {
      return { db: null, snapshotId: null, error: 'No snapshots available — upload first' };
    }
    const file = path.join(this.snapshotsDir, snap.filename);
    if (!fs.existsSync(file)) {
      return { db: null, snapshotId: null, error: 'Latest snapshot file missing on disk' };
    }
    try {
      const buffer = fs.readFileSync(file);
      const db = new sqlEngine.Database(buffer);
      return { db, snapshotId: snap.id, error: null };
    } catch (e) {
      return {
        db: null,
        snapshotId: null,
        error: `Cannot open SQLite file: ${e instanceof Error ? e.message : String(e)}`,
      };
    }
  }

  hasTable(db: SqliteDb, tableName: string): boolean {
    const stmt = db.prepare(
      "SELECT 1 AS ok FROM sqlite_master WHERE type='table' AND name=?"
    );
    stmt.bind([tableName]);
    const has = stmt.step();
    stmt.free();
    return has;
  }

  queryAll(db: SqliteDb, sql: string, params: SqlValue[] = []): Record<string, SqlValue>[] {
    const stmt = db.prepare(sql);
    if (params.length > 0) stmt.bind(params);
    const rows: Record<string, SqlValue>[] = [];
    while (stmt.step()) {
      rows.push(stmt.getAsObject() as Record<string, SqlValue>);
    }
    stmt.free();
    return rows;
  }

  queryGet(db: SqliteDb, sql: string, params: SqlValue[] = []): Record<string, SqlValue> | undefined {
    const rows = this.queryAll(db, sql, params);
    return rows[0];
  }

  withLatest<T>(fn: (db: SqliteDb, snapshotId: string) => T): T | { error: string; status: number } {
    const { db, snapshotId, error } = this.openLatest();
    if (error || !db || !snapshotId) {
      return { error: error ?? 'No snapshot', status: 503 };
    }
    try {
      return fn(db, snapshotId);
    } finally {
      db.close();
    }
  }
}

export function enrichStatusFromSnapshot(latest: Snapshot | null): {
  last_upload_at: string | null;
  file_size_bytes: number;
  db_ready: boolean;
} {
  return {
    last_upload_at: latest?.uploaded_at ?? null,
    file_size_bytes: latest?.size_bytes ?? 0,
    db_ready: latest !== null,
  };
}

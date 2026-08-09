import fs from 'fs';
import path from 'path';
import { createHash } from 'crypto';
import { Response } from 'express';
import { MAX_SNAPSHOTS, Snapshot } from '../../shared/types';
import { Logger } from '../../shared/logger';
import { ManifestService } from './manifest';

export class SnapshotService {
  private manifest: ManifestService;

  constructor(
    private snapshotsDir: string,
    private logger: Logger
  ) {
    fs.mkdirSync(snapshotsDir, { recursive: true });
    this.manifest = new ManifestService(snapshotsDir);
  }

  list(): Snapshot[] {
    return this.manifest.load();
  }

  latest(): Snapshot | null {
    return this.manifest.latest();
  }

  findById(id: string): Snapshot | undefined {
    return this.manifest.findById(id);
  }

  addFromBuffer(fileBytes: Buffer, label?: string): { snapshot: Snapshot; pruned: number } {
    const hash = createHash('sha256').update(fileBytes).digest('hex');
    const now = new Date();
    const id = `${Math.floor(now.getTime() / 1000)}_${hash.substring(0, 8)}`;
    const filename = `${id}.sqlite`;
    const dest = path.join(this.snapshotsDir, filename);
    fs.writeFileSync(dest, fileBytes);

    const snapshot: Snapshot = {
      id,
      filename,
      uploaded_at: now.toISOString(),
      size_bytes: fileBytes.length,
      sha256: hash,
      ...(label && label.length > 0 ? { label } : {}),
    };

    const snapshots = this.manifest.load();
    snapshots.push(snapshot);

    let pruned = 0;
    while (snapshots.length > MAX_SNAPSHOTS) {
      const old = snapshots.shift()!;
      const oldFile = path.join(this.snapshotsDir, old.filename);
      if (fs.existsSync(oldFile)) fs.unlinkSync(oldFile);
      pruned++;
    }

    this.manifest.save(snapshots);
    this.logger.log(
      `[upload] ${id}  ${fileBytes.length} bytes  sha256:${hash.substring(0, 12)}…`
    );

    return { snapshot, pruned };
  }

  delete(id: string): boolean {
    const removed = this.manifest.remove(id);
    if (!removed) return false;
    const file = path.join(this.snapshotsDir, removed.filename);
    if (fs.existsSync(file)) fs.unlinkSync(file);
    this.logger.log(`[delete] snapshot ${id}`);
    return true;
  }

  streamToResponse(snap: Snapshot, res: Response): void {
    const file = path.join(this.snapshotsDir, snap.filename);
    if (!fs.existsSync(file)) {
      res.status(404).json({ ok: false, error: 'Snapshot file missing on disk' });
      return;
    }
    const bytes = fs.readFileSync(file);
    res
      .status(200)
      .set({
        'content-type': 'application/octet-stream',
        'content-disposition': `attachment; filename="wexcom-${snap.id}.sqlite"`,
        'content-length': String(bytes.length),
        'x-sha256': snap.sha256,
        'x-snapshot-id': snap.id,
      })
      .send(bytes);
  }
}

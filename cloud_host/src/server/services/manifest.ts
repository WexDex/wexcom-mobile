import fs from 'fs';
import path from 'path';
import { Snapshot } from '../../shared/types';

export class ManifestService {
  constructor(private snapshotsDir: string) {}

  private get manifestPath(): string {
    return path.join(this.snapshotsDir, 'manifest.json');
  }

  load(): Snapshot[] {
    if (!fs.existsSync(this.manifestPath)) return [];
    try {
      const raw = JSON.parse(fs.readFileSync(this.manifestPath, 'utf8')) as Snapshot[];
      return Array.isArray(raw) ? raw : [];
    } catch {
      return [];
    }
  }

  save(snapshots: Snapshot[]): void {
    fs.writeFileSync(this.manifestPath, JSON.stringify(snapshots, null, 2), 'utf8');
  }

  latest(): Snapshot | null {
    const snapshots = this.load();
    return snapshots.length > 0 ? snapshots[snapshots.length - 1] : null;
  }

  findById(id: string): Snapshot | undefined {
    return this.load().find((s) => s.id === id);
  }

  remove(id: string): Snapshot | null {
    const snapshots = this.load();
    const idx = snapshots.findIndex((s) => s.id === id);
    if (idx < 0) return null;
    const [removed] = snapshots.splice(idx, 1);
    this.save(snapshots);
    return removed;
  }
}

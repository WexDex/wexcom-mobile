import { Router, Request, Response } from 'express';
import { SERVER_VERSION } from '../../shared/types';
import { SnapshotService } from '../services/snapshots';
import { enrichStatusFromSnapshot } from '../services/sqlite';

export function createStatusRouter(snapshots: SnapshotService): Router {
  const router = Router();

  router.get('/status', (_req: Request, res: Response) => {
    const list = snapshots.list();
    const latest = snapshots.latest();
    const flat = enrichStatusFromSnapshot(latest);
    res.json({
      ok: true,
      version: SERVER_VERSION,
      snapshot_count: list.length,
      latest_snapshot: latest,
      server_time: new Date().toISOString(),
      ...flat,
    });
  });

  return router;
}

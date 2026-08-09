import { Router, Request, Response } from 'express';
import multer from 'multer';
import { SnapshotService } from '../services/snapshots';

export function createSnapshotsRouter(snapshots: SnapshotService): Router {
  const router = Router();
  const upload = multer({ storage: multer.memoryStorage() });

  router.get('/snapshots', (_req: Request, res: Response) => {
    const list = snapshots.list();
    res.json({
      ok: true,
      snapshots: [...list].reverse(),
      count: list.length,
    });
  });

  router.post('/upload', upload.single('db_file'), (req: Request, res: Response) => {
    if (!req.file || req.file.buffer.length === 0) {
      res.status(400).json({ ok: false, error: 'Missing db_file field in multipart body' });
      return;
    }
    const label = typeof req.body?.label === 'string' ? req.body.label.trim() : undefined;
    const { snapshot, pruned } = snapshots.addFromBuffer(req.file.buffer, label);
    res.json({
      ok: true,
      snapshot,
      pruned,
      // Flutter-friendly flat fields
      uploaded_at: snapshot.uploaded_at,
      sha256: snapshot.sha256,
      size_bytes: snapshot.size_bytes,
    });
  });

  router.get('/download', (_req: Request, res: Response) => {
    const latest = snapshots.latest();
    if (!latest) {
      res.status(404).json({ ok: false, error: 'No snapshots available — upload first' });
      return;
    }
    snapshots.streamToResponse(latest, res);
  });

  router.get('/download/:id', (req: Request, res: Response) => {
    const id = String(req.params.id);
    const snap = snapshots.findById(id);
    if (!snap) {
      res.status(404).json({ ok: false, error: `Snapshot "${id}" not found` });
      return;
    }
    snapshots.streamToResponse(snap, res);
  });

  router.delete('/snapshots/:id', (req: Request, res: Response) => {
    const id = String(req.params.id);
    const ok = snapshots.delete(id);
    if (!ok) {
      res.status(404).json({ ok: false, error: `Snapshot "${id}" not found` });
      return;
    }
    res.json({ ok: true });
  });

  return router;
}

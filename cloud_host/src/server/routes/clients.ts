import { Router, Request, Response } from 'express';
import { SqliteReader } from '../services/sqlite';

export function createClientsRouter(sqlite: SqliteReader): Router {
  const router = Router();

  router.get('/clients', (_req: Request, res: Response) => {
    const result = sqlite.withLatest((db, snapshotId) => {
      const rows = sqlite.queryAll(
        db,
        `SELECT id, full_name AS name, phone, balance_minor,
                CASE WHEN archived_at IS NOT NULL THEN 1 ELSE 0 END AS is_archived
         FROM clients ORDER BY full_name`
      );

      return {
        ok: true,
        clients: rows.map((r) => ({
          id: r.id,
          name: r.name,
          phone: r.phone,
          balance_minor: r.balance_minor,
          is_archived: r.is_archived === 1,
        })),
        count: rows.length,
        snapshot_id: snapshotId,
      };
    });

    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  router.get('/clients/:id', (req: Request, res: Response) => {
    const clientId = String(req.params.id);
    const result = sqlite.withLatest((db, snapshotId) => {
      const client = sqlite.queryGet(
        db,
        `SELECT id, full_name AS name, phone, note, balance_minor,
                CASE WHEN archived_at IS NOT NULL THEN 1 ELSE 0 END AS is_archived,
                created_at, updated_at
         FROM clients WHERE id = ?`,
        [clientId]
      );

      if (!client) {
        return { notFound: true as const };
      }

      const txRows = sqlite.queryAll(
        db,
        `SELECT id, amount_minor, tx_type, tx_status, note, reference_no,
                effective_at, due_at, created_at
         FROM ledger_transactions
         WHERE client_id = ?
         ORDER BY effective_at DESC, created_at DESC`,
        [clientId]
      );

      return {
        ok: true,
        snapshot_id: snapshotId,
        client: {
          id: client.id,
          name: client.name,
          phone: client.phone,
          note: client.note,
          balance_minor: client.balance_minor,
          is_archived: client.is_archived === 1,
          created_at: client.created_at,
          updated_at: client.updated_at,
        },
        transactions: txRows,
        transaction_count: txRows.length,
      };
    });

    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    if ('notFound' in result) {
      res.status(404).json({ ok: false, error: `Client "${clientId}" not found in latest snapshot` });
      return;
    }
    res.json(result);
  });

  return router;
}

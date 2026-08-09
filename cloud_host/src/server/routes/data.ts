import { Router, Request, Response } from 'express';
import { SqliteReader } from '../services/sqlite';

export function createDataRouter(sqlite: SqliteReader): Router {
  const router = Router();

  router.get('/wallet', (_req: Request, res: Response) => {
    const result = sqlite.withLatest((db, snapshotId) => {
      if (!sqlite.hasTable(db, 'wallet_accounts')) {
        return {
          ok: true,
          snapshot_id: snapshotId,
          total_balance_minor: 0,
          count: 0,
          accounts: [],
          note: 'wallet_accounts table not found — snapshot predates v9',
        };
      }
      const rows = sqlite.queryAll(
        db,
        'SELECT id, name, emoji, balance_minor, sort_order FROM wallet_accounts ORDER BY sort_order'
      );
      const total = rows.reduce((s, r) => s + Number(r.balance_minor ?? 0), 0);
      return {
        ok: true,
        snapshot_id: snapshotId,
        total_balance_minor: total,
        count: rows.length,
        accounts: rows,
      };
    });
    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  router.get('/savings', (_req: Request, res: Response) => {
    const result = sqlite.withLatest((db, snapshotId) => {
      if (!sqlite.hasTable(db, 'savings_goals')) {
        return {
          ok: true,
          snapshot_id: snapshotId,
          count: 0,
          goals: [],
          note: 'savings_goals table not found — snapshot predates v9',
        };
      }
      const rows = sqlite.queryAll(
        db,
        `SELECT id, name, emoji, target_minor, saved_minor, note, deadline, is_completed
         FROM savings_goals ORDER BY created_at`
      );
      return {
        ok: true,
        snapshot_id: snapshotId,
        count: rows.length,
        goals: rows.map((r) => ({
          id: r.id,
          name: r.name,
          emoji: r.emoji,
          target_minor: r.target_minor,
          saved_minor: r.saved_minor,
          note: r.note,
          deadline: r.deadline,
          is_completed: r.is_completed === 1,
          progress_pct:
            Number(r.target_minor) > 0
              ? Math.floor((Number(r.saved_minor) * 100) / Number(r.target_minor))
              : 0,
        })),
      };
    });
    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  router.get('/categories', (req: Request, res: Response) => {
    const scope = req.query.scope as string | undefined;
    const result = sqlite.withLatest((db, snapshotId) => {
      if (!sqlite.hasTable(db, 'expense_categories')) {
        return {
          ok: true,
          snapshot_id: snapshotId,
          count: 0,
          categories: [],
          note: 'expense_categories table not found — snapshot predates v9',
        };
      }
      const rows = scope
        ? sqlite.queryAll(
            db,
            `SELECT id, name, color_hex, icon_code_point, budget_minor_per_month, scope
             FROM expense_categories WHERE scope = ? ORDER BY name`,
            [scope]
          )
        : sqlite.queryAll(
            db,
            `SELECT id, name, color_hex, icon_code_point, budget_minor_per_month, scope
             FROM expense_categories ORDER BY scope, name`
          );
      return {
        ok: true,
        snapshot_id: snapshotId,
        count: rows.length,
        categories: rows,
      };
    });
    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  router.get('/wishlist', (req: Request, res: Response) => {
    const purchasedParam = req.query.purchased as string | undefined;
    const result = sqlite.withLatest((db, snapshotId) => {
      if (!sqlite.hasTable(db, 'wishlist_items')) {
        return {
          ok: true,
          snapshot_id: snapshotId,
          count: 0,
          pending_total_minor: 0,
          items: [],
          note: 'wishlist_items table not found — snapshot predates v9',
        };
      }
      let rows;
      if (purchasedParam === 'true') {
        rows = sqlite.queryAll(
          db,
          `SELECT id, title, amount_minor, currency_code, note, category_id, is_purchased, created_at, purchased_at
           FROM wishlist_items WHERE is_purchased = 1 ORDER BY purchased_at DESC`
        );
      } else if (purchasedParam === 'false') {
        rows = sqlite.queryAll(
          db,
          `SELECT id, title, amount_minor, currency_code, note, category_id, is_purchased, created_at, purchased_at
           FROM wishlist_items WHERE is_purchased = 0 ORDER BY created_at DESC`
        );
      } else {
        rows = sqlite.queryAll(
          db,
          `SELECT id, title, amount_minor, currency_code, note, category_id, is_purchased, created_at, purchased_at
           FROM wishlist_items ORDER BY is_purchased ASC, created_at DESC`
        );
      }
      const pendingTotal = rows
        .filter((r) => r.is_purchased === 0)
        .reduce((s, r) => s + Number(r.amount_minor ?? 0), 0);
      return {
        ok: true,
        snapshot_id: snapshotId,
        count: rows.length,
        pending_total_minor: pendingTotal,
        items: rows.map((r) => ({
          id: r.id,
          title: r.title,
          amount_minor: r.amount_minor,
          currency_code: r.currency_code,
          note: r.note,
          category_id: r.category_id,
          is_purchased: r.is_purchased === 1,
          created_at: r.created_at,
          purchased_at: r.purchased_at,
        })),
      };
    });
    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  router.get('/finance', (req: Request, res: Response) => {
    const kindParam = req.query.kind as string | undefined;
    const limit = parseInt((req.query.limit as string) ?? '100', 10) || 100;
    const result = sqlite.withLatest((db, snapshotId) => {
      const rows = kindParam
        ? sqlite.queryAll(
            db,
            `SELECT id, kind, title, amount_minor, currency_code, note, category_id, created_at
             FROM personal_finance_entries WHERE kind = ? ORDER BY created_at DESC LIMIT ?`,
            [parseInt(kindParam, 10) || 0, limit]
          )
        : sqlite.queryAll(
            db,
            `SELECT id, kind, title, amount_minor, currency_code, note, category_id, created_at
             FROM personal_finance_entries ORDER BY created_at DESC LIMIT ?`,
            [limit]
          );
      const totalExpense = rows
        .filter((r) => Number(r.kind) === 0)
        .reduce((s, r) => s + Number(r.amount_minor ?? 0), 0);
      const totalGain = rows
        .filter((r) => Number(r.kind) === 1)
        .reduce((s, r) => s + Number(r.amount_minor ?? 0), 0);
      return {
        ok: true,
        snapshot_id: snapshotId,
        count: rows.length,
        total_expense_minor: totalExpense,
        total_gain_minor: totalGain,
        entries: rows,
      };
    });
    if ('error' in result) {
      res.status(result.status).json({ ok: false, error: result.error });
      return;
    }
    res.json(result);
  });

  return router;
}

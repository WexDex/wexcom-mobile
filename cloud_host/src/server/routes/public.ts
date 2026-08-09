import { Router, Request, Response } from 'express';
import { SERVER_VERSION } from '../../shared/types';

export function createPublicRouter(): Router {
  const router = Router();

  router.get('/ping', (_req: Request, res: Response) => {
    res.json({ ok: true, time: new Date().toISOString() });
  });

  router.get('/', (_req: Request, res: Response) => {
    res
      .type('html')
      .send(`<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><title>Wexcom Cloud Host</title>
<style>body{font-family:system-ui;background:#0f172a;color:#e2e8f0;padding:2rem;max-width:640px;margin:auto}
a{color:#38bdf8}code{background:#1e293b;padding:2px 6px;border-radius:4px}</style></head>
<body>
<h1>Wexcom Cloud Host v${SERVER_VERSION}</h1>
<p>LAN backup server for Wexcom Mobile. Use the desktop app or Flutter Settings to sync.</p>
<p><a href="/openapi.json">OpenAPI spec</a> · <a href="/ping">Ping</a></p>
<p>Connect phone: <code>http://&lt;LAN-IP&gt;:8787</code> (same Wi‑Fi)</p>
</body></html>`);
  });

  router.get('/openapi.json', (_req: Request, res: Response) => {
    res.json({
      openapi: '3.0.3',
      info: {
        title: 'Wexcom Cloud Host',
        version: SERVER_VERSION,
        description:
          'LAN SQLite backup server for Wexcom Mobile. Basic Auth on protected routes.',
      },
      servers: [{ url: 'http://localhost:8787', description: 'LAN' }],
      components: {
        securitySchemes: {
          basicAuth: { type: 'http', scheme: 'basic' },
        },
      },
      security: [{ basicAuth: [] }],
      paths: {
        '/ping': {
          get: { summary: 'Health ping', security: [], responses: { '200': { description: 'OK' } } },
        },
        '/status': { get: { summary: 'Server status', responses: { '200': { description: 'OK' } } } },
        '/upload': { post: { summary: 'Upload SQLite snapshot', responses: { '200': { description: 'OK' } } } },
        '/download': { get: { summary: 'Download latest snapshot', responses: { '200': { description: 'OK' } } } },
        '/snapshots': { get: { summary: 'List snapshots', responses: { '200': { description: 'OK' } } } },
        '/clients': { get: { summary: 'List clients', responses: { '200': { description: 'OK' } } } },
        '/wallet': { get: { summary: 'Wallet accounts', responses: { '200': { description: 'OK' } } } },
        '/savings': { get: { summary: 'Savings goals', responses: { '200': { description: 'OK' } } } },
        '/categories': { get: { summary: 'Expense categories', responses: { '200': { description: 'OK' } } } },
        '/wishlist': { get: { summary: 'Wishlist items', responses: { '200': { description: 'OK' } } } },
        '/finance': { get: { summary: 'Personal finance entries', responses: { '200': { description: 'OK' } } } },
      },
    });
  });

  return router;
}

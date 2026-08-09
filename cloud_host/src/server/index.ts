import express, { Express, Request, Response, NextFunction } from 'express';
import http from 'http';
import path from 'path';
import { HostConfig } from '../shared/types';
import { Logger } from '../shared/logger';
import { createAuthMiddleware } from './middleware/auth';
import { corsMiddleware } from './middleware/cors';
import { SnapshotService } from './services/snapshots';
import { initSqliteEngine, SqliteReader } from './services/sqlite';
import { createPublicRouter } from './routes/public';
import { createStatusRouter } from './routes/status';
import { createSnapshotsRouter } from './routes/snapshots';
import { createClientsRouter } from './routes/clients';
import { createDataRouter } from './routes/data';

export interface WexcomServer {
  app: Express;
  start(): Promise<void>;
  stop(): Promise<void>;
  isRunning(): boolean;
  getSnapshotService(): SnapshotService;
}

export function createWexcomServer(config: HostConfig, logger: Logger): WexcomServer {
  const snapshotsDir = path.join(config.dataDir, 'snapshots');
  const snapshotService = new SnapshotService(snapshotsDir, logger);
  const sqliteReader = new SqliteReader(snapshotsDir);

  const app = express();
  app.use(corsMiddleware);
  app.use(createAuthMiddleware(config.user, config.pass));

  app.use((req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();
    res.on('finish', () => {
      const ms = Date.now() - start;
      logger.log(`${req.method} ${req.path} ${res.statusCode} ${ms}ms`);
    });
    next();
  });

  app.use(createPublicRouter());
  app.use(createStatusRouter(snapshotService));
  app.use(createSnapshotsRouter(snapshotService));
  app.use(createClientsRouter(sqliteReader));
  app.use(createDataRouter(sqliteReader));

  app.use((_req: Request, res: Response) => {
    res.status(404).json({ ok: false, error: 'Not found' });
  });

  let server: http.Server | null = null;

  return {
    app,
    async start() {
      if (server) return;
      await initSqliteEngine();
      await new Promise<void>((resolve, reject) => {
        server = app.listen(config.port, '0.0.0.0', () => {
          logger.log(`Server listening on 0.0.0.0:${config.port}`);
          resolve();
        });
        server.on('error', (err: NodeJS.ErrnoException) => {
          server = null;
          if (err.code === 'EADDRINUSE') {
            reject(new Error(`Port ${config.port} is already in use`));
          } else {
            reject(err);
          }
        });
      });
    },
    async stop() {
      if (!server) return;
      await new Promise<void>((resolve, reject) => {
        server!.close((err) => {
          if (err) reject(err);
          else {
            logger.log('Server stopped');
            server = null;
            resolve();
          }
        });
      });
    },
    isRunning() {
      return server !== null && server.listening;
    },
    getSnapshotService() {
      return snapshotService;
    },
  };
}

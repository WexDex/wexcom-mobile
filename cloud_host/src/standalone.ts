/** Standalone server for dev/testing without Electron. */
import path from 'path';
import { createWexcomServer } from './server';
import { Logger } from './shared/logger';
import { DEFAULT_CONFIG } from './shared/types';
import { buildLanUrl } from './shared/lan';

const logger = new Logger();
const dataDir = path.join(process.cwd(), 'data');
const config = {
  ...DEFAULT_CONFIG,
  dataDir,
  port: parseInt(process.env.PORT ?? '8787', 10),
  user: process.env.WEXCOM_USER ?? DEFAULT_CONFIG.user,
  pass: process.env.WEXCOM_PASS ?? DEFAULT_CONFIG.pass,
};

const server = createWexcomServer(config, logger);

server
  .start()
  .then(() => {
    console.log(`Standalone server: ${buildLanUrl(config.port)}`);
    console.log('Press Ctrl+C to stop');
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });

process.on('SIGINT', async () => {
  await server.stop();
  process.exit(0);
});

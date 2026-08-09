import { createHash } from 'crypto';
import { Request, Response, NextFunction } from 'express';

const PUBLIC_PATHS = new Set(['/', '/openapi.json', '/ping']);

export function createAuthMiddleware(user: string, pass: string) {
  const expected = createHash('sha256').update(`${user}:${pass}`).digest('hex');

  return (req: Request, res: Response, next: NextFunction): void => {
    const path = req.path || '/';
    if (PUBLIC_PATHS.has(path)) {
      next();
      return;
    }

    const auth = req.headers.authorization ?? '';
    if (!auth.startsWith('Basic ')) {
      sendUnauthorized(res);
      return;
    }

    try {
      const decoded = Buffer.from(auth.substring(6), 'base64').toString('utf8');
      const colon = decoded.indexOf(':');
      if (colon < 0) {
        sendUnauthorized(res);
        return;
      }
      const reqUser = decoded.substring(0, colon);
      const reqPass = decoded.substring(colon + 1);
      const actual = createHash('sha256')
        .update(`${reqUser}:${reqPass}`)
        .digest('hex');
      if (actual !== expected) {
        sendUnauthorized(res);
        return;
      }
      next();
    } catch {
      sendUnauthorized(res);
    }
  };
}

function sendUnauthorized(res: Response): void {
  res
    .status(401)
    .set({
      'www-authenticate': 'Basic realm="Wexcom"',
      'content-type': 'application/json',
      'access-control-allow-origin': '*',
    })
    .json({ ok: false, error: 'Unauthorized' });
}

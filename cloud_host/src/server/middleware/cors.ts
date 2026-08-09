import { Request, Response, NextFunction } from 'express';

export const CORS_HEADERS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, DELETE, OPTIONS',
  'access-control-allow-headers': 'Authorization, Content-Type',
};

export function corsMiddleware(req: Request, res: Response, next: NextFunction): void {
  if (req.method === 'OPTIONS') {
    res.set(CORS_HEADERS).status(200).send('');
    return;
  }
  res.set(CORS_HEADERS);
  next();
}

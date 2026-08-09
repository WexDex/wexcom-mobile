import os from 'os';

/** Prefer private LAN IPv4 for phone connection URLs. */
export function getLanIp(): string | null {
  const nets = os.networkInterfaces();
  const candidates: string[] = [];

  for (const name of Object.keys(nets)) {
    const addrs = nets[name];
    if (!addrs) continue;
    for (const addr of addrs) {
      if (addr.family !== 'IPv4' || addr.internal) continue;
      candidates.push(addr.address);
    }
  }

  const preferred = candidates.find(
    (ip) => ip.startsWith('192.168.') || ip.startsWith('10.')
  );
  if (preferred) return preferred;

  const linkLocal = candidates.find((ip) => ip.startsWith('172.'));
  if (linkLocal) {
    const second = parseInt(linkLocal.split('.')[1] ?? '0', 10);
    if (second >= 16 && second <= 31) return linkLocal;
  }

  return candidates[0] ?? null;
}

export function buildLanUrl(port: number): string {
  const ip = getLanIp();
  const host = ip ?? 'localhost';
  return `http://${host}:${port}`;
}

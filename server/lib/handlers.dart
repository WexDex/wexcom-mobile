import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'store.dart';

const _corsHeaders = <String, String>{
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'access-control-allow-headers':
      'authorization, content-type, accept, x-device-name, x-requested-with',
  'access-control-expose-headers':
      'x-snapshot-id, x-snapshot-sha256, content-disposition',
  'access-control-max-age': '86400',
};

Middleware _corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response(204, headers: _corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

Handler buildServerHandler({
  required ServerStore store,
  required String authUsername,
  required String authPassword,
}) {
  final router = Router()
    ..get('/', (Request request) {
      return _html(_adminHomeHtml());
    })
    ..get('/api', (Request request) {
      return _html(_adminHomeHtml());
    })
    ..get('/status', (Request request) {
      final info = store.status();
      final clientSha = request.url.queryParameters['clientSha256'];
      final current = info.lastSha256Hex != null &&
          clientSha != null &&
          clientSha.isNotEmpty &&
          clientSha == info.lastSha256Hex;
      return _json({
        'ok': true,
        'version': '1.0.0',
        'snapshotCount': info.snapshotCount,
        'lastUploadAt': info.lastUploadAtIso,
        'lastDeviceName': info.lastDeviceName,
        'lastSha256': info.lastSha256Hex,
        'current': current,
      });
    })
    ..post('/upload', (Request request) async {
      final raw = await request.readAsString();
      if (raw.trim().isEmpty) {
        return _jsonError(400, 'Request body must contain JSON payload.');
      }
      final now = DateTime.now().toUtc();
      final snapshotId = now.millisecondsSinceEpoch.toString();
      final deviceName = request.headers['x-device-name'];
      try {
        final result = store.saveUpload(
          rawJson: raw,
          deviceName: deviceName,
          snapshotId: snapshotId,
          uploadedAtIso: now.toIso8601String(),
        );
        return _json(
          {
            'id': result.id,
            'uploadedAt': result.uploadedAtIso,
            'sha256': result.sha256Hex,
            'clients': result.clientsCount,
            'transactions': result.transactionsCount,
          },
          statusCode: 201,
        );
      } on FormatException catch (e) {
        return _jsonError(400, 'Invalid payload: ${e.message}');
      } catch (_) {
        return _jsonError(500, 'Failed to save upload.');
      }
    })
    ..get('/download/<id>', (Request request, String id) {
      final snap = id == 'latest' ? store.getLatestSnapshot() : store.getSnapshotById(id);
      if (snap == null) {
        return _jsonError(404, 'Snapshot not found.');
      }
      return shelf.Response.ok(
        snap.rawJson,
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'content-disposition': 'attachment; filename="wexcom_backup_${snap.id}.json"',
          'x-snapshot-id': snap.id,
          'x-snapshot-sha256': snap.sha256Hex,
        },
      );
    })
    ..get('/client/<clientId>', (Request request, String clientId) {
      final payload = store.clientPayloadJson(clientId);
      if (payload == null) {
        return _jsonError(404, 'Client not found in mirror.');
      }
      return _json(payload);
    })
    ..get('/all', (Request request) {
      return _json(store.allPayloadJson());
    });

  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addMiddleware(
        basicAuthMiddleware(
          username: authUsername,
          password: authPassword,
        ),
      )
      .addHandler(router.call);
}

Response _json(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return shelf.Response(
    statusCode,
    body: jsonEncode(body),
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

Response _jsonError(int statusCode, String message) {
  return _json({'ok': false, 'error': message}, statusCode: statusCode);
}

Response _html(String html, {int statusCode = 200}) {
  return shelf.Response(
    statusCode,
    body: html,
    headers: const {'content-type': 'text/html; charset=utf-8'},
  );
}

String _adminHomeHtml() {
  return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Wexcom Sync API Docs</title>
  <style>
    :root {
      color-scheme: light dark;
      --bg: #0b1220;
      --panel: #121c2f;
      --panel-soft: #1a2740;
      --text: #e6edf7;
      --muted: #9eb0cb;
      --line: #2a3b5b;
      --blue: #4f8cff;
      --green: #2fb171;
      --amber: #c98a1f;
      --pink: #c95f99;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: Inter, "Segoe UI", Roboto, Arial, sans-serif;
      background: radial-gradient(circle at top, #162440, var(--bg) 55%);
      color: var(--text);
      line-height: 1.45;
    }
    .container {
      width: min(1080px, 92vw);
      margin: 28px auto 40px;
    }
    .hero {
      background: linear-gradient(160deg, rgba(79,140,255,0.22), rgba(201,95,153,0.15));
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 22px;
      margin-bottom: 16px;
    }
    h1 { margin: 0 0 8px; font-size: 1.65rem; }
    p { margin: 8px 0; }
    .muted { color: var(--muted); }
    .toolbar {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 14px;
    }
    a.button, button {
      border: 1px solid transparent;
      background: var(--blue);
      color: #fff;
      border-radius: 10px;
      padding: 8px 12px;
      font-size: 0.94rem;
      text-decoration: none;
      cursor: pointer;
    }
    a.button.secondary, button.secondary {
      background: transparent;
      border-color: var(--line);
      color: var(--text);
    }
    .meta {
      margin-top: 10px;
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }
    .pill {
      border: 1px solid var(--line);
      border-radius: 999px;
      font-size: 0.78rem;
      color: var(--muted);
      padding: 5px 10px;
      background: rgba(18, 28, 47, 0.65);
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 12px;
      margin-top: 12px;
    }
    .endpoint {
      background: linear-gradient(180deg, rgba(18,28,47,0.92), rgba(18,28,47,0.74));
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 14px;
    }
    .endpoint h3 { margin: 8px 0; font-size: 1rem; }
    .method {
      font-weight: 700;
      letter-spacing: 0.04em;
      font-size: 0.78rem;
      border-radius: 8px;
      padding: 3px 8px;
      display: inline-block;
      margin-right: 8px;
    }
    .get { background: rgba(47,177,113,0.22); color: #7ee2b4; }
    .post { background: rgba(201,95,153,0.2); color: #ffadd9; }
    .path { font-family: ui-monospace, SFMono-Regular, Consolas, monospace; }
    .sub {
      margin-top: 8px;
      border-top: 1px dashed var(--line);
      padding-top: 8px;
      color: var(--muted);
      font-size: 0.9rem;
    }
    .inline {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      align-items: center;
      margin-top: 10px;
    }
    input {
      min-width: 240px;
      border: 1px solid var(--line);
      border-radius: 10px;
      padding: 8px 10px;
      color: var(--text);
      background: var(--panel-soft);
    }
    pre {
      margin: 10px 0 0;
      padding: 10px;
      border-radius: 10px;
      border: 1px solid var(--line);
      background: #0a1427;
      font-size: 0.84rem;
      overflow: auto;
      color: #b9cae8;
    }
    code { font-family: ui-monospace, SFMono-Regular, Consolas, monospace; }
    .footer-note {
      margin-top: 18px;
      border: 1px solid rgba(201,138,31,0.5);
      background: rgba(201,138,31,0.12);
      border-radius: 10px;
      padding: 10px 12px;
      color: #f2d6a3;
      font-size: 0.92rem;
    }
    .route-buttons {
      margin-top: 12px;
      background: rgba(18, 28, 47, 0.65);
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 12px;
    }
    .route-buttons h3 {
      margin: 0 0 10px;
      font-size: 0.98rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <section class="hero">
      <h1>Wexcom Sync Server API</h1>
      <p class="muted">
        Reference for every sync endpoint exposed by this server.
        Use these routes for health checks, upload/download snapshots, and client-level sync.
      </p>
      <div class="toolbar">
        <a class="button" href="/api" target="_blank" rel="noreferrer">Explore API</a>
        <a class="button" href="/status" target="_blank" rel="noreferrer">Open server status</a>
        <a class="button secondary" href="/download/latest" target="_blank" rel="noreferrer">Download latest snapshot</a>
        <a class="button secondary" href="/all" target="_blank" rel="noreferrer">Fetch all mirrored data</a>
      </div>
      <div class="meta">
        <span class="pill">Auth: Basic Auth (required)</span>
        <span class="pill">Response format: JSON</span>
        <span class="pill">CORS enabled</span>
      </div>
      <div class="route-buttons">
        <h3>All routes (quick buttons)</h3>
        <div class="toolbar">
          <a class="button" href="/" target="_blank" rel="noreferrer">GET /</a>
          <a class="button" href="/api" target="_blank" rel="noreferrer">GET /api</a>
          <a class="button" href="/status" target="_blank" rel="noreferrer">GET /status</a>
          <a class="button" href="/all" target="_blank" rel="noreferrer">GET /all</a>
          <a class="button" href="/download/latest" target="_blank" rel="noreferrer">GET /download/latest</a>
          <button type="button" class="secondary" onclick="openSnapshot()">GET /download/&lt;id&gt;</button>
          <button type="button" class="secondary" onclick="openClient()">GET /client/&lt;clientId&gt;</button>
          <button type="button" onclick="postSampleUpload()">POST /upload (sample)</button>
        </div>
      </div>
    </section>

    <section class="grid">
      <article class="endpoint">
        <span class="method get">GET</span><span class="path">/status</span>
        <h3>Server health and sync metadata</h3>
        <p class="muted">Returns server availability and latest upload information.</p>
        <div class="sub">
          Optional query: <code>clientSha256</code> to check if client data matches latest server snapshot.
        </div>
        <pre><code>{
  "ok": true,
  "version": "1.0.0",
  "snapshotCount": 3,
  "lastUploadAt": "2026-05-05T11:24:48.412Z",
  "lastDeviceName": "wexcom-mobile",
  "lastSha256": "...",
  "current": false
}</code></pre>
        <div class="inline">
          <input id="clientSha" placeholder="client sha256 (optional)" />
          <button type="button" onclick="openStatusWithHash()">Test with client hash</button>
        </div>
      </article>

      <article class="endpoint">
        <span class="method post">POST</span><span class="path">/upload</span>
        <h3>Upload complete exported payload</h3>
        <p class="muted">
          Accepts the app JSON export and stores it as a new server snapshot.
          Header <code>x-device-name</code> is optional for attribution.
        </p>
        <div class="sub">
          Body: raw export JSON. Returns snapshot metadata including sha256 and counts.
        </div>
        <pre><code>{
  "id": "1714907810210",
  "uploadedAt": "2026-05-05T11:30:10.210Z",
  "sha256": "...",
  "clients": 46,
  "transactions": 902
}</code></pre>
      </article>

      <article class="endpoint">
        <span class="method get">GET</span><span class="path">/download/&lt;id&gt;</span>
        <h3>Download one snapshot JSON</h3>
        <p class="muted">
          Downloads a specific snapshot by id. Use <code>latest</code> for most recent backup.
        </p>
        <div class="sub">
          Response includes file attachment headers and snapshot metadata headers.
        </div>
        <div class="inline">
          <input id="snapshotId" placeholder="snapshot id (or latest)" />
          <button type="button" onclick="openSnapshot()">Open snapshot</button>
        </div>
      </article>

      <article class="endpoint">
        <span class="method get">GET</span><span class="path">/all</span>
        <h3>Read entire mirrored dataset</h3>
        <p class="muted">
          Returns server-side aggregate payload of all clients and transactions.
          Useful for full restore or verification flows.
        </p>
        <div class="sub">No path params required.</div>
      </article>

      <article class="endpoint">
        <span class="method get">GET</span><span class="path">/client/&lt;clientId&gt;</span>
        <h3>Read one client payload</h3>
        <p class="muted">
          Returns one client object and related transactions from the latest mirrored data.
        </p>
        <div class="sub">
          Returns <code>404</code> when client is not found in the mirror.
        </div>
        <div class="inline">
          <input id="clientId" placeholder="source client id (example: 12345)" />
          <button type="button" onclick="openClient()">Open client payload</button>
        </div>
      </article>

      <article class="endpoint">
        <span class="method get">GET</span><span class="path">/</span>
        <h3>Interactive API documentation</h3>
        <p class="muted">
          This page. Open in browser to inspect endpoints and launch quick route checks.
        </p>
        <div class="sub">Use this as a lightweight admin and troubleshooting entrypoint.</div>
      </article>
    </section>

    <div class="footer-note">
      Every route is protected by Basic Auth middleware. Provide valid credentials in app or API client before calling endpoints.
    </div>
  </div>

  <script>
    function openClient() {
      const id = document.getElementById('clientId').value.trim();
      if (!id) return;
      window.open('/client/' + encodeURIComponent(id), '_blank', 'noopener,noreferrer');
    }
    function openSnapshot() {
      const id = document.getElementById('snapshotId').value.trim();
      if (!id) return;
      window.open('/download/' + encodeURIComponent(id), '_blank', 'noopener,noreferrer');
    }
    function openStatusWithHash() {
      const sha = document.getElementById('clientSha').value.trim();
      if (!sha) return;
      window.open('/status?clientSha256=' + encodeURIComponent(sha), '_blank', 'noopener,noreferrer');
    }
    async function postSampleUpload() {
      const samplePayload = {
        clients: [],
        transactions: []
      };
      try {
        const response = await fetch('/upload', {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-device-name': 'api-docs-page'
          },
          body: JSON.stringify(samplePayload)
        });
        const text = await response.text();
        const popup = window.open('', '_blank', 'noopener,noreferrer');
        if (!popup) return;
        popup.document.write('<pre style="font-family: monospace; white-space: pre-wrap; padding: 12px;">' + text.replaceAll('<', '&lt;') + '</pre>');
      } catch (error) {
        alert('Upload request failed: ' + error);
      }
    }
  </script>
</body>
</html>
''';
}

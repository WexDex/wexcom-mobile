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
  <title>Wexcom Server Admin</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; background: #fafafa; color: #111; }
    h1 { margin-top: 0; }
    .card { background: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 16px; margin-bottom: 16px; max-width: 760px; }
    .row { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
    input { padding: 8px; border: 1px solid #bbb; border-radius: 6px; min-width: 260px; }
    button, a.button { padding: 8px 12px; border: 0; border-radius: 6px; background: #1d4ed8; color: #fff; text-decoration: none; cursor: pointer; }
    a.button { display: inline-block; }
    .muted { color: #666; font-size: 14px; }
    code { background: #eee; padding: 2px 4px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Wexcom Sync Server Admin</h1>
  <p class="muted">Quick buttons to inspect server routes.</p>

  <div class="card">
    <h3>Health & Overview</h3>
    <div class="row">
      <a class="button" href="/status" target="_blank" rel="noreferrer">GET /status</a>
      <a class="button" href="/all" target="_blank" rel="noreferrer">GET /all</a>
      <a class="button" href="/download/latest" target="_blank" rel="noreferrer">GET /download/latest</a>
    </div>
  </div>

  <div class="card">
    <h3>Lookup by Client ID</h3>
    <div class="row">
      <input id="clientId" placeholder="source client id (example: 12345)" />
      <button type="button" onclick="openClient()">Open /client/&lt;id&gt;</button>
    </div>
  </div>

  <div class="card">
    <h3>Download by Snapshot ID</h3>
    <div class="row">
      <input id="snapshotId" placeholder="snapshot id (or use latest above)" />
      <button type="button" onclick="openSnapshot()">Open /download/&lt;id&gt;</button>
    </div>
  </div>

  <div class="card">
    <h3>Status hash check</h3>
    <p class="muted">Check if your local payload hash matches server latest hash.</p>
    <div class="row">
      <input id="clientSha" placeholder="client sha256 hex" />
      <button type="button" onclick="openStatusWithHash()">Open /status?clientSha256=...</button>
    </div>
  </div>

  <p class="muted">All routes are protected by Basic Auth.</p>

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
  </script>
</body>
</html>
''';
}

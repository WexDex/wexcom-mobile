import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

const _version = '2.0.0';
const _maxSnapshots = 20;

// ─── Entry point ─────────────────────────────────────────────────────────────

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8787')
    ..addOption('user', defaultsTo: '')
    ..addOption('pass', defaultsTo: '')
    ..addOption('data-dir', defaultsTo: '.')
    ..addFlag('version', negatable: false);

  final result = parser.parse(args);

  if (result['version'] as bool) {
    print('wexcom-cloud-server v$_version');
    exit(0);
  }

  final port = int.tryParse(result['port'] as String) ?? 8787;
  final dataDir = result['data-dir'] as String;
  final user = (result['user'] as String).isNotEmpty
      ? result['user'] as String
      : Platform.environment['WEXCOM_USER'] ?? 'admin';
  final pass = (result['pass'] as String).isNotEmpty
      ? result['pass'] as String
      : Platform.environment['WEXCOM_PASS'] ?? 'changeme';

  if (user == 'admin' && pass == 'changeme') {
    print('[WARN] Using default credentials — set WEXCOM_USER / WEXCOM_PASS env vars.');
  }

  final snapshotsDir = Directory(p.join(dataDir, 'snapshots'));
  await snapshotsDir.create(recursive: true);

  final server = _WexcomServer(dataDir: dataDir, snapshotsDir: snapshotsDir, user: user, pass: pass);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(server.corsMiddleware)
      .addMiddleware(server.basicAuthMiddleware)
      .addHandler(server.router.call);

  final httpServer = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Wexcom cloud server v$_version  →  http://0.0.0.0:${httpServer.port}');
  print('Data dir   : $dataDir');
  print('Snapshots  : ${snapshotsDir.path}');
  print('Swagger UI : http://localhost:$port/');

  Future<void> shutdown() async {
    await httpServer.close(force: true);
    print('\nServer stopped.');
    exit(0);
  }

  // SIGINT = Ctrl+C in terminal
  ProcessSignal.sigint.watch().listen((_) => shutdown());

  // SIGTERM = sent by Windows when the console window is closed (compiled exe)
  // On Linux/Mac this is also the standard termination signal.
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => shutdown());
  }

  // On Windows the compiled exe receives SIGTERM when the console closes,
  // but as a fallback also watch for stdin EOF (console closed = stdin closes).
  stdin.listen(null, onDone: shutdown);
}

// ─── Snapshot manifest ───────────────────────────────────────────────────────

class _Snapshot {
  _Snapshot({
    required this.id,
    required this.filename,
    required this.uploadedAt,
    required this.sizeBytes,
    required this.sha256,
    this.label,
  });

  factory _Snapshot.fromJson(Map<String, dynamic> j) => _Snapshot(
        id: j['id'] as String,
        filename: j['filename'] as String,
        uploadedAt: j['uploaded_at'] as String,
        sizeBytes: j['size_bytes'] as int,
        sha256: j['sha256'] as String,
        label: j['label'] as String?,
      );

  final String id;
  final String filename;
  final String uploadedAt;
  final int sizeBytes;
  final String sha256;
  final String? label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'uploaded_at': uploadedAt,
        'size_bytes': sizeBytes,
        'sha256': sha256,
        if (label != null) 'label': label,
      };
}

// ─── Server ──────────────────────────────────────────────────────────────────

class _WexcomServer {
  _WexcomServer({
    required this.dataDir,
    required this.snapshotsDir,
    required this.user,
    required this.pass,
  }) : _manifestFile = File(p.join(snapshotsDir.path, 'manifest.json'));

  final String dataDir;
  final Directory snapshotsDir;
  final String user;
  final String pass;
  final File _manifestFile;

  static const _publicPaths = {'/', '/openapi.json', '/ping'};

  late final router = Router()
    // ── public ──────────────────────────────────────────────────────────────
    ..get('/', _handleDocs)
    ..get('/openapi.json', _handleOpenApiSpec)
    ..get('/ping', _handlePing)
    // ── authenticated ───────────────────────────────────────────────────────
    ..get('/status', _handleStatus)
    ..get('/snapshots', _handleListSnapshots)
    ..post('/upload', _handleUpload)
    ..get('/download', _handleDownloadLatest)
    ..get('/download/<id>', _handleDownloadById)
    ..delete('/snapshots/<id>', _handleDeleteSnapshot)
    ..get('/clients', _handleListClients)
    ..get('/clients/<id>', _handleGetClient);

  // ── CORS middleware ───────────────────────────────────────────────────────

  Middleware get corsMiddleware => (inner) => (req) async {
        if (req.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final res = await inner(req);
        return res.change(headers: _corsHeaders);
      };

  static const _corsHeaders = {
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, DELETE, OPTIONS',
    'access-control-allow-headers': 'Authorization, Content-Type',
  };

  // ── Basic Auth middleware ─────────────────────────────────────────────────

  Middleware get basicAuthMiddleware => (inner) => (req) {
        final path = req.url.path.isEmpty ? '/' : '/${req.url.path}';
        if (_publicPaths.contains(path)) return inner(req);
        final auth = req.headers['authorization'] ?? '';
        if (!_isAuthorized(auth)) {
          return Response(
            401,
            headers: {
              'www-authenticate': 'Basic realm="Wexcom"',
              'content-type': 'application/json',
              ..._corsHeaders,
            },
            body: jsonEncode({'ok': false, 'error': 'Unauthorized'}),
          );
        }
        return inner(req);
      };

  bool _isAuthorized(String authHeader) {
    if (!authHeader.startsWith('Basic ')) return false;
    try {
      final decoded = utf8.decode(base64.decode(authHeader.substring(6)));
      final colon = decoded.indexOf(':');
      if (colon < 0) return false;
      final reqUser = decoded.substring(0, colon);
      final reqPass = decoded.substring(colon + 1);
      final expected = sha256.convert(utf8.encode('$user:$pass')).toString();
      final actual = sha256.convert(utf8.encode('$reqUser:$reqPass')).toString();
      return expected == actual;
    } catch (_) {
      return false;
    }
  }

  // ── GET / — Swagger UI ────────────────────────────────────────────────────

  Future<Response> _handleDocs(Request request) async {
    const html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Wexcom Cloud API</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
  <style>
    *, *::before, *::after { box-sizing: border-box; }

    body { margin: 0; background: #0f172a; }

    /* ── Layout ── */
    .swagger-ui { background: #0f172a; color: #e2e8f0; font-family: ui-sans-serif, system-ui, sans-serif; }
    .swagger-ui .wrapper { padding: 0 16px; }

    /* ── Topbar ── */
    .swagger-ui .topbar { background: #020617; border-bottom: 1px solid #1e293b; padding: 10px 0; }
    .swagger-ui .topbar .topbar-wrapper { padding: 0 16px; }
    .swagger-ui .topbar .topbar-wrapper .link { display: flex; align-items: center; gap: 8px; }
    .swagger-ui .topbar .topbar-wrapper .link span { color: #38bdf8; font-size: 20px; font-weight: 700; letter-spacing: -.5px; }
    .swagger-ui .topbar .download-url-wrapper { display: none; }

    /* ── Info block ── */
    .swagger-ui .information-container { background: #0f172a; padding: 20px 0 8px; }
    .swagger-ui .info { margin: 0; }
    .swagger-ui .info hgroup.main { margin: 0 0 8px; }
    .swagger-ui .info .title { color: #38bdf8; font-size: 28px; font-weight: 700; }
    .swagger-ui .info .title small { background: #0369a1; color: #fff; border-radius: 4px; padding: 2px 8px; font-size: 13px; vertical-align: middle; margin-left: 8px; }
    .swagger-ui .info p, .swagger-ui .info li { color: #94a3b8; }
    .swagger-ui .info a, .swagger-ui .info a:hover { color: #38bdf8; }
    .swagger-ui .info .base-url { color: #64748b; }

    /* ── Scheme container ── */
    .swagger-ui .scheme-container { background: #0f172a; box-shadow: none; border-bottom: 1px solid #1e293b; padding: 12px 0; }
    .swagger-ui .schemes > label { color: #94a3b8; font-size: 12px; font-weight: 600; }
    .swagger-ui .schemes select { background: #1e293b; color: #e2e8f0; border: 1px solid #334155; border-radius: 6px; padding: 4px 8px; }
    .swagger-ui .auth-wrapper { display: flex; align-items: center; gap: 8px; }

    /* ── Op tags ── */
    .swagger-ui .opblock-tag { color: #e2e8f0; font-size: 18px; font-weight: 600; border-bottom: 1px solid #1e293b; padding: 12px 0; }
    .swagger-ui .opblock-tag:hover { background: transparent; }
    .swagger-ui .opblock-tag small { color: #64748b; font-size: 13px; font-weight: 400; }
    .swagger-ui .opblock-tag-section { margin-bottom: 16px; }

    /* ── Operation blocks ── */
    .swagger-ui .opblock { border-radius: 8px; margin: 6px 0; box-shadow: none; }
    .swagger-ui .opblock.opblock-get    { background: #0c1a2e; border: 1px solid #1d4ed8; }
    .swagger-ui .opblock.opblock-post   { background: #052e16; border: 1px solid #15803d; }
    .swagger-ui .opblock.opblock-delete { background: #2d0a0a; border: 1px solid #991b1b; }
    .swagger-ui .opblock.opblock-put    { background: #1c1200; border: 1px solid #b45309; }
    .swagger-ui .opblock.opblock-patch  { background: #1a1000; border: 1px solid #92400e; }

    .swagger-ui .opblock .opblock-summary { border: none; padding: 10px 16px; }
    .swagger-ui .opblock .opblock-summary-path { color: #f1f5f9; font-size: 15px; font-weight: 500; }
    .swagger-ui .opblock .opblock-summary-path__deprecated { color: #64748b; }
    .swagger-ui .opblock .opblock-summary-description { color: #94a3b8; font-size: 13px; }
    .swagger-ui .opblock .opblock-summary-operation-id { color: #64748b; font-size: 12px; }

    .swagger-ui .opblock.is-open .opblock-summary { border-bottom: 1px solid rgba(255,255,255,.07); }
    .swagger-ui .opblock-body { background: transparent; padding: 0; }
    .swagger-ui .opblock-section { padding: 12px 16px; }
    .swagger-ui .opblock-section-header { background: transparent; border: none; }
    .swagger-ui .opblock-section-header h4 { color: #cbd5e1; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
    .swagger-ui .opblock-description-wrapper p { color: #94a3b8; margin: 8px 0; }

    /* ── Method badges ── */
    .swagger-ui .opblock-summary-method { border-radius: 5px; font-size: 12px; font-weight: 700; min-width: 70px; text-align: center; padding: 4px 0; }

    /* ── Parameters ── */
    .swagger-ui table          { background: transparent; border-collapse: collapse; width: 100%; }
    .swagger-ui table thead tr { background: transparent; border-bottom: 1px solid #1e293b; }
    .swagger-ui table thead tr th { color: #64748b; font-size: 12px; font-weight: 600; text-transform: uppercase; padding: 8px; }
    .swagger-ui table tbody tr td { color: #e2e8f0; border-bottom: 1px solid #1e293b; padding: 8px; vertical-align: top; }
    .swagger-ui table tbody tr:last-child td { border-bottom: none; }
    .swagger-ui .parameter__name { color: #38bdf8; font-weight: 600; }
    .swagger-ui .parameter__name.required::after { color: #f43f5e; }
    .swagger-ui .parameter__type { color: #a78bfa; font-size: 12px; }
    .swagger-ui .parameter__in { color: #64748b; font-size: 11px; font-style: italic; }
    .swagger-ui .parameter__deprecated { color: #ef4444; font-size: 11px; }
    .swagger-ui .prop-type { color: #a78bfa; }
    .swagger-ui .prop-format { color: #64748b; }

    /* ── Inputs ── */
    .swagger-ui input[type=text],
    .swagger-ui input[type=email],
    .swagger-ui input[type=password],
    .swagger-ui textarea,
    .swagger-ui select {
      background: #1e293b; color: #e2e8f0; border: 1px solid #334155;
      border-radius: 6px; padding: 6px 10px; font-size: 13px;
    }
    .swagger-ui input[type=text]:focus,
    .swagger-ui textarea:focus { border-color: #38bdf8; outline: none; box-shadow: 0 0 0 3px rgba(56,189,248,.15); }
    .swagger-ui textarea { font-family: ui-monospace, monospace; }

    /* ── Buttons ── */
    .swagger-ui .btn { border-radius: 6px; font-weight: 600; font-size: 13px; padding: 6px 14px; cursor: pointer; }
    .swagger-ui .btn.authorize { background: #0369a1; border: 1px solid #0284c7; color: #fff; }
    .swagger-ui .btn.authorize:hover { background: #0284c7; }
    .swagger-ui .btn.authorize svg { fill: #fff; }
    .swagger-ui .btn.execute  { background: #1d4ed8; border: 1px solid #2563eb; color: #fff; }
    .swagger-ui .btn.execute:hover { background: #2563eb; }
    .swagger-ui .btn.btn-clear { background: transparent; border: 1px solid #475569; color: #94a3b8; }
    .swagger-ui .btn.cancel   { background: transparent; border: 1px solid #475569; color: #94a3b8; }
    .swagger-ui .btn.try-out__btn { background: transparent; border: 1px solid #334155; color: #94a3b8; }
    .swagger-ui .btn.try-out__btn.cancel { border-color: #475569; }
    .swagger-ui .copy-to-clipboard { background: #1e293b; border: 1px solid #334155; border-radius: 4px; }
    .swagger-ui .copy-to-clipboard button { background: transparent; }

    /* ── Responses ── */
    .swagger-ui .responses-inner { padding: 0 16px 16px; }
    .swagger-ui .responses-wrapper { background: transparent; }
    .swagger-ui .response-col_status { color: #e2e8f0; font-weight: 600; }
    .swagger-ui .response-col_description { color: #94a3b8; }
    .swagger-ui .response-col_description .markdown p { color: #94a3b8; margin: 4px 0; }
    .swagger-ui .response { background: #1e293b; border-radius: 6px; padding: 10px; margin: 6px 0; border: 1px solid #334155; }
    .swagger-ui .response .response-col_status { min-width: 60px; }
    .swagger-ui .responses-table tbody tr td:first-child { padding-left: 0; }

    /* ── Code / highlight ── */
    .swagger-ui .highlight-code,
    .swagger-ui .microlight,
    .swagger-ui pre { background: #020617 !important; border-radius: 6px; padding: 12px; border: 1px solid #1e293b; }
    .swagger-ui .microlight span { color: #e2e8f0 !important; }
    .swagger-ui code { color: #a78bfa; font-family: ui-monospace, monospace; font-size: 13px; }
    .swagger-ui pre.version { background: transparent !important; border: none !important; padding: 0 !important; }

    /* ── Live response area ── */
    .swagger-ui .live-responses-table tbody tr td { background: transparent; }
    .swagger-ui .request-url { background: #020617; border: 1px solid #1e293b; border-radius: 6px; padding: 10px; color: #94a3b8; font-size: 13px; }
    .swagger-ui .curl-command { background: #020617; border: 1px solid #1e293b; border-radius: 6px; padding: 10px; color: #94a3b8; font-size: 12px; word-break: break-all; }
    .swagger-ui .request-headers { color: #94a3b8; font-size: 12px; }
    .swagger-ui .response-headers-wrapper { color: #94a3b8; font-size: 12px; }
    .swagger-ui .loading-container .loading { color: #38bdf8; }

    /* ── Status codes ── */
    .swagger-ui .response-control-media-type { background: transparent; }
    .swagger-ui .response-control-media-type__accept-message { color: #94a3b8; font-size: 12px; }
    .swagger-ui table.responses-table .response .col_header { color: #64748b; font-size: 12px; }

    /* ── Models section ── */
    .swagger-ui section.models { background: #0f172a; border: 1px solid #1e293b; border-radius: 8px; margin-top: 20px; }
    .swagger-ui section.models h4 { color: #e2e8f0; font-size: 16px; }
    .swagger-ui section.models .model-container { background: #0f172a; }
    .swagger-ui section.models .model-container:hover { background: #0f172a; }
    .swagger-ui .model-box { background: #1e293b; border-radius: 6px; padding: 10px; }
    .swagger-ui .model { color: #e2e8f0; }
    .swagger-ui .model-title { color: #38bdf8; font-weight: 600; }
    .swagger-ui .model-toggle { color: #94a3b8; }
    .swagger-ui .model .property { color: #e2e8f0; }
    .swagger-ui .model .property.primitive { color: #a78bfa; }
    .swagger-ui .json-schema-2020-12-keyword { color: #94a3b8; }
    .swagger-ui .json-schema-2020-12-keyword__value { color: #38bdf8; }

    /* ── Auth modal ── */
    .swagger-ui .dialog-ux .modal-ux { background: #1e293b; border: 1px solid #334155; border-radius: 12px; box-shadow: 0 25px 50px rgba(0,0,0,.6); }
    .swagger-ui .dialog-ux .modal-ux-header { background: #0f172a; border-bottom: 1px solid #334155; border-radius: 12px 12px 0 0; padding: 16px 20px; }
    .swagger-ui .dialog-ux .modal-ux-header h3 { color: #e2e8f0; font-size: 18px; }
    .swagger-ui .dialog-ux .modal-ux-content { padding: 16px 20px; }
    .swagger-ui .dialog-ux .modal-ux-content p { color: #94a3b8; }
    .swagger-ui .dialog-ux .modal-ux-content h4 { color: #e2e8f0; margin: 12px 0 4px; }
    .swagger-ui .auth-container { padding: 0; }
    .swagger-ui .auth-container .wrapper { border: none; padding: 0; margin: 0; }
    .swagger-ui .auth-container label { color: #94a3b8; font-size: 12px; font-weight: 600; }
    .swagger-ui .auth-container input { background: #0f172a; width: 100%; }
    .swagger-ui .scopes h2 { color: #e2e8f0; }
    .swagger-ui .scope-def { color: #94a3b8; }

    /* ── Arrows / icons ── */
    .swagger-ui .arrow { fill: #94a3b8; }
    .swagger-ui .expand-operation svg { fill: #94a3b8; }

    /* ── Misc ── */
    .swagger-ui hr { border-color: #1e293b; }
    .swagger-ui .servers-title, .swagger-ui .servers > label { color: #94a3b8; }
    .swagger-ui .servers > label select { background: #1e293b; color: #e2e8f0; border-color: #334155; }
    .swagger-ui .renderedMarkdown p { color: #94a3b8; }
    .swagger-ui .markdown p { color: #94a3b8; }
    .swagger-ui .markdown code { color: #38bdf8; background: #1e293b; padding: 1px 5px; border-radius: 4px; }
    .swagger-ui .no-margin { margin: 0; }
    .swagger-ui .filter-container { background: #0f172a; padding: 8px 0; }
    .swagger-ui .filter .operation-filter-input { background: #1e293b; border-color: #334155; color: #e2e8f0; border-radius: 6px; }

    /* ── Scrollbar ── */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: #0f172a; }
    ::-webkit-scrollbar-thumb { background: #334155; border-radius: 3px; }
    ::-webkit-scrollbar-thumb:hover { background: #475569; }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    SwaggerUIBundle({
      url: '/openapi.json',
      dom_id: '#swagger-ui',
      deepLinking: true,
      displayRequestDuration: true,
      defaultModelsExpandDepth: 1,
      defaultModelExpandDepth: 2,
      docExpansion: 'list',
      filter: true,
      tryItOutEnabled: true,
      persistAuthorization: true,
      presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
      layout: 'BaseLayout',
      requestInterceptor: (req) => { req.credentials = 'include'; return req; },
      onComplete: () => {
        // Patch logo text since we can't access topbar SVG easily
        const link = document.querySelector('.topbar-wrapper .link');
        if (link) {
          link.innerHTML = '<span>⚡ Wexcom Cloud API</span>';
        }
      },
    });
  </script>
</body>
</html>''';
    return Response.ok(html, headers: {'content-type': 'text/html; charset=utf-8'});
  }

  // ── GET /openapi.json ─────────────────────────────────────────────────────

  Future<Response> _handleOpenApiSpec(Request request) async {
    final spec = {
      'openapi': '3.0.3',
      'info': {
        'title': 'Wexcom Cloud Server',
        'version': _version,
        'description':
            'SQLite backup server for the Wexcom debt ledger app.\n\n'
            '**Authentication:** All routes except `/ping`, `/`, and `/openapi.json` require **HTTP Basic Auth**.\n\n'
            'Click the **Authorize** button and enter your credentials to try protected endpoints.',
      },
      'servers': [
        {'url': 'http://localhost:8787', 'description': 'Local dev'},
        {'url': 'https://wexcom.wexdex.online', 'description': 'Production'},
      ],
      'components': {
        'securitySchemes': {
          'basicAuth': {'type': 'http', 'scheme': 'basic'},
        },
        'schemas': {
          'Ok': {
            'type': 'object',
            'properties': {
              'ok': {'type': 'boolean', 'example': true},
            },
          },
          'Error': {
            'type': 'object',
            'properties': {
              'ok': {'type': 'boolean', 'example': false},
              'error': {'type': 'string'},
            },
          },
          'StatusResponse': {
            'type': 'object',
            'properties': {
              'ok': {'type': 'boolean'},
              'version': {'type': 'string', 'example': _version},
              'snapshot_count': {'type': 'integer', 'example': 3},
              'latest_snapshot': {r'$ref': '#/components/schemas/Snapshot', 'nullable': true},
              'server_time': {'type': 'string', 'format': 'date-time'},
            },
          },
          'Snapshot': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string', 'example': '1715595600_a3f2c1b4'},
              'filename': {'type': 'string'},
              'uploaded_at': {'type': 'string', 'format': 'date-time'},
              'size_bytes': {'type': 'integer', 'example': 204800},
              'sha256': {'type': 'string', 'example': 'a3f2c1d4...'},
              'label': {'type': 'string', 'nullable': true, 'example': 'before-migration'},
            },
          },
          'UploadResponse': {
            'type': 'object',
            'properties': {
              'ok': {'type': 'boolean'},
              'snapshot': {r'$ref': '#/components/schemas/Snapshot'},
              'pruned': {'type': 'integer', 'description': 'Number of old snapshots pruned'},
            },
          },
          'ClientSummary': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
              'name': {'type': 'string'},
              'phone': {'type': 'string', 'nullable': true},
              'balance_minor': {'type': 'integer', 'example': 125000},
              'is_archived': {'type': 'boolean'},
            },
          },
          'ClientDetail': {
            'type': 'object',
            'properties': {
              'ok': {'type': 'boolean'},
              'client': {r'$ref': '#/components/schemas/ClientSummary'},
              'transactions': {
                'type': 'array',
                'items': {r'$ref': '#/components/schemas/Transaction'},
              },
              'transaction_count': {'type': 'integer'},
            },
          },
          'Transaction': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
              'amount_minor': {'type': 'integer', 'example': 50000},
              'tx_type': {'type': 'integer', 'description': '0=debt, 1=payment'},
              'tx_status': {'type': 'integer', 'description': '0=active, 1=settled, 2=cancelled'},
              'note': {'type': 'string', 'nullable': true},
              'reference_no': {'type': 'string', 'nullable': true},
              'effective_at': {'type': 'integer', 'description': 'Unix ms timestamp'},
              'due_at': {'type': 'integer', 'nullable': true, 'description': 'Unix ms timestamp'},
              'created_at': {'type': 'integer', 'description': 'Unix ms timestamp'},
            },
          },
        },
      },
      'security': [
        {'basicAuth': []},
      ],
      'paths': {
        '/ping': {
          'get': {
            'summary': 'Health ping',
            'description': 'Public endpoint. Returns `ok: true` when the server is reachable. No auth required.',
            'operationId': 'ping',
            'tags': ['Server'],
            'security': [],
            'responses': {
              '200': {
                'description': 'Server is alive',
                'content': {
                  'application/json': {'schema': {r'$ref': '#/components/schemas/Ok'}},
                },
              },
            },
          },
        },
        '/status': {
          'get': {
            'summary': 'Server status',
            'description': 'Returns version, snapshot count, and details of the latest snapshot.',
            'operationId': 'getStatus',
            'tags': ['Server'],
            'responses': {
              '200': {
                'description': 'Server is up',
                'content': {
                  'application/json': {'schema': {r'$ref': '#/components/schemas/StatusResponse'}},
                },
              },
              '401': {'description': 'Unauthorized', 'content': {'application/json': {'schema': {r'$ref': '#/components/schemas/Error'}}}},
            },
          },
        },
        '/snapshots': {
          'get': {
            'summary': 'List all snapshots',
            'description': 'Returns all stored snapshots, newest first. Max $_maxSnapshots snapshots are retained.',
            'operationId': 'listSnapshots',
            'tags': ['Snapshots'],
            'responses': {
              '200': {
                'description': 'Snapshot list',
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'ok': {'type': 'boolean'},
                        'snapshots': {'type': 'array', 'items': {r'$ref': '#/components/schemas/Snapshot'}},
                        'count': {'type': 'integer'},
                      },
                    },
                  },
                },
              },
              '401': {'description': 'Unauthorized'},
            },
          },
        },
        '/upload': {
          'post': {
            'summary': 'Upload database snapshot',
            'description':
                'Uploads a raw SQLite file as `multipart/form-data` (field name `db_file`). '
                'Creates a new versioned snapshot. Oldest snapshots are pruned when the limit of $_maxSnapshots is reached. '
                'Optional `label` field for a human-readable name.',
            'operationId': 'uploadSnapshot',
            'tags': ['Snapshots'],
            'requestBody': {
              'required': true,
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'required': ['db_file'],
                    'properties': {
                      'db_file': {'type': 'string', 'format': 'binary', 'description': 'Raw SQLite database file.'},
                      'label': {'type': 'string', 'description': 'Optional human-readable label (e.g. "before-migration").'},
                    },
                  },
                },
              },
            },
            'responses': {
              '200': {
                'description': 'Snapshot created',
                'content': {'application/json': {'schema': {r'$ref': '#/components/schemas/UploadResponse'}}},
              },
              '400': {'description': 'Bad request'},
              '401': {'description': 'Unauthorized'},
            },
          },
        },
        '/download': {
          'get': {
            'summary': 'Download latest snapshot',
            'description': 'Streams the most recently uploaded SQLite file. Returns 404 if no snapshots exist.',
            'operationId': 'downloadLatest',
            'tags': ['Snapshots'],
            'responses': {
              '200': {
                'description': 'SQLite file',
                'headers': {
                  'x-sha256': {'schema': {'type': 'string'}, 'description': 'SHA-256 hex digest'},
                  'x-snapshot-id': {'schema': {'type': 'string'}, 'description': 'Snapshot ID'},
                },
                'content': {'application/octet-stream': {'schema': {'type': 'string', 'format': 'binary'}}},
              },
              '401': {'description': 'Unauthorized'},
              '404': {'description': 'No snapshots yet'},
            },
          },
        },
        '/download/{id}': {
          'get': {
            'summary': 'Download snapshot by ID',
            'description': 'Download a specific snapshot. Use `GET /snapshots` to list available IDs.',
            'operationId': 'downloadById',
            'tags': ['Snapshots'],
            'parameters': [
              {
                'name': 'id',
                'in': 'path',
                'required': true,
                'description': 'Snapshot ID from `GET /snapshots`',
                'schema': {'type': 'string'},
              },
            ],
            'responses': {
              '200': {
                'description': 'SQLite file',
                'content': {'application/octet-stream': {'schema': {'type': 'string', 'format': 'binary'}}},
              },
              '401': {'description': 'Unauthorized'},
              '404': {'description': 'Snapshot not found'},
            },
          },
        },
        '/snapshots/{id}': {
          'delete': {
            'summary': 'Delete a snapshot',
            'description': 'Permanently deletes a specific snapshot file and removes it from the manifest.',
            'operationId': 'deleteSnapshot',
            'tags': ['Snapshots'],
            'parameters': [
              {
                'name': 'id',
                'in': 'path',
                'required': true,
                'schema': {'type': 'string'},
              },
            ],
            'responses': {
              '200': {'description': 'Deleted', 'content': {'application/json': {'schema': {r'$ref': '#/components/schemas/Ok'}}}},
              '401': {'description': 'Unauthorized'},
              '404': {'description': 'Snapshot not found'},
            },
          },
        },
        '/clients': {
          'get': {
            'summary': 'List all clients',
            'description': 'Queries the latest snapshot SQLite file and returns all clients with their balances. Returns 503 if no snapshot exists.',
            'operationId': 'listClients',
            'tags': ['Data'],
            'responses': {
              '200': {
                'description': 'Client list',
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'ok': {'type': 'boolean'},
                        'clients': {'type': 'array', 'items': {r'$ref': '#/components/schemas/ClientSummary'}},
                        'count': {'type': 'integer'},
                        'snapshot_id': {'type': 'string'},
                      },
                    },
                  },
                },
              },
              '401': {'description': 'Unauthorized'},
              '503': {'description': 'No snapshot available'},
            },
          },
        },
        '/clients/{id}': {
          'get': {
            'summary': 'Client detail + transactions',
            'description': 'Returns a single client and their full transaction history from the latest snapshot.',
            'operationId': 'getClient',
            'tags': ['Data'],
            'parameters': [
              {
                'name': 'id',
                'in': 'path',
                'required': true,
                'description': 'Client UUID',
                'schema': {'type': 'string'},
              },
            ],
            'responses': {
              '200': {
                'description': 'Client with transactions',
                'content': {'application/json': {'schema': {r'$ref': '#/components/schemas/ClientDetail'}}},
              },
              '401': {'description': 'Unauthorized'},
              '404': {'description': 'Client not found'},
              '503': {'description': 'No snapshot available'},
            },
          },
        },
      },
    };
    return _json(spec);
  }

  // ── GET /ping ─────────────────────────────────────────────────────────────

  Response _handlePing(Request request) =>
      _json({'ok': true, 'time': DateTime.now().toIso8601String()});

  // ── GET /status ───────────────────────────────────────────────────────────

  Future<Response> _handleStatus(Request request) async {
    final snapshots = await _loadManifest();
    return _json({
      'ok': true,
      'version': _version,
      'snapshot_count': snapshots.length,
      'latest_snapshot': snapshots.isNotEmpty ? snapshots.last.toJson() : null,
      'server_time': DateTime.now().toIso8601String(),
    });
  }

  // ── GET /snapshots ────────────────────────────────────────────────────────

  Future<Response> _handleListSnapshots(Request request) async {
    final snapshots = await _loadManifest();
    return _json({
      'ok': true,
      'snapshots': snapshots.reversed.map((s) => s.toJson()).toList(),
      'count': snapshots.length,
    });
  }

  // ── POST /upload ──────────────────────────────────────────────────────────

  Future<Response> _handleUpload(Request request) async {
    final contentType = request.headers['content-type'] ?? '';
    if (!contentType.contains('multipart/form-data')) {
      return _jsonError(400, 'Expected multipart/form-data');
    }
    final boundary = _parseBoundary(contentType);
    if (boundary == null) return _jsonError(400, 'Missing multipart boundary');

    final body = await request.read().expand((c) => c).toList();
    final fileBytes = _extractMultipartField(body, boundary, 'db_file');
    if (fileBytes == null || fileBytes.isEmpty) {
      return _jsonError(400, 'Missing db_file field in multipart body');
    }
    final labelBytes = _extractMultipartField(body, boundary, 'label');
    final label = labelBytes != null ? utf8.decode(labelBytes).trim() : null;

    final hash = sha256.convert(fileBytes).toString();
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch ~/ 1000}_${hash.substring(0, 8)}';
    final filename = '$id.sqlite';
    final dest = File(p.join(snapshotsDir.path, filename));
    await dest.writeAsBytes(fileBytes);

    final snapshot = _Snapshot(
      id: id,
      filename: filename,
      uploadedAt: now.toIso8601String(),
      sizeBytes: fileBytes.length,
      sha256: hash,
      label: (label != null && label.isNotEmpty) ? label : null,
    );

    var snapshots = await _loadManifest();
    snapshots.add(snapshot);

    // Prune oldest if over limit
    var pruned = 0;
    while (snapshots.length > _maxSnapshots) {
      final old = snapshots.removeAt(0);
      final oldFile = File(p.join(snapshotsDir.path, old.filename));
      if (await oldFile.exists()) await oldFile.delete();
      pruned++;
    }

    await _saveManifest(snapshots);
    print('[upload] $id  ${fileBytes.length} bytes  sha256:${hash.substring(0, 12)}…');

    return _json({'ok': true, 'snapshot': snapshot.toJson(), 'pruned': pruned});
  }

  // ── GET /download ─────────────────────────────────────────────────────────

  Future<Response> _handleDownloadLatest(Request request) async {
    final snapshots = await _loadManifest();
    if (snapshots.isEmpty) return _jsonError(404, 'No snapshots available — upload first');
    return _streamSnapshot(snapshots.last);
  }

  // ── GET /download/:id ─────────────────────────────────────────────────────

  Future<Response> _handleDownloadById(Request request, String id) async {
    final snapshots = await _loadManifest();
    final snap = snapshots.where((s) => s.id == id).firstOrNull;
    if (snap == null) return _jsonError(404, 'Snapshot "$id" not found');
    return _streamSnapshot(snap);
  }

  Future<Response> _streamSnapshot(_Snapshot snap) async {
    final file = File(p.join(snapshotsDir.path, snap.filename));
    if (!await file.exists()) return _jsonError(404, 'Snapshot file missing on disk');
    final bytes = await file.readAsBytes();
    return Response.ok(bytes, headers: {
      'content-type': 'application/octet-stream',
      'content-disposition': 'attachment; filename="wexcom-${snap.id}.sqlite"',
      'content-length': '${bytes.length}',
      'x-sha256': snap.sha256,
      'x-snapshot-id': snap.id,
    });
  }

  // ── DELETE /snapshots/:id ─────────────────────────────────────────────────

  Future<Response> _handleDeleteSnapshot(Request request, String id) async {
    var snapshots = await _loadManifest();
    final idx = snapshots.indexWhere((s) => s.id == id);
    if (idx < 0) return _jsonError(404, 'Snapshot "$id" not found');
    final snap = snapshots.removeAt(idx);
    final file = File(p.join(snapshotsDir.path, snap.filename));
    if (await file.exists()) await file.delete();
    await _saveManifest(snapshots);
    print('[delete] snapshot $id');
    return _json({'ok': true});
  }

  // ── GET /clients ──────────────────────────────────────────────────────────

  Future<Response> _handleListClients(Request request) async {
    final (db, snapId, err) = _openLatestSnapshot();
    if (err != null) return _jsonError(503, err);

    try {
      final rows = db!.select(
        'SELECT id, name, phone, balance_minor, is_archived FROM clients ORDER BY name',
      );
      return _json({
        'ok': true,
        'clients': rows.map((r) => _rowToClientSummary(r)).toList(),
        'count': rows.length,
        'snapshot_id': snapId,
      });
    } catch (e) {
      return _jsonError(500, 'Query error: $e');
    } finally {
      db?.dispose();
    }
  }

  // ── GET /clients/:id ─────────────────────────────────────────────────────

  Future<Response> _handleGetClient(Request request, String id) async {
    final (db, snapId, err) = _openLatestSnapshot();
    if (err != null) return _jsonError(503, err);

    try {
      final clients = db!.select(
        'SELECT id, name, phone, note, balance_minor, is_archived, created_at, updated_at FROM clients WHERE id = ?',
        [id],
      );
      if (clients.isEmpty) return _jsonError(404, 'Client "$id" not found in latest snapshot');

      final txRows = db.select(
        'SELECT id, amount_minor, tx_type, tx_status, note, reference_no, effective_at, due_at, created_at '
        'FROM ledger_transactions WHERE client_id = ? ORDER BY effective_at DESC, created_at DESC',
        [id],
      );

      final client = clients.first;
      return _json({
        'ok': true,
        'snapshot_id': snapId,
        'client': {
          'id': client['id'],
          'name': client['name'],
          'phone': client['phone'],
          'note': client['note'],
          'balance_minor': client['balance_minor'],
          'is_archived': (client['is_archived'] as int) == 1,
          'created_at': client['created_at'],
          'updated_at': client['updated_at'],
        },
        'transactions': txRows.map((r) => {
              'id': r['id'],
              'amount_minor': r['amount_minor'],
              'tx_type': r['tx_type'],
              'tx_status': r['tx_status'],
              'note': r['note'],
              'reference_no': r['reference_no'],
              'effective_at': r['effective_at'],
              'due_at': r['due_at'],
              'created_at': r['created_at'],
            }).toList(),
        'transaction_count': txRows.length,
      });
    } catch (e) {
      return _jsonError(500, 'Query error: $e');
    } finally {
      db?.dispose();
    }
  }

  // ── sqlite3 helpers ───────────────────────────────────────────────────────

  (Database?, String?, String?) _openLatestSnapshot() {
    // Returns (db, snapshotId, errorMessage)
    final snapshots = File(_manifestFile.path).existsSync()
        ? (_loadManifestSync())
        : <_Snapshot>[];
    if (snapshots.isEmpty) return (null, null, 'No snapshots available — upload first');
    final snap = snapshots.last;
    final file = File(p.join(snapshotsDir.path, snap.filename));
    if (!file.existsSync()) return (null, null, 'Latest snapshot file missing on disk');
    try {
      final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
      return (db, snap.id, null);
    } catch (e) {
      return (null, null, 'Cannot open SQLite file: $e');
    }
  }

  Map<String, dynamic> _rowToClientSummary(Row r) => {
        'id': r['id'],
        'name': r['name'],
        'phone': r['phone'],
        'balance_minor': r['balance_minor'],
        'is_archived': (r['is_archived'] as int) == 1,
      };

  // ── Manifest helpers ──────────────────────────────────────────────────────

  Future<List<_Snapshot>> _loadManifest() async {
    if (!await _manifestFile.exists()) return [];
    try {
      final raw = jsonDecode(await _manifestFile.readAsString()) as List<dynamic>;
      return raw.map((j) => _Snapshot.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  List<_Snapshot> _loadManifestSync() {
    if (!_manifestFile.existsSync()) return [];
    try {
      final raw = jsonDecode(_manifestFile.readAsStringSync()) as List<dynamic>;
      return raw.map((j) => _Snapshot.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveManifest(List<_Snapshot> snapshots) async {
    await _manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(snapshots.map((s) => s.toJson()).toList()),
    );
  }

  // ── Generic helpers ───────────────────────────────────────────────────────

  Response _json(dynamic data, {int status = 200}) => Response(
        status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json'},
      );

  Response _jsonError(int status, String message) =>
      _json({'ok': false, 'error': message}, status: status);

  String? _parseBoundary(String contentType) {
    for (final part in contentType.split(';')) {
      final t = part.trim();
      if (t.startsWith('boundary=')) return t.substring('boundary='.length).replaceAll('"', '');
    }
    return null;
  }

  List<int>? _extractMultipartField(List<int> body, String boundary, String fieldName) {
    final delimBytes = utf8.encode('--$boundary');
    final parts = _splitBytes(body, delimBytes);
    for (final part in parts) {
      if (part.isEmpty) continue;
      final headerEnd = _indexOfSequence(part, [13, 10, 13, 10]);
      if (headerEnd < 0) continue;
      final headers = utf8.decode(part.sublist(0, headerEnd), allowMalformed: true);
      if (!headers.contains('name="$fieldName"') &&
          !headers.contains("name='$fieldName'") &&
          !headers.contains('name=$fieldName')) { continue; }
      var content = part.sublist(headerEnd + 4);
      if (content.length >= 2 && content[content.length - 2] == 13 && content[content.length - 1] == 10) {
        content = content.sublist(0, content.length - 2);
      }
      return content;
    }
    return null;
  }

  List<List<int>> _splitBytes(List<int> data, List<int> delimiter) {
    final result = <List<int>>[];
    var start = 0;
    while (true) {
      final idx = _indexOfSequence(data, delimiter, start);
      if (idx < 0) break;
      result.add(data.sublist(start, idx));
      start = idx + delimiter.length;
    }
    result.add(data.sublist(start));
    return result;
  }

  int _indexOfSequence(List<int> data, List<int> seq, [int from = 0]) {
    outer:
    for (var i = from; i <= data.length - seq.length; i++) {
      for (var j = 0; j < seq.length; j++) {
        if (data[i + j] != seq[j]) continue outer;
      }
      return i;
    }
    return -1;
  }
}

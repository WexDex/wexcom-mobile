import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'store.dart';

Handler buildServerHandler({
  required ServerStore store,
  required String authUsername,
  required String authPassword,
}) {
  final router = Router()
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
      .addMiddleware(corsHeaders())
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

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

import 'ingest.dart';

class UploadSaveResult {
  const UploadSaveResult({
    required this.id,
    required this.uploadedAtIso,
    required this.sha256Hex,
    required this.clientsCount,
    required this.transactionsCount,
  });

  final String id;
  final String uploadedAtIso;
  final String sha256Hex;
  final int clientsCount;
  final int transactionsCount;
}

class SnapshotRecord {
  const SnapshotRecord({
    required this.id,
    required this.uploadedAtIso,
    required this.deviceName,
    required this.sizeBytes,
    required this.sha256Hex,
    required this.rawJson,
  });

  final String id;
  final String uploadedAtIso;
  final String? deviceName;
  final int sizeBytes;
  final String sha256Hex;
  final String rawJson;
}

class ServerStatusInfo {
  const ServerStatusInfo({
    required this.snapshotCount,
    required this.lastUploadAtIso,
    required this.lastDeviceName,
    required this.lastSha256Hex,
  });

  final int snapshotCount;
  final String? lastUploadAtIso;
  final String? lastDeviceName;
  final String? lastSha256Hex;
}

class ServerStore {
  ServerStore._(this._db);

  final Database _db;

  static ServerStore open(String dbPath) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      file.parent.createSync(recursive: true);
      file.createSync(recursive: true);
    }
    final db = sqlite3.open(dbPath);
    final store = ServerStore._(db);
    store._migrate();
    return store;
  }

  void close() => _db.dispose();

  UploadSaveResult saveUpload({
    required String rawJson,
    required String? deviceName,
    required String snapshotId,
    required String uploadedAtIso,
  }) {
    final sha = sha256.convert(utf8.encode(rawJson)).toString();
    final payload = parseExportPayload(rawJson);
    final sizeBytes = utf8.encode(rawJson).length;
    final txCount = payload.clients.fold<int>(
      0,
      (sum, c) => sum + c.transactions.length,
    );

    _db.execute('BEGIN TRANSACTION');
    try {
      _db.execute(
        '''
        INSERT INTO snapshots (
          id, uploaded_at, device_name, size_bytes, sha256, raw_json
        ) VALUES (?, ?, ?, ?, ?, ?)
        ''',
        [snapshotId, uploadedAtIso, deviceName, sizeBytes, sha, rawJson],
      );
      _replaceMirror(payload: payload, snapshotId: snapshotId);
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }

    return UploadSaveResult(
      id: snapshotId,
      uploadedAtIso: uploadedAtIso,
      sha256Hex: sha,
      clientsCount: payload.clients.length,
      transactionsCount: txCount,
    );
  }

  SnapshotRecord? getSnapshotById(String id) {
    final result = _db.select(
      '''
      SELECT id, uploaded_at, device_name, size_bytes, sha256, raw_json
      FROM snapshots
      WHERE id = ?
      LIMIT 1
      ''',
      [id],
    );
    if (result.isEmpty) return null;
    final row = result.first;
    return SnapshotRecord(
      id: row['id'] as String,
      uploadedAtIso: row['uploaded_at'] as String,
      deviceName: row['device_name'] as String?,
      sizeBytes: row['size_bytes'] as int,
      sha256Hex: row['sha256'] as String,
      rawJson: row['raw_json'] as String,
    );
  }

  SnapshotRecord? getLatestSnapshot() {
    final result = _db.select(
      '''
      SELECT id, uploaded_at, device_name, size_bytes, sha256, raw_json
      FROM snapshots
      ORDER BY uploaded_at DESC, id DESC
      LIMIT 1
      ''',
    );
    if (result.isEmpty) return null;
    final row = result.first;
    return SnapshotRecord(
      id: row['id'] as String,
      uploadedAtIso: row['uploaded_at'] as String,
      deviceName: row['device_name'] as String?,
      sizeBytes: row['size_bytes'] as int,
      sha256Hex: row['sha256'] as String,
      rawJson: row['raw_json'] as String,
    );
  }

  ServerStatusInfo status() {
    final countResult = _db.select('SELECT COUNT(*) AS c FROM snapshots');
    final latest = getLatestSnapshot();
    return ServerStatusInfo(
      snapshotCount: (countResult.first['c'] as int?) ?? 0,
      lastUploadAtIso: latest?.uploadedAtIso,
      lastDeviceName: latest?.deviceName,
      lastSha256Hex: latest?.sha256Hex,
    );
  }

  Map<String, dynamic> allPayloadJson() {
    final clients = _db.select(
      '''
      SELECT
        source_client_id,
        full_name,
        phone,
        note,
        source,
        created_at,
        last_interaction_at,
        archived_at
      FROM mirror_clients
      ORDER BY full_name ASC, source_client_id ASC
      ''',
    );
    final clientList = clients.map((row) => _clientJson(row)).toList();
    return {
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'clients': clientList,
    };
  }

  Map<String, dynamic>? clientPayloadJson(String clientId) {
    final clients = _db.select(
      '''
      SELECT
        source_client_id,
        full_name,
        phone,
        note,
        source,
        created_at,
        last_interaction_at,
        archived_at
      FROM mirror_clients
      WHERE source_client_id = ?
      LIMIT 1
      ''',
      [clientId],
    );
    if (clients.isEmpty) return null;
    return {
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'clients': [_clientJson(clients.first)],
    };
  }

  Map<String, dynamic> _clientJson(Row row) {
    final clientId = row['source_client_id'] as String;
    final tags = _db.select(
      '''
      SELECT tag_name, scope, color_hex
      FROM mirror_client_tags
      WHERE source_client_id = ?
      ORDER BY tag_name ASC
      ''',
      [clientId],
    );
    final txs = _db.select(
      '''
      SELECT
        tx_id,
        amount_minor,
        currency_code,
        tx_type,
        tx_status,
        note,
        created_at,
        effective_at
      FROM mirror_transactions
      WHERE source_client_id = ?
      ORDER BY effective_at ASC, created_at ASC, tx_id ASC
      ''',
      [clientId],
    );
    final txList = txs.map((tx) {
      final txId = tx['tx_id'] as String;
      final txTags = _db.select(
        '''
        SELECT tag_name, scope, color_hex
        FROM mirror_transaction_tags
        WHERE tx_id = ?
        ORDER BY tag_name ASC
        ''',
        [txId],
      );
      return {
        'sourceTransactionId': tx['tx_id'],
        'amountMinor': tx['amount_minor'],
        'currencyCode': tx['currency_code'],
        'txType': tx['tx_type'],
        'txStatus': tx['tx_status'],
        'note': tx['note'],
        'createdAt': tx['created_at'],
        'effectiveAt': tx['effective_at'],
        'tags': txTags
            .map(
              (t) => {
                'name': t['tag_name'],
                'scope': t['scope'],
                'colorHex': t['color_hex'],
              },
            )
            .toList(),
      };
    }).toList();
    return {
      'sourceClientId': clientId,
      'fullName': row['full_name'],
      'phone': row['phone'],
      'note': row['note'],
      'source': row['source'],
      'createdAt': row['created_at'],
      'lastInteractionAt': row['last_interaction_at'],
      'archivedAt': row['archived_at'],
      'tags': tags
          .map(
            (t) => {
              'name': t['tag_name'],
              'scope': t['scope'],
              'colorHex': t['color_hex'],
            },
          )
          .toList(),
      'transactions': txList,
    };
  }

  void _replaceMirror({
    required ParsedExportPayload payload,
    required String snapshotId,
  }) {
    _db.execute('DELETE FROM mirror_transaction_tags');
    _db.execute('DELETE FROM mirror_client_tags');
    _db.execute('DELETE FROM mirror_tags');
    _db.execute('DELETE FROM mirror_transactions');
    _db.execute('DELETE FROM mirror_clients');

    for (final client in payload.clients) {
      _db.execute(
        '''
        INSERT INTO mirror_clients (
          source_client_id,
          full_name,
          phone,
          note,
          source,
          created_at,
          last_interaction_at,
          archived_at,
          last_upload_id
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          client.sourceClientId,
          client.fullName,
          client.phone,
          client.note,
          client.source ?? 'import',
          client.createdAtIso,
          client.lastInteractionAtIso,
          client.archivedAtIso,
          snapshotId,
        ],
      );

      for (final tag in client.tags) {
        _upsertTag(
          name: tag.name,
          scope: 'client',
          colorHex: tag.colorHex,
          snapshotId: snapshotId,
        );
        _db.execute(
          '''
          INSERT INTO mirror_client_tags (
            source_client_id, tag_name, scope, color_hex, last_upload_id
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          [client.sourceClientId, tag.name, 'client', tag.colorHex, snapshotId],
        );
      }

      for (var i = 0; i < client.transactions.length; i++) {
        final tx = client.transactions[i];
        final txId = (tx.sourceTransactionId != null &&
                tx.sourceTransactionId!.trim().isNotEmpty)
            ? tx.sourceTransactionId!.trim()
            : '${client.sourceClientId}:$i:${tx.createdAtIso}';
        _db.execute(
          '''
          INSERT INTO mirror_transactions (
            tx_id,
            source_client_id,
            amount_minor,
            currency_code,
            tx_type,
            tx_status,
            note,
            created_at,
            effective_at,
            last_upload_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            txId,
            client.sourceClientId,
            tx.amountMinor,
            tx.currencyCode ?? 'DZD',
            tx.txType,
            tx.txStatus,
            tx.note,
            tx.createdAtIso,
            tx.effectiveAtIso,
            snapshotId,
          ],
        );
        for (final tag in tx.tags) {
          _upsertTag(
            name: tag.name,
            scope: 'transaction',
            colorHex: tag.colorHex,
            snapshotId: snapshotId,
          );
          _db.execute(
            '''
            INSERT INTO mirror_transaction_tags (
              tx_id, tag_name, scope, color_hex, last_upload_id
            ) VALUES (?, ?, ?, ?, ?)
            ''',
            [txId, tag.name, 'transaction', tag.colorHex, snapshotId],
          );
        }
      }
    }
  }

  void _upsertTag({
    required String name,
    required String scope,
    required String? colorHex,
    required String snapshotId,
  }) {
    _db.execute(
      '''
      INSERT INTO mirror_tags (name, scope, color_hex, last_upload_id)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(name, scope)
      DO UPDATE SET color_hex = excluded.color_hex, last_upload_id = excluded.last_upload_id
      ''',
      [name, scope, colorHex, snapshotId],
    );
  }

  void _migrate() {
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS snapshots (
        id TEXT PRIMARY KEY,
        uploaded_at TEXT NOT NULL,
        device_name TEXT,
        size_bytes INTEGER NOT NULL,
        sha256 TEXT NOT NULL,
        raw_json TEXT NOT NULL
      )
      ''',
    );
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS mirror_clients (
        source_client_id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone TEXT,
        note TEXT,
        source TEXT,
        created_at TEXT,
        last_interaction_at TEXT,
        archived_at TEXT,
        last_upload_id TEXT NOT NULL
      )
      ''',
    );
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS mirror_transactions (
        tx_id TEXT PRIMARY KEY,
        source_client_id TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        currency_code TEXT,
        tx_type INTEGER NOT NULL,
        tx_status INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        effective_at TEXT,
        last_upload_id TEXT NOT NULL
      )
      ''',
    );
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS mirror_tags (
        name TEXT NOT NULL,
        scope TEXT NOT NULL,
        color_hex TEXT,
        last_upload_id TEXT NOT NULL,
        PRIMARY KEY(name, scope)
      )
      ''',
    );
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS mirror_client_tags (
        source_client_id TEXT NOT NULL,
        tag_name TEXT NOT NULL,
        scope TEXT NOT NULL,
        color_hex TEXT,
        last_upload_id TEXT NOT NULL
      )
      ''',
    );
    _db.execute(
      '''
      CREATE TABLE IF NOT EXISTS mirror_transaction_tags (
        tx_id TEXT NOT NULL,
        tag_name TEXT NOT NULL,
        scope TEXT NOT NULL,
        color_hex TEXT,
        last_upload_id TEXT NOT NULL
      )
      ''',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_snapshots_uploaded_at ON snapshots(uploaded_at DESC)',
    );
    _db.execute(
      '''
      CREATE INDEX IF NOT EXISTS idx_mirror_tx_client_effective_created
      ON mirror_transactions(source_client_id, effective_at, created_at)
      ''',
    );
  }
}

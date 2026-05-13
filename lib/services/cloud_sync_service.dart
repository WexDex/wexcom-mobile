import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class CloudServerStatus {
  const CloudServerStatus({
    required this.ok,
    required this.version,
    required this.lastUploadAt,
    required this.fileSizeBytes,
    required this.dbReady,
    required this.serverTime,
  });

  final bool ok;
  final String? version;
  final DateTime? lastUploadAt;
  final int fileSizeBytes;
  final bool dbReady;
  final DateTime? serverTime;

  factory CloudServerStatus.fromJson(Map<String, dynamic> json) {
    return CloudServerStatus(
      ok: json['ok'] == true,
      version: json['version']?.toString(),
      lastUploadAt: _parseDate(json['last_upload_at']),
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      dbReady: json['db_ready'] == true,
      serverTime: _parseDate(json['server_time']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  String get fileSizeLabel {
    if (fileSizeBytes <= 0) return '—';
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class CloudSyncResult {
  const CloudSyncResult({
    required this.ok,
    this.message,
    this.sha256,
    this.sizeBytes,
    this.uploadedAt,
  });

  const CloudSyncResult.success({String? message, String? sha256, int? sizeBytes, DateTime? uploadedAt})
      : this(ok: true, message: message, sha256: sha256, sizeBytes: sizeBytes, uploadedAt: uploadedAt);

  const CloudSyncResult.failure(String message)
      : this(ok: false, message: message);

  final bool ok;
  final String? message;
  final String? sha256;
  final int? sizeBytes;
  final DateTime? uploadedAt;
}

// ─── Service ─────────────────────────────────────────────────────────────────

class CloudSyncService {
  CloudSyncService({
    required this.serverUrl,
    required this.username,
    required this.password,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String serverUrl;
  final String username;
  final String password;
  final http.Client _client;

  bool get isConfigured =>
      serverUrl.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty;

  // ── Fetch server status ───────────────────────────────────────────────────

  Future<CloudServerStatus?> fetchStatus() async {
    try {
      final response = await _client
          .get(_uri('/status'), headers: _headers())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 401) return null;
      if (response.statusCode != 200) return null;
      final json = _decodeJson(response.body);
      return CloudServerStatus.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ── Upload raw SQLite file ────────────────────────────────────────────────

  Future<CloudSyncResult> uploadDatabase() async {
    try {
      final dbFile = await _dbFile();
      if (!await dbFile.exists()) {
        return const CloudSyncResult.failure('Database file not found.');
      }

      // Copy to temp so Drift's open connection is unaffected
      final tmp = File('${dbFile.path}_upload_tmp');
      await dbFile.copy(tmp.path);

      try {
        final request = http.MultipartRequest('POST', _uri('/upload'))
          ..headers.addAll(_headers())
          ..files.add(await http.MultipartFile.fromPath('db_file', tmp.path,
              filename: 'wexcom.sqlite'));

        final streamed = await request.send().timeout(const Duration(seconds: 30));
        final body = await streamed.stream.bytesToString();

        if (streamed.statusCode == 401) {
          return const CloudSyncResult.failure('Authentication failed — check credentials.');
        }
        if (streamed.statusCode != 200) {
          return CloudSyncResult.failure('Upload failed (HTTP ${streamed.statusCode})');
        }

        final json = _decodeJson(body);
        final uploadedAt = DateTime.tryParse(json['uploaded_at']?.toString() ?? '')?.toLocal();
        return CloudSyncResult.success(
          message: 'Uploaded successfully',
          sha256: json['sha256']?.toString(),
          sizeBytes: (json['size_bytes'] as num?)?.toInt(),
          uploadedAt: uploadedAt ?? DateTime.now(),
        );
      } finally {
        if (await tmp.exists()) await tmp.delete();
      }
    } on SocketException {
      return const CloudSyncResult.failure('Server is offline or unreachable.');
    } on TimeoutException {
      return const CloudSyncResult.failure('Upload timed out.');
    } catch (e) {
      return CloudSyncResult.failure('Upload error: $e');
    }
  }

  // ── Download SQLite file (staged restore) ────────────────────────────────

  Future<CloudSyncResult> downloadDatabase() async {
    try {
      final response = await _client
          .get(_uri('/download'), headers: _downloadHeaders())
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 401) {
        return const CloudSyncResult.failure('Authentication failed — check credentials.');
      }
      if (response.statusCode == 404) {
        return const CloudSyncResult.failure('No backup available on server yet.');
      }
      if (response.statusCode != 200) {
        return CloudSyncResult.failure('Download failed (HTTP ${response.statusCode})');
      }

      // Save to staging file — app applies it on next launch
      final dir = await getApplicationSupportDirectory();
      final restoreFile = File(p.join(dir.path, 'debt_ledger_restore.sqlite'));
      await restoreFile.writeAsBytes(response.bodyBytes);

      final serverSha = response.headers['x-sha256'];
      return CloudSyncResult.success(
        message: 'Downloaded — restart app to apply',
        sha256: serverSha,
        sizeBytes: response.bodyBytes.length,
      );
    } on SocketException {
      return const CloudSyncResult.failure('Server is offline or unreachable.');
    } on TimeoutException {
      return const CloudSyncResult.failure('Download timed out.');
    } catch (e) {
      return CloudSyncResult.failure('Download error: $e');
    }
  }

  // ── Startup: apply pending restore ───────────────────────────────────────

  /// Call this in main() BEFORE Drift initializes.
  static Future<bool> applyPendingRestoreIfAny() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final restore = File(p.join(dir.path, 'debt_ledger_restore.sqlite'));
      if (!await restore.exists()) return false;

      final main = File(p.join(dir.path, 'debt_ledger.sqlite'));
      if (await main.exists()) await main.delete();
      await restore.rename(main.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<File> _dbFile() async {
    final dir = await getApplicationSupportDirectory();
    // Drift's driftDatabase(name: 'debt_ledger') creates debt_ledger.sqlite on most platforms.
    // On Windows/macOS it may also be just 'debt_ledger' without extension.
    final withExt = File(p.join(dir.path, 'debt_ledger.sqlite'));
    if (await withExt.exists()) return withExt;
    return File(p.join(dir.path, 'debt_ledger'));
  }

  Uri _uri(String path) {
    final base = serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final withScheme = base.contains('://') ? base : _guessScheme(base);
    return Uri.parse('$withScheme$path');
  }

  String _guessScheme(String input) {
    final lower = input.toLowerCase();
    final isLocal = lower.startsWith('localhost') ||
        lower.startsWith('127.') ||
        lower.startsWith('10.') ||
        lower.startsWith('192.168.');
    return '${isLocal ? 'http' : 'https'}://$input';
  }

  Map<String, String> _headers() {
    return {
      'authorization': 'Basic ${_basicAuth()}',
    };
  }

  Map<String, String> _downloadHeaders() => _headers();

  String _basicAuth() =>
      base64Encode(utf8.encode('${username.trim()}:${password.trim()}'));

  Map<String, dynamic> _decodeJson(String body) {
    final dynamic node = jsonDecode(body);
    if (node is Map<String, dynamic>) return node;
    throw const FormatException('Unexpected JSON response');
  }
}

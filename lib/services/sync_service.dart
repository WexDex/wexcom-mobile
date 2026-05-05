import 'dart:convert';

import 'package:http/http.dart' as http;

class SyncConnectionConfig {
  const SyncConnectionConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String serverUrl;
  final String username;
  final String password;

  bool get isValid =>
      serverUrl.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty;
}

class ServerStatus {
  const ServerStatus({
    required this.ok,
    required this.version,
    required this.snapshotCount,
    required this.lastUploadAt,
    required this.lastDeviceName,
    required this.lastSha256,
    required this.current,
  });

  final bool ok;
  final String? version;
  final int snapshotCount;
  final DateTime? lastUploadAt;
  final String? lastDeviceName;
  final String? lastSha256;
  final bool current;

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      ok: json['ok'] == true,
      version: json['version']?.toString(),
      snapshotCount: (json['snapshotCount'] as num?)?.toInt() ?? 0,
      lastUploadAt: DateTime.tryParse((json['lastUploadAt'] ?? '').toString())?.toUtc(),
      lastDeviceName: json['lastDeviceName']?.toString(),
      lastSha256: json['lastSha256']?.toString(),
      current: json['current'] == true,
    );
  }
}

class UploadResult {
  const UploadResult({
    required this.id,
    required this.uploadedAt,
    required this.sha256,
    required this.clients,
    required this.transactions,
  });

  final String id;
  final DateTime uploadedAt;
  final String sha256;
  final int clients;
  final int transactions;

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      id: json['id']?.toString() ?? '',
      uploadedAt: DateTime.tryParse((json['uploadedAt'] ?? '').toString())?.toUtc() ??
          DateTime.now().toUtc(),
      sha256: json['sha256']?.toString() ?? '',
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      transactions: (json['transactions'] as num?)?.toInt() ?? 0,
    );
  }
}

class ServerClient {
  const ServerClient({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.balanceMinor,
  });

  final String id;
  final String fullName;
  final String? phone;
  final int balanceMinor;
}

class SyncService {
  SyncService(this._config, {http.Client? client}) : _client = client ?? http.Client();

  final SyncConnectionConfig _config;
  final http.Client _client;

  Future<ServerStatus> getStatus({required String localSha256}) async {
    final uri = _uri('/status', query: {'clientSha256': localSha256});
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 10));
    _throwIfFailed(response);
    return ServerStatus.fromJson(_decodeObject(response.body));
  }

  Future<UploadResult> uploadAll(
    String jsonPayload, {
    String? deviceName,
  }) async {
    final uri = _uri('/upload');
    final headers = _headers();
    if (deviceName != null && deviceName.trim().isNotEmpty) {
      headers['x-device-name'] = deviceName.trim();
    }
    final response = await _client
        .post(uri, headers: headers, body: jsonPayload)
        .timeout(const Duration(seconds: 15));
    _throwIfFailed(response);
    return UploadResult.fromJson(_decodeObject(response.body));
  }

  Future<String> downloadAll() async {
    final response = await _client
        .get(_uri('/all'), headers: _headers())
        .timeout(const Duration(seconds: 15));
    _throwIfFailed(response);
    return response.body;
  }

  Future<String> downloadById(String id) async {
    final response = await _client
        .get(_uri('/download/$id'), headers: _headers())
        .timeout(const Duration(seconds: 15));
    _throwIfFailed(response);
    return response.body;
  }

  Future<String> downloadClient(String clientId) async {
    final response = await _client
        .get(_uri('/client/$clientId'), headers: _headers())
        .timeout(const Duration(seconds: 15));
    _throwIfFailed(response);
    return response.body;
  }

  Future<List<ServerClient>> listClients() async {
    final payload = _decodeObject(await downloadAll());
    final clientsNode = payload['clients'];
    if (clientsNode is! List) return const <ServerClient>[];
    final clients = <ServerClient>[];
    for (final entry in clientsNode.whereType<Map>()) {
      final map = entry.cast<String, dynamic>();
      final txNode = map['transactions'];
      var balanceMinor = 0;
      if (txNode is List) {
        for (final tx in txNode.whereType<Map>()) {
          final txMap = tx.cast<String, dynamic>();
          final type = (txMap['txType'] as num?)?.toInt() ?? 0;
          final amount = (txMap['amountMinor'] as num?)?.toInt() ?? 0;
          if (type == 0) {
            balanceMinor += amount;
          } else {
            balanceMinor -= amount;
          }
        }
      }
      clients.add(
        ServerClient(
          id: (map['sourceClientId'] ?? '').toString(),
          fullName: (map['fullName'] ?? '').toString(),
          phone: map['phone']?.toString(),
          balanceMinor: balanceMinor,
        ),
      );
    }
    clients.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    return clients;
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final base = _config.serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  Map<String, String> _headers() {
    final basic = base64Encode(
      utf8.encode('${_config.username.trim()}:${_config.password.trim()}'),
    );
    return {
      'authorization': 'Basic $basic',
      'content-type': 'application/json; charset=utf-8',
      'accept': 'application/json',
    };
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = 'HTTP ${response.statusCode}';
    try {
      final obj = _decodeObject(response.body);
      final serverError = obj['error']?.toString();
      if (serverError != null && serverError.isNotEmpty) {
        message = serverError;
      }
    } catch (_) {
      // Ignore parse errors and use status code fallback.
    }
    throw Exception(message);
  }

  Map<String, dynamic> _decodeObject(String text) {
    final dynamic node = jsonDecode(text);
    if (node is! Map<String, dynamic>) {
      throw const FormatException('Response root must be an object.');
    }
    return node;
  }
}

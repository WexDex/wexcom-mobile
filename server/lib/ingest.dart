import 'dart:convert';

class ParsedExportPayload {
  const ParsedExportPayload({
    required this.version,
    required this.exportedAtIso,
    required this.clients,
  });

  final int version;
  final String? exportedAtIso;
  final List<ParsedClient> clients;

  Map<String, dynamic> toJsonMap() {
    return {
      'version': version,
      'exportedAt': exportedAtIso,
      'clients': clients.map((c) => c.toJsonMap()).toList(),
    };
  }
}

class ParsedClient {
  const ParsedClient({
    required this.sourceClientId,
    required this.fullName,
    required this.phone,
    required this.note,
    required this.source,
    required this.createdAtIso,
    required this.lastInteractionAtIso,
    required this.archivedAtIso,
    required this.tags,
    required this.transactions,
  });

  final String sourceClientId;
  final String fullName;
  final String? phone;
  final String? note;
  final String? source;
  final String? createdAtIso;
  final String? lastInteractionAtIso;
  final String? archivedAtIso;
  final List<ParsedTag> tags;
  final List<ParsedTransaction> transactions;

  Map<String, dynamic> toJsonMap() {
    return {
      'sourceClientId': sourceClientId,
      'fullName': fullName,
      'phone': phone,
      'note': note,
      'source': source,
      'createdAt': createdAtIso,
      'lastInteractionAt': lastInteractionAtIso,
      'archivedAt': archivedAtIso,
      'tags': tags.map((t) => t.toJsonMap()).toList(),
      'transactions': transactions.map((t) => t.toJsonMap()).toList(),
    };
  }
}

class ParsedTag {
  const ParsedTag({
    required this.name,
    required this.colorHex,
    required this.scope,
  });

  final String name;
  final String? colorHex;
  final String? scope;

  Map<String, dynamic> toJsonMap() {
    return {'name': name, 'colorHex': colorHex, 'scope': scope};
  }
}

class ParsedTransaction {
  const ParsedTransaction({
    required this.sourceTransactionId,
    required this.amountMinor,
    required this.currencyCode,
    required this.txType,
    required this.txStatus,
    required this.note,
    required this.createdAtIso,
    required this.effectiveAtIso,
    required this.tags,
  });

  final String? sourceTransactionId;
  final int amountMinor;
  final String? currencyCode;
  final int txType;
  final int txStatus;
  final String? note;
  final String createdAtIso;
  final String? effectiveAtIso;
  final List<ParsedTag> tags;

  Map<String, dynamic> toJsonMap() {
    return {
      'sourceTransactionId': sourceTransactionId,
      'amountMinor': amountMinor,
      'currencyCode': currencyCode,
      'txType': txType,
      'txStatus': txStatus,
      'note': note,
      'createdAt': createdAtIso,
      'effectiveAt': effectiveAtIso,
      'tags': tags.map((t) => t.toJsonMap()).toList(),
    };
  }
}

ParsedExportPayload parseExportPayload(String rawJson) {
  final dynamic root = jsonDecode(rawJson);
  if (root is! Map<String, dynamic>) {
    throw const FormatException('Payload root must be an object.');
  }
  final version = (root['version'] as num?)?.toInt() ?? 1;
  final exportedAt = root['exportedAt']?.toString();
  final clientsNode = root['clients'];
  if (clientsNode is! List) {
    throw const FormatException('"clients" must be a list.');
  }

  final clients = clientsNode
      .whereType<Map>()
      .map((entry) => _parseClient(entry.cast<String, dynamic>()))
      .toList();

  return ParsedExportPayload(version: version, exportedAtIso: exportedAt, clients: clients);
}

ParsedClient _parseClient(Map<String, dynamic> map) {
  final fullName = (map['fullName'] ?? '').toString().trim();
  if (fullName.isEmpty) {
    throw const FormatException('Client fullName is required.');
  }
  final sourceClientIdRaw = (map['sourceClientId'] ?? '').toString().trim();
  final sourceClientId = sourceClientIdRaw.isNotEmpty
      ? sourceClientIdRaw
      : _fallbackClientId(fullName, map['phone']?.toString());
  final tagsNode = map['tags'];
  final txNode = map['transactions'];
  final tags = tagsNode is List
      ? tagsNode
            .whereType<Map>()
            .map((e) => _parseTag(e.cast<String, dynamic>()))
            .toList()
      : const <ParsedTag>[];
  final txs = txNode is List
      ? txNode
            .whereType<Map>()
            .map((e) => _parseTransaction(e.cast<String, dynamic>()))
            .toList()
      : const <ParsedTransaction>[];

  return ParsedClient(
    sourceClientId: sourceClientId,
    fullName: fullName,
    phone: map['phone']?.toString(),
    note: map['note']?.toString(),
    source: map['source']?.toString(),
    createdAtIso: map['createdAt']?.toString(),
    lastInteractionAtIso: map['lastInteractionAt']?.toString(),
    archivedAtIso: map['archivedAt']?.toString(),
    tags: tags,
    transactions: txs,
  );
}

ParsedTransaction _parseTransaction(Map<String, dynamic> map) {
  final amountMinor = (map['amountMinor'] as num?)?.toInt();
  final txType = (map['txType'] as num?)?.toInt();
  final txStatus = (map['txStatus'] as num?)?.toInt();
  final createdAtIso = map['createdAt']?.toString();
  if (amountMinor == null || amountMinor <= 0) {
    throw const FormatException('Transaction amountMinor must be > 0.');
  }
  if (txType == null || txStatus == null || createdAtIso == null || createdAtIso.isEmpty) {
    throw const FormatException('Transaction requires txType, txStatus, createdAt.');
  }
  final tagsNode = map['tags'];
  final tags = tagsNode is List
      ? tagsNode
            .whereType<Map>()
            .map((e) => _parseTag(e.cast<String, dynamic>()))
            .toList()
      : const <ParsedTag>[];
  return ParsedTransaction(
    sourceTransactionId: map['sourceTransactionId']?.toString(),
    amountMinor: amountMinor,
    currencyCode: map['currencyCode']?.toString(),
    txType: txType,
    txStatus: txStatus,
    note: map['note']?.toString(),
    createdAtIso: createdAtIso,
    effectiveAtIso: map['effectiveAt']?.toString(),
    tags: tags,
  );
}

ParsedTag _parseTag(Map<String, dynamic> map) {
  final name = (map['name'] ?? '').toString().trim();
  if (name.isEmpty) {
    throw const FormatException('Tag name is required.');
  }
  return ParsedTag(
    name: name,
    colorHex: map['colorHex']?.toString(),
    scope: map['scope']?.toString(),
  );
}

String _fallbackClientId(String fullName, String? phone) {
  final safeName = fullName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final safePhone = (phone ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
  if (safePhone.isEmpty) return safeName;
  return '$safeName-$safePhone';
}

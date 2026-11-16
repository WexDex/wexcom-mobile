import '../../../data/db/app_database.dart';

class ClientNameMatch {
  const ClientNameMatch({
    required this.status,
    this.clientId,
    this.messages = const [],
  });

  final BulkImportClientMatchStatus status;
  final String? clientId;
  final List<String> messages;
}

enum BulkImportClientMatchStatus {
  ok,
  warning,
  error,
}

/// Resolves a name from bulk import text against active clients.
ClientNameMatch resolveClientName(String query, List<Client> clients) {
  final q = query.trim();
  if (q.isEmpty) {
    return const ClientNameMatch(
      status: BulkImportClientMatchStatus.error,
      messages: ['Client name is empty'],
    );
  }

  final lower = q.toLowerCase();
  final exact = clients.where((c) => c.fullName.toLowerCase() == lower).toList();
  if (exact.length == 1) {
    return ClientNameMatch(
      status: BulkImportClientMatchStatus.ok,
      clientId: exact.first.id,
    );
  }
  if (exact.length > 1) {
    return ClientNameMatch(
      status: BulkImportClientMatchStatus.error,
      messages: ['Multiple clients named "$q"'],
    );
  }

  final partial = clients
      .where((c) => c.fullName.toLowerCase().contains(lower) || lower.contains(c.fullName.toLowerCase()))
      .toList();

  if (partial.length == 1) {
    return ClientNameMatch(
      status: BulkImportClientMatchStatus.warning,
      clientId: partial.first.id,
      messages: ['Matched client "${partial.first.fullName}"'],
    );
  }
  if (partial.length > 1) {
    return ClientNameMatch(
      status: BulkImportClientMatchStatus.error,
      messages: ['Several clients match "$q" — pick one in preview'],
    );
  }

  return ClientNameMatch(
    status: BulkImportClientMatchStatus.error,
    messages: ['No client matches "$q"'],
  );
}
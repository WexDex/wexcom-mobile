/// Persisted client list sort + layout (stored in app_settings).
enum ClientSortField {
  byName,
  updatedAt,
  createdAt,
  lastActivityAt,
  balance;

  String get storageKey => switch (this) {
        ClientSortField.byName => 'name',
        ClientSortField.updatedAt => 'updatedAt',
        ClientSortField.createdAt => 'createdAt',
        ClientSortField.lastActivityAt => 'lastActivityAt',
        ClientSortField.balance => 'balance',
      };

  static ClientSortField fromStorage(String? key) {
    return switch (key) {
      'updatedAt' => ClientSortField.updatedAt,
      'createdAt' => ClientSortField.createdAt,
      'lastActivityAt' => ClientSortField.lastActivityAt,
      'balance' => ClientSortField.balance,
      _ => ClientSortField.byName,
    };
  }
}

enum ClientListLayout {
  compact,
  detailed,
  grid;

  String get storageKey => name;

  static ClientListLayout fromStorage(String? key) {
    return ClientListLayout.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ClientListLayout.detailed,
    );
  }
}

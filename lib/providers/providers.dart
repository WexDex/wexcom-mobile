import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/ledger_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(ref.watch(appDatabaseProvider));
});

final defaultCurrencyProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.defaultCurrencyCode();
});

final activeClientsProvider = StreamProvider.autoDispose<List<Client>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchActiveClients();
});

final archivedClientsProvider = StreamProvider.autoDispose<List<Client>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchArchivedClients();
});

final clientProvider = StreamProvider.autoDispose.family<Client?, String>((ref, id) {
  return ref.watch(ledgerRepositoryProvider).watchClient(id);
});

final clientTransactionsProvider =
    StreamProvider.autoDispose.family<List<LedgerTransaction>, String>((ref, clientId) {
  return ref.watch(ledgerRepositoryProvider).watchTransactions(clientId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/ledger_repository.dart';
import '../services/contacts_service.dart';

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

final contactsAutofillEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.contactsAutofillEnabled();
});

final profileNameProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.profileName();
});

final lifetimeTotalsProvider = FutureProvider<LifetimeTotals>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.lifetimeTotals();
});

final overdueAlertDaysProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.overdueAlertDays();
});

final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService();
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

final allTransactionsProvider =
    StreamProvider.autoDispose.family<List<LedgerTransactionWithClient>, String?>((ref, clientId) {
  return ref.watch(ledgerRepositoryProvider).watchAllTransactions(clientId: clientId);
});

final clientTagsProvider =
    StreamProvider.autoDispose.family<List<Tag>, String>((ref, clientId) {
  return ref.watch(ledgerRepositoryProvider).watchClientTags(clientId);
});

final transactionTagsProvider =
    StreamProvider.autoDispose.family<List<Tag>, String>((ref, txId) {
  return ref.watch(ledgerRepositoryProvider).watchTransactionTags(txId);
});

final clientScopeTagsProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchTags('client');
});

final transactionScopeTagsProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchTags('transaction');
});

final quickAddSuggestionsProvider = StreamProvider.autoDispose<List<QuickAddSuggestion>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchTopQuickActions();
});

final clientInsightProvider =
    FutureProvider.autoDispose.family<String, String>((ref, clientId) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  final days = await repo.overdueAlertDays();
  return repo.payerInsightLabel(clientId, days);
});

final clientOverdueProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, clientId) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  final days = await repo.overdueAlertDays();
  return repo.hasOverdueDebt(clientId, days);
});

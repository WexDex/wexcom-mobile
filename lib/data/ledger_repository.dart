import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';
import 'ledger_types.dart';
import '../models/from_currency_snapshot.dart';
import '../utils/chart_curve.dart';
import '../utils/client_list_prefs.dart';
import '../utils/exchange_rate.dart';
import '../utils/subscription_schedule.dart';

class LifetimeTotals {
  const LifetimeTotals({
    required this.totalDebtsMinor,
    required this.totalPaymentsMinor,
  });

  final int totalDebtsMinor;
  final int totalPaymentsMinor;
}

class LedgerTransactionWithClient {
  const LedgerTransactionWithClient({
    required this.transaction,
    required this.clientName,
  });

  final LedgerTransaction transaction;
  final String clientName;
}

class QuickAddSuggestion {
  const QuickAddSuggestion({
    required this.type,
    required this.amountMinor,
    required this.usesCount,
  });

  final LedgerTxType type;
  final int amountMinor;
  final int usesCount;
}

enum ImportConflictResolution { mix, erase, ignore }

class ImportClientConflict {
  const ImportClientConflict({
    required this.importClientKey,
    required this.importClientName,
    required this.importClientPhone,
    required this.importClientNote,
    required this.importTxCount,
    required this.existingClientId,
    required this.existingClientName,
    required this.existingClientPhone,
    required this.existingClientNote,
    required this.existingTxCount,
  });

  final String importClientKey;
  final String importClientName;
  final String? importClientPhone;
  final String? importClientNote;
  final int importTxCount;
  final String existingClientId;
  final String existingClientName;
  final String? existingClientPhone;
  final String? existingClientNote;
  final int existingTxCount;
}

class ImportPreview {
  const ImportPreview({
    required this.totalClients,
    required this.newClients,
    required this.conflicts,
  });

  final int totalClients;
  final int newClients;
  final List<ImportClientConflict> conflicts;
}

class ImportApplyResult {
  const ImportApplyResult({
    required this.addedClients,
    required this.updatedClients,
    required this.mixedClients,
    required this.erasedClients,
    required this.skippedClients,
    required this.addedTransactions,
    required this.removedTransactions,
    required this.skippedDuplicateTransactions,
  });

  final int addedClients;
  final int updatedClients;
  final int mixedClients;
  final int erasedClients;
  final int skippedClients;
  final int addedTransactions;
  final int removedTransactions;
  final int skippedDuplicateTransactions;
}

enum SingleClientImportMode { mix, replace }

class SyncSettingsData {
  const SyncSettingsData({
    required this.enabled,
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.intervalHours,
    required this.periodicEnabled,
    required this.lastUploadAt,
    required this.lastUploadSha256,
    required this.lastDownloadAt,
    required this.lastServerOkAt,
  });

  final bool enabled;
  final String? serverUrl;
  final String? username;
  final String? password;
  final int intervalHours;
  final bool periodicEnabled;
  final DateTime? lastUploadAt;
  final String? lastUploadSha256;
  final DateTime? lastDownloadAt;
  final DateTime? lastServerOkAt;
}

class LedgerRepository {
  LedgerRepository(this._db);

  final AppDatabase _db;

  static const _uuid = Uuid();

  Stream<List<Client>> watchActiveClients() {
    return (_db.select(_db.clients)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.fullName)]))
        .watch();
  }

  Stream<List<Client>> watchArchivedClients() {
    return (_db.select(_db.clients)
          ..where((c) => c.archivedAt.isNotNull())
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .watch();
  }

  Stream<Client?> watchClient(String id) {
    return (_db.select(_db.clients)..where((c) => c.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<LedgerTransaction>> watchTransactions(String clientId) {
    return (_db.select(_db.ledgerTransactions)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveAt),
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Stream<List<LedgerTransactionWithClient>> watchAllTransactions({
    String? clientId,
  }) {
    final query = _db.select(_db.ledgerTransactions).join([
      innerJoin(
        _db.clients,
        _db.clients.id.equalsExp(_db.ledgerTransactions.clientId),
      ),
    ])
      ..where(_db.clients.archivedAt.isNull());
    if (clientId != null) {
      query.where(_db.ledgerTransactions.clientId.equals(clientId));
    }
    query.orderBy([
      OrderingTerm.desc(_db.ledgerTransactions.effectiveAt),
      OrderingTerm.desc(_db.ledgerTransactions.createdAt),
      OrderingTerm.desc(_db.ledgerTransactions.id),
    ]);
    return query.watch().map(
      (rows) => rows.map((row) {
        return LedgerTransactionWithClient(
          transaction: row.readTable(_db.ledgerTransactions),
          clientName: row.readTable(_db.clients).fullName,
        );
      }).toList(),
    );
  }

  Stream<List<PersonalFinanceEntry>> watchPersonalFinanceEntries(
    PersonalFinanceKind kind,
  ) {
    return (_db.select(_db.personalFinanceEntries)
          ..where((e) => e.kind.equals(kind.index))
          ..orderBy([
            (e) => OrderingTerm.desc(e.createdAt),
            (e) => OrderingTerm.desc(e.id),
          ]))
        .watch();
  }

  Future<void> addPersonalFinanceEntry({
    required PersonalFinanceKind kind,
    required String title,
    required int amountMinor,
    String? currencyCode,
    String? note,
    String? categoryId,
    DateTime? createdAt,
    FromCurrencySnapshot? fromCurrency,
  }) async {
    final now = DateTime.now().toUtc();
    final at = createdAt?.toUtc() ?? now;
    final defaultCode = await defaultCurrencyCode();
    final id = _uuid.v4();
    await _db.into(_db.personalFinanceEntries).insert(
          PersonalFinanceEntriesCompanion.insert(
            id: id,
            kind: kind.index,
            title: title.trim(),
            amountMinor: amountMinor,
            currencyCode: Value(defaultCode),
            fromCurrencyJson: Value(fromCurrency?.toJsonString()),
            note: Value(_normalizeNullable(note)),
            categoryId: Value(categoryId),
            createdAt: at,
            updatedAt: now,
          ),
        );
    await logAction(
      kind == PersonalFinanceKind.expense ? 'create_expense' : 'create_gain',
      'finance',
      id,
      detail: {'title': title.trim(), 'amountMinor': amountMinor},
    );
  }

  Future<void> updatePersonalFinanceEntry({
    required String id,
    required String title,
    required int amountMinor,
    String? currencyCode,
    String? note,
    String? categoryId,
    bool clearCategory = false,
    DateTime? createdAt,
    FromCurrencySnapshot? fromCurrency,
    bool clearFromCurrency = false,
  }) async {
    final existing = await (_db.select(_db.personalFinanceEntries)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    final now = DateTime.now().toUtc();
    await (_db.update(_db.personalFinanceEntries)..where((e) => e.id.equals(id))).write(
          PersonalFinanceEntriesCompanion(
            title: Value(title.trim()),
            amountMinor: Value(amountMinor),
            currencyCode: currencyCode == null ? const Value.absent() : Value(currencyCode),
            fromCurrencyJson: clearFromCurrency
                ? const Value(null)
                : fromCurrency == null
                    ? const Value.absent()
                    : Value(fromCurrency.toJsonString()),
            note: Value(_normalizeNullable(note)),
            categoryId: clearCategory ? const Value(null) : Value(categoryId),
            updatedAt: Value(now),
            createdAt: createdAt == null ? const Value.absent() : Value(createdAt.toUtc()),
          ),
        );
    final kind = existing?.kind ?? PersonalFinanceKind.expense.index;
    await logAction(
      kind == PersonalFinanceKind.expense.index ? 'update_expense' : 'update_gain',
      'finance',
      id,
      detail: {'title': title.trim(), 'amountMinor': amountMinor},
    );
  }

  Future<void> deletePersonalFinanceEntry(String id) async {
    final existing = await (_db.select(_db.personalFinanceEntries)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    await (_db.delete(_db.personalFinanceEntries)..where((e) => e.id.equals(id))).go();
    if (existing != null) {
      await logAction(
        existing.kind == PersonalFinanceKind.expense.index
            ? 'delete_expense'
            : 'delete_gain',
        'finance',
        id,
        detail: {'title': existing.title},
      );
    }
  }

  Future<String> exportAllClientsWithTransactionsJson() async {
    final payload = await _buildExportPayload();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<String> exportSingleClientJson(String clientId) async {
    final payload = await _buildExportPayload(clientId: clientId);
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<String> currentExportSha256() async {
    final raw = await exportAllClientsWithTransactionsJson();
    return sha256.convert(utf8.encode(raw)).toString();
  }

  Future<Map<String, dynamic>> _buildExportPayload({String? clientId}) async {
    final clients = await (_db.select(_db.clients)
          ..where(
            (c) => clientId == null ? const Constant(true) : c.id.equals(clientId),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.fullName)]))
        .get();
    final allTags = await (_db.select(_db.tags)).get();
    final clientTagRows = await (_db.select(_db.clientTags)).get();
    final txTagRows = await (_db.select(_db.transactionTags)).get();
    final txs = await (_db.select(_db.ledgerTransactions)
          ..orderBy([
            (t) => OrderingTerm.asc(t.clientId),
            (t) => OrderingTerm.asc(t.effectiveAt),
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();

    // ── v9 tables (full export only) ──────────────────────────────────────
    final allCategories = clientId == null
        ? await (_db.select(_db.expenseCategories)).get()
        : <ExpenseCategory>[];
    final allWishlist = clientId == null
        ? await (_db.select(_db.wishlistItems)).get()
        : <WishlistItem>[];
    final allSubscriptions = clientId == null
        ? await (_db.select(_db.subscriptionItems)).get()
        : <SubscriptionItem>[];
    final allWalletAccounts = clientId == null
        ? await (_db.select(_db.walletAccounts)).get()
        : <WalletAccount>[];
    final allSavingsGoals = clientId == null
        ? await (_db.select(_db.savingsGoals)).get()
        : <SavingsGoal>[];

    final categoriesById = {for (final c in allCategories) c.id: c};

    final tagsById = {for (final t in allTags) t.id: t};
    final clientTagIdsByClient = <String, List<String>>{};
    for (final row in clientTagRows) {
      clientTagIdsByClient.putIfAbsent(row.clientId, () => []).add(row.tagId);
    }
    final txTagIdsByTx = <String, List<String>>{};
    for (final row in txTagRows) {
      txTagIdsByTx.putIfAbsent(row.transactionId, () => []).add(row.tagId);
    }
    final txsByClient = <String, List<LedgerTransaction>>{};
    for (final tx in txs) {
      txsByClient.putIfAbsent(tx.clientId, () => []).add(tx);
    }

    final personalFinanceJson = clientId == null
        ? await _personalFinanceExportRows(categoriesById: categoriesById)
        : <Map<String, dynamic>>[];

    final defaultCode = await defaultCurrencyCode();
    final managedCurrencies = clientId == null
        ? await (_db.select(_db.managedCurrencies)).get()
        : <ManagedCurrency>[];
    final rateHistory = clientId == null
        ? await (_db.select(_db.exchangeRateHistory)
              ..orderBy([(r) => OrderingTerm.asc(r.recordedAt)]))
            .get()
        : <ExchangeRateHistoryData>[];
    final hasCurrencyExtras = managedCurrencies.length > 1 || rateHistory.isNotEmpty;
    final exportVersion = hasCurrencyExtras ? 3 : 2;

    Map<String, dynamic>? fromCurrencyExport(String? json) {
      final snap = FromCurrencySnapshot.fromJsonString(json);
      return snap?.toJson();
    }

    return {
      'version': exportVersion,
      if (exportVersion >= 3) 'defaultCurrencyCode': defaultCode,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'clients': clients.map((client) {
        final clientTagNames = (clientTagIdsByClient[client.id] ?? const <String>[])
            .map((tagId) => tagsById[tagId])
            .whereType<Tag>()
            .map(
              (tag) => {
                'name': tag.name,
                'colorHex': tag.colorHex,
                'scope': tag.scope,
              },
            )
            .toList();
        final clientTxs = (txsByClient[client.id] ?? const <LedgerTransaction>[])
            .map((tx) {
          final txTagNames = (txTagIdsByTx[tx.id] ?? const <String>[])
              .map((tagId) => tagsById[tagId])
              .whereType<Tag>()
              .map(
                (tag) => {
                  'name': tag.name,
                  'colorHex': tag.colorHex,
                  'scope': tag.scope,
                },
              )
              .toList();
          return {
            'sourceTransactionId': tx.id,
            'amountMinor': tx.amountMinor,
            'currencyCode': tx.currencyCode,
            if (fromCurrencyExport(tx.fromCurrencyJson) != null)
              'fromCurrency': fromCurrencyExport(tx.fromCurrencyJson),
            'txType': tx.txType,
            'txStatus': tx.txStatus,
            'note': tx.note,
            'createdAt': tx.createdAt.toIso8601String(),
            'effectiveAt': tx.effectiveAt?.toIso8601String(),
            'tags': txTagNames,
          };
        }).toList();
        return {
          'sourceClientId': client.id,
          'fullName': client.fullName,
          'phone': client.phone,
          'note': client.note,
          'source': client.source,
          'createdAt': client.createdAt.toIso8601String(),
          'lastInteractionAt': client.lastInteractionAt?.toIso8601String(),
          'archivedAt': client.archivedAt?.toIso8601String(),
          'tags': clientTagNames,
          'transactions': clientTxs,
        };
      }).toList(),
      if (clientId == null) 'personalFinance': personalFinanceJson,
      if (clientId == null)
        'categories': allCategories
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'colorHex': c.colorHex,
                  'iconCodePoint': c.iconCodePoint,
                  'budgetMinorPerMonth': c.budgetMinorPerMonth,
                  'scope': c.scope,
                  'createdAt': c.createdAt.toIso8601String(),
                })
            .toList(),
      if (clientId == null)
        'wishlist': allWishlist
            .map((w) => {
                  'id': w.id,
                  'title': w.title,
                  'amountMinor': w.amountMinor,
                  'currencyCode': w.currencyCode,
                  'note': w.note,
                  'categoryName': w.categoryId == null
                      ? null
                      : categoriesById[w.categoryId]?.name,
                  'isPurchased': w.isPurchased ? 1 : 0,
                  'createdAt': w.createdAt.toIso8601String(),
                  'purchasedAt': w.purchasedAt?.toIso8601String(),
                })
            .toList(),
      if (clientId == null)
        'subscriptions': allSubscriptions
            .map((s) => {
                  'id': s.id,
                  'title': s.title,
                  'amountMinor': s.amountMinor,
                  'currencyCode': s.currencyCode,
                  'fromCurrency': fromCurrencyExport(s.fromCurrencyJson),
                  'note': s.note,
                  'categoryName': s.categoryId == null
                      ? null
                      : categoriesById[s.categoryId]?.name,
                  'scheduleType': s.scheduleType,
                  'billingDayOfMonth': s.billingDayOfMonth,
                  'rollingDays': s.rollingDays,
                  'nextDueAt': s.nextDueAt.toIso8601String(),
                  'lastLoggedAt': s.lastLoggedAt?.toIso8601String(),
                  'isActive': s.isActive,
                  'createdAt': s.createdAt.toIso8601String(),
                  'updatedAt': s.updatedAt.toIso8601String(),
                })
            .toList(),
      if (clientId == null)
        'wallet': allWalletAccounts
            .map((a) => {
                  'id': a.id,
                  'name': a.name,
                  'emoji': a.emoji,
                  'currencyCode': a.currencyCode,
                  'balanceMinor': a.balanceMinor,
                  'sortOrder': a.sortOrder,
                  'createdAt': a.createdAt.toIso8601String(),
                  'updatedAt': a.updatedAt.toIso8601String(),
                })
            .toList(),
      if (clientId == null && exportVersion >= 3)
        'currencies': managedCurrencies
            .map((c) => {
                  'code': c.code,
                  'fractionDigits': c.fractionDigits,
                })
            .toList(),
      if (clientId == null && exportVersion >= 3)
        'exchangeRateHistory': rateHistory
            .map((r) => {
                  'currencyCode': r.currencyCode,
                  'rateToDefault': r.rateToDefault,
                  'rateScale': r.rateScale,
                  'recordedAt': r.recordedAt.toIso8601String(),
                  'note': r.note,
                })
            .toList(),
      if (clientId == null)
        'savings': allSavingsGoals
            .map((g) => {
                  'id': g.id,
                  'name': g.name,
                  'emoji': g.emoji,
                  'targetMinor': g.targetMinor,
                  'savedMinor': g.savedMinor,
                  'note': g.note,
                  'deadline': g.deadline?.toIso8601String(),
                  'isCompleted': g.isCompleted ? 1 : 0,
                  'createdAt': g.createdAt.toIso8601String(),
                })
            .toList(),
    };
  }

  Future<List<Map<String, dynamic>>> _personalFinanceExportRows({
    Map<String, ExpenseCategory> categoriesById = const {},
  }) async {
    final rows = await (_db.select(_db.personalFinanceEntries)
          ..orderBy([
            (e) => OrderingTerm.asc(e.kind),
            (e) => OrderingTerm.asc(e.createdAt),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .get();
    return rows
        .map(
          (e) => {
            'id': e.id,
            'kind': e.kind,
            'title': e.title,
            'amountMinor': e.amountMinor,
            'currencyCode': e.currencyCode,
            if (FromCurrencySnapshot.fromJsonString(e.fromCurrencyJson) != null)
              'fromCurrency':
                  FromCurrencySnapshot.fromJsonString(e.fromCurrencyJson)!.toJson(),
            'note': e.note,
            'categoryName': e.categoryId == null
                ? null
                : categoriesById[e.categoryId]?.name,
            'createdAt': e.createdAt.toIso8601String(),
            'updatedAt': e.updatedAt.toIso8601String(),
          },
        )
        .toList();
  }

  Future<ImportPreview> previewImport(String rawJson) async {
    final parsedClients = _parseImportClients(rawJson);
    final existingClients = await (_db.select(_db.clients)).get();
    final existingTxs = await (_db.select(_db.ledgerTransactions)).get();
    final existingByKey = <String, Client>{
      for (final c in existingClients) _clientMatchKey(c.fullName, c.phone): c,
    };
    final txCountByClientId = <String, int>{};
    for (final tx in existingTxs) {
      txCountByClientId.update(tx.clientId, (v) => v + 1, ifAbsent: () => 1);
    }
    final conflicts = <ImportClientConflict>[];
    var newCount = 0;
    for (final imported in parsedClients) {
      final key = _clientMatchKey(imported.fullName, imported.phone);
      final existing = existingByKey[key];
      if (existing == null) {
        newCount += 1;
        continue;
      }
      conflicts.add(
        ImportClientConflict(
          importClientKey: imported.importClientKey,
          importClientName: imported.fullName,
          importClientPhone: imported.phone,
          importClientNote: imported.note,
          importTxCount: imported.transactions.length,
          existingClientId: existing.id,
          existingClientName: existing.fullName,
          existingClientPhone: existing.phone,
          existingClientNote: existing.note,
          existingTxCount: txCountByClientId[existing.id] ?? 0,
        ),
      );
    }
    return ImportPreview(
      totalClients: parsedClients.length,
      newClients: newCount,
      conflicts: conflicts,
    );
  }

  Future<String> createClient({
    required String fullName,
    String? phone,
    String? note,
    String? externalRef,
    String? tagsJson,
    String source = 'manual',
    DateTime? lastInteractionAt,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _db.into(_db.clients).insert(
          ClientsCompanion.insert(
            id: id,
            fullName: fullName,
            phone: Value(phone),
            note: Value(note),
            externalRef: Value(externalRef),
            tagsJson: Value(tagsJson),
            source: Value(source),
            lastInteractionAt: Value(lastInteractionAt ?? now),
            balanceMinor: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await logAction('create_client', 'client', id, detail: {'fullName': fullName});
    return id;
  }

  Future<void> updateClient({
    required String id,
    required String fullName,
    String? phone,
    String? note,
    String? externalRef,
    String? tagsJson,
    String? source,
    DateTime? lastInteractionAt,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(id))).write(
          ClientsCompanion(
            fullName: Value(fullName),
            phone: Value(phone),
            note: Value(note),
            externalRef: Value(externalRef),
            tagsJson: Value(tagsJson),
            source: source == null ? const Value.absent() : Value(source),
            lastInteractionAt: Value(lastInteractionAt),
            updatedAt: Value(now),
          ),
        );
    await logAction('update_client', 'client', id, detail: {'fullName': fullName});
  }

  Future<void> setClientTags(String clientId, List<String> tagIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.clientTags)
            ..where((t) => t.clientId.equals(clientId)))
          .go();
      final now = DateTime.now().toUtc();
      for (final tagId in tagIds.toSet()) {
        await _db.into(_db.clientTags).insert(
              ClientTagsCompanion.insert(
                id: _uuid.v4(),
                clientId: clientId,
                tagId: tagId,
                createdAt: now,
              ),
            );
      }
    });
  }

  Stream<List<Tag>> watchClientTags(String clientId) {
    final query = _db.select(_db.clientTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.clientTags.tagId)),
    ])
      ..where(_db.clientTags.clientId.equals(clientId))
      ..orderBy([OrderingTerm.asc(_db.tags.name)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(_db.tags)).toList());
  }

  Future<void> setClientArchived(String id, bool archived) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(id))).write(
          ClientsCompanion(
            archivedAt: Value(archived ? now : null),
            updatedAt: Value(now),
          ),
        );
    await logAction(
      archived ? 'archive_client' : 'restore_client',
      'client',
      id,
    );
  }

  Future<void> insertTransaction({
    required String clientId,
    required int amountMinor,
    required LedgerTxType type,
    String? currencyCode,
    String? note,
    String createdBy = 'manual',
    String channel = 'other',
    String? referenceNo,
    DateTime? effectiveAt,
    DateTime? dueAt,
    int attachmentsCount = 0,
    List<String> tagIds = const [],
    FromCurrencySnapshot? fromCurrency,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be positive');
    }
    final defaultCode = await defaultCurrencyCode();
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      final createdAt = await _allocateCreatedAt(clientId, now);
      await _db.into(_db.ledgerTransactions).insert(
            LedgerTransactionsCompanion.insert(
              id: id,
              clientId: clientId,
              amountMinor: amountMinor,
              currencyCode: Value(defaultCode),
              fromCurrencyJson: Value(fromCurrency?.toJsonString()),
              createdBy: Value(createdBy),
              channel: Value(channel),
              referenceNo: Value(referenceNo),
              effectiveAt: Value(effectiveAt ?? createdAt),
              dueAt: Value(dueAt?.toUtc()),
              attachmentsCount: Value(attachmentsCount),
              txType: type.index,
              txStatus: LedgerTxStatus.active.index,
              postedBalanceBeforeMinor: 0,
              postedBalanceAfterMinor: 0,
              createdAt: createdAt,
              updatedAt: createdAt,
              note: Value(note),
            ),
          );
      if (tagIds.isNotEmpty) {
        await _replaceTransactionTags(id, tagIds);
      }
      await _recordQuickAction(type, amountMinor);
      await _refreshPostingSnapshots(clientId);
    });
    await logAction('create_tx', 'transaction', id, detail: {
      'clientId': clientId,
      'amountMinor': amountMinor,
      'type': type.name,
    });
  }

  Future<void> updateTransaction({
    required String id,
    required int amountMinor,
    required LedgerTxType type,
    String? note,
    List<String>? tagIds,
    DateTime? effectiveAt,
    DateTime? dueAt,
    FromCurrencySnapshot? fromCurrency,
    bool clearFromCurrency = false,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be positive');
    }
    final now = DateTime.now().toUtc();
    final tx = await (_db.select(_db.ledgerTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (tx == null || tx.txStatus != LedgerTxStatus.active.index) {
      throw StateError('Transaction not found or not active');
    }

    await _db.transaction(() async {
      await (_db.update(_db.ledgerTransactions)..where((t) => t.id.equals(id))).write(
            LedgerTransactionsCompanion(
              amountMinor: Value(amountMinor),
              txType: Value(type.index),
              note: Value(note),
              effectiveAt: Value(effectiveAt),
              dueAt: Value(dueAt?.toUtc()),
              fromCurrencyJson: clearFromCurrency
                  ? const Value(null)
                  : fromCurrency == null
                      ? const Value.absent()
                      : Value(fromCurrency.toJsonString()),
              updatedAt: Value(now),
            ),
          );
      if (tagIds != null) {
        await _replaceTransactionTags(id, tagIds);
      }
      await _recordQuickAction(type, amountMinor);
      await _refreshPostingSnapshots(tx.clientId);
    });
    await logAction('update_tx', 'transaction', id, detail: {
      'amountMinor': amountMinor,
      'type': type.name,
    });
  }

  Future<void> markDebtAsPaid(String transactionId) async {
    final tx = await (_db.select(_db.ledgerTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();
    if (tx == null || tx.txStatus != LedgerTxStatus.active.index) return;
    final type = LedgerTxType.fromInt(tx.txType);
    if (type != LedgerTxType.debt) return;

    await (_db.update(_db.ledgerTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .write(
      LedgerTransactionsCompanion(
        isSettled: const Value(true),
        settledAt: Value(DateTime.now().toUtc()),
      ),
    );
    await insertTransaction(
      clientId: tx.clientId,
      amountMinor: tx.amountMinor,
      type: LedgerTxType.payment,
      currencyCode: tx.currencyCode,
      note: 'Marked paid for debt #${tx.id.substring(0, 8)}',
    );
  }

  Future<void> settleFullDebt(String clientId) async {
    final balance = await _computeBalance(clientId);
    if (balance <= 0) return;
    await insertTransaction(
      clientId: clientId,
      amountMinor: balance,
      type: LedgerTxType.payment,
      note: 'Settle full debt',
    );
    await logAction('settle_tx', 'client', clientId,
        detail: {'amountMinor': balance});
    await (_db.update(_db.ledgerTransactions)
          ..where(
            (t) =>
                t.clientId.equals(clientId) &
                t.txType.equals(LedgerTxType.debt.index) &
                t.txStatus.equals(LedgerTxStatus.active.index),
          ))
        .write(
      LedgerTransactionsCompanion(
        isSettled: const Value(true),
        settledAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> cancelTransaction(String id) async {
    final tx = await (_db.select(_db.ledgerTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (tx == null || tx.txStatus != LedgerTxStatus.active.index) {
      return;
    }

    await _db.transaction(() async {
      final cancelBefore = await _computeBalance(tx.clientId);

      final now = DateTime.now().toUtc();
      await (_db.update(_db.ledgerTransactions)..where((t) => t.id.equals(id))).write(
            LedgerTransactionsCompanion(
              txStatus: Value(LedgerTxStatus.cancelled.index),
              cancelledAt: Value(now),
              updatedAt: Value(now),
              cancelBalanceBeforeMinor: Value(cancelBefore),
            ),
          );

      final cancelAfter = await _computeBalance(tx.clientId);

      await (_db.update(_db.ledgerTransactions)..where((t) => t.id.equals(id))).write(
            LedgerTransactionsCompanion(
              cancelBalanceAfterMinor: Value(cancelAfter),
            ),
          );

      await _refreshPostingSnapshots(tx.clientId);
    });
    await logAction('cancel_tx', 'transaction', id);
  }

  Future<int> computeBalance(String clientId) => _computeBalance(clientId);

  Future<int?> oldestOutstandingDebtAgeDays(String clientId) async {
    final rows = await (_db.select(_db.ledgerTransactions)
          ..where(
            (t) =>
                t.clientId.equals(clientId) &
                t.txStatus.equals(LedgerTxStatus.active.index) &
                t.txType.equals(LedgerTxType.debt.index),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final age = DateTime.now().toUtc().difference(rows.single.createdAt.toUtc());
    return age.inDays;
  }

  Future<bool> hasOverdueDebt(String clientId, int overdueDays) async {
    final balance = await _computeBalance(clientId);
    if (balance <= 0) return false;
    final age = await oldestOutstandingDebtAgeDays(clientId);
    return age != null && age >= overdueDays;
  }

  Future<String> payerInsightLabel(String clientId, int overdueDays) async {
    final overdue = await hasOverdueDebt(clientId, overdueDays);
    if (overdue) return 'Slow payer';
    final balance = await _computeBalance(clientId);
    return balance <= 0 ? 'Reliable payer' : 'Active';
  }

  Future<int> _computeBalance(String clientId) async {
    final txs = await (_db.select(_db.ledgerTransactions)
          ..where(
            (t) =>
                t.clientId.equals(clientId) &
                t.txStatus.equals(LedgerTxStatus.active.index),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();

    var balance = 0;
    for (final tx in txs) {
      balance = LedgerMath.apply(
        balance,
        LedgerTxType.fromInt(tx.txType),
        tx.amountMinor,
      );
    }
    return balance;
  }

  Future<void> _refreshPostingSnapshots(String clientId) async {
    final txs = await (_db.select(_db.ledgerTransactions)
          ..where(
            (t) =>
                t.clientId.equals(clientId) &
                t.txStatus.equals(LedgerTxStatus.active.index),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();

    var balance = 0;
    for (final tx in txs) {
      final before = balance;
      final after = LedgerMath.apply(
        balance,
        LedgerTxType.fromInt(tx.txType),
        tx.amountMinor,
      );
      await (_db.update(_db.ledgerTransactions)..where((t) => t.id.equals(tx.id))).write(
            LedgerTransactionsCompanion(
              postedBalanceBeforeMinor: Value(before),
              postedBalanceAfterMinor: Value(after),
            ),
          );
      balance = after;
    }

    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(clientId))).write(
          ClientsCompanion(
            balanceMinor: Value(balance),
            lastInteractionAt: txs.isEmpty
                ? const Value.absent()
                : Value(txs.last.createdAt),
            updatedAt: Value(now),
          ),
        );
  }

  Future<String> defaultCurrencyCode() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    return row?.defaultCurrencyCode ?? 'DZD';
  }

  Future<void> setDefaultCurrencyCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    final now = DateTime.now().toUtc();
    await _db.into(_db.managedCurrencies).insertOnConflictUpdate(
          ManagedCurrenciesCompanion.insert(
            code: trimmed,
            fractionDigits: const Value(0),
            createdAt: now,
          ),
        );
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(defaultCurrencyCode: Value(trimmed)),
        );
  }

  /// Foreign currencies + latest rates for the transaction editor.
  Future<({List<String> codes, Map<String, num> rates})>
      foreignCurrencyEditorContext() async {
    final defaultCode = await defaultCurrencyCode();
    final currencies = await (_db.select(_db.managedCurrencies)).get();
    final codes = <String>[];
    final rates = <String, num>{};
    for (final c in currencies) {
      if (c.code == defaultCode) continue;
      codes.add(c.code);
      final r = await currentRateFor(c.code);
      if (r != null) rates[c.code] = r;
    }
    return (codes: codes, rates: rates);
  }

  Future<int> overdueAlertDays() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    final days = row?.overdueAlertDays ?? 10;
    return days <= 0 ? 10 : days;
  }

  Future<void> setOverdueAlertDays(int days) async {
    final normalized = days <= 0 ? 10 : days;
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(overdueAlertDays: Value(normalized)),
        );
  }

  Future<bool> contactsAutofillEnabled() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    return row?.contactsAutofillEnabled ?? true;
  }

  Future<void> setContactsAutofillEnabled(bool enabled) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(contactsAutofillEnabled: Value(enabled)),
        );
  }

  Future<String?> profileName() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    return row?.profileName;
  }

  Future<void> setProfileName(String? name) async {
    final trimmed = name?.trim();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(
            profileName: Value(
              trimmed == null || trimmed.isEmpty ? null : trimmed,
            ),
          ),
        );
  }

  Future<SyncSettingsData> syncSettings() async {
    final row = await _db.select(_db.appSettings).getSingleOrNull();
    return _mapSyncSettings(row);
  }

  Stream<SyncSettingsData> watchSyncSettings() {
    return _db.select(_db.appSettings).watchSingleOrNull().map(_mapSyncSettings);
  }

  Future<AppSetting?> getAppSettings() =>
      _db.select(_db.appSettings).getSingleOrNull();

  Stream<AppSetting?> watchAppSettings() =>
      _db.select(_db.appSettings).watchSingleOrNull();

  Future<void> saveNotificationSettings({
    required bool overdueEnabled,
    required int overdueHour,
    required bool balanceMilestoneEnabled,
    required int balanceMilestoneMinor,
    required bool inactivityEnabled,
    required int inactivityDays,
    required bool syncEnabled,
    bool? backupReminderEnabled,
    int? backupReminderDays,
  }) async {
    final existing = await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(
        notifOverdueEnabled: Value(overdueEnabled),
        notifOverdueHour: Value(overdueHour),
        notifBalanceMilestoneEnabled: Value(balanceMilestoneEnabled),
        notifBalanceMilestoneMinor: Value(balanceMilestoneMinor),
        notifInactivityEnabled: Value(inactivityEnabled),
        notifInactivityDays: Value(inactivityDays),
        notifSyncEnabled: Value(syncEnabled),
        notifBackupReminderEnabled: backupReminderEnabled == null
            ? const Value.absent()
            : Value(backupReminderEnabled),
        notifBackupReminderDays: backupReminderDays == null
            ? const Value.absent()
            : Value(backupReminderDays),
      ),
    );
    await logAction('settings_notif_change', 'settings', '1', silent: true, detail: {
      'overdueEnabled': overdueEnabled,
      'backupReminderEnabled':
          backupReminderEnabled ?? existing?.notifBackupReminderEnabled,
    });
  }

  Future<void> saveClientListPrefs({
    required ClientSortField sortField,
    required bool sortAscending,
    required ClientListLayout layout,
  }) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(
        clientSortField: Value(sortField.storageKey),
        clientSortAscending: Value(sortAscending),
        clientListLayout: Value(layout.storageKey),
      ),
    );
    await logAction('settings_prefs_change', 'settings', '1', silent: true, detail: {
      'clientSortField': sortField.storageKey,
      'clientListLayout': layout.storageKey,
    });
  }

  ClientSortField clientSortFieldFromSettings(AppSetting? s) =>
      ClientSortField.fromStorage(s?.clientSortField);

  bool clientSortAscendingFromSettings(AppSetting? s) =>
      s?.clientSortAscending ?? true;

  ClientListLayout clientListLayoutFromSettings(AppSetting? s) =>
      ClientListLayout.fromStorage(s?.clientListLayout);

  Future<void> saveChartCurveStyle(ChartCurveStyle style) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(chartCurveStyle: Value(style.storageKey)),
    );
    await logAction('settings_prefs_change', 'settings', '1', silent: true, detail: {
      'chartCurveStyle': style.storageKey,
    });
  }

  ChartCurveStyle chartCurveStyleFromSettings(AppSetting? s) =>
      ChartCurveStyle.fromStorage(s?.chartCurveStyle);

  Future<void> saveSyncSettings({
    required bool enabled,
    String? serverUrl,
    String? username,
    String? password,
    required int intervalHours,
    required bool periodicEnabled,
  }) async {
    final normalizedInterval = intervalHours <= 0 ? 24 : intervalHours;
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(
            syncEnabled: Value(enabled),
            syncServerUrl: Value(_normalizeNullable(serverUrl)),
            syncUsername: Value(_normalizeNullable(username)),
            syncPassword: Value(_normalizeNullable(password)),
            syncIntervalHours: Value(normalizedInterval),
            syncPeriodicEnabled: Value(periodicEnabled),
          ),
        );
  }

  Future<void> updateSyncUploadMeta({
    required DateTime uploadedAt,
    required String sha256Hex,
  }) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(
            lastUploadAt: Value(uploadedAt.toUtc()),
            lastUploadSha256: Value(sha256Hex),
          ),
        );
  }

  Future<void> updateSyncDownloadMeta(DateTime downloadedAt) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(lastDownloadAt: Value(downloadedAt.toUtc())),
        );
  }

  Future<void> updateSyncServerOkMeta(DateTime checkedAt) async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(lastServerOkAt: Value(checkedAt.toUtc())),
        );
  }

  Future<LifetimeTotals> lifetimeTotals() async {
    final txs = await (_db.select(_db.ledgerTransactions)
          ..where((t) => t.txStatus.equals(LedgerTxStatus.active.index)))
        .get();
    var totalDebtsMinor = 0;
    var totalPaymentsMinor = 0;
    for (final tx in txs) {
      switch (LedgerTxType.fromInt(tx.txType)) {
        case LedgerTxType.debt:
          totalDebtsMinor += tx.amountMinor;
          break;
        case LedgerTxType.payment:
          totalPaymentsMinor += tx.amountMinor;
          break;
      }
    }
    return LifetimeTotals(
      totalDebtsMinor: totalDebtsMinor,
      totalPaymentsMinor: totalPaymentsMinor,
    );
  }

  Stream<List<Tag>> watchTags(String scope) {
    return (_db.select(_db.tags)
          ..where((t) => t.scope.equals(scope))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<String> createTag({
    required String name,
    required String colorHex,
    required String scope,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.tags).insert(
          TagsCompanion.insert(
            id: id,
            name: name.trim(),
            colorHex: Value(colorHex),
            scope: scope,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateTag({
    required String id,
    required String name,
    required String colorHex,
  }) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
          TagsCompanion(
            name: Value(name.trim()),
            colorHex: Value(colorHex),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> deleteTag(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.clientTags)..where((t) => t.tagId.equals(id))).go();
      await (_db.delete(_db.transactionTags)..where((t) => t.tagId.equals(id))).go();
      await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
    });
  }

  Stream<List<Tag>> watchTransactionTags(String txId) {
    final query = _db.select(_db.transactionTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.transactionTags.tagId)),
    ])
      ..where(_db.transactionTags.transactionId.equals(txId))
      ..orderBy([OrderingTerm.asc(_db.tags.name)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(_db.tags)).toList());
  }

  Future<void> _replaceTransactionTags(String txId, List<String> tagIds) async {
    await (_db.delete(_db.transactionTags)
          ..where((t) => t.transactionId.equals(txId)))
        .go();
    final now = DateTime.now().toUtc();
    for (final tagId in tagIds.toSet()) {
      await _db.into(_db.transactionTags).insert(
            TransactionTagsCompanion.insert(
              id: _uuid.v4(),
              transactionId: txId,
              tagId: tagId,
              createdAt: now,
            ),
          );
    }
  }

  Stream<List<QuickAddSuggestion>> watchTopQuickActions({int limit = 4}) {
    return (_db.select(_db.quickActionUsages)
          ..orderBy([
            (t) => OrderingTerm.desc(t.usesCount),
            (t) => OrderingTerm.desc(t.lastUsedAt),
          ])
          ..limit(limit))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => QuickAddSuggestion(
                  type: LedgerTxType.fromInt(row.txType),
                  amountMinor: row.amountMinor,
                  usesCount: row.usesCount,
                ),
              )
              .toList(),
        );
  }

  Future<void> _recordQuickAction(LedgerTxType type, int amountMinor) async {
    final id = '${type.index}_$amountMinor';
    final existing = await (_db.select(_db.quickActionUsages)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await _db.into(_db.quickActionUsages).insert(
            QuickActionUsagesCompanion.insert(
              id: id,
              txType: type.index,
              amountMinor: amountMinor,
              usesCount: const Value(1),
              lastUsedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.quickActionUsages)..where((t) => t.id.equals(id))).write(
            QuickActionUsagesCompanion(
              usesCount: Value(existing.usesCount + 1),
              lastUsedAt: Value(now),
            ),
          );
    }
  }

  /// Ensures new transactions sort after existing ones when clocks collide at SQLite precision.
  Future<DateTime> _allocateCreatedAt(String clientId, DateTime proposedUtc) async {
    final rows = await (_db.select(_db.ledgerTransactions)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .get();
    if (rows.isEmpty) return proposedUtc;
    final last = rows.single.createdAt.toUtc();
    final minNext = last.add(const Duration(seconds: 1));
    if (proposedUtc.isAfter(minNext)) return proposedUtc;
    return minNext;
  }

  Future<void> _importCurrencyExtrasFromJson(String rawJson) async {
    final Map<String, dynamic> root;
    try {
      root = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final version = (root['version'] as num?)?.toInt() ?? 1;
    if (version < 3) return;

    final defaultCode =
        root['defaultCurrencyCode']?.toString().trim().toUpperCase();
    if (defaultCode != null && defaultCode.isNotEmpty) {
      await setDefaultCurrencyCode(defaultCode);
    }

    final currenciesNode = root['currencies'];
    if (currenciesNode is List) {
      final now = DateTime.now().toUtc();
      for (final item in currenciesNode) {
        if (item is! Map) continue;
        final code = (item['code'] ?? '').toString().trim().toUpperCase();
        if (code.isEmpty) continue;
        final frac = (item['fractionDigits'] as num?)?.toInt() ?? 0;
        await _db.into(_db.managedCurrencies).insertOnConflictUpdate(
              ManagedCurrenciesCompanion.insert(
                code: code,
                fractionDigits: Value(frac),
                createdAt: now,
              ),
            );
      }
    }

    final ratesNode = root['exchangeRateHistory'];
    if (ratesNode is List) {
      for (final item in ratesNode) {
        if (item is! Map) continue;
        final code =
            (item['currencyCode'] ?? '').toString().trim().toUpperCase();
        final rateRaw = item['rateToDefault'];
        final recordedAtRaw = item['recordedAt']?.toString();
        if (code.isEmpty || rateRaw == null || recordedAtRaw == null) continue;
        final recordedAt = DateTime.tryParse(recordedAtRaw)?.toUtc();
        if (recordedAt == null) continue;
        final rateScale = (item['rateScale'] as num?)?.toInt() ?? 0;
        final rateStored = rateRaw is int
            ? rateRaw
            : (rateRaw is num ? rateRaw.round() : int.tryParse('$rateRaw'));
        if (rateStored == null) continue;
        await _db.into(_db.exchangeRateHistory).insert(
              ExchangeRateHistoryCompanion.insert(
                id: _uuid.v4(),
                currencyCode: code,
                rateToDefault: rateStored,
                rateScale: Value(rateScale),
                recordedAt: recordedAt,
                note: Value(item['note']?.toString()),
              ),
            );
      }
    }
  }

  Future<ImportApplyResult> importFromJson(
    String rawJson, {
    required Map<String, ImportConflictResolution> conflictResolutionsByImportKey,
  }) async {
    final importedClients = _parseImportClients(rawJson);
    var addedClients = 0;
    var updatedClients = 0;
    var mixedClients = 0;
    var erasedClients = 0;
    var skippedClients = 0;
    var addedTransactions = 0;
    var removedTransactions = 0;
    var skippedDuplicateTransactions = 0;

    await _db.transaction(() async {
      await _importCurrencyExtrasFromJson(rawJson);
      final importDefaultCode = await defaultCurrencyCode();

      // ── Step 1: Upsert categories so their IDs are available for
      //           finance entries and wishlist items below.
      //           Strategy: match by (name, scope) — don't overwrite
      //           existing user-customised categories (budget, colour).
      final importedCategories = _tryParseV9Section<_ImportedCategoryPayload>(
        rawJson, 'categories', _ImportedCategoryPayload.fromMap);
      final categoryIdByNameScope = <String, String>{};
      if (importedCategories != null) {
        for (final cat in importedCategories) {
          final existing = await (_db.select(_db.expenseCategories)
                ..where(
                  (c) =>
                      c.name.equals(cat.name) & c.scope.equals(cat.scope),
                )
                ..limit(1))
              .getSingleOrNull();
          if (existing != null) {
            categoryIdByNameScope['${cat.name}|${cat.scope}'] = existing.id;
          } else {
            await _db.into(_db.expenseCategories).insertOnConflictUpdate(
                  ExpenseCategoriesCompanion.insert(
                    id: cat.id,
                    name: cat.name,
                    colorHex: Value(cat.colorHex),
                    iconCodePoint: cat.iconCodePoint,
                    budgetMinorPerMonth: Value(cat.budgetMinorPerMonth),
                    scope: cat.scope,
                    createdAt: cat.createdAt,
                  ),
                );
            categoryIdByNameScope['${cat.name}|${cat.scope}'] = cat.id;
          }
        }
      }
      // Supplement map with any pre-existing categories the import didn't
      // contain (e.g. user created them locally).
      final existingCats = await (_db.select(_db.expenseCategories)).get();
      for (final c in existingCats) {
        categoryIdByNameScope.putIfAbsent('${c.name}|${c.scope}', () => c.id);
      }

      // ── Step 2: Wallet accounts ──────────────────────────────────────────
      final importedWallet = _tryParseV9Section<_ImportedWalletPayload>(
        rawJson, 'wallet', _ImportedWalletPayload.fromMap);
      if (importedWallet != null) {
        for (final acc in importedWallet) {
          // Insert only if id doesn't exist — don't overwrite live balances.
          final existing = await (_db.select(_db.walletAccounts)
                ..where((a) => a.id.equals(acc.id))
                ..limit(1))
              .getSingleOrNull();
          if (existing == null) {
            final defaultCode = await defaultCurrencyCode();
            await _db.into(_db.walletAccounts).insertOnConflictUpdate(
                  WalletAccountsCompanion.insert(
                    id: acc.id,
                    name: acc.name,
                    emoji: Value(acc.emoji),
                    currencyCode: Value(acc.currencyCode ?? defaultCode),
                    balanceMinor: Value(acc.balanceMinor),
                    sortOrder: Value(acc.sortOrder),
                    createdAt: acc.createdAt,
                    updatedAt: acc.createdAt,
                  ),
                );
          }
        }
      }

      // ── Step 3: Savings goals ────────────────────────────────────────────
      final importedSavings = _tryParseV9Section<_ImportedSavingsPayload>(
        rawJson, 'savings', _ImportedSavingsPayload.fromMap);
      if (importedSavings != null) {
        for (final goal in importedSavings) {
          await _db.into(_db.savingsGoals).insertOnConflictUpdate(
                SavingsGoalsCompanion.insert(
                  id: goal.id,
                  name: goal.name,
                  emoji: Value(goal.emoji),
                  targetMinor: goal.targetMinor,
                  savedMinor: Value(goal.savedMinor),
                  note: Value(goal.note),
                  deadline: Value(goal.deadline),
                  isCompleted: Value(goal.isCompleted),
                  createdAt: goal.createdAt,
                ),
              );
        }
      }

      final existingClients = await (_db.select(_db.clients)).get();
      final existingAllTxs = await (_db.select(_db.ledgerTransactions)).get();
      final existingTxIdsGlobal = <String>{for (final tx in existingAllTxs) tx.id};
      final existingByKey = <String, Client>{
        for (final c in existingClients) _clientMatchKey(c.fullName, c.phone): c,
      };

      for (final imported in importedClients) {
        final existing = existingByKey[_clientMatchKey(imported.fullName, imported.phone)];
        final hasConflict = existing != null;
        final resolution = hasConflict
            ? (conflictResolutionsByImportKey[imported.importClientKey] ??
                ImportConflictResolution.ignore)
            : ImportConflictResolution.mix;

        if (hasConflict && resolution == ImportConflictResolution.ignore) {
          skippedClients += 1;
          continue;
        }

        String targetClientId;
        if (!hasConflict) {
          targetClientId = _uuid.v4();
          await _db.into(_db.clients).insert(
                ClientsCompanion.insert(
                  id: targetClientId,
                  fullName: imported.fullName,
                  phone: Value(imported.phone),
                  note: Value(imported.note),
                  source: Value(imported.source ?? 'import'),
                  lastInteractionAt: Value(imported.lastInteractionAt),
                  balanceMinor: 0,
                  createdAt: imported.createdAt ?? DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                  archivedAt: Value(imported.archivedAt),
                ),
              );
          addedClients += 1;
        } else {
          targetClientId = existing.id;
          if (resolution == ImportConflictResolution.mix) {
            mixedClients += 1;
          }
          if (resolution == ImportConflictResolution.erase) {
            erasedClients += 1;
            final existingTxRows = await (_db.select(_db.ledgerTransactions)
                  ..where((t) => t.clientId.equals(existing.id)))
                .get();
            for (final row in existingTxRows) {
              existingTxIdsGlobal.remove(row.id);
            }
            final existingTxCount = await (_db.selectOnly(_db.ledgerTransactions)
                  ..addColumns([_db.ledgerTransactions.id.count()])
                  ..where(_db.ledgerTransactions.clientId.equals(existing.id)))
                .map((row) => row.read(_db.ledgerTransactions.id.count()) ?? 0)
                .getSingle();
            removedTransactions += existingTxCount;
            await (_db.delete(_db.transactionTags)
                  ..where(
                    (tt) => tt.transactionId.isInQuery(
                      _db.selectOnly(_db.ledgerTransactions)
                        ..addColumns([_db.ledgerTransactions.id])
                        ..where(_db.ledgerTransactions.clientId.equals(existing.id)),
                    ),
                  ))
                .go();
            await (_db.delete(_db.ledgerTransactions)
                  ..where((t) => t.clientId.equals(existing.id)))
                .go();
            await (_db.delete(_db.clientTags)
                  ..where((ct) => ct.clientId.equals(existing.id)))
                .go();
            await (_db.update(_db.clients)..where((c) => c.id.equals(existing.id))).write(
                  ClientsCompanion(
                    fullName: Value(imported.fullName),
                    phone: Value(imported.phone),
                    note: Value(imported.note),
                    source: Value(imported.source ?? 'import'),
                    lastInteractionAt: Value(imported.lastInteractionAt),
                    archivedAt: Value(imported.archivedAt),
                    updatedAt: Value(DateTime.now().toUtc()),
                  ),
                );
          }
          updatedClients += 1;
        }

        final txFingerprintSet = <String>{};
        final existingTxIdsForTarget = <String>{};
        if (existing != null && resolution == ImportConflictResolution.mix) {
          final existingTxs = await (_db.select(_db.ledgerTransactions)
                ..where((t) => t.clientId.equals(existing.id)))
              .get();
          for (final tx in existingTxs) {
            existingTxIdsForTarget.add(tx.id);
            txFingerprintSet.add(
              _txFingerprint(
                amountMinor: tx.amountMinor,
                txType: tx.txType,
                txStatus: tx.txStatus,
                note: tx.note,
                createdAt: tx.createdAt,
                effectiveAt: tx.effectiveAt,
              ),
            );
          }
        }

        final importedClientTagIds = <String>[];
        for (final tag in imported.clientTags) {
          final tagId = await _upsertTagByName(
            name: tag.name,
            scope: 'client',
            colorHex: tag.colorHex,
          );
          importedClientTagIds.add(tagId);
        }
        if (importedClientTagIds.isNotEmpty) {
          if (existing == null || resolution == ImportConflictResolution.erase) {
            await setClientTags(targetClientId, importedClientTagIds);
          } else if (resolution == ImportConflictResolution.mix) {
            final existingTagIds = await (_db.select(_db.clientTags)
                  ..where((ct) => ct.clientId.equals(targetClientId)))
                .get();
            final merged = {
              ...existingTagIds.map((e) => e.tagId),
              ...importedClientTagIds,
            }.toList();
            await setClientTags(targetClientId, merged);
          }
        }

        for (final tx in imported.transactions) {
          final sourceTxId = tx.sourceTransactionId?.trim();
          final normalizedSourceTxId =
              sourceTxId == null || sourceTxId.isEmpty ? null : sourceTxId;
          if (resolution == ImportConflictResolution.mix &&
              normalizedSourceTxId != null &&
              existingTxIdsForTarget.contains(normalizedSourceTxId)) {
            skippedDuplicateTransactions += 1;
            continue;
          }
          final fp = _txFingerprint(
            amountMinor: tx.amountMinor,
            txType: tx.txType,
            txStatus: tx.txStatus,
            note: tx.note,
            createdAt: tx.createdAt,
            effectiveAt: tx.effectiveAt,
          );
          if (resolution == ImportConflictResolution.mix &&
              txFingerprintSet.contains(fp)) {
            skippedDuplicateTransactions += 1;
            continue;
          }

          var txId = normalizedSourceTxId ?? _uuid.v4();
          if (existingTxIdsGlobal.contains(txId)) {
            txId = _uuid.v4();
          }
          await _db.into(_db.ledgerTransactions).insert(
                LedgerTransactionsCompanion.insert(
                  id: txId,
                  clientId: targetClientId,
                  amountMinor: tx.amountMinor,
                  currencyCode: Value(tx.currencyCode ?? importDefaultCode),
                  fromCurrencyJson: Value(tx.fromCurrencyJson),
                  createdBy: const Value('import'),
                  channel: const Value('import'),
                  txType: tx.txType,
                  txStatus: tx.txStatus,
                  postedBalanceBeforeMinor: 0,
                  postedBalanceAfterMinor: 0,
                  createdAt: tx.createdAt,
                  updatedAt: DateTime.now().toUtc(),
                  effectiveAt: Value(tx.effectiveAt ?? tx.createdAt),
                  note: Value(tx.note),
                ),
              );

          for (final tag in tx.tags) {
            final tagId = await _upsertTagByName(
              name: tag.name,
              scope: 'transaction',
              colorHex: tag.colorHex,
            );
            await _db.into(_db.transactionTags).insert(
                  TransactionTagsCompanion.insert(
                    id: _uuid.v4(),
                    transactionId: txId,
                    tagId: tagId,
                    createdAt: DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
          existingTxIdsGlobal.add(txId);
          existingTxIdsForTarget.add(txId);
          addedTransactions += 1;
        }

        await _refreshPostingSnapshots(targetClientId);
      }

      // ── Step 4: Personal finance entries ──────────────────────────────────
      final importedPf = _tryParsePersonalFinanceFromJson(rawJson);
      if (importedPf != null) {
        for (final row in importedPf) {
          final id = row.id.isEmpty ? _uuid.v4() : row.id;
          // Resolve categoryName → local categoryId (null if unknown)
          String? resolvedCategoryId;
          if (row.categoryName != null && row.categoryName!.isNotEmpty) {
            // Try both scopes; expense entries have kind=0, gains kind=1
            final scope = row.kind == 1 ? 'gain' : 'expense';
            resolvedCategoryId =
                categoryIdByNameScope['${row.categoryName}|$scope'] ??
                    categoryIdByNameScope['${row.categoryName}|expense'] ??
                    categoryIdByNameScope['${row.categoryName}|gain'];
          }
          await _db.into(_db.personalFinanceEntries).insert(
                PersonalFinanceEntriesCompanion.insert(
                  id: id,
                  kind: row.kind,
                  title: row.title,
                  amountMinor: row.amountMinor,
                  currencyCode: Value(row.currencyCode ?? 'DZD'),
                  fromCurrencyJson: Value(row.fromCurrencyJson),
                  note: Value(row.note),
                  categoryId: Value(resolvedCategoryId),
                  createdAt: row.createdAt,
                  updatedAt: row.updatedAt,
                ),
                mode: InsertMode.insertOrReplace,
              );
        }
      }

      // ── Step 5: Wishlist items ─────────────────────────────────────────────
      final importedWishlist = _tryParseV9Section<_ImportedWishlistPayload>(
        rawJson, 'wishlist', _ImportedWishlistPayload.fromMap);
      if (importedWishlist != null) {
        for (final item in importedWishlist) {
          String? resolvedCategoryId;
          if (item.categoryName != null && item.categoryName!.isNotEmpty) {
            resolvedCategoryId =
                categoryIdByNameScope['${item.categoryName}|expense'] ??
                    categoryIdByNameScope['${item.categoryName}|gain'];
          }
          await _db.into(_db.wishlistItems).insertOnConflictUpdate(
                WishlistItemsCompanion.insert(
                  id: item.id,
                  title: item.title,
                  amountMinor: item.amountMinor,
                  currencyCode: Value(item.currencyCode),
                  note: Value(item.note),
                  categoryId: Value(resolvedCategoryId),
                  isPurchased: Value(item.isPurchased),
                  createdAt: item.createdAt,
                  purchasedAt: Value(item.purchasedAt),
                ),
              );
        }
      }

      // ── Step 6: Subscription items ───────────────────────────────────────
      final importedSubs = _tryParseV9Section<_ImportedSubscriptionPayload>(
        rawJson, 'subscriptions', _ImportedSubscriptionPayload.fromMap);
      if (importedSubs != null) {
        for (final item in importedSubs) {
          String? resolvedCategoryId;
          if (item.categoryName != null && item.categoryName!.isNotEmpty) {
            resolvedCategoryId =
                categoryIdByNameScope['${item.categoryName}|expense'];
          }
          await _db.into(_db.subscriptionItems).insertOnConflictUpdate(
                SubscriptionItemsCompanion.insert(
                  id: item.id,
                  title: item.title,
                  amountMinor: item.amountMinor,
                  currencyCode: Value(item.currencyCode),
                  fromCurrencyJson: Value(item.fromCurrencyJson),
                  note: Value(item.note),
                  categoryId: Value(resolvedCategoryId),
                  scheduleType: item.scheduleType,
                  billingDayOfMonth: Value(item.billingDayOfMonth),
                  rollingDays: Value(item.rollingDays),
                  nextDueAt: item.nextDueAt,
                  lastLoggedAt: Value(item.lastLoggedAt),
                  isActive: Value(item.isActive),
                  createdAt: item.createdAt,
                  updatedAt: item.updatedAt,
                ),
              );
        }
      }
    });

    await logAction('json_import', 'backup', 'local', silent: true);

    return ImportApplyResult(
      addedClients: addedClients,
      updatedClients: updatedClients,
      mixedClients: mixedClients,
      erasedClients: erasedClients,
      skippedClients: skippedClients,
      addedTransactions: addedTransactions,
      removedTransactions: removedTransactions,
      skippedDuplicateTransactions: skippedDuplicateTransactions,
    );
  }

  Future<ImportApplyResult> importSingleClient(
    String rawJson, {
    required SingleClientImportMode mode,
  }) async {
    final preview = await previewImport(rawJson);
    final resolutions = <String, ImportConflictResolution>{};
    final resolution = mode == SingleClientImportMode.replace
        ? ImportConflictResolution.erase
        : ImportConflictResolution.mix;
    for (final conflict in preview.conflicts) {
      resolutions[conflict.importClientKey] = resolution;
    }
    return importFromJson(
      rawJson,
      conflictResolutionsByImportKey: resolutions,
    );
  }

  Future<String> _upsertTagByName({
    required String name,
    required String scope,
    String? colorHex,
  }) async {
    final existing = await (_db.select(_db.tags)
          ..where((t) => t.scope.equals(scope) & t.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _db.into(_db.tags).insert(
          TagsCompanion.insert(
            id: id,
            name: name,
            scope: scope,
            colorHex: Value(colorHex ?? '#4F46E5'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  SyncSettingsData _mapSyncSettings(AppSetting? row) {
    return SyncSettingsData(
      enabled: row?.syncEnabled ?? false,
      serverUrl: row?.syncServerUrl,
      username: row?.syncUsername,
      password: row?.syncPassword,
      intervalHours: row?.syncIntervalHours ?? 24,
      periodicEnabled: row?.syncPeriodicEnabled ?? false,
      lastUploadAt: row?.lastUploadAt,
      lastUploadSha256: row?.lastUploadSha256,
      lastDownloadAt: row?.lastDownloadAt,
      lastServerOkAt: row?.lastServerOkAt,
    );
  }

  String? _normalizeNullable(String? input) {
    final trimmed = input?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _clientMatchKey(String fullName, String? phone) {
    final normalizedName = fullName.trim().toLowerCase();
    final normalizedPhone = (phone ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
    return '$normalizedName|$normalizedPhone';
  }

  String _txFingerprint({
    required int amountMinor,
    required int txType,
    required int txStatus,
    required String? note,
    required DateTime createdAt,
    required DateTime? effectiveAt,
  }) {
    return [
      amountMinor.toString(),
      txType.toString(),
      txStatus.toString(),
      (note ?? '').trim(),
      createdAt.toUtc().toIso8601String(),
      (effectiveAt ?? createdAt).toUtc().toIso8601String(),
    ].join('|');
  }

  List<_ImportedClientPayload> _parseImportClients(String rawJson) {
    final dynamic root = jsonDecode(rawJson);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('Invalid import format: root must be an object');
    }
    final clientsNode = root['clients'];
    if (clientsNode is! List) {
      throw const FormatException('Invalid import format: "clients" must be a list');
    }
    return clientsNode
        .whereType<Map>()
        .map((c) => _ImportedClientPayload.fromMap(c.cast<String, dynamic>()))
        .toList();
  }

  /// When key is absent (legacy backups), returns null and local rows are left unchanged.
  /// When present, entries are upserted by [id] inside [importFromJson].
  List<_ImportedPersonalFinancePayload>? _tryParsePersonalFinanceFromJson(
    String rawJson,
  ) {
    return _tryParseV9Section<_ImportedPersonalFinancePayload>(
      rawJson, 'personalFinance', _ImportedPersonalFinancePayload.fromMap);
  }

  /// Generic optional-section parser for v9 additions.
  /// Returns null when the key is absent (old backups) — callers skip gracefully.
  /// Throws [FormatException] when the key exists but isn't a list.
  List<T>? _tryParseV9Section<T>(
    String rawJson,
    String key,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final dynamic root = jsonDecode(rawJson);
    if (root is! Map) return null;
    final node = root[key];
    if (node == null) return null;
    if (node is! List) {
      throw FormatException('Invalid import format: "$key" must be a list when provided');
    }
    return node
        .whereType<Map>()
        .map((e) => fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  // ── Audit log ─────────────────────────────────────────────────────────

  Future<void> logAction(
    String action,
    String entityType,
    String entityId, {
    Map<String, dynamic>? detail,
    bool silent = false,
  }) async {
    final payload = <String, dynamic>{
      if (detail != null) ...detail,
      if (silent) 'silent': true,
    };
    await _db.into(_db.auditLog).insert(
      AuditLogCompanion.insert(
        id: const Uuid().v4(),
        action: action,
        entityType: entityType,
        entityId: entityId,
        detail: Value(payload.isEmpty ? null : jsonEncode(payload)),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    // Prune oldest entries beyond 500
    final count = await _db.auditLog.count().getSingle();
    if (count > 500) {
      final oldest = await (_db.select(_db.auditLog)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(count - 500))
          .get();
      for (final row in oldest) {
        await (_db.delete(_db.auditLog)..where((t) => t.id.equals(row.id))).go();
      }
    }
  }

  Stream<List<AuditLogData>> watchAuditLog() =>
      (_db.select(_db.auditLog)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(500))
          .watch();

  // ── Transaction templates ──────────────────────────────────────────────

  Stream<List<TransactionTemplate>> watchTemplates() =>
      _db.select(_db.transactionTemplates).watch();

  Future<void> saveTemplate({
    required String label,
    required int amountMinor,
    required LedgerTxType type,
    String? note,
    String currencyCode = 'DZD',
  }) async {
    await _db.into(_db.transactionTemplates).insert(
      TransactionTemplatesCompanion.insert(
        id: const Uuid().v4(),
        label: label,
        amountMinor: amountMinor,
        txType: type.index,
        currencyCode: Value(currencyCode),
        note: Value(note),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> deleteTemplate(String id) async {
    await (_db.delete(_db.transactionTemplates)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ── Expense Categories (Part D) ──────────────────────────────────────────

  Stream<List<ExpenseCategory>> watchCategories(String scope) {
    return (_db.select(_db.expenseCategories)
          ..where((c) => c.scope.equals(scope))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<String> saveCategory({
    String? id,
    required String name,
    required String colorHex,
    required int iconCodePoint,
    int? budgetMinorPerMonth,
    required String scope,
  }) async {
    final now = DateTime.now().toUtc();
    final catId = id ?? _uuid.v4();
    await _db.into(_db.expenseCategories).insertOnConflictUpdate(
          ExpenseCategoriesCompanion.insert(
            id: catId,
            name: name.trim(),
            colorHex: Value(colorHex),
            iconCodePoint: iconCodePoint,
            budgetMinorPerMonth: Value(budgetMinorPerMonth),
            scope: scope,
            createdAt: now,
          ),
        );
    return catId;
  }

  Future<void> deleteCategory(String id) async {
    // Null out references in personal finance entries
    await (_db.update(_db.personalFinanceEntries)
          ..where((e) => e.categoryId.equals(id)))
        .write(const PersonalFinanceEntriesCompanion(
          categoryId: Value(null),
        ));
    await (_db.delete(_db.expenseCategories)..where((c) => c.id.equals(id)))
        .go();
  }

  /// Returns spent amount (minor) per category id for a given month.
  Stream<Map<String, int>> watchSpendPerCategory(
      String scope, DateTime monthStart) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1);
    return (_db.select(_db.personalFinanceEntries)
          ..where(
            (e) =>
                e.kind.equals(scope == 'gain' ? 1 : 0) &
                e.createdAt.isBiggerOrEqualValue(monthStart.toUtc()) &
                e.createdAt.isSmallerThanValue(monthEnd.toUtc()),
          ))
        .watch()
        .map((rows) {
      final map = <String, int>{};
      for (final r in rows) {
        final key = r.categoryId ?? '__none__';
        map[key] = (map[key] ?? 0) + r.amountMinor;
      }
      return map;
    });
  }

  // ── Wishlist (Part E) ────────────────────────────────────────────────────

  Stream<List<WishlistItem>> watchWishlistItems({bool purchased = false}) {
    return (_db.select(_db.wishlistItems)
          ..where((w) => w.isPurchased.equals(purchased))
          ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]))
        .watch();
  }

  Future<String> addWishlistItem({
    required String title,
    required int amountMinor,
    String? note,
    String? categoryId,
    String currencyCode = 'DZD',
    FromCurrencySnapshot? fromCurrency,
  }) async {
    final id = _uuid.v4();
    final defaultCode = await defaultCurrencyCode();
    await _db.into(_db.wishlistItems).insert(
          WishlistItemsCompanion.insert(
            id: id,
            title: title.trim(),
            amountMinor: amountMinor,
            currencyCode: Value(defaultCode),
            fromCurrencyJson: Value(fromCurrency?.toJsonString()),
            note: Value(note?.trim()),
            categoryId: Value(categoryId),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    await logAction('wishlist_add', 'wishlist', id, detail: {
      'title': title.trim(),
      'amountMinor': amountMinor,
    });
    return id;
  }

  Future<void> updateWishlistItem({
    required String id,
    required String title,
    required int amountMinor,
    String? note,
    String? categoryId,
    bool clearCategory = false,
    FromCurrencySnapshot? fromCurrency,
    bool clearFromCurrency = false,
  }) async {
    await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
          WishlistItemsCompanion(
            title: Value(title.trim()),
            amountMinor: Value(amountMinor),
            fromCurrencyJson: clearFromCurrency
                ? const Value(null)
                : fromCurrency == null
                    ? const Value.absent()
                    : Value(fromCurrency.toJsonString()),
            note: Value(_normalizeNullable(note)),
            categoryId: clearCategory ? const Value(null) : Value(categoryId),
          ),
        );
    await logAction('wishlist_update', 'wishlist', id, detail: {
      'title': title.trim(),
      'amountMinor': amountMinor,
    });
  }

  Future<void> markWishlistPurchased(String id) async {
    await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
          WishlistItemsCompanion(
            isPurchased: const Value(true),
            purchasedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await logAction('wishlist_purchase', 'wishlist', id);
  }

  Future<void> deleteWishlistItem(String id) async {
    await (_db.delete(_db.wishlistItems)..where((w) => w.id.equals(id))).go();
    await logAction('wishlist_delete', 'wishlist', id);
  }

  // ── Subscriptions ────────────────────────────────────────────────────────

  Stream<List<SubscriptionItem>> watchSubscriptionItems({bool activeOnly = true}) {
    return (_db.select(_db.subscriptionItems)
          ..where((s) => activeOnly ? s.isActive.equals(true) : const Constant(true))
          ..orderBy([(s) => OrderingTerm.asc(s.nextDueAt)]))
        .watch();
  }

  /// Active subscriptions with [nextDueAt] on or before [withinDays] from now.
  Future<List<SubscriptionItem>> subscriptionsDueForReminder({
    int withinDays = 3,
  }) async {
    final limit = DateTime.now().add(Duration(days: withinDays));
    return (_db.select(_db.subscriptionItems)
          ..where(
            (s) => s.isActive.equals(true) & s.nextDueAt.isSmallerOrEqualValue(limit),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.nextDueAt)]))
        .get();
  }

  Future<String> addSubscriptionItem({
    required String title,
    required int amountMinor,
    required SubscriptionScheduleType scheduleType,
    int? billingDayOfMonth,
    int? rollingDays,
    DateTime? nextDueAt,
    String? note,
    String? categoryId,
    FromCurrencySnapshot? fromCurrency,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final defaultCode = await defaultCurrencyCode();
    final due = nextDueAt?.toUtc() ??
        initialNextDue(
          type: scheduleType,
          billingDayOfMonth: billingDayOfMonth,
          rollingDays: rollingDays,
          from: now,
        );
    await _db.into(_db.subscriptionItems).insert(
          SubscriptionItemsCompanion.insert(
            id: id,
            title: title.trim(),
            amountMinor: amountMinor,
            currencyCode: Value(defaultCode),
            fromCurrencyJson: Value(fromCurrency?.toJsonString()),
            note: Value(_normalizeNullable(note)),
            categoryId: Value(categoryId),
            scheduleType: scheduleType.storageKey,
            billingDayOfMonth: Value(billingDayOfMonth),
            rollingDays: Value(rollingDays),
            nextDueAt: due,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await logAction('subscription_create', 'subscription', id, detail: {
      'title': title,
      'amountMinor': amountMinor,
    });
    return id;
  }

  Future<void> updateSubscriptionItem({
    required String id,
    required String title,
    required int amountMinor,
    required SubscriptionScheduleType scheduleType,
    int? billingDayOfMonth,
    int? rollingDays,
    DateTime? nextDueAt,
    String? note,
    String? categoryId,
    FromCurrencySnapshot? fromCurrency,
    bool clearFromCurrency = false,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.subscriptionItems)..where((s) => s.id.equals(id))).write(
          SubscriptionItemsCompanion(
            title: Value(title.trim()),
            amountMinor: Value(amountMinor),
            fromCurrencyJson: clearFromCurrency
                ? const Value(null)
                : fromCurrency == null
                    ? const Value.absent()
                    : Value(fromCurrency.toJsonString()),
            note: Value(_normalizeNullable(note)),
            categoryId: Value(categoryId),
            scheduleType: Value(scheduleType.storageKey),
            billingDayOfMonth: Value(billingDayOfMonth),
            rollingDays: Value(rollingDays),
            nextDueAt: nextDueAt == null ? const Value.absent() : Value(nextDueAt.toUtc()),
            updatedAt: Value(now),
          ),
        );
    await logAction('subscription_update', 'subscription', id);
  }

  Future<void> deleteSubscriptionItem(String id) async {
    await (_db.delete(_db.subscriptionItems)..where((s) => s.id.equals(id))).go();
    await logAction('subscription_delete', 'subscription', id);
  }

  Future<void> logSubscriptionPayment(
    String id, {
    int? amountMinorOverride,
    FromCurrencySnapshot? fromCurrencyOverride,
  }) async {
    final sub = await (_db.select(_db.subscriptionItems)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (sub == null) return;
    final now = DateTime.now().toUtc();
    final amount = amountMinorOverride ?? sub.amountMinor;
    final snap = fromCurrencyOverride ??
        FromCurrencySnapshot.fromJsonString(sub.fromCurrencyJson);
    await _db.transaction(() async {
      await addPersonalFinanceEntry(
        kind: PersonalFinanceKind.expense,
        title: sub.title,
        amountMinor: amount,
        note: sub.note,
        categoryId: sub.categoryId,
        createdAt: now,
        fromCurrency: snap,
      );
      final nextDue = computeNextDueAfterLog(
        type: SubscriptionScheduleType.fromStorage(sub.scheduleType),
        billingDayOfMonth: sub.billingDayOfMonth,
        rollingDays: sub.rollingDays,
        loggedAt: now,
      );
      await (_db.update(_db.subscriptionItems)..where((s) => s.id.equals(id))).write(
            SubscriptionItemsCompanion(
              lastLoggedAt: Value(now),
              nextDueAt: Value(nextDue),
              updatedAt: Value(now),
            ),
          );
    });
    await logAction('subscription_log', 'subscription', id, detail: {
      'amountMinor': amount,
      'title': sub.title,
    });
  }

  Future<void> recordJsonExport() async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(lastJsonExportAt: Value(DateTime.now().toUtc())),
        );
    await logAction('json_export', 'backup', 'local', silent: true);
  }

  // ── Wallet Accounts (Part F) ─────────────────────────────────────────────

  Stream<List<WalletAccount>> watchWalletAccounts() {
    return (_db.select(_db.walletAccounts)
          ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
        .watch();
  }

  Future<String> upsertWalletAccount({
    String? id,
    required String name,
    required String emoji,
    required int balanceMinor,
    int sortOrder = 0,
    String? currencyCode,
  }) async {
    final now = DateTime.now().toUtc();
    final accId = id ?? _uuid.v4();
    final code = currencyCode ?? await defaultCurrencyCode();
    await _db.into(_db.walletAccounts).insertOnConflictUpdate(
          WalletAccountsCompanion.insert(
            id: accId,
            name: name.trim(),
            emoji: Value(emoji),
            currencyCode: Value(code.toUpperCase()),
            balanceMinor: Value(balanceMinor),
            sortOrder: Value(sortOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await logAction(
      id == null ? 'wallet_account_upsert' : 'wallet_account_upsert',
      'wallet',
      accId,
      detail: {'name': name.trim(), 'balanceMinor': balanceMinor},
    );
    return accId;
  }

  Future<void> adjustAccountBalance(
    String id,
    int newBalanceMinor, {
    String? note,
    String source = 'manual',
    String? referenceId,
    FromCurrencySnapshot? fromCurrency,
  }) async {
    final account = await (_db.select(_db.walletAccounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (account == null) return;
    final before = account.balanceMinor;
    if (before == newBalanceMinor) return;
    final now = DateTime.now().toUtc();
    final opType = 'set';
    await _db.transaction(() async {
      await _db.into(_db.walletLedgerEntries).insert(
            WalletLedgerEntriesCompanion.insert(
              id: _uuid.v4(),
              accountId: id,
              opType: opType,
              amountMinor: newBalanceMinor,
              balanceBeforeMinor: before,
              balanceAfterMinor: newBalanceMinor,
              note: Value(note),
              source: Value(source),
              referenceId: Value(referenceId),
              fromCurrencyJson: Value(fromCurrency?.toJsonString()),
              createdAt: now,
            ),
          );
      await (_db.update(_db.walletAccounts)..where((a) => a.id.equals(id))).write(
            WalletAccountsCompanion(
              balanceMinor: Value(newBalanceMinor),
              updatedAt: Value(now),
            ),
          );
    });
    await logAction('wallet_adjust', 'wallet', id, detail: {
      'op': 'set',
      'before': before,
      'after': newBalanceMinor,
    });
  }

  Future<void> adjustWalletDelta(
    String accountId,
    int deltaMinor, {
    String? note,
    String source = 'manual',
    String? referenceId,
    FromCurrencySnapshot? fromCurrency,
  }) async {
    if (deltaMinor == 0) return;
    final account = await (_db.select(_db.walletAccounts)
          ..where((a) => a.id.equals(accountId)))
        .getSingleOrNull();
    if (account == null) return;
    final before = account.balanceMinor;
    final after = before + deltaMinor;
    final now = DateTime.now().toUtc();
    final opType = deltaMinor > 0 ? 'increase' : 'decrease';
    await _db.transaction(() async {
      await _db.into(_db.walletLedgerEntries).insert(
            WalletLedgerEntriesCompanion.insert(
              id: _uuid.v4(),
              accountId: accountId,
              opType: opType,
              amountMinor: deltaMinor.abs(),
              balanceBeforeMinor: before,
              balanceAfterMinor: after,
              note: Value(note),
              source: Value(source),
              referenceId: Value(referenceId),
              fromCurrencyJson: Value(fromCurrency?.toJsonString()),
              createdAt: now,
            ),
          );
      await (_db.update(_db.walletAccounts)..where((a) => a.id.equals(accountId)))
          .write(
        WalletAccountsCompanion(
          balanceMinor: Value(after),
          updatedAt: Value(now),
        ),
      );
    });
    await logAction('wallet_adjust', 'wallet', accountId, detail: {
      'op': opType,
      'delta': deltaMinor,
      'before': before,
      'after': after,
    });
  }

  Stream<List<WalletLedgerEntry>> watchWalletLedger(String accountId) {
    return (_db.select(_db.walletLedgerEntries)
          ..where((e) => e.accountId.equals(accountId))
          ..orderBy([
            (e) => OrderingTerm.desc(e.createdAt),
            (e) => OrderingTerm.desc(e.id),
          ]))
        .watch();
  }

  Stream<List<WalletLedgerEntry>> watchAllWalletLedger() {
    return (_db.select(_db.walletLedgerEntries)
          ..orderBy([
            (e) => OrderingTerm.asc(e.accountId),
            (e) => OrderingTerm.asc(e.createdAt),
          ]))
        .watch();
  }

  Future<void> deleteWalletAccount(String id) async {
    await (_db.delete(_db.walletAccounts)..where((a) => a.id.equals(id))).go();
    await logAction('wallet_account_delete', 'wallet', id);
  }

  // ── Savings Goals (Part F) ───────────────────────────────────────────────

  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return (_db.select(_db.savingsGoals)
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .watch();
  }

  Future<String> upsertSavingsGoal({
    String? id,
    required String name,
    required String emoji,
    required int targetMinor,
    int savedMinor = 0,
    String? note,
    DateTime? deadline,
  }) async {
    final goalId = id ?? _uuid.v4();
    await _db.into(_db.savingsGoals).insertOnConflictUpdate(
          SavingsGoalsCompanion.insert(
            id: goalId,
            name: name.trim(),
            emoji: Value(emoji),
            targetMinor: targetMinor,
            savedMinor: Value(savedMinor),
            note: Value(note?.trim()),
            deadline: Value(deadline?.toUtc()),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return goalId;
  }

  Future<void> addToSavingsGoal(String id, int amountMinor) async {
    final goal = await (_db.select(_db.savingsGoals)
          ..where((g) => g.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (goal == null) return;
    final newSaved = goal.savedMinor + amountMinor;
    final isCompleted = newSaved >= goal.targetMinor;
    await (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(
          SavingsGoalsCompanion(
            savedMinor: Value(newSaved),
            isCompleted: Value(isCompleted),
          ),
        );
  }

  Future<void> deleteSavingsGoal(String id) async {
    await (_db.delete(_db.savingsGoals)..where((g) => g.id.equals(id))).go();
  }

  // ── Managed currencies & exchange rates ────────────────────────────────────

  Stream<List<ManagedCurrency>> watchManagedCurrencies() {
    return (_db.select(_db.managedCurrencies)
          ..orderBy([(c) => OrderingTerm.asc(c.code)]))
        .watch();
  }

  Future<void> addManagedCurrency({
    required String code,
    required int fractionDigits,
    required num initialRateToDefault,
    int rateScale = 0,
  }) async {
    final upper = code.trim().toUpperCase();
    if (upper.isEmpty) return;
    final defaultCode = await defaultCurrencyCode();
    if (upper == defaultCode) return;
    final now = DateTime.now().toUtc();
    await _db.into(_db.managedCurrencies).insertOnConflictUpdate(
          ManagedCurrenciesCompanion.insert(
            code: upper,
            fractionDigits: Value(fractionDigits),
            createdAt: now,
          ),
        );
    await setExchangeRate(
      currencyCode: upper,
      rate: initialRateToDefault,
      rateScale: rateScale,
      note: 'Initial rate',
    );
    await logAction('currency_add', 'currency', upper, silent: true);
  }

  Future<void> setExchangeRate({
    required String currencyCode,
    required num rate,
    int rateScale = 0,
    String? note,
  }) async {
    final upper = currencyCode.trim().toUpperCase();
    final defaultCode = await defaultCurrencyCode();
    if (upper == defaultCode || rate <= 0) return;
    await _db.into(_db.exchangeRateHistory).insert(
          ExchangeRateHistoryCompanion.insert(
            id: _uuid.v4(),
            currencyCode: upper,
            rateToDefault: rateToStored(rate, scale: rateScale),
            rateScale: Value(rateScale),
            recordedAt: DateTime.now().toUtc(),
            note: Value(note),
          ),
        );
    await logAction('rate_set', 'currency', upper, silent: true, detail: {
      'rate': rate,
      'rateScale': rateScale,
    });
  }

  Future<num?> currentRateFor(String currencyCode) async {
    final upper = currencyCode.trim().toUpperCase();
    final defaultCode = await defaultCurrencyCode();
    if (upper == defaultCode) return 1;
    final row = await (_db.select(_db.exchangeRateHistory)
          ..where((r) => r.currencyCode.equals(upper))
          ..orderBy([(r) => OrderingTerm.desc(r.recordedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return rateFromStored(row.rateToDefault, row.rateScale);
  }

  Stream<num?> watchCurrentRate(String currencyCode) {
    final upper = currencyCode.trim().toUpperCase();
    return (_db.select(_db.exchangeRateHistory)
          ..where((r) => r.currencyCode.equals(upper))
          ..orderBy([(r) => OrderingTerm.desc(r.recordedAt)])
          ..limit(1))
        .watchSingleOrNull()
        .map((r) => r == null ? null : rateFromStored(r.rateToDefault, r.rateScale));
  }

  Stream<List<ExchangeRateHistoryData>> watchRateHistory(String currencyCode) {
    return (_db.select(_db.exchangeRateHistory)
          ..where((r) => r.currencyCode.equals(currencyCode.toUpperCase()))
          ..orderBy([(r) => OrderingTerm.desc(r.recordedAt)]))
        .watch();
  }

  Future<int> convertWalletToDefaultMinor(int balanceMinor, String currencyCode) async {
    final defaultCode = await defaultCurrencyCode();
    if (currencyCode.toUpperCase() == defaultCode) return balanceMinor;
    final rate = await currentRateFor(currencyCode);
    if (rate == null) return balanceMinor;
    final currency = await (_db.select(_db.managedCurrencies)
          ..where((c) => c.code.equals(currencyCode.toUpperCase())))
        .getSingleOrNull();
    final frac = currency?.fractionDigits ?? 0;
    final major = balanceMinor / (frac > 0 ? _pow10(frac) : 1);
    return convertMajorToDefaultMinor(
      majorAmount: major,
      rate: rate,
      defaultFractionDigits: 0,
    );
  }

  int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  Future<int> daysSinceLastTransaction() async {
    final row = await (_db.select(_db.ledgerTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return 999;
    return DateTime.now().toUtc().difference(row.createdAt).inDays;
  }

  Future<void> deleteManagedCurrency(String code) async {
    final upper = code.trim().toUpperCase();
    final inUse = await (_db.select(_db.walletAccounts)
          ..where((a) => a.currencyCode.equals(upper))
          ..limit(1))
        .getSingleOrNull();
    if (inUse != null) {
      throw StateError('Currency in use by wallet ${inUse.name}');
    }
    await (_db.delete(_db.exchangeRateHistory)
          ..where((r) => r.currencyCode.equals(upper)))
        .go();
    await (_db.delete(_db.managedCurrencies)..where((c) => c.code.equals(upper)))
        .go();
    await logAction('currency_delete', 'currency', upper, silent: true);
  }
}

class _ImportedSubscriptionPayload {
  const _ImportedSubscriptionPayload({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.fromCurrencyJson,
    required this.note,
    required this.categoryName,
    required this.scheduleType,
    required this.billingDayOfMonth,
    required this.rollingDays,
    required this.nextDueAt,
    required this.lastLoggedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String? fromCurrencyJson;
  final String? note;
  final String? categoryName;
  final String scheduleType;
  final int? billingDayOfMonth;
  final int? rollingDays;
  final DateTime nextDueAt;
  final DateTime? lastLoggedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory _ImportedSubscriptionPayload.fromMap(Map<String, dynamic> map) {
    final title = (map['title'] ?? '').toString().trim();
    final amountMinor = (map['amountMinor'] as num?)?.toInt();
    final nextDueRaw = map['nextDueAt']?.toString();
    if (title.isEmpty || amountMinor == null || amountMinor <= 0 || nextDueRaw == null) {
      throw const FormatException('Subscription item has missing required fields');
    }
    final nextDue = DateTime.tryParse(nextDueRaw)?.toUtc();
    if (nextDue == null) {
      throw const FormatException('Subscription nextDueAt is invalid');
    }
    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc() ??
            DateTime.now().toUtc();
    final updatedAt =
        DateTime.tryParse((map['updatedAt'] ?? '').toString())?.toUtc() ?? createdAt;
    final fromFc = map['fromCurrency'];
    String? fromJson;
    if (fromFc is Map) {
      fromJson = jsonEncode(fromFc);
    }
    return _ImportedSubscriptionPayload(
      id: (map['id'] ?? const Uuid().v4()).toString().trim(),
      title: title,
      amountMinor: amountMinor,
      currencyCode: (map['currencyCode'] ?? 'DZD').toString(),
      fromCurrencyJson: fromJson,
      note: map['note']?.toString(),
      categoryName: map['categoryName']?.toString(),
      scheduleType: (map['scheduleType'] ?? 'rolling_days').toString(),
      billingDayOfMonth: (map['billingDayOfMonth'] as num?)?.toInt(),
      rollingDays: (map['rollingDays'] as num?)?.toInt(),
      nextDueAt: nextDue,
      lastLoggedAt: DateTime.tryParse((map['lastLoggedAt'] ?? '').toString())?.toUtc(),
      isActive: map['isActive'] != false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class _ImportedPersonalFinancePayload {
  const _ImportedPersonalFinancePayload({
    required this.id,
    required this.kind,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.fromCurrencyJson,
    required this.note,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int kind;
  final String title;
  final int amountMinor;
  final String? currencyCode;
  final String? fromCurrencyJson;
  final String? note;
  /// Human-readable category name carried across exports (v2+). Null in v1 exports.
  final String? categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory _ImportedPersonalFinancePayload.fromMap(Map<String, dynamic> map) {
    final kind = (map['kind'] as num?)?.toInt();
    final amountMinor = (map['amountMinor'] as num?)?.toInt();
    final title = (map['title'] ?? '').toString().trim();
    final createdRaw = map['createdAt']?.toString();
    if (kind == null ||
        kind < 0 ||
        kind >= PersonalFinanceKind.values.length ||
        amountMinor == null ||
        amountMinor <= 0 ||
        title.isEmpty ||
        createdRaw == null) {
      throw const FormatException('Personal finance entry has missing required fields');
    }
    final createdAt = DateTime.tryParse(createdRaw)?.toUtc();
    if (createdAt == null) {
      throw const FormatException('Personal finance entry createdAt is invalid');
    }
    final updatedAt =
        DateTime.tryParse((map['updatedAt'] ?? '').toString())?.toUtc() ?? createdAt;
    final fromNode = map['fromCurrency'];
    String? fromCurrencyJson;
    if (fromNode is Map) {
      final snap = FromCurrencySnapshot.fromJsonMap(
        fromNode.cast<String, dynamic>(),
      );
      fromCurrencyJson = snap?.toJsonString();
    }
    return _ImportedPersonalFinancePayload(
      id: (map['id'] ?? '').toString().trim(),
      kind: kind,
      title: title,
      amountMinor: amountMinor,
      currencyCode: map['currencyCode']?.toString(),
      fromCurrencyJson: fromCurrencyJson,
      note: map['note']?.toString(),
      categoryName: map['categoryName']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class _ImportedTagPayload {
  const _ImportedTagPayload({
    required this.name,
    required this.colorHex,
  });

  final String name;
  final String? colorHex;

  factory _ImportedTagPayload.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString().trim();
    if (name.isEmpty) {
      throw const FormatException('Tag name is required');
    }
    return _ImportedTagPayload(
      name: name,
      colorHex: map['colorHex']?.toString(),
    );
  }
}

class _ImportedTransactionPayload {
  const _ImportedTransactionPayload({
    required this.sourceTransactionId,
    required this.amountMinor,
    required this.txType,
    required this.txStatus,
    required this.createdAt,
    required this.effectiveAt,
    required this.note,
    required this.currencyCode,
    required this.fromCurrencyJson,
    required this.tags,
  });

  final String? sourceTransactionId;
  final int amountMinor;
  final int txType;
  final int txStatus;
  final DateTime createdAt;
  final DateTime? effectiveAt;
  final String? note;
  final String? currencyCode;
  final String? fromCurrencyJson;
  final List<_ImportedTagPayload> tags;

  factory _ImportedTransactionPayload.fromMap(Map<String, dynamic> map) {
    final amountMinor = (map['amountMinor'] as num?)?.toInt();
    final txType = (map['txType'] as num?)?.toInt();
    final txStatus = (map['txStatus'] as num?)?.toInt();
    final createdAtRaw = map['createdAt']?.toString();
    if (amountMinor == null ||
        amountMinor <= 0 ||
        txType == null ||
        txStatus == null ||
        createdAtRaw == null) {
      throw const FormatException('Transaction has missing required fields');
    }
    final createdAt = DateTime.tryParse(createdAtRaw)?.toUtc();
    if (createdAt == null) {
      throw const FormatException('Transaction createdAt is invalid');
    }
    final effectiveAt = DateTime.tryParse((map['effectiveAt'] ?? '').toString())?.toUtc();
    final tagsNode = map['tags'];
    final tags = tagsNode is List
        ? tagsNode
            .whereType<Map>()
            .map((e) => _ImportedTagPayload.fromMap(e.cast<String, dynamic>()))
            .toList()
        : const <_ImportedTagPayload>[];
    final fromNode = map['fromCurrency'];
    String? fromCurrencyJson;
    if (fromNode is Map) {
      final snap = FromCurrencySnapshot.fromJsonMap(
        fromNode.cast<String, dynamic>(),
      );
      fromCurrencyJson = snap?.toJsonString();
    }
    return _ImportedTransactionPayload(
      sourceTransactionId: map['sourceTransactionId']?.toString(),
      amountMinor: amountMinor,
      txType: txType,
      txStatus: txStatus,
      createdAt: createdAt,
      effectiveAt: effectiveAt,
      note: map['note']?.toString(),
      currencyCode: map['currencyCode']?.toString(),
      fromCurrencyJson: fromCurrencyJson,
      tags: tags,
    );
  }
}

class _ImportedClientPayload {
  const _ImportedClientPayload({
    required this.importClientKey,
    required this.fullName,
    required this.phone,
    required this.note,
    required this.source,
    required this.createdAt,
    required this.lastInteractionAt,
    required this.archivedAt,
    required this.clientTags,
    required this.transactions,
  });

  final String importClientKey;
  final String fullName;
  final String? phone;
  final String? note;
  final String? source;
  final DateTime? createdAt;
  final DateTime? lastInteractionAt;
  final DateTime? archivedAt;
  final List<_ImportedTagPayload> clientTags;
  final List<_ImportedTransactionPayload> transactions;

  factory _ImportedClientPayload.fromMap(Map<String, dynamic> map) {
    final fullName = (map['fullName'] ?? '').toString().trim();
    if (fullName.isEmpty) {
      throw const FormatException('Client fullName is required');
    }
    final sourceId = (map['sourceClientId'] ?? '').toString().trim();
    final phone = map['phone']?.toString();
    final key = sourceId.isEmpty ? '$fullName|${phone ?? ''}' : sourceId;
    final tagsNode = map['tags'];
    final clientTags = tagsNode is List
        ? tagsNode
            .whereType<Map>()
            .map((e) => _ImportedTagPayload.fromMap(e.cast<String, dynamic>()))
            .toList()
        : const <_ImportedTagPayload>[];
    final txNode = map['transactions'];
    final txs = txNode is List
        ? txNode
            .whereType<Map>()
            .map((e) => _ImportedTransactionPayload.fromMap(e.cast<String, dynamic>()))
            .toList()
        : const <_ImportedTransactionPayload>[];

    return _ImportedClientPayload(
      importClientKey: key,
      fullName: fullName,
      phone: phone,
      note: map['note']?.toString(),
      source: map['source']?.toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc(),
      lastInteractionAt: DateTime.tryParse((map['lastInteractionAt'] ?? '').toString())?.toUtc(),
      archivedAt: DateTime.tryParse((map['archivedAt'] ?? '').toString())?.toUtc(),
      clientTags: clientTags,
      transactions: txs,
    );
  }
}

// ── v9 import payload classes ──────────────────────────────────────────────

class _ImportedCategoryPayload {
  const _ImportedCategoryPayload({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconCodePoint,
    required this.budgetMinorPerMonth,
    required this.scope,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String colorHex;
  final int iconCodePoint;
  final int? budgetMinorPerMonth;
  final String scope;
  final DateTime createdAt;

  factory _ImportedCategoryPayload.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString().trim();
    final scope = (map['scope'] ?? '').toString().trim();
    final iconCodePoint = (map['iconCodePoint'] as num?)?.toInt();
    if (name.isEmpty || scope.isEmpty || iconCodePoint == null) {
      throw const FormatException('Category has missing required fields');
    }
    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc() ??
            DateTime.now().toUtc();
    return _ImportedCategoryPayload(
      id: (map['id'] ?? const Uuid().v4()).toString().trim(),
      name: name,
      colorHex: (map['colorHex'] ?? '#22C55E').toString(),
      iconCodePoint: iconCodePoint,
      budgetMinorPerMonth: (map['budgetMinorPerMonth'] as num?)?.toInt(),
      scope: scope,
      createdAt: createdAt,
    );
  }
}

class _ImportedWishlistPayload {
  const _ImportedWishlistPayload({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.note,
    required this.categoryName,
    required this.isPurchased,
    required this.createdAt,
    required this.purchasedAt,
  });

  final String id;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String? note;
  final String? categoryName;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? purchasedAt;

  factory _ImportedWishlistPayload.fromMap(Map<String, dynamic> map) {
    final title = (map['title'] ?? '').toString().trim();
    final amountMinor = (map['amountMinor'] as num?)?.toInt();
    if (title.isEmpty || amountMinor == null || amountMinor <= 0) {
      throw const FormatException('Wishlist item has missing required fields');
    }
    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc() ??
            DateTime.now().toUtc();
    return _ImportedWishlistPayload(
      id: (map['id'] ?? const Uuid().v4()).toString().trim(),
      title: title,
      amountMinor: amountMinor,
      currencyCode: (map['currencyCode'] ?? 'DZD').toString(),
      note: map['note']?.toString(),
      categoryName: map['categoryName']?.toString(),
      isPurchased: (map['isPurchased'] as num?)?.toInt() == 1,
      createdAt: createdAt,
      purchasedAt: DateTime.tryParse((map['purchasedAt'] ?? '').toString())?.toUtc(),
    );
  }
}

class _ImportedWalletPayload {
  const _ImportedWalletPayload({
    required this.id,
    required this.name,
    required this.emoji,
    required this.currencyCode,
    required this.balanceMinor,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String emoji;
  final String? currencyCode;
  final int balanceMinor;
  final int sortOrder;
  final DateTime createdAt;

  factory _ImportedWalletPayload.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString().trim();
    if (name.isEmpty) {
      throw const FormatException('Wallet account name is required');
    }
    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc() ??
            DateTime.now().toUtc();
    return _ImportedWalletPayload(
      id: (map['id'] ?? const Uuid().v4()).toString().trim(),
      name: name,
      emoji: (map['emoji'] ?? '💵').toString(),
      currencyCode: map['currencyCode']?.toString(),
      balanceMinor: (map['balanceMinor'] as num?)?.toInt() ?? 0,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
    );
  }
}

class _ImportedSavingsPayload {
  const _ImportedSavingsPayload({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetMinor,
    required this.savedMinor,
    required this.note,
    required this.deadline,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String emoji;
  final int targetMinor;
  final int savedMinor;
  final String? note;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  factory _ImportedSavingsPayload.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString().trim();
    final targetMinor = (map['targetMinor'] as num?)?.toInt();
    if (name.isEmpty || targetMinor == null || targetMinor <= 0) {
      throw const FormatException('Savings goal has missing required fields');
    }
    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString())?.toUtc() ??
            DateTime.now().toUtc();
    return _ImportedSavingsPayload(
      id: (map['id'] ?? const Uuid().v4()).toString().trim(),
      name: name,
      emoji: (map['emoji'] ?? '🎯').toString(),
      targetMinor: targetMinor,
      savedMinor: (map['savedMinor'] as num?)?.toInt() ?? 0,
      note: map['note']?.toString(),
      deadline: DateTime.tryParse((map['deadline'] ?? '').toString())?.toUtc(),
      isCompleted: (map['isCompleted'] as num?)?.toInt() == 1,
      createdAt: createdAt,
    );
  }
}

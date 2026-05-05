import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';
import 'ledger_types.dart';

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
    required this.skippedClients,
    required this.addedTransactions,
    required this.skippedDuplicateTransactions,
  });

  final int addedClients;
  final int updatedClients;
  final int skippedClients;
  final int addedTransactions;
  final int skippedDuplicateTransactions;
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

  Future<String> exportAllClientsWithTransactionsJson() async {
    final clients = await (_db.select(_db.clients)
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

    final payload = {
      'version': 1,
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
            'amountMinor': tx.amountMinor,
            'currencyCode': tx.currencyCode,
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
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
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
  }

  Future<void> insertTransaction({
    required String clientId,
    required int amountMinor,
    required LedgerTxType type,
    String currencyCode = 'DZD',
    String? note,
    String createdBy = 'manual',
    String channel = 'other',
    String? referenceNo,
    DateTime? effectiveAt,
    int attachmentsCount = 0,
    List<String> tagIds = const [],
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be positive');
    }
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      final createdAt = await _allocateCreatedAt(clientId, now);
      await _db.into(_db.ledgerTransactions).insert(
            LedgerTransactionsCompanion.insert(
              id: id,
              clientId: clientId,
              amountMinor: amountMinor,
              currencyCode: Value(currencyCode),
              createdBy: Value(createdBy),
              channel: Value(channel),
              referenceNo: Value(referenceNo),
              effectiveAt: Value(effectiveAt ?? createdAt),
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
  }

  Future<void> updateTransaction({
    required String id,
    required int amountMinor,
    required LedgerTxType type,
    String? note,
    List<String>? tagIds,
    DateTime? effectiveAt,
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
              updatedAt: Value(now),
            ),
          );
      if (tagIds != null) {
        await _replaceTransactionTags(id, tagIds);
      }
      await _recordQuickAction(type, amountMinor);
      await _refreshPostingSnapshots(tx.clientId);
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
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
          AppSettingsCompanion(defaultCurrencyCode: Value(trimmed)),
        );
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

  Future<ImportApplyResult> importFromJson(
    String rawJson, {
    required Map<String, ImportConflictResolution> conflictResolutionsByImportKey,
  }) async {
    final importedClients = _parseImportClients(rawJson);
    var addedClients = 0;
    var updatedClients = 0;
    var skippedClients = 0;
    var addedTransactions = 0;
    var skippedDuplicateTransactions = 0;

    await _db.transaction(() async {
      final existingClients = await (_db.select(_db.clients)).get();
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
          if (resolution == ImportConflictResolution.erase) {
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
        if (existing != null && resolution == ImportConflictResolution.mix) {
          final existingTxs = await (_db.select(_db.ledgerTransactions)
                ..where((t) => t.clientId.equals(existing.id)))
              .get();
          for (final tx in existingTxs) {
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

          final txId = _uuid.v4();
          await _db.into(_db.ledgerTransactions).insert(
                LedgerTransactionsCompanion.insert(
                  id: txId,
                  clientId: targetClientId,
                  amountMinor: tx.amountMinor,
                  currencyCode: Value(tx.currencyCode ?? 'DZD'),
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
          addedTransactions += 1;
        }

        await _refreshPostingSnapshots(targetClientId);
      }
    });

    return ImportApplyResult(
      addedClients: addedClients,
      updatedClients: updatedClients,
      skippedClients: skippedClients,
      addedTransactions: addedTransactions,
      skippedDuplicateTransactions: skippedDuplicateTransactions,
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
    required this.amountMinor,
    required this.txType,
    required this.txStatus,
    required this.createdAt,
    required this.effectiveAt,
    required this.note,
    required this.currencyCode,
    required this.tags,
  });

  final int amountMinor;
  final int txType;
  final int txStatus;
  final DateTime createdAt;
  final DateTime? effectiveAt;
  final String? note;
  final String? currencyCode;
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
    return _ImportedTransactionPayload(
      amountMinor: amountMinor,
      txType: txType,
      txStatus: txStatus,
      createdAt: createdAt,
      effectiveAt: effectiveAt,
      note: map['note']?.toString(),
      currencyCode: map['currencyCode']?.toString(),
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

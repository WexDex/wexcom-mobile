import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';
import 'ledger_types.dart';

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
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<String> createClient({
    required String fullName,
    String? phone,
    String? note,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _db.into(_db.clients).insert(
          ClientsCompanion.insert(
            id: id,
            fullName: fullName,
            phone: Value(phone),
            note: Value(note),
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
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(id))).write(
          ClientsCompanion(
            fullName: Value(fullName),
            phone: Value(phone),
            note: Value(note),
            updatedAt: Value(now),
          ),
        );
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
              txType: type.index,
              txStatus: LedgerTxStatus.active.index,
              postedBalanceBeforeMinor: 0,
              postedBalanceAfterMinor: 0,
              createdAt: createdAt,
              updatedAt: createdAt,
              note: Value(note),
            ),
          );
      await _refreshPostingSnapshots(clientId);
    });
  }

  Future<void> updateTransaction({
    required String id,
    required int amountMinor,
    required LedgerTxType type,
    String? note,
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
              updatedAt: Value(now),
            ),
          );
      await _refreshPostingSnapshots(tx.clientId);
    });
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
    if (proposedUtc.isAfter(last)) return proposedUtc;
    return last.add(const Duration(milliseconds: 1));
  }
}

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wexcom_mobile/data/db/app_database.dart';
import 'package:wexcom_mobile/data/ledger_repository.dart';
import 'package:wexcom_mobile/data/ledger_types.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LedgerRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('payment then debt balance and posted snapshots', () async {
    final cid = await repo.createClient(fullName: 'Ada');

    await repo.insertTransaction(
      clientId: cid,
      amountMinor: 5000,
      type: LedgerTxType.payment,
    );
    expect(await repo.computeBalance(cid), -5000);

    await repo.insertTransaction(
      clientId: cid,
      amountMinor: 2000,
      type: LedgerTxType.debt,
    );
    expect(await repo.computeBalance(cid), -3000);

    final client = await db.select(db.clients).getSingle();
    expect(client.balanceMinor, -3000);

    final txs = await (db.select(db.ledgerTransactions)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    expect(txs, hasLength(2));
    expect(txs[0].postedBalanceBeforeMinor, 0);
    expect(txs[0].postedBalanceAfterMinor, -5000);
    expect(txs[1].postedBalanceBeforeMinor, -5000);
    expect(txs[1].postedBalanceAfterMinor, -3000);
  });

  test('cancel fills cancel snapshots and recomputes balance', () async {
    final cid = await repo.createClient(fullName: 'Bob');

    await repo.insertTransaction(
      clientId: cid,
      amountMinor: 1000,
      type: LedgerTxType.payment,
    );
    await repo.insertTransaction(
      clientId: cid,
      amountMinor: 400,
      type: LedgerTxType.debt,
    );

    expect(await repo.computeBalance(cid), -600);

    final txs = await db.select(db.ledgerTransactions).get();
    final paymentId = txs.firstWhere((t) => t.txType == LedgerTxType.payment.index).id;

    await repo.cancelTransaction(paymentId);

    expect(await repo.computeBalance(cid), 400);

    final cancelled = await (db.select(db.ledgerTransactions)..where((t) => t.id.equals(paymentId)))
        .getSingle();
    expect(cancelled.txStatus, LedgerTxStatus.cancelled.index);
    expect(cancelled.cancelledAt, isNotNull);
    expect(cancelled.cancelBalanceBeforeMinor, -600);
    expect(cancelled.cancelBalanceAfterMinor, 400);

    final client = await db.select(db.clients).getSingle();
    expect(client.balanceMinor, 400);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wexcom_mobile/data/db/app_database.dart';
import 'package:wexcom_mobile/data/ledger_repository.dart';
import 'package:wexcom_mobile/main.dart';
import 'package:wexcom_mobile/providers/providers.dart';

void main() {
  testWidgets('Shows Home title', (WidgetTester tester) async {
    // Avoid Drift stream teardown timers conflicting with fake_async by not
    // subscribing ClientListScreen to a live DB stream in this smoke test.
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
          activeClientsProvider.overrideWith((ref) => Stream.value([])),
          allTransactionsProvider
              .overrideWith((ref, _) => Stream.value(<LedgerTransactionWithClient>[])),
        ],
        child: const WexcomDebtApp(enablePeriodicSync: false),
      ),
    );

    await tester.pump();
    expect(find.text('Home'), findsWidgets);
  });
}

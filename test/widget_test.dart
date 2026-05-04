import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wexcom_mobile/data/db/app_database.dart';
import 'package:wexcom_mobile/main.dart';
import 'package:wexcom_mobile/providers/providers.dart';

void main() {
  testWidgets('Shows Clients title', (WidgetTester tester) async {
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
        ],
        child: const WexcomDebtApp(),
      ),
    );

    await tester.pump();
    expect(find.text('Clients'), findsOneWidget);
  });
}

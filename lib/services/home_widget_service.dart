import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../data/db/app_database.dart';
import '../data/ledger_repository.dart';
import '../data/ledger_types.dart';
import 'notification_service.dart';

/// Background entry point for interactive widget taps (no UI).
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'roulette') return;
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  final db = AppDatabase();
  try {
    final repo = LedgerRepository(db);
    await HomeWidgetService.runDebtRoulette(repo);
  } finally {
    await db.close();
  }
}

/// Android home-screen widgets: quick actions, debt roulette, rate display.
class HomeWidgetService {
  HomeWidgetService._();

  static const quickWidgetName = 'WexcomQuickWidgetProvider';
  static const rateWidgetName = 'WexcomRateWidgetProvider';

  static bool _listening = false;

  static Future<void> init(
    LedgerRepository repo, {
    void Function(Uri uri)? onLaunch,
  }) async {
    if (!Platform.isAndroid) return;

    if (!_listening) {
      _listening = true;
      HomeWidget.widgetClicked.listen((uri) async {
        if (uri == null) return;
        if (uri.host == 'roulette') return;
        onLaunch?.call(uri);
      });
    }

    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initial != null && initial.host != 'roulette') {
      onLaunch?.call(initial);
    }

    await syncWidgetData(repo);
  }

  static Future<void> syncWidgetData(LedgerRepository repo) async {
    if (!Platform.isAndroid) return;

    final defaultCode = await repo.defaultCurrencyCode();
    await HomeWidget.saveWidgetData('default_currency', defaultCode);

    final currencies = await repo.watchManagedCurrencies().first;
    for (final c in currencies) {
      if (c.code == defaultCode) continue;
      final rate = await repo.currentRateFor(c.code);
      if (rate == null) continue;
      await HomeWidget.saveWidgetData('rate_${c.code}', rate.toString());
      await HomeWidget.saveWidgetData('rate_currency', c.code);
    }

    await HomeWidget.updateWidget(androidName: quickWidgetName);
    await HomeWidget.updateWidget(androidName: rateWidgetName);
  }

  static Future<void> runDebtRoulette(LedgerRepository repo) async {
    final clients = await repo.watchActiveClients().first;
    final withDebt = clients.where((c) => c.balanceMinor > 0).toList();
    if (withDebt.isEmpty) return;
    withDebt.shuffle(Random());
    final pick = withDebt.first;
    final code = await repo.defaultCurrencyCode();
    await NotificationService.showDebtRoulette(
      clientName: pick.fullName,
      balanceMinor: pick.balanceMinor,
      currencyCode: code,
    );
  }

  /// Parsed from widget / deep-link query params on the transactions screen.
  static ({bool open, LedgerTxType? type}) parseTransactionLaunch(Uri uri) {
    final isTransactions = uri.host == 'transactions' ||
        uri.path == '/transactions' ||
        uri.path.startsWith('/transactions');
    if (!isTransactions) return (open: false, type: null);
    final params = uri.queryParameters;
    final action = params['action'];
    if (action != 'new' && action != 'new_tx') {
      return (open: false, type: null);
    }
    final typeRaw = params['type'];
    if (typeRaw == 'payment') {
      return (open: true, type: LedgerTxType.payment);
    }
    if (typeRaw == 'debt') {
      return (open: true, type: LedgerTxType.debt);
    }
    return (open: true, type: null);
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'router/app_router.dart';
import 'services/cloud_sync_service.dart';
import 'services/home_widget_service.dart';
import 'services/notification_scheduler.dart';
import 'services/notification_service.dart';
import 'services/periodic_sync.dart';
import 'theme/app_theme.dart';
import 'utils/chart_curve.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CloudSyncService.applyPendingRestoreIfAny();
  await NotificationService.initialize();
  runApp(const ProviderScope(child: WexcomDebtApp()));
}

class WexcomDebtApp extends ConsumerStatefulWidget {
  const WexcomDebtApp({
    super.key,
    this.enablePeriodicSync = true,
  });

  final bool enablePeriodicSync;

  @override
  ConsumerState<WexcomDebtApp> createState() => _WexcomDebtAppState();
}

class _WexcomDebtAppState extends ConsumerState<WexcomDebtApp> {
  bool _checkedContactsPermission = false;
  PeriodicSync? _periodicSync;

  @override
  void initState() {
    super.initState();
    if (widget.enablePeriodicSync) {
      _periodicSync = PeriodicSync(ref)..start();
    }
    Future.microtask(_maybeRequestContactsPermissionAtStartup);
    Future.microtask(_bootstrapApp);
  }

  Future<void> _bootstrapApp() async {
    final repo = ref.read(ledgerRepositoryProvider);
    final s = await repo.getAppSettings();
    if (s != null) {
      currentChartCurveStyle = ChartCurveStyle.fromStorage(s.chartCurveStyle);
    }
    await refreshScheduledNotifications(repo);
    await runNotificationChecks(repo);
    if (Platform.isAndroid) {
      await NotificationService.requestAndroidPermission();
      await HomeWidgetService.init(
        repo,
        onLaunch: (uri) {
          final router = ref.read(goRouterProvider);
          if (uri.host == 'transactions') {
            router.go(Uri(path: '/transactions', queryParameters: uri.queryParameters).toString());
          } else if (uri.host == 'tags') {
            router.go(Uri(path: '/tags', queryParameters: uri.queryParameters).toString());
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _periodicSync?.dispose();
    super.dispose();
  }

  Future<void> _maybeRequestContactsPermissionAtStartup() async {
    if (_checkedContactsPermission) return;
    _checkedContactsPermission = true;
    final contactsEnabled = await ref.read(contactsAutofillEnabledProvider.future);
    final contactsService = ref.read(contactsServiceProvider);
    if (!contactsEnabled || !contactsService.isSupported) return;
    final hasPermission = await contactsService.hasPermission();
    if (!hasPermission) {
      await contactsService.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Debt ledger',
      theme: AppTheme.dark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

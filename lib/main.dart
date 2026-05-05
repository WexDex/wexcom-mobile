import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'router/app_router.dart';
import 'services/periodic_sync.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

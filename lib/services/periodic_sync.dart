import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ledger_repository.dart';
import '../providers/providers.dart';

class PeriodicSync {
  PeriodicSync(this._ref);

  final WidgetRef _ref;
  ProviderSubscription<AsyncValue<SyncSettingsData>>? _settingsSub;
  Timer? _timer;
  bool _tickRunning = false;

  void start() {
    _settingsSub?.close();
    _settingsSub = _ref.listenManual<AsyncValue<SyncSettingsData>>(
      syncSettingsProvider,
      (previous, next) {
        final settings = next.valueOrNull;
        if (settings == null) return;
        _resetTimer(settings);
      },
      fireImmediately: true,
    );
  }

  void dispose() {
    _timer?.cancel();
    _settingsSub?.close();
  }

  void _resetTimer(SyncSettingsData settings) {
    _timer?.cancel();
    if (!settings.enabled || !settings.periodicEnabled) return;
    final hours = settings.intervalHours <= 0 ? 24 : settings.intervalHours;
    _timer = Timer.periodic(Duration(hours: hours), (_) => _tick());
  }

  Future<void> _tick() async {
    if (_tickRunning) return;
    _tickRunning = true;
    try {
      final settings = await _ref.read(syncSettingsProvider.future);
      if (!settings.enabled || !settings.periodicEnabled) return;
      final service = _ref.read(syncServiceProvider);
      if (service == null) return;
      final repo = _ref.read(ledgerRepositoryProvider);
      final localSha = await repo.currentExportSha256();
      if (settings.lastUploadSha256 == localSha) {
        return;
      }
      await service.getStatus(localSha256: localSha);
      final json = await repo.exportAllClientsWithTransactionsJson();
      final result = await service.uploadAll(json, deviceName: 'wexcom-mobile');
      await repo.updateSyncUploadMeta(
        uploadedAt: result.uploadedAt,
        sha256Hex: result.sha256,
      );
      await repo.updateSyncServerOkMeta(DateTime.now().toUtc());
      _ref.invalidate(syncSettingsProvider);
      _ref.invalidate(serverStatusProvider);
    } catch (_) {
      // Ignore periodic sync failures; manual sync remains available.
    } finally {
      _tickRunning = false;
    }
  }
}

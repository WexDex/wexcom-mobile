import '../data/ledger_repository.dart';
import '../services/notification_service.dart';

/// Reschedules local notifications from app_settings.
Future<void> refreshScheduledNotifications(LedgerRepository repo) async {
  final s = await repo.getAppSettings();
  if (s == null) return;

  if (s.notifBalanceMilestoneEnabled) {
    await NotificationService.scheduleBalanceDigest(
      hourOfDay: s.notifOverdueHour,
    );
  } else {
    await NotificationService.cancelBalanceDigest();
  }

  if (s.notifInactivityEnabled) {
    await NotificationService.scheduleInactivityReminder(
      daysThreshold: s.notifInactivityDays,
      hourOfDay: s.notifOverdueHour,
    );
  } else {
    await NotificationService.cancelInactivityReminder();
  }
}

Future<void> runNotificationChecks(LedgerRepository repo) async {
  final s = await repo.getAppSettings();
  if (s == null) return;

  if (s.notifBalanceMilestoneEnabled) {
    final clients = await repo.watchActiveClients().first;
    final threshold = s.notifBalanceMilestoneMinor;
    final over = clients
        .where((c) => c.balanceMinor >= threshold)
        .map((c) => c.fullName)
        .toList();
    if (over.isNotEmpty) {
      final code = await repo.defaultCurrencyCode();
      await NotificationService.showBalanceDigest(
        clientNames: over,
        thresholdMinor: threshold,
        currencyCode: code,
      );
    }
  }

  if (s.notifInactivityEnabled) {
    final days = await repo.daysSinceLastTransaction();
    if (days >= s.notifInactivityDays) {
      await NotificationService.showInactivityReminder(daysSinceLast: days);
    }
  }
}

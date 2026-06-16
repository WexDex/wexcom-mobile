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

  if (s.notifBackupReminderEnabled) {
    await NotificationService.scheduleBackupReminder(
      hourOfDay: s.notifOverdueHour,
    );
  } else {
    await NotificationService.cancelBackupReminder();
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

  if (s.notifBackupReminderEnabled) {
    final last = s.lastJsonExportAt;
    final daysSince = last == null
        ? s.notifBackupReminderDays + 1
        : DateTime.now().toUtc().difference(last.toUtc()).inDays;
    if (daysSince >= s.notifBackupReminderDays) {
      await NotificationService.showBackupReminder(
        daysSinceLastExport: daysSince,
        neverExported: last == null,
      );
    }
  }

  final dueSubs = await repo.subscriptionsDueForReminder(withinDays: 3);
  if (dueSubs.isNotEmpty) {
    final now = DateTime.now();
    var overdue = 0;
    for (final sub in dueSubs) {
      if (sub.nextDueAt.toLocal().isBefore(
            DateTime(now.year, now.month, now.day),
          )) {
        overdue++;
      }
    }
    await NotificationService.showSubscriptionDueReminder(
      dueCount: dueSubs.length,
      overdueCount: overdue,
      nextTitle: dueSubs.first.title,
    );
  }
}

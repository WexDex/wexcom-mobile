import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/money.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelOverdue = 'wexcom_overdue';
  static const _channelSync = 'wexcom_sync';
  static const _channelActivity = 'wexcom_activity';
  static const _channelBalance = 'wexcom_balance';

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.initialize error: $e');
    }
  }

  // ── Overdue debt alert ─────────────────────────────────────────────────

  static Future<void> scheduleOverdueAlert({
    required int overdueCount,
    required int criticalCount,
    required int hourOfDay,
  }) async {
    if (!_initialized || overdueCount == 0) return;
    try {
      await _plugin.cancel(1);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, hourOfDay);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      final body = criticalCount > 0
          ? 'You have $overdueCount overdue debts — $criticalCount critical (90d+)'
          : 'You have $overdueCount overdue debt${overdueCount == 1 ? '' : 's'}';
      await _plugin.zonedSchedule(
        1,
        'Overdue Debts',
        body,
        scheduled,
        _details(_channelOverdue, 'Overdue Debts', importance: Importance.high),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleOverdueAlert error: $e');
    }
  }

  static Future<void> cancelOverdueAlert() async {
    try {
      await _plugin.cancel(1);
    } catch (_) {}
  }

  // ── Client balance milestone ───────────────────────────────────────────

  static Future<void> showBalanceMilestone({
    required String clientName,
    required int balanceMinor,
    required String currencyCode,
    required int thresholdMinor,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        2,
        'Balance milestone',
        '$clientName now owes ${MoneyFormat.formatMinor(balanceMinor, currencyCode)} '
            '— over your ${MoneyFormat.formatMinor(thresholdMinor, currencyCode)} alert',
        _details(_channelBalance, 'Balance Milestones'),
      );
    } catch (e) {
      debugPrint('showBalanceMilestone error: $e');
    }
  }

  // ── No activity reminder ───────────────────────────────────────────────

  static Future<void> showInactivityReminder({
    required int daysSinceLast,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        3,
        'No recent transactions',
        'No transactions in $daysSinceLast days — tap to open Wexcom',
        _details(_channelActivity, 'Activity Reminders'),
      );
    } catch (e) {
      debugPrint('showInactivityReminder error: $e');
    }
  }

  // ── Successful cloud sync ──────────────────────────────────────────────

  static Future<void> showSyncSuccess({
    required String sizeLabel,
    required DateTime uploadedAt,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        4,
        'Backup uploaded',
        'Backup uploaded · $sizeLabel · ${MoneyFormat.formatDate(uploadedAt)}',
        _details(
          _channelSync,
          'Cloud Sync',
          importance: Importance.low,
          priority: Priority.low,
        ),
      );
    } catch (e) {
      debugPrint('showSyncSuccess error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static NotificationDetails _details(
    String channelId,
    String channelName, {
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: priority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}

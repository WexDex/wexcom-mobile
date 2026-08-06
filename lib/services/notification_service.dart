import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/money.dart';
import 'notification_navigation.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelOverdue = 'wexcom_overdue';
  static const _channelSync = 'wexcom_sync';
  static const _channelActivity = 'wexcom_activity';
  static const _channelBalance = 'wexcom_balance';

  static Future<void> initialize({
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: onTap ?? handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            notificationTapBackgroundHandler,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.initialize error: $e');
    }
  }

  /// Call after [GoRouter] is available (e.g. app bootstrap).
  static Future<void> handleLaunchNotification() async {
    if (!_initialized) return;
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if (response != null) {
        handleNotificationResponse(response);
      }
    } catch (e) {
      debugPrint('handleLaunchNotification error: $e');
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

  /// Fires an immediate overdue notification for testing purposes.
  static Future<void> showOverdueAlert({
    required int overdueCount,
    required int criticalCount,
  }) async {
    if (!_initialized) return;
    try {
      final body = criticalCount > 0
          ? 'You have $overdueCount overdue debts — $criticalCount critical (90d+)'
          : 'You have $overdueCount overdue debt${overdueCount == 1 ? '' : 's'}';
      await _plugin.show(
        1,
        'Overdue Debts',
        body,
        _details(_channelOverdue, 'Overdue Debts', importance: Importance.high),
      );
    } catch (e) {
      debugPrint('showOverdueAlert error: $e');
    }
  }

  // ── Daily balance digest (scheduled) ───────────────────────────────────

  static Future<void> scheduleBalanceDigest({required int hourOfDay}) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(5);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hourOfDay);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        5,
        'Balance digest',
        'Tap to see clients over your milestone',
        scheduled,
        _details(_channelBalance, 'Balance Milestones'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleBalanceDigest error: $e');
    }
  }

  static Future<void> cancelBalanceDigest() async {
    try {
      await _plugin.cancel(5);
    } catch (_) {}
  }

  static Future<void> showBalanceDigest({
    required List<String> clientNames,
    required int thresholdMinor,
    required String currencyCode,
  }) async {
    if (!_initialized || clientNames.isEmpty) return;
    final names = clientNames.take(3).join(', ');
    final extra = clientNames.length > 3 ? ' +${clientNames.length - 3} more' : '';
      await _plugin.show(
        5,
        'Clients over ${MoneyFormat.formatMinor(thresholdMinor, currencyCode)}',
        '$names$extra',
        _details(_channelBalance, 'Balance Milestones', importance: Importance.high),
        payload: '/clients',
      );
  }

  static Future<void> scheduleInactivityReminder({
    required int daysThreshold,
    required int hourOfDay,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(6);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hourOfDay);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        6,
        'Activity check',
        'Reminder after $daysThreshold days without transactions',
        scheduled,
        _details(_channelActivity, 'Activity Reminders'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleInactivityReminder error: $e');
    }
  }

  static Future<void> cancelInactivityReminder() async {
    try {
      await _plugin.cancel(6);
    } catch (_) {}
  }

  static Future<void> scheduleBackupReminder({required int hourOfDay}) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(8);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hourOfDay);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        8,
        'Backup reminder',
        'Time to export your JSON backup',
        scheduled,
        _details(_channelActivity, 'Backup Reminders'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleBackupReminder error: $e');
    }
  }

  static Future<void> cancelBackupReminder() async {
    try {
      await _plugin.cancel(8);
    } catch (_) {}
  }

  // ── Daily finance logging reminder ─────────────────────────────────────

  static Future<void> scheduleFinanceDailyReminder({required int hourOfDay}) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(9);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hourOfDay);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        9,
        'Log today\'s spending?',
        'Tap to add an expense or gain',
        scheduled,
        _details(_channelActivity, 'Finance Reminders'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '/finance?tab=expenses',
      );
    } catch (e) {
      debugPrint('scheduleFinanceDailyReminder error: $e');
    }
  }

  static Future<void> cancelFinanceDailyReminder() async {
    try {
      await _plugin.cancel(9);
    } catch (_) {}
  }

  static Future<void> showBackupReminder({
    required int daysSinceLastExport,
    bool neverExported = false,
  }) async {
    if (!_initialized) return;
    try {
      final body = neverExported
          ? 'You have not exported a backup yet — tap to open Settings'
          : 'Last export was $daysSinceLastExport days ago — tap to open Settings';
      await _plugin.show(
        8,
        'Export JSON backup',
        body,
        _details(_channelActivity, 'Backup Reminders', importance: Importance.high),
        payload: '/settings',
      );
    } catch (e) {
      debugPrint('showBackupReminder error: $e');
    }
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
        payload: '/transactions',
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

  static Future<bool> requestAndroidPermission() async {
    if (!_initialized) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      return await android.requestNotificationsPermission() ?? true;
    } catch (e) {
      debugPrint('requestAndroidPermission error: $e');
      return false;
    }
  }

  static Future<void> showDebtRoulette({
    required String clientName,
    required int balanceMinor,
    required String currencyCode,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        7,
        'Debt roulette',
        '$clientName owes ${MoneyFormat.formatMinor(balanceMinor, currencyCode)}',
        _details(_channelOverdue, 'Debt Roulette', importance: Importance.high),
        payload: '/home',
      );
    } catch (e) {
      debugPrint('showDebtRoulette error: $e');
    }
  }

  static Future<void> showSubscriptionDueReminder({
    required int dueCount,
    required int overdueCount,
    String? nextTitle,
  }) async {
    if (!_initialized || dueCount == 0) return;
    try {
      final body = overdueCount > 0
          ? '$overdueCount overdue · ${dueCount - overdueCount} due soon'
          : nextTitle != null
              ? 'Next: $nextTitle'
              : '$dueCount subscription${dueCount == 1 ? '' : 's'} due soon';
      await _plugin.show(
        9,
        'Subscriptions due',
        body,
        _details(_channelActivity, 'Subscription Reminders', importance: Importance.high),
        payload: '/finance?tab=wishlist',
      );
    } catch (e) {
      debugPrint('showSubscriptionDueReminder error: $e');
    }
  }

  // ── Subscription warning (per-subscription, scheduled) ────────────────

  /// Schedules a warning notification [warnBeforeDays] days before [dueAt].
  /// Uses notification id derived from a hash of the subscription id so that
  /// re-scheduling the same subscription replaces the old notification.
  static Future<void> scheduleSubscriptionWarning({
    required String subscriptionId,
    required DateTime dueAt,
    required int warnBeforeDays,
    required String title,
    required int amountMinor,
    required String currencyCode,
  }) async {
    if (!_initialized || warnBeforeDays <= 0) return;
    try {
      final notifId = _subWarningId(subscriptionId);
      await _plugin.cancel(notifId);
      final warnAt = dueAt.subtract(Duration(days: warnBeforeDays));
      final now = DateTime.now();
      if (warnAt.isBefore(now)) return; // window already passed
      final scheduled = tz.TZDateTime.from(warnAt, tz.local);
      final body =
          '${MoneyFormat.formatMinor(amountMinor, currencyCode)} due in $warnBeforeDays day${warnBeforeDays == 1 ? '' : 's'}';
      await _plugin.zonedSchedule(
        notifId,
        'Subscription due: $title',
        body,
        scheduled,
        _details(_channelActivity, 'Subscription Reminders',
            importance: Importance.high),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '/finance?tab=wishlist',
      );
    } catch (e) {
      debugPrint('scheduleSubscriptionWarning error: $e');
    }
  }

  static Future<void> cancelSubscriptionWarning(String subscriptionId) async {
    try {
      await _plugin.cancel(_subWarningId(subscriptionId));
    } catch (_) {}
  }

  /// Stable int id derived from subscription UUID (keeps id < 2^31).
  static int _subWarningId(String subscriptionId) {
    final bytes = subscriptionId.codeUnits;
    var h = 0x811c9dc5;
    for (final b in bytes) {
      h ^= b;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return 10000 + (h % 90000); // range 10000–99999
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

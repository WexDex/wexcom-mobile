/// Subscription billing schedule helpers.

enum SubscriptionScheduleType {
  dayOfMonth('day_of_month'),
  rollingDays('rolling_days');

  const SubscriptionScheduleType(this.storageKey);
  final String storageKey;

  static SubscriptionScheduleType fromStorage(String? key) {
    return SubscriptionScheduleType.values.firstWhere(
      (e) => e.storageKey == key,
      orElse: () => SubscriptionScheduleType.rollingDays,
    );
  }
}

int clampDayOfMonth(int year, int month, int day) {
  final last = DateTime(year, month + 1, 0).day;
  return day.clamp(1, last);
}

DateTime initialNextDue({
  required SubscriptionScheduleType type,
  int? billingDayOfMonth,
  int? rollingDays,
  DateTime? from,
}) {
  final base = (from ?? DateTime.now()).toLocal();
  switch (type) {
    case SubscriptionScheduleType.dayOfMonth:
      final dom = billingDayOfMonth ?? base.day;
      var year = base.year;
      var month = base.month;
      var day = clampDayOfMonth(year, month, dom);
      var candidate = DateTime(year, month, day, 23, 59);
      if (!candidate.isAfter(base)) {
        month += 1;
        if (month > 12) {
          month = 1;
          year += 1;
        }
        day = clampDayOfMonth(year, month, dom);
        candidate = DateTime(year, month, day, 23, 59);
      }
      return candidate;
    case SubscriptionScheduleType.rollingDays:
      final days = rollingDays ?? 30;
      return base.add(Duration(days: days));
  }
}

DateTime computeNextDueAfterLog({
  required SubscriptionScheduleType type,
  int? billingDayOfMonth,
  int? rollingDays,
  required DateTime loggedAt,
}) {
  final local = loggedAt.toLocal();
  switch (type) {
    case SubscriptionScheduleType.dayOfMonth:
      final dom = billingDayOfMonth ?? local.day;
      var year = local.year;
      var month = local.month + 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
      final day = clampDayOfMonth(year, month, dom);
      return DateTime(year, month, day, 23, 59);
    case SubscriptionScheduleType.rollingDays:
      final days = rollingDays ?? 30;
      return local.add(Duration(days: days));
  }
}

({int days, bool overdue}) daysUntilDue(DateTime nextDueAt) {
  final now = DateTime.now();
  final due = nextDueAt.toLocal();
  final diff = due.difference(DateTime(now.year, now.month, now.day)).inDays;
  if (diff < 0) return (days: diff.abs(), overdue: true);
  return (days: diff, overdue: false);
}

String formatDueLabel(DateTime nextDueAt) {
  final d = daysUntilDue(nextDueAt);
  if (d.overdue) {
    return d.days == 0 ? 'Due today' : 'Overdue ${d.days}d';
  }
  if (d.days == 0) return 'Due today';
  if (d.days == 1) return 'Due tomorrow';
  return 'Due in ${d.days}d';
}

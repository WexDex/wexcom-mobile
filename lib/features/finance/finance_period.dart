import 'package:intl/intl.dart';

enum FinancePeriod { last7Days, thisWeek, lastWeek, thisMonth, lastMonth, custom }

/// Inclusive (start, end) date-range for [FinancePeriod].
({DateTime start, DateTime end}) financePeriodRange(
  FinancePeriod period, {
  DateTime? customStart,
  DateTime? customEnd,
  DateTime? trackingStartAt,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final ({DateTime start, DateTime end}) raw = switch (period) {
    FinancePeriod.last7Days => (
        start: today.subtract(const Duration(days: 6)),
        end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      ),
    FinancePeriod.thisWeek => (
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      ),
    FinancePeriod.lastWeek => () {
        final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
        final lastWeekEnd = thisWeekStart.subtract(const Duration(seconds: 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        return (start: lastWeekStart, end: lastWeekEnd);
      }(),
    FinancePeriod.thisMonth => (
        start: DateTime(now.year, now.month, 1),
        end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      ),
    FinancePeriod.lastMonth => () {
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd =
            DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
        return (start: lastMonth, end: lastMonthEnd);
      }(),
    FinancePeriod.custom => () {
        final s = customStart ?? DateTime(now.year, now.month, 1);
        final e = customEnd ??
            today.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        return (start: s, end: e.isAfter(s) ? e : s);
      }(),
  };

  if (trackingStartAt == null) return raw;
  final trackLocal = DateTime(
    trackingStartAt.toLocal().year,
    trackingStartAt.toLocal().month,
    trackingStartAt.toLocal().day,
  );
  if (raw.end.isBefore(trackLocal)) {
    return (start: raw.start, end: raw.start);
  }
  final effectiveStart = raw.start.isBefore(trackLocal) ? trackLocal : raw.start;
  return (start: effectiveStart, end: raw.end);
}

String financePeriodLabel(
  FinancePeriod period, {
  DateTime? customStart,
  DateTime? customEnd,
}) {
  return switch (period) {
    FinancePeriod.last7Days => 'Last 7 days',
    FinancePeriod.thisWeek => 'This week',
    FinancePeriod.lastWeek => 'Last week',
    FinancePeriod.thisMonth => 'This month',
    FinancePeriod.lastMonth => 'Last month',
    FinancePeriod.custom => customStart != null && customEnd != null
        ? '${DateFormat.MMMd().format(customStart)}–${DateFormat.MMMd().format(customEnd)}'
        : 'Custom',
  };
}

bool dateInFinanceRange(DateTime createdAt, DateTime start, DateTime end) {
  final local = createdAt.toLocal();
  return !local.isBefore(start) && !local.isAfter(end);
}

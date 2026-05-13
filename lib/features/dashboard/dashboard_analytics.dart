import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top clients by balance
// ─────────────────────────────────────────────────────────────────────────────

class TopClientBalancePoint {
  const TopClientBalancePoint({
    required this.clientName,
    required this.balanceMinor,
    required this.initials,
  });

  final String clientName;
  final int balanceMinor;
  final String initials;
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  final w = parts[0];
  return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
}

/// Returns top [limit] clients sorted by absolute balance (highest first).
/// Only includes clients with a non-zero balance.
List<TopClientBalancePoint> buildTopClientsByBalance(
  List<Client> clients, {
  int limit = 5,
}) {
  final nonZero = clients
      .where((c) => c.balanceMinor != 0)
      .toList()
    ..sort((a, b) => b.balanceMinor.abs().compareTo(a.balanceMinor.abs()));
  return nonZero.take(limit).map((c) {
    return TopClientBalancePoint(
      clientName: c.fullName,
      balanceMinor: c.balanceMinor,
      initials: _initials(c.fullName),
    );
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly net flow (last 12 months)
// ─────────────────────────────────────────────────────────────────────────────

class MonthlyNetFlowPoint {
  const MonthlyNetFlowPoint({
    required this.monthLabel,
    required this.year,
    required this.month,
    required this.debtMinor,
    required this.paymentMinor,
  });

  final String monthLabel;
  final int year;
  final int month;
  final int debtMinor;
  final int paymentMinor;

  int get netMinor => paymentMinor - debtMinor;
}

List<MonthlyNetFlowPoint> buildMonthlyNetFlow(
  List<LedgerTransactionWithClient> rows, {
  int monthCount = 12,
}) {
  final now = DateTime.now();
  final months = <DateTime>[];
  for (var i = monthCount - 1; i >= 0; i--) {
    var m = now.month - i;
    var y = now.year;
    while (m <= 0) {
      m += 12;
      y -= 1;
    }
    months.add(DateTime(y, m));
  }

  final debtByMonth = {for (final m in months) m: 0};
  final payByMonth = {for (final m in months) m: 0};

  for (final row in rows) {
    final tx = row.transaction;
    if (LedgerTxStatus.fromInt(tx.txStatus) != LedgerTxStatus.active) continue;
    final key = DateTime(tx.createdAt.year, tx.createdAt.month);
    if (!debtByMonth.containsKey(key)) continue;
    if (LedgerTxType.fromInt(tx.txType) == LedgerTxType.debt) {
      debtByMonth[key] = (debtByMonth[key] ?? 0) + tx.amountMinor;
    } else {
      payByMonth[key] = (payByMonth[key] ?? 0) + tx.amountMinor;
    }
  }

  return months.map((m) {
    return MonthlyNetFlowPoint(
      monthLabel: DateFormat.MMM().format(m),
      year: m.year,
      month: m.month,
      debtMinor: debtByMonth[m] ?? 0,
      paymentMinor: payByMonth[m] ?? 0,
    );
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Debt age distribution (open debts bucketed by age in days)
// ─────────────────────────────────────────────────────────────────────────────

class DebtAgeBucket {
  const DebtAgeBucket({
    required this.d0to7,
    required this.d7to30,
    required this.d30to90,
    required this.d90plus,
  });

  final int d0to7;
  final int d7to30;
  final int d30to90;
  final int d90plus;

  int get total => d0to7 + d7to30 + d30to90 + d90plus;
  bool get isEmpty => total == 0;
}

DebtAgeBucket buildDebtAgeBuckets(List<LedgerTransactionWithClient> rows) {
  final now = DateTime.now();
  var b0 = 0, b7 = 0, b30 = 0, b90 = 0;
  for (final row in rows) {
    final tx = row.transaction;
    if (LedgerTxStatus.fromInt(tx.txStatus) != LedgerTxStatus.active) continue;
    if (LedgerTxType.fromInt(tx.txType) != LedgerTxType.debt) continue;
    final age = now.difference(tx.createdAt).inDays;
    if (age <= 7) {
      b0++;
    } else if (age <= 30) {
      b7++;
    } else if (age <= 90) {
      b30++;
    } else {
      b90++;
    }
  }
  return DebtAgeBucket(d0to7: b0, d7to30: b7, d30to90: b30, d90plus: b90);
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment heatmap (day-of-week frequency)
// ─────────────────────────────────────────────────────────────────────────────

class PaymentHeatmapCell {
  const PaymentHeatmapCell({
    required this.dayOfWeek,
    required this.dayLabel,
    required this.count,
  });

  final int dayOfWeek; // 1=Mon … 7=Sun (DateTime.weekday)
  final String dayLabel;
  final int count;
}

List<PaymentHeatmapCell> buildPaymentHeatmap(List<LedgerTransactionWithClient> rows) {
  final counts = {for (var i = 1; i <= 7; i++) i: 0};
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  for (final row in rows) {
    final tx = row.transaction;
    if (LedgerTxStatus.fromInt(tx.txStatus) != LedgerTxStatus.active) continue;
    if (LedgerTxType.fromInt(tx.txType) != LedgerTxType.payment) continue;
    final dow = tx.createdAt.weekday; // 1-7
    counts[dow] = (counts[dow] ?? 0) + 1;
  }
  return List.generate(7, (i) {
    final dow = i + 1;
    return PaymentHeatmapCell(
      dayOfWeek: dow,
      dayLabel: labels[i],
      count: counts[dow] ?? 0,
    );
  });
}

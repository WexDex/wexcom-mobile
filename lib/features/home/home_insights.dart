import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../utils/subscription_schedule.dart';

class OverdueClient {
  const OverdueClient({required this.client, required this.ageDays});
  final Client client;
  final int ageDays;
}

/// Clients who still owe you and whose oldest active debt is ≥ [overdueDays] old
/// (same rule as `LedgerRepository.hasOverdueDebt`).
List<OverdueClient> overdueClients(
  List<Client> clients,
  List<LedgerTransactionWithClient> rows,
  int overdueDays,
) {
  final oldestDebt = <String, DateTime>{};
  for (final r in rows) {
    final tx = r.transaction;
    if (tx.txStatus != LedgerTxStatus.active.index) continue;
    if (tx.txType != LedgerTxType.debt.index) continue;
    final prev = oldestDebt[tx.clientId];
    if (prev == null || tx.createdAt.isBefore(prev)) oldestDebt[tx.clientId] = tx.createdAt;
  }
  final now = DateTime.now().toUtc();
  final result = <OverdueClient>[];
  for (final c in clients) {
    if (c.balanceMinor <= 0) continue;
    final oldest = oldestDebt[c.id];
    if (oldest == null) continue;
    final age = now.difference(oldest.toUtc()).inDays;
    if (age >= overdueDays) result.add(OverdueClient(client: c, ageDays: age));
  }
  result.sort((a, b) => b.ageDays.compareTo(a.ageDays));
  return result;
}

class UpcomingBill {
  const UpcomingBill({required this.subscription, required this.due});
  final SubscriptionItem subscription;
  final DateTime due;

  bool get overdue {
    final now = DateTime.now();
    return due.isBefore(DateTime(now.year, now.month, now.day));
  }
}

/// Projected subscription charges from today through [days] ahead, plus any
/// that are already overdue. Recurrences are expanded from each schedule.
List<UpcomingBill> upcomingBills(List<SubscriptionItem> subs, {int days = 30}) {
  final now = DateTime.now();
  final horizon = DateTime(now.year, now.month, now.day).add(Duration(days: days + 1));
  final bills = <UpcomingBill>[];
  for (final s in subs) {
    if (!s.isActive) continue;
    final type = SubscriptionScheduleType.fromStorage(s.scheduleType);
    var due = s.nextDueAt.toLocal();
    var guard = 0;
    while (due.isBefore(horizon) && guard++ < 62) {
      bills.add(UpcomingBill(subscription: s, due: due));
      due = computeNextDueAfterLog(
        type: type,
        billingDayOfMonth: s.billingDayOfMonth,
        rollingDays: s.rollingDays,
        loggedAt: due,
      );
    }
  }
  bills.sort((a, b) => a.due.compareTo(b.due));
  return bills;
}

DateTime budgetWindowStart(ExpenseCategory cat) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return switch (cat.budgetPeriod) {
    'week' => today.subtract(Duration(days: now.weekday - 1)),
    'custom' => today.subtract(Duration(days: (cat.budgetCustomDays ?? 30) - 1)),
    _ => DateTime(now.year, now.month, 1),
  };
}

class BudgetAlert {
  const BudgetAlert({required this.category, required this.spentMinor, required this.budgetMinor});
  final ExpenseCategory category;
  final int spentMinor;
  final int budgetMinor;

  double get ratio => budgetMinor == 0 ? 0 : spentMinor / budgetMinor;
  bool get over => spentMinor >= budgetMinor;
}

/// Categories whose spend in their budget window is ≥ [threshold] of the budget.
List<BudgetAlert> budgetAlerts(
  List<ExpenseCategory> categories,
  List<PersonalFinanceEntry> expenses, {
  double threshold = 0.9,
}) {
  final alerts = <BudgetAlert>[];
  for (final cat in categories) {
    final budget = cat.budgetMinorPerMonth;
    if (budget == null || budget <= 0) continue;
    final start = budgetWindowStart(cat);
    var spent = 0;
    for (final e in expenses) {
      if (e.categoryId == cat.id && !e.createdAt.toLocal().isBefore(start)) {
        spent += e.amountMinor;
      }
    }
    final alert = BudgetAlert(category: cat, spentMinor: spent, budgetMinor: budget);
    if (alert.ratio >= threshold) alerts.add(alert);
  }
  alerts.sort((a, b) => b.ratio.compareTo(a.ratio));
  return alerts;
}

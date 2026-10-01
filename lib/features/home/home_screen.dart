import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../utils/balance_display.dart';
import '../../widgets/hud_empty_state.dart';
import '../finance/finance_period.dart';
import '../finance/finance_summary.dart';
import 'home_insights.dart';
import 'home_sections.dart';

/// Cashflow dashboard: what clients owe, what you spent/earned, what is coming.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(activeClientsProvider);
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final accounts = ref.watch(walletAccountsProvider).valueOrNull ?? const [];
    final walletLedger = ref.watch(allWalletLedgerProvider).valueOrNull ?? const [];
    final netWorth = ref.watch(netWorthProvider).valueOrNull;
    final txRows = ref.watch(allTransactionsProvider(null)).valueOrNull ?? const [];
    final expenses =
        ref.watch(personalFinanceEntriesProvider(PersonalFinanceKind.expense)).valueOrNull ?? const [];
    final gains =
        ref.watch(personalFinanceEntriesProvider(PersonalFinanceKind.gain)).valueOrNull ?? const [];
    // Also keeps these alive for the add-entry editor, which reads them once.
    final expenseCats = ref.watch(expenseCategoriesProvider('expense')).valueOrNull ?? const [];
    final gainCats = ref.watch(expenseCategoriesProvider('gain')).valueOrNull ?? const [];
    final subs = ref.watch(subscriptionsProvider).valueOrNull ?? const [];
    final goals = ref.watch(savingsGoalsProvider).valueOrNull ?? const [];
    final overdueDays = ref.watch(overdueAlertDaysProvider).valueOrNull ?? 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Analytics',
            onPressed: () => context.push('/analytics'),
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HudEmptyState(
          icon: Icons.error_outline,
          message: 'Could not load data',
          subtitle: e.toString(),
        ),
        data: (clients) {
          final month = financePeriodRange(
            FinancePeriod.thisMonth,
            trackingStartAt: settings?.financeTrackingStartAt,
          );
          final pulse = spendingPulse(expenses);
          final bills = upcomingBills(subs);
          final budgets = budgetAlerts(expenseCats, expenses, threshold: 0);
          final soonLimit = DateTime.now().add(const Duration(days: 3));
          final walletReady =
              walletLedger.isNotEmpty || accounts.any((a) => a.balanceMinor != 0);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeClientsProvider);
              ref.invalidate(walletAccountsProvider);
              ref.invalidate(allWalletLedgerProvider);
              ref.invalidate(netWorthProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                OnboardingChecklist(
                  walletReady: walletReady,
                  hasExpense: expenses.isNotEmpty,
                  hasClient: clients.isNotEmpty,
                ),
                AttentionStrip(
                  overdue: overdueClients(clients, txRows, overdueDays),
                  billsSoon: bills.where((b) => b.due.isBefore(soonLimit)).toList(),
                  budgets: budgets.where((b) => b.ratio >= 0.9).toList(),
                  code: code,
                  overdueDays: overdueDays,
                ),
                ClientBalancesCard(totals: ClientBalanceTotals.fromClients(clients), code: code),
                const QuickAddRow(),
                ThisMonthCard(
                  expenseMinor: sumEntriesInRange(expenses, month.start, month.end),
                  gainMinor: sumEntriesInRange(gains, month.start, month.end),
                  expenseCategories: categoryTotals(expenses, expenseCats, month.start, month.end),
                  gainCategories: categoryTotals(gains, gainCats, month.start, month.end),
                  code: code,
                ),
                SpendingPulseCard(rolling: pulse.rolling, lastWeek: pulse.lastWeek, code: code),
                WalletHubCard(
                  accounts: accounts,
                  ledger: walletLedger,
                  netWorth: netWorth,
                  code: code,
                ),
                UpcomingBillsCard(bills: bills, code: code),
                BudgetsCard(budgets: budgets, code: code),
                GoalsSnippetCard(goals: goals, code: code),
                RecentClientsCard(rows: txRows),
                RecentFinanceCard(expenses: expenses, gains: gains),
              ],
            ),
          );
        },
      ),
    );
  }
}

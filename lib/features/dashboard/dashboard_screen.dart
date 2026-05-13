import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/hud_empty_state.dart';
import '../../widgets/hud_stat_card.dart';
import '../../widgets/skeleton_loaders.dart';
import 'dashboard_analytics.dart';
import 'dashboard_charts.dart';
import 'new_chart_painters.dart';

String _formatChartDay(DateTime day) => DateFormat.yMMMd().format(day.toLocal());

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _rangeEnd;
  late DateTime _rangeStart;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _rangeEnd = today;
    _rangeStart = today.subtract(const Duration(days: 6));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setQuickDays(int n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _rangeEnd = today;
      _rangeStart = today.subtract(Duration(days: n - 1));
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _rangeEnd = today;
      _rangeStart = DateTime(now.year, now.month, 1);
    });
  }

  void _shiftRange(int deltaDays) {
    setState(() {
      _rangeStart = _rangeStart.add(Duration(days: deltaDays));
      _rangeEnd = _rangeEnd.add(Duration(days: deltaDays));
    });
  }

  Future<void> _pickRangeEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rangeEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeEnd = DateTime(picked.year, picked.month, picked.day);
      if (_rangeStart.isAfter(_rangeEnd)) {
        _rangeStart = _rangeEnd;
      }
    });
  }

  Future<void> _pickRangeStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rangeStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeStart = DateTime(picked.year, picked.month, picked.day);
      if (_rangeEnd.isBefore(_rangeStart)) {
        _rangeEnd = _rangeStart;
      }
    });
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _rangeStart, end: _rangeEnd),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeStart = DateTime(picked.start.year, picked.start.month, picked.start.day);
      _rangeEnd = DateTime(picked.end.year, picked.end.month, picked.end.day);
    });
  }

  int _sumInRange(List<PersonalFinanceEntry> entries) {
    return entries
        .where((e) {
          final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
          return !d.isBefore(_rangeStart) && !d.isAfter(_rangeEnd);
        })
        .fold<int>(0, (a, e) => a + e.amountMinor);
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(allTransactionsProvider(null));
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final expenseAsync = ref.watch(personalFinanceEntriesProvider(PersonalFinanceKind.expense));
    final gainAsync = ref.watch(personalFinanceEntriesProvider(PersonalFinanceKind.gain));
    final clientsAsync = ref.watch(activeClientsProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';

    final expList = expenseAsync.valueOrNull ?? const [];
    final gainList = gainAsync.valueOrNull ?? const [];

    final rangeLabel =
        '${DateFormat.MMMd().format(_rangeStart.toLocal())} – ${DateFormat.MMMd().format(_rangeEnd.toLocal())}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandPrimary,
          labelColor: AppTheme.brandPrimary,
          unselectedLabelColor: AppTheme.mutedFg,
          tabs: const [
            Tab(text: 'Debt & Payments'),
            Tab(text: 'Expenses & Gains'),
            Tab(text: 'Combined'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Open Finance',
            onPressed: () => context.go('/finance'),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            color: AppTheme.personalGain,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppTheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chart range: $rangeLabel', style: TextStyle(color: AppTheme.mutedFg, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('7d'),
                        selected: false,
                        onSelected: (_) => _setQuickDays(7),
                      ),
                      ChoiceChip(
                        label: const Text('14d'),
                        selected: false,
                        onSelected: (_) => _setQuickDays(14),
                      ),
                      ChoiceChip(
                        label: const Text('30d'),
                        selected: false,
                        onSelected: (_) => _setQuickDays(30),
                      ),
                      ChoiceChip(
                        label: const Text('This month'),
                        selected: false,
                        onSelected: (_) => _setThisMonth(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.date_range_outlined, size: 18),
                        label: const Text('Custom range'),
                        onPressed: _pickCustomRange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickRangeStart,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          label: Text('From ${_formatChartDay(_rangeStart)}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickRangeEnd,
                          icon: const Icon(Icons.event_rounded, size: 18),
                          label: Text('To ${_formatChartDay(_rangeEnd)}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Shift earlier',
                        onPressed: () => _shiftRange(-7),
                        icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                        color: AppTheme.brandPrimary,
                      ),
                      IconButton(
                        tooltip: 'Shift later',
                        onPressed: () => _shiftRange(7),
                        icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                        color: AppTheme.brandPrimary,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _setQuickDays(7),
                        child: const Text('Reset to last 7d'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                txAsync.when(
                  data: (rows) => _DebtPaymentsTab(
                    rows: rows,
                    code: code,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                  ),
                  loading: () => ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [StatCardSkeleton(), SizedBox(height: 16), ChartSkeleton(), SizedBox(height: 16), ChartSkeleton()],
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                _ExpensesGainsTab(
                  expenseAsync: expenseAsync,
                  gainAsync: gainAsync,
                  code: code,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  rangeSumExpense: _sumInRange(expList),
                  rangeSumGain: _sumInRange(gainList),
                ),
                txAsync.when(
                  data: (rows) => _CombinedDashboardTab(
                    rows: rows,
                    expenseAsync: expenseAsync,
                    gainAsync: gainAsync,
                    code: code,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                  ),
                  loading: () => ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [ChartSkeleton()],
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                txAsync.when(
                  data: (rows) => _AnalyticsTab(
                    rows: rows,
                    clients: clientsAsync.valueOrNull ?? const [],
                    code: code,
                  ),
                  loading: () => ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      ChartSkeleton(),
                      SizedBox(height: 16),
                      ChartSkeleton(),
                    ],
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CombinedDashboardTab extends StatelessWidget {
  const _CombinedDashboardTab({
    required this.rows,
    required this.expenseAsync,
    required this.gainAsync,
    required this.code,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<LedgerTransactionWithClient> rows;
  final AsyncValue<List<PersonalFinanceEntry>> expenseAsync;
  final AsyncValue<List<PersonalFinanceEntry>> gainAsync;
  final String code;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  Widget build(BuildContext context) {
    return expenseAsync.when(
      data: (expenses) {
        return gainAsync.when(
          data: (gains) {
            final merged = buildLedgerPersonalDailyPointsForRange(
              rows,
              expenses,
              gains,
              rangeStart,
              rangeEnd,
            );
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Ledger amounts and personal finance use your default currency for this chart. '
                  'Hover or drag for the four daily totals.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedFg),
                ),
                const SizedBox(height: 16),
                if (merged.isEmpty)
                  const HudEmptyState(
                    icon: Icons.show_chart_rounded,
                    message: 'No data in range',
                    subtitle: 'Adjust the date range to see combined activity.',
                  )
                else
                  ChartCard(
                    title: 'Debt, payments, expenses, and gains',
                    subtitle: 'One scale; filter which lines to show',
                    child: CombinedLedgerPersonalLineChart(
                      points: merged,
                      interactiveCurrencyCode: code,
                      detailBuilder: (i, c) {
                        final p = merged[i];
                        return '${_formatChartDay(p.day)}\n'
                            'Debt: ${MoneyFormat.formatMinor(p.debt, c)}\n'
                            'Payment: ${MoneyFormat.formatMinor(p.payment, c)}\n'
                            'Expense: ${MoneyFormat.formatMinor(p.expense, c)}\n'
                            'Gain: ${MoneyFormat.formatMinor(p.gain, c)}';
                      },
                    ),
                  ),
              ],
            );
          },
          loading: () => ListView(padding: const EdgeInsets.all(16), children: const [ChartSkeleton()]),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({
    required this.rows,
    required this.clients,
    required this.code,
  });

  final List<LedgerTransactionWithClient> rows;
  final List<Client> clients;
  final String code;

  @override
  Widget build(BuildContext context) {
    final topClients = buildTopClientsByBalance(clients);
    final monthlyFlow = buildMonthlyNetFlow(rows);
    final heatmap = buildPaymentHeatmap(rows);
    final ageBucket = buildDebtAgeBuckets(rows);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        if (topClients.isNotEmpty) ...[
          ChartCard(
            title: 'Top clients by balance',
            subtitle: 'Highest absolute balances — cyan = they owe you, red = you owe them',
            accentColor: AppTheme.balanceReceivable,
            child: TopClientsBarChart(points: topClients, currencyCode: code),
          ),
          const SizedBox(height: 20),
        ],
        ChartCard(
          title: 'Monthly debt vs payments',
          subtitle: 'Last 12 months — left bar: debt, right bar: payments',
          accentColor: AppTheme.ledgerPayment,
          child: MonthlyNetFlowChart(points: monthlyFlow, currencyCode: code),
        ),
        const SizedBox(height: 20),
        ChartCard(
          title: 'Payment day of week',
          subtitle: 'Which days clients pay most often',
          accentColor: AppTheme.ledgerPayment,
          child: SizedBox(
            height: 100,
            child: PaymentHeatmapChart(cells: heatmap),
          ),
        ),
        if (!ageBucket.isEmpty) ...[
          const SizedBox(height: 20),
          ChartCard(
            title: 'Open debt age',
            subtitle: 'How old your active debts are',
            accentColor: AppTheme.ledgerDebt,
            child: DebtAgeChart(bucket: ageBucket),
          ),
        ],
      ],
    );
  }
}

class _DebtPaymentsTab extends StatelessWidget {
  const _DebtPaymentsTab({
    required this.rows,
    required this.code,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<LedgerTransactionWithClient> rows;
  final String code;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  Widget build(BuildContext context) {
    var totalOwedToYou = 0;
    var totalYouOwe = 0;
    for (final row in rows) {
      if (LedgerTxStatus.fromInt(row.transaction.txStatus) != LedgerTxStatus.active) {
        continue;
      }
      final type = LedgerTxType.fromInt(row.transaction.txType);
      if (type == LedgerTxType.debt) {
        totalOwedToYou += row.transaction.amountMinor;
      } else {
        totalYouOwe += row.transaction.amountMinor;
      }
    }

    final daily = buildLedgerDailyPointsForRange(rows, rangeStart, rangeEnd);
    final cumulative = toCumulativeLedger(daily);
    final currentBal = buildCurrentBalancePointsForRange(rows, rangeStart, rangeEnd);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: HudStatCard(
                label: 'Owed to you',
                displayText: MoneyFormat.formatMinor(totalOwedToYou, code),
                numericValue: totalOwedToYou.toDouble(),
                color: AppTheme.balanceReceivable,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: HudStatCard(
                label: 'You owe',
                displayText: MoneyFormat.formatMinor(totalYouOwe, code),
                numericValue: totalYouOwe.toDouble(),
                color: AppTheme.ledgerDebt,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        HudStatCard(
          label: 'Net balance',
          displayText: MoneyFormat.formatMinor(totalOwedToYou - totalYouOwe, code),
          numericValue: (totalOwedToYou - totalYouOwe).toDouble(),
          color: AppTheme.receivableAccent,
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 20),
        if (daily.isEmpty)
          const HudEmptyState(
            icon: Icons.bar_chart_rounded,
            message: 'No data in range',
            subtitle: 'Adjust the date range to see ledger activity.',
          )
        else ...[
          ChartCard(
            title: 'Current balances (end of day)',
            subtitle:
                'Replay of active ledger: “they owe you” vs “you owe them” from client balances',
            child: CurrentBalanceLineChart(
              points: currentBal,
              interactiveCurrencyCode: code,
              detailBuilder: (i, c) {
                final p = currentBal[i];
                return '${_formatChartDay(p.day)}\n'
                    'They owe you: ${MoneyFormat.formatMinor(p.theyOweYouMinor, c)}\n'
                    'You owe them: ${MoneyFormat.formatMinor(p.youOweThemMinor, c)}';
              },
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Debt and payments per day',
            subtitle: 'Amounts posted on each day (active only)',
            child: DualAmountLineChart(
              points: daily,
              colorA: AppTheme.ledgerDebt,
              colorB: AppTheme.ledgerPayment,
              legendA: 'Debt',
              legendB: 'Payment',
              interactiveCurrencyCode: code,
              interactiveDetailLine: (i, c) {
                final p = daily[i];
                return '${_formatChartDay(p.day)}\n'
                    'Debt: ${MoneyFormat.formatMinor(p.debt, c)}\n'
                    'Payment: ${MoneyFormat.formatMinor(p.payment, c)}\n'
                    'Net: ${MoneyFormat.formatMinor(p.net, c)}\n'
                    'Counts: ${p.debtCount} debt · ${p.paymentCount} payment';
              },
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Running totals in range',
            subtitle: 'Cumulative debt and payments in this period',
            child: CumulativeAmountLineChart(
              points: cumulative,
              colorA: AppTheme.ledgerDebt,
              colorB: AppTheme.ledgerPayment,
              legendA: 'Cumulative debt',
              legendB: 'Cumulative payments',
              interactiveCurrencyCode: code,
              interactiveDetailLine: (i, c) {
                final p = cumulative[i];
                return '${_formatChartDay(p.day)}\n'
                    'Cumulative debt: ${MoneyFormat.formatMinor(p.cumDebt, c)}\n'
                    'Cumulative payments: ${MoneyFormat.formatMinor(p.cumPayment, c)}\n'
                    'Net: ${MoneyFormat.formatMinor(p.net, c)}';
              },
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Net flow per day',
            subtitle: 'Debt minus payments',
            child: NetAmountLineChart(
              points: daily,
              lineColor: AppTheme.receivableAccent,
              interactiveCurrencyCode: code,
              interactiveDetailLine: (i, c) {
                final p = daily[i];
                return '${_formatChartDay(p.day)}\n'
                    'Net: ${MoneyFormat.formatMinor(p.net, c)}';
              },
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Transaction counts',
            subtitle: 'Debt vs payment rows per day',
            child: CountLineChart(
              points: daily,
              colorA: AppTheme.ledgerDebt,
              colorB: AppTheme.ledgerPayment.withValues(alpha: 0.85),
              legendA: 'Debt count',
              legendB: 'Payment count',
              interactiveDetailLine: (i) {
                final p = daily[i];
                return '${_formatChartDay(p.day)}\n'
                    'Debt txs: ${p.debtCount}\n'
                    'Payment txs: ${p.paymentCount}';
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ExpensesGainsTab extends StatelessWidget {
  const _ExpensesGainsTab({
    required this.expenseAsync,
    required this.gainAsync,
    required this.code,
    required this.rangeStart,
    required this.rangeEnd,
    required this.rangeSumExpense,
    required this.rangeSumGain,
  });

  final AsyncValue<List<PersonalFinanceEntry>> expenseAsync;
  final AsyncValue<List<PersonalFinanceEntry>> gainAsync;
  final String code;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int rangeSumExpense;
  final int rangeSumGain;

  @override
  Widget build(BuildContext context) {
    return expenseAsync.when(
      data: (expenses) {
        return gainAsync.when(
          data: (gains) {
            final combined = buildPersonalCombinedDailyPointsForRange(
              expenses,
              gains,
              rangeStart,
              rangeEnd,
            );
            final cum = toCumulativePersonal(combined);
            final expTotal = expenses.fold<int>(0, (a, e) => a + e.amountMinor);
            final gainTotal = gains.fold<int>(0, (a, e) => a + e.amountMinor);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: HudStatCard(
                        label: 'All-time expenses',
                        displayText: MoneyFormat.formatMinor(expTotal, code),
                        numericValue: expTotal.toDouble(),
                        color: AppTheme.personalExpense,
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HudStatCard(
                        label: 'All-time gains',
                        displayText: MoneyFormat.formatMinor(gainTotal, code),
                        numericValue: gainTotal.toDouble(),
                        color: AppTheme.personalGain,
                        icon: Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                HudStatCard(
                  label: 'In selected range',
                  displayText:
                      '−${MoneyFormat.formatMinor(rangeSumExpense, code)} · +${MoneyFormat.formatMinor(rangeSumGain, code)}',
                  numericValue: (rangeSumGain - rangeSumExpense).toDouble(),
                  color: AppTheme.receivableAccent,
                  icon: Icons.date_range_outlined,
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  child: InkWell(
                    onTap: () => context.go('/finance'),
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: AppTheme.brandPrimary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Log or edit entries in Finance',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppTheme.mutedFg),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (combined.isEmpty)
                  const HudEmptyState(
                    icon: Icons.trending_up_rounded,
                    message: 'No data in range',
                    subtitle: 'Adjust the date range to see finance activity.',
                  )
                else ...[
                  ChartCard(
                    title: 'Expenses and gains per day',
                    subtitle: 'Same scale; hover for amounts',
                    child: DualPersonalAmountLineChart(
                      points: combined,
                      interactiveCurrencyCode: code,
                      detailBuilder: (i, c) {
                        final p = combined[i];
                        return '${_formatChartDay(p.day)}\n'
                            'Expenses: ${MoneyFormat.formatMinor(p.expense, c)} (${p.expenseCount} entries)\n'
                            'Gains: ${MoneyFormat.formatMinor(p.gain, c)} (${p.gainCount} entries)\n'
                            'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ChartCard(
                    title: 'Running totals in range',
                    subtitle: 'Cumulative expenses vs gains',
                    child: CumulativePersonalLineChart(
                      points: cum,
                      interactiveCurrencyCode: code,
                      detailBuilder: (i, c) {
                        final p = cum[i];
                        return '${_formatChartDay(p.day)}\n'
                            'Cumulative expenses: ${MoneyFormat.formatMinor(p.cumExpense, c)}\n'
                            'Cumulative gains: ${MoneyFormat.formatMinor(p.cumGain, c)}\n'
                            'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ChartCard(
                    title: 'Net per day (gains − expenses)',
                    subtitle: 'Above zero means more gains that day',
                    child: PersonalNetLineChart(
                      points: combined,
                      interactiveCurrencyCode: code,
                      detailBuilder: (i, c) {
                        final p = combined[i];
                        return '${_formatChartDay(p.day)}\n'
                            'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ChartCard(
                    title: 'Entry counts',
                    subtitle: 'How many expense vs gain rows per day',
                    child: PersonalCountLineChart(
                      points: combined,
                      detailBuilder: (i) {
                        final p = combined[i];
                        return '${_formatChartDay(p.day)}\n'
                            'Expense entries: ${p.expenseCount}\n'
                            'Gain entries: ${p.gainCount}';
                      },
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => ListView(padding: const EdgeInsets.all(16), children: const [ChartSkeleton()]),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}


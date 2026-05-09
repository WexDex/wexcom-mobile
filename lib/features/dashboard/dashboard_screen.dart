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
import 'dashboard_charts.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                  const Text(
                    'No days in selected range.',
                    style: TextStyle(color: AppTheme.mutedFg),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
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
              child: _StatCard(
                label: 'Total owed to you',
                value: MoneyFormat.formatMinor(totalOwedToYou, code),
                color: AppTheme.balanceReceivable,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Total you owe',
                value: MoneyFormat.formatMinor(totalYouOwe, code),
                color: AppTheme.ledgerDebt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatCard(
          label: 'Net balance',
          value: MoneyFormat.formatMinor(totalOwedToYou - totalYouOwe, code),
          color: AppTheme.receivableAccent,
        ),
        const SizedBox(height: 20),
        if (daily.isEmpty)
          const Text('No days in selected range.', style: TextStyle(color: AppTheme.mutedFg))
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
                      child: _StatCard(
                        label: 'All-time expenses',
                        value: MoneyFormat.formatMinor(expTotal, code),
                        color: AppTheme.personalExpense,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'All-time gains',
                        value: MoneyFormat.formatMinor(gainTotal, code),
                        color: AppTheme.personalGain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _StatCard(
                  label: 'In selected range',
                  value:
                      '−${MoneyFormat.formatMinor(rangeSumExpense, code)} · +${MoneyFormat.formatMinor(rangeSumGain, code)}',
                  color: AppTheme.receivableAccent,
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
                  const Text('No days in selected range.', style: TextStyle(color: AppTheme.mutedFg))
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.mutedFg)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

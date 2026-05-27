import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../dashboard/dashboard_analytics.dart';
import '../dashboard/dashboard_charts.dart';
import '../dashboard/new_chart_painters.dart';

String _fmtDay(DateTime d) => DateFormat.yMMMd().format(d.toLocal());

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Screen
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
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
    setState(() {
      _rangeEnd = DateTime(now.year, now.month, now.day);
      _rangeStart = DateTime(now.year, now.month, 1);
    });
  }

  void _shiftRange(int deltaDays) {
    setState(() {
      _rangeStart = _rangeStart.add(Duration(days: deltaDays));
      _rangeEnd = _rangeEnd.add(Duration(days: deltaDays));
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
        '${DateFormat.MMMd().format(_rangeStart.toLocal())} – '
        '${DateFormat.MMMd().format(_rangeEnd.toLocal())}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandPrimary,
          labelColor: AppTheme.brandPrimary,
          unselectedLabelColor: AppTheme.mutedFg,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Debt & Payments'),
            Tab(text: 'Expenses & Gains'),
            Tab(text: 'Combined'),
            Tab(text: 'Deep Analytics'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Date range controls ──────────────────────────────────────────
          Material(
            color: AppTheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Range: $rangeLabel',
                    style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _RangeChip(label: '7d', onTap: () => _setQuickDays(7)),
                      _RangeChip(label: '14d', onTap: () => _setQuickDays(14)),
                      _RangeChip(label: '30d', onTap: () => _setQuickDays(30)),
                      _RangeChip(label: 'This month', onTap: _setThisMonth),
                      ActionChip(
                        avatar: const Icon(Icons.date_range_outlined, size: 16),
                        label: const Text('Custom'),
                        visualDensity: VisualDensity.compact,
                        onPressed: _pickCustomRange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Shift 7 days earlier',
                        onPressed: () => _shiftRange(-7),
                        icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                        color: AppTheme.brandPrimary,
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        tooltip: 'Shift 7 days later',
                        onPressed: () => _shiftRange(7),
                        icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                        color: AppTheme.brandPrimary,
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _setQuickDays(7),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1 — Debt & Payments
                txAsync.when(
                  data: (rows) => _DebtPaymentsTab(
                    rows: rows,
                    code: code,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                  ),
                  loading: () => _loadingList(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                // Tab 2 — Expenses & Gains
                _ExpensesGainsTab(
                  expenseAsync: expenseAsync,
                  gainAsync: gainAsync,
                  code: code,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  rangeSumExpense: _sumInRange(expList),
                  rangeSumGain: _sumInRange(gainList),
                ),
                // Tab 3 — Combined
                txAsync.when(
                  data: (rows) => _CombinedTab(
                    rows: rows,
                    expenseAsync: expenseAsync,
                    gainAsync: gainAsync,
                    code: code,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                  ),
                  loading: () => _loadingList(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                // Tab 4 — Deep Analytics
                txAsync.when(
                  data: (rows) => _DeepAnalyticsTab(
                    rows: rows,
                    clients: clientsAsync.valueOrNull ?? const [],
                    code: code,
                  ),
                  loading: () => _loadingList(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingList() => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ChartSkeleton(),
          SizedBox(height: 16),
          ChartSkeleton(),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
      );
}

/// Highlighted section header card with emoji, title and description.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.description,
  });
  final String emoji;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedFg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Insight line displayed below a chart.
class _Insight extends StatelessWidget {
  const _Insight(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 14, color: Colors.amber.shade400),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.mutedFg,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Axis-labelled chart wrapper.
class _AxisLabelled extends StatelessWidget {
  const _AxisLabelled({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: AppTheme.mutedFg, fontSize: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -pi / 2,
              child: Text('Amount', style: labelStyle),
            ),
            const SizedBox(width: 4),
            Expanded(child: child),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text('Date', style: labelStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Debt & Payments
// ─────────────────────────────────────────────────────────────────────────────

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

    // Insight: best payment day
    String bestPayDay = '—';
    if (daily.isNotEmpty) {
      final best = daily.reduce((a, b) => a.payment > b.payment ? a : b);
      if (best.payment > 0) {
        bestPayDay = _fmtDay(best.day);
      }
    }
    final netPct = totalOwedToYou == 0
        ? 0
        : ((totalOwedToYou - totalYouOwe) * 100 / totalOwedToYou).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        const _SectionHeader(
          emoji: '💰',
          title: 'Debt & Payments',
          description:
              'Track money flowing in and out from your clients. '
              'Green = received; red = new debt.',
        ),
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
            subtitle: 'Replay of active ledger: "they owe you" vs "you owe them"',
            child: _AxisLabelled(
              child: CurrentBalanceLineChart(
                points: currentBal,
                interactiveCurrencyCode: code,
                detailBuilder: (i, c) {
                  final p = currentBal[i];
                  return '${_fmtDay(p.day)}\n'
                      'They owe you: ${MoneyFormat.formatMinor(p.theyOweYouMinor, c)}\n'
                      'You owe them: ${MoneyFormat.formatMinor(p.youOweThemMinor, c)}';
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Debt and payments per day',
            subtitle: 'Amounts posted on each day (active transactions only)',
            child: _AxisLabelled(
              child: DualAmountLineChart(
                points: daily,
                colorA: AppTheme.ledgerDebt,
                colorB: AppTheme.ledgerPayment,
                legendA: 'Debt',
                legendB: 'Payment',
                interactiveCurrencyCode: code,
                interactiveDetailLine: (i, c) {
                  final p = daily[i];
                  return '${_fmtDay(p.day)}\n'
                      'Debt: ${MoneyFormat.formatMinor(p.debt, c)}\n'
                      'Payment: ${MoneyFormat.formatMinor(p.payment, c)}\n'
                      'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
            ),
          ),
          _Insight('Best payment day this period: $bestPayDay'),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Running totals in range',
            subtitle: 'Cumulative debt and payments in this period',
            child: _AxisLabelled(
              child: CumulativeAmountLineChart(
                points: cumulative,
                colorA: AppTheme.ledgerDebt,
                colorB: AppTheme.ledgerPayment,
                legendA: 'Cumulative debt',
                legendB: 'Cumulative payments',
                interactiveCurrencyCode: code,
                interactiveDetailLine: (i, c) {
                  final p = cumulative[i];
                  return '${_fmtDay(p.day)}\n'
                      'Cumulative debt: ${MoneyFormat.formatMinor(p.cumDebt, c)}\n'
                      'Cumulative payments: ${MoneyFormat.formatMinor(p.cumPayment, c)}\n'
                      'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
            ),
          ),
          _Insight("You've collected $netPct% of all debt logged."),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Net flow per day',
            subtitle: 'Debt minus payments (positive = more debt that day)',
            child: _AxisLabelled(
              child: NetAmountLineChart(
                points: daily,
                lineColor: AppTheme.receivableAccent,
                interactiveCurrencyCode: code,
                interactiveDetailLine: (i, c) {
                  final p = daily[i];
                  return '${_fmtDay(p.day)}\nNet: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
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
                return '${_fmtDay(p.day)}\n'
                    'Debt: ${p.debtCount}  Payment: ${p.paymentCount}';
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Expenses & Gains
// ─────────────────────────────────────────────────────────────────────────────

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
      data: (expenses) => gainAsync.when(
        data: (gains) => _buildLoaded(context, expenses, gains),
        loading: () => _skeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<PersonalFinanceEntry> expenses,
    List<PersonalFinanceEntry> gains,
  ) {
    final combined = buildPersonalCombinedDailyPointsForRange(
      expenses, gains, rangeStart, rangeEnd,
    );
    final cum = toCumulativePersonal(combined);
    final expTotal = expenses.fold<int>(0, (a, e) => a + e.amountMinor);
    final gainTotal = gains.fold<int>(0, (a, e) => a + e.amountMinor);
    final netRange = rangeSumGain - rangeSumExpense;
    final insightText = netRange >= 0
        ? 'Net +${MoneyFormat.formatMinor(netRange, code)} in this period.'
        : 'You spent ${MoneyFormat.formatMinor(-netRange, code)} more than you earned.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        const _SectionHeader(
          emoji: '💸',
          title: 'Personal Finance',
          description:
              'Your own spending vs income — separate from client transactions.',
        ),
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
          displayText: '−${MoneyFormat.formatMinor(rangeSumExpense, code)}'
              ' · +${MoneyFormat.formatMinor(rangeSumGain, code)}',
          numericValue: netRange.toDouble(),
          color: AppTheme.receivableAccent,
          icon: Icons.date_range_outlined,
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
            subtitle: 'Same scale — hover for amounts',
            child: _AxisLabelled(
              child: DualPersonalAmountLineChart(
                points: combined,
                interactiveCurrencyCode: code,
                detailBuilder: (i, c) {
                  final p = combined[i];
                  return '${_fmtDay(p.day)}\n'
                      'Expenses: ${MoneyFormat.formatMinor(p.expense, c)} (${p.expenseCount})\n'
                      'Gains: ${MoneyFormat.formatMinor(p.gain, c)} (${p.gainCount})\n'
                      'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
            ),
          ),
          _Insight(insightText),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Running totals in range',
            subtitle: 'Cumulative expenses vs gains',
            child: _AxisLabelled(
              child: CumulativePersonalLineChart(
                points: cum,
                interactiveCurrencyCode: code,
                detailBuilder: (i, c) {
                  final p = cum[i];
                  return '${_fmtDay(p.day)}\n'
                      'Cum. expenses: ${MoneyFormat.formatMinor(p.cumExpense, c)}\n'
                      'Cum. gains: ${MoneyFormat.formatMinor(p.cumGain, c)}\n'
                      'Net: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Net per day (gains − expenses)',
            subtitle: 'Above zero = more gains that day',
            child: _AxisLabelled(
              child: PersonalNetLineChart(
                points: combined,
                interactiveCurrencyCode: code,
                detailBuilder: (i, c) {
                  final p = combined[i];
                  return '${_fmtDay(p.day)}\nNet: ${MoneyFormat.formatMinor(p.net, c)}';
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Entry counts per day',
            subtitle: 'How many expense vs gain rows per day',
            child: PersonalCountLineChart(
              points: combined,
              detailBuilder: (i) {
                final p = combined[i];
                return '${_fmtDay(p.day)}\n'
                    'Expenses: ${p.expenseCount}  Gains: ${p.gainCount}';
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _skeletonList() => ListView(
        padding: const EdgeInsets.all(16),
        children: const [ChartSkeleton(), SizedBox(height: 16), ChartSkeleton()],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Combined
// ─────────────────────────────────────────────────────────────────────────────

class _CombinedTab extends StatelessWidget {
  const _CombinedTab({
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
      data: (expenses) => gainAsync.when(
        data: (gains) => _buildLoaded(context, expenses, gains),
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [ChartSkeleton()],
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<PersonalFinanceEntry> expenses,
    List<PersonalFinanceEntry> gains,
  ) {
    final merged = buildLedgerPersonalDailyPointsForRange(
      rows, expenses, gains, rangeStart, rangeEnd,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        const _SectionHeader(
          emoji: '📊',
          title: 'Full Picture',
          description:
              'Client debt + payments + your expenses + gains on one timeline.',
        ),
        if (merged.isEmpty)
          const HudEmptyState(
            icon: Icons.show_chart_rounded,
            message: 'No data in range',
            subtitle: 'Adjust the date range to see combined activity.',
          )
        else ...[
          ChartCard(
            title: 'Debt, payments, expenses and gains',
            subtitle: 'One scale — drag to see four daily totals',
            child: _AxisLabelled(
              child: CombinedLedgerPersonalLineChart(
                points: merged,
                interactiveCurrencyCode: code,
                detailBuilder: (i, c) {
                  final p = merged[i];
                  return '${_fmtDay(p.day)}\n'
                      'Debt: ${MoneyFormat.formatMinor(p.debt, c)}\n'
                      'Payment: ${MoneyFormat.formatMinor(p.payment, c)}\n'
                      'Expense: ${MoneyFormat.formatMinor(p.expense, c)}\n'
                      'Gain: ${MoneyFormat.formatMinor(p.gain, c)}';
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          _CombinedLegend(),
        ],
      ],
    );
  }
}

class _CombinedLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.mutedFg);
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _LegendDot(color: AppTheme.ledgerDebt, label: 'Debt', style: style),
        _LegendDot(color: AppTheme.ledgerPayment, label: 'Payment', style: style),
        _LegendDot(color: AppTheme.personalExpense, label: 'Expense', style: style),
        _LegendDot(color: AppTheme.personalGain, label: 'Gain', style: style),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, this.style});
  final Color color;
  final String label;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: style),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 — Deep Analytics
// ─────────────────────────────────────────────────────────────────────────────

class _DeepAnalyticsTab extends StatelessWidget {
  const _DeepAnalyticsTab({
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

    // Insight strings
    final totalReceivable = clients
        .where((c) => c.balanceMinor > 0)
        .fold<int>(0, (s, c) => s + c.balanceMinor);
    String topClientsInsight = '';
    if (topClients.length >= 3 && totalReceivable > 0) {
      final top3 = topClients.take(3).fold<int>(0, (s, p) => s + p.balanceMinor.abs());
      final pct = (top3 * 100 / totalReceivable).round();
      topClientsInsight = 'Top 3 clients represent $pct% of total receivable.';
    }

    // Best month
    String bestMonthInsight = '';
    if (monthlyFlow.isNotEmpty) {
      final best = monthlyFlow.reduce((a, b) => a.paymentMinor > b.paymentMinor ? a : b);
      if (best.paymentMinor > 0) {
        bestMonthInsight =
            'Best month for payments: ${DateFormat.yMMM().format(DateTime(best.year, best.month))}.';
      }
    }

    // Best pay-day
    String heatmapInsight = '';
    if (heatmap.isNotEmpty) {
      final maxCell = heatmap.reduce((a, b) => a.count > b.count ? a : b);
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (maxCell.dayOfWeek >= 0 && maxCell.dayOfWeek < 7) {
        heatmapInsight = 'Clients pay most often on ${dayNames[maxCell.dayOfWeek]}.';
      }
    }

    // Old debt warning
    String ageInsight = '';
    if (!ageBucket.isEmpty) {
      final old = ageBucket.d90plus;
      if (old > 0) {
        ageInsight = '⚠️ $old debt${old == 1 ? '' : 's'} are over 90 days old.';
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        const _SectionHeader(
          emoji: '🔍',
          title: 'Patterns & Insights',
          description:
              'Who owes the most, when clients pay, and how old your open debts are.',
        ),
        if (topClients.isNotEmpty) ...[
          ChartCard(
            title: 'Top clients by balance',
            subtitle: 'Cyan = they owe you · Red = you owe them',
            accentColor: AppTheme.balanceReceivable,
            child: TopClientsBarChart(points: topClients, currencyCode: code),
          ),
          if (topClientsInsight.isNotEmpty) _Insight(topClientsInsight),
          const SizedBox(height: 20),
        ],
        ChartCard(
          title: 'Monthly debt vs payments',
          subtitle: 'Last 12 months — left bar: debt, right bar: payments',
          accentColor: AppTheme.ledgerPayment,
          child: MonthlyNetFlowChart(points: monthlyFlow, currencyCode: code),
        ),
        if (bestMonthInsight.isNotEmpty) _Insight(bestMonthInsight),
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
        if (heatmapInsight.isNotEmpty) _Insight(heatmapInsight),
        if (!ageBucket.isEmpty) ...[
          const SizedBox(height: 20),
          ChartCard(
            title: 'Open debt age',
            subtitle: 'How old your active debts are',
            accentColor: AppTheme.ledgerDebt,
            child: DebtAgeChart(bucket: ageBucket),
          ),
          if (ageInsight.isNotEmpty) _Insight(ageInsight),
        ],
      ],
    );
  }
}

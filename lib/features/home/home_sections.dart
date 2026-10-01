import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import '../finance/finance_summary.dart';
import '../finance/personal_finance_editor.dart';
import '../finance/wallet_balance_actions.dart';
import '../finance/wallet_history.dart';
import '../transactions/quick_client_transaction.dart';
import 'home_insights.dart';

/// Session-only dismissal of the onboarding checklist.
final onboardingHiddenProvider = StateProvider<bool>((_) => false);

String _fmt(int minor, String code) => MoneyFormat.formatMinor(minor, code);

String _relative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat.MMMd().format(dt.toLocal());
}

/// Rounded surface used by every Home block.
class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.accent,
    this.onTap,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final border = (accent ?? AppTheme.hudGrid).withValues(alpha: accent == null ? 0.6 : 0.35);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    if (actionLabel != null)
                      TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text('$actionLabel ›'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding checklist
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingChecklist extends ConsumerWidget {
  const OnboardingChecklist({
    super.key,
    required this.walletReady,
    required this.hasExpense,
    required this.hasClient,
  });

  final bool walletReady;
  final bool hasExpense;
  final bool hasClient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(onboardingHiddenProvider)) return const SizedBox.shrink();
    if (walletReady && hasExpense && hasClient) return const SizedBox.shrink();
    final done = [walletReady, hasExpense, hasClient].where((d) => d).length;

    Widget step(bool isDone, String label, VoidCallback onTap) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isDone ? AppTheme.balanceReceivable : AppTheme.mutedFg,
          ),
          title: Text(
            label,
            style: TextStyle(
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? AppTheme.mutedFg : null,
            ),
          ),
          trailing: isDone ? null : const Icon(Icons.chevron_right, size: 18),
          onTap: isDone ? null : onTap,
        );

    return HomeCard(
      title: 'Get started · $done/3',
      accent: AppTheme.brandPrimary,
      actionLabel: 'Hide',
      onAction: () => ref.read(onboardingHiddenProvider.notifier).state = true,
      child: Column(
        children: [
          step(walletReady, 'Set your wallet balance',
              () => openWalletBalanceAction(context, ref, op: WalletOp.set)),
          step(hasExpense, 'Log your first expense',
              () => addPersonalFinanceEntryFlow(context, ref, PersonalFinanceKind.expense)),
          step(hasClient, 'Add a client', () => context.go('/clients')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attention strip — overdue clients, bills due soon, budgets near limit
// ─────────────────────────────────────────────────────────────────────────────

class AttentionStrip extends StatelessWidget {
  const AttentionStrip({
    super.key,
    required this.overdue,
    required this.billsSoon,
    required this.budgets,
    required this.code,
    required this.overdueDays,
  });

  final List<OverdueClient> overdue;
  final List<UpcomingBill> billsSoon;
  final List<BudgetAlert> budgets;
  final String code;
  final int overdueDays;

  @override
  Widget build(BuildContext context) {
    if (overdue.isEmpty && billsSoon.isEmpty && budgets.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    Widget row(IconData icon, Color color, String label, String detail, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: text.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ),
              Flexible(
                child: Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
              ),
              const Icon(Icons.chevron_right, size: 16, color: AppTheme.mutedFg),
            ],
          ),
        ),
      );
    }

    final overdueSum = overdue.fold<int>(0, (s, o) => s + o.client.balanceMinor);
    final billsSum = billsSoon.fold<int>(0, (s, b) => s + b.subscription.amountMinor);

    return HomeCard(
      title: 'Needs attention',
      accent: AppTheme.ledgerCancel,
      child: Column(
        children: [
          if (overdue.isNotEmpty)
            row(
              Icons.hourglass_bottom_rounded,
              AppTheme.ledgerDebt,
              '${overdue.length} slow payer${overdue.length == 1 ? '' : 's'} · ${_fmt(overdueSum, code)}',
              '${overdue.first.client.fullName} · ${overdue.first.ageDays}d (>$overdueDays d)',
              () => overdue.length == 1
                  ? context.push('/client/${overdue.first.client.id}')
                  : context.go('/clients'),
            ),
          if (billsSoon.isNotEmpty)
            row(
              Icons.event_rounded,
              AppTheme.brandSecondary,
              '${billsSoon.length} bill${billsSoon.length == 1 ? '' : 's'} due soon · ${_fmt(billsSum, code)}',
              billsSoon.first.subscription.title,
              () => context.go('/finance?tab=subscriptions'),
            ),
          for (final b in budgets.take(3))
            row(
              b.over ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              b.over ? AppTheme.ledgerDebt : AppTheme.ledgerCancel,
              '${b.category.name} budget ${(b.ratio * 100).round()}%',
              '${_fmt(b.spentMinor, code)} / ${_fmt(b.budgetMinor, code)}',
              () => context.go('/finance?tab=expenses'),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client balances
// ─────────────────────────────────────────────────────────────────────────────

class ClientBalancesCard extends StatelessWidget {
  const ClientBalancesCard({super.key, required this.totals, required this.code});

  final ClientBalanceTotals totals;
  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget column(String label, int amount, int count, Color color, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(label, style: text.labelMedium?.copyWith(color: color)),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _fmt(amount, code),
                  style: text.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text('$count client${count == 1 ? '' : 's'}',
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
            ],
          ),
        ),
      );
    }

    return HomeCard(
      title: 'Client balances',
      actionLabel: 'Clients',
      onAction: () => context.go('/clients'),
      child: Row(
        children: [
          column('They pay you', totals.theyPayYouMinor, totals.theyPayYouCount,
              AppTheme.balanceReceivable, Icons.south_west_rounded),
          const SizedBox(width: 8),
          column('I pay them', totals.iPayThemMinor, totals.iPayThemCount, AppTheme.ledgerDebt,
              Icons.north_east_rounded),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// This month — expenses / gains / net + category split
// ─────────────────────────────────────────────────────────────────────────────

class ThisMonthCard extends StatelessWidget {
  const ThisMonthCard({
    super.key,
    required this.expenseMinor,
    required this.gainMinor,
    required this.expenseCategories,
    required this.gainCategories,
    required this.code,
  });

  final int expenseMinor;
  final int gainMinor;
  final List<CategoryTotal> expenseCategories;
  final List<CategoryTotal> gainCategories;
  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final net = gainMinor - expenseMinor;

    Widget line(String label, String value, Color color, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(label, style: text.bodyMedium?.copyWith(color: AppTheme.mutedFg)),
              const Spacer(),
              Text(
                value,
                style: (bold ? text.titleMedium : text.bodyLarge)?.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );

    return HomeCard(
      title: 'This month',
      actionLabel: 'Finance',
      onAction: () => context.go('/finance?tab=expenses'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line('Expenses', '−${_fmt(expenseMinor, code)}', AppTheme.personalExpense),
          line('Gains', '+${_fmt(gainMinor, code)}', AppTheme.personalGain),
          const Divider(height: 14),
          line('Net', '${net >= 0 ? '+' : '−'}${_fmt(net.abs(), code)}',
              net >= 0 ? AppTheme.personalGain : AppTheme.personalExpense,
              bold: true),
          if (expenseCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Spending by category',
                style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
            const SizedBox(height: 6),
            CategoryBreakdown(
              totals: expenseCategories,
              currencyCode: code,
              maxChips: 5,
              onTap: (_) => context.go('/finance?tab=expenses'),
            ),
          ],
          if (gainCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Gains by category', style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
            const SizedBox(height: 6),
            CategoryBreakdown(
              totals: gainCategories,
              currencyCode: code,
              maxChips: 4,
              onTap: (_) => context.go('/finance?tab=gains'),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending pulse
// ─────────────────────────────────────────────────────────────────────────────

class SpendingPulseCard extends StatelessWidget {
  const SpendingPulseCard({super.key, required this.rolling, required this.lastWeek, required this.code});

  final PulseWindow rolling;
  final PulseWindow lastWeek;
  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget row(PulseWindow w, String vsLabel) {
      final pct = w.changePct;
      final Widget badge;
      if (pct == null) {
        badge = Text(w.currentMinor > 0 ? 'new' : '—',
            style: text.labelMedium?.copyWith(color: AppTheme.mutedFg));
      } else {
        // Spending more is bad (red ▲); spending less is good (green ▼).
        final up = pct > 0;
        final color = pct == 0
            ? AppTheme.mutedFg
            : up
                ? AppTheme.ledgerDebt
                : AppTheme.balanceReceivable;
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${pct == 0 ? '•' : up ? '▲' : '▼'} ${pct.abs().toStringAsFixed(pct.abs() < 10 ? 1 : 0)}%',
            style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.label, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('$vsLabel ${_fmt(w.previousMinor, code)}',
                      style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
                ],
              ),
            ),
            Text(
              _fmt(w.currentMinor, code),
              style: text.titleMedium?.copyWith(
                color: AppTheme.personalExpense,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 72, child: Align(alignment: Alignment.centerRight, child: badge)),
          ],
        ),
      );
    }

    return HomeCard(
      title: 'Spending pulse',
      actionLabel: 'Details',
      onAction: () => context.go('/finance?tab=expenses'),
      child: Column(
        children: [
          row(rolling, 'prior 7 days'),
          const Divider(height: 8),
          row(lastWeek, 'week before'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet hub
// ─────────────────────────────────────────────────────────────────────────────

class WalletHubCard extends ConsumerWidget {
  const WalletHubCard({
    super.key,
    required this.accounts,
    required this.ledger,
    required this.netWorth,
    required this.code,
  });

  final List<WalletAccount> accounts;
  final List<WalletLedgerEntry> ledger;
  final int? netWorth;
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final byId = {for (final a in accounts) a.id: a};
    final recent = [...ledger]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Widget opButton(WalletOp op, IconData icon, String label, Color color) => Expanded(
          child: OutlinedButton.icon(
            onPressed: () => openWalletBalanceAction(context, ref, op: op),
            icon: Icon(icon, size: 16, color: color),
            label: Text(label, style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.45)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );

    return HomeCard(
      title: 'Wallet',
      actionLabel: 'See all',
      onAction: () => context.go('/finance?tab=wallet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (netWorth != null)
            Row(
              children: [
                Text('Net worth', style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Wallet + they pay you − I pay them',
                  child: Icon(Icons.info_outline, size: 14, color: AppTheme.mutedFg),
                ),
                const Spacer(),
                Text(
                  _fmt(netWorth!, code),
                  style: text.titleMedium?.copyWith(
                    color: netWorth! >= 0 ? AppTheme.balanceReceivable : AppTheme.ledgerDebt,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (accounts.isEmpty)
            Text('No wallet accounts yet — add one from Finance › Wallet.',
                style: text.bodySmall?.copyWith(color: AppTheme.mutedFg))
          else
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  final a = accounts[i];
                  return ActionChip(
                    avatar: Text(a.emoji),
                    label: Text('${a.name} · ${_fmt(a.balanceMinor, a.currencyCode)}'),
                    onPressed: () => openWalletHistorySheet(context, accountId: a.id),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              opButton(WalletOp.add, Icons.add_rounded, 'Add', AppTheme.balanceReceivable),
              const SizedBox(width: 6),
              opButton(WalletOp.remove, Icons.remove_rounded, 'Remove', AppTheme.ledgerDebt),
              const SizedBox(width: 6),
              opButton(WalletOp.set, Icons.tune_rounded, 'Set', walletSetColor),
            ],
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final e in recent.take(2))
              WalletEntryTile(entry: e, account: byId[e.accountId], showAccount: true, dense: true),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => openWalletHistorySheet(context),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('View history'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick add
// ─────────────────────────────────────────────────────────────────────────────

class QuickAddRow extends ConsumerWidget {
  const QuickAddRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget tile(IconData icon, String label, Color color, VoidCallback onTap) => Expanded(
          child: Material(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          tile(Icons.shopping_bag_outlined, 'Expense', AppTheme.personalExpense,
              () => addPersonalFinanceEntryFlow(context, ref, PersonalFinanceKind.expense)),
          const SizedBox(width: 8),
          tile(Icons.savings_outlined, 'Gain', AppTheme.personalGain,
              () => addPersonalFinanceEntryFlow(context, ref, PersonalFinanceKind.gain)),
          const SizedBox(width: 8),
          tile(Icons.swap_vert_rounded, 'Client tx', AppTheme.receivableAccent,
              () => openQuickClientTransaction(context, ref)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming bills (list + month calendar sheet)
// ─────────────────────────────────────────────────────────────────────────────

class UpcomingBillsCard extends StatelessWidget {
  const UpcomingBillsCard({super.key, required this.bills, required this.code});

  final List<UpcomingBill> bills;
  final String code;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final total = bills.fold<int>(0, (s, b) => s + b.subscription.amountMinor);

    return HomeCard(
      title: 'Upcoming bills · 30 days',
      actionLabel: 'Calendar',
      onAction: () => _openBillsCalendar(context, bills, code),
      child: Column(
        children: [
          for (final b in bills.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: (b.overdue ? AppTheme.ledgerDebt : AppTheme.brandSecondary)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(DateFormat.MMM().format(b.due),
                            style: text.labelSmall?.copyWith(color: AppTheme.mutedFg, fontSize: 9)),
                        Text('${b.due.day}',
                            style: text.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(b.subscription.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
                  ),
                  if (b.overdue)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('overdue',
                          style: text.labelSmall?.copyWith(color: AppTheme.ledgerDebt)),
                    ),
                  Text('−${_fmt(b.subscription.amountMinor, b.subscription.currencyCode)}',
                      style: text.labelLarge?.copyWith(
                          color: AppTheme.personalExpense, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          if (bills.length > 4)
            Align(
              alignment: Alignment.centerLeft,
              child: Text('+${bills.length - 4} more · ${_fmt(total, code)} total',
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
            ),
        ],
      ),
    );
  }
}

Future<void> _openBillsCalendar(BuildContext context, List<UpcomingBill> bills, String code) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => _BillsCalendar(bills: bills, code: code, scroll: scroll),
    ),
  );
}

class _BillsCalendar extends StatefulWidget {
  const _BillsCalendar({required this.bills, required this.code, required this.scroll});

  final List<UpcomingBill> bills;
  final String code;
  final ScrollController scroll;

  @override
  State<_BillsCalendar> createState() => _BillsCalendarState();
}

class _BillsCalendarState extends State<_BillsCalendar> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final byDay = <DateTime, List<UpcomingBill>>{};
    for (final b in widget.bills) {
      byDay.putIfAbsent(_day(b.due), () => []).add(b);
    }
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday; // 1 = Mon
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = _day(DateTime.now());
    final listed = _selected == null
        ? widget.bills
            .where((b) => b.due.year == _month.year && b.due.month == _month.month)
            .toList()
        : (byDay[_selected] ?? const <UpcomingBill>[]);

    return ListView(
      controller: widget.scroll,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1);
                _selected = null;
              }),
            ),
            Expanded(
              child: Text(DateFormat.yMMMM().format(_month),
                  textAlign: TextAlign.center,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1);
                _selected = null;
              }),
            ),
          ],
        ),
        Row(
          children: [
            for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(d, style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              Builder(builder: (ctx) {
                final date = DateTime(_month.year, _month.month, d);
                final has = byDay[date];
                final isSel = _selected == date;
                final isToday = date == today;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selected = isSel ? null : date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.brandSecondary.withValues(alpha: 0.25) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: AppTheme.brandPrimary) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$d', style: text.labelMedium),
                        if (has != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: has.any((b) => b.overdue)
                                  ? AppTheme.ledgerDebt
                                  : AppTheme.brandSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
        const Divider(height: 24),
        Text(
          _selected == null ? 'This month' : DateFormat.yMMMEd().format(_selected!),
          style: text.labelLarge?.copyWith(color: AppTheme.mutedFg),
        ),
        if (listed.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('No bills projected (next 30 days only)',
                style: text.bodySmall?.copyWith(color: AppTheme.mutedFg)),
          ),
        for (final b in listed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.autorenew_rounded,
                color: b.overdue ? AppTheme.ledgerDebt : AppTheme.brandSecondary),
            title: Text(b.subscription.title),
            subtitle: Text(DateFormat.MMMEd().format(b.due)),
            trailing: Text('−${_fmt(b.subscription.amountMinor, b.subscription.currencyCode)}',
                style: const TextStyle(color: AppTheme.personalExpense, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Savings goals snippet
// ─────────────────────────────────────────────────────────────────────────────

class GoalsSnippetCard extends StatelessWidget {
  const GoalsSnippetCard({super.key, required this.goals, required this.code});

  final List<SavingsGoal> goals;
  final String code;

  @override
  Widget build(BuildContext context) {
    final active = goals.where((g) => !g.isCompleted && g.targetMinor > 0).toList()
      ..sort((a, b) => (b.savedMinor / b.targetMinor).compareTo(a.savedMinor / a.targetMinor));
    if (active.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return HomeCard(
      title: 'Savings goals',
      actionLabel: 'Wallet',
      onAction: () => context.go('/finance?tab=wallet'),
      child: Column(
        children: [
          for (final g in active.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Builder(builder: (_) {
                final pct = (g.savedMinor / g.targetMinor).clamp(0.0, 1.0);
                final color = pct >= 0.8 ? AppTheme.balanceReceivable : AppTheme.receivableAccent;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(g.emoji),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(g.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Text('${(pct * 100).round()}%',
                            style: text.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${_fmt(g.savedMinor, code)} of ${_fmt(g.targetMinor, code)}',
                        style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budgets — every budgeted category with its current window usage
// ─────────────────────────────────────────────────────────────────────────────

class BudgetsCard extends StatelessWidget {
  const BudgetsCard({super.key, required this.budgets, required this.code});

  final List<BudgetAlert> budgets;
  final String code;

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return HomeCard(
      title: 'Budgets',
      actionLabel: 'Expenses',
      onAction: () => context.go('/finance?tab=expenses'),
      child: Column(
        children: [
          for (final b in budgets.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Builder(builder: (_) {
                final color = b.over
                    ? AppTheme.ledgerDebt
                    : b.ratio >= 0.9
                        ? AppTheme.ledgerCancel
                        : AppTheme.balanceReceivable;
                final period = switch (b.category.budgetPeriod) {
                  'week' => 'this week',
                  'custom' => 'last ${b.category.budgetCustomDays ?? 30}d',
                  _ => 'this month',
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${b.category.name} · $period',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Text('${_fmt(b.spentMinor, code)} / ${_fmt(b.budgetMinor, code)}',
                            style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: b.ratio.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent clients / recent finance
// ─────────────────────────────────────────────────────────────────────────────

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
                ],
              ),
            ),
            Text(amount,
                style: text.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ],
        ),
      ),
    );
  }
}

class RecentClientsCard extends StatelessWidget {
  const RecentClientsCard({super.key, required this.rows});

  final List<LedgerTransactionWithClient> rows;

  @override
  Widget build(BuildContext context) {
    final active = rows
        .where((r) => r.transaction.txStatus == LedgerTxStatus.active.index)
        .toList()
      ..sort((a, b) => (b.transaction.effectiveAt ?? b.transaction.createdAt)
          .compareTo(a.transaction.effectiveAt ?? a.transaction.createdAt));
    if (active.isEmpty) return const SizedBox.shrink();

    return HomeCard(
      title: 'Recent clients',
      actionLabel: 'See all',
      onAction: () => context.push('/transactions'),
      child: Column(
        children: [
          for (final r in active.take(4))
            Builder(builder: (_) {
              final tx = r.transaction;
              final isDebt = tx.txType == LedgerTxType.debt.index;
              return _RecentRow(
                icon: isDebt ? Icons.north_east_rounded : Icons.south_west_rounded,
                color: isDebt ? AppTheme.ledgerDebt : AppTheme.ledgerPayment,
                title: r.clientName,
                subtitle: '${isDebt ? 'Debt' : 'Payment'} · ${_relative(tx.effectiveAt ?? tx.createdAt)}',
                amount: _fmt(tx.amountMinor, tx.currencyCode),
                onTap: () => context.push('/client/${tx.clientId}'),
              );
            }),
        ],
      ),
    );
  }
}

class RecentFinanceCard extends StatelessWidget {
  const RecentFinanceCard({super.key, required this.expenses, required this.gains});

  final List<PersonalFinanceEntry> expenses;
  final List<PersonalFinanceEntry> gains;

  @override
  Widget build(BuildContext context) {
    final merged = [...expenses, ...gains]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (merged.isEmpty) return const SizedBox.shrink();

    return HomeCard(
      title: 'Recent finance',
      actionLabel: 'See all',
      onAction: () => context.go('/finance?tab=expenses'),
      child: Column(
        children: [
          for (final e in merged.take(4))
            Builder(builder: (_) {
              final isGain = e.kind == PersonalFinanceKind.gain.index;
              return _RecentRow(
                icon: isGain ? Icons.savings_outlined : Icons.shopping_bag_outlined,
                color: isGain ? AppTheme.personalGain : AppTheme.personalExpense,
                title: e.title,
                subtitle: '${isGain ? 'Gain' : 'Expense'} · ${_relative(e.createdAt)}',
                amount: '${isGain ? '+' : '−'}${_fmt(e.amountMinor, e.currencyCode)}',
                onTap: () => context.go('/finance?tab=${isGain ? 'gains' : 'expenses'}'),
              );
            }),
        ],
      ),
    );
  }
}

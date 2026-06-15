import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import '../../widgets/hud_empty_state.dart';
import 'home_exchange_rates_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(profileNameProvider);
    final clientsAsync = ref.watch(activeClientsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final walletAsync = ref.watch(walletAccountsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';
    final text = Theme.of(context).textTheme;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    final name = nameAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name != null && name.isNotEmpty ? '$greeting, $name' : greeting,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Analytics',
            onPressed: () => context.push('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: clientsAsync.when(
        data: (clients) {
          int receivable = 0;
          int payable = 0;
          for (final c in clients) {
            if (c.balanceMinor > 0) receivable += c.balanceMinor;
            if (c.balanceMinor < 0) payable += -c.balanceMinor;
          }

          final walletAccounts = walletAsync.valueOrNull ?? [];
          final netWorth = netWorthAsync.valueOrNull;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeClientsProvider);
              ref.invalidate(walletAccountsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                // ── Net receivable hero card ──────────────────────────────
                _NetSummaryCard(
                  receivable: receivable,
                  payable: payable,
                  activeCount: clients.length,
                  code: code,
                ),
                const SizedBox(height: 12),

                // ── Quick stat chips ──────────────────────────────────────
                _QuickStatChips(
                  receivable: receivable,
                  payable: payable,
                  activeCount: clients.length,
                  code: code,
                ),
                const SizedBox(height: 16),

                HomeExchangeRatesCard(defaultCode: code),
                const SizedBox(height: 16),

                // ── Wallet preview — always shown so user can set it up ──
                _WalletPreviewCard(
                  accounts: walletAccounts,
                  netWorth: netWorth,
                  code: code,
                  onTap: () => context.go('/finance'),
                ),
                const SizedBox(height: 16),

                // ── Top clients ───────────────────────────────────────────
                _TopClientsSection(
                  clients: clients,
                  code: code,
                  onSeeAll: () => context.go('/clients'),
                ),
                const SizedBox(height: 16),

                // ── Recent activity ───────────────────────────────────────
                _RecentActivitySection(code: code),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HudEmptyState(
          icon: Icons.error_outline,
          message: 'Could not load data',
          subtitle: e.toString(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Net Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _NetSummaryCard extends StatelessWidget {
  const _NetSummaryCard({
    required this.receivable,
    required this.payable,
    required this.activeCount,
    required this.code,
  });

  final int receivable;
  final int payable;
  final int activeCount;
  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.balanceReceivable.withValues(alpha: 0.3)),
        boxShadow: AppTheme.cardGlow(AppTheme.balanceReceivable, intensity: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Net Receivable',
              style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
          const SizedBox(height: 4),
          Text(
            MoneyFormat.formatMinor(receivable, code),
            style: text.headlineMedium?.copyWith(
              color: AppTheme.balanceReceivable,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$activeCount client${activeCount == 1 ? '' : 's'} owe you',
            style: text.bodySmall?.copyWith(color: AppTheme.mutedFg),
          ),
          if (payable > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.arrow_upward_rounded, size: 13, color: AppTheme.ledgerDebt),
                const SizedBox(width: 4),
                Text(
                  'You owe: ${MoneyFormat.formatMinor(payable, code)}',
                  style: text.labelSmall?.copyWith(color: AppTheme.ledgerDebt),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick stat chips
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatChips extends StatelessWidget {
  const _QuickStatChips({
    required this.receivable,
    required this.payable,
    required this.activeCount,
    required this.code,
  });

  final int receivable;
  final int payable;
  final int activeCount;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: MoneyFormat.formatMinor(receivable, code),
            sublabel: 'receivable',
            color: AppTheme.balanceReceivable,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: MoneyFormat.formatMinor(payable, code),
            sublabel: 'you owe',
            color: AppTheme.ledgerDebt,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: '$activeCount',
            sublabel: 'clients',
            color: AppTheme.receivableAccent,
            icon: Icons.people_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(sublabel, style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet preview card
// ─────────────────────────────────────────────────────────────────────────────

class _WalletPreviewCard extends StatelessWidget {
  const _WalletPreviewCard({
    required this.accounts,
    required this.netWorth,
    required this.code,
    required this.onTap,
  });

  final List<WalletAccount> accounts;
  final int? netWorth;
  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final preview = accounts.take(3).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.receivableAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: AppTheme.receivableAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💵 Wallet',
                      style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    preview.isEmpty
                        ? 'Tap to set up your wallet accounts'
                        : preview.map((a) => '${a.emoji} ${MoneyFormat.formatMinor(a.balanceMinor, code)}').join(' · '),
                    style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (netWorth != null) ...[
              const SizedBox(width: 8),
              Text(
                MoneyFormat.formatMinor(netWorth!, code),
                style: text.labelLarge?.copyWith(
                  color: netWorth! >= 0 ? AppTheme.balanceReceivable : AppTheme.ledgerDebt,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppTheme.mutedFg, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top clients section
// ─────────────────────────────────────────────────────────────────────────────

class _TopClientsSection extends StatelessWidget {
  const _TopClientsSection({
    required this.clients,
    required this.code,
    required this.onSeeAll,
  });

  final List<Client> clients;
  final String code;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final top = clients
        .where((c) => c.balanceMinor > 0)
        .toList()
      ..sort((a, b) => b.balanceMinor.compareTo(a.balanceMinor));
    final show = top.take(3).toList();

    if (show.isEmpty) return const SizedBox.shrink();

    final maxBalance = show.first.balanceMinor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Top balances', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: onSeeAll, child: const Text('See all →')),
          ],
        ),
        const SizedBox(height: 6),
        ...show.map((c) {
          final pct = maxBalance > 0 ? c.balanceMinor / maxBalance : 0.0;
          final accent = balanceColor(c.balanceMinor);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    _initials(c.fullName),
                    style: text.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            MoneyFormat.formatMinor(c.balanceMinor, code),
                            style: text.labelMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent activity section
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(allTransactionsProvider(null));
    final expenseAsync = ref.watch(personalFinanceEntriesProvider(PersonalFinanceKind.expense));
    final text = Theme.of(context).textTheme;

    final txList = txAsync.valueOrNull ?? [];
    final expenseList = expenseAsync.valueOrNull ?? [];

    // Merge last 5 transactions + last 2 expenses, sort by date desc
    final combined = <_ActivityItem>[
      ...txList.take(20).map((t) => _ActivityItem.fromTx(t)),
      ...expenseList.take(5).map((e) => _ActivityItem.fromExpense(e)),
    ]..sort((a, b) => b.at.compareTo(a.at));
    final show = combined.take(5).toList();

    if (show.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent activity',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('See all →'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...show.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 16, color: item.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _relativeTime(item.at),
                        style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.amountLabel,
                  style: text.labelMedium?.copyWith(
                    color: item.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(dt.toLocal());
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.amountLabel,
    required this.at,
    required this.color,
    required this.icon,
  });

  final String title;
  final String amountLabel;
  final DateTime at;
  final Color color;
  final IconData icon;

  factory _ActivityItem.fromTx(LedgerTransactionWithClient t) {
    final tx = t.transaction;
    final isDebt = tx.txType == LedgerTxType.debt.index;
    return _ActivityItem(
      title: t.clientName,
      amountLabel: MoneyFormat.formatMinor(tx.amountMinor, tx.currencyCode),
      at: tx.effectiveAt ?? tx.createdAt,
      color: isDebt ? AppTheme.ledgerDebt : AppTheme.ledgerPayment,
      icon: isDebt ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
    );
  }

  factory _ActivityItem.fromExpense(PersonalFinanceEntry e) {
    return _ActivityItem(
      title: e.title,
      amountLabel: MoneyFormat.formatMinor(e.amountMinor, e.currencyCode),
      at: e.createdAt,
      color: AppTheme.personalExpense,
      icon: Icons.shopping_bag_outlined,
    );
  }
}

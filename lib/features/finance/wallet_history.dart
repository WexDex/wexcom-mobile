import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import 'finance_period.dart';
import 'wallet_balance_actions.dart';

/// Opens wallet history as a tall draggable sheet. [accountId] null = all accounts.
Future<void> openWalletHistorySheet(BuildContext context, {String? accountId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => WalletHistoryView(
        initialAccountId: accountId,
        scrollController: scroll,
      ),
    ),
  );
}

/// One wallet ledger row with colored op, used everywhere wallet history shows.
class WalletEntryTile extends StatelessWidget {
  const WalletEntryTile({
    super.key,
    required this.entry,
    required this.account,
    this.showAccount = false,
    this.dense = false,
  });

  final WalletLedgerEntry entry;
  final WalletAccount? account;
  final bool showAccount;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final code = account?.currencyCode ?? 'DZD';
    final style = WalletEntryStyle.of(entry, code);
    final snap = FromCurrencySnapshot.fromJsonString(entry.fromCurrencyJson);
    final meta = [
      style.subtitle,
      if (snap != null) snap.formatPrimary(),
      if (entry.note != null && entry.note!.isNotEmpty) entry.note!,
      if (entry.source != 'manual') entry.source,
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 4 : 6),
      child: Row(
        children: [
          Container(
            width: dense ? 30 : 36,
            height: dense ? 30 : 36,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: showAccount && account != null
                ? Text(account!.emoji, style: TextStyle(fontSize: dense ? 14 : 16))
                : Icon(style.icon, size: dense ? 15 : 18, color: style.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showAccount && account != null
                      ? '${style.title} · ${account!.name}'
                      : style.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat.jm().format(entry.createdAt.toLocal()),
            style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
          ),
        ],
      ),
    );
  }
}

/// Filterable, day-grouped wallet history list with +/−/Set actions.
class WalletHistoryView extends ConsumerStatefulWidget {
  const WalletHistoryView({
    super.key,
    this.initialAccountId,
    this.scrollController,
    this.showHeader = true,
  });

  final String? initialAccountId;
  final ScrollController? scrollController;
  final bool showHeader;

  @override
  ConsumerState<WalletHistoryView> createState() => _WalletHistoryViewState();
}

class _WalletHistoryViewState extends ConsumerState<WalletHistoryView> {
  String? _accountId;
  FinancePeriod _period = FinancePeriod.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
  }

  Future<void> _selectPeriod(FinancePeriod p) async {
    if (p != FinancePeriod.custom) {
      setState(() {
        _period = p;
        _customStart = null;
        _customEnd = null;
      });
      return;
    }
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _period = p;
      _customStart = picked.start;
      _customEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accounts = ref.watch(walletAccountsProvider).valueOrNull ?? [];
    final byId = {for (final a in accounts) a.id: a};
    final selected = _accountId == null ? null : byId[_accountId];
    final ledgerAsync = ref.watch(allWalletLedgerProvider);
    final range = financePeriodRange(_period, customStart: _customStart, customEnd: _customEnd);

    final header = <Widget>[
      if (widget.showHeader)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected == null ? 'Wallet history' : '${selected.emoji} ${selected.name}',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              _OpButton(op: WalletOp.add, account: selected),
              _OpButton(op: WalletOp.remove, account: selected),
              _OpButton(op: WalletOp.set, account: selected),
            ],
          ),
        ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: const Text('All'),
                selected: _accountId == null,
                onSelected: (_) => setState(() => _accountId = null),
              ),
            ),
            for (final a in accounts)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('${a.emoji} ${a.name}'),
                  selected: _accountId == a.id,
                  onSelected: (_) => setState(() => _accountId = a.id),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final p in FinancePeriod.values)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(financePeriodLabel(p,
                      customStart: _customStart, customEnd: _customEnd)),
                  selected: _period == p,
                  onSelected: (_) => _selectPeriod(p),
                ),
              ),
          ],
        ),
      ),
      const Divider(height: 20),
    ];

    final rows = (ledgerAsync.valueOrNull ?? [])
        .where((e) => _accountId == null || e.accountId == _accountId)
        .where((e) => dateInFinanceRange(e.createdAt, range.start, range.end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final body = <Widget>[];
    if (ledgerAsync.isLoading && !ledgerAsync.hasValue) {
      body.add(const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else if (rows.isEmpty) {
      body.add(Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text('No wallet activity in this period',
              style: text.bodyMedium?.copyWith(color: AppTheme.mutedFg)),
        ),
      ));
    } else {
      DateTime? currentDay;
      for (final e in rows) {
        final local = e.createdAt.toLocal();
        final day = DateTime(local.year, local.month, local.day);
        if (day != currentDay) {
          currentDay = day;
          body.add(Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(_dayLabel(day),
                style: text.labelMedium?.copyWith(
                    color: AppTheme.mutedFg, fontWeight: FontWeight.w700)),
          ));
        }
        body.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WalletEntryTile(
            entry: e,
            account: byId[e.accountId],
            showAccount: _accountId == null,
          ),
        ));
      }
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(allWalletLedgerProvider),
      child: ListView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [...header, ...body],
      ),
    );
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat.yMMMEd().format(day);
  }
}

class _OpButton extends ConsumerWidget {
  const _OpButton({required this.op, required this.account});

  final WalletOp op;
  final WalletAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, color, tip) = switch (op) {
      WalletOp.add => (Icons.add_circle_outline, AppTheme.balanceReceivable, 'Add'),
      WalletOp.remove => (Icons.remove_circle_outline, AppTheme.ledgerDebt, 'Remove'),
      WalletOp.set => (Icons.tune_rounded, walletSetColor, 'Set balance'),
    };
    return IconButton(
      tooltip: tip,
      icon: Icon(icon, color: color),
      onPressed: () => openWalletBalanceAction(context, ref, account: account, op: op),
    );
  }
}

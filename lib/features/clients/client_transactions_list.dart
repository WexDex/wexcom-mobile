import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

enum _TxKindFilter { all, debt, payment, cancelled }

class ClientTransactionsList extends StatefulWidget {
  const ClientTransactionsList({
    super.key,
    required this.transactions,
    required this.currencyCode,
    required this.onEditActive,
    required this.onCancelActive,
  });

  final List<LedgerTransaction> transactions;
  final String currencyCode;
  final void Function(LedgerTransaction tx) onEditActive;
  final void Function(String txId) onCancelActive;

  @override
  State<ClientTransactionsList> createState() => _ClientTransactionsListState();
}

class _ClientTransactionsListState extends State<ClientTransactionsList> {
  _TxKindFilter _kind = _TxKindFilter.all;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime _issuedAt(LedgerTransaction tx) => tx.effectiveAt ?? tx.createdAt;

  bool _inDateRange(DateTime issuedUtc) {
    if (_rangeStart == null || _rangeEnd == null) return true;
    final local = issuedUtc.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    final a = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
    final b = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);
    return !d.isBefore(a) && !d.isAfter(b);
  }

  Iterable<LedgerTransaction> get _filtered sync* {
    for (final t in widget.transactions) {
      if (!_inDateRange(_issuedAt(t))) continue;
      final active = t.txStatus == LedgerTxStatus.active.index;
      final type = LedgerTxType.fromInt(t.txType);
      switch (_kind) {
        case _TxKindFilter.all:
          yield t;
        case _TxKindFilter.debt:
          if (active && type == LedgerTxType.debt) yield t;
        case _TxKindFilter.payment:
          if (active && type == LedgerTxType.payment) yield t;
        case _TxKindFilter.cancelled:
          if (!active) yield t;
      }
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = _rangeStart != null && _rangeEnd != null
        ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
        : DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.receivableAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _rangeStart = picked.start;
        _rangeEnd = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered.toList();
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _kind == _TxKindFilter.all,
                onSelected: (_) => setState(() => _kind = _TxKindFilter.all),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppTheme.ledgerDebt.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    const Text('Debt'),
                  ],
                ),
                selected: _kind == _TxKindFilter.debt,
                onSelected: (_) => setState(() => _kind = _TxKindFilter.debt),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppTheme.ledgerPayment.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    const Text('Payment'),
                  ],
                ),
                selected: _kind == _TxKindFilter.payment,
                onSelected: (_) =>
                    setState(() => _kind = _TxKindFilter.payment),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.layers_clear,
                      size: 16,
                      color: AppTheme.ledgerCancel.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    const Text('Cancelled'),
                  ],
                ),
                selected: _kind == _TxKindFilter.cancelled,
                onSelected: (_) =>
                    setState(() => _kind = _TxKindFilter.cancelled),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonalIcon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range_outlined, size: 20),
                label: Text(
                  _rangeStart == null || _rangeEnd == null
                      ? 'All dates'
                      : '${MoneyFormat.formatDate(_rangeStart!)} – ${MoneyFormat.formatDate(_rangeEnd!)}',
                  style: text.labelLarge,
                ),
              ),
              if (_rangeStart != null && _rangeEnd != null)
                TextButton(
                  onPressed: () => setState(() {
                    _rangeStart = null;
                    _rangeEnd = null;
                  }),
                  child: const Text('Clear dates'),
                ),
            ],
          ),
        ),
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                widget.transactions.isEmpty
                    ? 'No transactions yet.'
                    : 'Nothing matches these filters.',
                style: TextStyle(color: AppTheme.mutedFg),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = filtered[i];
                return _LedgerTransactionTile(
                  tx: t,
                  currencyCode: widget.currencyCode,
                  onTap: t.txStatus == LedgerTxStatus.active.index
                      ? () => widget.onEditActive(t)
                      : null,
                  onCancel: t.txStatus == LedgerTxStatus.active.index
                      ? () => widget.onCancelActive(t.id)
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _LedgerTransactionTile extends StatelessWidget {
  const _LedgerTransactionTile({
    required this.tx,
    required this.currencyCode,
    this.onTap,
    this.onCancel,
  });

  final LedgerTransaction tx;
  final String currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final active = tx.txStatus == LedgerTxStatus.active.index;
    final type = LedgerTxType.fromInt(tx.txType);
    final typeColor = type == LedgerTxType.debt
        ? AppTheme.ledgerDebt
        : AppTheme.ledgerPayment;
    final typeLabel = type == LedgerTxType.debt ? 'Debt' : 'Payment';
    final amountLabel = MoneyFormat.formatMinor(tx.amountMinor, currencyCode);
    final text = Theme.of(context).textTheme;

    final borderColor = !active
        ? AppTheme.ledgerCancel.withValues(alpha: 0.65)
        : typeColor.withValues(alpha: 0.85);
    final bgTint = !active
        ? AppTheme.ledgerCancelSurface.withValues(alpha: 0.85)
        : typeColor.withValues(alpha: 0.14);

    return Material(
      color: bgTint,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: !active ? AppTheme.ledgerCancel : typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (!active ? AppTheme.ledgerCancel : typeColor)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            !active ? 'Cancelled' : typeLabel,
                            style: text.labelMedium?.copyWith(
                              color: !active
                                  ? AppTheme.ledgerCancel
                                  : typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          amountLabel,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: active ? typeColor : AppTheme.mutedFg,
                            decoration: active
                                ? null
                                : TextDecoration.lineThrough,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Issued ${MoneyFormat.formatDateTime(tx.effectiveAt ?? tx.createdAt)}',
                      style: text.bodySmall?.copyWith(
                        color: active
                            ? typeColor.withValues(alpha: 0.95)
                            : AppTheme.mutedFg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (tx.effectiveAt != null &&
                        tx.effectiveAt!.toUtc() != tx.createdAt.toUtc())
                      Text(
                        'Created ${MoneyFormat.formatDateTime(tx.createdAt)}',
                        style: text.bodySmall?.copyWith(
                          color: AppTheme.mutedFg.withValues(alpha: 0.72),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance ${MoneyFormat.formatMinor(tx.postedBalanceBeforeMinor, currencyCode)} → ${MoneyFormat.formatMinor(tx.postedBalanceAfterMinor, currencyCode)}',
                      style: text.bodyLarge?.copyWith(
                        color: AppTheme.mutedFg.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (!active &&
                        tx.cancelBalanceBeforeMinor != null &&
                        tx.cancelBalanceAfterMinor != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppTheme.ledgerCancel.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'After cancel: ${MoneyFormat.formatMinor(tx.cancelBalanceBeforeMinor!, currencyCode)} → ${MoneyFormat.formatMinor(tx.cancelBalanceAfterMinor!, currencyCode)}',
                              style: text.bodyMedium?.copyWith(
                                color: AppTheme.ledgerCancel.withValues(
                                  alpha: 0.95,
                                ),
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(tx.note!, style: text.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (active)
                IconButton(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: AppTheme.ledgerCancel.withValues(alpha: 0.95),
                  ),
                  tooltip: 'Cancel transaction',
                  onPressed: onCancel,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.not_interested_outlined,
                    color: AppTheme.mutedFg.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

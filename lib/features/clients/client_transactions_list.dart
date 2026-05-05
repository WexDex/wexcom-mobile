import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

enum _TxKindFilter { all, debt, payment, cancelled }

class ClientTransactionsList extends ConsumerStatefulWidget {
  const ClientTransactionsList({
    super.key,
    required this.transactions,
    required this.currencyCode,
    required this.onEditActive,
    required this.onCancelActive,
    this.embeddedInParentScroll = false,
    this.compactControls = false,
  });

  final List<LedgerTransaction> transactions;
  final String currencyCode;
  final void Function(LedgerTransaction tx) onEditActive;
  final void Function(String txId) onCancelActive;
  final bool embeddedInParentScroll;
  final bool compactControls;

  @override
  ConsumerState<ClientTransactionsList> createState() =>
      _ClientTransactionsListState();
}

class _ClientTransactionsListState extends ConsumerState<ClientTransactionsList> {
  _TxKindFilter _kind = _TxKindFilter.all;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showAdvancedFilters = false;
  final Set<String> _selectedTagIds = <String>{};
  RangeValues? _amountRange;

  DateTime _issuedAt(LedgerTransaction tx) => tx.effectiveAt ?? tx.createdAt;
  DateTime _cancelledAtOrIssued(LedgerTransaction tx) =>
      tx.cancelledAt ?? tx.effectiveAt ?? tx.createdAt;

  bool _inDateRange(DateTime issuedUtc) {
    if (_rangeStart == null || _rangeEnd == null) return true;
    final local = issuedUtc.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    final a = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
    final b = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);
    return !d.isBefore(a) && !d.isAfter(b);
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
    final txTagsByTxId = <String, List<Tag>>{
      for (final tx in widget.transactions)
        tx.id: ref.watch(transactionTagsProvider(tx.id)).valueOrNull ?? const <Tag>[],
    };
    final availableTags = txTagsByTxId.values
        .expand((tags) => tags)
        .fold<Map<String, Tag>>({}, (map, tag) {
          map[tag.id] = tag;
          return map;
        })
        .values
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final amounts = widget.transactions.map((t) => t.amountMinor).toList();
    final minAmount = amounts.isEmpty ? 0 : amounts.reduce((a, b) => a < b ? a : b);
    final maxAmount = amounts.isEmpty ? 0 : amounts.reduce((a, b) => a > b ? a : b);
    final sliderMin = minAmount.toDouble();
    final sliderMax = (maxAmount > minAmount ? maxAmount : minAmount + 1).toDouble();
    final effectiveAmountRange = _amountRange == null
        ? RangeValues(sliderMin, sliderMax)
        : RangeValues(
            _amountRange!.start.clamp(sliderMin, sliderMax),
            _amountRange!.end.clamp(sliderMin, sliderMax),
          );

    final filtered = widget.transactions.where((t) {
      if (!_inDateRange(_issuedAt(t))) return false;
      final active = t.txStatus == LedgerTxStatus.active.index;
      final type = LedgerTxType.fromInt(t.txType);
      switch (_kind) {
        case _TxKindFilter.all:
          break;
        case _TxKindFilter.debt:
          if (!(active && type == LedgerTxType.debt)) return false;
        case _TxKindFilter.payment:
          if (!(active && type == LedgerTxType.payment)) return false;
        case _TxKindFilter.cancelled:
          if (active) return false;
      }
      final amount = t.amountMinor.toDouble();
      if (amount < effectiveAmountRange.start || amount > effectiveAmountRange.end) {
        return false;
      }
      if (_selectedTagIds.isNotEmpty) {
        final tagIds = txTagsByTxId[t.id]?.map((e) => e.id).toSet() ?? const <String>{};
        if (_selectedTagIds.intersection(tagIds).isEmpty) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort(_compareTx);
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(16, 0, 16, widget.compactControls ? 4 : 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                visualDensity: widget.compactControls
                    ? VisualDensity.compact
                    : VisualDensity.standard,
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
                visualDensity: widget.compactControls
                    ? VisualDensity.compact
                    : VisualDensity.standard,
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
                visualDensity: widget.compactControls
                    ? VisualDensity.compact
                    : VisualDensity.standard,
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
                visualDensity: widget.compactControls
                    ? VisualDensity.compact
                    : VisualDensity.standard,
                selected: _kind == _TxKindFilter.cancelled,
                onSelected: (_) =>
                    setState(() => _kind = _TxKindFilter.cancelled),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, widget.compactControls ? 6 : 10),
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
                  style: (widget.compactControls ? text.labelMedium : text.labelLarge),
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
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showAdvancedFilters = !_showAdvancedFilters),
                icon: Icon(
                  _showAdvancedFilters
                      ? Icons.tune_rounded
                      : Icons.tune_outlined,
                  size: 18,
                ),
                label: Text(_showAdvancedFilters ? 'Hide filters' : 'More filters'),
              ),
            ],
          ),
        ),
        if (_showAdvancedFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: AppTheme.receivableAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Advanced filters',
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() {
                          _selectedTagIds.clear();
                          _amountRange = null;
                        }),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount range',
                    style: text.labelLarge?.copyWith(
                      color: AppTheme.mutedFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  RangeSlider(
                    values: effectiveAmountRange,
                    min: sliderMin,
                    max: sliderMax,
                    labels: RangeLabels(
                      MoneyFormat.formatMinor(
                        effectiveAmountRange.start.round(),
                        widget.currencyCode,
                      ),
                      MoneyFormat.formatMinor(
                        effectiveAmountRange.end.round(),
                        widget.currencyCode,
                      ),
                    ),
                    onChanged: (values) => setState(() => _amountRange = values),
                  ),
                  Text(
                    '${MoneyFormat.formatMinor(effectiveAmountRange.start.round(), widget.currencyCode)} - ${MoneyFormat.formatMinor(effectiveAmountRange.end.round(), widget.currencyCode)}',
                    style: text.bodySmall?.copyWith(color: AppTheme.mutedFg),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tags',
                    style: text.labelLarge?.copyWith(
                      color: AppTheme.mutedFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (availableTags.isEmpty)
                    Text(
                      'No tags in this client transactions yet.',
                      style: text.bodySmall?.copyWith(color: AppTheme.mutedFg),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: availableTags
                          .map(
                            (tag) => FilterChip(
                              label: Text(tag.name),
                              avatar: CircleAvatar(
                                radius: 4,
                                backgroundColor: _tagColor(tag.colorHex),
                              ),
                              selected: _selectedTagIds.contains(tag.id),
                              selectedColor:
                                  _tagColor(tag.colorHex).withValues(alpha: 0.22),
                              side: BorderSide(
                                color: _tagColor(tag.colorHex).withValues(alpha: 0.75),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTagIds.add(tag.id);
                                  } else {
                                    _selectedTagIds.remove(tag.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        if (filtered.isEmpty)
          SizedBox(
            height: widget.embeddedInParentScroll ? null : 220,
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
          ListView.separated(
            shrinkWrap: widget.embeddedInParentScroll,
            physics: widget.embeddedInParentScroll
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final t = filtered[i];
              return _LedgerTransactionTile(
                    indexLabel: '${i + 1}',
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
      ],
    );
  }

  int _compareTx(LedgerTransaction a, LedgerTransaction b) {
    if (_kind == _TxKindFilter.cancelled) {
      final cancelCompare = _cancelledAtOrIssued(b).compareTo(_cancelledAtOrIssued(a));
      if (cancelCompare != 0) return cancelCompare;
    }

    final issuedCompare = _issuedAt(b).compareTo(_issuedAt(a));
    if (issuedCompare != 0) return issuedCompare;
    final createdCompare = b.createdAt.compareTo(a.createdAt);
    if (createdCompare != 0) return createdCompare;
    return b.id.compareTo(a.id);
  }
}

Color _tagColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

class _LedgerTransactionTile extends ConsumerWidget {
  const _LedgerTransactionTile({
    required this.indexLabel,
    required this.tx,
    required this.currencyCode,
    this.onTap,
    this.onCancel,
  });

  final String indexLabel;
  final LedgerTransaction tx;
  final String currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(transactionTagsProvider(tx.id)).valueOrNull ?? const <Tag>[];
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
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            '#$indexLabel',
                            style: text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.mutedFg,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeLabel,
                            style: text.labelMedium?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!active) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.ledgerCancel.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cancelled',
                              style: text.labelMedium?.copyWith(
                                color: AppTheme.ledgerCancel,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags
                            .map(
                              (t) => Chip(
                                label: Text(t.name),
                                avatar: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: _tagColor(t.colorHex),
                                ),
                                backgroundColor: _tagColor(
                                  t.colorHex,
                                ).withValues(alpha: 0.18),
                                side: BorderSide(
                                  color: _tagColor(t.colorHex).withValues(alpha: 0.75),
                                ),
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
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

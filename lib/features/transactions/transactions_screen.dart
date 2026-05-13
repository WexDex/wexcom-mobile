import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/hud_empty_state.dart';
import '../../widgets/skeleton_loaders.dart';
import 'transaction_editor_sheet.dart';

Color _tagColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

enum _TxTypeFilter { debt, payment, cancelled }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedClientId;
  String _searchQuery = '';
  final Set<_TxTypeFilter> _typeFilters = {};
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LedgerTransactionWithClient> _filter(List<LedgerTransactionWithClient> rows) {
    var result = rows;

    // Type filter
    if (_typeFilters.isNotEmpty) {
      result = result.where((r) {
        final type = LedgerTxType.fromInt(r.transaction.txType);
        final status = LedgerTxStatus.fromInt(r.transaction.txStatus);
        if (_typeFilters.contains(_TxTypeFilter.cancelled) && status == LedgerTxStatus.cancelled) return true;
        if (_typeFilters.contains(_TxTypeFilter.debt) && type == LedgerTxType.debt && status == LedgerTxStatus.active) return true;
        if (_typeFilters.contains(_TxTypeFilter.payment) && type == LedgerTxType.payment && status == LedgerTxStatus.active) return true;
        return false;
      }).toList();
    }

    // Text search
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((r) {
        final tx = r.transaction;
        return r.clientName.toLowerCase().contains(q) ||
            (tx.note?.toLowerCase().contains(q) ?? false) ||
            (tx.referenceNo?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(allTransactionsProvider(_selectedClientId));
    final clientsAsync = ref.watch(activeClientsProvider);
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: txAsync.valueOrNull == null
                ? null
                : () => _exportCsv(context, txAsync.valueOrNull!),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search client, note, reference…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // ── Filter chips ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                // Client filter chip
                clientsAsync.when(
                  data: (clients) {
                    final clientName = _selectedClientId == null
                        ? null
                        : clients.firstWhere((c) => c.id == _selectedClientId, orElse: () => clients.first).fullName;
                    return FilterChip(
                      avatar: const Icon(Icons.person_outline, size: 16),
                      label: Text(clientName ?? 'All clients'),
                      selected: _selectedClientId != null,
                      selectedColor: AppTheme.brandPrimary.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.brandPrimary,
                      onSelected: (_) => _pickClientFilter(context, clients),
                      side: BorderSide(
                        color: _selectedClientId != null
                            ? AppTheme.brandPrimary.withValues(alpha: 0.6)
                            : AppTheme.mutedFg.withValues(alpha: 0.35),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                _typeChip(theme, _TxTypeFilter.debt, 'Debt', AppTheme.ledgerDebt),
                const SizedBox(width: 8),
                _typeChip(theme, _TxTypeFilter.payment, 'Payment', AppTheme.ledgerPayment),
                const SizedBox(width: 8),
                _typeChip(theme, _TxTypeFilter.cancelled, 'Cancelled', AppTheme.ledgerCancel),
                if (_typeFilters.isNotEmpty || _selectedClientId != null) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Clear'),
                    avatar: const Icon(Icons.filter_alt_off_outlined, size: 16),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _typeFilters.clear();
                        _selectedClientId = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          // ── Transaction list ──────────────────────────────────────────────
          Expanded(
            child: txAsync.when(
              data: (rows) {
                final filtered = _filter(rows);
                if (filtered.isEmpty) {
                  return HudEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: rows.isEmpty ? 'No transactions yet' : 'No results found',
                    subtitle: rows.isEmpty
                        ? 'Tap + to add your first transaction'
                        : 'Try adjusting your search or filters',
                  );
                }
                final grouped = _groupByDate(filtered);
                final keys = grouped.keys.toList();
                var runningIndex = 0;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                  itemCount: keys.length,
                  itemBuilder: (context, i) {
                    final key = keys[i];
                    final items = grouped[key]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(key, style: Theme.of(context).textTheme.titleSmall),
                        ),
                        ...items.map((row) {
                          runningIndex += 1;
                          final isDebt = LedgerTxType.fromInt(row.transaction.txType) == LedgerTxType.debt;
                          final isActive = LedgerTxStatus.fromInt(row.transaction.txStatus) == LedgerTxStatus.active;
                          return Dismissible(
                            key: ValueKey(row.transaction.id),
                            direction: isActive ? DismissDirection.horizontal : DismissDirection.none,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                // Cancel
                                return _confirmCancel(context, row);
                              } else {
                                // Settle — only for debt
                                if (!isDebt) return false;
                                return _confirmSettle(context, row);
                              }
                            },
                            onDismissed: (_) {
                              // Row already acted on in confirmDismiss; nothing extra needed
                            },
                            background: _SwipeBg(
                              color: AppTheme.ledgerPayment,
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Settle',
                              alignment: Alignment.centerLeft,
                            ),
                            secondaryBackground: _SwipeBg(
                              color: AppTheme.ledgerDebt,
                              icon: Icons.cancel_outlined,
                              label: 'Cancel',
                              alignment: Alignment.centerRight,
                            ),
                            child: _TxCard(
                              index: runningIndex,
                              row: row,
                              currencyCode: code,
                              tagsAsync: ref.watch(transactionTagsProvider(row.transaction.id)),
                              onEdit: () => _openEditor(context, editing: row.transaction),
                              onMarkPaid: () async {
                                HapticFeedback.heavyImpact();
                                await ref.read(ledgerRepositoryProvider).markDebtAsPaid(row.transaction.id);
                              },
                              onSettleFullDebt: () async {
                                HapticFeedback.heavyImpact();
                                await ref.read(ledgerRepositoryProvider).settleFullDebt(row.transaction.clientId);
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
              loading: () => ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                children: const [TransactionListSkeleton()],
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _openEditor(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _typeChip(ThemeData theme, _TxTypeFilter filter, String label, Color color) {
    final sel = _typeFilters.contains(filter);
    return FilterChip(
      label: Text(label),
      selected: sel,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: sel ? color : AppTheme.mutedFg,
        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13,
      ),
      side: BorderSide(color: sel ? color.withValues(alpha: 0.6) : AppTheme.mutedFg.withValues(alpha: 0.35)),
      onSelected: (v) {
        HapticFeedback.selectionClick();
        setState(() {
          if (v) {
            _typeFilters.add(filter);
          } else {
            _typeFilters.remove(filter);
          }
        });
      },
    );
  }

  Future<void> _pickClientFilter(BuildContext context, List<Client> clients) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All clients'),
              leading: const Icon(Icons.people_outline),
              selected: _selectedClientId == null,
              onTap: () => Navigator.pop(ctx, ''),
            ),
            ...clients.map((c) => ListTile(
              title: Text(c.fullName),
              selected: _selectedClientId == c.id,
              onTap: () => Navigator.pop(ctx, c.id),
            )),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _selectedClientId = picked.isEmpty ? null : picked);
  }

  Future<bool> _confirmCancel(BuildContext context, LedgerTransactionWithClient row) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel transaction?'),
        content: Text(
          'Cancel the ${LedgerTxType.fromInt(row.transaction.txType).name} of '
          '${MoneyFormat.formatMinor(row.transaction.amountMinor, ref.read(defaultCurrencyProvider).valueOrNull ?? 'DZD')} '
          'for ${row.clientName}? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.ledgerDebt),
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await ref.read(ledgerRepositoryProvider).cancelTransaction(row.transaction.id);
    }
    return false; // Don't dismiss the Dismissible — list updates via stream
  }

  Future<bool> _confirmSettle(BuildContext context, LedgerTransactionWithClient row) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settle debt?'),
        content: Text(
          'Mark the ${MoneyFormat.formatMinor(row.transaction.amountMinor, ref.read(defaultCurrencyProvider).valueOrNull ?? 'DZD')} '
          'debt for ${row.clientName} as paid?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Settle'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await ref.read(ledgerRepositoryProvider).markDebtAsPaid(row.transaction.id);
    }
    return false;
  }

  Map<String, List<LedgerTransactionWithClient>> _groupByDate(
    List<LedgerTransactionWithClient> rows,
  ) {
    final grouped = <String, List<LedgerTransactionWithClient>>{};
    for (final row in rows) {
      final issued = row.transaction.effectiveAt ?? row.transaction.createdAt;
      final key = MoneyFormat.formatDate(issued);
      grouped.putIfAbsent(key, () => []).add(row);
    }
    return grouped;
  }

  Future<void> _openEditor(
    BuildContext context, {
    LedgerTransaction? editing,
    int? defaultAmount,
    LedgerTxType? defaultType,
  }) async {
    final clients = await ref.read(activeClientsProvider.future);
    final tags = await ref.read(transactionScopeTagsProvider.future);
    final selectedTags = editing == null
        ? const <String>[]
        : (await ref.read(transactionTagsProvider(editing.id).future)).map((e) => e.id).toList();
    String? targetClientId = editing?.clientId ?? _selectedClientId;
    if (targetClientId == null && clients.isNotEmpty) {
      targetClientId = clients.first.id;
    }
    if (targetClientId == null) return;
    int? fallbackBalance;
    for (final c in clients) {
      if (c.id == targetClientId) {
        fallbackBalance = c.balanceMinor;
        break;
      }
    }

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: TransactionEditorSheet(
          title: editing == null ? 'New transaction' : 'Edit transaction',
          currencyCode: ref.read(defaultCurrencyProvider).valueOrNull ?? 'DZD',
          initialAmountMinor: editing?.amountMinor ?? defaultAmount,
          initialType: editing == null
              ? (defaultType ?? LedgerTxType.debt)
              : LedgerTxType.fromInt(editing.txType),
          initialNote: editing?.note,
          availableTags: tags,
          initialTagIds: selectedTags,
          initialEffectiveAt: editing?.effectiveAt ?? editing?.createdAt,
          currentBalanceMinor: editing?.postedBalanceBeforeMinor ?? fallbackBalance,
          templates: editing == null
              ? (ref.read(transactionTemplatesProvider).valueOrNull ?? [])
              : [],
          onSaveTemplate: editing == null
              ? (label, amount, type, note) => ref
                    .read(ledgerRepositoryProvider)
                    .saveTemplate(
                      label: label,
                      amountMinor: amount,
                      type: type,
                      note: note,
                      currencyCode: ref.read(defaultCurrencyProvider).valueOrNull ?? 'DZD',
                    )
              : null,
          onDeleteTemplate: editing == null
              ? (id) => ref.read(ledgerRepositoryProvider).deleteTemplate(id)
              : null,
          onSubmit: (amountMinor, type, note, tagIds, effectiveAt, dueAt) async {
            if (editing == null) {
              await ref.read(ledgerRepositoryProvider).insertTransaction(
                clientId: targetClientId!,
                amountMinor: amountMinor,
                type: type,
                note: note,
                tagIds: tagIds,
                effectiveAt: effectiveAt,
                dueAt: dueAt,
              );
            } else {
              await ref.read(ledgerRepositoryProvider).updateTransaction(
                id: editing.id,
                amountMinor: amountMinor,
                type: type,
                note: note,
                tagIds: tagIds,
                effectiveAt: effectiveAt,
                dueAt: dueAt,
              );
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, List<LedgerTransactionWithClient> rows) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    final csv = ExportService().exportTransactionsCsv(rows, range: range);
    if (!context.mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Copy CSV to clipboard'),
              onTap: () => Navigator.pop(ctx, 'clipboard'),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download CSV file'),
              onTap: () => Navigator.pop(ctx, 'download'),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == 'clipboard') {
      await Clipboard.setData(ClipboardData(text: csv));
    } else {
      try {
        final location = await getSaveLocation(
          suggestedName: 'transactions_export_${DateTime.now().millisecondsSinceEpoch}.csv',
          acceptedTypeGroups: const [XTypeGroup(label: 'csv', extensions: ['csv'])],
        );
        if (location == null) return;
        final file = XFile.fromData(
          Uint8List.fromList(utf8.encode(csv)),
          mimeType: 'text/csv',
          name: 'transactions_export.csv',
        );
        await file.saveTo(location.path);
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: csv));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File save unavailable. CSV copied to clipboard instead.')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action == 'clipboard' ? 'Transactions CSV copied to clipboard' : 'Transactions CSV downloaded'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Swipe action background
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({required this.color, required this.icon, required this.label, required this.alignment});

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ] else ...[
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(icon, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction card
// ─────────────────────────────────────────────────────────────────────────────

class _TxCard extends StatelessWidget {
  const _TxCard({
    required this.index,
    required this.row,
    required this.currencyCode,
    required this.tagsAsync,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onSettleFullDebt,
  });

  final int index;
  final LedgerTransactionWithClient row;
  final String currencyCode;
  final AsyncValue<List<Tag>> tagsAsync;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onSettleFullDebt;

  @override
  Widget build(BuildContext context) {
    final tx = row.transaction;
    final type = LedgerTxType.fromInt(tx.txType);
    final status = LedgerTxStatus.fromInt(tx.txStatus);
    final isActive = status == LedgerTxStatus.active;
    final color = status == LedgerTxStatus.cancelled
        ? AppTheme.ledgerCancel
        : type == LedgerTxType.debt
            ? AppTheme.ledgerDebt
            : AppTheme.ledgerPayment;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: isActive ? AppTheme.cardGlow(color, intensity: 0.06) : null,
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                '#$index  ${row.clientName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withValues(alpha: 0.16),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Text(
                status == LedgerTxStatus.cancelled ? 'CANCELLED' : type.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issued ${MoneyFormat.formatDateTime(tx.effectiveAt ?? tx.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (tx.effectiveAt != null && tx.effectiveAt!.toUtc() != tx.createdAt.toUtc())
              Text(
                'Created ${MoneyFormat.formatDateTime(tx.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedFg.withValues(alpha: 0.72),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text(MoneyFormat.formatMinor(tx.amountMinor, currencyCode)),
            if (tx.note != null && tx.note!.isNotEmpty) Text(tx.note!),
            tagsAsync.when(
              data: (tags) => tags.isEmpty
                  ? const SizedBox.shrink()
                  : Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (t) => Chip(
                              label: Text(t.name),
                              avatar: CircleAvatar(radius: 4, backgroundColor: _tagColor(t.colorHex)),
                              backgroundColor: _tagColor(t.colorHex).withValues(alpha: 0.18),
                              side: BorderSide(color: _tagColor(t.colorHex).withValues(alpha: 0.75)),
                              shape: const StadiumBorder(),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'paid') onMarkPaid();
            if (value == 'settle') onSettleFullDebt();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (isActive && type == LedgerTxType.debt)
              const PopupMenuItem(value: 'paid', child: Text('Mark as paid')),
            const PopupMenuItem(value: 'settle', child: Text('Settle full debt')),
          ],
        ),
      ),
    );
  }
}

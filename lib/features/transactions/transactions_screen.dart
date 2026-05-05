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
import 'transaction_editor_sheet.dart';

Color _tagColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedClientId;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(allTransactionsProvider(_selectedClientId));
    final clientsAsync = ref.watch(activeClientsProvider);
    final quickAsync = ref.watch(quickAddSuggestionsProvider);
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: clientsAsync.when(
              data: (clients) => DropdownButtonFormField<String?>(
                initialValue: _selectedClientId,
                decoration: const InputDecoration(labelText: 'Client filter'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All clients'),
                  ),
                  ...clients.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.fullName),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedClientId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          quickAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    final label =
                        '${it.type == LedgerTxType.debt ? 'Add debt' : 'Add payment'} ${it.amountMinor}';
                    return ActionChip(
                      label: Text(label),
                      onPressed: () => _openEditor(
                        context,
                        defaultAmount: it.amountMinor,
                        defaultType: it.type,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: items.length,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: txAsync.when(
              data: (rows) {
                if (rows.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(color: AppTheme.mutedFg),
                    ),
                  );
                }
                final grouped = _groupByDate(rows);
                final keys = grouped.keys.toList();
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
                          child: Text(
                            key,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        ...items.map(
                          (row) => _TxCard(
                            row: row,
                            currencyCode: code,
                            tagsAsync: ref.watch(
                              transactionTagsProvider(row.transaction.id),
                            ),
                            onEdit: () =>
                                _openEditor(context, editing: row.transaction),
                            onMarkPaid: () async {
                              await ref
                                  .read(ledgerRepositoryProvider)
                                  .markDebtAsPaid(row.transaction.id);
                            },
                            onSettleFullDebt: () async {
                              await ref
                                  .read(ledgerRepositoryProvider)
                                  .settleFullDebt(row.transaction.clientId);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
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
        : (await ref.read(
            transactionTagsProvider(editing.id).future,
          )).map((e) => e.id).toList();
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius),
        ),
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
          currentBalanceMinor:
              editing?.postedBalanceBeforeMinor ?? fallbackBalance,
          onSubmit: (amountMinor, type, note, tagIds, effectiveAt) async {
            if (editing == null) {
              await ref
                  .read(ledgerRepositoryProvider)
                  .insertTransaction(
                    clientId: targetClientId!,
                    amountMinor: amountMinor,
                    type: type,
                    note: note,
                    tagIds: tagIds,
                    effectiveAt: effectiveAt,
                  );
            } else {
              await ref
                  .read(ledgerRepositoryProvider)
                  .updateTransaction(
                    id: editing.id,
                    amountMinor: amountMinor,
                    type: type,
                    note: note,
                    tagIds: tagIds,
                    effectiveAt: effectiveAt,
                  );
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _exportCsv(
    BuildContext context,
    List<LedgerTransactionWithClient> rows,
  ) async {
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
          suggestedName:
              'transactions_export_${DateTime.now().millisecondsSinceEpoch}.csv',
          acceptedTypeGroups: const [
            XTypeGroup(label: 'csv', extensions: ['csv']),
          ],
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
          const SnackBar(
            content: Text(
              'File save unavailable. Transactions CSV copied to clipboard instead.',
            ),
          ),
        );
        return;
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'clipboard'
              ? 'Transactions CSV copied to clipboard'
              : 'Transactions CSV downloaded',
        ),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  const _TxCard({
    required this.row,
    required this.currencyCode,
    required this.tagsAsync,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onSettleFullDebt,
  });

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
    final color = type == LedgerTxType.debt
        ? AppTheme.ledgerDebt
        : AppTheme.ledgerPayment;
    final isActive =
        LedgerTxStatus.fromInt(tx.txStatus) == LedgerTxStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                row.clientName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                type.name.toUpperCase(),
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
            if (tx.effectiveAt != null &&
                tx.effectiveAt!.toUtc() != tx.createdAt.toUtc())
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
                              avatar: CircleAvatar(
                                radius: 4,
                                backgroundColor: _tagColor(t.colorHex),
                              ),
                              backgroundColor: _tagColor(
                                t.colorHex,
                              ).withValues(alpha: 0.18),
                              side: BorderSide(
                                color: _tagColor(
                                  t.colorHex,
                                ).withValues(alpha: 0.75),
                              ),
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
            const PopupMenuItem(
              value: 'settle',
              child: Text('Settle full debt'),
            ),
          ],
        ),
      ),
    );
  }
}

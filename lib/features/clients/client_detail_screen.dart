import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import '../transactions/transaction_editor_sheet.dart';
import 'client_editor_sheet.dart';
import 'client_transactions_list.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientProvider(clientId));
    final txsAsync = ref.watch(clientTransactionsProvider(clientId));
    final currencyAsync = ref.watch(defaultCurrencyProvider);

    return clientAsync.when(
      data: (client) {
        if (client == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Client')),
            body: const Center(child: Text('Client not found')),
          );
        }
        final archived = client.archivedAt != null;
        final code = currencyAsync.valueOrNull ?? 'DZD';

        return Scaffold(
          appBar: AppBar(
            title: Text(client.fullName),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final repo = ref.read(ledgerRepositoryProvider);
                  switch (value) {
                    case 'edit':
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
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                          ),
                          child: ClientEditorSheet(
                            title: 'Edit client',
                            submitLabel: 'Update',
                            initialName: client.fullName,
                            initialPhone: client.phone,
                            initialNote: client.note,
                            onSaved: (fullName, phone, note) async {
                              await repo.updateClient(
                                id: client.id,
                                fullName: fullName,
                                phone: phone,
                                note: note,
                              );
                              if (context.mounted) Navigator.pop(ctx);
                            },
                          ),
                        ),
                      );
                    case 'archive':
                      await repo.setClientArchived(client.id, true);
                      if (context.mounted) context.pop();
                    case 'restore':
                      await repo.setClientArchived(client.id, false);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!archived)
                    const PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive'),
                    ),
                  if (archived)
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('Restore'),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: balanceColor(
                        client.balanceMinor,
                      ).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: balanceColor(
                                client.balanceMinor,
                              ).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              balanceSemanticsLine(client.balanceMinor),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: balanceColor(client.balanceMinor),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        MoneyFormat.formatMinor(client.balanceMinor, code),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: balanceColor(client.balanceMinor),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppTheme.mutedFg,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Added ${MoneyFormat.formatDate(client.createdAt)}',
                            style: TextStyle(color: AppTheme.mutedFg),
                          ),
                        ],
                      ),
                      if (client.phone != null && client.phone!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: AppTheme.mutedFg,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                client.phone!,
                                style: TextStyle(color: AppTheme.mutedFg),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (client.note != null && client.note!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          client.note!,
                          style: TextStyle(
                            color: AppTheme.mutedFg,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.mutedFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    txsAsync.when(
                      data: (txs) {
                        final lastActivity = txs.isNotEmpty
                            ? ' • Last: ${MoneyFormat.formatDate(txs.first.createdAt)}'
                            : '';
                        return Text(
                          '(${txs.length})$lastActivity',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppTheme.mutedFg),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: txsAsync.when(
                  data: (txs) {
                    return ClientTransactionsList(
                      transactions: txs,
                      currencyCode: code,
                      onEditActive: (t) => _openEditTx(context, ref, t),
                      onCancelActive: (id) => _confirmCancel(context, ref, id),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: archived ? null : AppTheme.ledgerPayment,
            foregroundColor: archived ? null : Colors.black87,
            onPressed: archived
                ? null
                : () async {
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
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                        ),
                        child: TransactionEditorSheet(
                          title: 'New transaction',
                          currencyCode: code,
                          onSubmit: (amountMinor, type, note) async {
                            await ref
                                .read(ledgerRepositoryProvider)
                                .insertTransaction(
                                  clientId: client.id,
                                  amountMinor: amountMinor,
                                  type: type,
                                  currencyCode: code,
                                  note: note,
                                );
                            if (context.mounted) Navigator.pop(ctx);
                          },
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Transaction'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _openEditTx(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction t,
  ) async {
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
          title: 'Edit transaction',
          currencyCode: t.currencyCode,
          initialAmountMinor: t.amountMinor,
          initialType: LedgerTxType.fromInt(t.txType),
          initialNote: t.note,
          onSubmit: (amountMinor, type, note) async {
            await ref
                .read(ledgerRepositoryProvider)
                .updateTransaction(
                  id: t.id,
                  amountMinor: amountMinor,
                  type: type,
                  note: note,
                );
            if (context.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    String txId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel transaction?'),
        content: const Text(
          'It will stay in the list as cancelled and no longer affect balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ledgerCancel,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel transaction'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).cancelTransaction(txId);
    }
  }
}

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
                          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
                        ),
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
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
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  if (archived)
                    const PopupMenuItem(value: 'restore', child: Text('Restore')),
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balanceSemanticsLine(client.balanceMinor),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: balanceColor(client.balanceMinor),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormat.formatMinor(client.balanceMinor, code),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: balanceColor(client.balanceMinor),
                          ),
                    ),
                    if (client.phone != null && client.phone!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 18, color: AppTheme.mutedFg),
                          const SizedBox(width: 8),
                          Text(client.phone!, style: TextStyle(color: AppTheme.mutedFg)),
                        ],
                      ),
                    ],
                    if (client.note != null && client.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(client.note!, style: TextStyle(color: AppTheme.mutedFg)),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.mutedFg),
                ),
              ),
              Expanded(
                child: txsAsync.when(
                  data: (txs) {
                    if (txs.isEmpty) {
                      return Center(
                        child: Text(
                          'No transactions yet.',
                          style: TextStyle(color: AppTheme.mutedFg),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: txs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final t = txs[i];
                        return _TransactionTile(
                          tx: t,
                          currencyCode: code,
                          onTap:
                              t.txStatus == LedgerTxStatus.active.index
                                  ? () => _openEditTx(context, ref, t)
                                  : null,
                          onCancel:
                              t.txStatus == LedgerTxStatus.active.index
                                  ? () => _confirmCancel(context, ref, t.id)
                                  : null,
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: archived
                ? null
                : () async {
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
                          title: 'New transaction',
                          currencyCode: code,
                          onSubmit: (amountMinor, type, note) async {
                            await ref.read(ledgerRepositoryProvider).insertTransaction(
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

  Future<void> _openEditTx(BuildContext context, WidgetRef ref, LedgerTransaction t) async {
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
          title: 'Edit transaction',
          currencyCode: t.currencyCode,
          initialAmountMinor: t.amountMinor,
          initialType: LedgerTxType.fromInt(t.txType),
          initialNote: t.note,
          onSubmit: (amountMinor, type, note) async {
            await ref.read(ledgerRepositoryProvider).updateTransaction(
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

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, String txId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel transaction?'),
        content: const Text('It will stay in the list as cancelled and no longer affect balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel tx')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).cancelTransaction(txId);
    }
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
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
    final typeLabel = type == LedgerTxType.debt ? 'Debt' : 'Payment';
    final amountLabel = MoneyFormat.formatMinor(tx.amountMinor, currencyCode);

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          '$typeLabel · $amountLabel',
          style: TextStyle(
            color: active ? null : AppTheme.mutedFg,
            decoration: active ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posted: ${MoneyFormat.formatMinor(tx.postedBalanceBeforeMinor, currencyCode)} → ${MoneyFormat.formatMinor(tx.postedBalanceAfterMinor, currencyCode)}',
              style: TextStyle(fontSize: 12, color: AppTheme.mutedFg.withValues(alpha: 0.9)),
            ),
            if (!active &&
                tx.cancelBalanceBeforeMinor != null &&
                tx.cancelBalanceAfterMinor != null)
              Text(
                'Cancel: ${MoneyFormat.formatMinor(tx.cancelBalanceBeforeMinor!, currencyCode)} → ${MoneyFormat.formatMinor(tx.cancelBalanceAfterMinor!, currencyCode)}',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedFg.withValues(alpha: 0.9)),
              ),
            if (tx.note != null && tx.note!.isNotEmpty) Text(tx.note!),
          ],
        ),
        trailing: active
            ? IconButton(
                icon: const Icon(Icons.cancel_outlined),
                tooltip: 'Cancel',
                onPressed: onCancel,
              )
            : Icon(Icons.do_not_disturb_on_outlined, color: AppTheme.mutedFg.withValues(alpha: 0.8)),
      ),
    );
  }
}

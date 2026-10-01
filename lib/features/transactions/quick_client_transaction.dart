import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import 'transaction_editor_sheet.dart';

/// Pick a client (unless given), then add a debt/payment for them.
Future<void> openQuickClientTransaction(
  BuildContext context,
  WidgetRef ref, {
  Client? client,
}) async {
  final target = client ?? await _pickClient(context, ref);
  if (target == null || !context.mounted) return;

  final repo = ref.read(ledgerRepositoryProvider);
  final code = await ref.read(defaultCurrencyProvider.future);
  final txTags = await ref.read(transactionScopeTagsProvider.future);
  final foreign = await repo.foreignCurrencyEditorContext();
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
        title: target.fullName,
        currencyCode: code,
        currentBalanceMinor: target.balanceMinor,
        availableTags: txTags,
        foreignCurrencyCodes: foreign.codes,
        foreignRates: foreign.rates,
        onSubmit: (amount, type, note, tagIds, effectiveAt, dueAt, [fromCurrency]) async {
          await repo.insertTransaction(
            clientId: target.id,
            amountMinor: amount,
            type: type,
            note: note,
            tagIds: tagIds,
            effectiveAt: effectiveAt,
            dueAt: dueAt,
            fromCurrency: fromCurrency,
          );
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    ),
  );
}

Future<Client?> _pickClient(BuildContext context, WidgetRef ref) async {
  final clients = await ref.read(activeClientsProvider.future);
  final code = await ref.read(defaultCurrencyProvider.future);
  if (!context.mounted) return null;
  if (clients.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add a client first (Clients tab).')),
    );
    return null;
  }
  return showModalBottomSheet<Client>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    builder: (ctx) => _ClientPicker(clients: clients, currencyCode: code),
  );
}

class _ClientPicker extends StatefulWidget {
  const _ClientPicker({required this.clients, required this.currencyCode});

  final List<Client> clients;
  final String currencyCode;

  @override
  State<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends State<_ClientPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = widget.clients
        .where((c) =>
            q.isEmpty ||
            c.fullName.toLowerCase().contains(q) ||
            (c.phone?.toLowerCase().contains(q) ?? false))
        .toList()
      ..sort((a, b) => (b.lastInteractionAt ?? b.createdAt)
          .compareTo(a.lastInteractionAt ?? a.createdAt));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search client…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: shown.length,
              itemBuilder: (ctx, i) {
                final c = shown[i];
                return ListTile(
                  title: Text(c.fullName),
                  subtitle: Text(balanceSemanticsLine(c.balanceMinor)),
                  trailing: Text(
                    MoneyFormat.formatMinor(c.balanceMinor.abs(), widget.currencyCode),
                    style: TextStyle(
                      color: balanceColor(c.balanceMinor),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

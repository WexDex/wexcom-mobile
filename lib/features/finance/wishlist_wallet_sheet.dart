import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

/// After marking wishlist purchased + expense logged, optionally deduct wallets.
Future<void> showWishlistWalletSheet({
  required BuildContext context,
  required WidgetRef ref,
  required WishlistItem item,
}) async {
  final repo = ref.read(ledgerRepositoryProvider);
  final accounts = await ref.read(walletAccountsProvider.future);
  final matching =
      accounts.where((a) => a.currencyCode == item.currencyCode).toList();

  if (!context.mounted) return;

  if (matching.isEmpty) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No matching wallets'),
        content: Text(
          'No wallet accounts in ${item.currencyCode}. '
          'Expense was logged; wallet balances unchanged.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final selected = <String>{};
  final amountCtrls = <String, TextEditingController>{};
  final pctCtrls = <String, TextEditingController>{};
  for (final a in matching) {
    amountCtrls[a.id] = TextEditingController();
    pctCtrls[a.id] = TextEditingController();
  }

  var confirmed = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModal) {
          int allocated() {
            var sum = 0;
            for (final id in selected) {
              final m = MoneyFormat.parseMinorUnits(
                amountCtrls[id]!.text,
                fractionDigits: 0,
              );
              if (m != null) sum += m;
            }
            return sum;
          }

          void splitEqual() {
            if (selected.isEmpty) return;
            final each = item.amountMinor ~/ selected.length;
            var rem = item.amountMinor - each * selected.length;
            for (final id in selected) {
              final extra = rem > 0 ? 1 : 0;
              if (rem > 0) rem--;
              amountCtrls[id]!.text = '${each + extra}';
            }
            setModal(() {});
          }

          void splitPercent() {
            if (selected.isEmpty) return;
            var totalPct = 0.0;
            for (final id in selected) {
              totalPct += double.tryParse(pctCtrls[id]!.text) ?? 0;
            }
            if (totalPct <= 0) return;
            for (final id in selected) {
              final pct = double.tryParse(pctCtrls[id]!.text) ?? 0;
              amountCtrls[id]!.text =
                  '${(item.amountMinor * pct / totalPct).round()}';
            }
            setModal(() {});
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              left: 20,
              right: 20,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Deduct from wallet',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                Text(
                  '${item.title} · ${MoneyFormat.formatMinor(item.amountMinor, item.currencyCode)}',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedFg,
                      ),
                ),
                const SizedBox(height: 12),
                ...matching.map((a) {
                  final isSel = selected.contains(a.id);
                  final before = a.balanceMinor;
                  final amt = MoneyFormat.parseMinorUnits(
                        amountCtrls[a.id]!.text,
                        fractionDigits: 0,
                      ) ??
                      0;
                  final after = before - amt;
                  return Card(
                    child: CheckboxListTile(
                      value: isSel,
                      onChanged: (v) => setModal(() {
                        if (v == true) {
                          selected.add(a.id);
                        } else {
                          selected.remove(a.id);
                        }
                      }),
                      title: Text('${a.emoji} ${a.name}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${MoneyFormat.formatMinor(before, a.currencyCode)} → '
                            '${MoneyFormat.formatMinor(after, a.currencyCode)}',
                          ),
                          if (isSel) ...[
                            const SizedBox(height: 6),
                            TextField(
                              controller: amountCtrls[a.id],
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModal(() {}),
                            ),
                            TextField(
                              controller: pctCtrls[a.id],
                              decoration: const InputDecoration(
                                labelText: '% share',
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                Row(
                  children: [
                    TextButton(onPressed: splitEqual, child: const Text('Split equal')),
                    TextButton(onPressed: splitPercent, child: const Text('Apply %')),
                  ],
                ),
                Text(
                  'Allocated: ${MoneyFormat.formatMinor(allocated(), item.currencyCode)} / '
                  '${MoneyFormat.formatMinor(item.amountMinor, item.currencyCode)}',
                  style: TextStyle(
                    color: allocated() == item.amountMinor
                        ? AppTheme.balanceReceivable
                        : AppTheme.ledgerDebt,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    confirmed = false;
                    Navigator.pop(ctx);
                  },
                  child: const Text("Don't adjust wallets"),
                ),
                FilledButton(
                  onPressed: allocated() == item.amountMinor && selected.isNotEmpty
                      ? () {
                          confirmed = true;
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: const Text('Confirm deduction'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );

  if (!confirmed) return;

  for (final id in selected) {
    final m = MoneyFormat.parseMinorUnits(amountCtrls[id]!.text, fractionDigits: 0);
    if (m == null || m <= 0) continue;
    await repo.adjustWalletDelta(
      id,
      -m,
      source: 'wishlist',
      referenceId: item.id,
      note: item.title,
    );
  }

  for (final c in amountCtrls.values) {
    c.dispose();
  }
  for (final c in pctCtrls.values) {
    c.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import 'finance_period.dart';

class WalletAccountHistoryScreen extends ConsumerStatefulWidget {
  const WalletAccountHistoryScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<WalletAccountHistoryScreen> createState() =>
      _WalletAccountHistoryScreenState();
}

class _WalletAccountHistoryScreenState extends ConsumerState<WalletAccountHistoryScreen> {
  FinancePeriod _period = FinancePeriod.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(walletAccountsProvider).valueOrNull ?? [];
    final account = accounts.where((a) => a.id == widget.accountId).firstOrNull;
    final ledgerAsync = ref.watch(walletLedgerProvider(widget.accountId));

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account history')),
        body: const Center(child: Text('Account not found')),
      );
    }

    final range = financePeriodRange(
      _period,
      customStart: _customStart,
      customEnd: _customEnd,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${account.emoji} ${account.name}'),
            Text(
              MoneyFormat.formatMinor(account.balanceMinor, account.currencyCode),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in FinancePeriod.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(financePeriodLabel(
                          p,
                          customStart: _customStart,
                          customEnd: _customEnd,
                        )),
                        selected: _period == p,
                        onSelected: (_) async {
                          if (p == FinancePeriod.custom) {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null && mounted) {
                              setState(() {
                                _period = p;
                                _customStart = picked.start;
                                _customEnd = DateTime(
                                  picked.end.year,
                                  picked.end.month,
                                  picked.end.day,
                                  23,
                                  59,
                                  59,
                                );
                              });
                            }
                          } else {
                            setState(() {
                              _period = p;
                              _customStart = null;
                              _customEnd = null;
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ledgerAsync.when(
              data: (rows) {
                final filtered = rows.where((e) {
                  return dateInFinanceRange(e.createdAt, range.start, range.end);
                }).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No history in this period'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = filtered[i];
                    final op = e.opType;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        op == 'increase'
                            ? Icons.add_circle_outline
                            : op == 'decrease'
                                ? Icons.remove_circle_outline
                                : Icons.swap_horiz,
                      ),
                      title: Text(
                        '${e.source} · ${MoneyFormat.formatMinor(e.amountMinor, account.currencyCode)}',
                      ),
                      subtitle: Text(
                        '${MoneyFormat.formatMinor(e.balanceBeforeMinor, account.currencyCode)} → '
                        '${MoneyFormat.formatMinor(e.balanceAfterMinor, account.currencyCode)}'
                        '${e.note != null && e.note!.isNotEmpty ? ' · ${e.note}' : ''}',
                      ),
                      trailing: Text(
                        DateFormat.MMMd().add_jm().format(e.createdAt.toLocal()),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

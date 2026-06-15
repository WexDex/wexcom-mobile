import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../services/home_widget_service.dart';

class HomeExchangeRatesCard extends ConsumerWidget {
  const HomeExchangeRatesCard({super.key, required this.defaultCode});

  final String defaultCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesAsync = ref.watch(managedCurrenciesProvider);
    final currencies = currenciesAsync.valueOrNull ?? [];
    final foreign =
        currencies.where((c) => c.code != defaultCode).toList();
    if (foreign.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exchange rates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...foreign.map((c) => _RateRow(currency: c, defaultCode: defaultCode)),
          ],
        ),
      ),
    );
  }
}

class _RateRow extends ConsumerStatefulWidget {
  const _RateRow({required this.currency, required this.defaultCode});

  final ManagedCurrency currency;
  final String defaultCode;

  @override
  ConsumerState<_RateRow> createState() => _RateRowState();
}

class _RateRowState extends ConsumerState<_RateRow> {
  late final TextEditingController _rateCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rateAsync = ref.watch(currentRateProvider(widget.currency.code));
    final rate = rateAsync.valueOrNull;
    if (rate != null && _rateCtrl.text.isEmpty) {
      _rateCtrl.text = rate == rate.roundToDouble() ? '${rate.toInt()}' : '$rate';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(widget.currency.code, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: TextField(
              controller: _rateCtrl,
              decoration: InputDecoration(
                isDense: true,
                labelText: '1 ${widget.currency.code} =',
                suffixText: widget.defaultCode,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              final parsed = num.tryParse(_rateCtrl.text.trim());
              if (parsed == null || parsed <= 0) return;
              await ref.read(ledgerRepositoryProvider).setExchangeRate(
                    currencyCode: widget.currency.code,
                    rate: parsed,
                    note: 'Updated from home',
                  );
              await HomeWidgetService.syncWidgetData(
                ref.read(ledgerRepositoryProvider),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.currency.code} rate updated')),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

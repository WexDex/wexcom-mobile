import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/exchange_rate.dart';
import '../../widgets/rate_history_chart.dart';

class TagEditorScreen extends ConsumerStatefulWidget {
  const TagEditorScreen({super.key});

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  String _scope = 'client';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final seg = GoRouterState.of(context).uri.queryParameters['segment'];
      if (seg == 'currencies') setState(() => _scope = 'currencies');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = _scope == 'client'
        ? ref.watch(clientScopeTagsProvider)
        : _scope == 'transaction'
            ? ref.watch(transactionScopeTagsProvider)
            : null;
    final defaultCode = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';

    return Scaffold(
      appBar: AppBar(
        title: Text(_scope == 'currencies' ? 'Currencies' : 'Tag editor'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: _scope == 'currencies'
          ? FloatingActionButton(
              onPressed: () => _addCurrencyDialog(context, defaultCode),
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () => _openTagDialog(context),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'client', label: Text('Client tags')),
                ButtonSegment(
                  value: 'transaction',
                  label: Text('Transaction tags'),
                ),
                ButtonSegment(value: 'currencies', label: Text('Currencies')),
              ],
              selected: {_scope},
              onSelectionChanged: (value) =>
                  setState(() => _scope = value.first),
            ),
          ),
          Expanded(
            child: _scope == 'currencies'
                ? _buildCurrenciesBody(defaultCode)
                : tagsAsync!.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return Center(
                    child: Text(
                      'No tags yet',
                      style: TextStyle(color: AppTheme.mutedFg),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tag = tags[i];
                    final color = _parseTagColor(tag.colorHex);
                    return ListTile(
                      tileColor: color.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: color.withValues(alpha: 0.45)),
                      ),
                      title: Text(tag.name),
                      subtitle: Text(tag.scope),
                      leading: CircleAvatar(backgroundColor: color, radius: 10),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openTagDialog(context, tag: tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(ledgerRepositoryProvider)
                                  .deleteTag(tag.id);
                            },
                          ),
                        ],
                      ),
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
    );
  }

  Widget _buildCurrenciesBody(String defaultCode) {
    final currenciesAsync = ref.watch(managedCurrenciesProvider);
    return currenciesAsync.when(
      data: (list) => ListView(
        padding: const EdgeInsets.all(16),
        children: list.map((c) {
          final isDefault = c.code == defaultCode;
          return Card(
            child: ExpansionTile(
              title: Text(c.code),
              subtitle: Text(isDefault
                  ? 'Base currency (1.0)'
                  : 'Tap to view rate history'),
              children: [
                if (!isDefault)
                  _RateHistoryList(currencyCode: c.code, defaultCode: defaultCode),
              ],
            ),
          );
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _addCurrencyDialog(BuildContext context, String defaultCode) async {
    final codeCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final digitsCtrl = TextEditingController(text: '2');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'ISO code (e.g. USD)'),
              textCapitalization: TextCapitalization.characters,
            ),
            TextField(
              controller: rateCtrl,
              decoration: InputDecoration(labelText: '1 unit = ? $defaultCode'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: digitsCtrl,
              decoration: const InputDecoration(labelText: 'Decimal places'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final rate = num.tryParse(rateCtrl.text.trim());
              final digits = int.tryParse(digitsCtrl.text.trim()) ?? 2;
              if (code.isEmpty || rate == null || rate <= 0) return;
              await ref.read(ledgerRepositoryProvider).addManagedCurrency(
                    code: code,
                    fractionDigits: digits,
                    initialRateToDefault: rate,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTagDialog(BuildContext context, {Tag? tag}) async {
    final name = TextEditingController(text: tag?.name ?? '');
    var colorHex = tag?.colorHex ?? '#4F46E5';
    final colors = <String>[
      '#EF4444',
      '#F97316',
      '#EAB308',
      '#22C55E',
      '#14B8A6',
      '#0EA5E9',
      '#6366F1',
      '#A855F7',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tag == null ? 'New tag' : 'Edit tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Tag name'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((hex) {
                    final selected = hex == colorHex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => colorHex = hex),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _parseTagColor(hex),
                          border: Border.all(
                            width: selected ? 3 : 1,
                            color: selected ? Colors.white : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final trimmed = name.text.trim();
                if (trimmed.isEmpty) return;
                final repo = ref.read(ledgerRepositoryProvider);
                if (tag == null) {
                  await repo.createTag(
                    name: trimmed,
                    colorHex: colorHex,
                    scope: _scope,
                  );
                } else {
                  await repo.updateTag(
                    id: tag.id,
                    name: trimmed,
                    colorHex: colorHex,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateHistoryList extends ConsumerWidget {
  const _RateHistoryList({
    required this.currencyCode,
    required this.defaultCode,
  });

  final String currencyCode;
  final String defaultCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      rateHistoryProvider(currencyCode),
    );
    return historyAsync.when(
      data: (rows) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (rows.length >= 2) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RateHistoryChart(rows: rows),
            ),
          ],
          ...rows.map(
                (r) => ListTile(
                  dense: true,
                  title: Text(
                    '1 $currencyCode = ${rateFromStored(r.rateToDefault, r.rateScale)} $defaultCode',
                  ),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(r.recordedAt.toLocal())),
                ),
              ),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('$e'),
    );
  }
}

Color _parseTagColor(String hex) {
  final clean = hex.replaceAll('#', '');
  if (clean.length != 6) return AppTheme.receivableAccent;
  final parsed = int.tryParse(clean, radix: 16);
  if (parsed == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | parsed);
}

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/db/app_database.dart';
import '../../../data/ledger_repository.dart';
import '../../../data/ledger_types.dart';
import '../../../providers/providers.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/money.dart';
import '../personal_finance_editor.dart';
import 'bulk_import_models.dart';
import 'bulk_import_syntax_panel.dart';
import 'finance_bulk_line_parser.dart';

class FinanceBulkImportScreen extends ConsumerStatefulWidget {
  const FinanceBulkImportScreen({super.key});

  @override
  ConsumerState<FinanceBulkImportScreen> createState() => _FinanceBulkImportScreenState();
}

class _FinanceBulkImportScreenState extends ConsumerState<FinanceBulkImportScreen> {
  final _textCtrl = TextEditingController();
  var _previewing = false;
  List<BulkImportDraftLine> _drafts = const [];
  var _committing = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'text', extensions: ['txt', 'text']),
        ],
      );
      if (file == null) return;
      final raw = await file.readAsString();
      if (!mounted) return;
      if (_textCtrl.text.trim().isNotEmpty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Replace or append?'),
            content: const Text('The text field already has content.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, 'append'), child: const Text('Append')),
              FilledButton(onPressed: () => Navigator.pop(ctx, 'replace'), child: const Text('Replace')),
            ],
          ),
        );
        if (choice == null || choice == 'cancel') return;
        if (choice == 'append') {
          _textCtrl.text = '${_textCtrl.text.trim()}\n$raw';
        } else {
          _textCtrl.text = raw;
        }
      } else {
        _textCtrl.text = raw;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file. Paste text instead.')),
      );
    }
  }

  void _runPreview() {
    final expenses = ref.read(expenseCategoriesProvider('expense')).valueOrNull ?? [];
    final gains = ref.read(expenseCategoriesProvider('gain')).valueOrNull ?? [];
    final clients = ref.read(activeClientsProvider).valueOrNull ?? [];
    final wallets = ref.read(walletAccountsProvider).valueOrNull ?? [];

    final drafts = parseBulkImportText(
      text: _textCtrl.text,
      expenseCategories: expenses,
      gainCategories: gains,
      clients: clients,
      walletAccounts: wallets,
    );

    if (drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lines to import. Add text or check comments.')),
      );
      return;
    }

    setState(() {
      _drafts = drafts;
      _previewing = true;
    });
  }

  Future<void> _commit() async {
    final errors = _drafts.where((d) => !d.canCommit).length;
    if (errors > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fix or remove $errors row(s) before saving.')),
      );
      return;
    }

    final counts = _countByTarget(_drafts);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save all entries?'),
        content: Text(
          'Expenses: ${counts.expenses}\n'
          'Gains: ${counts.gains}\n'
          'Client debts: ${counts.debts}\n'
          'Client payments: ${counts.payments}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _committing = true);
    final repo = ref.read(ledgerRepositoryProvider);
    final currency = await ref.read(defaultCurrencyProvider.future);

    var saved = 0;
  try {
      for (final row in _drafts) {
        if (!row.canCommit) continue;
        if (row.isPersonal) {
          await repo.addPersonalFinanceEntry(
            kind: personalKindFor(row.target),
            title: row.title,
            amountMinor: row.amountMinor,
            currencyCode: currency,
            categoryId: row.categoryId,
            accountId: row.accountId,
            createdAt: personalFinanceCreatedAtUtcForSave(dayLocal: row.dayLocal),
          );
        } else {
          if (row.clientId == null) continue;
          await repo.insertTransaction(
            clientId: row.clientId!,
            amountMinor: row.amountMinor,
            type: ledgerTypeFor(row.target),
            note: row.title,
            createdBy: 'bulk_import',
            effectiveAt: DateTime(
              row.dayLocal.year,
              row.dayLocal.month,
              row.dayLocal.day,
            ).toUtc(),
          );
        }
        saved += 1;
      }
    } finally {
      if (mounted) setState(() => _committing = false);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved $saved entries')),
    );
    Navigator.pop(context);
  }

  ({int expenses, int gains, int debts, int payments}) _countByTarget(List<BulkImportDraftLine> rows) {
    var expenses = 0, gains = 0, debts = 0, payments = 0;
    for (final r in rows) {
      switch (r.target) {
        case BulkImportTarget.personalExpense:
          expenses++;
        case BulkImportTarget.personalGain:
          gains++;
        case BulkImportTarget.clientDebt:
          debts++;
        case BulkImportTarget.clientPayment:
          payments++;
      }
    }
    return (expenses: expenses, gains: gains, debts: debts, payments: payments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_previewing ? 'Review import' : 'Import from text'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_previewing) {
              setState(() => _previewing = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _previewing ? _buildPreviewBody() : _buildComposeBody(),
    );
  }

  Widget _buildComposeBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        TextField(
          controller: _textCtrl,
          maxLines: 14,
          decoration: const InputDecoration(
            hintText: bulkImportComposeHint,
            hintStyle: TextStyle(color: AppTheme.mutedFg, fontSize: 12, height: 1.35),
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _loadFile,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Load file'),
            ),
            OutlinedButton(
              onPressed: () => _textCtrl.clear(),
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: _runPreview,
              child: const Text('Preview'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Syntax help',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            children: const [
              BulkImportSyntaxPanel(showPreviews: true, showFullSyntax: true, dense: true),
              SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewBody() {
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final clients = ref.watch(activeClientsProvider).valueOrNull ?? [];
    final expenseCats = ref.watch(expenseCategoriesProvider('expense')).valueOrNull ?? [];
    final gainCats = ref.watch(expenseCategoriesProvider('gain')).valueOrNull ?? [];
    final wallets = ref.watch(walletAccountsProvider).valueOrNull ?? [];
    final hasErrors = _drafts.any((d) => !d.canCommit);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _drafts.length,
            itemBuilder: (context, index) {
              return _DraftRowCard(
                row: _drafts[index],
                currencyCode: code,
                clients: clients,
                expenseCategories: expenseCats,
                gainCategories: gainCats,
                wallets: wallets,
                onChanged: (next) => setState(() => _drafts[index] = next),
                onRemove: () => setState(() => _drafts = List.of(_drafts)..removeAt(index)),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: FilledButton(
            onPressed: hasErrors || _committing ? null : _commit,
            child: _committing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save all'),
          ),
        ),
      ],
    );
  }
}

class _DraftRowCard extends StatelessWidget {
  const _DraftRowCard({
    required this.row,
    required this.currencyCode,
    required this.clients,
    required this.expenseCategories,
    required this.gainCategories,
    required this.wallets,
    required this.onChanged,
    required this.onRemove,
  });

  final BulkImportDraftLine row;
  final String currencyCode;
  final List<Client> clients;
  final List<ExpenseCategory> expenseCategories;
  final List<ExpenseCategory> gainCategories;
  final List<WalletAccount> wallets;
  final ValueChanged<BulkImportDraftLine> onChanged;
  final VoidCallback onRemove;

  IconData _statusIcon(BulkImportParseStatus s) => switch (s) {
        BulkImportParseStatus.ok => Icons.check_circle_outline,
        BulkImportParseStatus.warning => Icons.warning_amber_rounded,
        BulkImportParseStatus.error => Icons.error_outline,
      };

  Color _statusColor(BulkImportParseStatus s) => switch (s) {
        BulkImportParseStatus.ok => AppTheme.balanceReceivable,
        BulkImportParseStatus.warning => AppTheme.brandSecondary,
        BulkImportParseStatus.error => AppTheme.ledgerDebt,
      };

  String _summary(BulkImportDraftLine r) {
    final date = DateFormat.MMMd().format(r.dayLocal);
    final amount = MoneyFormat.formatMinor(r.amountMinor, currencyCode, fractionDigits: 0);
    return switch (r.target) {
      BulkImportTarget.personalExpense => 'Expense · ${r.title} · $amount · $date',
      BulkImportTarget.personalGain => 'Gain · ${r.title} · $amount · $date',
      BulkImportTarget.clientDebt => 'Client debt · ${r.clientNameHint ?? "?"} · $amount',
      BulkImportTarget.clientPayment => 'Client payment · ${r.clientNameHint ?? "?"} · $amount',
    };
  }

  BulkImportParseStatus _recomputeStatus(BulkImportDraftLine r) {
    if (r.amountMinor <= 0) return BulkImportParseStatus.error;
    if (r.isClient && r.clientId == null) return BulkImportParseStatus.error;
    if (r.messages.isNotEmpty && r.status == BulkImportParseStatus.error) {
      return BulkImportParseStatus.error;
    }
    if (r.messages.isNotEmpty) return BulkImportParseStatus.warning;
    return BulkImportParseStatus.ok;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(_statusIcon(row.status), color: _statusColor(row.status)),
          title: Text(
            'Line ${row.sourceLineNumber}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.rawLine.trim(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
              const SizedBox(height: 4),
              Text(_summary(row), style: const TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
              if (row.messages.isNotEmpty)
                Text(
                  row.messages.join(' · '),
                  style: TextStyle(color: _statusColor(row.status), fontSize: 11),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.ledgerDebt),
            onPressed: onRemove,
          ),
          children: [
            if (row.isClient) ...[
              DropdownButtonFormField<String>(
                initialValue: row.clientId,
                decoration: const InputDecoration(labelText: 'Client'),
                items: clients
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)))
                    .toList(),
                onChanged: (id) {
                  final c = clients.where((x) => x.id == id).firstOrNull;
                  onChanged(
                    row.copyWith(
                      clientId: id,
                      clientNameHint: c?.fullName,
                      clearClient: id == null,
                      status: id != null ? BulkImportParseStatus.ok : BulkImportParseStatus.error,
                      messages: id != null ? const [] : row.messages,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              SegmentedButton<BulkImportTarget>(
                segments: const [
                  ButtonSegment(value: BulkImportTarget.clientDebt, label: Text('Debt')),
                  ButtonSegment(value: BulkImportTarget.clientPayment, label: Text('Payment')),
                ],
                selected: {
                  row.target == BulkImportTarget.clientPayment
                      ? BulkImportTarget.clientPayment
                      : BulkImportTarget.clientDebt,
                },
                onSelectionChanged: (s) => onChanged(row.copyWith(target: s.first)),
              ),
            ] else ...[
              SegmentedButton<BulkImportTarget>(
                segments: const [
                  ButtonSegment(value: BulkImportTarget.personalExpense, label: Text('Expense')),
                  ButtonSegment(value: BulkImportTarget.personalGain, label: Text('Gain')),
                ],
                selected: {
                  row.target == BulkImportTarget.personalGain
                      ? BulkImportTarget.personalGain
                      : BulkImportTarget.personalExpense,
                },
                onSelectionChanged: (s) => onChanged(row.copyWith(target: s.first)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: row.categoryId,
                decoration: const InputDecoration(labelText: 'Category (optional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...(row.target == BulkImportTarget.personalGain ? gainCategories : expenseCategories)
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (id) => onChanged(row.copyWith(categoryId: id, clearCategory: id == null)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: row.accountId,
                decoration: const InputDecoration(labelText: 'Wallet account'),
                items: wallets
                    .map((w) => DropdownMenuItem(value: w.id, child: Text('${w.emoji} ${w.name}')))
                    .toList(),
                onChanged: (id) {
                  if (id != null) onChanged(row.copyWith(accountId: id));
                },
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              initialValue: row.title,
              decoration: InputDecoration(
                labelText: row.isClient ? 'Note' : 'Title',
              ),
              onChanged: (v) => onChanged(row.copyWith(title: v)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '${row.amountMinor}',
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final minor = MoneyFormat.parseMinorUnits(v, fractionDigits: 0) ?? 0;
                final next = row.copyWith(amountMinor: minor);
                onChanged(next.copyWith(status: _recomputeStatus(next)));
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(DateFormat.yMMMd().format(row.dayLocal)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: row.dayLocal,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) onChanged(row.copyWith(dayLocal: picked));
              },
            ),
          ],
        ),
      ),
    );
  }
}
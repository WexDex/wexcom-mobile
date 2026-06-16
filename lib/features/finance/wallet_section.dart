import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/currency_amount_input.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared wallet summary widgets (Finance → Wallet tab)
// ─────────────────────────────────────────────────────────────────────────────

class WalletNetWorthCard extends ConsumerWidget {
  const WalletNetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorthAsync = ref.watch(netWorthProvider);
    final accounts = ref.watch(walletAccountsProvider).valueOrNull ?? [];
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final text = Theme.of(context).textTheme;
    final netWorth = netWorthAsync.valueOrNull;

    if (accounts.isEmpty || netWorth == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.savings_outlined, color: AppTheme.brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Net worth', style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
                  Text(
                    MoneyFormat.formatMinor(netWorth, code),
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: netWorth >= 0 ? AppTheme.balanceReceivable : AppTheme.ledgerDebt,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${accounts.length} account${accounts.length == 1 ? '' : 's'}',
              style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletSavingsGoalsSection extends ConsumerWidget {
  const WalletSavingsGoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final text = Theme.of(context).textTheme;

    return goalsAsync.when(
      data: (goals) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Savings goals',
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add goal'),
                  onPressed: () => openGoalEditor(context, ref, null),
                ),
              ],
            ),
            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'No savings goals yet.',
                  style: text.bodySmall?.copyWith(color: AppTheme.mutedFg),
                ),
              )
            else
              ...goals.map((g) => _GoalTile(goal: g, code: code)),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Text('Goals error: $e'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full wallet management bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

Future<void> openWalletManager(BuildContext context, WidgetRef ref, String code) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => _WalletManagerSheet(
        scrollController: scrollCtrl,
        code: code,
      ),
    ),
  );
}

class _WalletManagerSheet extends ConsumerWidget {
  const _WalletManagerSheet({
    required this.scrollController,
    required this.code,
  });

  final ScrollController scrollController;
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(walletAccountsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);
    final text = Theme.of(context).textTheme;
    final accounts = accountsAsync.valueOrNull ?? [];
    final netWorth = netWorthAsync.valueOrNull;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text('My Wallet',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (netWorth != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Net Worth', style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
                  Text(
                    MoneyFormat.formatMinor(netWorth, code),
                    style: text.titleMedium?.copyWith(
                      color: netWorth >= 0 ? AppTheme.balanceReceivable : AppTheme.ledgerDebt,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Accounts ────────────────────────────────────────────────────
        Row(
          children: [
            Text('Accounts', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              onPressed: () => _openAccountEditor(context, ref, null, code),
            ),
          ],
        ),
        ...accounts.map((a) => _AccountTile(account: a, code: code)),
        const Divider(height: 28),
        const WalletSavingsGoalsSection(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account tile
// ─────────────────────────────────────────────────────────────────────────────

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account, required this.code});

  final WalletAccount account;
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(account.emoji, style: const TextStyle(fontSize: 24)),
      title: Text(account.name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        MoneyFormat.formatMinor(account.balanceMinor, account.currencyCode),
        style: TextStyle(
          color: AppTheme.receivableAccent,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit account',
            onPressed: () => _openAccountEditor(context, ref, account, code),
          ),
          IconButton(
            icon: const Icon(Icons.payments_outlined, size: 18),
            tooltip: 'Adjust balance',
            onPressed: () => _editBalance(context, ref, account, account.currencyCode),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.ledgerDebt),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete "${account.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await ref.read(ledgerRepositoryProvider).deleteWalletAccount(account.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Savings goal tile
// ─────────────────────────────────────────────────────────────────────────────

class _GoalTile extends ConsumerWidget {
  const _GoalTile({required this.goal, required this.code});

  final SavingsGoal goal;
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final pct = goal.targetMinor > 0
        ? (goal.savedMinor / goal.targetMinor).clamp(0.0, 1.0)
        : 0.0;
    final barColor = goal.isCompleted
        ? AppTheme.balanceReceivable
        : pct >= 0.8
            ? AppTheme.ledgerCancel
            : AppTheme.receivableAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.inputFill.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: barColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.name,
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: barColor, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                // Add to goal
                if (!goal.isCompleted)
                  SizedBox(
                    height: 28,
                    child: FilledButton.tonal(
                      onPressed: () => _addToGoal(context, ref),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('+', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                // Delete
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.mutedFg),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete "${goal.name}"?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await ref.read(ledgerRepositoryProvider).deleteSavingsGoal(goal.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 7,
                backgroundColor: barColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${MoneyFormat.formatMinor(goal.savedMinor, code)} saved',
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                ),
                const Spacer(),
                Text(
                  'goal: ${MoneyFormat.formatMinor(goal.targetMinor, code)}',
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                ),
              ],
            ),
            if (goal.isCompleted) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppTheme.balanceReceivable),
                  const SizedBox(width: 4),
                  Text('Goal reached! 🎉',
                      style: text.labelSmall?.copyWith(color: AppTheme.balanceReceivable)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addToGoal(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "${goal.name}"'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Amount to add'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final amount = int.tryParse(ctrl.text.trim()) ?? 0;
      if (amount > 0) {
        await ref.read(ledgerRepositoryProvider).addToSavingsGoal(goal.id, amount);
      }
    }
    ctrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialogs for account / goal editors
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _editBalance(
    BuildContext context, WidgetRef ref, WalletAccount account, String defaultCode) async {
  final repo = ref.read(ledgerRepositoryProvider);
  final foreign = await repo.foreignCurrencyEditorContext();
  final previewCtrl = TextEditingController(text: '${account.balanceMinor}');
  final amountKey = GlobalKey<CurrencyAmountInputState>();
  FromCurrencySnapshot? fromSnap;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${account.emoji} ${account.name}'),
      content: SingleChildScrollView(
        child: account.currencyCode == defaultCode
            ? TextField(
                controller: previewCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Balance ($defaultCode)'),
              )
            : CurrencyAmountInput(
                key: amountKey,
                defaultCurrencyCode: defaultCode,
                amountMinorController: previewCtrl,
                currencyCodes: foreign.codes,
                rates: foreign.rates,
                fixedInputCurrency: account.currencyCode,
                showForeignToggle: false,
                onSnapshotChanged: (s) => fromSnap = s,
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    int? val;
    if (account.currencyCode == defaultCode) {
      val = int.tryParse(previewCtrl.text.trim());
    } else {
      final snap = amountKey.currentState?.buildSnapshot() ?? fromSnap;
      val = snap != null ? snap.amount.round() : int.tryParse(previewCtrl.text.trim());
    }
    if (val != null) {
      await repo.adjustAccountBalance(
        account.id,
        val,
        fromCurrency: fromSnap,
      );
    }
  }
  previewCtrl.dispose();
}

Future<void> _openAccountEditor(
    BuildContext context, WidgetRef ref, WalletAccount? existing, String code) async {
  final managed = await ref.read(managedCurrenciesProvider.future);
  final currencyCodes = managed.map((c) => c.code).toList();
  if (!currencyCodes.contains(code)) {
    currencyCodes.insert(0, code);
  }
  if (currencyCodes.isEmpty) {
    currencyCodes.add(code);
  }

  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final emojiCtrl = TextEditingController(text: existing?.emoji ?? '💵');
  final balCtrl = TextEditingController(
    text: existing != null ? '${existing.balanceMinor}' : '0',
  );
  var selectedCurrency = existing?.currencyCode ?? code;
  if (!currencyCodes.contains(selectedCurrency)) {
    selectedCurrency = code;
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(existing == null ? 'New account' : 'Edit account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiCtrl,
                decoration: const InputDecoration(labelText: 'Emoji'),
                maxLength: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: currencyCodes
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedCurrency = v);
                },
              ),
              if (existing == null) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: balCtrl,
                  decoration: InputDecoration(
                    labelText: 'Opening balance (${selectedCurrency})',
                    helperText: 'Amount in minor units',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    ),
  );

  if (ok == true && context.mounted) {
    final name = nameCtrl.text.trim();
    final emoji = emojiCtrl.text.trim();
    final bal = existing?.balanceMinor ?? (int.tryParse(balCtrl.text.trim()) ?? 0);
    if (name.isNotEmpty) {
      await ref.read(ledgerRepositoryProvider).upsertWalletAccount(
            id: existing?.id,
            name: name,
            emoji: emoji.isEmpty ? '💵' : emoji,
            balanceMinor: bal,
            sortOrder: existing?.sortOrder ?? 0,
            currencyCode: selectedCurrency,
          );
    }
  }
  nameCtrl.dispose();
  emojiCtrl.dispose();
  balCtrl.dispose();
}

Future<void> openGoalEditor(
    BuildContext context, WidgetRef ref, SavingsGoal? existing) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🎯');
  final targetCtrl = TextEditingController(
    text: existing != null ? '${existing.targetMinor}' : '',
  );
  final noteCtrl = TextEditingController(text: existing?.note ?? '');

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'New savings goal' : 'Edit goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiCtrl,
              decoration: const InputDecoration(labelText: 'Emoji'),
              maxLength: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal name'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: targetCtrl,
              decoration: const InputDecoration(labelText: 'Target amount (minor units)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ),
  );

  if (ok == true && context.mounted) {
    final name = nameCtrl.text.trim();
    final emoji = emojiCtrl.text.trim();
    final target = int.tryParse(targetCtrl.text.trim()) ?? 0;
    final note = noteCtrl.text.trim();
    if (name.isNotEmpty && target > 0) {
      await ref.read(ledgerRepositoryProvider).upsertSavingsGoal(
            id: existing?.id,
            name: name,
            emoji: emoji.isEmpty ? '🎯' : emoji,
            targetMinor: target,
            savedMinor: existing?.savedMinor ?? 0,
            note: note.isEmpty ? null : note,
          );
    }
  }
  nameCtrl.dispose();
  emojiCtrl.dispose();
  targetCtrl.dispose();
  noteCtrl.dispose();
}

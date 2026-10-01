import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/currency_amount_input.dart';

enum WalletOp { add, remove, set }

/// Set operations: amber when reconciling, independent of direction.
const Color walletSetColor = AppTheme.ledgerCancel;

/// Display style for one wallet ledger row (shared by Home, Wallet tab, history).
class WalletEntryStyle {
  const WalletEntryStyle({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory WalletEntryStyle.of(WalletLedgerEntry e, String currencyCode) {
    String fmt(int v) => MoneyFormat.formatMinor(v, currencyCode);
    final delta = e.balanceAfterMinor - e.balanceBeforeMinor;
    final signedDelta = delta >= 0 ? '+${fmt(delta)}' : '−${fmt(-delta)}';
    switch (e.opType) {
      case 'increase':
        return WalletEntryStyle(
          color: AppTheme.balanceReceivable,
          icon: Icons.add_circle_outline,
          title: '+${fmt(e.amountMinor)}',
          subtitle: '${fmt(e.balanceBeforeMinor)} → ${fmt(e.balanceAfterMinor)}',
        );
      case 'decrease':
        return WalletEntryStyle(
          color: AppTheme.ledgerDebt,
          icon: Icons.remove_circle_outline,
          title: '−${fmt(e.amountMinor)}',
          subtitle: '${fmt(e.balanceBeforeMinor)} → ${fmt(e.balanceAfterMinor)}',
        );
      default:
        return WalletEntryStyle(
          color: walletSetColor,
          icon: delta >= 0 ? Icons.north_east_rounded : Icons.south_east_rounded,
          title: 'Set → ${fmt(e.balanceAfterMinor)}',
          subtitle: 'was ${fmt(e.balanceBeforeMinor)}, $signedDelta',
        );
    }
  }

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
}

/// Add / remove / set a wallet balance. Prompts for the account and/or the
/// operation when they are not provided.
Future<void> openWalletBalanceAction(
  BuildContext context,
  WidgetRef ref, {
  WalletAccount? account,
  WalletOp? op,
}) async {
  var target = account;
  if (target == null) {
    final accounts = await ref.read(walletAccountsProvider.future);
    if (!context.mounted || accounts.isEmpty) return;
    target = accounts.length == 1 ? accounts.first : await _pickAccount(context, accounts);
  }
  if (target == null || !context.mounted) return;

  final chosenOp = op ?? await _pickOp(context);
  if (chosenOp == null || !context.mounted) return;

  final repo = ref.read(ledgerRepositoryProvider);
  final defaultCode = await ref.read(defaultCurrencyProvider.future);
  final foreign = await repo.foreignCurrencyEditorContext();
  if (!context.mounted) return;

  final result = await showDialog<_WalletOpResult>(
    context: context,
    builder: (_) => _WalletOpDialog(
      account: target!,
      op: chosenOp,
      defaultCode: defaultCode,
      foreignCodes: foreign.codes,
      foreignRates: foreign.rates,
    ),
  );
  if (result == null) return;

  switch (chosenOp) {
    case WalletOp.add:
      await repo.adjustWalletDelta(target.id, result.minor, fromCurrency: result.snapshot);
    case WalletOp.remove:
      await repo.adjustWalletDelta(target.id, -result.minor, fromCurrency: result.snapshot);
    case WalletOp.set:
      await repo.adjustAccountBalance(target.id, result.minor, fromCurrency: result.snapshot);
  }
}

Future<WalletAccount?> _pickAccount(BuildContext context, List<WalletAccount> accounts) {
  return showModalBottomSheet<WalletAccount>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Choose account')),
          for (final a in accounts)
            ListTile(
              leading: Text(a.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(a.name),
              trailing: Text(MoneyFormat.formatMinor(a.balanceMinor, a.currencyCode)),
              onTap: () => Navigator.pop(ctx, a),
            ),
        ],
      ),
    ),
  );
}

Future<WalletOp?> _pickOp(BuildContext context) {
  return showModalBottomSheet<WalletOp>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: AppTheme.balanceReceivable),
            title: const Text('Add to balance'),
            onTap: () => Navigator.pop(ctx, WalletOp.add),
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle_outline, color: AppTheme.ledgerDebt),
            title: const Text('Remove from balance'),
            onTap: () => Navigator.pop(ctx, WalletOp.remove),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded, color: walletSetColor),
            title: const Text('Set balance'),
            subtitle: const Text('Enter the real total; the difference is recorded'),
            onTap: () => Navigator.pop(ctx, WalletOp.set),
          ),
        ],
      ),
    ),
  );
}

class _WalletOpResult {
  const _WalletOpResult(this.minor, this.snapshot);
  final int minor;
  final FromCurrencySnapshot? snapshot;
}

class _WalletOpDialog extends StatefulWidget {
  const _WalletOpDialog({
    required this.account,
    required this.op,
    required this.defaultCode,
    required this.foreignCodes,
    required this.foreignRates,
  });

  final WalletAccount account;
  final WalletOp op;
  final String defaultCode;
  final List<String> foreignCodes;
  final Map<String, num> foreignRates;

  @override
  State<_WalletOpDialog> createState() => _WalletOpDialogState();
}

class _WalletOpDialogState extends State<_WalletOpDialog> {
  final _ctrl = TextEditingController();
  final _amountKey = GlobalKey<CurrencyAmountInputState>();
  FromCurrencySnapshot? _snap;

  bool get _isDefault => widget.account.currencyCode == widget.defaultCode;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? _enteredMinor() {
    if (_isDefault) {
      return MoneyFormat.parseMinorUnits(_ctrl.text, fractionDigits: 0);
    }
    final snap = _amountKey.currentState?.buildSnapshot() ?? _snap;
    return snap?.amount.round();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final a = widget.account;
    String fmt(int v) => MoneyFormat.formatMinor(v, a.currencyCode);
    final before = a.balanceMinor;
    final entered = _enteredMinor();

    int? after;
    if (entered != null && entered >= 0) {
      after = switch (widget.op) {
        WalletOp.add => before + entered,
        WalletOp.remove => before - entered,
        WalletOp.set => entered,
      };
    }
    final delta = after == null ? null : after - before;
    final valid = entered != null &&
        (widget.op == WalletOp.set ? delta != 0 && entered >= 0 : entered > 0);

    final (title, color) = switch (widget.op) {
      WalletOp.add => ('Add to ${a.name}', AppTheme.balanceReceivable),
      WalletOp.remove => ('Remove from ${a.name}', AppTheme.ledgerDebt),
      WalletOp.set => ('Set ${a.name} balance', walletSetColor),
    };

    return AlertDialog(
      title: Text('${a.emoji} $title'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current balance: ${fmt(before)}',
                style: text.bodyMedium?.copyWith(color: AppTheme.mutedFg)),
            const SizedBox(height: 12),
            if (_isDefault)
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: widget.op == WalletOp.set ? 'New total' : 'Amount',
                  helperText: a.currencyCode,
                ),
              )
            else
              CurrencyAmountInput(
                key: _amountKey,
                defaultCurrencyCode: widget.defaultCode,
                amountMinorController: _ctrl,
                currencyCodes: widget.foreignCodes,
                rates: widget.foreignRates,
                fixedInputCurrency: a.currencyCode,
                showForeignToggle: false,
                amountLabel: widget.op == WalletOp.set ? 'New total' : 'Amount',
                onSnapshotChanged: (s) => setState(() => _snap = s),
              ),
            if (after != null && delta != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  delta == 0
                      ? 'No change'
                      : '${fmt(before)} → ${fmt(after)}  '
                          '(${delta > 0 ? '+${fmt(delta)}' : '−${fmt(-delta)}'})',
                  style: text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(
                    context,
                    _WalletOpResult(entered, _amountKey.currentState?.buildSnapshot() ?? _snap),
                  )
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

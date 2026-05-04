import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/ledger_types.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

typedef TransactionSubmit =
    Future<void> Function(int amountMinor, LedgerTxType type, String? note);

class TransactionEditorSheet extends StatefulWidget {
  const TransactionEditorSheet({
    super.key,
    required this.title,
    required this.currencyCode,
    required this.onSubmit,
    this.initialAmountMinor,
    this.initialType,
    this.initialNote,
  });

  final String title;
  final String currencyCode;
  final TransactionSubmit onSubmit;
  final int? initialAmountMinor;
  final LedgerTxType? initialType;
  final String? initialNote;

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  LedgerTxType _type = LedgerTxType.debt;
  late final TextEditingController _note = TextEditingController(
    text: widget.initialNote ?? '',
  );
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
    if (widget.initialAmountMinor != null) {
      _amount = TextEditingController(
        text: widget.initialAmountMinor!.toString(),
      );
    } else {
      _amount = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                'Currency: ${widget.currencyCode}',
                style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TxTypeCard(
                      selected: _type == LedgerTxType.debt,
                      title: 'Debt',
                      caption: 'Increases amount owed',
                      color: AppTheme.ledgerDebt,
                      icon: Icons.trending_up_rounded,
                      onTap: () => setState(() => _type = LedgerTxType.debt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TxTypeCard(
                      selected: _type == LedgerTxType.payment,
                      title: 'Payment',
                      caption: 'Reduces balance owed',
                      color: AppTheme.ledgerPayment,
                      icon: Icons.payments_rounded,
                      onTap: () => setState(() => _type = LedgerTxType.payment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '100',
                  helperText: 'Enter whole DZD values only.',
                ),
                validator: (v) {
                  final minor = MoneyFormat.parseMinorUnits(v ?? '');
                  if (minor == null || minor <= 0)
                    return 'Enter a positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final minor = MoneyFormat.parseMinorUnits(
                          _amount.text,
                        )!;
                        setState(() => _busy = true);
                        try {
                          await widget.onSubmit(
                            minor,
                            _type,
                            _note.text.trim().isEmpty
                                ? null
                                : _note.text.trim(),
                          );
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxTypeCard extends StatelessWidget {
  const _TxTypeCard({
    required this.selected,
    required this.title,
    required this.caption,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String caption;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? color.withValues(alpha: 0.22) : AppTheme.inputFill,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: selected
                  ? color
                  : AppTheme.mutedFg.withValues(alpha: 0.25),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: text.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                style: text.bodySmall?.copyWith(
                  color: AppTheme.mutedFg,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

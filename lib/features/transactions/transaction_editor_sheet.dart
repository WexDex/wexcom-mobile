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
  late final TextEditingController _note = TextEditingController(text: widget.initialNote ?? '');
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
    if (widget.initialAmountMinor != null) {
      final major = widget.initialAmountMinor! / 100;
      _amount = TextEditingController(text: major.toStringAsFixed(2));
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
              SegmentedButton<LedgerTxType>(
                segments: const [
                  ButtonSegment(
                    value: LedgerTxType.debt,
                    label: Text('Debt'),
                    tooltip: 'Increases balance (you owe more)',
                  ),
                  ButtonSegment(
                    value: LedgerTxType.payment,
                    label: Text('Payment'),
                    tooltip: 'Decreases balance',
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                ),
                validator: (v) {
                  final minor = MoneyFormat.parseMinorUnits(v ?? '');
                  if (minor == null || minor <= 0) return 'Enter a positive amount';
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
                        final minor = MoneyFormat.parseMinorUnits(_amount.text)!;
                        setState(() => _busy = true);
                        try {
                          await widget.onSubmit(
                            minor,
                            _type,
                            _note.text.trim().isEmpty ? null : _note.text.trim(),
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

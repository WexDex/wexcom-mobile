import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/from_currency_snapshot.dart';
import '../theme/app_theme.dart';
import '../utils/exchange_rate.dart';
import '../utils/money.dart';

/// Amount entry with currency picker and bidirectional default-currency preview.
///
/// [amountMinorController] holds the default-currency minor units (source of truth).
/// When input currency is foreign, [onSnapshotChanged] receives a snapshot at save time.
class CurrencyAmountInput extends StatefulWidget {
  const CurrencyAmountInput({
    super.key,
    required this.defaultCurrencyCode,
    required this.amountMinorController,
    required this.currencyCodes,
    required this.rates,
    this.onSnapshotChanged,
    this.initialSnapshot,
    this.defaultFractionDigits = 0,
    this.showForeignToggle = true,
    this.fixedInputCurrency,
    this.amountLabel,
    this.validator,
  });

  final String defaultCurrencyCode;
  final TextEditingController amountMinorController;
  final List<String> currencyCodes;
  final Map<String, num> rates;
  final ValueChanged<FromCurrencySnapshot?>? onSnapshotChanged;
  final FromCurrencySnapshot? initialSnapshot;
  final int defaultFractionDigits;
  /// When false, always show currency dropdown (no toggle).
  final bool showForeignToggle;
  /// When set, currency is fixed (e.g. wallet account currency).
  final String? fixedInputCurrency;
  final String? amountLabel;
  final String? Function(String? defaultMinorText)? validator;

  @override
  State<CurrencyAmountInput> createState() => CurrencyAmountInputState();
}

class CurrencyAmountInputState extends State<CurrencyAmountInput> {
  bool _useForeign = false;
  String? _inputCode;
  final _inputAmount = TextEditingController();
  bool _syncing = false;

  List<String> get _allCodes {
    final codes = <String>[widget.defaultCurrencyCode];
    for (final c in widget.currencyCodes) {
      if (c != widget.defaultCurrencyCode && !codes.contains(c)) {
        codes.add(c);
      }
    }
    return codes;
  }

  String get _selectedCode =>
      widget.fixedInputCurrency ?? _inputCode ?? widget.defaultCurrencyCode;

  bool get _isForeign => _selectedCode != widget.defaultCurrencyCode;

  num? get _rate =>
      _isForeign ? widget.rates[_selectedCode] : null;

  @override
  void initState() {
    super.initState();
    final snap = widget.initialSnapshot;
    if (snap != null && snap.code != widget.defaultCurrencyCode) {
      _useForeign = true;
      _inputCode = snap.code;
      _inputAmount.text = _formatMajor(snap.amount);
    } else if (widget.fixedInputCurrency != null &&
        widget.fixedInputCurrency != widget.defaultCurrencyCode) {
      _useForeign = true;
      _inputCode = widget.fixedInputCurrency;
    } else {
      final foreign = widget.currencyCodes
          .where((c) => c != widget.defaultCurrencyCode)
          .toList();
      if (foreign.isNotEmpty) _inputCode = foreign.first;
    }
    widget.amountMinorController.addListener(_onDefaultChanged);
    _inputAmount.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialSnapshot != null ||
          widget.amountMinorController.text.trim().isNotEmpty) {
        _notifySnapshot();
      }
    });
  }

  /// True when the user enabled foreign entry (finance / transactions editors).
  bool get foreignModeEnabled =>
      widget.fixedInputCurrency == null && _useForeign;

  @override
  void dispose() {
    widget.amountMinorController.removeListener(_onDefaultChanged);
    _inputAmount.removeListener(_onInputChanged);
    _inputAmount.dispose();
    super.dispose();
  }

  void _notifySnapshot() {
    widget.onSnapshotChanged?.call(buildSnapshot());
  }

  FromCurrencySnapshot? buildSnapshot() {
    if (widget.fixedInputCurrency == null && !_useForeign) return null;
    if (!_isForeign) return null;
    final rate = _rate;
    if (rate == null || rate <= 0) return null;
    final major = num.tryParse(_inputAmount.text.trim()) ?? 0;
    if (major <= 0) {
      final minor =
          MoneyFormat.parseMinorUnits(widget.amountMinorController.text) ?? 0;
      if (minor <= 0) return null;
      final computedMajor = convertDefaultMinorToForeignMajor(
        defaultMinor: minor,
        rate: rate,
        defaultFractionDigits: widget.defaultFractionDigits,
      );
      return FromCurrencySnapshot(
        code: _selectedCode,
        rate: rate,
        amount: computedMajor,
      );
    }
    return FromCurrencySnapshot(code: _selectedCode, rate: rate, amount: major);
  }

  String _formatMajor(num value) {
    if (value <= 0) return '';
    if (value == value.roundToDouble()) return value.round().toString();
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _onDefaultChanged() {
    if (!mounted || _syncing || !_isForeign) {
      if (mounted) setState(() {});
      return;
    }
    _syncFromDefault();
  }

  void _onInputChanged() {
    if (!mounted || _syncing || !_isForeign) return;
    _syncFromInput();
  }

  void _syncFromInput() {
    final rate = _rate;
    if (rate == null || rate <= 0) {
      setState(() {});
      return;
    }
    final major = num.tryParse(_inputAmount.text.trim()) ?? 0;
    _syncing = true;
    if (major <= 0) {
      widget.amountMinorController.text = '';
    } else {
      widget.amountMinorController.text = '${convertMajorToDefaultMinor(
        majorAmount: major,
        rate: rate,
        defaultFractionDigits: widget.defaultFractionDigits,
      )}';
    }
    _syncing = false;
    _notifySnapshot();
    setState(() {});
  }

  void _syncFromDefault() {
    final rate = _rate;
    if (rate == null || rate <= 0) {
      setState(() {});
      return;
    }
    final minor =
        MoneyFormat.parseMinorUnits(widget.amountMinorController.text) ?? 0;
    _syncing = true;
    if (minor <= 0) {
      _inputAmount.text = '';
    } else {
      _inputAmount.text = _formatMajor(convertDefaultMinorToForeignMajor(
        defaultMinor: minor,
        rate: rate,
        defaultFractionDigits: widget.defaultFractionDigits,
      ));
    }
    _syncing = false;
    _notifySnapshot();
    setState(() {});
  }

  void _onCurrencyChanged(String? code) {
    if (code == null) return;
    setState(() {
      _inputCode = code;
      if (code == widget.defaultCurrencyCode) {
        _useForeign = false;
      } else {
        _useForeign = true;
      }
    });
    if (_isForeign) {
      if (_inputAmount.text.trim().isNotEmpty) {
        _syncFromInput();
      } else if (widget.amountMinorController.text.trim().isNotEmpty) {
        _syncFromDefault();
      }
    }
    _notifySnapshot();
  }

  @override
  Widget build(BuildContext context) {
    final foreignCodes =
        _allCodes.where((c) => c != widget.defaultCurrencyCode).toList();
    final showMulti = foreignCodes.isNotEmpty;
    final showForeignFields =
        widget.fixedInputCurrency != null || (showMulti && _useForeign);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showMulti && widget.showForeignToggle && widget.fixedInputCurrency == null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Foreign currency'),
            subtitle: const Text('Enter amount in another currency; default updates below'),
            value: _useForeign,
            onChanged: (v) {
              setState(() {
                _useForeign = v;
                if (v && _inputCode == null && foreignCodes.isNotEmpty) {
                  _inputCode = foreignCodes.first;
                }
                if (!v) _inputCode = widget.defaultCurrencyCode;
              });
              if (v && widget.amountMinorController.text.isNotEmpty) {
                _syncFromDefault();
              } else {
                _notifySnapshot();
              }
            },
          ),
        if (!showMulti && widget.fixedInputCurrency == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Add currencies and rates under Tags → Currencies to record foreign amounts.',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            ),
          ),
        if (showForeignFields) ...[
          if (widget.fixedInputCurrency == null)
            DropdownButtonFormField<String>(
              value: _selectedCode,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: _allCodes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: _onCurrencyChanged,
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Currency: ${widget.fixedInputCurrency}',
                style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
              ),
            ),
          if (_rate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '1 $_selectedCode = $_rate ${widget.defaultCurrencyCode}',
                style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
              ),
            )
          else if (_isForeign)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No rate for $_selectedCode — set one in Tags → Currencies',
                style: TextStyle(color: AppTheme.ledgerDebt, fontSize: 13),
              ),
            ),
          TextFormField(
            controller: _inputAmount,
            decoration: InputDecoration(
              labelText: widget.amountLabel ?? 'Amount ($_selectedCode)',
              helperText:
                  'Enter $_selectedCode — ${widget.defaultCurrencyCode} updates below',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.amountMinorController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Amount (${widget.defaultCurrencyCode})',
              helperText: _isForeign
                  ? 'Or enter ${widget.defaultCurrencyCode} directly'
                  : null,
            ),
            validator: widget.validator,
          ),
        ] else
          TextFormField(
            controller: widget.amountMinorController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: widget.amountLabel ??
                  'Amount (${widget.defaultCurrencyCode})',
              helperText: 'Whole ${widget.defaultCurrencyCode} units',
            ),
            validator: widget.validator,
          ),
      ],
    );
  }
}

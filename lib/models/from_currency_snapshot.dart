import 'dart:convert';

import '../utils/money.dart';

/// Optional foreign-currency clarification on a monetary row.
/// [amountMinor] on the parent row remains the default-currency source of truth.
class FromCurrencySnapshot {
  const FromCurrencySnapshot({
    required this.code,
    required this.rate,
    required this.amount,
  });

  final String code;
  /// 1 major [code] unit = [rate] default (at event time).
  final num rate;
  /// Foreign amount in major units (e.g. 2 = $2).
  final num amount;

  Map<String, dynamic> toJson() => {
        'code': code,
        'rate': rate,
        'amount': amount,
      };

  static FromCurrencySnapshot? fromJsonString(String? json) {
    if (json == null || json.trim().isEmpty) return null;
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return fromJsonMap(m);
    } catch (_) {
      return null;
    }
  }

  static FromCurrencySnapshot? fromJsonMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final code = m['code'] as String?;
    final rate = m['rate'];
    final amount = m['amount'];
    if (code == null || rate == null || amount == null) return null;
    return FromCurrencySnapshot(
      code: code.toUpperCase(),
      rate: rate is num ? rate : num.tryParse('$rate') ?? 0,
      amount: amount is num ? amount : num.tryParse('$amount') ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  String formatPrimary() {
    final amt = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    return '$amt $code';
  }

  String formatPreview(String defaultCode, int amountMinor) {
    return '~= ${MoneyFormat.formatMinor(amountMinor, defaultCode)}';
  }
}

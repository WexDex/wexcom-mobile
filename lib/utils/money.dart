import 'package:intl/intl.dart';

final class MoneyFormat {
  MoneyFormat._();

  /// Parses user decimal input into minor units ([fractionDigits] fractional digits).
  static int? parseMinorUnits(String raw, {int fractionDigits = 2}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll(',', '.');
    final match = RegExp(r'^-?\d+(?:\.\d*)?$').firstMatch(normalized);
    if (match == null) return null;

    final negative = normalized.startsWith('-');
    final unsigned = negative ? normalized.substring(1) : normalized;

    final parts = unsigned.split('.');
    final whole = parts[0];
    if (whole.isEmpty) return null;

    var frac = '';
    if (parts.length > 1) {
      frac = parts.sublist(1).join();
    }
    if (frac.length > fractionDigits) {
      frac = frac.substring(0, fractionDigits);
    }
    frac = frac.padRight(fractionDigits, '0');

    final wholeMinor = int.tryParse(whole);
    if (wholeMinor == null) return null;
    final fracMinor = int.tryParse(frac.isEmpty ? '0' : frac);
    if (fracMinor == null) return null;

    final magnitude = wholeMinor * _pow10(fractionDigits) + fracMinor;
    return negative ? -magnitude : magnitude;
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  static String formatMinor(int minorUnits, String currencyCode, {int fractionDigits = 2}) {
    final major = minorUnits / _pow10(fractionDigits);
    final fmt = NumberFormat.currency(
      locale: 'en_US',
      name: currencyCode,
      symbol: currencyCode,
      decimalDigits: fractionDigits,
    );
    return fmt.format(major);
  }
}

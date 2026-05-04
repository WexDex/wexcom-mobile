import 'package:intl/intl.dart';

final class MoneyFormat {
  MoneyFormat._();

  /// Parses user input into whole minor units.
  ///
  /// For DZD / whole-unit currencies this stores the integer amount directly.
  static int? parseMinorUnits(String raw, {int fractionDigits = 0}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll(' ', '').replaceAll(',', '.');
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

  static String _grouped(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final positionFromRight = digits.length - i - 1;
      buffer.write(digits[i]);
      if (positionFromRight > 0 && positionFromRight % 3 == 0) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Plain amount with thousands separators and optional fraction digits.
  static String formatMinor(
    int minorUnits,
    String currencyCode, {
    int fractionDigits = 0,
  }) {
    final negative = minorUnits < 0;
    final abs = minorUnits.abs();
    final denom = _pow10(fractionDigits);
    final whole = fractionDigits == 0 ? abs : abs ~/ denom;
    final wholeStr = _grouped(whole);
    final sign = negative ? '-' : '';

    if (fractionDigits == 0) {
      return '$sign$wholeStr $currencyCode';
    }

    final frac = abs % denom;
    final fracStr = frac.toString().padLeft(fractionDigits, '0');
    return '$sign$wholeStr.$fracStr $currencyCode';
  }

  static String formatDateTime(DateTime utc) {
    return DateFormat.yMMMd().add_jm().format(utc.toLocal());
  }

  static String formatDate(DateTime utc) {
    return DateFormat.yMMMd().format(utc.toLocal());
  }
}

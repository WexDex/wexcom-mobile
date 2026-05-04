import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Negative → they owe you; positive → you owe them (matches ledger plan).
String balanceSemanticsLine(int balanceMinor) {
  if (balanceMinor < 0) return 'They owe you';
  if (balanceMinor > 0) return 'You owe them';
  return 'Even';
}

Color balanceColor(int balanceMinor) {
  if (balanceMinor < 0) return AppTheme.receivableAccent;
  if (balanceMinor > 0) return AppTheme.destructive;
  return AppTheme.mutedFg;
}

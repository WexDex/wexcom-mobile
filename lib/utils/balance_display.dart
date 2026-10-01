import 'package:flutter/material.dart';

import '../data/db/app_database.dart';
import '../theme/app_theme.dart';

/// Positive → they pay you (debt increases balance); negative → I pay them.
String balanceSemanticsLine(int balanceMinor) {
  if (balanceMinor > 0) return 'They pay you';
  if (balanceMinor < 0) return 'I pay them';
  return 'Even';
}

Color balanceColor(int balanceMinor) {
  if (balanceMinor > 0) return AppTheme.balanceReceivable;
  if (balanceMinor < 0) return AppTheme.ledgerDebt;
  return AppTheme.mutedFg;
}

/// Client balances split into what clients pay you vs what you pay them.
class ClientBalanceTotals {
  const ClientBalanceTotals({
    required this.theyPayYouMinor,
    required this.iPayThemMinor,
    required this.theyPayYouCount,
    required this.iPayThemCount,
  });

  factory ClientBalanceTotals.fromClients(Iterable<Client> clients) {
    var theyPay = 0;
    var iPay = 0;
    var theyPayCount = 0;
    var iPayCount = 0;
    for (final c in clients) {
      if (c.balanceMinor > 0) {
        theyPay += c.balanceMinor;
        theyPayCount++;
      } else if (c.balanceMinor < 0) {
        iPay += -c.balanceMinor;
        iPayCount++;
      }
    }
    return ClientBalanceTotals(
      theyPayYouMinor: theyPay,
      iPayThemMinor: iPay,
      theyPayYouCount: theyPayCount,
      iPayThemCount: iPayCount,
    );
  }

  final int theyPayYouMinor;
  final int iPayThemMinor;
  final int theyPayYouCount;
  final int iPayThemCount;

  int get netMinor => theyPayYouMinor - iPayThemMinor;
}

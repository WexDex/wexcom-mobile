import 'package:flutter/material.dart';

import 'wallet_history.dart';

/// Full-screen host for [WalletHistoryView] (deep links, `/finance/wallet/:id`).
class WalletAccountHistoryScreen extends StatelessWidget {
  const WalletAccountHistoryScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: WalletHistoryView(initialAccountId: accountId)),
    );
  }
}

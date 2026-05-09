import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final i = navigationShell.currentIndex;
    final inactive = AppTheme.mutedFg;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: i == 0 ? null : inactive),
            selectedIcon: const Icon(Icons.home_rounded, color: AppTheme.brandPrimary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline, color: i == 1 ? null : inactive),
            selectedIcon: const Icon(Icons.people_rounded, color: AppTheme.brandPrimary),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: i == 2 ? null : inactive),
            selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.brandPrimary),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined, color: i == 3 ? null : inactive),
            selectedIcon:
                const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.personalGain),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline, color: i == 4 ? null : inactive),
            selectedIcon: const Icon(Icons.label_rounded, color: AppTheme.brandSecondary),
            label: 'Tags',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: i == 5 ? null : inactive),
            selectedIcon: const Icon(Icons.settings_rounded, color: AppTheme.brandPrimary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

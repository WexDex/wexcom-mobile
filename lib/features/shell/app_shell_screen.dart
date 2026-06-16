import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCount = ref.watch(financeBadgeCountProvider).valueOrNull ?? 0;

    // Sync app icon badge on Android/iOS
    ref.listen(financeBadgeCountProvider, (_, next) {
      final count = next.valueOrNull ?? 0;
      AppBadgePlus.updateBadge(count);
    });

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) {
          HapticFeedback.lightImpact();
          navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clients',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: _BadgedIcon(
              icon: Icons.account_balance_wallet_outlined,
              count: badgeCount,
            ),
            selectedIcon: _BadgedIcon(
              icon: Icons.account_balance_wallet_rounded,
              count: badgeCount,
            ),
            label: 'Finance',
          ),
          const NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label_rounded),
            label: 'Tags',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

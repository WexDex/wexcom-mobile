import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomPad),
        child: _FloatingPillNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating pill navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.activeColor});
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', activeColor: AppTheme.brandPrimary),
  _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Clients', activeColor: AppTheme.brandPrimary),
  _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Ledger', activeColor: AppTheme.brandPrimary),
  _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Finance', activeColor: AppTheme.personalGain),
  _NavItem(icon: Icons.label_outline, activeIcon: Icons.label_rounded, label: 'Tags', activeColor: AppTheme.brandSecondary),
  _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', activeColor: AppTheme.brandPrimary),
];

class _FloatingPillNav extends StatefulWidget {
  const _FloatingPillNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_FloatingPillNav> createState() => _FloatingPillNavState();
}

class _FloatingPillNavState extends State<_FloatingPillNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.06, end: 0.14).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final activeColor = _navItems[widget.currentIndex].activeColor;
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: activeColor.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8)),
              BoxShadow(color: activeColor.withValues(alpha: _pulse.value), blurRadius: 20),
            ],
          ),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = i == widget.currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: _NavPillItem(
                    item: item,
                    active: active,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _NavPillItem extends StatelessWidget {
  const _NavPillItem({required this.item, required this.active});

  final _NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: active ? item.activeColor.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? [BoxShadow(color: item.activeColor.withValues(alpha: 0.2), blurRadius: 8)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              active ? item.activeIcon : item.icon,
              key: ValueKey(active),
              size: 22,
              color: active ? item.activeColor : AppTheme.mutedFg,
            ),
          ),
        ],
      ),
    );
  }
}

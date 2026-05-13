import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/clients/archived_clients_screen.dart';
import '../features/clients/client_detail_screen.dart';
import '../features/clients/client_list_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/finance/personal_finance_screen.dart';
import '../features/settings/audit_log_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/tag_editor_screen.dart';
import '../features/settings/user_stats_screen.dart';
import '../features/shell/app_shell_screen.dart';
import '../features/transactions/transactions_screen.dart';

// Subtle fade + micro-slide for tab switches
Page<void> _tabPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondary, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

// Slightly stronger slide for detail/push routes (right-to-left feel)
Page<void> _detailPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => _tabPage(state, const DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                pageBuilder: (context, state) => _tabPage(state, const ClientListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                pageBuilder: (context, state) => _tabPage(state, const TransactionsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                name: 'finance',
                pageBuilder: (context, state) => _tabPage(state, const PersonalFinanceScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tags',
                name: 'tags',
                pageBuilder: (context, state) => _tabPage(state, const TagEditorScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => _tabPage(state, const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/archived',
        name: 'archived',
        pageBuilder: (context, state) => _detailPage(state, const ArchivedClientsScreen()),
      ),
      GoRoute(
        path: '/client/:clientId',
        name: 'client',
        pageBuilder: (context, state) {
          final id = state.pathParameters['clientId']!;
          return _detailPage(state, ClientDetailScreen(clientId: id));
        },
      ),
      GoRoute(
        path: '/settings/stats',
        name: 'user-stats',
        pageBuilder: (context, state) => _detailPage(state, const UserStatsScreen()),
      ),
      GoRoute(
        path: '/settings/audit-log',
        name: 'audit-log',
        pageBuilder: (context, state) => _detailPage(state, const AuditLogScreen()),
      ),
    ],
  );
});

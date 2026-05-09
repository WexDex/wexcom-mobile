import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/clients/archived_clients_screen.dart';
import '../features/clients/client_detail_screen.dart';
import '../features/clients/client_list_screen.dart';
import '../features/settings/tag_editor_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/user_stats_screen.dart';
import '../features/shell/app_shell_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/finance/personal_finance_screen.dart';

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
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                builder: (context, state) => const ClientListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                name: 'finance',
                builder: (context, state) => const PersonalFinanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tags',
                name: 'tags',
                builder: (context, state) => const TagEditorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/archived',
        name: 'archived',
        builder: (context, state) => const ArchivedClientsScreen(),
      ),
      GoRoute(
        path: '/client/:clientId',
        name: 'client',
        builder: (context, state) {
          final id = state.pathParameters['clientId']!;
          return ClientDetailScreen(clientId: id);
        },
      ),
      GoRoute(
        path: '/settings/stats',
        name: 'user-stats',
        builder: (context, state) => const UserStatsScreen(),
      ),
    ],
  );
});

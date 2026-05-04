import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/clients/archived_clients_screen.dart';
import '../features/clients/client_detail_screen.dart';
import '../features/clients/client_list_screen.dart';
import '../features/settings/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'clients',
        builder: (context, state) => const ClientListScreen(),
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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

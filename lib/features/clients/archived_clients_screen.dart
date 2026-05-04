import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class ArchivedClientsScreen extends ConsumerWidget {
  const ArchivedClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncClients = ref.watch(archivedClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncClients.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Text(
                'No archived clients.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedFg),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = clients[i];
              return Card(
                child: ListTile(
                  title: Text(c.fullName),
                  subtitle: const Text('Archived'),
                  trailing: TextButton(
                    onPressed: () async {
                      await ref.read(ledgerRepositoryProvider).setClientArchived(c.id, false);
                    },
                    child: const Text('Restore'),
                  ),
                  onTap: () => context.push('/client/${c.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

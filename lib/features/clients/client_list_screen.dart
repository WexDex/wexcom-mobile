import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import 'client_editor_sheet.dart';

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncClients = ref.watch(activeClientsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archived clients',
            onPressed: () => context.push('/archived'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: asyncClients.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Text(
                'No clients yet.\nTap + to add someone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedFg),
              ),
            );
          }
          final code = currencyAsync.valueOrNull ?? 'DZD';
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: clients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = clients[i];
              final balanceLabel = MoneyFormat.formatMinor(c.balanceMinor, code);
              final phrase = balanceSemanticsLine(c.balanceMinor);
              final color = balanceColor(c.balanceMinor);
              return Card(
                child: ListTile(
                  title: Text(c.fullName),
                  subtitle: Text(
                    phrase,
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    balanceLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
            ),
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
              child: ClientEditorSheet(
                onSaved: (fullName, phone, note) async {
                  final repo = ref.read(ledgerRepositoryProvider);
                  await repo.createClient(fullName: fullName, phone: phone, note: note);
                  if (context.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }
}

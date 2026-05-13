import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/hud_empty_state.dart';

String _archivedInitials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }
  final w = parts[0];
  if (w.length >= 2) return w.substring(0, 2).toUpperCase();
  return w.toUpperCase();
}

class ArchivedClientsScreen extends ConsumerStatefulWidget {
  const ArchivedClientsScreen({super.key});

  @override
  ConsumerState<ArchivedClientsScreen> createState() => _ArchivedClientsScreenState();
}

class _ArchivedClientsScreenState extends ConsumerState<ArchivedClientsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncClients = ref.watch(archivedClientsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final text = Theme.of(context).textTheme;

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
            return const HudEmptyState(
              icon: Icons.archive_outlined,
              message: 'No archived clients',
              subtitle: 'Clients you archive will appear here.',
            );
          }
          final code = currencyAsync.valueOrNull ?? 'DZD';
          final filtered = clients
              .where((c) => _query.isEmpty || c.fullName.toLowerCase().contains(_query))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search archived…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _search.clear(),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No matches.', style: TextStyle(color: AppTheme.mutedFg)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final initials = _archivedInitials(c.fullName);
                          final balance = MoneyFormat.formatMinor(c.balanceMinor, code);
                          return Material(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              onTap: () => context.push('/client/${c.id}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppTheme.mutedFg.withValues(alpha: 0.2),
                                      child: Text(
                                        initials,
                                        style: text.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.mutedFg,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'ARCHIVED · $balance',
                                            style: text.bodySmall?.copyWith(
                                              color: AppTheme.mutedFg,
                                              fontWeight: FontWeight.w700,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await ref.read(ledgerRepositoryProvider).setClientArchived(c.id, false);
                                      },
                                      style: TextButton.styleFrom(foregroundColor: AppTheme.ledgerPayment),
                                      child: const Text('Restore'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

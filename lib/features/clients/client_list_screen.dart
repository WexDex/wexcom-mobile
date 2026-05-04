import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import 'client_editor_sheet.dart';

String _initials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
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

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Client c) {
    if (_query.isEmpty) return true;
    if (c.fullName.toLowerCase().contains(_query)) return true;
    final phone = c.phone;
    if (phone != null && phone.toLowerCase().contains(_query)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final asyncClients = ref.watch(activeClientsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            tooltip: _compact ? 'Comfortable view' : 'Compact view',
            icon: Icon(
              _compact
                  ? Icons.view_agenda_outlined
                  : Icons.view_headline_outlined,
            ),
            onPressed: () => setState(() => _compact = !_compact),
          ),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 56,
                      color: AppTheme.mutedFg.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No clients yet',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add someone to your ledger.',
                      textAlign: TextAlign.center,
                      style: text.bodyLarge?.copyWith(color: AppTheme.mutedFg),
                    ),
                  ],
                ),
              ),
            );
          }
          final code = currencyAsync.valueOrNull ?? 'DZD';
          final filtered = clients.where(_matches).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} of ${clients.length}',
                      style: text.labelMedium?.copyWith(
                        color: AppTheme.mutedFg,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _compact ? 'Compact' : 'Comfortable',
                      style: text.labelMedium?.copyWith(
                        color: AppTheme.mutedFg,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matches for your search.',
                          style: text.bodyLarge?.copyWith(
                            color: AppTheme.mutedFg,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: _compact ? 6 : 10),
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final balanceLabel = MoneyFormat.formatMinor(
                            c.balanceMinor,
                            code,
                          );
                          final phrase = balanceSemanticsLine(c.balanceMinor);
                          final color = balanceColor(c.balanceMinor);
                          final initials = _initials(c.fullName);
                          return _compact
                              ? _ClientRowCompact(
                                  name: c.fullName,
                                  phrase: phrase,
                                  balanceLabel: balanceLabel,
                                  accent: color,
                                  initials: initials,
                                  onTap: () => context.push('/client/${c.id}'),
                                )
                              : _ClientRowComfortable(
                                  name: c.fullName,
                                  phone: c.phone,
                                  phrase: phrase,
                                  balanceLabel: balanceLabel,
                                  createdAt: c.createdAt,
                                  accent: color,
                                  initials: initials,
                                  onTap: () => context.push('/client/${c.id}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radius),
              ),
            ),
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: ClientEditorSheet(
                onSaved: (fullName, phone, note) async {
                  final repo = ref.read(ledgerRepositoryProvider);
                  await repo.createClient(
                    fullName: fullName,
                    phone: phone,
                    note: note,
                  );
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

class _ClientRowCompact extends StatelessWidget {
  const _ClientRowCompact({
    required this.name,
    required this.phrase,
    required this.balanceLabel,
    required this.accent,
    required this.initials,
    required this.onTap,
  });

  final String name;
  final String phrase;
  final String balanceLabel;
  final Color accent;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.2),
                foregroundColor: accent,
                child: Text(
                  initials,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      phrase,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                balanceLabel,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.mutedFg.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientRowComfortable extends StatelessWidget {
  const _ClientRowComfortable({
    required this.name,
    required this.phone,
    required this.phrase,
    required this.balanceLabel,
    required this.createdAt,
    required this.accent,
    required this.initials,
    required this.onTap,
  });

  final String name;
  final String? phone;
  final String phrase;
  final String balanceLabel;
  final DateTime createdAt;
  final Color accent;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: accent.withValues(alpha: 0.22),
                foregroundColor: accent,
                child: Text(
                  initials,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase,
                      style: text.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added ${MoneyFormat.formatDate(createdAt)}',
                      style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                    ),
                    if (phone != null && phone!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: AppTheme.mutedFg,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              phone!,
                              style: text.bodySmall?.copyWith(
                                color: AppTheme.mutedFg,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balanceLabel,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.mutedFg.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

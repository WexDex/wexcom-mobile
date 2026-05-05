import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import 'client_editor_sheet.dart';

Color _tagColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

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

enum _ClientSortField { name, updatedAt, createdAt, lastActivityAt, balance }

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _compact = false;
  _ClientSortField _sortField = _ClientSortField.name;
  bool _sortAscending = true;

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

  int _compareClients(Client a, Client b) {
    final sign = _sortAscending ? 1 : -1;
    switch (_sortField) {
      case _ClientSortField.name:
        return sign * a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
      case _ClientSortField.updatedAt:
        return sign * a.updatedAt.compareTo(b.updatedAt);
      case _ClientSortField.createdAt:
        return sign * a.createdAt.compareTo(b.createdAt);
      case _ClientSortField.balance:
        return sign * a.balanceMinor.compareTo(b.balanceMinor);
      case _ClientSortField.lastActivityAt:
        final aAt = a.lastInteractionAt ?? a.createdAt;
        final bAt = b.lastInteractionAt ?? b.createdAt;
        return sign * aAt.compareTo(bAt);
    }
  }

  String get _sortLabel {
    switch (_sortField) {
      case _ClientSortField.name:
        return 'Name';
      case _ClientSortField.updatedAt:
        return 'Updated';
      case _ClientSortField.createdAt:
        return 'Created';
      case _ClientSortField.balance:
        return 'Balance';
      case _ClientSortField.lastActivityAt:
        return 'Last activity';
    }
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
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export clients CSV',
            onPressed: () => _exportClientsCsv(context, asyncClients.valueOrNull),
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
          filtered.sort(_compareClients);
          var totalDebtsMinor = 0;
          var totalPaymentsMinor = 0;
          for (final client in filtered) {
            if (client.balanceMinor > 0) {
              totalDebtsMinor += client.balanceMinor;
            } else if (client.balanceMinor < 0) {
              totalPaymentsMinor += -client.balanceMinor;
            }
          }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.swap_vert_rounded, size: 18),
                            label: Text('Sort: $_sortLabel'),
                            onPressed: () async {
                              final selected = await showModalBottomSheet<_ClientSortField>(
                                context: context,
                                backgroundColor: AppTheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(AppTheme.radius),
                                  ),
                                ),
                                builder: (ctx) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8),
                                      ListTile(
                                        title: const Text('Name'),
                                        trailing: _sortField == _ClientSortField.name
                                            ? const Icon(Icons.check)
                                            : null,
                                        onTap: () =>
                                            Navigator.pop(ctx, _ClientSortField.name),
                                      ),
                                      ListTile(
                                        title: const Text('Updated'),
                                        trailing:
                                            _sortField == _ClientSortField.updatedAt
                                            ? const Icon(Icons.check)
                                            : null,
                                        onTap: () => Navigator.pop(
                                          ctx,
                                          _ClientSortField.updatedAt,
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Created'),
                                        trailing:
                                            _sortField == _ClientSortField.createdAt
                                            ? const Icon(Icons.check)
                                            : null,
                                        onTap: () => Navigator.pop(
                                          ctx,
                                          _ClientSortField.createdAt,
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Last activity'),
                                        trailing: _sortField ==
                                                _ClientSortField.lastActivityAt
                                            ? const Icon(Icons.check)
                                            : null,
                                        onTap: () => Navigator.pop(
                                          ctx,
                                          _ClientSortField.lastActivityAt,
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Balance'),
                                        trailing:
                                            _sortField == _ClientSortField.balance
                                            ? const Icon(Icons.check)
                                            : null,
                                        onTap: () => Navigator.pop(
                                          ctx,
                                          _ClientSortField.balance,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                              if (selected != null && mounted) {
                                setState(() => _sortField = selected);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () =>
                              setState(() => _sortAscending = !_sortAscending),
                          tooltip: _sortAscending ? 'Ascending' : 'Descending',
                          icon: Icon(
                            _sortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TotalsChip(
                        label: 'Total Debts',
                        value: MoneyFormat.formatMinor(totalDebtsMinor, code),
                        color: AppTheme.ledgerDebt,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TotalsChip(
                        label: 'Total Payments',
                        value: MoneyFormat.formatMinor(totalPaymentsMinor, code),
                        color: AppTheme.ledgerPayment,
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
                          final tagsAsync = ref.watch(clientTagsProvider(c.id));
                          final insightAsync = ref.watch(clientInsightProvider(c.id));
                          final overdueAsync = ref.watch(clientOverdueProvider(c.id));
                          return _compact
                              ? _ClientRowCompact(
                                  name: c.fullName,
                                  phrase: phrase,
                                  balanceLabel: balanceLabel,
                                  accent: color,
                                  initials: initials,
                                  isArchived: c.archivedAt != null,
                                  tags: tagsAsync.valueOrNull ?? const [],
                                  insight: insightAsync.valueOrNull ?? '',
                                  overdue: overdueAsync.valueOrNull ?? false,
                                  onTap: () => context.push('/client/${c.id}'),
                                )
                              : _ClientRowComfortable(
                                  name: c.fullName,
                                  phone: c.phone,
                                  phrase: phrase,
                                  balanceLabel: balanceLabel,
                                  createdAt: c.createdAt,
                                  lastActivityAt: c.lastInteractionAt,
                                  accent: color,
                                  initials: initials,
                                  isArchived: c.archivedAt != null,
                                  tags: tagsAsync.valueOrNull ?? const [],
                                  insight: insightAsync.valueOrNull ?? '',
                                  overdue: overdueAsync.valueOrNull ?? false,
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
                availableTags: ref.read(clientScopeTagsProvider).valueOrNull ?? const [],
                onSaved: (fullName, phone, note, tagIds) async {
                  final repo = ref.read(ledgerRepositoryProvider);
                  final clientId = await repo.createClient(
                    fullName: fullName,
                    phone: phone,
                    note: note,
                  );
                  await repo.setClientTags(clientId, tagIds);
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

  Future<void> _exportClientsCsv(
    BuildContext context,
    List<Client>? clients,
  ) async {
    if (clients == null) return;
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    final csv = ExportService().exportClientsCsv(clients, range: range);
    if (!context.mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Copy CSV to clipboard'),
              onTap: () => Navigator.pop(ctx, 'clipboard'),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download CSV file'),
              onTap: () => Navigator.pop(ctx, 'download'),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == 'clipboard') {
      await Clipboard.setData(ClipboardData(text: csv));
    } else {
      try {
        final location = await getSaveLocation(
          suggestedName:
              'clients_export_${DateTime.now().millisecondsSinceEpoch}.csv',
          acceptedTypeGroups: const [
            XTypeGroup(label: 'csv', extensions: ['csv']),
          ],
        );
        if (location == null) return;
        final file = XFile.fromData(
          Uint8List.fromList(utf8.encode(csv)),
          mimeType: 'text/csv',
          name: 'clients_export.csv',
        );
        await file.saveTo(location.path);
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: csv));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File save unavailable. Clients CSV copied to clipboard instead.',
            ),
          ),
        );
        return;
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'clipboard'
              ? 'Clients CSV copied to clipboard'
              : 'Clients CSV downloaded',
        ),
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
    required this.isArchived,
    required this.tags,
    required this.insight,
    required this.overdue,
    required this.onTap,
  });

  final String name;
  final String phrase;
  final String balanceLabel;
  final Color accent;
  final String initials;
  final bool isArchived;
  final List<Tag> tags;
  final String insight;
  final bool overdue;
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
                    const SizedBox(height: 2),
                    Text(
                      isArchived ? 'ARCHIVED' : 'ACTIVE',
                      style: text.labelSmall?.copyWith(
                        color: isArchived ? AppTheme.ledgerCancel : AppTheme.ledgerPayment,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      overdue && insight.isNotEmpty ? '$phrase • $insight' : phrase,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: tags
                            .take(2)
                            .map(
                              (t) => Chip(
                                label: Text(
                                  t.name,
                                  style: text.labelSmall,
                                ),
                                avatar: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: _tagColor(t.colorHex),
                                ),
                                backgroundColor: _tagColor(
                                  t.colorHex,
                                ).withValues(alpha: 0.18),
                                side: BorderSide(
                                  color: _tagColor(
                                    t.colorHex,
                                  ).withValues(alpha: 0.75),
                                ),
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
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
                overdue ? Icons.warning_amber_rounded : Icons.chevron_right,
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
    required this.lastActivityAt,
    required this.accent,
    required this.initials,
    required this.isArchived,
    required this.tags,
    required this.insight,
    required this.overdue,
    required this.onTap,
  });

  final String name;
  final String? phone;
  final String phrase;
  final String balanceLabel;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final Color accent;
  final String initials;
  final bool isArchived;
  final List<Tag> tags;
  final String insight;
  final bool overdue;
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
                      insight.isEmpty ? phrase : '$phrase • $insight',
                      style: text.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: (isArchived ? AppTheme.ledgerCancel : AppTheme.ledgerPayment)
                            .withValues(alpha: 0.16),
                      ),
                      child: Text(
                        isArchived ? 'ARCHIVED' : 'ACTIVE',
                        style: text.labelSmall?.copyWith(
                          color: isArchived ? AppTheme.ledgerCancel : AppTheme.ledgerPayment,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added ${MoneyFormat.formatDate(createdAt)}${lastActivityAt == null ? '' : ' • Last: ${MoneyFormat.formatDate(lastActivityAt!)}'}',
                      style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags
                            .map(
                              (t) => Chip(
                                label: Text(t.name),
                                avatar: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: _tagColor(t.colorHex),
                                ),
                                backgroundColor: _tagColor(
                                  t.colorHex,
                                ).withValues(alpha: 0.18),
                                side: BorderSide(
                                  color: _tagColor(
                                    t.colorHex,
                                  ).withValues(alpha: 0.75),
                                ),
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
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
                    overdue ? Icons.warning_amber_rounded : Icons.chevron_right,
                    color: overdue
                        ? AppTheme.ledgerCancel
                        : AppTheme.mutedFg.withValues(alpha: 0.6),
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

class _TotalsChip extends StatelessWidget {
  const _TotalsChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

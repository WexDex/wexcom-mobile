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
import '../../widgets/hud_empty_state.dart';
import '../../widgets/skeleton_loaders.dart';
import 'client_editor_sheet.dart';
import '../transactions/transaction_editor_sheet.dart';

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

String _relativeDate(DateTime? dt) {
  if (dt == null) return 'Never';
  final diff = DateTime.now().difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
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
  _ClientSortField _sortField = _ClientSortField.name;
  bool _sortAscending = true;
  bool _selectMode = false;
  final Set<String> _selected = {};

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
      case _ClientSortField.name:        return 'Name';
      case _ClientSortField.updatedAt:   return 'Updated';
      case _ClientSortField.createdAt:   return 'Created';
      case _ClientSortField.balance:     return 'Balance';
      case _ClientSortField.lastActivityAt: return 'Last activity';
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncClients = ref.watch(activeClientsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: _selectMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _selectMode = false;
                  _selected.clear();
                }),
              ),
              title: Text('${_selected.length} selected'),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                  onPressed: _selected.isEmpty ? null : _bulkArchive,
                ),
              ],
            )
          : AppBar(
              title: const Text('Clients'),
              actions: [
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
            return HudEmptyState(
              icon: Icons.people_outline,
              message: 'No clients yet',
              subtitle: 'Tap + to add someone to your ledger.',
            );
          }
          final code = currencyAsync.valueOrNull ?? 'DZD';
          final filtered = clients.where(_matches).toList();
          filtered.sort(_compareClients);

          // Summary header numbers
          int receivableMinor = 0;
          int payableMinor = 0;
          for (final c in clients) {
            if (c.balanceMinor > 0) {
              receivableMinor += c.balanceMinor;
            } else if (c.balanceMinor < 0) {
              payableMinor += -c.balanceMinor;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Summary header strip ──────────────────────────────────────
              _ClientsSummaryHeader(
                activeCount: clients.length,
                receivableMinor: receivableMinor,
                payableMinor: payableMinor,
                currencyCode: code,
              ),
              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
              // ── Sort row ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} of ${clients.length}',
                      style: text.labelMedium?.copyWith(color: AppTheme.mutedFg),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
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
                                for (final f in _ClientSortField.values)
                                  ListTile(
                                    title: Text({
                                      _ClientSortField.name: 'Name',
                                      _ClientSortField.updatedAt: 'Updated',
                                      _ClientSortField.createdAt: 'Created',
                                      _ClientSortField.lastActivityAt: 'Last activity',
                                      _ClientSortField.balance: 'Balance',
                                    }[f]!),
                                    trailing: _sortField == f
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () => Navigator.pop(ctx, f),
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
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _sortAscending = !_sortAscending),
                      tooltip: _sortAscending ? 'Ascending' : 'Descending',
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              // ── List ─────────────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matches for your search.',
                          style: text.bodyLarge?.copyWith(color: AppTheme.mutedFg),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final balanceLabel = MoneyFormat.formatMinor(c.balanceMinor, code);
                          final phrase = balanceSemanticsLine(c.balanceMinor);
                          final accent = balanceColor(c.balanceMinor);
                          final initials = _initials(c.fullName);
                          final tagsAsync = ref.watch(clientTagsProvider(c.id));
                          final insightAsync = ref.watch(clientInsightProvider(c.id));
                          final overdueAsync = ref.watch(clientOverdueProvider(c.id));

                          return GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _selectMode = true;
                                _selected.add(c.id);
                              });
                            },
                            child: Stack(
                              children: [
                                _ClientCard(
                                  name: c.fullName,
                                  phone: c.phone,
                                  phrase: phrase,
                                  balanceLabel: balanceLabel,
                                  lastActivityAt: c.lastInteractionAt,
                                  accent: accent,
                                  initials: initials,
                                  isArchived: c.archivedAt != null,
                                  tags: tagsAsync.valueOrNull ?? const [],
                                  insight: insightAsync.valueOrNull ?? '',
                                  overdue: overdueAsync.valueOrNull ?? false,
                                  onTap: _selectMode
                                      ? () => setState(() {
                                            if (_selected.contains(c.id)) {
                                              _selected.remove(c.id);
                                            } else {
                                              _selected.add(c.id);
                                            }
                                          })
                                      : () => context.push('/client/${c.id}'),
                                  onQuickAdd: _selectMode ? null : () async {
                                    final txTags = await ref.read(
                                      transactionScopeTagsProvider.future,
                                    );
                                    if (!context.mounted) return;
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
                                        child: TransactionEditorSheet(
                                          title: 'Add transaction',
                                          currencyCode: code,
                                          currentBalanceMinor: c.balanceMinor,
                                          availableTags: txTags,
                                          onSubmit: (amount, type, note, tagIds, effectiveAt, dueAt) async {
                                            await ref.read(ledgerRepositoryProvider).insertTransaction(
                                              clientId: c.id,
                                              amountMinor: amount,
                                              type: type,
                                              currencyCode: code,
                                              note: note,
                                              tagIds: tagIds,
                                              effectiveAt: effectiveAt,
                                              dueAt: dueAt,
                                            );
                                            if (ctx.mounted) Navigator.pop(ctx);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_selectMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IgnorePointer(
                                      child: Checkbox(
                                        value: _selected.contains(c.id),
                                        onChanged: null,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: const [ClientListSkeleton()],
        ),
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

  Future<void> _bulkArchive() async {
    final ids = List<String>.from(_selected);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive ${ids.length} client${ids.length == 1 ? '' : 's'}?'),
        content: const Text('Archived clients are hidden from the main list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final repo = ref.read(ledgerRepositoryProvider);
    for (final id in ids) {
      await repo.setClientArchived(id, true);
    }
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
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

// ─────────────────────────────────────────────────────────────────────────────
// Summary header strip
// ─────────────────────────────────────────────────────────────────────────────

class _ClientsSummaryHeader extends StatelessWidget {
  const _ClientsSummaryHeader({
    required this.activeCount,
    required this.receivableMinor,
    required this.payableMinor,
    required this.currencyCode,
  });

  final int activeCount;
  final int receivableMinor;
  final int payableMinor;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _MiniStatChip(
            label: '$activeCount active',
            icon: Icons.people_rounded,
            color: AppTheme.receivableAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStatChip(
              label: 'Recv: ${MoneyFormat.formatMinor(receivableMinor, currencyCode)}',
              icon: Icons.arrow_downward_rounded,
              color: AppTheme.balanceReceivable,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStatChip(
              label: 'Owe: ${MoneyFormat.formatMinor(payableMinor, currencyCode)}',
              icon: Icons.arrow_upward_rounded,
              color: AppTheme.ledgerDebt,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client card (single layout — replaces both compact and comfortable)
// ─────────────────────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.phone,
    required this.phrase,
    required this.balanceLabel,
    required this.lastActivityAt,
    required this.accent,
    required this.initials,
    required this.isArchived,
    required this.tags,
    required this.insight,
    required this.overdue,
    required this.onTap,
    this.onQuickAdd,
  });

  final String name;
  final String? phone;
  final String phrase;
  final String balanceLabel;
  final DateTime? lastActivityAt;
  final Color accent;
  final String initials;
  final bool isArchived;
  final List<Tag> tags;
  final String insight;
  final bool overdue;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 3 px accent left bar ──────────────────────────────
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLg),
                        bottomLeft: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                  ),
                  // ── Card body ─────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: accent.withValues(alpha: 0.18),
                            child: Text(
                              initials,
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Middle column — name, phrase, tags, footer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  name,
                                  style: text.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Semantic phrase
                                Text(
                                  insight.isEmpty ? phrase : '$phrase · $insight',
                                  style: text.labelMedium?.copyWith(
                                    color: AppTheme.mutedFg,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Tag chips
                                if (tags.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 4,
                                    children: tags
                                        .take(3)
                                        .map(
                                          (t) => Chip(
                                            label: Text(t.name),
                                            avatar: CircleAvatar(
                                              radius: 4,
                                              backgroundColor: _tagColor(t.colorHex),
                                            ),
                                            backgroundColor: _tagColor(t.colorHex).withValues(alpha: 0.18),
                                            side: BorderSide(color: _tagColor(t.colorHex).withValues(alpha: 0.75)),
                                            shape: const StadiumBorder(),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                // Footer: phone · last seen
                                Row(
                                  children: [
                                    if (phone != null && phone!.isNotEmpty) ...[
                                      Icon(Icons.phone_outlined, size: 12, color: AppTheme.mutedFg),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          phone!,
                                          style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(Icons.access_time_rounded, size: 12, color: AppTheme.mutedFg),
                                    const SizedBox(width: 4),
                                    Text(
                                      _relativeDate(lastActivityAt),
                                      style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Right column — balance + actions
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Balance — hero element
                              Text(
                                balanceLabel,
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 2),
                              // "They owe you" / "You owe them" label
                              Text(
                                phrase,
                                style: text.labelSmall?.copyWith(
                                  color: AppTheme.mutedFg,
                                ),
                              ),
                              const Spacer(),
                              // Actions row
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (onQuickAdd != null && !isArchived)
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        icon: const Icon(Icons.add_rounded),
                                        color: accent,
                                        tooltip: 'Add transaction',
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          onQuickAdd!();
                                        },
                                      ),
                                    ),
                                  Icon(
                                    overdue
                                        ? Icons.warning_amber_rounded
                                        : Icons.chevron_right,
                                    color: overdue
                                        ? AppTheme.ledgerCancel
                                        : AppTheme.mutedFg.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

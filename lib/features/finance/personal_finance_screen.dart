import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../dashboard/dashboard_charts.dart';

class PersonalFinanceScreen extends ConsumerStatefulWidget {
  const PersonalFinanceScreen({super.key});

  @override
  ConsumerState<PersonalFinanceScreen> createState() => _PersonalFinanceScreenState();
}

class _PersonalFinanceScreenState extends ConsumerState<PersonalFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _chartDays = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PersonalFinanceKind get _kind =>
      _tabController.index == 0 ? PersonalFinanceKind.expense : PersonalFinanceKind.gain;

  Future<void> _openEditor(PersonalFinanceEntry? existing) async {
    final kind = existing != null ? PersonalFinanceKind.fromInt(existing.kind) : _kind;
    final currency = await ref.read(defaultCurrencyProvider.future);
    if (!mounted) return;

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? '${existing.amountMinor}' : '',
    );
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    final color = kind == PersonalFinanceKind.expense
        ? AppTheme.personalExpense
        : AppTheme.personalGain;

    var dayLocal = existing != null
        ? DateTime(
            existing.createdAt.toLocal().year,
            existing.createdAt.toLocal().month,
            existing.createdAt.toLocal().day,
          )
        : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            existing == null
                                ? (kind == PersonalFinanceKind.expense
                                    ? 'New expense'
                                    : 'New gain')
                                : (kind == PersonalFinanceKind.expense
                                    ? 'Edit expense'
                                    : 'Edit gain'),
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          icon: const Icon(Icons.close),
                          color: AppTheme.mutedFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat.yMMMEd().format(dayLocal),
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () async {
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate: dayLocal,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (p != null) {
                            setModal(() {
                              dayLocal = DateTime(p.year, p.month, p.day);
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month_rounded, size: 20),
                        label: const Text('Change'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'What was it?',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        helperText: 'Whole units ($currency)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText: 'Optional',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
                        final title = titleCtrl.text.trim();
                        if (minor == null || minor <= 0 || title.isEmpty) {
                          Navigator.pop(ctx, false);
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(existing == null ? 'Add' : 'Save changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
      final title = titleCtrl.text.trim();
      final note = noteCtrl.text.trim();
      if (minor != null && minor > 0 && title.isNotEmpty) {
        final createdAt = _createdAtUtcForSave(existing: existing, dayLocal: dayLocal);
        final repo = ref.read(ledgerRepositoryProvider);
        if (existing == null) {
          await repo.addPersonalFinanceEntry(
            kind: kind,
            title: title,
            amountMinor: minor,
            currencyCode: currency,
            note: note.isEmpty ? null : note,
            createdAt: createdAt,
          );
        } else {
          await repo.updatePersonalFinanceEntry(
            id: existing.id,
            title: title,
            amountMinor: minor,
            currencyCode: currency,
            note: note.isEmpty ? null : note,
            createdAt: createdAt,
          );
        }
      }
    }
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
  }

  static DateTime _createdAtUtcForSave({
    PersonalFinanceEntry? existing,
    required DateTime dayLocal,
  }) {
    final now = DateTime.now();
    if (existing == null) {
      return DateTime(
        dayLocal.year,
        dayLocal.month,
        dayLocal.day,
        now.hour,
        now.minute,
        now.second,
      ).toUtc();
    }
    final old = existing.createdAt.toLocal();
    return DateTime(
      dayLocal.year,
      dayLocal.month,
      dayLocal.day,
      old.hour,
      old.minute,
      old.second,
      old.millisecond,
      old.microsecond,
    ).toUtc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandPrimary,
          labelColor: AppTheme.brandPrimary,
          unselectedLabelColor: AppTheme.mutedFg,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Gains'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FinanceTabBody(
            kind: PersonalFinanceKind.expense,
            chartDays: _chartDays,
            onDaysChanged: (d) => setState(() => _chartDays = d),
            onOpenEditor: _openEditor,
          ),
          _FinanceTabBody(
            kind: PersonalFinanceKind.gain,
            chartDays: _chartDays,
            onDaysChanged: (d) => setState(() => _chartDays = d),
            onOpenEditor: _openEditor,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(null),
        backgroundColor: _kind == PersonalFinanceKind.expense
            ? AppTheme.personalExpense
            : AppTheme.personalGain,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Groups entries newest-day first; within a day, newest first.
Map<DateTime, List<PersonalFinanceEntry>> _groupByDay(List<PersonalFinanceEntry> entries) {
  final map = <DateTime, List<PersonalFinanceEntry>>{};
  for (final e in entries) {
    final d = DateTime(
      e.createdAt.toLocal().year,
      e.createdAt.toLocal().month,
      e.createdAt.toLocal().day,
    );
    map.putIfAbsent(d, () => []).add(e);
  }
  for (final list in map.values) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  return map;
}

class _FinanceTabBody extends ConsumerWidget {
  const _FinanceTabBody({
    required this.kind,
    required this.chartDays,
    required this.onDaysChanged,
    required this.onOpenEditor,
  });

  final PersonalFinanceKind kind;
  final int chartDays;
  final ValueChanged<int> onDaysChanged;
  final Future<void> Function(PersonalFinanceEntry? existing) onOpenEditor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(personalFinanceEntriesProvider(kind));
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';
    final color = kind == PersonalFinanceKind.expense ? AppTheme.personalExpense : AppTheme.personalGain;

    return entriesAsync.when(
      data: (entries) {
        final totalAll = entries.fold<int>(0, (a, e) => a + e.amountMinor);
        final days = recentCalendarDays(chartDays);
        final startDay = days.first;
        final inRange = entries.where((e) {
          final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
          return !d.isBefore(startDay);
        }).toList();
        final totalRange = inRange.fold<int>(0, (a, e) => a + e.amountMinor);
        final daily = buildPersonalDailyPoints(inRange, chartDays);
        final grouped = _groupByDay(entries);
        final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7d')),
                ButtonSegment(value: 14, label: Text('14d')),
                ButtonSegment(value: 30, label: Text('30d')),
              ],
              selected: {chartDays},
              onSelectionChanged: (s) => onDaysChanged(s.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: 'Total (all time)',
                    value: MoneyFormat.formatMinor(totalAll, code),
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Chart period',
                    value: MoneyFormat.formatMinor(totalRange, code),
                    color: AppTheme.receivableAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ChartCard(
              title: kind == PersonalFinanceKind.expense ? 'Spending per day' : 'Gains per day',
              subtitle: 'Last $chartDays days',
              child: PersonalAmountLineChart(
                points: daily,
                color: color,
                legend: kind == PersonalFinanceKind.expense ? 'Expenses' : 'Gains',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                  style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Newest first · grouped by day · tap a row or ⋮ to edit',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Nothing logged yet. Tap + to add.',
                    style: TextStyle(color: AppTheme.mutedFg),
                  ),
                ),
              )
            else
              for (var i = 0; i < sortedDays.length; i++) ...[
                _DaySectionHeader(
                  day: sortedDays[i],
                  dayTotalMinor: grouped[sortedDays[i]]!.fold<int>(0, (a, e) => a + e.amountMinor),
                  code: code,
                  color: color,
                  showTopDivider: i > 0,
                ),
                ...grouped[sortedDays[i]]!.map(
                  (e) => _EntryCard(
                    entry: e,
                    code: code,
                    color: color,
                    kind: kind,
                    onEdit: () => onOpenEditor(e),
                    onDelete: () => _confirmDelete(context, ref, e),
                  ),
                ),
              ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PersonalFinanceEntry entry,
) async {
  final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete entry?'),
          content: Text('Remove “${entry.title}” permanently?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.destructive),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
  if (ok && context.mounted) {
    await ref.read(ledgerRepositoryProvider).deletePersonalFinanceEntry(entry.id);
  }
}

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({
    required this.day,
    required this.dayTotalMinor,
    required this.code,
    required this.color,
    required this.showTopDivider,
  });

  final DateTime day;
  final int dayTotalMinor;
  final String code;
  final Color color;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: showTopDivider ? 20 : 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DateFormat.yMMMMEEEEd().format(day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            MoneyFormat.formatMinor(dayTotalMinor, code),
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.code,
    required this.color,
    required this.kind,
    required this.onEdit,
    required this.onDelete,
  });

  final PersonalFinanceEntry entry;
  final String code;
  final Color color;
  final PersonalFinanceKind kind;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(entry.createdAt.toLocal());
    final note = entry.note?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.inputFill.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  child: Icon(
                    kind == PersonalFinanceKind.expense ? Icons.south_west : Icons.north_east,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: AppTheme.mutedFg),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
                          ),
                        ],
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          note,
                          style: TextStyle(color: AppTheme.mutedFg.withValues(alpha: 0.95), height: 1.35),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormat.formatMinor(entry.amountMinor, code),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: AppTheme.mutedFg),
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: AppTheme.destructive)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

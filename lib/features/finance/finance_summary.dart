import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_icon.dart';
import '../../utils/money.dart';
import 'finance_period.dart';

Color categoryColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (cleaned.length != 6 || value == null) return AppTheme.mutedFg;
  return Color(0xFF000000 | value);
}

int sumEntriesInRange(Iterable<PersonalFinanceEntry> entries, DateTime start, DateTime end) {
  var total = 0;
  for (final e in entries) {
    if (dateInFinanceRange(e.createdAt, start, end)) total += e.amountMinor;
  }
  return total;
}

/// Amount for one category in a window. [category] null = uncategorized.
class CategoryTotal {
  const CategoryTotal({required this.category, required this.amountMinor});

  final ExpenseCategory? category;
  final int amountMinor;

  String? get id => category?.id;
  String get name => category?.name ?? 'Uncategorized';
  Color get color => category == null ? AppTheme.mutedFg : categoryColor(category!.colorHex);
}

/// Totals per category for entries in [start]..[end], largest first.
List<CategoryTotal> categoryTotals(
  Iterable<PersonalFinanceEntry> entries,
  List<ExpenseCategory> categories,
  DateTime start,
  DateTime end,
) {
  final byId = {for (final c in categories) c.id: c};
  final sums = <String?, int>{};
  for (final e in entries) {
    if (!dateInFinanceRange(e.createdAt, start, end)) continue;
    final key = byId.containsKey(e.categoryId) ? e.categoryId : null;
    sums[key] = (sums[key] ?? 0) + e.amountMinor;
  }
  final list = [
    for (final entry in sums.entries)
      if (entry.value > 0)
        CategoryTotal(category: entry.key == null ? null : byId[entry.key], amountMinor: entry.value),
  ]..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
  return list;
}

typedef CategorySummaryKey = ({PersonalFinanceKind kind, DateTime start, DateTime end});

/// Category totals for a kind (expense/gain) over a window.
final categorySpendSummaryProvider = Provider.autoDispose
    .family<AsyncValue<List<CategoryTotal>>, CategorySummaryKey>((ref, key) {
  final scope = key.kind == PersonalFinanceKind.expense ? 'expense' : 'gain';
  final entries = ref.watch(personalFinanceEntriesProvider(key.kind));
  final cats = ref.watch(expenseCategoriesProvider(scope));
  return entries.whenData(
    (rows) => categoryTotals(rows, cats.valueOrNull ?? const [], key.start, key.end),
  );
});

/// Current vs previous window comparison.
class PulseWindow {
  const PulseWindow({required this.label, required this.currentMinor, required this.previousMinor});

  final String label;
  final int currentMinor;
  final int previousMinor;

  /// Percent change vs previous; null when there is nothing to compare against.
  double? get changePct =>
      previousMinor == 0 ? null : (currentMinor - previousMinor) * 100 / previousMinor;
}

/// Last 7 days vs prior 7 days, and last calendar week vs the week before.
({PulseWindow rolling, PulseWindow lastWeek}) spendingPulse(
  Iterable<PersonalFinanceEntry> expenses,
) {
  const week = Duration(days: 7);
  final r = financePeriodRange(FinancePeriod.last7Days);
  final w = financePeriodRange(FinancePeriod.lastWeek);
  return (
    rolling: PulseWindow(
      label: 'Last 7 days',
      currentMinor: sumEntriesInRange(expenses, r.start, r.end),
      previousMinor: sumEntriesInRange(expenses, r.start.subtract(week), r.end.subtract(week)),
    ),
    lastWeek: PulseWindow(
      label: 'Last week',
      currentMinor: sumEntriesInRange(expenses, w.start, w.end),
      previousMinor: sumEntriesInRange(expenses, w.start.subtract(week), w.end.subtract(week)),
    ),
  );
}

/// Stacked color bar + chips showing how a total splits across categories.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
    required this.totals,
    required this.currencyCode,
    this.selectedId,
    this.onTap,
    this.maxChips = 6,
  });

  final List<CategoryTotal> totals;
  final String currencyCode;
  final String? selectedId;
  final ValueChanged<CategoryTotal>? onTap;
  final int maxChips;

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final sum = totals.fold<int>(0, (s, t) => s + t.amountMinor);
    final shown = totals.take(maxChips).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (final t in totals)
                  Expanded(
                    flex: (t.amountMinor * 1000 ~/ (sum == 0 ? 1 : sum)).clamp(1, 1000),
                    child: Container(color: t.color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in shown)
              _CategoryChip(
                total: t,
                pct: sum == 0 ? 0 : (t.amountMinor * 100 / sum).round(),
                currencyCode: currencyCode,
                selected: selectedId != null && selectedId == t.id,
                onTap: onTap == null ? null : () => onTap!(t),
                text: text,
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.total,
    required this.pct,
    required this.currencyCode,
    required this.selected,
    required this.onTap,
    required this.text,
  });

  final CategoryTotal total;
  final int pct;
  final String currencyCode;
  final bool selected;
  final VoidCallback? onTap;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    final c = total.color;
    return Material(
      color: c.withValues(alpha: selected ? 0.28 : 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.withValues(alpha: selected ? 0.9 : 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                total.category == null
                    ? Icons.label_off_outlined
                    : categoryIconData(total.category!.iconCodePoint),
                size: 14,
                color: c,
              ),
              const SizedBox(width: 5),
              Text(
                '${total.name} · ${MoneyFormat.formatMinor(total.amountMinor, currencyCode)} · $pct%',
                style: text.labelSmall?.copyWith(color: c, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

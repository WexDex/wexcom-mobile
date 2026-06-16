import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_icon.dart';
import '../../utils/money.dart';
import '../../services/notification_service.dart';
import '../../utils/subscription_schedule.dart';
import '../../widgets/currency_amount_input.dart';
import '../dashboard/dashboard_charts.dart';
import 'expense_categories_screen.dart';
import 'wallet_tab.dart';
import 'wishlist_wallet_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Period type for analytics / chart selector
// ─────────────────────────────────────────────────────────────────────────────

enum _FinancePeriod { thisWeek, thisMonth, lastMonth, custom }

/// Computes inclusive (start, end) date-range from a [_FinancePeriod].
/// For [_FinancePeriod.custom] supply [customStart] / [customEnd];
/// fallback is the current month.
({DateTime start, DateTime end}) _periodRange(
  _FinancePeriod period, {
  DateTime? customStart,
  DateTime? customEnd,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case _FinancePeriod.thisWeek:
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return (start: weekStart, end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
    case _FinancePeriod.thisMonth:
      return (
        start: DateTime(now.year, now.month, 1),
        end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      );
    case _FinancePeriod.lastMonth:
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
      return (start: lastMonth, end: lastMonthEnd);
    case _FinancePeriod.custom:
      final s = customStart ?? DateTime(now.year, now.month, 1);
      final e = customEnd ?? today.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      return (start: s, end: e.isAfter(s) ? e : s);
  }
}

/// Computes window start for a category's budget period.
DateTime _budgetWindowStart(ExpenseCategory cat) {
  final now = DateTime.now();
  return switch (cat.budgetPeriod) {
    'week' => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: DateTime.now().weekday - 1)),
    'custom' => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: (cat.budgetCustomDays ?? 30) - 1)),
    _ => DateTime(now.year, now.month, 1),
  };
}

String _budgetPeriodWindowLabel(ExpenseCategory cat) {
  return switch (cat.budgetPeriod) {
    'week' => 'this week',
    'custom' => 'last ${cat.budgetCustomDays ?? 30}d',
    _ => 'this month',
  };
}

class PersonalFinanceScreen extends ConsumerStatefulWidget {
  const PersonalFinanceScreen({super.key, this.initialTabKey});

  /// Optional tab: `expenses`, `gains`, `wishlist`, `wallet`.
  final String? initialTabKey;

  @override
  ConsumerState<PersonalFinanceScreen> createState() => _PersonalFinanceScreenState();
}

class _PersonalFinanceScreenState extends ConsumerState<PersonalFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _FinancePeriod _period = _FinancePeriod.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyInitialTab());
  }

  void _applyInitialTab() {
    final key = widget.initialTabKey?.toLowerCase();
    if (key == null) return;
    final index = switch (key) {
      'expenses' || 'expense' => 0,
      'gains' || 'gain' => 1,
      'wishlist' || 'subscriptions' || 'subs' => 2,
      'wallet' => 3,
      _ => 0,
    };
    if (_tabController.index != index) {
      _tabController.index = index;
      if (mounted) setState(() {});
    }
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
    final repo = ref.read(ledgerRepositoryProvider);
    final foreign = await repo.foreignCurrencyEditorContext();
    if (!mounted) return;

    final categories = ref
        .read(expenseCategoriesProvider(kind == PersonalFinanceKind.expense ? 'expense' : 'gain'))
        .valueOrNull ?? [];

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? '${existing.amountMinor}' : '',
    );
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    final initialSnap = FromCurrencySnapshot.fromJsonString(existing?.fromCurrencyJson);
    FromCurrencySnapshot? fromSnap = initialSnap;
    final amountKey = GlobalKey<CurrencyAmountInputState>();
    final color = kind == PersonalFinanceKind.expense
        ? AppTheme.personalExpense
        : AppTheme.personalGain;

    String? selectedCategoryId = existing?.categoryId;

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
                                ? (kind == PersonalFinanceKind.expense ? 'New expense' : 'New gain')
                                : (kind == PersonalFinanceKind.expense ? 'Edit expense' : 'Edit gain'),
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
                    // Date picker
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
                    CurrencyAmountInput(
                      key: amountKey,
                      defaultCurrencyCode: currency,
                      amountMinorController: amountCtrl,
                      currencyCodes: foreign.codes,
                      rates: foreign.rates,
                      initialSnapshot: initialSnap,
                      onSnapshotChanged: (s) => fromSnap = s,
                    ),
                    // Category chips
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Category',
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                          color: AppTheme.mutedFg,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // "None" chip
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: const Text('None'),
                                selected: selectedCategoryId == null,
                                onSelected: (_) => setModal(() => selectedCategoryId = null),
                              ),
                            ),
                            ...categories.map((cat) {
                              final catColor = _hexColor(cat.colorHex);
                              final isSelected = selectedCategoryId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  avatar: Icon(
                                    categoryIconData(cat.iconCodePoint),
                                    size: 16,
                                    color: isSelected ? catColor : AppTheme.mutedFg,
                                  ),
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  selectedColor: catColor.withValues(alpha: 0.2),
                                  side: BorderSide(
                                    color: isSelected
                                        ? catColor
                                        : AppTheme.mutedFg.withValues(alpha: 0.3),
                                  ),
                                  checkmarkColor: catColor,
                                  onSelected: (_) =>
                                      setModal(() => selectedCategoryId = cat.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
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
                        fromSnap = amountKey.currentState?.buildSnapshot();
                        final minor =
                            MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) {
                          Navigator.pop(ctx, false);
                          return;
                        }
                        final foreignOn =
                            amountKey.currentState?.foreignModeEnabled ?? false;
                        if (foreignOn && (minor == null || minor <= 0)) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Set an exchange rate in Tags → Currencies, '
                                'then enter the foreign or default amount',
                              ),
                            ),
                          );
                          return;
                        }
                        if (minor == null || minor <= 0) {
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
      fromSnap = amountKey.currentState?.buildSnapshot() ?? fromSnap;
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
            categoryId: selectedCategoryId,
            createdAt: createdAt,
            fromCurrency: fromSnap,
          );
        } else {
          await repo.updatePersonalFinanceEntry(
            id: existing.id,
            title: title,
            amountMinor: minor,
            currencyCode: currency,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            clearCategory: selectedCategoryId == null,
            createdAt: createdAt,
            fromCurrency: fromSnap,
            clearFromCurrency: fromSnap == null,
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
        dayLocal.year, dayLocal.month, dayLocal.day,
        now.hour, now.minute, now.second,
      ).toUtc();
    }
    final old = existing.createdAt.toLocal();
    return DateTime(
      dayLocal.year, dayLocal.month, dayLocal.day,
      old.hour, old.minute, old.second, old.millisecond, old.microsecond,
    ).toUtc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage categories',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ExpenseCategoriesScreen(),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandPrimary,
          labelColor: AppTheme.brandPrimary,
          unselectedLabelColor: AppTheme.mutedFg,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Gains'),
            Tab(text: 'Wishlist & Subs'),
            Tab(text: 'Wallet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FinanceTabBody(
            kind: PersonalFinanceKind.expense,
            period: _period,
            customStart: _customStart,
            customEnd: _customEnd,
            onPeriodChanged: (p, s, e) =>
                setState(() { _period = p; _customStart = s; _customEnd = e; }),
            onOpenEditor: _openEditor,
          ),
          _FinanceTabBody(
            kind: PersonalFinanceKind.gain,
            period: _period,
            customStart: _customStart,
            customEnd: _customEnd,
            onPeriodChanged: (p, s, e) =>
                setState(() { _period = p; _customStart = s; _customEnd = e; }),
            onOpenEditor: _openEditor,
          ),
          _WishlistTabBody(
            onOpenWishlistEditor: _openWishlistEditor,
            onOpenSubscriptionEditor: _openSubscriptionEditor,
          ),
          const WalletTabBody(),
        ],
      ),
      floatingActionButton: _tabController.index < 2
          ? FloatingActionButton(
              onPressed: () => _openEditor(null),
              backgroundColor: _kind == PersonalFinanceKind.expense
                  ? AppTheme.personalExpense
                  : AppTheme.personalGain,
              foregroundColor: Colors.black87,
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: _showWishlistFabMenu,
              backgroundColor: AppTheme.brandSecondary,
              foregroundColor: Colors.black87,
              child: const Icon(Icons.add_shopping_cart_rounded),
            ),
    );
  }

  Future<void> _showWishlistFabMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Wishlist item'),
              onTap: () => Navigator.pop(ctx, 'wishlist'),
            ),
            ListTile(
              leading: const Icon(Icons.autorenew_rounded),
              title: const Text('Subscription'),
              onTap: () => Navigator.pop(ctx, 'subscription'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'wishlist') {
      await _openWishlistEditor(null);
    } else {
      await _openSubscriptionEditor(null);
    }
  }

  Future<void> _openWishlistEditor(WishlistItem? existing) async {
    final currency = await ref.read(defaultCurrencyProvider.future);
    final repo = ref.read(ledgerRepositoryProvider);
    final foreign = await repo.foreignCurrencyEditorContext();
    if (!mounted) return;
    final categories = ref.read(expenseCategoriesProvider('expense')).valueOrNull ?? [];

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? '${existing.amountMinor}' : '',
    );
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    String? selectedCategoryId = existing?.categoryId;
    final initialSnap = FromCurrencySnapshot.fromJsonString(existing?.fromCurrencyJson);
    FromCurrencySnapshot? fromSnap = initialSnap;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
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
                        existing == null ? 'Add to wishlist' : 'Edit wishlist item',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          color: AppTheme.brandSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Item name', hintText: 'e.g. New headphones'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                CurrencyAmountInput(
                  defaultCurrencyCode: currency,
                  amountMinorController: amountCtrl,
                  currencyCodes: foreign.codes,
                  rates: foreign.rates,
                  initialSnapshot: initialSnap,
                  amountLabel: 'Estimated price',
                  onSnapshotChanged: (s) => fromSnap = s,
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Category',
                    style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: const Text('None'),
                            selected: selectedCategoryId == null,
                            onSelected: (_) => setModal(() => selectedCategoryId = null),
                          ),
                        ),
                        ...categories.map((cat) {
                          final catColor = _hexColor(cat.colorHex);
                          final isSelected = selectedCategoryId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              avatar: Icon(categoryIconData(cat.iconCodePoint),
                                  size: 16, color: isSelected ? catColor : AppTheme.mutedFg),
                              label: Text(cat.name),
                              selected: isSelected,
                              selectedColor: catColor.withValues(alpha: 0.2),
                              onSelected: (_) => setModal(() => selectedCategoryId = cat.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note / link', hintText: 'Optional'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
                    if (minor == null || minor <= 0 || titleCtrl.text.trim().isEmpty) {
                      Navigator.pop(ctx, false);
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.brandSecondary,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(existing == null ? 'Add to wishlist' : 'Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
      final title = titleCtrl.text.trim();
      final note = noteCtrl.text.trim();
      if (minor != null && minor > 0 && title.isNotEmpty) {
        final repo = ref.read(ledgerRepositoryProvider);
        if (existing == null) {
          await repo.addWishlistItem(
            title: title,
            amountMinor: minor,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            currencyCode: currency,
            fromCurrency: fromSnap,
          );
        } else {
          await repo.updateWishlistItem(
            id: existing.id,
            title: title,
            amountMinor: minor,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            clearCategory: selectedCategoryId == null,
            fromCurrency: fromSnap,
            clearFromCurrency: fromSnap == null,
          );
        }
      }
    }
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
  }

  Future<void> _openSubscriptionEditor(SubscriptionItem? existing) async {
    final currency = await ref.read(defaultCurrencyProvider.future);
    final repo = ref.read(ledgerRepositoryProvider);
    final foreign = await repo.foreignCurrencyEditorContext();
    if (!mounted) return;
    final categories = ref.read(expenseCategoriesProvider('expense')).valueOrNull ?? [];

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? '${existing.amountMinor}' : '',
    );
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    final rollingCtrl = TextEditingController(
      text: '${existing?.rollingDays ?? 30}',
    );
    final warnCtrl = TextEditingController(
      text: existing?.warnBeforeDays != null ? '${existing!.warnBeforeDays}' : '',
    );
    String? selectedCategoryId = existing?.categoryId;
    final initialSnap = FromCurrencySnapshot.fromJsonString(existing?.fromCurrencyJson);
    FromCurrencySnapshot? fromSnap = initialSnap;
    var scheduleType = existing != null
        ? SubscriptionScheduleType.fromStorage(existing.scheduleType)
        : SubscriptionScheduleType.rollingDays;
    var billingDay = existing?.billingDayOfMonth ?? DateTime.now().day;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
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
                        existing == null ? 'New subscription' : 'Edit subscription',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          color: AppTheme.brandPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                CurrencyAmountInput(
                  defaultCurrencyCode: currency,
                  amountMinorController: amountCtrl,
                  currencyCodes: foreign.codes,
                  rates: foreign.rates,
                  initialSnapshot: initialSnap,
                  onSnapshotChanged: (s) => fromSnap = s,
                ),
                const SizedBox(height: 12),
                Text('Schedule',
                    style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg)),
                const SizedBox(height: 6),
                SegmentedButton<SubscriptionScheduleType>(
                  segments: const [
                    ButtonSegment(
                      value: SubscriptionScheduleType.dayOfMonth,
                      label: Text('Day of month'),
                    ),
                    ButtonSegment(
                      value: SubscriptionScheduleType.rollingDays,
                      label: Text('Rolling'),
                    ),
                  ],
                  selected: {scheduleType},
                  onSelectionChanged: (s) => setModal(() => scheduleType = s.first),
                ),
                const SizedBox(height: 12),
                if (scheduleType == SubscriptionScheduleType.dayOfMonth)
                  DropdownButtonFormField<int>(
                    value: billingDay.clamp(1, 31),
                    decoration: const InputDecoration(labelText: 'Billing day'),
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                    ),
                    onChanged: (v) {
                      if (v != null) setModal(() => billingDay = v);
                    },
                  )
                else
                  TextField(
                    controller: rollingCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Every N days',
                      helperText: 'Default 30',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Category',
                      style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: const Text('None'),
                            selected: selectedCategoryId == null,
                            onSelected: (_) => setModal(() => selectedCategoryId = null),
                          ),
                        ),
                        ...categories.map((cat) {
                          final catColor = _hexColor(cat.colorHex);
                          final isSelected = selectedCategoryId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              selectedColor: catColor.withValues(alpha: 0.2),
                              onSelected: (_) => setModal(() => selectedCategoryId = cat.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note', hintText: 'Optional'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: warnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Warn me N days before due (optional)',
                    helperText: 'Leave empty to disable warning',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
                    if (minor == null || minor <= 0 || titleCtrl.text.trim().isEmpty) {
                      Navigator.pop(ctx, false);
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: Text(existing == null ? 'Add subscription' : 'Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
      final title = titleCtrl.text.trim();
      final note = noteCtrl.text.trim();
      final rolling = int.tryParse(rollingCtrl.text.trim()) ?? 30;
      final warnDays = int.tryParse(warnCtrl.text.trim());
      if (minor != null && minor > 0 && title.isNotEmpty) {
        String newId;
        if (existing == null) {
          newId = await repo.addSubscriptionItem(
            title: title,
            amountMinor: minor,
            scheduleType: scheduleType,
            billingDayOfMonth:
                scheduleType == SubscriptionScheduleType.dayOfMonth ? billingDay : null,
            rollingDays: scheduleType == SubscriptionScheduleType.rollingDays ? rolling : null,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            fromCurrency: fromSnap,
            warnBeforeDays: warnDays,
          );
        } else {
          await repo.updateSubscriptionItem(
            id: existing.id,
            title: title,
            amountMinor: minor,
            scheduleType: scheduleType,
            billingDayOfMonth:
                scheduleType == SubscriptionScheduleType.dayOfMonth ? billingDay : null,
            rollingDays: scheduleType == SubscriptionScheduleType.rollingDays ? rolling : null,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            fromCurrency: fromSnap,
            clearFromCurrency: fromSnap == null,
            warnBeforeDays: warnDays,
            clearWarnBeforeDays: warnDays == null,
          );
          newId = existing.id;
        }
        // Schedule or cancel warning notification
        final savedSubs = await repo.subscriptionsDueForReminder(withinDays: 366);
        final saved2 = savedSubs.where((s) => s.id == newId).firstOrNull;
        if (saved2 != null && warnDays != null && warnDays > 0) {
          await _NotificationHelper.scheduleSubWarning(saved2);
        } else {
          await _NotificationHelper.cancelSubWarning(newId);
        }
      }
    }
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    rollingCtrl.dispose();
    warnCtrl.dispose();
  }
}

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

abstract final class _NotificationHelper {
  static Future<void> scheduleSubWarning(SubscriptionItem sub) async {
    final warn = sub.warnBeforeDays;
    if (warn == null || warn <= 0) return;
    await NotificationService.scheduleSubscriptionWarning(
      subscriptionId: sub.id,
      dueAt: sub.nextDueAt,
      warnBeforeDays: warn,
      title: sub.title,
      amountMinor: sub.amountMinor,
      currencyCode: sub.currencyCode,
    );
  }

  static Future<void> cancelSubWarning(String subscriptionId) async {
    await NotificationService.cancelSubscriptionWarning(subscriptionId);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expense / Gain tab body
// ─────────────────────────────────────────────────────────────────────────────

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

class _FinanceTabBody extends ConsumerStatefulWidget {
  const _FinanceTabBody({
    required this.kind,
    required this.period,
    required this.onPeriodChanged,
    required this.onOpenEditor,
    this.customStart,
    this.customEnd,
  });

  final PersonalFinanceKind kind;
  final _FinancePeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;
  final void Function(_FinancePeriod, DateTime?, DateTime?) onPeriodChanged;
  final Future<void> Function(PersonalFinanceEntry? existing) onOpenEditor;

  @override
  ConsumerState<_FinanceTabBody> createState() => _FinanceTabBodyState();
}

class _FinanceTabBodyState extends ConsumerState<_FinanceTabBody> {
  String? _filterCategoryId; // null = show all

  Future<void> _openCustomPicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: widget.customStart != null && widget.customEnd != null
          ? DateTimeRange(start: widget.customStart!, end: widget.customEnd!)
          : null,
    );
    if (range != null) {
      widget.onPeriodChanged(
        _FinancePeriod.custom,
        DateTime(range.start.year, range.start.month, range.start.day),
        DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = widget.kind == PersonalFinanceKind.expense ? 'expense' : 'gain';
    final otherKind = widget.kind == PersonalFinanceKind.expense
        ? PersonalFinanceKind.gain
        : PersonalFinanceKind.expense;
    final entriesAsync = ref.watch(personalFinanceEntriesProvider(widget.kind));
    final otherEntriesAsync = ref.watch(personalFinanceEntriesProvider(otherKind));
    final categoriesAsync = ref.watch(expenseCategoriesProvider(scope));
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';
    final color = widget.kind == PersonalFinanceKind.expense
        ? AppTheme.personalExpense
        : AppTheme.personalGain;
    final categories = categoriesAsync.valueOrNull ?? [];

    final range = _periodRange(
      widget.period,
      customStart: widget.customStart,
      customEnd: widget.customEnd,
    );

    return entriesAsync.when(
      data: (allEntries) {
        final otherEntries = otherEntriesAsync.valueOrNull ?? [];

        // ── Period filtering ──────────────────────────────────────────────
        final inRange = allEntries.where((e) {
          final local = e.createdAt.toLocal();
          return !local.isBefore(range.start) && !local.isAfter(range.end);
        }).toList();

        final otherInRange = otherEntries.where((e) {
          final local = e.createdAt.toLocal();
          return !local.isBefore(range.start) && !local.isAfter(range.end);
        }).toList();

        // ── Previous period for trend ─────────────────────────────────────
        final duration = range.end.difference(range.start);
        final prevEnd = range.start.subtract(const Duration(seconds: 1));
        final prevStart = prevEnd.subtract(duration);
        final prevInRange = allEntries.where((e) {
          final local = e.createdAt.toLocal();
          return !local.isBefore(prevStart) && !local.isAfter(prevEnd);
        }).toList();

        final totalRange = inRange.fold<int>(0, (a, e) => a + e.amountMinor);
        final totalPrev = prevInRange.fold<int>(0, (a, e) => a + e.amountMinor);
        final otherTotal = otherInRange.fold<int>(0, (a, e) => a + e.amountMinor);

        // ── Per-category spend for the period ─────────────────────────────
        final spendByCat = <String, int>{};
        for (final e in inRange) {
          final key = e.categoryId ?? '__none__';
          spendByCat[key] = (spendByCat[key] ?? 0) + e.amountMinor;
        }

        // ── Budget window spend (per-category period, independent) ────────
        final budgetCats =
            categories.where((c) => c.budgetMinorPerMonth != null && c.budgetMinorPerMonth! > 0);
        final budgetSpend = <String, int>{};
        for (final cat in budgetCats) {
          final windowStart = _budgetWindowStart(cat);
          for (final e in allEntries) {
            if (e.categoryId == cat.id &&
                !e.createdAt.toLocal().isBefore(windowStart)) {
              budgetSpend[cat.id] = (budgetSpend[cat.id] ?? 0) + e.amountMinor;
            }
          }
        }

        // ── Apply category filter for history list ────────────────────────
        final filteredEntries = _filterCategoryId == null
            ? allEntries
            : allEntries.where((e) => e.categoryId == _filterCategoryId).toList();
        final grouped = _groupByDay(filteredEntries);
        final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        // ── Chart: use the period range for daily points ──────────────────
        final dayCount = duration.inDays.clamp(1, 90) + 1;
        final daily = buildPersonalDailyPoints(inRange, dayCount);

        // ── Stats ─────────────────────────────────────────────────────────
        final days = duration.inDays + 1;
        final dailyAvg = days > 0 ? totalRange ~/ days : 0;
        final weeklyAvg = days >= 7 ? (totalRange / (days / 7)).round() : totalRange;

        // ── Top category ──────────────────────────────────────────────────
        String? topCatId;
        int topCatAmount = 0;
        spendByCat.forEach((id, amt) {
          if (id != '__none__' && amt > topCatAmount) {
            topCatAmount = amt;
            topCatId = id;
          }
        });
        final topCat = topCatId != null
            ? categories.where((c) => c.id == topCatId).firstOrNull
            : null;
        final topPct = totalRange > 0 && topCatAmount > 0
            ? (topCatAmount / totalRange * 100).round()
            : 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // ── Budget progress bars ────────────────────────────────────────
            if (widget.kind == PersonalFinanceKind.expense && budgetCats.isNotEmpty) ...[
              ...budgetCats.map((cat) {
                final spent = budgetSpend[cat.id] ?? 0;
                final budget = cat.budgetMinorPerMonth!;
                final pct = (spent / budget).clamp(0.0, 1.0);
                final catColor = _hexColor(cat.colorHex);
                final barColor = pct >= 1.0
                    ? AppTheme.ledgerDebt
                    : pct >= 0.8
                        ? AppTheme.ledgerCancel
                        : catColor;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(categoryIconData(cat.iconCodePoint), size: 16, color: catColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(cat.name,
                                      style: Theme.of(context).textTheme.labelMedium),
                                ),
                                Text(
                                  '${MoneyFormat.formatMinor(spent, code)} / ${MoneyFormat.formatMinor(budget, code)} · ${_budgetPeriodWindowLabel(cat)}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: barColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: barColor.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 20),
            ],

            // ── Period selector ─────────────────────────────────────────────
            _PeriodSelector(
              selected: widget.period,
              customStart: widget.customStart,
              customEnd: widget.customEnd,
              onSelected: (p) {
                if (p == _FinancePeriod.custom) {
                  _openCustomPicker();
                } else {
                  widget.onPeriodChanged(p, null, null);
                }
              },
            ),
            const SizedBox(height: 12),

            // ── Stat row ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: 'Period total',
                    value: MoneyFormat.formatMinor(totalRange, code),
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Daily avg',
                    value: MoneyFormat.formatMinor(dailyAvg, code),
                    color: AppTheme.receivableAccent,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Weekly avg',
                    value: MoneyFormat.formatMinor(weeklyAvg, code),
                    color: AppTheme.brandSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Trend card ─────────────────────────────────────────────────
            _TrendCard(
              current: totalRange,
              previous: totalPrev,
              code: code,
              color: color,
              isExpense: widget.kind == PersonalFinanceKind.expense,
            ),
            const SizedBox(height: 10),

            // ── Expenses vs Gains comparison bar ───────────────────────────
            _ComparisonBar(
              expenseTotal: widget.kind == PersonalFinanceKind.expense ? totalRange : otherTotal,
              gainTotal: widget.kind == PersonalFinanceKind.gain ? totalRange : otherTotal,
              code: code,
            ),
            const SizedBox(height: 20),

            // ── Chart ──────────────────────────────────────────────────────
            ChartCard(
              title: widget.kind == PersonalFinanceKind.expense
                  ? 'Spending per day'
                  : 'Gains per day',
              subtitle: _periodLabel(widget.period, widget.customStart, widget.customEnd),
              child: PersonalAmountLineChart(
                points: daily,
                color: color,
                legend: widget.kind == PersonalFinanceKind.expense ? 'Expenses' : 'Gains',
              ),
            ),

            // ── Top category highlight ─────────────────────────────────────
            if (topCat != null) ...[
              const SizedBox(height: 16),
              _TopCategoryCard(
                category: topCat,
                amount: topCatAmount,
                percentage: topPct,
                code: code,
              ),
            ],

            // ── Category breakdown list ─────────────────────────────────────
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'By category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              _CategoryBreakdownList(
                categories: categories,
                spendByCat: spendByCat,
                totalRange: totalRange,
                code: code,
                filterCategoryId: _filterCategoryId,
                onCategoryTap: (catId) {
                  setState(() {
                    _filterCategoryId = (_filterCategoryId == catId) ? null : catId;
                  });
                },
                onCategoryDetailTap: (cat) => _showCategoryDetail(context, cat, range),
              ),
            ],

            // ── History header ─────────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              children: [
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${filteredEntries.length} ${filteredEntries.length == 1 ? 'entry' : 'entries'}',
                  style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'All time · newest first · tap to edit',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (filteredEntries.isEmpty)
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
                  dayTotalMinor:
                      grouped[sortedDays[i]]!.fold<int>(0, (a, e) => a + e.amountMinor),
                  code: code,
                  color: color,
                  showTopDivider: i > 0,
                ),
                ...grouped[sortedDays[i]]!.map(
                  (e) => _EntryCard(
                    entry: e,
                    code: code,
                    color: color,
                    kind: widget.kind,
                    categoryLabel: categories
                        .where((c) => c.id == e.categoryId)
                        .map((c) => c.name)
                        .firstOrNull,
                    onEdit: () => widget.onOpenEditor(e),
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

  void _showCategoryDetail(
    BuildContext context,
    ExpenseCategory cat,
    ({DateTime start, DateTime end}) range,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => _CategoryDetailSheet(
        category: cat,
        kind: widget.kind,
        periodStart: range.start,
        periodEnd: range.end,
        onOpenEditor: widget.onOpenEditor,
      ),
    );
  }
}

String _periodLabel(
  _FinancePeriod period,
  DateTime? customStart,
  DateTime? customEnd,
) {
  return switch (period) {
    _FinancePeriod.thisWeek => 'This week',
    _FinancePeriod.thisMonth => 'This month',
    _FinancePeriod.lastMonth => 'Last month',
    _FinancePeriod.custom => customStart != null && customEnd != null
        ? '${DateFormat.MMMd().format(customStart)} – ${DateFormat.MMMd().format(customEnd)}'
        : 'Custom',
  };
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
          content: Text('Remove "${entry.title}" permanently?'),
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

// ─────────────────────────────────────────────────────────────────────────────
// Wishlist tab
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistTabBody extends ConsumerWidget {
  const _WishlistTabBody({
    required this.onOpenWishlistEditor,
    required this.onOpenSubscriptionEditor,
  });

  final Future<void> Function(WishlistItem?) onOpenWishlistEditor;
  final Future<void> Function(SubscriptionItem?) onOpenSubscriptionEditor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wishlistItemsProvider(false));
    final subsAsync = ref.watch(subscriptionsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';
    final text = Theme.of(context).textTheme;

    return itemsAsync.when(
      data: (items) {
        return subsAsync.when(
          data: (subs) {
            final total = items.fold<int>(0, (s, i) => s + i.amountMinor);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text('Wishlist',
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 18, color: AppTheme.brandSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '${items.length} item${items.length == 1 ? '' : 's'} · ${MoneyFormat.formatMinor(total, code)}',
                          style: text.labelMedium?.copyWith(color: AppTheme.mutedFg),
                        ),
                      ],
                    ),
                  ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text('Nothing on your list yet',
                        style: text.bodySmall?.copyWith(color: AppTheme.mutedFg)),
                  )
                else
                  ...items.map(
                    (item) => _WishlistItemCard(
                      item: item,
                      code: code,
                      onEdit: () => onOpenWishlistEditor(item),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Subscriptions',
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (subs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No subscriptions yet — tap + to add',
                        style: text.bodySmall?.copyWith(color: AppTheme.mutedFg)),
                  )
                else
                  ...subs.map(
                    (sub) => _SubscriptionItemCard(
                      item: sub,
                      code: code,
                      onEdit: () => onOpenSubscriptionEditor(sub),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _WishlistItemCard extends ConsumerWidget {
  const _WishlistItemCard({
    required this.item,
    required this.code,
    required this.onEdit,
  });

  final WishlistItem item;
  final String code;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.brandSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.brandSecondary.withValues(alpha: 0.15),
            child: Icon(Icons.shopping_bag_outlined,
                color: AppTheme.brandSecondary, size: 20),
          ),
          title: Text(item.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MoneyFormat.formatMinor(item.amountMinor, code),
                style: text.labelLarge?.copyWith(
                  color: AppTheme.brandSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.note != null && item.note!.isNotEmpty)
                Text(
                  item.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              // Mark purchased
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 22),
                color: AppTheme.balanceReceivable,
                tooltip: 'Mark as purchased',
                onPressed: () => _markPurchased(context, ref),
              ),
              // Delete
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppTheme.ledgerDebt,
                tooltip: 'Remove',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove item?'),
                      content: Text(item.title),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await ref.read(ledgerRepositoryProvider).deleteWishlistItem(item.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markPurchased(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ledgerRepositoryProvider);
    await repo.markWishlistPurchased(item.id);
    await repo.addPersonalFinanceEntry(
      kind: PersonalFinanceKind.expense,
      title: item.title,
      amountMinor: item.amountMinor,
      currencyCode: item.currencyCode,
      note: item.note,
      categoryId: item.categoryId,
    );
    if (!context.mounted) return;
    await showWishlistWalletSheet(context: context, ref: ref, item: item);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${item.title}" marked purchased')),
      );
    }
  }
}

class _SubscriptionItemCard extends ConsumerWidget {
  const _SubscriptionItemCard({
    required this.item,
    required this.code,
    required this.onEdit,
  });

  final SubscriptionItem item;
  final String code;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final scheduleType = SubscriptionScheduleType.fromStorage(item.scheduleType);
    final scheduleLabel = scheduleType == SubscriptionScheduleType.dayOfMonth
        ? 'Day ${item.billingDayOfMonth ?? 1}'
        : 'Every ${item.rollingDays ?? 30}d';
    final dueInfo = daysUntilDue(item.nextDueAt);
    final dueLabel = formatDueLabel(item.nextDueAt);
    final isOverdue = dueInfo.overdue;
    final warnDays = item.warnBeforeDays;
    final isInWarningWindow = !isOverdue &&
        warnDays != null &&
        warnDays > 0 &&
        dueInfo.days <= warnDays;
    final showWarning = isOverdue || isInWarningWindow;
    final borderColor = isOverdue
        ? AppTheme.ledgerCancel
        : isInWarningWindow
            ? AppTheme.ledgerCancel.withValues(alpha: 0.6)
            : AppTheme.brandPrimary.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: showWarning
              ? AppTheme.ledgerCancel.withValues(alpha: 0.06)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor, width: isOverdue ? 1.5 : 1.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.brandPrimary.withValues(alpha: 0.15),
            child: const Icon(Icons.autorenew_rounded, color: AppTheme.brandPrimary, size: 20),
          ),
          title: Text(item.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MoneyFormat.formatMinor(item.amountMinor, code),
                style: text.labelLarge?.copyWith(
                  color: AppTheme.brandPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.mutedFg.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(scheduleLabel, style: text.labelSmall),
                  ),
                  const SizedBox(width: 8),
                  Text(dueLabel,
                      style: text.labelSmall?.copyWith(
                        color: isOverdue
                            ? AppTheme.ledgerDebt
                            : isInWarningWindow
                                ? AppTheme.ledgerCancel
                                : AppTheme.mutedFg,
                        fontWeight: FontWeight.w600,
                      )),
                  if (isOverdue) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.ledgerCancel.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 12, color: AppTheme.ledgerCancel),
                          const SizedBox(width: 3),
                          Text('Needs logging',
                              style: text.labelSmall?.copyWith(
                                  color: AppTheme.ledgerCancel,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ] else if (isInWarningWindow) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.ledgerCancel.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              size: 12, color: AppTheme.ledgerCancel),
                          const SizedBox(width: 3),
                          Text('Due soon',
                              style: text.labelSmall?.copyWith(
                                  color: AppTheme.ledgerCancel,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined, size: 22),
                color: AppTheme.personalExpense,
                tooltip: 'Log payment',
                onPressed: () => _logSubscription(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppTheme.ledgerDebt,
                tooltip: 'Delete',
                onPressed: () => _deleteSubscription(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logSubscription(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log subscription payment?'),
        content: Text(
          'Log "${item.title}" as an expense and advance the next due date.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final repo = ref.read(ledgerRepositoryProvider);
    await repo.logSubscriptionPayment(item.id);
    if (!context.mounted) return;
    await showWishlistWalletSheet(
      context: context,
      ref: ref,
      amountMinor: item.amountMinor,
      currencyCode: item.currencyCode,
      title: item.title,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${item.title}" logged')),
      );
    }
  }

  Future<void> _deleteSubscription(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subscription?'),
        content: Text(item.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).deleteSubscriptionItem(item.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

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
            width: 4, height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DateFormat.yMMMMEEEEd().format(day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
    this.categoryLabel,
  });

  final PersonalFinanceEntry entry;
  final String code;
  final Color color;
  final PersonalFinanceKind kind;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? categoryLabel;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(entry.createdAt.toLocal());
    final note = entry.note?.trim();
    final fromSnap = FromCurrencySnapshot.fromJsonString(entry.fromCurrencyJson);

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
                          Text(timeStr, style: TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
                          if (categoryLabel != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                categoryLabel!,
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          note,
                          style: TextStyle(
                            color: AppTheme.mutedFg.withValues(alpha: 0.95),
                            height: 1.35,
                          ),
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
                    if (fromSnap != null)
                      Text(
                        fromSnap.formatPrimary(),
                        style: TextStyle(
                          color: AppTheme.mutedFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
  const _MiniStatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.mutedFg, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period selector
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onSelected,
    this.customStart,
    this.customEnd,
  });

  final _FinancePeriod selected;
  final ValueChanged<_FinancePeriod> onSelected;
  final DateTime? customStart;
  final DateTime? customEnd;

  @override
  Widget build(BuildContext context) {
    final customLabel = selected == _FinancePeriod.custom &&
            customStart != null &&
            customEnd != null
        ? '${DateFormat.MMMd().format(customStart!)}–${DateFormat.MMMd().format(customEnd!)}'
        : 'Custom';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(
            label: 'This week',
            selected: selected == _FinancePeriod.thisWeek,
            onTap: () => onSelected(_FinancePeriod.thisWeek),
          ),
          const SizedBox(width: 6),
          _PeriodChip(
            label: 'This month',
            selected: selected == _FinancePeriod.thisMonth,
            onTap: () => onSelected(_FinancePeriod.thisMonth),
          ),
          const SizedBox(width: 6),
          _PeriodChip(
            label: 'Last month',
            selected: selected == _FinancePeriod.lastMonth,
            onTap: () => onSelected(_FinancePeriod.lastMonth),
          ),
          const SizedBox(width: 6),
          _PeriodChip(
            label: customLabel,
            selected: selected == _FinancePeriod.custom,
            onTap: () => onSelected(_FinancePeriod.custom),
            icon: Icons.date_range_rounded,
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.brandPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppTheme.inputFill,
          border: Border.all(
            color: selected ? color : AppTheme.mutedFg.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? color : AppTheme.mutedFg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppTheme.mutedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trend card
// ─────────────────────────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.current,
    required this.previous,
    required this.code,
    required this.color,
    required this.isExpense,
  });

  final int current;
  final int previous;
  final String code;
  final Color color;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    if (previous == 0 && current == 0) return const SizedBox.shrink();
    final noComparison = previous == 0;
    final delta = current - previous;
    final pct = previous > 0 ? (delta / previous * 100).abs().round() : 0;
    final isUp = delta > 0;
    // For expenses: up is bad (red), down is good (green)
    // For gains: up is good (green), down is bad (red)
    final trendColor = isExpense
        ? (isUp ? AppTheme.ledgerDebt : AppTheme.balanceReceivable)
        : (isUp ? AppTheme.balanceReceivable : AppTheme.ledgerDebt);
    final arrow = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.mutedFg.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows_rounded, size: 18, color: AppTheme.mutedFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'vs previous period: ${MoneyFormat.formatMinor(previous, code)}',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            ),
          ),
          if (noComparison)
            Text('— no data', style: TextStyle(color: AppTheme.mutedFg, fontSize: 12))
          else ...[
            Icon(arrow, size: 18, color: trendColor),
            const SizedBox(width: 4),
            Text(
              '$pct%',
              style: TextStyle(
                color: trendColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expenses vs Gains comparison bar
// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.expenseTotal,
    required this.gainTotal,
    required this.code,
  });

  final int expenseTotal;
  final int gainTotal;
  final String code;

  @override
  Widget build(BuildContext context) {
    if (expenseTotal == 0 && gainTotal == 0) return const SizedBox.shrink();
    final total = expenseTotal + gainTotal;
    final expPct = total > 0 ? expenseTotal / total : 0.5;
    final net = gainTotal - expenseTotal;
    final netColor = net >= 0 ? AppTheme.personalGain : AppTheme.personalExpense;
    final netLabel = MoneyFormat.formatMinor(net.abs(), code);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.mutedFg.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.personalExpense, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Expenses: ${MoneyFormat.formatMinor(expenseTotal, code)}',
                  style: TextStyle(color: AppTheme.personalExpense, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Gains: ${MoneyFormat.formatMinor(gainTotal, code)}',
                  style: TextStyle(color: AppTheme.personalGain, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.personalGain, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: (expPct * 100).round(),
                  child: Container(height: 8, color: AppTheme.personalExpense),
                ),
                Expanded(
                  flex: ((1 - expPct) * 100).round().clamp(1, 100),
                  child: Container(height: 8, color: AppTheme.personalGain),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Net: ', style: TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
              Text(
                net >= 0 ? '+$netLabel' : '−$netLabel',
                style: TextStyle(
                    color: netColor, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top category card
// ─────────────────────────────────────────────────────────────────────────────

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.code,
  });

  final ExpenseCategory category;
  final int amount;
  final int percentage;
  final String code;

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(category.colorHex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(categoryIconData(category.iconCodePoint), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top category',
                    style: TextStyle(color: AppTheme.mutedFg, fontSize: 11)),
                Text(
                  category.name,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormat.formatMinor(amount, code),
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text(
                '$percentage% of total',
                style: TextStyle(color: AppTheme.mutedFg, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category breakdown list
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({
    required this.categories,
    required this.spendByCat,
    required this.totalRange,
    required this.code,
    required this.filterCategoryId,
    required this.onCategoryTap,
    required this.onCategoryDetailTap,
  });

  final List<ExpenseCategory> categories;
  final Map<String, int> spendByCat;
  final int totalRange;
  final String code;
  final String? filterCategoryId;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<ExpenseCategory> onCategoryDetailTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...categories]..sort((a, b) {
        final sa = spendByCat[a.id] ?? 0;
        final sb = spendByCat[b.id] ?? 0;
        return sb.compareTo(sa);
      });

    return Column(
      children: sorted.map((cat) {
        final spent = spendByCat[cat.id] ?? 0;
        if (spent == 0) return const SizedBox.shrink();
        final pct = totalRange > 0 ? (spent / totalRange * 100).round() : 0;
        final catColor = _hexColor(cat.colorHex);
        final isSelected = filterCategoryId == cat.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => onCategoryTap(cat.id),
            onLongPress: () => onCategoryDetailTap(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? catColor.withValues(alpha: 0.15)
                    : AppTheme.inputFill,
                border: Border.all(
                  color: isSelected
                      ? catColor.withValues(alpha: 0.6)
                      : AppTheme.mutedFg.withValues(alpha: 0.12),
                ),
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(categoryIconData(cat.iconCodePoint), size: 16, color: catColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? catColor : null,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        MoneyFormat.formatMinor(spent, code),
                        style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$pct%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppTheme.mutedFg,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onCategoryDetailTap(cat),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppTheme.mutedFg),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: totalRange > 0 ? spent / totalRange : 0,
                      backgroundColor: catColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category detail sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryDetailSheet extends ConsumerStatefulWidget {
  const _CategoryDetailSheet({
    required this.category,
    required this.kind,
    required this.periodStart,
    required this.periodEnd,
    required this.onOpenEditor,
  });

  final ExpenseCategory category;
  final PersonalFinanceKind kind;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Future<void> Function(PersonalFinanceEntry?) onOpenEditor;

  @override
  ConsumerState<_CategoryDetailSheet> createState() => _CategoryDetailSheetState();
}

class _CategoryDetailSheetState extends ConsumerState<_CategoryDetailSheet> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final catColor = _hexColor(cat.colorHex);
    final code = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final allEntriesAsync = ref.watch(personalFinanceEntriesProvider(widget.kind));
    final allEntries = allEntriesAsync.valueOrNull ?? [];

    final periodEntries = allEntries.where((e) {
      final local = e.createdAt.toLocal();
      return e.categoryId == cat.id &&
          !local.isBefore(widget.periodStart) &&
          !local.isAfter(widget.periodEnd);
    }).toList();

    final shownEntries = _showAll
        ? allEntries.where((e) => e.categoryId == cat.id).toList()
        : periodEntries;

    final periodTotal = periodEntries.fold<int>(0, (a, e) => a + e.amountMinor);
    final allEntriesTotalForKind = allEntries.fold<int>(0, (a, e) => a + e.amountMinor);
    final pct = allEntriesTotalForKind > 0
        ? (periodTotal / allEntriesTotalForKind * 100).round()
        : 0;

    final dayCount = widget.periodEnd.difference(widget.periodStart).inDays.clamp(1, 90) + 1;
    final chartPoints = buildPersonalDailyPoints(periodEntries, dayCount);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: catColor.withValues(alpha: 0.2),
                    child: Icon(categoryIconData(cat.iconCodePoint),
                        color: catColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                              color: catColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                        Text(
                          '${MoneyFormat.formatMinor(periodTotal, code)}  ·  $pct% of total',
                          style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // ── Mini chart ───────────────────────────────────────────────
            if (periodEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 120,
                  child: PersonalAmountLineChart(
                    points: chartPoints,
                    color: catColor,
                    legend: cat.name,
                  ),
                ),
              ),
            // ── All entries toggle ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Text(
                    _showAll ? 'All entries' : 'Period entries',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _showAll,
                    onChanged: (v) => setState(() => _showAll = v),
                    activeThumbColor: catColor,
                  ),
                  Text(
                    'All time',
                    style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Entry list ───────────────────────────────────────────────
            Expanded(
              child: shownEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No entries in this period',
                        style: TextStyle(color: AppTheme.mutedFg),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: shownEntries.length,
                      itemBuilder: (ctx, i) {
                        final e = shownEntries[i];
                        return _EntryCard(
                          entry: e,
                          code: code,
                          color: catColor,
                          kind: widget.kind,
                          onEdit: () => widget.onOpenEditor(e),
                          onDelete: () async {
                            if (ctx.mounted) {
                              await _confirmDelete(ctx, ref, e);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

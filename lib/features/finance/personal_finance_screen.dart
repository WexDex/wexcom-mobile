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
import '../../utils/subscription_schedule.dart';
import '../../widgets/currency_amount_input.dart';
import '../dashboard/dashboard_charts.dart';
import 'expense_categories_screen.dart';
import 'wallet_tab.dart';
import 'wishlist_wallet_sheet.dart';

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
  int _chartDays = 7;

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
      if (minor != null && minor > 0 && title.isNotEmpty) {
        if (existing == null) {
          await repo.addSubscriptionItem(
            title: title,
            amountMinor: minor,
            scheduleType: scheduleType,
            billingDayOfMonth:
                scheduleType == SubscriptionScheduleType.dayOfMonth ? billingDay : null,
            rollingDays: scheduleType == SubscriptionScheduleType.rollingDays ? rolling : null,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            fromCurrency: fromSnap,
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
          );
        }
      }
    }
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    rollingCtrl.dispose();
  }
}

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
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
    required this.chartDays,
    required this.onDaysChanged,
    required this.onOpenEditor,
  });

  final PersonalFinanceKind kind;
  final int chartDays;
  final ValueChanged<int> onDaysChanged;
  final Future<void> Function(PersonalFinanceEntry? existing) onOpenEditor;

  @override
  ConsumerState<_FinanceTabBody> createState() => _FinanceTabBodyState();
}

class _FinanceTabBodyState extends ConsumerState<_FinanceTabBody> {
  String? _filterCategoryId; // null = show all

  @override
  Widget build(BuildContext context) {
    final scope = widget.kind == PersonalFinanceKind.expense ? 'expense' : 'gain';
    final entriesAsync = ref.watch(personalFinanceEntriesProvider(widget.kind));
    final categoriesAsync = ref.watch(expenseCategoriesProvider(scope));
    final spendAsync = ref.watch(monthlySpendProvider(scope));
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';
    final color = widget.kind == PersonalFinanceKind.expense
        ? AppTheme.personalExpense
        : AppTheme.personalGain;
    final categories = categoriesAsync.valueOrNull ?? [];
    final spendMap = spendAsync.valueOrNull ?? {};

    return entriesAsync.when(
      data: (allEntries) {
        // Apply category filter
        final entries = _filterCategoryId == null
            ? allEntries
            : allEntries.where((e) => e.categoryId == _filterCategoryId).toList();

        final totalAll = allEntries.fold<int>(0, (a, e) => a + e.amountMinor);
        final days = recentCalendarDays(widget.chartDays);
        final startDay = days.first;
        final inRange = entries.where((e) {
          final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
          return !d.isBefore(startDay);
        }).toList();
        final totalRange = inRange.fold<int>(0, (a, e) => a + e.amountMinor);
        final daily = buildPersonalDailyPoints(inRange, widget.chartDays);
        final grouped = _groupByDay(entries);
        final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // ── Budget progress bars (expense tab, categories with budgets) ──
            if (widget.kind == PersonalFinanceKind.expense) ...[
              ...categories
                  .where((c) => c.budgetMinorPerMonth != null && c.budgetMinorPerMonth! > 0)
                  .map((cat) {
                final spent = spendMap[cat.id] ?? 0;
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
                      Icon(
                        categoryIconData(cat.iconCodePoint),
                        size: 16,
                        color: catColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ),
                                Text(
                                  '${MoneyFormat.formatMinor(spent, code)} / ${MoneyFormat.formatMinor(budget, code)}',
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
              if (categories.any((c) =>
                  c.budgetMinorPerMonth != null && c.budgetMinorPerMonth! > 0))
                const Divider(height: 20),
            ],

            // ── Period selector ──
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7d')),
                ButtonSegment(value: 14, label: Text('14d')),
                ButtonSegment(value: 30, label: Text('30d')),
              ],
              selected: {widget.chartDays},
              onSelectionChanged: (s) => widget.onDaysChanged(s.first),
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
              title: widget.kind == PersonalFinanceKind.expense
                  ? 'Spending per day'
                  : 'Gains per day',
              subtitle: 'Last ${widget.chartDays} days',
              child: PersonalAmountLineChart(
                points: daily,
                color: color,
                legend: widget.kind == PersonalFinanceKind.expense ? 'Expenses' : 'Gains',
              ),
            ),

            // ── Category filter chips ──
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _filterCategoryId == null,
                        onSelected: (_) => setState(() => _filterCategoryId = null),
                      ),
                    ),
                    ...categories.map((cat) {
                      final catColor = _hexColor(cat.colorHex);
                      final isSelected = _filterCategoryId == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          avatar: Icon(
                            categoryIconData(cat.iconCodePoint),
                            size: 14,
                            color: isSelected ? catColor : AppTheme.mutedFg,
                          ),
                          label: Text(cat.name),
                          selected: isSelected,
                          selectedColor: catColor.withValues(alpha: 0.2),
                          onSelected: (_) =>
                              setState(() => _filterCategoryId = isSelected ? null : cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

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
              'Newest first · grouped by day · tap to edit',
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
    final dueLabel = formatDueLabel(item.nextDueAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.2)),
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
                        color: dueLabel.startsWith('Overdue')
                            ? AppTheme.ledgerDebt
                            : AppTheme.mutedFg,
                        fontWeight: FontWeight.w600,
                      )),
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

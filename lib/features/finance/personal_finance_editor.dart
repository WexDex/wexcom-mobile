import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_icon.dart';
import '../../utils/money.dart';
import '../../widgets/currency_amount_input.dart';
import '../../widgets/scrollable_form_sheet.dart';

class PersonalFinanceEditorResult {
  const PersonalFinanceEditorResult({
    required this.title,
    required this.amountMinor,
    required this.note,
    required this.categoryId,
    required this.accountId,
    required this.dayLocal,
    required this.fromCurrency,
  });

  final String title;
  final int amountMinor;
  final String? note;
  final String? categoryId;
  final String accountId;
  final DateTime dayLocal;
  final FromCurrencySnapshot? fromCurrency;
}

/// Opens expense/gain editor with Quick | Full toggle (Quick default for new entries).
Future<PersonalFinanceEditorResult?> openPersonalFinanceEditor({
  required BuildContext context,
  required WidgetRef ref,
  required PersonalFinanceKind kind,
  PersonalFinanceEntry? existing,
}) async {
  final currency = await ref.read(defaultCurrencyProvider.future);
  final repo = ref.read(ledgerRepositoryProvider);
  final foreign = await repo.foreignCurrencyEditorContext();
  if (!context.mounted) return null;

  final scope = kind == PersonalFinanceKind.expense ? 'expense' : 'gain';
  final categories =
      ref.read(expenseCategoriesProvider(scope)).valueOrNull ?? [];
  final accounts = ref.read(walletAccountsProvider).valueOrNull ?? [];

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
  var selectedAccountId = existing?.accountId ?? kDefaultPocketAccountId;
  var quickMode = existing == null;

  var dayLocal = existing != null
      ? DateTime(
          existing.createdAt.toLocal().year,
          existing.createdAt.toLocal().month,
          existing.createdAt.toLocal().day,
        )
      : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final sheetTitle = existing == null
      ? (kind == PersonalFinanceKind.expense ? 'New expense' : 'New gain')
      : (kind == PersonalFinanceKind.expense ? 'Edit expense' : 'Edit gain');

  PersonalFinanceEditorResult? result;

  await showScrollableFormSheet<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) {
        void trySave() {
          fromSnap = amountKey.currentState?.buildSnapshot();
          final minor = MoneyFormat.parseMinorUnits(amountCtrl.text, fractionDigits: 0);
          if (minor == null || minor <= 0) return;

          final foreignOn = amountKey.currentState?.foreignModeEnabled ?? false;
          if (foreignOn && minor <= 0) {
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

          String title;
          if (quickMode && existing == null) {
            final cat = categories.where((c) => c.id == selectedCategoryId).firstOrNull;
            title = cat?.name ??
                (kind == PersonalFinanceKind.expense ? 'Expense' : 'Gain');
          } else {
            title = titleCtrl.text.trim();
            if (title.isEmpty) return;
          }

          final note = noteCtrl.text.trim();
          result = PersonalFinanceEditorResult(
            title: title,
            amountMinor: minor,
            note: note.isEmpty ? null : note,
            categoryId: selectedCategoryId,
            accountId: selectedAccountId,
            dayLocal: dayLocal,
            fromCurrency: fromSnap,
          );
          Navigator.pop(ctx);
        }

        Widget categoryChips({bool showNone = true}) {
          if (categories.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (showNone)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('None'),
                          selected: selectedCategoryId == null,
                          onSelected: (_) => setModal(() => selectedCategoryId = null),
                        ),
                      ),
                    ...categories.map((cat) {
                      final catColor = Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
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
                          onSelected: (_) => setModal(() => selectedCategoryId = cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }

        Widget accountChips() {
          if (accounts.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Account',
                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: accounts.map((a) {
                    final isSelected = selectedAccountId == a.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('${a.emoji} ${a.name}'),
                        selected: isSelected,
                        onSelected: (_) => setModal(() => selectedAccountId = a.id),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        final body = quickMode && existing == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CurrencyAmountInput(
                    key: amountKey,
                    defaultCurrencyCode: currency,
                    amountMinorController: amountCtrl,
                    currencyCodes: foreign.codes,
                    rates: foreign.rates,
                    initialSnapshot: initialSnap,
                    onSnapshotChanged: (s) => fromSnap = s,
                  ),
                  const SizedBox(height: 14),
                  categoryChips(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Optional',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const SizedBox(height: 14),
                  categoryChips(),
                  accountChips(),
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
                ],
              );

        return ScrollableFormSheet(
          title: sheetTitle,
          onClose: () => Navigator.pop(ctx),
          primaryLabel: existing == null ? 'Add' : 'Save changes',
          primaryColor: color,
          onPrimary: trySave,
          toolbar: existing == null
              ? SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Quick')),
                    ButtonSegment(value: false, label: Text('Full')),
                  ],
                  selected: {quickMode},
                  onSelectionChanged: (s) => setModal(() => quickMode = s.first),
                )
              : null,
          body: body,
        );
      },
    ),
  );

  titleCtrl.dispose();
  amountCtrl.dispose();
  noteCtrl.dispose();
  return result;
}

DateTime personalFinanceCreatedAtUtcForSave({
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

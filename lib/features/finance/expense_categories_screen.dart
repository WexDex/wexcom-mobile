import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_icon.dart';
import '../../utils/money.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expense / Gain category management screen
// Accessible from the Finance AppBar → "Categories" action
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseCategoriesScreen extends ConsumerWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseCategoriesProvider('expense'));
    final gainAsync = ref.watch(expenseCategoriesProvider('gain'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New category',
            onPressed: () => _openEditor(context, ref, null, 'expense'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // ── Expense categories ───────────────────────────────────────────
          _SectionLabel(
            label: 'Expense categories',
            onAdd: () => _openEditor(context, ref, null, 'expense'),
          ),
          expenseAsync.when(
            data: (cats) => cats.isEmpty
                ? _EmptyHint(
                    message: 'No expense categories — tap + to create one.',
                  )
                : Column(
                    children: cats
                        .map((c) => _CategoryTile(
                              category: c,
                              onEdit: () => _openEditor(context, ref, c, 'expense'),
                              onDelete: () => _confirmDelete(context, ref, c),
                            ))
                        .toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 20),

          // ── Gain categories ──────────────────────────────────────────────
          _SectionLabel(
            label: 'Gain categories',
            onAdd: () => _openEditor(context, ref, null, 'gain'),
          ),
          gainAsync.when(
            data: (cats) => cats.isEmpty
                ? _EmptyHint(
                    message: 'No gain categories — tap + to create one.',
                  )
                : Column(
                    children: cats
                        .map((c) => _CategoryTile(
                              category: c,
                              onEdit: () => _openEditor(context, ref, c, 'gain'),
                              onDelete: () => _confirmDelete(context, ref, c),
                            ))
                        .toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
      BuildContext context, WidgetRef ref, ExpenseCategory? existing, String scope) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => _CategoryEditorSheet(existing: existing, scope: scope),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ExpenseCategory cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${cat.name}"?'),
        content: const Text(
            'Existing entries linked to this category will become uncategorised.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).deleteCategory(cat.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.onAdd});
  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppTheme.mutedFg),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Category tile
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(category.colorHex);
    final budget = category.budgetMinorPerMonth;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.18),
        child: Icon(
          categoryIconData(category.iconCodePoint),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: budget != null && budget > 0
          ? Text(
              'Budget: ${MoneyFormat.formatMinor(budget, 'DZD')}/month',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            )
          : Text(
              'No budget set',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.ledgerDebt),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editor bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryEditorSheet extends ConsumerStatefulWidget {
  const _CategoryEditorSheet({this.existing, required this.scope});
  final ExpenseCategory? existing;
  final String scope;

  @override
  ConsumerState<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<_CategoryEditorSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _budgetCtrl;
  late int _iconCodePoint;

  // A handful of common Material icons with friendly labels
  static const _iconOptions = [
    (0xe532, 'Food'),
    (0xe1b0, 'Transport'),
    (0xe3e7, 'Bills'),
    (0xe87e, 'Health'),
    (0xf1cc, 'Shopping'),
    (0xe574, 'Other'),
    (0xe8f9, 'Work'),
    (0xe86f, 'Freelance'),
    (0xe227, 'Home'),
    (0xe547, 'Pets'),
    (0xe02c, 'Entertainment'),
    (0xe425, 'Education'),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _colorCtrl = TextEditingController(text: e?.colorHex ?? '#22C55E');
    _budgetCtrl = TextEditingController(
      text: e?.budgetMinorPerMonth != null ? '${e!.budgetMinorPerMonth}' : '',
    );
    _iconCodePoint = e?.iconCodePoint ?? 0xe574;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = widget.existing == null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isNew ? 'New ${widget.scope} category' : 'Edit category',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.sentences,
            autofocus: isNew,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _colorCtrl,
            decoration: const InputDecoration(
              labelText: 'Colour hex (e.g. #22C55E)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _budgetCtrl,
            decoration: const InputDecoration(
              labelText: 'Monthly budget (optional, minor units)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          Text('Icon', style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _iconOptions.map((pair) {
              final (cp, label) = pair;
              final selected = cp == _iconCodePoint;
              return GestureDetector(
                onTap: () => setState(() => _iconCodePoint = cp),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.brandPrimary.withValues(alpha: 0.18)
                        : AppTheme.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppTheme.brandPrimary
                          : AppTheme.brandPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        categoryIconData(cp),
                        size: 18,
                        color: selected ? AppTheme.brandPrimary : AppTheme.mutedFg,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? AppTheme.brandPrimary : AppTheme.mutedFg,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final colorHex = _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : '#22C55E';
    final budget = int.tryParse(_budgetCtrl.text.trim());

    await ref.read(ledgerRepositoryProvider).saveCategory(
          id: widget.existing?.id,
          name: name,
          colorHex: colorHex,
          iconCodePoint: _iconCodePoint,
          budgetMinorPerMonth: budget,
          scope: widget.scope,
        );

    if (mounted) Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  try {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppTheme.brandPrimary;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

typedef OnSaveTemplate =
    Future<void> Function(String label, int amountMinor, LedgerTxType type, String? note);

typedef TransactionSubmit =
    Future<void> Function(
      int amountMinor,
      LedgerTxType type,
      String? note,
      List<String> tagIds,
      DateTime effectiveAt,
      DateTime? dueAt,
    );

class TransactionEditorSheet extends StatefulWidget {
  const TransactionEditorSheet({
    super.key,
    required this.title,
    required this.currencyCode,
    required this.onSubmit,
    this.initialAmountMinor,
    this.initialType,
    this.initialNote,
    this.availableTags = const [],
    this.initialTagIds = const [],
    this.currentBalanceMinor,
    this.initialEffectiveAt,
    this.initialDueAt,
    this.templates = const [],
    this.onSaveTemplate,
    this.onDeleteTemplate,
  });

  final String title;
  final String currencyCode;
  final TransactionSubmit onSubmit;
  final int? initialAmountMinor;
  final LedgerTxType? initialType;
  final String? initialNote;
  final List<Tag> availableTags;
  final List<String> initialTagIds;
  final int? currentBalanceMinor;
  final DateTime? initialEffectiveAt;
  final DateTime? initialDueAt;
  final List<TransactionTemplate> templates;
  final OnSaveTemplate? onSaveTemplate;
  final Future<void> Function(String id)? onDeleteTemplate;

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  LedgerTxType _type = LedgerTxType.debt;
  late final TextEditingController _note = TextEditingController(
    text: widget.initialNote ?? '',
  );
  bool _busy = false;
  late final Set<String> _selectedTagIds = widget.initialTagIds.toSet();
  late DateTime _effectiveAt =
      (widget.initialEffectiveAt ?? DateTime.now()).toLocal();
  DateTime? _dueAt;

  DateTime _selectedDateWithCurrentTime(DateTime dateOnlyLocal) {
    final now = DateTime.now();
    return DateTime(
      dateOnlyLocal.year,
      dateOnlyLocal.month,
      dateOnlyLocal.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  void _onAmountChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
    if (widget.initialDueAt != null) _dueAt = widget.initialDueAt!.toLocal();
    if (widget.initialAmountMinor != null) {
      _amount = TextEditingController(
        text: widget.initialAmountMinor!.toString(),
      );
    } else {
      _amount = TextEditingController();
    }
    _amount.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amount.removeListener(_onAmountChanged);
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = MoneyFormat.parseMinorUnits(_amount.text) ?? 0;
    final before = widget.currentBalanceMinor;
    final after = before == null
        ? null
        : LedgerMath.apply(before, _type, parsedAmount);

    final typeTint = _type == LedgerTxType.debt
        ? AppTheme.ledgerDebt
        : AppTheme.ledgerPayment;
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: typeTint.withValues(alpha: 0.08),
          border: Border(
            top: BorderSide(color: typeTint.withValues(alpha: 0.35), width: 1.2),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                'Currency: ${widget.currencyCode}',
                style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TxTypeCard(
                      selected: _type == LedgerTxType.debt,
                      title: 'Debt',
                      caption: 'Increases amount owed',
                      color: AppTheme.ledgerDebt,
                      icon: Icons.trending_up_rounded,
                      onTap: () => setState(() => _type = LedgerTxType.debt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TxTypeCard(
                      selected: _type == LedgerTxType.payment,
                      title: 'Payment',
                      caption: 'Reduces balance owed',
                      color: AppTheme.ledgerPayment,
                      icon: Icons.payments_rounded,
                      onTap: () => setState(() => _type = LedgerTxType.payment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.templates.isNotEmpty) ...[
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final t = widget.templates[i];
                      final tType = LedgerTxType.fromInt(t.txType);
                      final label =
                          '${tType == LedgerTxType.debt ? '↑' : '↓'} ${t.label} · ${MoneyFormat.formatMinor(t.amountMinor, widget.currencyCode)}';
                      return GestureDetector(
                        onLongPress: widget.onDeleteTemplate == null
                            ? null
                            : () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete template?'),
                                    content: Text('"${t.label}"'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true && mounted) {
                                  await widget.onDeleteTemplate!(t.id);
                                }
                              },
                        child: ActionChip(
                          label: Text(label, style: const TextStyle(fontSize: 12)),
                          onPressed: () => setState(() {
                            _amount.text = t.amountMinor.toString();
                            _type = tType;
                            if (t.note != null) _note.text = t.note!;
                          }),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '100',
                  helperText: 'Enter whole DZD values only.',
                ),
                validator: (v) {
                  final minor = MoneyFormat.parseMinorUnits(v ?? '');
                  if (minor == null || minor <= 0) {
                    return 'Enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: const Text('Transaction date'),
                subtitle: Text(MoneyFormat.formatDate(_effectiveAt)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _effectiveAt,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(now.year + 1, 12, 31),
                  );
                  if (picked != null && mounted) {
                    setState(
                      () => _effectiveAt = _selectedDateWithCurrentTime(picked),
                    );
                  }
                },
              ),
              if (_type == LedgerTxType.debt)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.schedule_outlined,
                    color: _dueAt != null && _dueAt!.isBefore(DateTime.now())
                        ? Colors.amber
                        : null,
                  ),
                  title: Text(
                    _dueAt == null ? 'Due date' : 'Due ${MoneyFormat.formatDate(_dueAt!)}',
                    style: _dueAt != null && _dueAt!.isBefore(DateTime.now())
                        ? const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600)
                        : null,
                  ),
                  subtitle: _dueAt == null ? const Text('Tap to set a repayment deadline') : null,
                  trailing: _dueAt == null
                      ? const Icon(Icons.add_circle_outline, size: 20)
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _dueAt = null),
                        ),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueAt ?? now.add(const Duration(days: 7)),
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: DateTime(now.year + 5, 12, 31),
                      helpText: 'Select due date',
                    );
                    if (picked != null && mounted) {
                      setState(() => _dueAt = DateTime(picked.year, picked.month, picked.day, 23, 59));
                    }
                  },
                ),
              if (before != null && after != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(
                      color: AppTheme.mutedFg.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Before: ${MoneyFormat.formatMinor(before, widget.currencyCode)}',
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'After: ${MoneyFormat.formatMinor(after, widget.currencyCode)}',
                          style: TextStyle(
                            color: _type == LedgerTxType.debt
                                ? AppTheme.ledgerDebt
                                : AppTheme.ledgerPayment,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              if (widget.onSaveTemplate != null && parsedAmount > 0) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('Save as template'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onPressed: () async {
                      final labelCtrl = TextEditingController();
                      final label = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Save template'),
                          content: TextField(
                            controller: labelCtrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Template name',
                              hintText: 'e.g. Monthly rent',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, labelCtrl.text.trim()),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if (label != null && label.isNotEmpty && mounted) {
                        await widget.onSaveTemplate!(
                          label,
                          parsedAmount,
                          _type,
                          _note.text.trim().isEmpty ? null : _note.text.trim(),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Template "$label" saved')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
              if (widget.availableTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableTags.map((tag) {
                    final selected = _selectedTagIds.contains(tag.id);
                    final color = _parseTagColor(tag.colorHex);
                    return FilterChip(
                      selected: selected,
                      selectedColor: color.withValues(alpha: 0.28),
                      checkmarkColor: color,
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color: selected
                            ? color
                            : AppTheme.mutedFg.withValues(alpha: 0.24),
                      ),
                      label: Text(tag.name),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final minor = MoneyFormat.parseMinorUnits(
                          _amount.text,
                        )!;
                        setState(() => _busy = true);
                        try {
                          await widget.onSubmit(
                            minor,
                            _type,
                            _note.text.trim().isEmpty
                                ? null
                                : _note.text.trim(),
                            _selectedTagIds.toList(growable: false),
                            _effectiveAt.toUtc(),
                            _type == LedgerTxType.debt ? _dueAt?.toUtc() : null,
                          );
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _parseTagColor(String hex) {
  final normalized = hex.replaceAll('#', '').trim();
  if (normalized.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

class _TxTypeCard extends StatelessWidget {
  const _TxTypeCard({
    required this.selected,
    required this.title,
    required this.caption,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String caption;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? color.withValues(alpha: 0.22) : AppTheme.inputFill,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: selected
                  ? color
                  : AppTheme.mutedFg.withValues(alpha: 0.25),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: text.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                style: text.bodySmall?.copyWith(
                  color: AppTheme.mutedFg,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

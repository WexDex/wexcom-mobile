import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../services/contacts_service.dart';
import '../../theme/app_theme.dart';

class ClientEditorSheet extends ConsumerStatefulWidget {
  const ClientEditorSheet({
    super.key,
    required this.onSaved,
    this.initialName = '',
    this.initialPhone,
    this.initialNote,
    this.title = 'New client',
    this.submitLabel = 'Save',
    this.availableTags = const [],
    this.initialTagIds = const [],
  });

  final Future<void> Function(
    String fullName,
    String? phone,
    String? note,
    List<String> tagIds,
  )
  onSaved;
  final String initialName;
  final String? initialPhone;
  final String? initialNote;
  final String title;
  final String submitLabel;
  final List<Tag> availableTags;
  final List<String> initialTagIds;

  @override
  ConsumerState<ClientEditorSheet> createState() => _ClientEditorSheetState();
}

class _ClientEditorSheetState extends ConsumerState<ClientEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initialPhone ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initialNote ?? '',
  );
  bool _busy = false;
  late Set<String> _selectedTagIds = widget.initialTagIds.toSet();
  bool _contactsAutofillVisible = false;
  bool _contactsPermissionGranted = false;
  bool _loadingSuggestions = false;
  int _suggestionRequestId = 0;
  List<ContactSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
    Future.microtask(_initContactsAutofill);
  }

  Future<void> _initContactsAutofill() async {
    final service = ref.read(contactsServiceProvider);
    if (!service.isSupported) return;
    final enabled = await ref.read(contactsAutofillEnabledProvider.future);
    final hasPermission = await service.hasPermission();
    if (!mounted) return;
    setState(() {
      _contactsAutofillVisible = enabled;
      _contactsPermissionGranted = hasPermission;
    });
    if (_contactsAutofillVisible && _contactsPermissionGranted) {
      await _refreshSuggestions(_name.text);
    }
  }

  Future<void> _onNameChanged() async {
    if (!_contactsAutofillVisible || !_contactsPermissionGranted) return;
    await _refreshSuggestions(_name.text);
  }

  Future<void> _refreshSuggestions(String query) async {
    final nextId = ++_suggestionRequestId;
    if (query.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _suggestions = const []);
      return;
    }
    if (!mounted) return;
    setState(() => _loadingSuggestions = true);
    final service = ref.read(contactsServiceProvider);
    final items = await service.searchSuggestions(query);
    if (!mounted || nextId != _suggestionRequestId) return;
    setState(() {
      _loadingSuggestions = false;
      _suggestions = items;
    });
  }

  void _applySuggestion(ContactSuggestion suggestion) {
    _name.text = suggestion.displayName;
    _phone.text = suggestion.phoneNumber;
    _name.selection = TextSelection.collapsed(offset: _name.text.length);
    setState(() => _suggestions = const []);
  }

  Color _tagColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null || cleaned.length != 6) return AppTheme.receivableAccent;
    return Color(0xFF000000 | parsed);
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'e.g. Ahmed Ben Ali',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Enter a name';
                  return null;
                },
              ),
              if (_contactsAutofillVisible && _contactsPermissionGranted) ...[
                const SizedBox(height: 8),
                if (_loadingSuggestions)
                  const LinearProgressIndicator(minHeight: 2),
                if (_suggestions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 190),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final suggestion = _suggestions[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.contacts_outlined),
                          title: Text(
                            suggestion.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            suggestion.phoneNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _applySuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
              if (_contactsAutofillVisible && !_contactsPermissionGranted) ...[
                const SizedBox(height: 8),
                Text(
                  'Contacts autofill is enabled, but contacts permission is denied on this device.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade300),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: '+213 123 456 789',
                  helperText: 'Add a contact number for client follow-up.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'A note, address, or account reference',
                  helperText:
                      'Use this field for client details or special terms.',
                ),
              ),
              if (widget.availableTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableTags.map((tag) {
                    final selected = _selectedTagIds.contains(tag.id);
                    final color = _tagColor(tag.colorHex);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: selected,
                      selectedColor: color.withValues(alpha: 0.2),
                      shape: const StadiumBorder(),
                      checkmarkColor: color,
                      avatar: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      side: BorderSide(
                        color: selected
                            ? color
                            : AppTheme.mutedFg.withValues(alpha: 0.4),
                      ),
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
                        setState(() => _busy = true);
                        try {
                          await widget.onSaved(
                            _name.text.trim(),
                            _phone.text.trim().isEmpty
                                ? null
                                : _phone.text.trim(),
                            _note.text.trim().isEmpty
                                ? null
                                : _note.text.trim(),
                            _selectedTagIds.toList(growable: false),
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
                    : Text(widget.submitLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

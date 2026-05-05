import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class TagEditorScreen extends ConsumerStatefulWidget {
  const TagEditorScreen({super.key});

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  String _scope = 'client';

  @override
  Widget build(BuildContext context) {
    final tagsAsync = _scope == 'client'
        ? ref.watch(clientScopeTagsProvider)
        : ref.watch(transactionScopeTagsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag editor'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTagDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'client', label: Text('Client tags')),
                ButtonSegment(
                  value: 'transaction',
                  label: Text('Transaction tags'),
                ),
              ],
              selected: {_scope},
              onSelectionChanged: (value) =>
                  setState(() => _scope = value.first),
            ),
          ),
          Expanded(
            child: tagsAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return Center(
                    child: Text(
                      'No tags yet',
                      style: TextStyle(color: AppTheme.mutedFg),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tag = tags[i];
                    final color = _parseTagColor(tag.colorHex);
                    return ListTile(
                      tileColor: color.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: color.withValues(alpha: 0.45)),
                      ),
                      title: Text(tag.name),
                      subtitle: Text(tag.scope),
                      leading: CircleAvatar(backgroundColor: color, radius: 10),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openTagDialog(context, tag: tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(ledgerRepositoryProvider)
                                  .deleteTag(tag.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTagDialog(BuildContext context, {Tag? tag}) async {
    final name = TextEditingController(text: tag?.name ?? '');
    var colorHex = tag?.colorHex ?? '#4F46E5';
    final colors = <String>[
      '#EF4444',
      '#F97316',
      '#EAB308',
      '#22C55E',
      '#14B8A6',
      '#0EA5E9',
      '#6366F1',
      '#A855F7',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tag == null ? 'New tag' : 'Edit tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Tag name'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((hex) {
                    final selected = hex == colorHex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => colorHex = hex),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _parseTagColor(hex),
                          border: Border.all(
                            width: selected ? 3 : 1,
                            color: selected ? Colors.white : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final trimmed = name.text.trim();
                if (trimmed.isEmpty) return;
                final repo = ref.read(ledgerRepositoryProvider);
                if (tag == null) {
                  await repo.createTag(
                    name: trimmed,
                    colorHex: colorHex,
                    scope: _scope,
                  );
                } else {
                  await repo.updateTag(
                    id: tag.id,
                    name: trimmed,
                    colorHex: colorHex,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _parseTagColor(String hex) {
  final clean = hex.replaceAll('#', '');
  if (clean.length != 6) return AppTheme.receivableAccent;
  final parsed = int.tryParse(clean, radix: 16);
  if (parsed == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | parsed);
}

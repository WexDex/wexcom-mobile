import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ledger_repository.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _controller = TextEditingController();
  final _overdueController = TextEditingController();
  final _importPayloadController = TextEditingController();
  bool _contactsAutofillEnabled = true;
  bool _settingsLoaded = false;
  bool _backupBusy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final repo = ref.read(ledgerRepositoryProvider);
      final code = await repo.defaultCurrencyCode();
      final contactsEnabled = await repo.contactsAutofillEnabled();
      final overdueDays = await repo.overdueAlertDays();
      if (!mounted) return;
      setState(() {
        _controller.text = code;
        _overdueController.text = overdueDays.toString();
        _contactsAutofillEnabled = contactsEnabled;
        _settingsLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overdueController.dispose();
    _importPayloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileNameAsync = ref.watch(profileNameProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Display currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ISO code used when formatting amounts (default DZD). Changing this does not convert stored balances.',
              style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Currency code',
                hintText: 'DZD',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(ledgerRepositoryProvider);
                await repo.setDefaultCurrencyCode(_controller.text);
                final overdue = int.tryParse(_overdueController.text.trim()) ?? 10;
                await repo.setOverdueAlertDays(overdue);
                ref.invalidate(defaultCurrencyProvider);
                ref.invalidate(overdueAlertDaysProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
            Text(
              'Overdue alert',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _overdueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unpaid debt threshold (days)',
                hintText: '10',
              ),
            ),
            const SizedBox(height: 18),
            if (_settingsLoaded)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use contacts for client autofill'),
                subtitle: const Text(
                  'Suggest existing phone contacts when entering a client name.',
                ),
                value: _contactsAutofillEnabled,
                onChanged: (value) async {
                  final service = ref.read(contactsServiceProvider);
                  var next = value;
                  if (value) {
                    if (!service.isSupported) {
                      next = false;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Contacts autofill is available on Android and iOS only.',
                            ),
                          ),
                        );
                      }
                    } else {
                      final granted = await service.requestPermission();
                      if (!granted) {
                        next = false;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contacts permission was denied. Enable it to use autofill.',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  }
                  await ref
                      .read(ledgerRepositoryProvider)
                      .setContactsAutofillEnabled(next);
                  ref.invalidate(contactsAutofillEnabledProvider);
                  if (!mounted) return;
                  setState(() => _contactsAutofillEnabled = next);
                },
              ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insights_outlined),
              title: const Text('User stats'),
              subtitle: Text(
                profileNameAsync.valueOrNull?.trim().isNotEmpty == true
                    ? 'Signed in as ${profileNameAsync.valueOrNull}'
                    : 'Lifetime totals and your profile name',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/stats'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Export all data'),
              subtitle: const Text('Export all clients and their transactions'),
              trailing: _backupBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _backupBusy ? null : _exportAllData,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download_outlined),
              title: const Text('Import data'),
              subtitle: const Text(
                'Adds imported data and resolves client conflicts',
              ),
              trailing: _backupBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _backupBusy ? null : _openImportDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _backupBusy = true);
    try {
      final json = await ref
          .read(ledgerRepositoryProvider)
          .exportAllClientsWithTransactionsJson();
      if (!mounted) return;
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
                title: const Text('Copy to clipboard'),
                onTap: () => Navigator.pop(ctx, 'clipboard'),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Download JSON file'),
                onTap: () => Navigator.pop(ctx, 'download'),
              ),
            ],
          ),
        ),
      );
      if (action == null) return;
      if (action == 'clipboard') {
        await Clipboard.setData(ClipboardData(text: json));
      } else {
        try {
          final location = await getSaveLocation(
            suggestedName:
                'wexcom_backup_${DateTime.now().millisecondsSinceEpoch}.json',
            acceptedTypeGroups: const [
              XTypeGroup(label: 'json', extensions: ['json']),
            ],
          );
          if (location == null) return;
          final file = XFile.fromData(
            Uint8List.fromList(utf8.encode(json)),
            mimeType: 'application/json',
            name: 'wexcom_backup.json',
          );
          await file.saveTo(location.path);
        } catch (_) {
          await Clipboard.setData(ClipboardData(text: json));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File save is unavailable on this device. Export copied to clipboard instead.',
              ),
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'clipboard'
                ? 'Export copied to clipboard'
                : 'Export downloaded successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _openImportDialog() async {
    ImportPreview? preview;
    ImportApplyResult? importReport;
    final resolutionByKey = <String, ImportConflictResolution>{};
    var analyzing = false;
    var importing = false;
    var sourceLabel = 'paste';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Import backup'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import center',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Import adds data to the current database. Source: $sourceLabel',
                    style: TextStyle(color: AppTheme.mutedFg),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: analyzing || importing
                            ? null
                            : () async {
                                try {
                                  final file = await openFile(
                                    acceptedTypeGroups: const [
                                      XTypeGroup(
                                        label: 'json',
                                        extensions: ['json'],
                                      ),
                                    ],
                                  );
                                  if (file == null) return;
                                  final raw = await file.readAsString();
                                  setLocalState(() {
                                    _importPayloadController.text = raw;
                                    sourceLabel = 'file';
                                    preview = null;
                                    resolutionByKey.clear();
                                  });
                                } catch (_) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'File picker is unavailable on this device. Paste JSON instead.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.file_open_outlined),
                        label: const Text('Import from file'),
                      ),
                      OutlinedButton.icon(
                        onPressed: analyzing || importing
                            ? null
                            : () async {
                                final clip = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                final raw = clip?.text?.trim() ?? '';
                                if (raw.isEmpty) return;
                                setLocalState(() {
                                  _importPayloadController.text = raw;
                                  sourceLabel = 'clipboard';
                                  preview = null;
                                  resolutionByKey.clear();
                                });
                              },
                        icon: const Icon(Icons.content_paste_outlined),
                        label: const Text('Paste from clipboard'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (preview != null) ...[
                    _ImportSummaryBox(
                      preview: preview!,
                      resolutionByKey: resolutionByKey,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (importReport != null) ...[
                    _ImportReportBox(report: importReport!),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _importPayloadController,
                    minLines: 8,
                    maxLines: 14,
                    decoration: const InputDecoration(
                      labelText: 'Backup JSON',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (preview != null && preview!.conflicts.isNotEmpty)
                    ...preview!.conflicts.map(
                      (conflict) => Padding(
                        key: ValueKey('conflict-${conflict.importClientKey}'),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conflict: ${conflict.importClientName}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppTheme.ledgerPayment.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Input\nName: ${conflict.importClientName}\nPhone: ${conflict.importClientPhone ?? '-'}\nNote: ${conflict.importClientNote ?? '-'}\nTxs: ${conflict.importTxCount}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppTheme.ledgerDebt.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Current\nName: ${conflict.existingClientName}\nPhone: ${conflict.existingClientPhone ?? '-'}\nNote: ${conflict.existingClientNote ?? '-'}\nTxs: ${conflict.existingTxCount}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<ImportConflictResolution>(
                              key: ValueKey(
                                'resolution-${conflict.importClientKey}',
                              ),
                              value:
                                  resolutionByKey[conflict.importClientKey] ??
                                      ImportConflictResolution.mix,
                              items: const [
                                DropdownMenuItem(
                                  value: ImportConflictResolution.mix,
                                  child: Text('Mix'),
                                ),
                                DropdownMenuItem(
                                  value: ImportConflictResolution.erase,
                                  child: Text('Erase'),
                                ),
                                DropdownMenuItem(
                                  value: ImportConflictResolution.ignore,
                                  child: Text('Ignore'),
                                ),
                              ],
                              onChanged: importing
                                  ? null
                                  : (value) {
                                if (value == null) return;
                                setLocalState(() {
                                  resolutionByKey[conflict.importClientKey] =
                                      value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: importing ? null : () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            FilledButton.tonalIcon(
              onPressed: analyzing || importing
                  ? null
                  : () async {
                      final raw = _importPayloadController.text.trim();
                      if (raw.isEmpty) return;
                      setLocalState(() => analyzing = true);
                      try {
                        final p = await ref
                            .read(ledgerRepositoryProvider)
                            .previewImport(raw);
                        for (final conflict in p.conflicts) {
                          resolutionByKey.putIfAbsent(
                            conflict.importClientKey,
                            () => ImportConflictResolution.mix,
                          );
                        }
                        setLocalState(() {
                          preview = p;
                          importReport = null;
                        });
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Import preview failed: $e')),
                        );
                      } finally {
                        setLocalState(() => analyzing = false);
                      }
                    },
              icon: const Icon(Icons.analytics_outlined),
              label: analyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze conflicts'),
            ),
            FilledButton.icon(
              onPressed: importing
                  ? null
                  : () async {
                      final raw = _importPayloadController.text.trim();
                      if (raw.isEmpty) return;
                      setLocalState(() => importing = true);
                      try {
                        final result = await ref
                            .read(ledgerRepositoryProvider)
                            .importFromJson(
                              raw,
                              conflictResolutionsByImportKey: resolutionByKey,
                            );
                        ref.invalidate(activeClientsProvider);
                        ref.invalidate(archivedClientsProvider);
                        ref.invalidate(allTransactionsProvider(null));
                        if (!mounted) return;
                        setLocalState(() => importReport = result);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Import failed: $e')),
                        );
                      } finally {
                        if (ctx.mounted) {
                          setLocalState(() => importing = false);
                        }
                      }
                    },
              icon: const Icon(Icons.download_done_outlined),
              label: importing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run import'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportSummaryBox extends StatelessWidget {
  const _ImportSummaryBox({
    required this.preview,
    required this.resolutionByKey,
  });

  final ImportPreview preview;
  final Map<String, ImportConflictResolution> resolutionByKey;

  @override
  Widget build(BuildContext context) {
    var mix = 0;
    var erase = 0;
    var ignore = 0;
    for (final c in preview.conflicts) {
      switch (resolutionByKey[c.importClientKey] ?? ImportConflictResolution.mix) {
        case ImportConflictResolution.mix:
          mix += 1;
        case ImportConflictResolution.erase:
          erase += 1;
        case ImportConflictResolution.ignore:
          ignore += 1;
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.receivableAccent.withValues(alpha: 0.35)),
        color: AppTheme.receivableAccent.withValues(alpha: 0.08),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MiniStatChip(label: 'Clients in file', value: '${preview.totalClients}'),
          _MiniStatChip(label: 'New clients', value: '${preview.newClients}'),
          _MiniStatChip(label: 'Conflicts', value: '${preview.conflicts.length}'),
          _MiniStatChip(label: 'Mix', value: '$mix'),
          _MiniStatChip(label: 'Erase', value: '$erase'),
          _MiniStatChip(label: 'Ignore', value: '$ignore'),
        ],
      ),
    );
  }
}

class _ImportReportBox extends StatelessWidget {
  const _ImportReportBox({required this.report});

  final ImportApplyResult report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.ledgerPayment.withValues(alpha: 0.45)),
        color: AppTheme.ledgerPayment.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post-import report',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniStatChip(label: 'Clients added', value: '${report.addedClients}'),
              _MiniStatChip(label: 'Clients changed', value: '${report.updatedClients}'),
              _MiniStatChip(label: 'Mixed', value: '${report.mixedClients}'),
              _MiniStatChip(label: 'Erased+replaced', value: '${report.erasedClients}'),
              _MiniStatChip(label: 'Clients ignored', value: '${report.skippedClients}'),
              _MiniStatChip(label: 'Tx added', value: '${report.addedTransactions}'),
              _MiniStatChip(label: 'Tx removed', value: '${report.removedTransactions}'),
              _MiniStatChip(
                label: 'Tx duplicates skipped',
                value: '${report.skippedDuplicateTransactions}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.8),
        ),
        color: AppTheme.surface,
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.labelMedium,
          children: [
            TextSpan(
              text: '$value ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }
}

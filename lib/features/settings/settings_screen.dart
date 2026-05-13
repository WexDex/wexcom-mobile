import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ledger_repository.dart';
import '../../providers/providers.dart';
import '../../services/backup_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _controller = TextEditingController();
  final _overdueController = TextEditingController();
  final _importPayloadController = TextEditingController();
  final _syncUrlController = TextEditingController();
  final _syncUsernameController = TextEditingController();
  final _syncPasswordController = TextEditingController();
  bool _contactsAutofillEnabled = true;
  bool _syncEnabled = false;
  bool _syncPeriodicEnabled = false;
  int _syncIntervalHours = 24;
  bool _settingsLoaded = false;
  bool _backupBusy = false;
  // Cloud sync card state
  bool _syncPasswordVisible = false;
  bool _cloudTestBusy = false;
  bool _cloudUploadBusy = false;
  bool _cloudDownloadBusy = false;
  CloudServerStatus? _cloudStatus;
  _CloudDotState _cloudDotState = _CloudDotState.unconfigured;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final repo = ref.read(ledgerRepositoryProvider);
      final code = await repo.defaultCurrencyCode();
      final contactsEnabled = await repo.contactsAutofillEnabled();
      final overdueDays = await repo.overdueAlertDays();
      final syncSettings = await repo.syncSettings();
      if (!mounted) return;
      setState(() {
        _controller.text = code;
        _overdueController.text = overdueDays.toString();
        _contactsAutofillEnabled = contactsEnabled;
        _syncUrlController.text = syncSettings.serverUrl ?? '';
        _syncUsernameController.text = syncSettings.username ?? '';
        _syncPasswordController.text = syncSettings.password ?? '';
        _syncEnabled = syncSettings.enabled;
        _syncPeriodicEnabled = syncSettings.periodicEnabled;
        _syncIntervalHours = syncSettings.intervalHours;
        _settingsLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overdueController.dispose();
    _importPayloadController.dispose();
    // Persist cloud fields whenever the screen is left, even without "Save"
    final url = _syncUrlController.text.trim();
    final user = _syncUsernameController.text.trim();
    final pass = _syncPasswordController.text.trim();
    if (url.isNotEmpty || user.isNotEmpty || pass.isNotEmpty) {
      ref.read(ledgerRepositoryProvider).saveSyncSettings(
            enabled: _syncEnabled,
            serverUrl: url,
            username: user,
            password: pass,
            intervalHours: _syncIntervalHours,
            periodicEnabled: _syncPeriodicEnabled,
          );
    }
    _syncUrlController.dispose();
    _syncUsernameController.dispose();
    _syncPasswordController.dispose();
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
                await repo.saveSyncSettings(
                  enabled: _syncEnabled,
                  serverUrl: _syncUrlController.text,
                  username: _syncUsernameController.text,
                  password: _syncPasswordController.text,
                  intervalHours: _syncIntervalHours,
                  periodicEnabled: _syncPeriodicEnabled,
                );
                ref.invalidate(defaultCurrencyProvider);
                ref.invalidate(overdueAlertDaysProvider);
                ref.invalidate(syncSettingsProvider);
                ref.invalidate(syncServiceProvider);
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
            const SizedBox(height: 22),
            _buildSyncSection(),
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
            _buildImportExportSection(),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_outlined),
              title: const Text('Audit log'),
              subtitle: const Text('View recent changes to clients and transactions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/audit-log'),
            ),
            const Divider(height: 24),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImportExportSection() {
    final busy = _backupBusy;
    Widget chevron = const Icon(Icons.chevron_right);
    Widget spinner = const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Import & Export',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // ── JSON ─────────────────────────────────────────────────────────
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Export JSON'),
          subtitle: const Text('All clients & transactions as a portable .json file'),
          trailing: busy ? spinner : chevron,
          onTap: busy ? null : _exportAllData,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_for_offline_outlined),
          title: const Text('Import JSON'),
          subtitle: const Text('Merge clients from a .json file (non-destructive)'),
          trailing: busy ? spinner : chevron,
          onTap: busy ? null : _openImportDialog,
        ),
        const Divider(height: 20),
        // ── SQLite ───────────────────────────────────────────────────────
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.save_outlined),
          title: const Text('Export SQLite backup (.wexcom)'),
          subtitle: const Text('Raw database snapshot — fastest full restore'),
          trailing: chevron,
          onTap: _exportLocalBackup,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restore_outlined),
          title: const Text('Import SQLite backup'),
          subtitle: const Text('Restore from a .wexcom file — replaces all data'),
          trailing: chevron,
          onTap: _importLocalBackup,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    final s = ref.watch(appSettingsProvider).valueOrNull;
    if (s == null) return const SizedBox.shrink();

    void save({
      bool? overdueEnabled,
      int? overdueHour,
      bool? milestoneEnabled,
      int? milestoneMinor,
      bool? inactivityEnabled,
      int? inactivityDays,
      bool? syncEnabled,
    }) {
      ref.read(ledgerRepositoryProvider).saveNotificationSettings(
            overdueEnabled: overdueEnabled ?? s.notifOverdueEnabled,
            overdueHour: overdueHour ?? s.notifOverdueHour,
            balanceMilestoneEnabled:
                milestoneEnabled ?? s.notifBalanceMilestoneEnabled,
            balanceMilestoneMinor:
                milestoneMinor ?? s.notifBalanceMilestoneMinor,
            inactivityEnabled: inactivityEnabled ?? s.notifInactivityEnabled,
            inactivityDays: inactivityDays ?? s.notifInactivityDays,
            syncEnabled: syncEnabled ?? s.notifSyncEnabled,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Notifications',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.warning_amber_outlined),
          title: const Text('Overdue debt alert'),
          subtitle: const Text('Daily reminder when you have overdue debts'),
          value: s.notifOverdueEnabled,
          onChanged: (v) => save(overdueEnabled: v),
        ),
        if (s.notifOverdueEnabled)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 56),
            title: Text('Alert time: ${s.notifOverdueHour}:00'),
            trailing: const Icon(Icons.schedule_outlined, size: 18),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: s.notifOverdueHour, minute: 0),
              );
              if (picked != null) save(overdueHour: picked.hour);
            },
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Balance milestone'),
          subtitle: Text(
              'Alert when a client exceeds ${MoneyFormat.formatMinor(s.notifBalanceMilestoneMinor, 'DZD')}'),
          value: s.notifBalanceMilestoneEnabled,
          onChanged: (v) => save(milestoneEnabled: v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.hourglass_empty_outlined),
          title: const Text('No activity reminder'),
          subtitle: Text(
              'After ${s.notifInactivityDays} days without transactions'),
          value: s.notifInactivityEnabled,
          onChanged: (v) => save(inactivityEnabled: v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.cloud_done_outlined),
          title: const Text('Cloud sync notification'),
          subtitle: const Text('Notify after a successful backup upload'),
          value: s.notifSyncEnabled,
          onChanged: (v) => save(syncEnabled: v),
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    final settingsAsync = ref.watch(syncSettingsProvider);
    final lastUploadAt = settingsAsync.valueOrNull?.lastUploadAt;

    final dotColor = switch (_cloudDotState) {
      _CloudDotState.unconfigured => AppTheme.mutedFg,
      _CloudDotState.untested => Colors.amber,
      _CloudDotState.connected => Colors.greenAccent,
      _CloudDotState.offline => Theme.of(context).colorScheme.error,
    };
    final dotLabel = switch (_cloudDotState) {
      _CloudDotState.unconfigured => 'Not set up',
      _CloudDotState.untested => 'Not tested',
      _CloudDotState.connected => 'Connected',
      _CloudDotState.offline => 'Offline',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cloud sync', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Upload the database to your PC server whenever you want a backup. '
          'The app stays fully offline — sync is always opt-in.',
          style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: dotColor.withValues(alpha: _cloudDotState == _CloudDotState.unconfigured ? 0.15 : 0.3),
            ),
            boxShadow: _cloudDotState == _CloudDotState.connected
                ? AppTheme.cardGlow(Colors.greenAccent, intensity: 0.08)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.cloud_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Cloud Server',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: _cloudDotState == _CloudDotState.connected
                            ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 6)]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(dotLabel, style: TextStyle(color: dotColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                // ── Fields ───────────────────────────────────────────────
                TextField(
                  controller: _syncUrlController,
                  onChanged: (_) => _updateDotFromFields(),
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'https://wexcom.wexdex.online',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _syncUsernameController,
                  onChanged: (_) => _updateDotFromFields(),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _syncPasswordController,
                  obscureText: !_syncPasswordVisible,
                  onChanged: (_) => _updateDotFromFields(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_syncPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _syncPasswordVisible = !_syncPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Test connection ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cloudTestBusy ? null : _testCloudConnection,
                    icon: _cloudTestBusy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: Text(_cloudTestBusy ? 'Testing…' : 'Test connection'),
                  ),
                ),
                // ── Server info (when connected) ─────────────────────────
                if (_cloudStatus != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      color: Colors.greenAccent.withValues(alpha: 0.07),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: 'Server backup',
                          value: _cloudStatus!.dbReady
                              ? '${_cloudStatus!.fileSizeLabel} — ${_formatMaybeTime(_cloudStatus!.lastUploadAt)}'
                              : 'No backup yet',
                        ),
                        if (lastUploadAt != null)
                          _InfoRow(label: 'Last local upload', value: _formatMaybeTime(lastUploadAt)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                // ── Upload ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _cloudUploadBusy || _cloudDownloadBusy ? null : _cloudUpload,
                    icon: _cloudUploadBusy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_cloudUploadBusy ? 'Uploading…' : '↑  Upload now'),
                  ),
                ),
                const SizedBox(height: 8),
                // ── Download & restore ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cloudUploadBusy || _cloudDownloadBusy ? null : _cloudDownload,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4)),
                    ),
                    icon: _cloudDownloadBusy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cloud_download_outlined),
                    label: Text(_cloudDownloadBusy ? 'Downloading…' : '↓  Download & restore'),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Auto-upload toggle ────────────────────────────────────
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Auto-upload when app opens'),
                  subtitle: const Text('Uploads only if data changed since last backup.'),
                  value: _syncPeriodicEnabled,
                  onChanged: (value) => setState(() => _syncPeriodicEnabled = value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateDotFromFields() {
    final hasFields = _syncUrlController.text.trim().isNotEmpty &&
        _syncUsernameController.text.trim().isNotEmpty &&
        _syncPasswordController.text.trim().isNotEmpty;
    setState(() {
      if (!hasFields) {
        _cloudDotState = _CloudDotState.unconfigured;
      } else if (_cloudDotState == _CloudDotState.unconfigured) {
        _cloudDotState = _CloudDotState.untested;
      }
    });
  }

  CloudSyncService? _buildCloudService() {
    final url = _syncUrlController.text.trim();
    final user = _syncUsernameController.text.trim();
    final pass = _syncPasswordController.text.trim();
    if (url.isEmpty || user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in server URL, username, and password first.')),
      );
      return null;
    }
    return CloudSyncService(serverUrl: url, username: user, password: pass);
  }

  Future<void> _testCloudConnection() async {
    final svc = _buildCloudService();
    if (svc == null) return;
    setState(() => _cloudTestBusy = true);
    try {
      final status = await svc.fetchStatus();
      if (!mounted) return;
      if (status == null) {
        setState(() {
          _cloudDotState = _CloudDotState.offline;
          _cloudStatus = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server unreachable or credentials rejected.')),
        );
      } else {
        setState(() {
          _cloudDotState = _CloudDotState.connected;
          _cloudStatus = status;
        });
      }
    } finally {
      if (mounted) setState(() => _cloudTestBusy = false);
    }
  }

  Future<void> _cloudUpload() async {
    final svc = _buildCloudService();
    if (svc == null) return;
    setState(() => _cloudUploadBusy = true);
    try {
      final result = await svc.uploadDatabase();
      if (!mounted) return;
      if (result.ok) {
        final repo = ref.read(ledgerRepositoryProvider);
        if (result.sha256 != null) {
          await repo.updateSyncUploadMeta(
            uploadedAt: result.uploadedAt ?? DateTime.now().toUtc(),
            sha256Hex: result.sha256!,
          );
        }
        ref.invalidate(syncSettingsProvider);
        // Refresh server info
        final status = await svc.fetchStatus();
        if (!mounted) return;
        setState(() => _cloudStatus = status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded — ${result.sizeBytes != null ? '${(result.sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB' : 'done'}')),
        );
      } else {
        setState(() => _cloudDotState = _CloudDotState.offline);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _cloudUploadBusy = false);
    }
  }

  Future<void> _cloudDownload() async {
    final svc = _buildCloudService();
    if (svc == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download & restore?'),
        content: const Text(
          'This will replace ALL local data with the server backup on the next app restart.\n\n'
          'Current data will be overwritten. Make sure you have an export if needed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Download & restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cloudDownloadBusy = true);
    try {
      final result = await svc.downloadDatabase();
      if (!mounted) return;
      if (result.ok) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore ready'),
            content: const Text('The backup has been downloaded. Restart the app to apply it.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Download failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _cloudDownloadBusy = false);
    }
  }

  String _formatMaybeTime(DateTime? time) {
    if (time == null) return '-';
    return time.toLocal().toString();
  }

  Future<void> _exportLocalBackup() async {
    final result = await BackupService.exportBackup();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.ok
            ? 'Backup saved'
            : 'Export failed: ${result.message ?? 'unknown error'}'),
      ),
    );
  }

  Future<void> _importLocalBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import backup?'),
        content: const Text(
          'This will replace ALL local data with the backup on the next restart. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await BackupService.importBackup();
    if (!mounted) return;
    if (result.ok) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore staged'),
          content: const Text(
              'Backup ready. Restart the app to apply it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (result.message != 'Cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: ${result.message}')),
      );
    }
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

  Future<void> _openImportDialog({
    String? initialPayload,
    String initialSourceLabel = 'paste',
  }) async {
    ImportPreview? preview;
    ImportApplyResult? importReport;
    final resolutionByKey = <String, ImportConflictResolution>{};
    var analyzing = false;
    var importing = false;
    var sourceLabel = initialSourceLabel;
    if (initialPayload != null && initialPayload.trim().isNotEmpty) {
      _importPayloadController.text = initialPayload;
    }

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

// ─── Helpers ─────────────────────────────────────────────────────────────────

enum _CloudDotState { unconfigured, untested, connected, offline }

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

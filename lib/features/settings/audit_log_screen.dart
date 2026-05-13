import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final f in [
                  ('all', 'All'),
                  ('transaction', 'Transactions'),
                  ('client', 'Clients'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: _filter == f.$1,
                      onSelected: (_) => setState(() => _filter = f.$1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: logsAsync.when(
        data: (logs) {
          final filtered = _filter == 'all'
              ? logs
              : logs.where((l) => l.entityType == _filter).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_outlined,
                      size: 48, color: AppTheme.mutedFg),
                  const SizedBox(height: 12),
                  Text('No audit entries',
                      style: TextStyle(color: AppTheme.mutedFg)),
                ],
              ),
            );
          }

          // Group by date
          final groups = <String, List<_AuditEntry>>{};
          for (final log in filtered) {
            final local = log.createdAt.toLocal();
            final key = MoneyFormat.formatDate(local);
            groups.putIfAbsent(key, () => []).add(
              _AuditEntry(
                action: log.action,
                entityType: log.entityType,
                entityId: log.entityId,
                detail: log.detail,
                createdAt: local,
              ),
            );
          }

          final dateKeys = groups.keys.toList();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: dateKeys.length,
            itemBuilder: (_, i) {
              final dateLabel = dateKeys[i];
              final entries = groups[dateLabel]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.mutedFg,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  ...entries.map((e) => _AuditRow(entry: e)),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AuditEntry {
  const _AuditEntry({
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.detail,
    required this.createdAt,
  });
  final String action;
  final String entityType;
  final String entityId;
  final String? detail;
  final DateTime createdAt;
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.entry});
  final _AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _meta(entry.action);
    final time =
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        entry.entityId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: AppTheme.mutedFg),
      ),
      trailing: Text(time,
          style: TextStyle(fontSize: 11, color: AppTheme.mutedFg)),
    );
  }

  static (IconData, Color, String) _meta(String action) {
    switch (action) {
      case 'create_tx':
        return (Icons.add_circle_outline, AppTheme.ledgerPayment, 'Transaction created');
      case 'cancel_tx':
        return (Icons.cancel_outlined, AppTheme.ledgerCancel, 'Transaction cancelled');
      case 'settle_tx':
        return (Icons.check_circle_outline, AppTheme.ledgerPayment, 'Debt settled');
      case 'archive_client':
        return (Icons.archive_outlined, AppTheme.mutedFg, 'Client archived');
      case 'restore_client':
        return (Icons.unarchive_outlined, AppTheme.brandPrimary, 'Client restored');
      default:
        return (Icons.history, AppTheme.mutedFg, action);
    }
  }
}

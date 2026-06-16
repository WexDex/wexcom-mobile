import 'dart:convert';

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

  static const _filters = [
    ('all', 'All'),
    ('transaction', 'Transactions'),
    ('client', 'Clients'),
    ('finance', 'Finance'),
    ('wishlist', 'Wishlist'),
    ('wallet', 'Wallet'),
    ('currency', 'Currency'),
    ('settings', 'Settings'),
    ('subscription', 'Subscriptions'),
    ('backup', 'Backup'),
  ];

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final f in _filters)
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

  bool get isSilent {
    if (detail == null || detail!.isEmpty) return false;
    try {
      final map = jsonDecode(detail!) as Map<String, dynamic>;
      return map['silent'] == true;
    } catch (_) {
      return false;
    }
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.entry});
  final _AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _meta(entry.action);
    final time =
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';
    final displayColor = entry.isSilent ? AppTheme.mutedFg : color;
    final subtitle = entry.isSilent ? 'Background · ${entry.entityId}' : entry.entityId;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: displayColor.withValues(alpha: 0.15),
        child: Icon(icon, size: 16, color: displayColor),
      ),
      title: Text(label, style: TextStyle(fontSize: 13, color: entry.isSilent ? AppTheme.mutedFg : null)),
      subtitle: Text(
        subtitle,
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
      case 'update_tx':
        return (Icons.edit_outlined, AppTheme.ledgerPayment, 'Transaction updated');
      case 'cancel_tx':
        return (Icons.cancel_outlined, AppTheme.ledgerCancel, 'Transaction cancelled');
      case 'settle_tx':
        return (Icons.check_circle_outline, AppTheme.ledgerPayment, 'Debt settled');
      case 'archive_client':
        return (Icons.archive_outlined, AppTheme.mutedFg, 'Client archived');
      case 'restore_client':
        return (Icons.unarchive_outlined, AppTheme.brandPrimary, 'Client restored');
      case 'create_client':
        return (Icons.person_add_outlined, AppTheme.brandPrimary, 'Client created');
      case 'update_client':
        return (Icons.person_outline, AppTheme.brandPrimary, 'Client updated');
      case 'create_expense':
        return (Icons.remove_circle_outline, AppTheme.personalExpense, 'Expense added');
      case 'update_expense':
        return (Icons.edit_note, AppTheme.personalExpense, 'Expense updated');
      case 'delete_expense':
        return (Icons.delete_outline, AppTheme.personalExpense, 'Expense deleted');
      case 'create_gain':
        return (Icons.add_circle, AppTheme.personalGain, 'Gain added');
      case 'update_gain':
        return (Icons.edit_note, AppTheme.personalGain, 'Gain updated');
      case 'delete_gain':
        return (Icons.delete_outline, AppTheme.personalGain, 'Gain deleted');
      case 'wishlist_add':
        return (Icons.add_shopping_cart, AppTheme.brandSecondary, 'Wishlist item added');
      case 'wishlist_update':
        return (Icons.edit, AppTheme.brandSecondary, 'Wishlist item updated');
      case 'wishlist_purchase':
        return (Icons.check_circle, AppTheme.brandSecondary, 'Wishlist purchased');
      case 'wishlist_delete':
        return (Icons.delete_outline, AppTheme.brandSecondary, 'Wishlist item removed');
      case 'wallet_adjust':
        return (Icons.account_balance_wallet, AppTheme.brandPrimary, 'Wallet adjusted');
      case 'wallet_account_upsert':
        return (Icons.savings_outlined, AppTheme.brandPrimary, 'Wallet account saved');
      case 'wallet_account_delete':
        return (Icons.delete_outline, AppTheme.brandPrimary, 'Wallet account deleted');
      case 'rate_set':
        return (Icons.currency_exchange, AppTheme.mutedFg, 'Exchange rate set');
      case 'currency_add':
        return (Icons.attach_money, AppTheme.mutedFg, 'Currency added');
      case 'currency_delete':
        return (Icons.money_off, AppTheme.mutedFg, 'Currency removed');
      case 'settings_notif_change':
        return (Icons.notifications_outlined, AppTheme.mutedFg, 'Notification settings');
      case 'settings_prefs_change':
        return (Icons.tune, AppTheme.mutedFg, 'Preferences changed');
      case 'json_export':
        return (Icons.upload_file, AppTheme.mutedFg, 'JSON exported');
      case 'json_import':
        return (Icons.download, AppTheme.mutedFg, 'JSON imported');
      case 'subscription_create':
        return (Icons.autorenew, AppTheme.brandPrimary, 'Subscription created');
      case 'subscription_update':
        return (Icons.edit, AppTheme.brandPrimary, 'Subscription updated');
      case 'subscription_delete':
        return (Icons.delete_outline, AppTheme.brandPrimary, 'Subscription deleted');
      case 'subscription_log':
        return (Icons.receipt_long, AppTheme.personalExpense, 'Subscription logged');
      default:
        return (Icons.history, AppTheme.mutedFg, action);
    }
  }
}

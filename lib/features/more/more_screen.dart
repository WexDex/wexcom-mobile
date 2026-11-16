import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../finance/bulk_import/bulk_import_more_section.dart';

/// Fourth tab: less-frequent destinations, each opened as a pushed page.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, Color color, String title, String subtitle, String location) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.mutedFg)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(location),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const BulkImportMoreSection(),
          tile(Icons.receipt_long_rounded, AppTheme.receivableAccent, 'Ledger',
              'Every client transaction, filterable', '/transactions'),
          tile(Icons.label_rounded, AppTheme.brandSecondary, 'Tags',
              'Client and transaction tags', '/tags'),
          tile(Icons.cloud_sync_rounded, AppTheme.brandPrimary, 'Backup & cloud sync',
              'Export, import and server sync — in Settings', '/settings'),
          tile(Icons.settings_rounded, AppTheme.mutedFg, 'Settings',
              'Currency, notifications, preferences', '/settings'),
        ],
      ),
    );
  }
}

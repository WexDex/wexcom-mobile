import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';
import 'bulk_import_syntax_panel.dart';

/// “Import from text” block on the More tab.
class BulkImportMoreSection extends StatefulWidget {
  const BulkImportMoreSection({super.key});

  @override
  State<BulkImportMoreSection> createState() => _BulkImportMoreSectionState();
}

class _BulkImportMoreSectionState extends State<BulkImportMoreSection> {
  var _fullSyntax = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: const Icon(Icons.text_snippet_outlined, color: AppTheme.brandPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import from text',
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Paste one entry per line — expenses, gains, or client debt/payment. Review before saving.',
                          style: text.bodySmall?.copyWith(color: AppTheme.mutedFg, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const BulkImportSyntaxPanel(showPreviews: true, dense: true),
              TextButton(
                onPressed: () => setState(() => _fullSyntax = !_fullSyntax),
                child: Text(_fullSyntax ? 'Hide full syntax' : 'Full syntax'),
              ),
              if (_fullSyntax)
                const BulkImportSyntaxPanel(showPreviews: false, showFullSyntax: true, dense: true),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => context.push('/finance/bulk-import'),
                child: const Text('Open import'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
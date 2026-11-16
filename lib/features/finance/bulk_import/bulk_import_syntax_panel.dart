import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'bulk_import_models.dart';

/// Full multiline hint for empty compose field.
const bulkImportComposeHint = '''
One line = one entry. Flags: d:date cat:category w:wallet

Personal expense (default Pocket):
1500 lunch
2200 groceries d:2025-11-10 cat:Food
800 transport cat:Transport w:Bank

Personal gain:
+1200 salary d:15/11/2025
-500 refund cat:Other

Client — they owe you (debt):
@Ahmed +5000 cement d:2025-11-01
@Sara 3000 parts

Client — they paid you (payment):
@Ahmed -2000 paid cash

# Lines like this are ignored (comments)
''';

const bulkImportSyntaxExamples = [
  BulkImportSyntaxExample(
    line: '1500 lunch',
    previewLabel: 'Expense · lunch · Pocket · today',
  ),
  BulkImportSyntaxExample(
    line: '2200 groceries d:2025-11-10 cat:Food',
    previewLabel: 'Expense · groceries · Food · 10 Nov · Pocket',
  ),
  BulkImportSyntaxExample(
    line: '+1200 salary',
    previewLabel: 'Gain · salary · Pocket · today',
  ),
  BulkImportSyntaxExample(
    line: '@Ahmed +5000 cement',
    previewLabel: 'Client debt · Ahmed · cement',
  ),
  BulkImportSyntaxExample(
    line: '@Ahmed -2000 paid cash',
    previewLabel: 'Client payment · Ahmed · paid cash',
  ),
];

const bulkImportRulesRecap = [
  'Flags: d: date · cat: category (personal) · w: wallet (personal, default Pocket)',
  'Personal: positive amount = expense; + or − amount = gain',
  'Client: line starts with @; + = debt, − = payment, unsigned = debt',
  '# or // comment lines (no amount) are skipped',
];

/// Syntax help for More tab or compose screen.
class BulkImportSyntaxPanel extends StatelessWidget {
  const BulkImportSyntaxPanel({
    super.key,
    this.showPreviews = true,
    this.showFullSyntax = false,
    this.dense = false,
  });

  final bool showPreviews;
  final bool showFullSyntax;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mono = text.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: AppTheme.mutedFg,
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPreviews) ...[
          Text(
            'Examples',
            style: text.labelMedium?.copyWith(color: AppTheme.mutedFg, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: dense ? 6 : 10),
          for (final ex in bulkImportSyntaxExamples)
            Padding(
              padding: EdgeInsets.only(bottom: dense ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.line, style: mono),
                  const SizedBox(height: 2),
                  Text(
                    '→ ${ex.previewLabel}',
                    style: text.bodySmall?.copyWith(color: AppTheme.mutedFg),
                  ),
                ],
              ),
            ),
          SizedBox(height: dense ? 4 : 8),
        ],
        Text(
          'Rules',
          style: text.labelMedium?.copyWith(color: AppTheme.mutedFg, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: dense ? 4 : 6),
        for (final rule in bulkImportRulesRecap)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $rule',
              style: text.bodySmall?.copyWith(color: AppTheme.mutedFg, height: 1.35),
            ),
          ),
        if (showFullSyntax) ...[
          const SizedBox(height: 12),
          Text(
            'Full syntax',
            style: text.labelMedium?.copyWith(color: AppTheme.mutedFg, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SelectableText(
            bulkImportComposeHint.trim(),
            style: mono,
          ),
        ],
      ],
    );
  }
}
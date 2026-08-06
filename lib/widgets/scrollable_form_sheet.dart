import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom-sheet layout with a scrollable body and a sticky primary action button.
class ScrollableFormSheet extends StatelessWidget {
  const ScrollableFormSheet({
    super.key,
    required this.title,
    required this.onClose,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.primaryColor,
    this.toolbar,
    this.secondary,
  });

  final String title;
  final VoidCallback onClose;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryEnabled;
  final Color? primaryColor;
  final Widget? toolbar;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    color: AppTheme.mutedFg,
                  ),
                ],
              ),
            ),
            if (toolbar != null) Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: toolbar!,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (secondary != null) ...[
                    secondary!,
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: primaryEnabled ? onPrimary : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor ?? AppTheme.brandPrimary,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(primaryLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet using [ScrollableFormSheet].
Future<T?> showScrollableFormSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: builder,
  );
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HudEmptyState extends StatelessWidget {
  const HudEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.accentColor,
  });

  final String message;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.brandPrimary;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.06),
                border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
                boxShadow: AppTheme.cardGlow(accent, intensity: 0.08),
              ),
              child: Icon(icon, size: 38, color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.appFg),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedFg),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: action, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HudStatCard extends StatefulWidget {
  const HudStatCard({
    super.key,
    required this.label,
    required this.displayText,
    required this.numericValue,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String displayText;
  final double numericValue;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<HudStatCard> createState() => _HudStatCardState();
}

class _HudStatCardState extends State<HudStatCard>
    with TickerProviderStateMixin {
  late AnimationController _countCtrl;
  late Animation<double> _count;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _countCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _count = Tween<double>(begin: 0, end: widget.numericValue).animate(
      CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _countCtrl.forward();
  }

  @override
  void didUpdateWidget(HudStatCard old) {
    super.didUpdateWidget(old);
    if (old.numericValue != widget.numericValue) {
      _count = Tween<double>(begin: _count.value, end: widget.numericValue).animate(
        CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut),
      );
      _countCtrl.forward(from: 0);
      _pulseCtrl.forward(from: 0).then((_) => _pulseCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _animatedDisplay() => widget.displayText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_count, _pulseAnim]),
        builder: (_, __) {
          final glowIntensity = 0.10 + (_pulseAnim.value - 1.0) * 0.12;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: widget.color.withValues(alpha: 0.32)),
              boxShadow: AppTheme.cardGlow(widget.color, intensity: glowIntensity),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 16, color: widget.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.mutedFg,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _animatedDisplay(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

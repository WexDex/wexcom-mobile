import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared shimmer base color
// ─────────────────────────────────────────────────────────────────────────────

Widget _shimmerBlock({double? width, double? height, double radius = 8}) {
  return Shimmer.fromColors(
    baseColor: AppTheme.surface,
    highlightColor: AppTheme.inputFill,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Client list skeleton
// ─────────────────────────────────────────────────────────────────────────────

class ClientListSkeleton extends StatelessWidget {
  const ClientListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const _ClientRowSkeleton(),
    );
  }
}

class _ClientRowSkeleton extends StatelessWidget {
  const _ClientRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.mutedFg.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _shimmerBlock(width: 44, height: 44, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBlock(width: 120, height: 14),
                const SizedBox(height: 6),
                _shimmerBlock(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _shimmerBlock(width: 72, height: 14),
              const SizedBox(height: 6),
              _shimmerBlock(width: 48, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart skeleton
// ─────────────────────────────────────────────────────────────────────────────

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key, this.height = 230});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBlock(width: 160, height: 16),
        const SizedBox(height: 6),
        _shimmerBlock(width: 100, height: 12),
        const SizedBox(height: 10),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.15)),
          ),
          child: Shimmer.fromColors(
            baseColor: AppTheme.surface,
            highlightColor: AppTheme.inputFill,
            child: CustomPaint(
              painter: _HudGridSkeletonPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _HudGridSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.hudGridFaint
      ..strokeWidth = 0.5;
    for (var i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card skeleton (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────────

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => const _StatCardSkeleton()),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.inputFill,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _shimmerBlock(width: 18, height: 18, radius: 4),
                const SizedBox(width: 8),
                _shimmerBlock(width: 60, height: 12),
              ],
            ),
            _shimmerBlock(width: 80, height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction list skeleton
// ─────────────────────────────────────────────────────────────────────────────

class TransactionListSkeleton extends StatelessWidget {
  const TransactionListSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, __) => const _TransactionRowSkeleton(),
    );
  }
}

class _TransactionRowSkeleton extends StatelessWidget {
  const _TransactionRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          _shimmerBlock(width: 36, height: 36, radius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBlock(width: 100, height: 13),
                const SizedBox(height: 5),
                _shimmerBlock(width: 64, height: 11),
              ],
            ),
          ),
          _shimmerBlock(width: 64, height: 16),
        ],
      ),
    );
  }
}

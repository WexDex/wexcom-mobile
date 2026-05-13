import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import 'dashboard_analytics.dart';
import 'dashboard_charts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared glow bar helpers
// ─────────────────────────────────────────────────────────────────────────────

void _drawHudGridLocal(Canvas canvas, Size size, {int hLines = 4}) {
  final paint = Paint()
    ..color = AppTheme.hudGridFaint
    ..strokeWidth = 0.5;
  for (var i = 1; i <= hLines; i++) {
    final y = size.height * (i / (hLines + 1));
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

void _drawGlowBar(Canvas canvas, Rect rect, Color color, {double progress = 1.0}) {
  final clipped = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * progress);
  // Outer aura
  canvas.drawRect(
    clipped,
    Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, AppTheme.glowSigmaOuter * 0.6),
  );
  // Inner glow fill
  canvas.drawRect(
    clipped,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.55)],
      ).createShader(clipped),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Clients Horizontal Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class TopClientsBarChart extends StatefulWidget {
  const TopClientsBarChart({
    super.key,
    required this.points,
    required this.currencyCode,
  });

  final List<TopClientBalancePoint> points;
  final String currencyCode;

  @override
  State<TopClientsBarChart> createState() => _TopClientsBarChartState();
}

class _TopClientsBarChartState extends State<TopClientsBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(TopClientsBarChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (widget.points.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxVal = widget.points.fold<int>(0, (m, p) => math.max(m, p.balanceMinor.abs()));
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Column(
          children: [
            for (final p in widget.points) ...[
              Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.mutedFg.withValues(alpha: 0.15),
                      child: Text(
                        p.initials,
                        style: text.labelSmall?.copyWith(
                          color: AppTheme.brandPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        LayoutBuilder(builder: (context, constraints) {
                          final frac = maxVal > 0 ? p.balanceMinor.abs() / maxVal : 0.0;
                          final barW = constraints.maxWidth * frac * _anim.value;
                          final barColor =
                              p.balanceMinor < 0 ? AppTheme.ledgerDebt : AppTheme.balanceReceivable;
                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.hudGridFaint,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Container(
                                height: 6,
                                width: barW,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: barColor.withValues(alpha: 0.45),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    MoneyFormat.formatMinor(p.balanceMinor.abs(), widget.currencyCode),
                    style: text.labelSmall?.copyWith(
                      color: p.balanceMinor < 0 ? AppTheme.ledgerDebt : AppTheme.balanceReceivable,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly Net Flow Vertical Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _VerticalBarPainter extends CustomPainter {
  _VerticalBarPainter({
    required this.points,
    required this.progress,
    required this.hoverIndex,
  });

  final List<MonthlyNetFlowPoint> points;
  final double progress;
  final int? hoverIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxAbs = points.fold<int>(
      0,
      (m, p) => math.max(m, math.max(p.debtMinor, p.paymentMinor)),
    );
    if (maxAbs == 0) return;

    final halfH = size.height / 2;
    final baseline = halfH;

    _drawHudGridLocal(canvas, size, hLines: 4);

    // Draw baseline
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()
        ..color = AppTheme.hudGrid
        ..strokeWidth = 1,
    );

    final n = points.length;
    final slotW = size.width / n;
    final barW = slotW * 0.35;

    for (var i = 0; i < n; i++) {
      final p = points[i];
      final cx = slotW * i + slotW / 2;
      final isHover = hoverIndex == i;

      // Debt bar (goes down from baseline)
      if (p.debtMinor > 0) {
        final barH = (p.debtMinor / maxAbs) * halfH * 0.85 * progress;
        final rect = Rect.fromLTWH(cx - barW - 1, baseline, barW, barH);
        _drawGlowBar(canvas, rect, AppTheme.ledgerDebt);
        if (isHover) {
          canvas.drawRect(
            rect,
            Paint()..color = Colors.white.withValues(alpha: 0.12),
          );
        }
      }

      // Payment bar (goes up from baseline)
      if (p.paymentMinor > 0) {
        final barH = (p.paymentMinor / maxAbs) * halfH * 0.85 * progress;
        final rect = Rect.fromLTWH(cx + 1, baseline - barH, barW, barH);
        _drawGlowBar(canvas, rect, AppTheme.ledgerPayment);
        if (isHover) {
          canvas.drawRect(
            rect,
            Paint()..color = Colors.white.withValues(alpha: 0.12),
          );
        }
      }

      // Month label tick
      final tp = TextPainter(
        text: TextSpan(
          text: p.monthLabel,
          style: TextStyle(
            color: isHover ? AppTheme.brandPrimary : AppTheme.mutedFg,
            fontSize: 9,
            fontWeight: isHover ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(_VerticalBarPainter old) =>
      old.progress != progress || old.hoverIndex != hoverIndex || old.points != points;
}

class MonthlyNetFlowChart extends StatefulWidget {
  const MonthlyNetFlowChart({
    super.key,
    required this.points,
    required this.currencyCode,
  });

  final List<MonthlyNetFlowPoint> points;
  final String currencyCode;

  @override
  State<MonthlyNetFlowChart> createState() => _MonthlyNetFlowChartState();
}

class _MonthlyNetFlowChartState extends State<MonthlyNetFlowChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(MonthlyNetFlowChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveChartShell(
      pointCount: widget.points.length,
      chartHeight: 160,
      buildChart: (hoverIdx) => AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => CustomPaint(
          painter: _VerticalBarPainter(
            points: widget.points,
            progress: _anim.value,
            hoverIndex: hoverIdx,
          ),
          size: const Size(double.infinity, 160),
        ),
      ),
      detailBuilder: (i) {
        final p = widget.points[i];
        final net = MoneyFormat.formatMinor(p.netMinor.abs(), widget.currencyCode);
        final sign = p.netMinor >= 0 ? '+' : '−';
        return '${p.monthLabel} ${p.year}\n'
            'Debt: ${MoneyFormat.formatMinor(p.debtMinor, widget.currencyCode)}\n'
            'Payments: ${MoneyFormat.formatMinor(p.paymentMinor, widget.currencyCode)}\n'
            'Net: $sign$net';
      },
      footer: Row(
        children: [
          _LegendDot(color: AppTheme.ledgerDebt, label: 'Debt'),
          const SizedBox(width: 12),
          _LegendDot(color: AppTheme.ledgerPayment, label: 'Payments'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Heatmap (day of week)
// ─────────────────────────────────────────────────────────────────────────────

class PaymentHeatmapChart extends StatefulWidget {
  const PaymentHeatmapChart({super.key, required this.cells});

  final List<PaymentHeatmapCell> cells;

  @override
  State<PaymentHeatmapChart> createState() => _PaymentHeatmapChartState();
}

class _PaymentHeatmapChartState extends State<PaymentHeatmapChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(PaymentHeatmapChart old) {
    super.didUpdateWidget(old);
    if (old.cells != widget.cells) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxCount = widget.cells.fold<int>(0, (m, c) => math.max(m, c.count));
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.cells.map((cell) {
            final intensity = maxCount > 0 ? cell.count / maxCount : 0.0;
            final color = Color.lerp(
              AppTheme.brandPrimary.withValues(alpha: 0.1),
              AppTheme.ledgerPayment,
              intensity,
            )!;
            final barH = 60.0 * intensity * _anim.value + 12.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cell.count > 0)
                      Text(
                        '${cell.count}',
                        style: text.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Container(
                      height: barH,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: intensity > 0.5
                            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cell.dayLabel,
                      style: text.labelSmall?.copyWith(
                        color: AppTheme.mutedFg,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Debt Age Stacked Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class DebtAgeChart extends StatefulWidget {
  const DebtAgeChart({super.key, required this.bucket});

  final DebtAgeBucket bucket;

  @override
  State<DebtAgeChart> createState() => _DebtAgeChartState();
}

class _DebtAgeChartState extends State<DebtAgeChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _labels = ['0–7 days', '7–30 days', '30–90 days', '90+ days'];
  static const _colors = [
    Color(0xFF22D3EE), // fresh – brand cyan
    Color(0xFFF59E0B), // warning – amber
    Color(0xFFF97316), // orange
    Color(0xFFEF4444), // red
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(DebtAgeChart old) {
    super.didUpdateWidget(old);
    if (old.bucket != widget.bucket) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final b = widget.bucket;
    final counts = [b.d0to7, b.d7to30, b.d30to90, b.d90plus];
    final total = b.total;

    if (total == 0) {
      return Center(
        child: Text('No open debts', style: TextStyle(color: AppTheme.mutedFg, fontSize: 13)),
      );
    }

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Column(
          children: [
            // Stacked horizontal bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (counts[i] > 0)
                      Flexible(
                        flex: (counts[i] * 1000).round(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 20,
                          decoration: BoxDecoration(
                            color: _colors[i].withValues(alpha: _anim.value),
                            boxShadow: [
                              BoxShadow(
                                color: _colors[i].withValues(alpha: 0.4 * _anim.value),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Legend rows
            for (var i = 0; i < 4; i++)
              if (counts[i] > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[i],
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: _colors[i].withValues(alpha: 0.5), blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_labels[i], style: text.bodySmall?.copyWith(color: AppTheme.mutedFg)),
                      ),
                      Text(
                        '${counts[i]} debt${counts[i] == 1 ? '' : 's'} '
                        '(${(counts[i] / total * 100).round()}%)',
                        style: text.bodySmall?.copyWith(
                          color: _colors[i],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend dot (reused from dashboard_charts pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6, spreadRadius: 1)],
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppTheme.mutedFg, fontSize: 12)),
      ],
    );
  }
}

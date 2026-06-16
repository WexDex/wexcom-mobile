import 'package:flutter/material.dart';

import '../data/db/app_database.dart';
import '../theme/app_theme.dart';
import '../utils/chart_curve.dart';
import '../utils/exchange_rate.dart';

/// Compact line chart of exchange rate history (oldest → newest).
class RateHistoryChart extends StatelessWidget {
  const RateHistoryChart({
    super.key,
    required this.rows,
    this.height = 120,
  });

  final List<ExchangeRateHistoryData> rows;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (rows.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Need at least 2 rate entries to chart',
            style: TextStyle(color: AppTheme.mutedFg, fontSize: 12),
          ),
        ),
      );
    }

    final sorted = [...rows]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final rates = sorted
        .map((r) => rateFromStored(r.rateToDefault, r.rateScale).toDouble())
        .toList();

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _RateChartPainter(rates: rates),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RateChartPainter extends CustomPainter {
  _RateChartPainter({required this.rates});

  final List<double> rates;

  @override
  void paint(Canvas canvas, Size size) {
    if (rates.length < 2) return;

    var minY = rates.first;
    var maxY = rates.first;
    for (final r in rates) {
      if (r < minY) minY = r;
      if (r > maxY) maxY = r;
    }
    final span = (maxY - minY).clamp(0.0001, double.infinity);

    final pts = <Offset>[];
    for (var i = 0; i < rates.length; i++) {
      final x = rates.length == 1 ? 0.0 : i / (rates.length - 1) * size.width;
      final norm = (rates[i] - minY) / span;
      final y = size.height * (1 - norm * 0.85) - size.height * 0.05;
      pts.add(Offset(x, y));
    }

    final grid = Paint()
      ..color = AppTheme.hudGridFaint
      ..strokeWidth = 0.5;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = buildSeriesPath(pts, currentChartCurveStyle);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.brandPrimary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final dot = Paint()..color = AppTheme.brandPrimary;
    canvas.drawCircle(pts.last, 3, dot);
  }

  @override
  bool shouldRepaint(covariant _RateChartPainter oldDelegate) =>
      oldDelegate.rates != rates;
}

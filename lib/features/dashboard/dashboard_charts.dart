import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Date helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Inclusive calendar days from [start] through [end] (date-only), oldest first.
List<DateTime> calendarDaysInRange(DateTime start, DateTime end) {
  final a = DateTime(start.year, start.month, start.day);
  final b = DateTime(end.year, end.month, end.day);
  if (a.isAfter(b)) return [];
  final out = <DateTime>[];
  for (var d = a; !d.isAfter(b); d = d.add(const Duration(days: 1))) {
    out.add(d);
  }
  return out;
}

/// Last [dayCount] calendar days ending at [endDay] (inclusive), oldest first.
List<DateTime> recentCalendarDaysEnding(DateTime endDay, int dayCount) {
  final end = DateTime(endDay.year, endDay.month, endDay.day);
  final n = dayCount < 1 ? 1 : dayCount;
  return List<DateTime>.generate(
    n,
    (i) => end.subtract(Duration(days: n - 1 - i)),
  );
}

List<DateTime> recentCalendarDays(int dayCount) {
  final now = DateTime.now();
  return recentCalendarDaysEnding(
    DateTime(now.year, now.month, now.day),
    dayCount,
  );
}

String shortDayLabel(DateTime day, int rangeLength) {
  if (rangeLength <= 14) {
    return DateFormat.E().format(day.toLocal());
  }
  return '${day.month}/${day.day}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class LedgerDailyPoint {
  const LedgerDailyPoint({
    required this.label,
    required this.day,
    required this.debt,
    required this.payment,
    required this.debtCount,
    required this.paymentCount,
  });

  final String label;
  final DateTime day;
  final int debt;
  final int payment;
  final int debtCount;
  final int paymentCount;

  int get net => debt - payment;
}

List<LedgerDailyPoint> buildLedgerDailyPoints(
  List<LedgerTransactionWithClient> rows,
  int dayCount,
) {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(Duration(days: dayCount - 1));
  return buildLedgerDailyPointsForRange(rows, start, end);
}

List<LedgerDailyPoint> buildLedgerDailyPointsForRange(
  List<LedgerTransactionWithClient> rows,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final days = calendarDaysInRange(rangeStart, rangeEnd);
  if (days.isEmpty) return [];
  final n = days.length;
  final debtByDay = {for (final d in days) d: 0};
  final payByDay = {for (final d in days) d: 0};
  final debtCountByDay = {for (final d in days) d: 0};
  final payCountByDay = {for (final d in days) d: 0};

  for (final row in rows) {
    final tx = row.transaction;
    if (LedgerTxStatus.fromInt(tx.txStatus) != LedgerTxStatus.active) continue;
    final date = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
    if (!debtByDay.containsKey(date)) continue;
    if (LedgerTxType.fromInt(tx.txType) == LedgerTxType.debt) {
      debtByDay[date] = (debtByDay[date] ?? 0) + tx.amountMinor;
      debtCountByDay[date] = (debtCountByDay[date] ?? 0) + 1;
    } else {
      payByDay[date] = (payByDay[date] ?? 0) + tx.amountMinor;
      payCountByDay[date] = (payCountByDay[date] ?? 0) + 1;
    }
  }

  return days
      .map(
        (d) => LedgerDailyPoint(
          label: shortDayLabel(d, n),
          day: d,
          debt: debtByDay[d] ?? 0,
          payment: payByDay[d] ?? 0,
          debtCount: debtCountByDay[d] ?? 0,
          paymentCount: payCountByDay[d] ?? 0,
        ),
      )
      .toList();
}

/// End-of-day totals from replayed client balances (sign: negative ⇒ they owe you).
class CurrentBalancePoint {
  const CurrentBalancePoint({
    required this.label,
    required this.day,
    required this.theyOweYouMinor,
    required this.youOweThemMinor,
  });

  final String label;
  final DateTime day;
  final int theyOweYouMinor;
  final int youOweThemMinor;
}

List<CurrentBalancePoint> buildCurrentBalancePointsForRange(
  List<LedgerTransactionWithClient> allRows,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final days = calendarDaysInRange(rangeStart, rangeEnd);
  if (days.isEmpty) return [];

  final sorted = allRows
      .where((r) => LedgerTxStatus.fromInt(r.transaction.txStatus) == LedgerTxStatus.active)
      .map((r) => r.transaction)
      .toList()
    ..sort((a, b) {
      final c = a.createdAt.compareTo(b.createdAt);
      if (c != 0) return c;
      return a.id.compareTo(b.id);
    });

  var txIndex = 0;
  final bal = <String, int>{};

  return days.map((d) {
    while (txIndex < sorted.length) {
      final tx = sorted[txIndex];
      final txDay = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      if (txDay.isAfter(d)) break;
      final cid = tx.clientId;
      final cur = bal[cid] ?? 0;
      bal[cid] = LedgerMath.apply(
        cur,
        LedgerTxType.fromInt(tx.txType),
        tx.amountMinor,
      );
      txIndex++;
    }
    var theyOwe = 0;
    var youOwe = 0;
    for (final v in bal.values) {
      if (v < 0) {
        theyOwe += -v;
      } else if (v > 0) {
        youOwe += v;
      }
    }
    return CurrentBalancePoint(
      label: shortDayLabel(d, days.length),
      day: d,
      theyOweYouMinor: theyOwe,
      youOweThemMinor: youOwe,
    );
  }).toList();
}

class CumulativeLedgerPoint {
  const CumulativeLedgerPoint({
    required this.label,
    required this.day,
    required this.cumDebt,
    required this.cumPayment,
  });

  final String label;
  final DateTime day;
  final int cumDebt;
  final int cumPayment;

  int get net => cumDebt - cumPayment;
}

List<CumulativeLedgerPoint> toCumulativeLedger(List<LedgerDailyPoint> daily) {
  var cd = 0;
  var cp = 0;
  return daily
      .map((p) {
        cd += p.debt;
        cp += p.payment;
        return CumulativeLedgerPoint(
          label: p.label,
          day: p.day,
          cumDebt: cd,
          cumPayment: cp,
        );
      })
      .toList();
}

class PersonalDailyPoint {
  const PersonalDailyPoint({
    required this.label,
    required this.day,
    required this.amount,
    required this.entryCount,
  });

  final String label;
  final DateTime day;
  final int amount;
  final int entryCount;
}

List<PersonalDailyPoint> buildPersonalDailyPoints(
  List<PersonalFinanceEntry> entries,
  int dayCount,
) {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(Duration(days: dayCount - 1));
  return buildPersonalDailyPointsForRange(entries, start, end);
}

List<PersonalDailyPoint> buildPersonalDailyPointsForRange(
  List<PersonalFinanceEntry> entries,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final days = calendarDaysInRange(rangeStart, rangeEnd);
  if (days.isEmpty) return [];
  final n = days.length;
  final byDay = {for (final d in days) d: 0};
  final counts = {for (final d in days) d: 0};
  for (final e in entries) {
    final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    if (!byDay.containsKey(date)) continue;
    byDay[date] = (byDay[date] ?? 0) + e.amountMinor;
    counts[date] = (counts[date] ?? 0) + 1;
  }
  return days
      .map(
        (d) => PersonalDailyPoint(
          label: shortDayLabel(d, n),
          day: d,
          amount: byDay[d] ?? 0,
          entryCount: counts[d] ?? 0,
        ),
      )
      .toList();
}

class PersonalCombinedDailyPoint {
  const PersonalCombinedDailyPoint({
    required this.label,
    required this.day,
    required this.expense,
    required this.gain,
    required this.expenseCount,
    required this.gainCount,
  });

  final String label;
  final DateTime day;
  final int expense;
  final int gain;
  final int expenseCount;
  final int gainCount;

  int get net => gain - expense;
}

List<PersonalCombinedDailyPoint> buildPersonalCombinedDailyPointsForRange(
  List<PersonalFinanceEntry> expenses,
  List<PersonalFinanceEntry> gains,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final days = calendarDaysInRange(rangeStart, rangeEnd);
  if (days.isEmpty) return [];
  final n = days.length;
  final expAmt = {for (final d in days) d: 0};
  final gainAmt = {for (final d in days) d: 0};
  final expCt = {for (final d in days) d: 0};
  final gainCt = {for (final d in days) d: 0};

  for (final e in expenses) {
    final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    if (!expAmt.containsKey(date)) continue;
    expAmt[date] = (expAmt[date] ?? 0) + e.amountMinor;
    expCt[date] = (expCt[date] ?? 0) + 1;
  }
  for (final e in gains) {
    final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    if (!gainAmt.containsKey(date)) continue;
    gainAmt[date] = (gainAmt[date] ?? 0) + e.amountMinor;
    gainCt[date] = (gainCt[date] ?? 0) + 1;
  }

  return days
      .map(
        (d) => PersonalCombinedDailyPoint(
          label: shortDayLabel(d, n),
          day: d,
          expense: expAmt[d] ?? 0,
          gain: gainAmt[d] ?? 0,
          expenseCount: expCt[d] ?? 0,
          gainCount: gainCt[d] ?? 0,
        ),
      )
      .toList();
}

class LedgerPersonalDailyPoint {
  const LedgerPersonalDailyPoint({
    required this.label,
    required this.day,
    required this.debt,
    required this.payment,
    required this.expense,
    required this.gain,
  });

  final String label;
  final DateTime day;
  final int debt;
  final int payment;
  final int expense;
  final int gain;
}

List<LedgerPersonalDailyPoint> buildLedgerPersonalDailyPointsForRange(
  List<LedgerTransactionWithClient> rows,
  List<PersonalFinanceEntry> expenses,
  List<PersonalFinanceEntry> gains,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final ledger = buildLedgerDailyPointsForRange(rows, rangeStart, rangeEnd);
  final personal = buildPersonalCombinedDailyPointsForRange(expenses, gains, rangeStart, rangeEnd);
  final n = math.min(ledger.length, personal.length);
  return List.generate(
    n,
    (i) => LedgerPersonalDailyPoint(
      label: ledger[i].label,
      day: ledger[i].day,
      debt: ledger[i].debt,
      payment: ledger[i].payment,
      expense: personal[i].expense,
      gain: personal[i].gain,
    ),
  );
}

class CumulativePersonalPoint {
  const CumulativePersonalPoint({
    required this.label,
    required this.day,
    required this.cumExpense,
    required this.cumGain,
  });

  final String label;
  final DateTime day;
  final int cumExpense;
  final int cumGain;

  int get net => cumGain - cumExpense;
}

List<CumulativePersonalPoint> toCumulativePersonal(List<PersonalCombinedDailyPoint> daily) {
  var ce = 0;
  var cg = 0;
  return daily
      .map((p) {
        ce += p.expense;
        cg += p.gain;
        return CumulativePersonalPoint(
          label: p.label,
          day: p.day,
          cumExpense: ce,
          cumGain: cg,
        );
      })
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow HUD drawing helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Clips a polyline to the first [progress] fraction of its length.
List<Offset> _clipProgressPts(List<Offset> pts, double progress) {
  if (pts.length < 2 || progress >= 1.0) return pts;
  if (progress <= 0.0) return [];
  final total = pts.length - 1;
  final show = progress * total;
  final full = show.floor().clamp(0, total - 1);
  final frac = show - full;
  final clipped = List<Offset>.of(pts.sublist(0, full + 1));
  if (frac > 0) {
    clipped.add(Offset.lerp(pts[full], pts[full + 1], frac)!);
  }
  return clipped;
}

/// HUD scan-line grid — faint horizontal lines + optional vertical markers.
void _drawHudGrid(Canvas canvas, Size size, {int hLines = 4, int vLines = 0}) {
  final hPaint = Paint()
    ..color = AppTheme.hudGridFaint
    ..strokeWidth = 0.5;
  for (var i = 1; i <= hLines; i++) {
    final y = size.height * (i / (hLines + 1));
    canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
  }
  if (vLines > 0) {
    final vPaint = Paint()
      ..color = AppTheme.hudGrid.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    for (var i = 1; i < vLines; i++) {
      final x = size.width * (i / vLines);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vPaint);
    }
  }
}

/// Gradient fill under a polyline. Draw BEFORE the glow line.
void _drawGradientFill(Canvas canvas, Size size, List<Offset> pts, Color color) {
  if (pts.length < 2) return;
  final fillPath = Path()..moveTo(pts[0].dx, size.height);
  for (final p in pts) {
    fillPath.lineTo(p.dx, p.dy);
  }
  fillPath
    ..lineTo(pts.last.dx, size.height)
    ..close();
  final gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
  );
  canvas.drawPath(
    fillPath,
    Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill,
  );
}

/// Three-pass neon glow polyline: outer aura → inner glow → crisp core.
void _drawGlowPolyline(
  Canvas canvas,
  List<Offset> pts,
  Color color, {
  double progress = 1.0,
}) {
  if (pts.length < 2) return;
  final clipped = _clipProgressPts(pts, progress);
  if (clipped.length < 2) return;

  final path = Path()..moveTo(clipped[0].dx, clipped[0].dy);
  for (var i = 1; i < clipped.length; i++) {
    path.lineTo(clipped[i].dx, clipped[i].dy);
  }

  // Pass 1: outer aura
  canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = AppTheme.glowStrokeOuter
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, AppTheme.glowSigmaOuter)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  // Pass 2: inner solid glow
  canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, AppTheme.glowSigmaInner)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  // Pass 3: crisp core line
  canvas.drawPath(
    path,
    Paint()
      ..color = color
      ..strokeWidth = AppTheme.glowStrokeCore
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

/// Three-layer glowing dot at a chart data point.
void _drawGlowDot(Canvas canvas, Offset center, Color color, {bool highlight = false}) {
  final r = highlight ? 5.0 : 3.0;
  canvas.drawCircle(
    center,
    r * 3,
    Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 8),
  );
  canvas.drawCircle(
    center,
    r * 1.8,
    Paint()
      ..color = color.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 4),
  );
  canvas.drawCircle(center, r, Paint()..color = color);
  if (highlight) {
    canvas.drawCircle(center, r * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.8));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChartCard
// ─────────────────────────────────────────────────────────────────────────────

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.brandPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(color: AppTheme.mutedFg, fontSize: 13)),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
            boxShadow: AppTheme.cardGlow(accent, intensity: 0.12),
          ),
          child: child,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive shell
// ─────────────────────────────────────────────────────────────────────────────

int? chartIndexAtDx(double localX, double width, int count) {
  if (count <= 0) return null;
  if (count == 1) return 0;
  final t = (localX / width).clamp(0.0, 1.0);
  return (t * (count - 1)).round().clamp(0, count - 1);
}

class InteractiveChartShell extends StatefulWidget {
  const InteractiveChartShell({
    super.key,
    required this.pointCount,
    required this.chartHeight,
    required this.buildChart,
    required this.detailBuilder,
    this.footer,
  });

  final int pointCount;
  final double chartHeight;
  final Widget Function(int? hoverIndex) buildChart;
  final String Function(int index) detailBuilder;
  final Widget? footer;

  @override
  State<InteractiveChartShell> createState() => _InteractiveChartShellState();
}

class _InteractiveChartShellState extends State<InteractiveChartShell> {
  int? _index;
  Offset? _pointer;

  void _update(double dx, double dy, double w) {
    if (widget.pointCount <= 0) return;
    final idx = chartIndexAtDx(dx, w, widget.pointCount);
    setState(() {
      _index = idx;
      _pointer = Offset(dx, dy);
    });
  }

  void _clear() {
    if (_index != null || _pointer != null) {
      setState(() {
        _index = null;
        _pointer = null;
      });
    }
  }

  static const double _tooltipEstW = 248;
  static const double _tooltipEstH = 96;

  double _tooltipLeft(double px, double chartW) {
    return (px + 12).clamp(4, (chartW - _tooltipEstW - 4).clamp(4, double.infinity));
  }

  double _tooltipTop(double py, double chartH) {
    final above = py - _tooltipEstH - 10;
    if (above >= 4) return above;
    return (py + 16).clamp(4, (chartH - _tooltipEstH - 4).clamp(4, double.infinity));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.chartHeight,
          child: LayoutBuilder(
            builder: (context, c) {
              final showFloat =
                  _index != null && _pointer != null && widget.pointCount > 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: MouseRegion(
                      onExit: (_) => _clear(),
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerHover: (e) =>
                            _update(e.localPosition.dx, e.localPosition.dy, c.maxWidth),
                        onPointerDown: (e) =>
                            _update(e.localPosition.dx, e.localPosition.dy, c.maxWidth),
                        onPointerMove: (e) =>
                            _update(e.localPosition.dx, e.localPosition.dy, c.maxWidth),
                        child: widget.buildChart(_index),
                      ),
                    ),
                  ),
                  if (showFloat)
                    Positioned(
                      left: _tooltipLeft(_pointer!.dx, c.maxWidth),
                      top: _tooltipTop(_pointer!.dy, c.maxHeight),
                      child: IgnorePointer(
                        child: Material(
                          elevation: 8,
                          shadowColor: Colors.black54,
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: (c.maxWidth - 8).clamp(120, 320)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.brandPrimary.withValues(alpha: 0.45),
                              ),
                              boxShadow: AppTheme.cardGlow(AppTheme.brandPrimary, intensity: 0.1),
                            ),
                            child: Text(
                              widget.detailBuilder(_index!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.appFg,
                                height: 1.38,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (_index == null || _pointer == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Hover, tap, or drag on the chart for details',
              style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.mutedFg),
            ),
          ),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart widgets
// ─────────────────────────────────────────────────────────────────────────────

class DualAmountLineChart extends StatefulWidget {
  const DualAmountLineChart({
    super.key,
    required this.points,
    required this.colorA,
    required this.colorB,
    required this.legendA,
    required this.legendB,
    this.interactiveCurrencyCode,
    this.interactiveDetailLine,
  });

  final List<LedgerDailyPoint> points;
  final Color colorA;
  final Color colorB;
  final String legendA;
  final String legendB;
  final String? interactiveCurrencyCode;
  final String Function(int i, String code)? interactiveDetailLine;

  @override
  State<DualAmountLineChart> createState() => _DualAmountLineChartState();
}

class _DualAmountLineChartState extends State<DualAmountLineChart>
    with SingleTickerProviderStateMixin {
  bool _showA = true;
  bool _showB = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(DualAmountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _entry.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showA) m = math.max(m, p.debt);
      if (_showB) m = math.max(m, p.payment);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    final code = widget.interactiveCurrencyCode ?? '';

    final filters = _SeriesFilterChips(
      labelA: widget.legendA,
      labelB: widget.legendB,
      colorA: widget.colorA,
      colorB: widget.colorB,
      showA: _showA,
      showB: _showB,
      onAChanged: (v) => setState(() {
        _showA = v;
        if (!_showA && !_showB) _showB = true;
      }),
      onBChanged: (v) => setState(() {
        _showB = v;
        if (!_showA && !_showB) _showA = true;
      }),
    );

    if (widget.interactiveDetailLine != null && code.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filters,
          InteractiveChartShell(
            pointCount: widget.points.length,
            chartHeight: 210,
            detailBuilder: (i) => widget.interactiveDetailLine!(i, code),
            footer: _footerLegend(
              context,
              widget.legendA,
              widget.legendB,
              widget.colorA,
              widget.colorB,
              widget.points,
              showLegendDots: false,
            ),
            buildChart: (hover) => AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => CustomPaint(
                painter: _DualAmountPainter<LedgerDailyPoint>(
                  points: widget.points,
                  maxY: maxY,
                  valueA: (p) => p.debt,
                  valueB: (p) => p.payment,
                  colorA: widget.colorA,
                  colorB: widget.colorB,
                  showA: _showA,
                  showB: _showB,
                  highlightIndex: hover,
                  progress: _progress.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filters,
        SizedBox(
          height: 210,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualAmountPainter<LedgerDailyPoint>(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.debt,
                valueB: (p) => p.payment,
                colorA: widget.colorA,
                colorB: widget.colorB,
                showA: _showA,
                showB: _showB,
                highlightIndex: null,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _xLabels(context, widget.points.map((p) => p.label).toList()),
      ],
    );
  }
}

class CurrentBalanceLineChart extends StatefulWidget {
  const CurrentBalanceLineChart({
    super.key,
    required this.points,
    required this.interactiveCurrencyCode,
    required this.detailBuilder,
  });

  final List<CurrentBalancePoint> points;
  final String interactiveCurrencyCode;
  final String Function(int i, String code) detailBuilder;

  @override
  State<CurrentBalanceLineChart> createState() => _CurrentBalanceLineChartState();
}

class _CurrentBalanceLineChartState extends State<CurrentBalanceLineChart>
    with SingleTickerProviderStateMixin {
  bool _showTheyOwe = true;
  bool _showYouOwe = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(CurrentBalanceLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showTheyOwe) m = math.max(m, p.theyOweYouMinor);
      if (_showYouOwe) m = math.max(m, p.youOweThemMinor);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeriesFilterChips(
          labelA: 'They owe you',
          labelB: 'You owe them',
          colorA: AppTheme.balanceReceivable,
          colorB: AppTheme.ledgerDebt,
          showA: _showTheyOwe,
          showB: _showYouOwe,
          onAChanged: (v) => setState(() {
            _showTheyOwe = v;
            if (!_showTheyOwe && !_showYouOwe) _showYouOwe = true;
          }),
          onBChanged: (v) => setState(() {
            _showYouOwe = v;
            if (!_showTheyOwe && !_showYouOwe) _showTheyOwe = true;
          }),
        ),
        InteractiveChartShell(
          pointCount: widget.points.length,
          chartHeight: 210,
          detailBuilder: (i) => widget.detailBuilder(i, widget.interactiveCurrencyCode),
          footer: _footerLegend(
            context,
            'They owe you',
            'You owe them',
            AppTheme.balanceReceivable,
            AppTheme.ledgerDebt,
            widget.points,
            showLegendDots: false,
          ),
          buildChart: (hover) => AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualAmountPainter<CurrentBalancePoint>(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.theyOweYouMinor,
                valueB: (p) => p.youOweThemMinor,
                colorA: AppTheme.balanceReceivable,
                colorB: AppTheme.ledgerDebt,
                showA: _showTheyOwe,
                showB: _showYouOwe,
                highlightIndex: hover,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class CumulativeAmountLineChart extends StatefulWidget {
  const CumulativeAmountLineChart({
    super.key,
    required this.points,
    required this.colorA,
    required this.colorB,
    required this.legendA,
    required this.legendB,
    this.interactiveCurrencyCode,
    this.interactiveDetailLine,
  });

  final List<CumulativeLedgerPoint> points;
  final Color colorA;
  final Color colorB;
  final String legendA;
  final String legendB;
  final String? interactiveCurrencyCode;
  final String Function(int i, String code)? interactiveDetailLine;

  @override
  State<CumulativeAmountLineChart> createState() => _CumulativeAmountLineChartState();
}

class _CumulativeAmountLineChartState extends State<CumulativeAmountLineChart>
    with SingleTickerProviderStateMixin {
  bool _showA = true;
  bool _showB = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(CumulativeAmountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showA) m = math.max(m, p.cumDebt);
      if (_showB) m = math.max(m, p.cumPayment);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    final code = widget.interactiveCurrencyCode ?? '';

    final filters = _SeriesFilterChips(
      labelA: widget.legendA,
      labelB: widget.legendB,
      colorA: widget.colorA,
      colorB: widget.colorB,
      showA: _showA,
      showB: _showB,
      onAChanged: (v) => setState(() {
        _showA = v;
        if (!_showA && !_showB) _showB = true;
      }),
      onBChanged: (v) => setState(() {
        _showB = v;
        if (!_showA && !_showB) _showA = true;
      }),
    );

    if (widget.interactiveDetailLine != null && code.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filters,
          InteractiveChartShell(
            pointCount: widget.points.length,
            chartHeight: 210,
            detailBuilder: (i) => widget.interactiveDetailLine!(i, code),
            footer: _footerLegend(
              context,
              widget.legendA,
              widget.legendB,
              widget.colorA,
              widget.colorB,
              widget.points,
              showLegendDots: false,
            ),
            buildChart: (hover) => AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => CustomPaint(
                painter: _DualAmountPainter<CumulativeLedgerPoint>(
                  points: widget.points,
                  maxY: maxY,
                  valueA: (p) => p.cumDebt,
                  valueB: (p) => p.cumPayment,
                  colorA: widget.colorA,
                  colorB: widget.colorB,
                  showA: _showA,
                  showB: _showB,
                  highlightIndex: hover,
                  progress: _progress.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filters,
        SizedBox(
          height: 210,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualAmountPainter<CumulativeLedgerPoint>(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.cumDebt,
                valueB: (p) => p.cumPayment,
                colorA: widget.colorA,
                colorB: widget.colorB,
                showA: _showA,
                showB: _showB,
                highlightIndex: null,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _xLabels(context, widget.points.map((p) => p.label).toList()),
      ],
    );
  }
}

class NetAmountLineChart extends StatefulWidget {
  const NetAmountLineChart({
    super.key,
    required this.points,
    required this.lineColor,
    this.interactiveCurrencyCode,
    this.interactiveDetailLine,
  });

  final List<LedgerDailyPoint> points;
  final Color lineColor;
  final String? interactiveCurrencyCode;
  final String Function(int i, String code)? interactiveDetailLine;

  @override
  State<NetAmountLineChart> createState() => _NetAmountLineChartState();
}

class _NetAmountLineChartState extends State<NetAmountLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(NetAmountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawMax = widget.points.map((p) => p.net.abs()).fold<int>(1, (a, b) => b > a ? b : a);
    final maxY = rawMax;
    final code = widget.interactiveCurrencyCode ?? '';
    if (widget.interactiveDetailLine != null && code.isNotEmpty) {
      return InteractiveChartShell(
        pointCount: widget.points.length,
        chartHeight: 200,
        detailBuilder: (i) => widget.interactiveDetailLine!(i, code),
        footer: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Debt minus payments per day',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
          ),
        ),
        buildChart: (hover) => AnimatedBuilder(
          animation: _progress,
          builder: (_, __) => CustomPaint(
            painter: _SingleSeriesPainter(
              values: widget.points.map((p) => p.net.toDouble()).toList(),
              maxAbs: maxY.toDouble(),
              color: widget.lineColor,
              highlightIndex: hover,
              progress: _progress.value,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _SingleSeriesPainter(
                values: widget.points.map((p) => p.net.toDouble()).toList(),
                maxAbs: maxY.toDouble(),
                color: widget.lineColor,
                highlightIndex: null,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _xLabels(context, widget.points.map((p) => p.label).toList()),
        const SizedBox(height: 8),
        Text(
          'Debt minus payments per day',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
        ),
      ],
    );
  }
}

class CountLineChart extends StatefulWidget {
  const CountLineChart({
    super.key,
    required this.points,
    required this.colorA,
    required this.colorB,
    required this.legendA,
    required this.legendB,
    this.interactiveDetailLine,
  });

  final List<LedgerDailyPoint> points;
  final Color colorA;
  final Color colorB;
  final String legendA;
  final String legendB;
  final String Function(int i)? interactiveDetailLine;

  @override
  State<CountLineChart> createState() => _CountLineChartState();
}

class _CountLineChartState extends State<CountLineChart>
    with SingleTickerProviderStateMixin {
  bool _showA = true;
  bool _showB = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(CountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showA) m = math.max(m, p.debtCount);
      if (_showB) m = math.max(m, p.paymentCount);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();

    final filters = _SeriesFilterChips(
      labelA: widget.legendA,
      labelB: widget.legendB,
      colorA: widget.colorA,
      colorB: widget.colorB,
      showA: _showA,
      showB: _showB,
      onAChanged: (v) => setState(() {
        _showA = v;
        if (!_showA && !_showB) _showB = true;
      }),
      onBChanged: (v) => setState(() {
        _showB = v;
        if (!_showA && !_showB) _showA = true;
      }),
    );

    if (widget.interactiveDetailLine != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filters,
          InteractiveChartShell(
            pointCount: widget.points.length,
            chartHeight: 200,
            detailBuilder: widget.interactiveDetailLine!,
            footer: _footerLegend(
              context,
              widget.legendA,
              widget.legendB,
              widget.colorA,
              widget.colorB,
              widget.points,
              showLegendDots: false,
            ),
            buildChart: (hover) => AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => CustomPaint(
                painter: _DualIntPainter(
                  points: widget.points,
                  maxY: maxY,
                  valueA: (p) => p.debtCount,
                  valueB: (p) => p.paymentCount,
                  colorA: widget.colorA,
                  colorB: widget.colorB,
                  showA: _showA,
                  showB: _showB,
                  highlightIndex: hover,
                  progress: _progress.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filters,
        SizedBox(
          height: 200,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualIntPainter(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.debtCount,
                valueB: (p) => p.paymentCount,
                colorA: widget.colorA,
                colorB: widget.colorB,
                showA: _showA,
                showB: _showB,
                highlightIndex: null,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _xLabels(context, widget.points.map((p) => p.label).toList()),
      ],
    );
  }
}

class DualPersonalAmountLineChart extends StatefulWidget {
  const DualPersonalAmountLineChart({
    super.key,
    required this.points,
    required this.interactiveCurrencyCode,
    required this.detailBuilder,
  });

  final List<PersonalCombinedDailyPoint> points;
  final String interactiveCurrencyCode;
  final String Function(int i, String code) detailBuilder;

  @override
  State<DualPersonalAmountLineChart> createState() => _DualPersonalAmountLineChartState();
}

class _DualPersonalAmountLineChartState extends State<DualPersonalAmountLineChart>
    with SingleTickerProviderStateMixin {
  bool _showExpense = true;
  bool _showGain = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(DualPersonalAmountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showExpense) m = math.max(m, p.expense);
      if (_showGain) m = math.max(m, p.gain);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeriesFilterChips(
          labelA: 'Expenses',
          labelB: 'Gains',
          colorA: AppTheme.personalExpense,
          colorB: AppTheme.personalGain,
          showA: _showExpense,
          showB: _showGain,
          onAChanged: (v) => setState(() {
            _showExpense = v;
            if (!_showExpense && !_showGain) _showGain = true;
          }),
          onBChanged: (v) => setState(() {
            _showGain = v;
            if (!_showExpense && !_showGain) _showExpense = true;
          }),
        ),
        InteractiveChartShell(
          pointCount: widget.points.length,
          chartHeight: 210,
          detailBuilder: (i) => widget.detailBuilder(i, widget.interactiveCurrencyCode),
          footer: _footerLegend(
            context,
            'Expenses',
            'Gains',
            AppTheme.personalExpense,
            AppTheme.personalGain,
            widget.points,
            showLegendDots: false,
          ),
          buildChart: (hover) => AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualAmountPainter<PersonalCombinedDailyPoint>(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.expense,
                valueB: (p) => p.gain,
                colorA: AppTheme.personalExpense,
                colorB: AppTheme.personalGain,
                showA: _showExpense,
                showB: _showGain,
                highlightIndex: hover,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class CumulativePersonalLineChart extends StatefulWidget {
  const CumulativePersonalLineChart({
    super.key,
    required this.points,
    required this.interactiveCurrencyCode,
    required this.detailBuilder,
  });

  final List<CumulativePersonalPoint> points;
  final String interactiveCurrencyCode;
  final String Function(int i, String code) detailBuilder;

  @override
  State<CumulativePersonalLineChart> createState() => _CumulativePersonalLineChartState();
}

class _CumulativePersonalLineChartState extends State<CumulativePersonalLineChart>
    with SingleTickerProviderStateMixin {
  bool _showExpense = true;
  bool _showGain = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(CumulativePersonalLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showExpense) m = math.max(m, p.cumExpense);
      if (_showGain) m = math.max(m, p.cumGain);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeriesFilterChips(
          labelA: 'Cumulative expenses',
          labelB: 'Cumulative gains',
          colorA: AppTheme.personalExpense,
          colorB: AppTheme.personalGain,
          showA: _showExpense,
          showB: _showGain,
          onAChanged: (v) => setState(() {
            _showExpense = v;
            if (!_showExpense && !_showGain) _showGain = true;
          }),
          onBChanged: (v) => setState(() {
            _showGain = v;
            if (!_showExpense && !_showGain) _showExpense = true;
          }),
        ),
        InteractiveChartShell(
          pointCount: widget.points.length,
          chartHeight: 210,
          detailBuilder: (i) => widget.detailBuilder(i, widget.interactiveCurrencyCode),
          footer: _footerLegend(
            context,
            'Cumulative expenses',
            'Cumulative gains',
            AppTheme.personalExpense,
            AppTheme.personalGain,
            widget.points,
            showLegendDots: false,
          ),
          buildChart: (hover) => AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualAmountPainter<CumulativePersonalPoint>(
                points: widget.points,
                maxY: maxY,
                valueA: (p) => p.cumExpense,
                valueB: (p) => p.cumGain,
                colorA: AppTheme.personalExpense,
                colorB: AppTheme.personalGain,
                showA: _showExpense,
                showB: _showGain,
                highlightIndex: hover,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FourSeriesFilterChips extends StatelessWidget {
  const _FourSeriesFilterChips({
    required this.labelDebt,
    required this.labelPayment,
    required this.labelExpense,
    required this.labelGain,
    required this.colorDebt,
    required this.colorPayment,
    required this.colorExpense,
    required this.colorGain,
    required this.showDebt,
    required this.showPayment,
    required this.showExpense,
    required this.showGain,
    required this.onDebt,
    required this.onPayment,
    required this.onExpense,
    required this.onGain,
  });

  final String labelDebt;
  final String labelPayment;
  final String labelExpense;
  final String labelGain;
  final Color colorDebt;
  final Color colorPayment;
  final Color colorExpense;
  final Color colorGain;
  final bool showDebt;
  final bool showPayment;
  final bool showExpense;
  final bool showGain;
  final ValueChanged<bool> onDebt;
  final ValueChanged<bool> onPayment;
  final ValueChanged<bool> onExpense;
  final ValueChanged<bool> onGain;

  @override
  Widget build(BuildContext context) {
    int vis() =>
        (showDebt ? 1 : 0) + (showPayment ? 1 : 0) + (showExpense ? 1 : 0) + (showGain ? 1 : 0);

    void gate(ValueChanged<bool> fn, bool cur, bool v) {
      if (!v && cur && vis() <= 1) return;
      fn(v);
    }

    FilterChip chip(String label, Color c, bool sel, ValueChanged<bool> onSel) {
      return FilterChip(
        label: Text(label),
        selected: sel,
        onSelected: (v) => gate(onSel, sel, v),
        selectedColor: c.withValues(alpha: 0.32),
        checkmarkColor: c,
        labelStyle: TextStyle(
          color: sel ? c : AppTheme.mutedFg,
          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
        side: BorderSide(
          color: sel ? c.withValues(alpha: 0.75) : AppTheme.mutedFg.withValues(alpha: 0.35),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          chip(labelDebt, colorDebt, showDebt, onDebt),
          chip(labelPayment, colorPayment, showPayment, onPayment),
          chip(labelExpense, colorExpense, showExpense, onExpense),
          chip(labelGain, colorGain, showGain, onGain),
        ],
      ),
    );
  }
}

class CombinedLedgerPersonalLineChart extends StatefulWidget {
  const CombinedLedgerPersonalLineChart({
    super.key,
    required this.points,
    required this.interactiveCurrencyCode,
    required this.detailBuilder,
  });

  final List<LedgerPersonalDailyPoint> points;
  final String interactiveCurrencyCode;
  final String Function(int i, String code) detailBuilder;

  @override
  State<CombinedLedgerPersonalLineChart> createState() =>
      _CombinedLedgerPersonalLineChartState();
}

class _CombinedLedgerPersonalLineChartState extends State<CombinedLedgerPersonalLineChart>
    with SingleTickerProviderStateMixin {
  bool _showDebt = true;
  bool _showPayment = true;
  bool _showExpense = true;
  bool _showGain = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(CombinedLedgerPersonalLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _visibleCount() =>
      (_showDebt ? 1 : 0) + (_showPayment ? 1 : 0) + (_showExpense ? 1 : 0) + (_showGain ? 1 : 0);

  void _setDebt(bool v) => setState(() {
    if (!v && _showDebt && _visibleCount() <= 1) return;
    _showDebt = v;
  });
  void _setPayment(bool v) => setState(() {
    if (!v && _showPayment && _visibleCount() <= 1) return;
    _showPayment = v;
  });
  void _setExpense(bool v) => setState(() {
    if (!v && _showExpense && _visibleCount() <= 1) return;
    _showExpense = v;
  });
  void _setGain(bool v) => setState(() {
    if (!v && _showGain && _visibleCount() <= 1) return;
    _showGain = v;
  });

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showDebt) m = math.max(m, p.debt);
      if (_showPayment) m = math.max(m, p.payment);
      if (_showExpense) m = math.max(m, p.expense);
      if (_showGain) m = math.max(m, p.gain);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FourSeriesFilterChips(
          labelDebt: 'Debt',
          labelPayment: 'Payments',
          labelExpense: 'Expenses',
          labelGain: 'Gains',
          colorDebt: AppTheme.ledgerDebt,
          colorPayment: AppTheme.ledgerPayment,
          colorExpense: AppTheme.personalExpense,
          colorGain: AppTheme.personalGain,
          showDebt: _showDebt,
          showPayment: _showPayment,
          showExpense: _showExpense,
          showGain: _showGain,
          onDebt: _setDebt,
          onPayment: _setPayment,
          onExpense: _setExpense,
          onGain: _setGain,
        ),
        InteractiveChartShell(
          pointCount: widget.points.length,
          chartHeight: 220,
          detailBuilder: (i) => widget.detailBuilder(i, widget.interactiveCurrencyCode),
          footer: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _xLabels(context, widget.points.map((p) => p.label).toList()),
          ),
          buildChart: (hover) => AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _QuadLedgerPersonalPainter(
                points: widget.points,
                maxY: maxY,
                showDebt: _showDebt,
                showPayment: _showPayment,
                showExpense: _showExpense,
                showGain: _showGain,
                highlightIndex: hover,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonalNetLineChart extends StatefulWidget {
  const PersonalNetLineChart({
    super.key,
    required this.points,
    required this.interactiveCurrencyCode,
    required this.detailBuilder,
  });

  final List<PersonalCombinedDailyPoint> points;
  final String interactiveCurrencyCode;
  final String Function(int i, String code) detailBuilder;

  @override
  State<PersonalNetLineChart> createState() => _PersonalNetLineChartState();
}

class _PersonalNetLineChartState extends State<PersonalNetLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(PersonalNetLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxAbs = widget.points.map((p) => p.net.abs()).fold<int>(1, (a, b) => b > a ? b : a);
    return InteractiveChartShell(
      pointCount: widget.points.length,
      chartHeight: 200,
      detailBuilder: (i) => widget.detailBuilder(i, widget.interactiveCurrencyCode),
      footer: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Gains minus expenses per day',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedFg),
        ),
      ),
      buildChart: (hover) => AnimatedBuilder(
        animation: _progress,
        builder: (_, __) => CustomPaint(
          painter: _SingleSeriesPainter(
            values: widget.points.map((p) => p.net.toDouble()).toList(),
            maxAbs: maxAbs.toDouble(),
            color: AppTheme.brandPrimary,
            highlightIndex: hover,
            progress: _progress.value,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class PersonalCountLineChart extends StatefulWidget {
  const PersonalCountLineChart({
    super.key,
    required this.points,
    required this.detailBuilder,
  });

  final List<PersonalCombinedDailyPoint> points;
  final String Function(int i) detailBuilder;

  @override
  State<PersonalCountLineChart> createState() => _PersonalCountLineChartState();
}

class _PersonalCountLineChartState extends State<PersonalCountLineChart>
    with SingleTickerProviderStateMixin {
  bool _showExpense = true;
  bool _showGain = true;
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(PersonalCountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int _maxY() {
    var m = 1;
    for (final p in widget.points) {
      if (_showExpense) m = math.max(m, p.expenseCount);
      if (_showGain) m = math.max(m, p.gainCount);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeriesFilterChips(
          labelA: 'Expense entries',
          labelB: 'Gain entries',
          colorA: AppTheme.personalExpense,
          colorB: AppTheme.personalGain,
          showA: _showExpense,
          showB: _showGain,
          onAChanged: (v) => setState(() {
            _showExpense = v;
            if (!_showExpense && !_showGain) _showGain = true;
          }),
          onBChanged: (v) => setState(() {
            _showGain = v;
            if (!_showExpense && !_showGain) _showExpense = true;
          }),
        ),
        InteractiveChartShell(
          pointCount: widget.points.length,
          chartHeight: 200,
          detailBuilder: widget.detailBuilder,
          footer: _footerLegend(
            context,
            'Expense entries',
            'Gain entries',
            AppTheme.personalExpense,
            AppTheme.personalGain,
            widget.points,
            showLegendDots: false,
          ),
          buildChart: (hover) => AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _DualPersonalCountPainter(
                points: widget.points,
                maxY: maxY,
                showExpense: _showExpense,
                showGain: _showGain,
                highlightIndex: hover,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonalAmountLineChart extends StatefulWidget {
  const PersonalAmountLineChart({
    super.key,
    required this.points,
    required this.color,
    required this.legend,
  });

  final List<PersonalDailyPoint> points;
  final Color color;
  final String legend;

  @override
  State<PersonalAmountLineChart> createState() => _PersonalAmountLineChartState();
}

class _PersonalAmountLineChartState extends State<PersonalAmountLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _progress = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void didUpdateWidget(PersonalAmountLineChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _entry.forward(from: 0);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = widget.points.map((p) => p.amount).fold<int>(1, (a, b) => b > a ? b : a);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => CustomPaint(
              painter: _SinglePositivePainter(
                values: widget.points.map((p) => p.amount).toList(),
                maxY: maxY,
                color: widget.color,
                highlightIndex: null,
                progress: _progress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _xLabels(context, widget.points.map((p) => p.label).toList()),
        const SizedBox(height: 8),
        _LegendDot(color: widget.color, label: widget.legend),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _xLabels(BuildContext context, List<String> labels) {
  return Row(
    children: labels
        .map(
          (label) => Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.mutedFg),
            ),
          ),
        )
        .toList(),
  );
}

Widget _footerLegend<T>(
  BuildContext context,
  String legendA,
  String legendB,
  Color colorA,
  Color colorB,
  List<T> points, {
  bool showLegendDots = true,
}) {
  return Column(
    children: [
      const SizedBox(height: 6),
      _xLabels(context, _labelsFromPoints(points)),
      if (showLegendDots) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendDot(color: colorA, label: legendA),
            const SizedBox(width: 16),
            _LegendDot(color: colorB, label: legendB),
          ],
        ),
      ],
    ],
  );
}

List<String> _labelsFromPoints<T>(List<T> points) {
  if (points.isEmpty) return [];
  if (points.first is LedgerDailyPoint) {
    return (points as List<LedgerDailyPoint>).map((p) => p.label).toList();
  }
  if (points.first is CumulativeLedgerPoint) {
    return (points as List<CumulativeLedgerPoint>).map((p) => p.label).toList();
  }
  if (points.first is CurrentBalancePoint) {
    return (points as List<CurrentBalancePoint>).map((p) => p.label).toList();
  }
  if (points.first is CumulativePersonalPoint) {
    return (points as List<CumulativePersonalPoint>).map((p) => p.label).toList();
  }
  if (points.first is PersonalCombinedDailyPoint) {
    return (points as List<PersonalCombinedDailyPoint>).map((p) => p.label).toList();
  }
  if (points.first is LedgerPersonalDailyPoint) {
    return (points as List<LedgerPersonalDailyPoint>).map((p) => p.label).toList();
  }
  return [];
}

void _paintDashedVertical(Canvas canvas, Offset a, Offset b, Paint p) {
  const dash = 6.0;
  const gap = 4.0;
  final d = b - a;
  final len = d.distance;
  if (len < 0.1) return;
  final dir = d / len;
  var t = 0.0;
  while (t < len) {
    final e = (t + dash).clamp(0.0, len);
    canvas.drawLine(a + dir * t, a + dir * e, p);
    t += dash + gap;
  }
}

class _SeriesFilterChips extends StatelessWidget {
  const _SeriesFilterChips({
    required this.labelA,
    required this.labelB,
    required this.colorA,
    required this.colorB,
    required this.showA,
    required this.showB,
    required this.onAChanged,
    required this.onBChanged,
  });

  final String labelA;
  final String labelB;
  final Color colorA;
  final Color colorB;
  final bool showA;
  final bool showB;
  final ValueChanged<bool> onAChanged;
  final ValueChanged<bool> onBChanged;

  @override
  Widget build(BuildContext context) {
    void setA(bool v) {
      if (!v && !showB) return;
      onAChanged(v);
    }

    void setB(bool v) {
      if (!v && !showA) return;
      onBChanged(v);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          FilterChip(
            label: Text(labelA),
            selected: showA,
            onSelected: setA,
            selectedColor: colorA.withValues(alpha: 0.32),
            checkmarkColor: colorA,
            labelStyle: TextStyle(
              color: showA ? colorA : AppTheme.mutedFg,
              fontWeight: showA ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            side: BorderSide(
              color: showA ? colorA.withValues(alpha: 0.75) : AppTheme.mutedFg.withValues(alpha: 0.35),
            ),
          ),
          FilterChip(
            label: Text(labelB),
            selected: showB,
            onSelected: setB,
            selectedColor: colorB.withValues(alpha: 0.32),
            checkmarkColor: colorB,
            labelStyle: TextStyle(
              color: showB ? colorB : AppTheme.mutedFg,
              fontWeight: showB ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            side: BorderSide(
              color: showB ? colorB.withValues(alpha: 0.75) : AppTheme.mutedFg.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters — all upgraded with glow HUD rendering
// ─────────────────────────────────────────────────────────────────────────────

class _QuadLedgerPersonalPainter extends CustomPainter {
  _QuadLedgerPersonalPainter({
    required this.points,
    required this.maxY,
    required this.showDebt,
    required this.showPayment,
    required this.showExpense,
    required this.showGain,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<LedgerPersonalDailyPoint> points;
  final int maxY;
  final bool showDebt;
  final bool showPayment;
  final bool showExpense;
  final bool showGain;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (points.length <= 1) return w / 2;
    return i * (w / (points.length - 1));
  }

  List<Offset> _pts(Size size, int Function(LedgerPersonalDailyPoint) val) => [
    for (var i = 0; i < points.length; i++)
      Offset(
        _xFor(i, size.width),
        size.height - ((val(points[i]) / maxY) * size.height),
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || maxY <= 0) return;
    _drawHudGrid(canvas, size);

    // Draw fills back-to-front to avoid z-fighting
    if (showGain) _drawGradientFill(canvas, size, _pts(size, (p) => p.gain), AppTheme.personalGain);
    if (showExpense) _drawGradientFill(canvas, size, _pts(size, (p) => p.expense), AppTheme.personalExpense);
    if (showPayment) _drawGradientFill(canvas, size, _pts(size, (p) => p.payment), AppTheme.ledgerPayment);
    if (showDebt) _drawGradientFill(canvas, size, _pts(size, (p) => p.debt), AppTheme.ledgerDebt);

    if (showGain) _drawGlowPolyline(canvas, _pts(size, (p) => p.gain), AppTheme.personalGain, progress: progress);
    if (showExpense) _drawGlowPolyline(canvas, _pts(size, (p) => p.expense), AppTheme.personalExpense, progress: progress);
    if (showPayment) _drawGlowPolyline(canvas, _pts(size, (p) => p.payment), AppTheme.ledgerPayment, progress: progress);
    if (showDebt) _drawGlowPolyline(canvas, _pts(size, (p) => p.debt), AppTheme.ledgerDebt, progress: progress);

    // Dots for each visible series
    final seriesInfo = [
      if (showDebt) (AppTheme.ledgerDebt, _pts(size, (p) => p.debt)),
      if (showPayment) (AppTheme.ledgerPayment, _pts(size, (p) => p.payment)),
      if (showExpense) (AppTheme.personalExpense, _pts(size, (p) => p.expense)),
      if (showGain) (AppTheme.personalGain, _pts(size, (p) => p.gain)),
    ];
    final clippedCount = _clipProgressPts(
      List.generate(points.length, (i) => Offset(i.toDouble(), 0)),
      progress,
    ).length;
    for (final (color, pts) in seriesInfo) {
      for (var i = 0; i < math.min(clippedCount, pts.length); i++) {
        _drawGlowDot(canvas, pts[i], color, highlight: i == highlightIndex);
      }
    }

    if (highlightIndex != null && highlightIndex! >= 0 && highlightIndex! < points.length) {
      final hx = _xFor(highlightIndex!, size.width);
      _paintDashedVertical(
        canvas,
        Offset(hx, 0),
        Offset(hx, size.height),
        Paint()..color = AppTheme.mutedFg.withValues(alpha: 0.5)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuadLedgerPersonalPainter old) =>
      old.points != points ||
      old.maxY != maxY ||
      old.highlightIndex != highlightIndex ||
      old.showDebt != showDebt ||
      old.showPayment != showPayment ||
      old.showExpense != showExpense ||
      old.showGain != showGain ||
      old.progress != progress;
}

class _DualAmountPainter<T> extends CustomPainter {
  _DualAmountPainter({
    required this.points,
    required this.maxY,
    required this.valueA,
    required this.valueB,
    required this.colorA,
    required this.colorB,
    this.showA = true,
    this.showB = true,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<T> points;
  final int maxY;
  final int Function(T) valueA;
  final int Function(T) valueB;
  final Color colorA;
  final Color colorB;
  final bool showA;
  final bool showB;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (points.length <= 1) return w / 2;
    return i * (w / (points.length - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || maxY <= 0) return;
    _drawHudGrid(canvas, size);

    final ptsA = showA
        ? [
            for (var i = 0; i < points.length; i++)
              Offset(_xFor(i, size.width), size.height - ((valueA(points[i]) / maxY) * size.height)),
          ]
        : <Offset>[];

    final ptsB = showB
        ? [
            for (var i = 0; i < points.length; i++)
              Offset(_xFor(i, size.width), size.height - ((valueB(points[i]) / maxY) * size.height)),
          ]
        : <Offset>[];

    if (showB) _drawGradientFill(canvas, size, ptsB, colorB);
    if (showA) _drawGradientFill(canvas, size, ptsA, colorA);

    if (showB) _drawGlowPolyline(canvas, ptsB, colorB, progress: progress);
    if (showA) _drawGlowPolyline(canvas, ptsA, colorA, progress: progress);

    final clippedCount = points.isEmpty
        ? 0
        : _clipProgressPts(List.generate(points.length, (i) => Offset(i.toDouble(), 0)), progress).length;

    if (showA) {
      for (var i = 0; i < math.min(clippedCount, ptsA.length); i++) {
        _drawGlowDot(canvas, ptsA[i], colorA, highlight: i == highlightIndex);
      }
    }
    if (showB) {
      for (var i = 0; i < math.min(clippedCount, ptsB.length); i++) {
        _drawGlowDot(canvas, ptsB[i], colorB, highlight: i == highlightIndex);
      }
    }

    if (highlightIndex != null && highlightIndex! >= 0 && highlightIndex! < points.length) {
      final hx = _xFor(highlightIndex!, size.width);
      _paintDashedVertical(
        canvas,
        Offset(hx, 0),
        Offset(hx, size.height),
        Paint()..color = AppTheme.mutedFg.withValues(alpha: 0.5)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualAmountPainter<T> old) =>
      old.points != points ||
      old.maxY != maxY ||
      old.highlightIndex != highlightIndex ||
      old.showA != showA ||
      old.showB != showB ||
      old.colorA != colorA ||
      old.colorB != colorB ||
      old.progress != progress;
}

class _DualIntPainter extends CustomPainter {
  _DualIntPainter({
    required this.points,
    required this.maxY,
    required this.valueA,
    required this.valueB,
    required this.colorA,
    required this.colorB,
    this.showA = true,
    this.showB = true,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<LedgerDailyPoint> points;
  final int maxY;
  final int Function(LedgerDailyPoint) valueA;
  final int Function(LedgerDailyPoint) valueB;
  final Color colorA;
  final Color colorB;
  final bool showA;
  final bool showB;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (points.length <= 1) return w / 2;
    return i * (w / (points.length - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || maxY <= 0) return;
    _drawHudGrid(canvas, size);

    final ptsA = showA
        ? [for (var i = 0; i < points.length; i++)
            Offset(_xFor(i, size.width), size.height - ((valueA(points[i]) / maxY) * size.height))]
        : <Offset>[];
    final ptsB = showB
        ? [for (var i = 0; i < points.length; i++)
            Offset(_xFor(i, size.width), size.height - ((valueB(points[i]) / maxY) * size.height))]
        : <Offset>[];

    if (showB) _drawGradientFill(canvas, size, ptsB, colorB);
    if (showA) _drawGradientFill(canvas, size, ptsA, colorA);
    if (showB) _drawGlowPolyline(canvas, ptsB, colorB, progress: progress);
    if (showA) _drawGlowPolyline(canvas, ptsA, colorA, progress: progress);

    final clippedCount = points.isEmpty
        ? 0
        : _clipProgressPts(List.generate(points.length, (i) => Offset(i.toDouble(), 0)), progress).length;

    if (showA) {
      for (var i = 0; i < math.min(clippedCount, ptsA.length); i++) {
        _drawGlowDot(canvas, ptsA[i], colorA, highlight: i == highlightIndex);
      }
    }
    if (showB) {
      for (var i = 0; i < math.min(clippedCount, ptsB.length); i++) {
        _drawGlowDot(canvas, ptsB[i], colorB, highlight: i == highlightIndex);
      }
    }

    if (highlightIndex != null && highlightIndex! >= 0 && highlightIndex! < points.length) {
      final hx = _xFor(highlightIndex!, size.width);
      _paintDashedVertical(
        canvas,
        Offset(hx, 0),
        Offset(hx, size.height),
        Paint()..color = AppTheme.mutedFg.withValues(alpha: 0.5)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualIntPainter old) =>
      old.points != points ||
      old.maxY != maxY ||
      old.highlightIndex != highlightIndex ||
      old.showA != showA ||
      old.showB != showB ||
      old.progress != progress;
}

class _DualPersonalCountPainter extends CustomPainter {
  _DualPersonalCountPainter({
    required this.points,
    required this.maxY,
    this.showExpense = true,
    this.showGain = true,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<PersonalCombinedDailyPoint> points;
  final int maxY;
  final bool showExpense;
  final bool showGain;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (points.length <= 1) return w / 2;
    return i * (w / (points.length - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || maxY <= 0) return;
    _drawHudGrid(canvas, size);

    final ptsA = showExpense
        ? [for (var i = 0; i < points.length; i++)
            Offset(_xFor(i, size.width), size.height - ((points[i].expenseCount / maxY) * size.height))]
        : <Offset>[];
    final ptsB = showGain
        ? [for (var i = 0; i < points.length; i++)
            Offset(_xFor(i, size.width), size.height - ((points[i].gainCount / maxY) * size.height))]
        : <Offset>[];

    if (showGain) _drawGradientFill(canvas, size, ptsB, AppTheme.personalGain);
    if (showExpense) _drawGradientFill(canvas, size, ptsA, AppTheme.personalExpense);
    if (showGain) _drawGlowPolyline(canvas, ptsB, AppTheme.personalGain, progress: progress);
    if (showExpense) _drawGlowPolyline(canvas, ptsA, AppTheme.personalExpense, progress: progress);

    final clippedCount = points.isEmpty
        ? 0
        : _clipProgressPts(List.generate(points.length, (i) => Offset(i.toDouble(), 0)), progress).length;

    if (showExpense) {
      for (var i = 0; i < math.min(clippedCount, ptsA.length); i++) {
        _drawGlowDot(canvas, ptsA[i], AppTheme.personalExpense, highlight: i == highlightIndex);
      }
    }
    if (showGain) {
      for (var i = 0; i < math.min(clippedCount, ptsB.length); i++) {
        _drawGlowDot(canvas, ptsB[i], AppTheme.personalGain, highlight: i == highlightIndex);
      }
    }

    if (highlightIndex != null && highlightIndex! >= 0 && highlightIndex! < points.length) {
      final hx = _xFor(highlightIndex!, size.width);
      _paintDashedVertical(
        canvas,
        Offset(hx, 0),
        Offset(hx, size.height),
        Paint()..color = AppTheme.mutedFg.withValues(alpha: 0.5)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualPersonalCountPainter old) =>
      old.points != points ||
      old.maxY != maxY ||
      old.highlightIndex != highlightIndex ||
      old.showExpense != showExpense ||
      old.showGain != showGain ||
      old.progress != progress;
}

class _SingleSeriesPainter extends CustomPainter {
  _SingleSeriesPainter({
    required this.values,
    required this.maxAbs,
    required this.color,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<double> values;
  final double maxAbs;
  final Color color;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (values.length <= 1) return w / 2;
    return i * (w / (values.length - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || maxAbs <= 0) return;
    _drawHudGrid(canvas, size);

    final midY = size.height / 2;
    // Glow midline
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = AppTheme.mutedFg.withValues(alpha: 0.25)
        ..strokeWidth = 1,
    );

    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(
          _xFor(i, size.width),
          midY - ((values[i] / maxAbs).clamp(-1.0, 1.0)) * (size.height * 0.42),
        ),
    ];

    _drawGradientFill(canvas, size, pts, color);
    _drawGlowPolyline(canvas, pts, color, progress: progress);

    final clippedCount = values.isEmpty
        ? 0
        : _clipProgressPts(List.generate(values.length, (i) => Offset(i.toDouble(), 0)), progress).length;

    for (var i = 0; i < math.min(clippedCount, pts.length); i++) {
      _drawGlowDot(canvas, pts[i], color, highlight: i == highlightIndex);
    }

    if (highlightIndex != null && highlightIndex! >= 0 && highlightIndex! < values.length) {
      final hx = _xFor(highlightIndex!, size.width);
      _paintDashedVertical(
        canvas,
        Offset(hx, 0),
        Offset(hx, size.height),
        Paint()..color = AppTheme.mutedFg.withValues(alpha: 0.5)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SingleSeriesPainter old) =>
      old.values != values ||
      old.maxAbs != maxAbs ||
      old.highlightIndex != highlightIndex ||
      old.progress != progress;
}

class _SinglePositivePainter extends CustomPainter {
  _SinglePositivePainter({
    required this.values,
    required this.maxY,
    required this.color,
    this.highlightIndex,
    this.progress = 1.0,
  });

  final List<int> values;
  final int maxY;
  final Color color;
  final int? highlightIndex;
  final double progress;

  double _xFor(int i, double w) {
    if (values.length <= 1) return w / 2;
    return i * (w / (values.length - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || maxY <= 0) return;
    _drawHudGrid(canvas, size);

    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(_xFor(i, size.width), size.height - ((values[i] / maxY) * size.height)),
    ];

    _drawGradientFill(canvas, size, pts, color);
    _drawGlowPolyline(canvas, pts, color, progress: progress);

    final clippedCount = values.isEmpty
        ? 0
        : _clipProgressPts(List.generate(values.length, (i) => Offset(i.toDouble(), 0)), progress).length;

    for (var i = 0; i < math.min(clippedCount, pts.length); i++) {
      _drawGlowDot(canvas, pts[i], color, highlight: i == highlightIndex);
    }
  }

  @override
  bool shouldRepaint(covariant _SinglePositivePainter old) =>
      old.values != values || old.maxY != maxY || old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend dot
// ─────────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

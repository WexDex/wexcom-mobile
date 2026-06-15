import 'dart:math' as math;
import 'dart:ui';

/// Global curve style for line charts (loaded from app_settings on startup).
ChartCurveStyle currentChartCurveStyle = ChartCurveStyle.monotone;

/// Global line chart curve styles (persisted in app_settings).
enum ChartCurveStyle {
  straight,
  bezier,
  catmullRom,
  monotone;

  String get storageKey => name;

  static ChartCurveStyle fromStorage(String? key) {
    return ChartCurveStyle.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ChartCurveStyle.monotone,
    );
  }
}

/// Build a path through [pts] using [style]. Returns empty path if pts empty.
Path buildSeriesPath(List<Offset> pts, ChartCurveStyle style) {
  final path = Path();
  if (pts.isEmpty) return path;
  if (pts.length == 1) {
    path.addOval(Rect.fromCircle(center: pts.first, radius: 1));
    return path;
  }
  if (style == ChartCurveStyle.straight || pts.length == 2) {
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }
  if (style == ChartCurveStyle.bezier) {
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cp1 = Offset(
        p0.dx + (p1.dx - p0.dx) / 3,
        p0.dy,
      );
      final cp2 = Offset(
        p0.dx + 2 * (p1.dx - p0.dx) / 3,
        p1.dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }
    return path;
  }
  if (style == ChartCurveStyle.catmullRom) {
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      const tension = 0.5;
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * tension / 6,
        p1.dy + (p2.dy - p0.dy) * tension / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * tension / 6,
        p2.dy - (p3.dy - p1.dy) * tension / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }
  // Monotone cubic (Fritsch-Carlson)
  final n = pts.length;
  final dx = List<double>.filled(n - 1, 0);
  final dy = List<double>.filled(n - 1, 0);
  final m = List<double>.filled(n, 0);
  for (var i = 0; i < n - 1; i++) {
    dx[i] = pts[i + 1].dx - pts[i].dx;
    dy[i] = pts[i + 1].dy - pts[i].dy;
    if (dx[i] == 0) {
      m[i] = 0;
      m[i + 1] = 0;
    } else {
      m[i] = dy[i] / dx[i];
    }
  }
  for (var i = 1; i < n - 1; i++) {
    if (m[i - 1] * m[i] <= 0) {
      m[i] = 0;
    } else {
      final avg = (m[i - 1] + m[i]) / 2;
      m[i] = avg.sign * math.min(avg.abs(), math.min(m[i - 1].abs(), m[i].abs()) * 3);
    }
  }
  path.moveTo(pts.first.dx, pts.first.dy);
  for (var i = 0; i < n - 1; i++) {
    final h = dx[i];
    final cp1 = Offset(
      pts[i].dx + h / 3,
      pts[i].dy + m[i] * h / 3,
    );
    final cp2 = Offset(
      pts[i + 1].dx - h / 3,
      pts[i + 1].dy - m[i + 1] * h / 3,
    );
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
  }
  return path;
}

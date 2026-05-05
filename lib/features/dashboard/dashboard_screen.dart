import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ledger_repository.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(allTransactionsProvider(null));
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: txAsync.when(
        data: (rows) {
          var totalOwedToYou = 0;
          var totalYouOwe = 0;
          for (final row in rows) {
            if (LedgerTxStatus.fromInt(row.transaction.txStatus) !=
                LedgerTxStatus.active) {
              continue;
            }
            final type = LedgerTxType.fromInt(row.transaction.txType);
            if (type == LedgerTxType.debt) {
              totalOwedToYou += row.transaction.amountMinor;
            } else {
              totalYouOwe += row.transaction.amountMinor;
            }
          }

          final points = _buildDailySeries(rows);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total owed to you',
                      value: MoneyFormat.formatMinor(totalOwedToYou, code),
                      color: AppTheme.ledgerDebt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Total you owe',
                      value: MoneyFormat.formatMinor(totalYouOwe, code),
                      color: AppTheme.ledgerPayment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StatCard(
                label: 'Net balance',
                value: MoneyFormat.formatMinor(totalOwedToYou - totalYouOwe, code),
                color: AppTheme.receivableAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Debt & Payments over time (last 7 days)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _DualLineChart(points: points),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<_SeriesPoint> _buildDailySeries(List<LedgerTransactionWithClient> rows) {
    final now = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day).subtract(
        Duration(days: 6 - i),
      ),
    );
    final debts = <DateTime, int>{for (final d in days) d: 0};
    final payments = <DateTime, int>{for (final d in days) d: 0};

    for (final row in rows) {
      final tx = row.transaction;
      if (LedgerTxStatus.fromInt(tx.txStatus) != LedgerTxStatus.active) continue;
      final date = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      if (!debts.containsKey(date)) continue;
      if (LedgerTxType.fromInt(tx.txType) == LedgerTxType.debt) {
        debts[date] = (debts[date] ?? 0) + tx.amountMinor;
      } else {
        payments[date] = (payments[date] ?? 0) + tx.amountMinor;
      }
    }
    return days
        .map(
          (d) => _SeriesPoint(
            label: '${d.month}/${d.day}',
            debt: debts[d] ?? 0,
            payment: payments[d] ?? 0,
          ),
        )
        .toList();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.mutedFg)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesPoint {
  const _SeriesPoint({
    required this.label,
    required this.debt,
    required this.payment,
  });
  final String label;
  final int debt;
  final int payment;
}

class _DualLineChart extends StatelessWidget {
  const _DualLineChart({required this.points});

  final List<_SeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points
        .map((p) => p.debt > p.payment ? p.debt : p.payment)
        .fold<int>(1, (a, b) => b > a ? b : a);
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.mutedFg.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(points: points, maxY: maxY),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: points
                .map(
                  (p) => Expanded(
                    child: Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.mutedFg,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _LegendDot(color: AppTheme.ledgerDebt, label: 'Debt'),
              SizedBox(width: 16),
              _LegendDot(color: AppTheme.ledgerPayment, label: 'Payment'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.points, required this.maxY});

  final List<_SeriesPoint> points;
  final int maxY;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final gap = size.width / (points.length - 1);
    final debtPaint = Paint()
      ..color = AppTheme.ledgerDebt
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;
    final payPaint = Paint()
      ..color = AppTheme.ledgerPayment
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final debtPath = Path();
    final payPath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * gap;
      final debtY = size.height - ((points[i].debt / maxY) * size.height);
      final payY = size.height - ((points[i].payment / maxY) * size.height);
      if (i == 0) {
        debtPath.moveTo(x, debtY);
        payPath.moveTo(x, payY);
      } else {
        debtPath.lineTo(x, debtY);
        payPath.lineTo(x, payY);
      }
      canvas.drawCircle(Offset(x, debtY), 2.4, debtPaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, payY), 2.4, payPaint..style = PaintingStyle.fill);
      debtPaint.style = PaintingStyle.stroke;
      payPaint.style = PaintingStyle.stroke;
    }
    canvas.drawPath(debtPath, debtPaint);
    canvas.drawPath(payPath, payPaint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxY != maxY;
  }
}

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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

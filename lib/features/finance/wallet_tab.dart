import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../models/from_currency_snapshot.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/chart_curve.dart';
import '../../utils/exchange_rate.dart';
import '../../utils/money.dart';
import '../../widgets/currency_amount_input.dart';
import 'wallet_section.dart';

class WalletTabBody extends ConsumerStatefulWidget {
  const WalletTabBody({super.key});

  @override
  ConsumerState<WalletTabBody> createState() => _WalletTabBodyState();
}

class _WalletTabBodyState extends ConsumerState<WalletTabBody> {
  final Set<String> _visibleAccounts = {};

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(walletAccountsProvider);
    final ledgerAsync = ref.watch(allWalletLedgerProvider);
    final defaultCode = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'DZD';
    final text = Theme.of(context).textTheme;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppTheme.mutedFg),
                const SizedBox(height: 12),
                Text('No wallet accounts', style: text.titleMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => openWalletManager(context, ref, defaultCode),
                  icon: const Icon(Icons.add),
                  label: const Text('Add account'),
                ),
              ],
            ),
          );
        }

        for (final a in accounts) {
          _visibleAccounts.add(a.id);
        }

        final ledger = ledgerAsync.valueOrNull ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            const WalletNetWorthCard(),
            const WalletSavingsGoalsSection(),
            const Divider(height: 24),
            Row(
              children: [
                Text('Accounts', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Manage accounts',
                  onPressed: () => openWalletManager(context, ref, defaultCode),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accounts.map((a) {
                final visible = _visibleAccounts.contains(a.id);
                return FilterChip(
                  label: Text('${a.emoji} ${a.name}'),
                  selected: visible,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _visibleAccounts.add(a.id);
                    } else {
                      _visibleAccounts.remove(a.id);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _WalletComparisonChart(
                accounts: accounts.where((a) => _visibleAccounts.contains(a.id)).toList(),
                ledger: ledger,
              ),
            ),
            const SizedBox(height: 20),
            ...accounts.map((a) => _AccountSection(
                  account: a,
                  defaultCode: defaultCode,
                  ledger: ledger.where((e) => e.accountId == a.id).toList(),
                  onAdjust: () => _walletOps(context, ref, a, defaultCode),
                )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _walletOps(
    BuildContext context,
    WidgetRef ref,
    WalletAccount account,
    String defaultCode,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add to balance'),
              onTap: () => Navigator.pop(ctx, 'add'),
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: const Text('Remove from balance'),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Set balance'),
              onTap: () => Navigator.pop(ctx, 'set'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final repo = ref.read(ledgerRepositoryProvider);
    final foreign = await repo.foreignCurrencyEditorContext();
    if (!context.mounted) return;

    final previewCtrl = TextEditingController();
    final amountKey = GlobalKey<CurrencyAmountInputState>();
    FromCurrencySnapshot? fromSnap;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(switch (action) {
          'add' => 'Add amount',
          'remove' => 'Remove amount',
          _ => 'Set balance',
        }),
        content: SingleChildScrollView(
          child: account.currencyCode == defaultCode
              ? TextField(
                  controller: previewCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(helperText: defaultCode),
                )
              : CurrencyAmountInput(
                  key: amountKey,
                  defaultCurrencyCode: defaultCode,
                  amountMinorController: previewCtrl,
                  currencyCodes: foreign.codes,
                  rates: foreign.rates,
                  fixedInputCurrency: account.currencyCode,
                  showForeignToggle: false,
                  onSnapshotChanged: (s) => fromSnap = s,
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    int minor;
    if (account.currencyCode == defaultCode) {
      minor = MoneyFormat.parseMinorUnits(previewCtrl.text, fractionDigits: 0) ?? 0;
    } else {
      final snap = amountKey.currentState?.buildSnapshot() ?? fromSnap;
      minor = snap != null ? snap.amount.round() : 0;
    }
    previewCtrl.dispose();
    if (minor <= 0) return;
    switch (action) {
      case 'add':
        await repo.adjustWalletDelta(account.id, minor, fromCurrency: fromSnap);
      case 'remove':
        await repo.adjustWalletDelta(account.id, -minor, fromCurrency: fromSnap);
      default:
        await repo.adjustAccountBalance(account.id, minor, fromCurrency: fromSnap);
    }
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection({
    required this.account,
    required this.defaultCode,
    required this.ledger,
    required this.onAdjust,
  });

  final WalletAccount account;
  final String defaultCode;
  final List<WalletLedgerEntry> ledger;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rateAsync = ref.watch(currentRateProvider(account.currencyCode));
    final rate = rateAsync.valueOrNull;
    final native = MoneyFormat.formatMinor(account.balanceMinor, account.currencyCode);
    String? estimate;
    if (account.currencyCode != defaultCode && rate != null) {
      final est = convertMajorToDefaultMinor(
        majorAmount: account.balanceMinor,
        rate: rate,
        defaultFractionDigits: 0,
      );
      estimate = '~= ${MoneyFormat.formatMinor(est, defaultCode)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${account.emoji} ${account.name}',
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(native, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            if (estimate != null)
              Text(estimate, style: text.labelSmall?.copyWith(color: AppTheme.mutedFg)),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onAdjust,
              child: const Text('Adjust balance'),
            ),
            TextButton(
              onPressed: () => context.push('/finance/wallet/${account.id}'),
              child: const Text('See all history'),
            ),
            if (ledger.isNotEmpty) ...[
              const Divider(height: 20),
              Text('History', style: text.labelMedium?.copyWith(color: AppTheme.mutedFg)),
              ...ledger.take(8).map((e) {
                final snap = FromCurrencySnapshot.fromJsonString(e.fromCurrencyJson);
                final op = e.opType;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    op == 'increase'
                        ? Icons.add_circle_outline
                        : op == 'decrease'
                            ? Icons.remove_circle_outline
                            : Icons.swap_horiz,
                    size: 18,
                  ),
                  title: Text(
                    '$op ${MoneyFormat.formatMinor(e.amountMinor, account.currencyCode)}',
                    style: text.bodySmall,
                  ),
                  subtitle: Text(
                    '${MoneyFormat.formatMinor(e.balanceBeforeMinor, account.currencyCode)} → '
                    '${MoneyFormat.formatMinor(e.balanceAfterMinor, account.currencyCode)}'
                    '${snap != null ? ' · ${snap.formatPrimary()}' : ''}',
                    style: text.labelSmall?.copyWith(color: AppTheme.mutedFg),
                  ),
                  trailing: Text(
                    DateFormat.MMMd().format(e.createdAt.toLocal()),
                    style: text.labelSmall,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _WalletComparisonChart extends StatelessWidget {
  const _WalletComparisonChart({
    required this.accounts,
    required this.ledger,
  });

  final List<WalletAccount> accounts;
  final List<WalletLedgerEntry> ledger;

  static const _colors = [
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const Center(child: Text('Select accounts to compare'));
    }
    return CustomPaint(
      painter: _WalletChartPainter(accounts: accounts, ledger: ledger, colors: _colors),
      child: const SizedBox.expand(),
    );
  }
}

class _WalletChartPainter extends CustomPainter {
  _WalletChartPainter({
    required this.accounts,
    required this.ledger,
    required this.colors,
  });

  final List<WalletAccount> accounts;
  final List<WalletLedgerEntry> ledger;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    _drawHudGrid(canvas, size);
    var maxY = 1.0;
    for (final a in accounts) {
      if (a.balanceMinor > maxY) maxY = a.balanceMinor.toDouble();
      for (final e in ledger.where((l) => l.accountId == a.id)) {
        if (e.balanceAfterMinor > maxY) maxY = e.balanceAfterMinor.toDouble();
      }
    }

    for (var ai = 0; ai < accounts.length; ai++) {
      final a = accounts[ai];
      final entries = ledger.where((l) => l.accountId == a.id).toList()
        ..sort((x, y) => x.createdAt.compareTo(y.createdAt));
      final pts = <Offset>[];
      if (entries.isEmpty) {
        pts.add(Offset(0, size.height * (1 - a.balanceMinor / maxY)));
        pts.add(Offset(size.width, size.height * (1 - a.balanceMinor / maxY)));
      } else {
        final step = size.width / (entries.length - 1).clamp(1, 999);
        for (var i = 0; i < entries.length; i++) {
          pts.add(Offset(
            i * step,
            size.height * (1 - entries[i].balanceAfterMinor / maxY),
          ));
        }
      }
      final color = colors[ai % colors.length];
      _drawGlowPolyline(canvas, pts, color);
    }
  }

  void _drawHudGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.hudGridFaint
      ..strokeWidth = 0.5;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGlowPolyline(Canvas canvas, List<Offset> pts, Color color) {
    if (pts.length < 2) return;
    final path = buildSeriesPath(pts, currentChartCurveStyle);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WalletChartPainter oldDelegate) => true;
}

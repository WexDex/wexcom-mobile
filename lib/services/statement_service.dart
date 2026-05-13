import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/db/app_database.dart';
import '../data/ledger_types.dart';
import '../utils/money.dart';

class StatementService {
  /// Generates a PDF statement for [client] covering transactions in [range].
  /// Returns the raw PDF bytes.
  static Future<Uint8List> generate({
    required Client client,
    required List<LedgerTransaction> allTransactions,
    required DateTime from,
    required DateTime to,
    required String currencyCode,
  }) async {
    // Filter and sort transactions within the range
    final inRange = allTransactions
        .where((tx) {
          if (LedgerTxStatus.fromInt(tx.txStatus) == LedgerTxStatus.cancelled) return false;
          final date = tx.effectiveAt ?? tx.createdAt;
          return !date.isBefore(from) && !date.isAfter(to);
        })
        .toList()
      ..sort((a, b) {
        final da = a.effectiveAt ?? a.createdAt;
        final db = b.effectiveAt ?? b.createdAt;
        return da.compareTo(db);
      });

    // Opening balance = balance before the first transaction in range
    // = client's current balance minus sum of in-range transactions
    int runningBalance = _openingBalance(client.balanceMinor, inRange);

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (ctx) => [
          // ── Header ────────────────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('WEXCOM', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.Text('Account Statement', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // ── Client info ───────────────────────────────────────────
          pw.Text(client.fullName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Period: ${dateFormat.format(from)}  –  ${dateFormat.format(to)}',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
          if (client.phone != null)
            pw.Text('Phone: ${client.phone}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          pw.SizedBox(height: 14),

          // ── Opening balance ───────────────────────────────────────
          _balanceLine('Opening balance', runningBalance, currencyCode),
          pw.SizedBox(height: 10),

          // ── Transaction table ─────────────────────────────────────
          if (inRange.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 24),
                child: pw.Text('No transactions in this period.',
                    style: const pw.TextStyle(color: PdfColors.grey500)),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(70),
                1: const pw.FixedColumnWidth(52),
                2: const pw.FlexColumnWidth(),
                3: const pw.FixedColumnWidth(80),
                4: const pw.FixedColumnWidth(80),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _th('Date'),
                    _th('Type'),
                    _th('Note'),
                    _th('Amount'),
                    _th('Balance'),
                  ],
                ),
                // Data rows
                ...inRange.map((tx) {
                  final isDebt = LedgerTxType.fromInt(tx.txType) == LedgerTxType.debt;
                  final sign = isDebt ? 1 : -1;
                  runningBalance += sign * tx.amountMinor;
                  return pw.TableRow(children: [
                    _td(dateFormat.format(tx.effectiveAt ?? tx.createdAt)),
                    _td(isDebt ? 'Debt' : 'Payment', color: isDebt ? PdfColors.red700 : PdfColors.green700),
                    _td(tx.note ?? '—'),
                    _td(
                      MoneyFormat.formatMinor(tx.amountMinor, currencyCode),
                      color: isDebt ? PdfColors.red700 : PdfColors.green700,
                    ),
                    _td(MoneyFormat.formatMinor(runningBalance, currencyCode)),
                  ]);
                }),
              ],
            ),

          pw.SizedBox(height: 16),

          // ── Closing balance ───────────────────────────────────────
          _balanceLine('Closing balance', runningBalance, currencyCode, bold: true),

          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Text(
            'Generated ${DateFormat('dd/MM/yyyy HH:mm').format(now)} — Wexcom Mobile',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static int _openingBalance(int currentBalance, List<LedgerTransaction> txsInRange) {
    // Work backwards: current balance minus effect of each in-range tx
    var balance = currentBalance;
    for (final tx in txsInRange.reversed) {
      final isDebt = LedgerTxType.fromInt(tx.txType) == LedgerTxType.debt;
      balance -= isDebt ? tx.amountMinor : -tx.amountMinor;
    }
    return balance;
  }

  static pw.Widget _balanceLine(String label, int amountMinor, String code, {bool bold = false}) {
    final style = bold
        ? pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle(fontSize: 11);
    final color = amountMinor >= 0 ? PdfColors.red700 : PdfColors.green700;
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(
          MoneyFormat.formatMinor(amountMinor, code),
          style: pw.TextStyle(fontSize: bold ? 13 : 11, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color),
        ),
      ],
    );
  }

  static pw.Widget _th(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _td(String text, {PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color)),
      );
}

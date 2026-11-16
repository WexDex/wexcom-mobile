import 'package:flutter_test/flutter_test.dart';
import 'package:wexcom_mobile/data/db/app_database.dart';
import 'package:wexcom_mobile/features/finance/bulk_import/bulk_import_models.dart';
import 'package:wexcom_mobile/features/finance/bulk_import/finance_bulk_line_parser.dart';

ExpenseCategory _cat(String id, String name, String scope) {
  return ExpenseCategory(
    id: id,
    name: name,
    colorHex: '#22C55E',
    iconCodePoint: 0xe227,
    budgetMinorPerMonth: null,
    scope: scope,
    createdAt: DateTime.utc(2025, 1, 1),
    budgetPeriod: 'month',
    budgetCustomDays: null,
  );
}

Client _client(String id, String name) {
  return Client(
    id: id,
    fullName: name,
    phone: null,
    note: null,
    externalRef: null,
    tagsJson: null,
    source: 'manual',
    lastInteractionAt: null,
    balanceMinor: 0,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
    archivedAt: null,
  );
}

WalletAccount _wallet(String id, String name) {
  return WalletAccount(
    id: id,
    name: name,
    emoji: '💵',
    currencyCode: 'DZD',
    balanceMinor: 0,
    sortOrder: 0,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}

void main() {
  final expenses = [_cat('c1', 'Food', 'expense'), _cat('c2', 'Transport', 'expense')];
  final gains = [_cat('g1', 'Other', 'gain')];
  final clients = [_client('cl1', 'Ahmed'), _client('cl2', 'Sara')];
  final wallets = [
    _wallet('wallet-cash', 'Pocket'),
    _wallet('bank', 'Bank'),
  ];
  final defaultDay = DateTime(2025, 11, 15);

  List<BulkImportDraftLine> parse(String text) => parseBulkImportText(
        text: text,
        expenseCategories: expenses,
        gainCategories: gains,
        clients: clients,
        walletAccounts: wallets,
        defaultDay: defaultDay,
      );

  test('expense bare amount and title', () {
    final rows = parse('1500 lunch');
    expect(rows.length, 1);
    expect(rows.first.target, BulkImportTarget.personalExpense);
    expect(rows.first.amountMinor, 1500);
    expect(rows.first.title, 'lunch');
  });

  test('expense with date and category flags', () {
    final rows = parse('2200 groceries d:2025-11-10 cat:Food');
    expect(rows.single.categoryId, 'c1');
    expect(rows.single.dayLocal, DateTime(2025, 11, 10));
    expect(rows.single.title, 'groceries');
  });

  test('gain with plus sign', () {
    final rows = parse('+1200 salary');
    expect(rows.single.target, BulkImportTarget.personalGain);
    expect(rows.single.amountMinor, 1200);
  });

  test('gain with minus sign', () {
    final rows = parse('-500 refund');
    expect(rows.single.target, BulkImportTarget.personalGain);
  });

  test('wallet flag', () {
    final rows = parse('800 transport cat:Transport w:Bank');
    expect(rows.single.accountId, 'bank');
    expect(rows.single.categoryId, 'c2');
  });

  test('client debt', () {
    final rows = parse('@Ahmed +5000 cement');
    expect(rows.single.target, BulkImportTarget.clientDebt);
    expect(rows.single.clientId, 'cl1');
    expect(rows.single.title, 'cement');
    expect(rows.single.amountMinor, 5000);
  });

  test('client payment', () {
    final rows = parse('@Ahmed -2000 paid cash');
    expect(rows.single.target, BulkImportTarget.clientPayment);
    expect(rows.single.amountMinor, 2000);
  });

  test('client unsigned debt', () {
    final rows = parse('@Sara 3000 parts');
    expect(rows.single.target, BulkImportTarget.clientDebt);
    expect(rows.single.clientId, 'cl2');
  });

  test('skips comment and blank', () {
    final rows = parse('# November\n\n1500 lunch');
    expect(rows.length, 1);
  });

  test('unknown client is error', () {
    final rows = parse('@Nobody 100 x');
    expect(rows.single.status, BulkImportParseStatus.error);
  });
}
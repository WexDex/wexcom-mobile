import '../../../data/db/app_database.dart';
import '../../../data/ledger_repository.dart';
import '../../../data/ledger_types.dart';
import '../../../utils/money.dart';
import 'bulk_import_models.dart';
import 'client_name_resolver.dart';

/// Parsed flag values stripped from a line before amount/title extraction.
class _ParsedFlags {
  _ParsedFlags();

  DateTime? dayLocal;
  String? categoryName;
  String? walletName;
}

final _amountPattern = RegExp(r'([+-]?\d[\d\s.,]*\d|\d+)(?=\s|$)');

/// Parses multiline paste into draft rows.
List<BulkImportDraftLine> parseBulkImportText({
  required String text,
  required List<ExpenseCategory> expenseCategories,
  required List<ExpenseCategory> gainCategories,
  required List<Client> clients,
  required List<WalletAccount> walletAccounts,
  DateTime? defaultDay,
}) {
  final today = defaultDay ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final lines = text.split(RegExp(r'\r?\n'));
  final out = <BulkImportDraftLine>[];

  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;

    if (_isCommentLine(trimmed)) {
      continue;
    }

    final lineNo = i + 1;
  if (trimmed.startsWith('@')) {
      out.add(_parseClientLine(
        lineNo: lineNo,
        raw: raw,
        trimmed: trimmed,
        clients: clients,
        today: today,
      ));
    } else {
      out.add(_parsePersonalLine(
        lineNo: lineNo,
        raw: raw,
        trimmed: trimmed,
        expenseCategories: expenseCategories,
        gainCategories: gainCategories,
        walletAccounts: walletAccounts,
        today: today,
      ));
    }
  }
  return out;
}

bool _isCommentLine(String trimmed) {
  final startsComment = trimmed.startsWith('#') || trimmed.startsWith('//');
  if (!startsComment) return false;
  return !_lineHasSignedAmount(trimmed);
}

bool _lineHasSignedAmount(String line) {
  for (final m in _amountPattern.allMatches(line)) {
    final token = m.group(1)!.replaceAll(RegExp(r'[\s]'), '');
    final minor = MoneyFormat.parseMinorUnits(token, fractionDigits: 0);
    if (minor != null && minor != 0) return true;
  }
  return false;
}

_ParsedFlags _extractFlags(String line, DateTime today) {
  final flags = _ParsedFlags();
  var work = line;

  final flagRe = RegExp(
    r'\b(d|cat|w):(?:"([^"]+)"|(\S+))',
    caseSensitive: false,
  );
  for (final m in flagRe.allMatches(line)) {
    final key = m.group(1)!.toLowerCase();
    final value = (m.group(2) ?? m.group(3))!.trim();
    switch (key) {
      case 'd':
        final parsed = _parseFlagDate(value);
        if (parsed != null) flags.dayLocal = parsed;
      case 'cat':
        flags.categoryName = value;
      case 'w':
        flags.walletName = value;
    }
  }
  return flags;
}

DateTime? _parseFlagDate(String raw) {
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(raw);
  if (iso != null) {
    final y = int.parse(iso.group(1)!);
    final mo = int.parse(iso.group(2)!);
    final d = int.parse(iso.group(3)!);
    return DateTime(y, mo, d);
  }
  final dmy = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$').firstMatch(raw);
  if (dmy != null) {
    final d = int.parse(dmy.group(1)!);
    final mo = int.parse(dmy.group(2)!);
    final y = int.parse(dmy.group(3)!);
    return DateTime(y, mo, d);
  }
  return null;
}

BulkImportDraftLine _parsePersonalLine({
  required int lineNo,
  required String raw,
  required String trimmed,
  required List<ExpenseCategory> expenseCategories,
  required List<ExpenseCategory> gainCategories,
  required List<WalletAccount> walletAccounts,
  required DateTime today,
}) {
  final flags = _extractFlags(trimmed, today);
  var work = trimmed;
  work = work.replaceAll(RegExp(r'\b(d|cat|w):(?:"([^"]+)"|(\S+))', caseSensitive: false), ' ');
  work = work.replaceAll(RegExp(r'\s+'), ' ').trim();

  final amountMatch = _findAmountToken(work);
  final messages = <String>[];
  var status = BulkImportParseStatus.ok;

  if (amountMatch == null) {
    return BulkImportDraftLine(
      sourceLineNumber: lineNo,
      rawLine: raw,
      target: BulkImportTarget.personalExpense,
      title: work,
      amountMinor: 0,
      dayLocal: flags.dayLocal ?? today,
      status: BulkImportParseStatus.error,
      messages: const ['Could not find amount'],
    );
  }

  final amountToken = amountMatch.token;
  final signedMinor = MoneyFormat.parseMinorUnits(amountToken.replaceAll(' ', ''), fractionDigits: 0);
  if (signedMinor == null || signedMinor == 0) {
    return BulkImportDraftLine(
      sourceLineNumber: lineNo,
      rawLine: raw,
      target: BulkImportTarget.personalExpense,
      title: work,
      amountMinor: 0,
      dayLocal: flags.dayLocal ?? today,
      status: BulkImportParseStatus.error,
      messages: const ['Invalid amount'],
    );
  }

  BulkImportTarget target;
  int amountMinor;
  if (amountToken.startsWith('+') || amountToken.startsWith('-')) {
    target = BulkImportTarget.personalGain;
    amountMinor = signedMinor.abs();
  } else {
    target = BulkImportTarget.personalExpense;
    amountMinor = signedMinor.abs();
  }

  var title = work.substring(amountMatch.end).trim();
  if (title.isEmpty) {
    title = work.substring(0, amountMatch.start).trim();
  }
  if (title.isEmpty) title = target == BulkImportTarget.personalExpense ? 'Expense' : 'Gain';

  final day = flags.dayLocal ?? today;
  if (flags.dayLocal == null && trimmed.contains('d:')) {
    messages.add('Invalid date — using today');
    status = BulkImportParseStatus.warning;
  }

  String? categoryId;
  final cats = target == BulkImportTarget.personalExpense ? expenseCategories : gainCategories;
  if (flags.categoryName != null) {
    final cat = _matchCategory(flags.categoryName!, cats);
    if (cat != null) {
      categoryId = cat.id;
    } else {
      messages.add('Unknown category "${flags.categoryName}"');
      status = BulkImportParseStatus.warning;
    }
  }

  var accountId = kDefaultPocketAccountId;
  if (flags.walletName != null) {
    final acc = _matchWallet(flags.walletName!, walletAccounts);
    if (acc != null) {
      accountId = acc.id;
    } else {
      messages.add('Unknown wallet "${flags.walletName}" — using Pocket');
      status = BulkImportParseStatus.warning;
    }
  }

  return BulkImportDraftLine(
    sourceLineNumber: lineNo,
    rawLine: raw,
    target: target,
    title: title,
    amountMinor: amountMinor,
    dayLocal: day,
    categoryId: categoryId,
    accountId: accountId,
    status: status,
    messages: messages,
  );
}

class _AmountMatch {
  _AmountMatch({required this.token, required this.start, required this.end});
  final String token;
  final int start;
  final int end;
}

_AmountMatch? _findAmountToken(String work) {
  _AmountMatch? best;
  for (final m in _amountPattern.allMatches(work)) {
    final token = m.group(1)!;
    final normalized = token.replaceAll(RegExp(r'[\s]'), '');
    if (MoneyFormat.parseMinorUnits(normalized, fractionDigits: 0) == null) continue;
    best = _AmountMatch(token: normalized, start: m.start, end: m.end);
  }
  return best;
}

BulkImportDraftLine _parseClientLine({
  required int lineNo,
  required String raw,
  required String trimmed,
  required List<Client> clients,
  required DateTime today,
}) {
  final flags = _extractFlags(trimmed, today);
  var work = trimmed.substring(1).trim(); // after @

  work = work.replaceAll(RegExp(r'\b(d|cat|w):(?:"([^"]+)"|(\S+))', caseSensitive: false), ' ');
  work = work.replaceAll(RegExp(r'\s+'), ' ').trim();

  String clientQuery;
  String remainder;

  if (work.startsWith('"')) {
    final close = work.indexOf('"', 1);
    if (close > 0) {
      clientQuery = work.substring(1, close);
      remainder = work.substring(close + 1).trim();
    } else {
      clientQuery = work;
      remainder = '';
    }
  } else {
    final amountMatch = _findAmountToken(work);
    if (amountMatch == null) {
      return BulkImportDraftLine(
        sourceLineNumber: lineNo,
        rawLine: raw,
        target: BulkImportTarget.clientDebt,
        title: work,
        amountMinor: 0,
        dayLocal: flags.dayLocal ?? today,
        clientNameHint: work,
        status: BulkImportParseStatus.error,
        messages: const ['Could not find amount on client line'],
      );
    }
    clientQuery = work.substring(0, amountMatch.start).trim();
    remainder = work.substring(amountMatch.start).trim();
    work = remainder;
  }

  final amountMatch = _findAmountToken(work);
  final messages = <String>[];
  var status = BulkImportParseStatus.ok;

  if (amountMatch == null) {
    return BulkImportDraftLine(
      sourceLineNumber: lineNo,
      rawLine: raw,
      target: BulkImportTarget.clientDebt,
      title: '',
      amountMinor: 0,
      dayLocal: flags.dayLocal ?? today,
      clientNameHint: clientQuery,
      status: BulkImportParseStatus.error,
      messages: const ['Could not find amount'],
    );
  }

  final amountToken = amountMatch.token;
  final signedMinor = MoneyFormat.parseMinorUnits(amountToken, fractionDigits: 0);
  if (signedMinor == null || signedMinor == 0) {
    return BulkImportDraftLine(
      sourceLineNumber: lineNo,
      rawLine: raw,
      target: BulkImportTarget.clientDebt,
      title: '',
      amountMinor: 0,
      dayLocal: flags.dayLocal ?? today,
      clientNameHint: clientQuery,
      status: BulkImportParseStatus.error,
      messages: const ['Invalid amount'],
    );
  }

  BulkImportTarget target;
  if (amountToken.startsWith('-')) {
    target = BulkImportTarget.clientPayment;
  } else {
    target = BulkImportTarget.clientDebt;
  }
  final amountMinor = signedMinor.abs();

  var note = work.substring(amountMatch.end).trim();
  if (note.isEmpty) note = target == BulkImportTarget.clientDebt ? 'Debt' : 'Payment';

  final match = resolveClientName(clientQuery, clients);
  messages.addAll(match.messages);
  if (match.status == BulkImportClientMatchStatus.error) {
    status = BulkImportParseStatus.error;
  } else if (match.status == BulkImportClientMatchStatus.warning) {
    if (status == BulkImportParseStatus.ok) status = BulkImportParseStatus.warning;
  }

  if (flags.dayLocal == null && trimmed.contains('d:')) {
    messages.add('Invalid date — using today');
    if (status != BulkImportParseStatus.error) status = BulkImportParseStatus.warning;
  }

  return BulkImportDraftLine(
    sourceLineNumber: lineNo,
    rawLine: raw,
    target: target,
    title: note,
    amountMinor: amountMinor,
    dayLocal: flags.dayLocal ?? today,
    clientId: match.clientId,
    clientNameHint: clientQuery,
    status: status,
    messages: messages,
  );
}

ExpenseCategory? _matchCategory(String name, List<ExpenseCategory> cats) {
  final lower = name.toLowerCase();
  final exact = cats.where((c) => c.name.toLowerCase() == lower).toList();
  if (exact.length == 1) return exact.first;
  final partial = cats.where((c) => c.name.toLowerCase().contains(lower)).toList();
  if (partial.length == 1) return partial.first;
  return null;
}

WalletAccount? _matchWallet(String name, List<WalletAccount> accounts) {
  final lower = name.toLowerCase();
  for (final a in accounts) {
    if (a.id == kDefaultPocketAccountId && (lower == 'pocket' || lower == 'cash')) return a;
    if (a.name.toLowerCase() == lower) return a;
    if ('${a.emoji} ${a.name}'.toLowerCase().contains(lower)) return a;
    if (a.name.toLowerCase().contains(lower)) return a;
  }
  return null;
}

/// Maps draft target to repository enums.
PersonalFinanceKind personalKindFor(BulkImportTarget t) {
  return t == BulkImportTarget.personalGain
      ? PersonalFinanceKind.gain
      : PersonalFinanceKind.expense;
}

LedgerTxType ledgerTypeFor(BulkImportTarget t) {
  return t == BulkImportTarget.clientPayment ? LedgerTxType.payment : LedgerTxType.debt;
}
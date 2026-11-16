import '../../../data/ledger_repository.dart';

enum BulkImportTarget {
  personalExpense,
  personalGain,
  clientDebt,
  clientPayment,
}

enum BulkImportParseStatus {
  ok,
  warning,
  error,
}

/// One parsed line ready for preview / commit.
class BulkImportDraftLine {
  const BulkImportDraftLine({
    required this.sourceLineNumber,
    required this.rawLine,
    required this.target,
    required this.title,
    required this.amountMinor,
    required this.dayLocal,
    this.categoryId,
    this.accountId = kDefaultPocketAccountId,
    this.clientId,
    this.clientNameHint,
    this.status = BulkImportParseStatus.ok,
    this.messages = const [],
    this.skip = false,
  });

  final int sourceLineNumber;
  final String rawLine;
  final BulkImportTarget target;
  final String title;
  final int amountMinor;
  final DateTime dayLocal;
  final String? categoryId;
  final String accountId;
  final String? clientId;
  final String? clientNameHint;
  final BulkImportParseStatus status;
  final List<String> messages;

  /// Comment or blank — not shown in preview.
  final bool skip;

  bool get isClient =>
      target == BulkImportTarget.clientDebt || target == BulkImportTarget.clientPayment;

  bool get isPersonal =>
      target == BulkImportTarget.personalExpense || target == BulkImportTarget.personalGain;

  bool get canCommit => !skip && status != BulkImportParseStatus.error && amountMinor > 0;

  BulkImportDraftLine copyWith({
    BulkImportTarget? target,
    String? title,
    int? amountMinor,
    DateTime? dayLocal,
    String? categoryId,
    bool clearCategory = false,
    String? accountId,
    String? clientId,
    bool clearClient = false,
    String? clientNameHint,
    BulkImportParseStatus? status,
    List<String>? messages,
  }) {
    return BulkImportDraftLine(
      sourceLineNumber: sourceLineNumber,
      rawLine: rawLine,
      target: target ?? this.target,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      dayLocal: dayLocal ?? this.dayLocal,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: accountId ?? this.accountId,
      clientId: clearClient ? null : (clientId ?? this.clientId),
      clientNameHint: clientNameHint ?? this.clientNameHint,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      skip: skip,
    );
  }

  /// Recompute worst status from messages if needed.
  BulkImportDraftLine withMessages(List<String> msgs, BulkImportParseStatus st) {
    return copyWith(messages: msgs, status: st);
  }
}

/// Static preview row for More tab syntax panel.
class BulkImportSyntaxExample {
  const BulkImportSyntaxExample({
    required this.line,
    required this.previewLabel,
  });

  final String line;
  final String previewLabel;
}
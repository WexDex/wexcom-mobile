enum PersonalFinanceKind {
  expense,
  gain;

  static PersonalFinanceKind fromInt(int v) => PersonalFinanceKind.values[v];
}

enum LedgerTxType {
  debt,
  payment;

  static LedgerTxType fromInt(int v) => LedgerTxType.values[v];
}

enum LedgerTxStatus {
  active,
  cancelled;

  static LedgerTxStatus fromInt(int v) => LedgerTxStatus.values[v];
}

final class LedgerMath {
  LedgerMath._();

  static int apply(int balance, LedgerTxType type, int amountMinor) {
    switch (type) {
      case LedgerTxType.debt:
        return balance + amountMinor;
      case LedgerTxType.payment:
        return balance - amountMinor;
    }
  }
}

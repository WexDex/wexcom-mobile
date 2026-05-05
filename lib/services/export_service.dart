import 'package:flutter/material.dart';

import '../data/db/app_database.dart';
import '../data/ledger_repository.dart';
import '../data/ledger_types.dart';

class ExportService {
  String exportClientsCsv(
    List<Client> clients, {
    DateTimeRange? range,
  }) {
    final filtered = range == null
        ? clients
        : clients
              .where(
                (c) =>
                    !c.createdAt.isBefore(range.start) &&
                    !c.createdAt.isAfter(range.end),
              )
              .toList();
    final lines = <String>[
      'id,full_name,phone,note,balance_minor,created_at,last_interaction_at',
    ];
    for (final c in filtered) {
      lines.add(
        '${_csv(c.id)},${_csv(c.fullName)},${_csv(c.phone ?? '')},${_csv(c.note ?? '')},${c.balanceMinor},${_csv(c.createdAt.toIso8601String())},${_csv(c.lastInteractionAt?.toIso8601String() ?? '')}',
      );
    }
    return lines.join('\n');
  }

  String exportTransactionsCsv(
    List<LedgerTransactionWithClient> rows, {
    DateTimeRange? range,
  }) {
    final filtered = range == null
        ? rows
        : rows
              .where(
                (row) =>
                    !row.transaction.createdAt.isBefore(range.start) &&
                    !row.transaction.createdAt.isAfter(range.end),
              )
              .toList();
    final lines = <String>[
      'id,client_id,client_name,type,status,amount_minor,note,created_at',
    ];
    for (final row in filtered) {
      final tx = row.transaction;
      lines.add(
        '${_csv(tx.id)},${_csv(tx.clientId)},${_csv(row.clientName)},${_csv(LedgerTxType.fromInt(tx.txType).name)},${_csv(LedgerTxStatus.fromInt(tx.txStatus).name)},${tx.amountMinor},${_csv(tx.note ?? '')},${_csv(tx.createdAt.toIso8601String())}',
      );
    }
    return lines.join('\n');
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@TableIndex(name: 'idx_clients_archived_at', columns: {#archivedAt})
class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get externalRef => text().nullable()();
  TextColumn get tagsJson => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get lastInteractionAt => dateTime().nullable()();
  IntColumn get balanceMinor => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get colorHex => text().withDefault(const Constant('#4F46E5'))();
  TextColumn get scope => text()(); // client | transaction
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_client_tags_client', columns: {#clientId})
class ClientTags extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get tagId => text().references(Tags, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_transactions_client_created', columns: {#clientId, #createdAt})
class LedgerTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('DZD'))();
  TextColumn get createdBy => text().withDefault(const Constant('manual'))();
  TextColumn get channel => text().withDefault(const Constant('other'))();
  TextColumn get referenceNo => text().nullable()();
  DateTimeColumn get effectiveAt => dateTime().nullable()();
  IntColumn get attachmentsCount => integer().withDefault(const Constant(0))();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get settledAt => dateTime().nullable()();
  IntColumn get txType => integer()();
  IntColumn get txStatus => integer()();
  IntColumn get postedBalanceBeforeMinor => integer()();
  IntColumn get postedBalanceAfterMinor => integer()();
  IntColumn get cancelBalanceBeforeMinor => integer().nullable()();
  IntColumn get cancelBalanceAfterMinor => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_tx_tags_tx', columns: {#transactionId})
class TransactionTags extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(LedgerTransactions, #id)();
  TextColumn get tagId => text().references(Tags, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class QuickActionUsages extends Table {
  TextColumn get id => text()();
  IntColumn get txType => integer()();
  IntColumn get amountMinor => integer()();
  IntColumn get usesCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get defaultCurrencyCode => text().withDefault(const Constant('DZD'))();
  BoolColumn get contactsAutofillEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get overdueAlertDays => integer().withDefault(const Constant(10))();
  TextColumn get profileName => text().nullable()();
  BoolColumn get syncEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get syncServerUrl => text().nullable()();
  TextColumn get syncUsername => text().nullable()();
  TextColumn get syncPassword => text().nullable()();
  IntColumn get syncIntervalHours => integer().withDefault(const Constant(24))();
  BoolColumn get syncPeriodicEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUploadAt => dateTime().nullable()();
  TextColumn get lastUploadSha256 => text().nullable()();
  DateTimeColumn get lastDownloadAt => dateTime().nullable()();
  DateTimeColumn get lastServerOkAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Clients,
    Tags,
    ClientTags,
    LedgerTransactions,
    TransactionTags,
    QuickActionUsages,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await into(appSettings).insert(
            const AppSettingsCompanion(
              id: Value(1),
              defaultCurrencyCode: Value('DZD'),
              contactsAutofillEnabled: Value(true),
              overdueAlertDays: Value(10),
            ),
            mode: InsertMode.insertOrReplace,
          );
          await _insertDefaultTags();
        },
        onUpgrade: (Migrator m, from, to) async {
          if (from < 2) {
            await m.addColumn(clients, clients.externalRef);
            await m.addColumn(clients, clients.tagsJson);
            await m.addColumn(clients, clients.source);
            await m.addColumn(clients, clients.lastInteractionAt);

            await m.addColumn(ledgerTransactions, ledgerTransactions.createdBy);
            await m.addColumn(ledgerTransactions, ledgerTransactions.channel);
            await m.addColumn(ledgerTransactions, ledgerTransactions.referenceNo);
            await m.addColumn(ledgerTransactions, ledgerTransactions.effectiveAt);
            await m.addColumn(
              ledgerTransactions,
              ledgerTransactions.attachmentsCount,
            );

            await m.addColumn(
              appSettings,
              appSettings.contactsAutofillEnabled,
            );
            await m.addColumn(appSettings, appSettings.profileName);
          }
          if (from < 3) {
            await m.addColumn(ledgerTransactions, ledgerTransactions.isSettled);
            await m.addColumn(ledgerTransactions, ledgerTransactions.settledAt);
            await m.addColumn(appSettings, appSettings.overdueAlertDays);

            await m.createTable(tags);
            await m.createTable(clientTags);
            await m.createTable(transactionTags);
            await m.createTable(quickActionUsages);

            await customStatement(
              '''
              UPDATE app_settings
              SET overdue_alert_days = 10
              WHERE overdue_alert_days IS NULL OR overdue_alert_days <= 0;
              ''',
            );
            await customStatement(
              '''
              UPDATE clients
              SET last_interaction_at = (
                SELECT MAX(created_at)
                FROM ledger_transactions t
                WHERE t.client_id = clients.id
              )
              WHERE last_interaction_at IS NULL;
              ''',
            );
          }
          if (from < 4) {
            await _insertDefaultTags();
          }
          if (from < 5) {
            await m.addColumn(appSettings, appSettings.syncEnabled);
            await m.addColumn(appSettings, appSettings.syncServerUrl);
            await m.addColumn(appSettings, appSettings.syncUsername);
            await m.addColumn(appSettings, appSettings.syncPassword);
            await m.addColumn(appSettings, appSettings.syncIntervalHours);
            await m.addColumn(appSettings, appSettings.syncPeriodicEnabled);
            await m.addColumn(appSettings, appSettings.lastUploadAt);
            await m.addColumn(appSettings, appSettings.lastUploadSha256);
            await m.addColumn(appSettings, appSettings.lastDownloadAt);
            await m.addColumn(appSettings, appSettings.lastServerOkAt);
          }
        },
      );

  Future<void> _insertDefaultTags() async {
    final now = DateTime.now().toUtc();
    Future<void> insertIfMissing({
      required String name,
      required String scope,
      required String colorHex,
    }) async {
      final exists = await (select(tags)
            ..where((t) => t.name.equals(name) & t.scope.equals(scope))
            ..limit(1))
          .getSingleOrNull();
      if (exists != null) return;
      await into(tags).insert(
        TagsCompanion.insert(
          id: 'default-${scope.toLowerCase()}-${name.toLowerCase()}',
          name: name,
          colorHex: Value(colorHex),
          scope: scope,
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    await insertIfMissing(name: 'Friend', scope: 'client', colorHex: '#22C55E');
    await insertIfMissing(name: 'Jadarmi', scope: 'client', colorHex: '#3B82F6');
    await insertIfMissing(name: 'Family', scope: 'client', colorHex: '#A855F7');
    await insertIfMissing(name: 'Flexy', scope: 'transaction', colorHex: '#F59E0B');
    await insertIfMissing(name: 'Loan', scope: 'transaction', colorHex: '#EF4444');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'debt_ledger',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}

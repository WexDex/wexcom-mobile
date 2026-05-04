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
  IntColumn get balanceMinor => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_transactions_client_created', columns: {#clientId, #createdAt})
class LedgerTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('DZD'))();
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

@DataClassName('AppSetting')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get defaultCurrencyCode => text().withDefault(const Constant('DZD'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Clients, LedgerTransactions, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await into(appSettings).insert(
            const AppSettingsCompanion(
              id: Value(1),
              defaultCurrencyCode: Value('DZD'),
            ),
            mode: InsertMode.insertOrReplace,
          );
        },
      );

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

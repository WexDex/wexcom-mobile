// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _lastInteractionAtMeta = const VerificationMeta(
    'lastInteractionAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteractionAt =
      GeneratedColumn<DateTime>(
        'last_interaction_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    phone,
    note,
    externalRef,
    tagsJson,
    source,
    lastInteractionAt,
    balanceMinor,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('last_interaction_at')) {
      context.handle(
        _lastInteractionAtMeta,
        lastInteractionAt.isAcceptableOrUnknown(
          data['last_interaction_at']!,
          _lastInteractionAtMeta,
        ),
      );
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      lastInteractionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interaction_at'],
      ),
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String fullName;
  final String? phone;
  final String? note;
  final String? externalRef;
  final String? tagsJson;
  final String source;
  final DateTime? lastInteractionAt;
  final int balanceMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const Client({
    required this.id,
    required this.fullName,
    this.phone,
    this.note,
    this.externalRef,
    this.tagsJson,
    required this.source,
    this.lastInteractionAt,
    required this.balanceMinor,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || lastInteractionAt != null) {
      map['last_interaction_at'] = Variable<DateTime>(lastInteractionAt);
    }
    map['balance_minor'] = Variable<int>(balanceMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      source: Value(source),
      lastInteractionAt: lastInteractionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractionAt),
      balanceMinor: Value(balanceMinor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      note: serializer.fromJson<String?>(json['note']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      source: serializer.fromJson<String>(json['source']),
      lastInteractionAt: serializer.fromJson<DateTime?>(
        json['lastInteractionAt'],
      ),
      balanceMinor: serializer.fromJson<int>(json['balanceMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'note': serializer.toJson<String?>(note),
      'externalRef': serializer.toJson<String?>(externalRef),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'source': serializer.toJson<String>(source),
      'lastInteractionAt': serializer.toJson<DateTime?>(lastInteractionAt),
      'balanceMinor': serializer.toJson<int>(balanceMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Client copyWith({
    String? id,
    String? fullName,
    Value<String?> phone = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> externalRef = const Value.absent(),
    Value<String?> tagsJson = const Value.absent(),
    String? source,
    Value<DateTime?> lastInteractionAt = const Value.absent(),
    int? balanceMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Client(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    phone: phone.present ? phone.value : this.phone,
    note: note.present ? note.value : this.note,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
    tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
    source: source ?? this.source,
    lastInteractionAt: lastInteractionAt.present
        ? lastInteractionAt.value
        : this.lastInteractionAt,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      note: data.note.present ? data.note.value : this.note,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      source: data.source.present ? data.source.value : this.source,
      lastInteractionAt: data.lastInteractionAt.present
          ? data.lastInteractionAt.value
          : this.lastInteractionAt,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('note: $note, ')
          ..write('externalRef: $externalRef, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('source: $source, ')
          ..write('lastInteractionAt: $lastInteractionAt, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    phone,
    note,
    externalRef,
    tagsJson,
    source,
    lastInteractionAt,
    balanceMinor,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.note == this.note &&
          other.externalRef == this.externalRef &&
          other.tagsJson == this.tagsJson &&
          other.source == this.source &&
          other.lastInteractionAt == this.lastInteractionAt &&
          other.balanceMinor == this.balanceMinor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<String?> note;
  final Value<String?> externalRef;
  final Value<String?> tagsJson;
  final Value<String> source;
  final Value<DateTime?> lastInteractionAt;
  final Value<int> balanceMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.lastInteractionAt = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String fullName,
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.lastInteractionAt = const Value.absent(),
    required int balanceMinor,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName),
       balanceMinor = Value(balanceMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? note,
    Expression<String>? externalRef,
    Expression<String>? tagsJson,
    Expression<String>? source,
    Expression<DateTime>? lastInteractionAt,
    Expression<int>? balanceMinor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (note != null) 'note': note,
      if (externalRef != null) 'external_ref': externalRef,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (source != null) 'source': source,
      if (lastInteractionAt != null) 'last_interaction_at': lastInteractionAt,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String?>? phone,
    Value<String?>? note,
    Value<String?>? externalRef,
    Value<String?>? tagsJson,
    Value<String>? source,
    Value<DateTime?>? lastInteractionAt,
    Value<int>? balanceMinor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      externalRef: externalRef ?? this.externalRef,
      tagsJson: tagsJson ?? this.tagsJson,
      source: source ?? this.source,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lastInteractionAt.present) {
      map['last_interaction_at'] = Variable<DateTime>(lastInteractionAt.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('note: $note, ')
          ..write('externalRef: $externalRef, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('source: $source, ')
          ..write('lastInteractionAt: $lastInteractionAt, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#4F46E5'),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    scope,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String colorHex;
  final String scope;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.scope,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['scope'] = Variable<String>(scope);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      scope: Value(scope),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? scope,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    scope: scope ?? this.scope,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorHex, scope, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    required String scope,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       scope = Value(scope),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<String>? scope,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<String>? scope,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientTagsTable extends ClientTags
    with TableInfo<$ClientTagsTable, ClientTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, clientId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientTagsTable createAlias(String alias) {
    return $ClientTagsTable(attachedDatabase, alias);
  }
}

class ClientTag extends DataClass implements Insertable<ClientTag> {
  final String id;
  final String clientId;
  final String tagId;
  final DateTime createdAt;
  const ClientTag({
    required this.id,
    required this.clientId,
    required this.tagId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientTagsCompanion toCompanion(bool nullToAbsent) {
    return ClientTagsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory ClientTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientTag(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClientTag copyWith({
    String? id,
    String? clientId,
    String? tagId,
    DateTime? createdAt,
  }) => ClientTag(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    tagId: tagId ?? this.tagId,
    createdAt: createdAt ?? this.createdAt,
  );
  ClientTag copyWithCompanion(ClientTagsCompanion data) {
    return ClientTag(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientTag(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clientId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientTag &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class ClientTagsCompanion extends UpdateCompanion<ClientTag> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> tagId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ClientTagsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientTagsCompanion.insert({
    required String id,
    required String clientId,
    required String tagId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       tagId = Value(tagId),
       createdAt = Value(createdAt);
  static Insertable<ClientTag> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? tagId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? tagId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ClientTagsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientTagsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerTransactionsTable extends LedgerTransactions
    with TableInfo<$LedgerTransactionsTable, LedgerTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveAt = GeneratedColumn<DateTime>(
    'effective_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentsCountMeta = const VerificationMeta(
    'attachmentsCount',
  );
  @override
  late final GeneratedColumn<int> attachmentsCount = GeneratedColumn<int>(
    'attachments_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<int> txType = GeneratedColumn<int>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txStatusMeta = const VerificationMeta(
    'txStatus',
  );
  @override
  late final GeneratedColumn<int> txStatus = GeneratedColumn<int>(
    'tx_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postedBalanceBeforeMinorMeta =
      const VerificationMeta('postedBalanceBeforeMinor');
  @override
  late final GeneratedColumn<int> postedBalanceBeforeMinor =
      GeneratedColumn<int>(
        'posted_balance_before_minor',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _postedBalanceAfterMinorMeta =
      const VerificationMeta('postedBalanceAfterMinor');
  @override
  late final GeneratedColumn<int> postedBalanceAfterMinor =
      GeneratedColumn<int>(
        'posted_balance_after_minor',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cancelBalanceBeforeMinorMeta =
      const VerificationMeta('cancelBalanceBeforeMinor');
  @override
  late final GeneratedColumn<int> cancelBalanceBeforeMinor =
      GeneratedColumn<int>(
        'cancel_balance_before_minor',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cancelBalanceAfterMinorMeta =
      const VerificationMeta('cancelBalanceAfterMinor');
  @override
  late final GeneratedColumn<int> cancelBalanceAfterMinor =
      GeneratedColumn<int>(
        'cancel_balance_after_minor',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromCurrencyJsonMeta = const VerificationMeta(
    'fromCurrencyJson',
  );
  @override
  late final GeneratedColumn<String> fromCurrencyJson = GeneratedColumn<String>(
    'from_currency_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    amountMinor,
    currencyCode,
    createdBy,
    channel,
    referenceNo,
    effectiveAt,
    attachmentsCount,
    isSettled,
    settledAt,
    txType,
    txStatus,
    postedBalanceBeforeMinor,
    postedBalanceAfterMinor,
    cancelBalanceBeforeMinor,
    cancelBalanceAfterMinor,
    createdAt,
    updatedAt,
    cancelledAt,
    note,
    dueAt,
    fromCurrencyJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    }
    if (data.containsKey('attachments_count')) {
      context.handle(
        _attachmentsCountMeta,
        attachmentsCount.isAcceptableOrUnknown(
          data['attachments_count']!,
          _attachmentsCountMeta,
        ),
      );
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('tx_status')) {
      context.handle(
        _txStatusMeta,
        txStatus.isAcceptableOrUnknown(data['tx_status']!, _txStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_txStatusMeta);
    }
    if (data.containsKey('posted_balance_before_minor')) {
      context.handle(
        _postedBalanceBeforeMinorMeta,
        postedBalanceBeforeMinor.isAcceptableOrUnknown(
          data['posted_balance_before_minor']!,
          _postedBalanceBeforeMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postedBalanceBeforeMinorMeta);
    }
    if (data.containsKey('posted_balance_after_minor')) {
      context.handle(
        _postedBalanceAfterMinorMeta,
        postedBalanceAfterMinor.isAcceptableOrUnknown(
          data['posted_balance_after_minor']!,
          _postedBalanceAfterMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postedBalanceAfterMinorMeta);
    }
    if (data.containsKey('cancel_balance_before_minor')) {
      context.handle(
        _cancelBalanceBeforeMinorMeta,
        cancelBalanceBeforeMinor.isAcceptableOrUnknown(
          data['cancel_balance_before_minor']!,
          _cancelBalanceBeforeMinorMeta,
        ),
      );
    }
    if (data.containsKey('cancel_balance_after_minor')) {
      context.handle(
        _cancelBalanceAfterMinorMeta,
        cancelBalanceAfterMinor.isAcceptableOrUnknown(
          data['cancel_balance_after_minor']!,
          _cancelBalanceAfterMinorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('from_currency_json')) {
      context.handle(
        _fromCurrencyJsonMeta,
        fromCurrencyJson.isAcceptableOrUnknown(
          data['from_currency_json']!,
          _fromCurrencyJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_at'],
      ),
      attachmentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachments_count'],
      )!,
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_type'],
      )!,
      txStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_status'],
      )!,
      postedBalanceBeforeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}posted_balance_before_minor'],
      )!,
      postedBalanceAfterMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}posted_balance_after_minor'],
      )!,
      cancelBalanceBeforeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancel_balance_before_minor'],
      ),
      cancelBalanceAfterMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancel_balance_after_minor'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      fromCurrencyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_currency_json'],
      ),
    );
  }

  @override
  $LedgerTransactionsTable createAlias(String alias) {
    return $LedgerTransactionsTable(attachedDatabase, alias);
  }
}

class LedgerTransaction extends DataClass
    implements Insertable<LedgerTransaction> {
  final String id;
  final String clientId;
  final int amountMinor;
  final String currencyCode;
  final String createdBy;
  final String channel;
  final String? referenceNo;
  final DateTime? effectiveAt;
  final int attachmentsCount;
  final bool isSettled;
  final DateTime? settledAt;
  final int txType;
  final int txStatus;
  final int postedBalanceBeforeMinor;
  final int postedBalanceAfterMinor;
  final int? cancelBalanceBeforeMinor;
  final int? cancelBalanceAfterMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? note;
  final DateTime? dueAt;

  /// Optional JSON: { code, rate, amount } — foreign clarification; amountMinor stays default total.
  final String? fromCurrencyJson;
  const LedgerTransaction({
    required this.id,
    required this.clientId,
    required this.amountMinor,
    required this.currencyCode,
    required this.createdBy,
    required this.channel,
    this.referenceNo,
    this.effectiveAt,
    required this.attachmentsCount,
    required this.isSettled,
    this.settledAt,
    required this.txType,
    required this.txStatus,
    required this.postedBalanceBeforeMinor,
    required this.postedBalanceAfterMinor,
    this.cancelBalanceBeforeMinor,
    this.cancelBalanceAfterMinor,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.note,
    this.dueAt,
    this.fromCurrencyJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_by'] = Variable<String>(createdBy);
    map['channel'] = Variable<String>(channel);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || effectiveAt != null) {
      map['effective_at'] = Variable<DateTime>(effectiveAt);
    }
    map['attachments_count'] = Variable<int>(attachmentsCount);
    map['is_settled'] = Variable<bool>(isSettled);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    map['tx_type'] = Variable<int>(txType);
    map['tx_status'] = Variable<int>(txStatus);
    map['posted_balance_before_minor'] = Variable<int>(
      postedBalanceBeforeMinor,
    );
    map['posted_balance_after_minor'] = Variable<int>(postedBalanceAfterMinor);
    if (!nullToAbsent || cancelBalanceBeforeMinor != null) {
      map['cancel_balance_before_minor'] = Variable<int>(
        cancelBalanceBeforeMinor,
      );
    }
    if (!nullToAbsent || cancelBalanceAfterMinor != null) {
      map['cancel_balance_after_minor'] = Variable<int>(
        cancelBalanceAfterMinor,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || fromCurrencyJson != null) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson);
    }
    return map;
  }

  LedgerTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LedgerTransactionsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      createdBy: Value(createdBy),
      channel: Value(channel),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      effectiveAt: effectiveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveAt),
      attachmentsCount: Value(attachmentsCount),
      isSettled: Value(isSettled),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      txType: Value(txType),
      txStatus: Value(txStatus),
      postedBalanceBeforeMinor: Value(postedBalanceBeforeMinor),
      postedBalanceAfterMinor: Value(postedBalanceAfterMinor),
      cancelBalanceBeforeMinor: cancelBalanceBeforeMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelBalanceBeforeMinor),
      cancelBalanceAfterMinor: cancelBalanceAfterMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelBalanceAfterMinor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      fromCurrencyJson: fromCurrencyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCurrencyJson),
    );
  }

  factory LedgerTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerTransaction(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      channel: serializer.fromJson<String>(json['channel']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      effectiveAt: serializer.fromJson<DateTime?>(json['effectiveAt']),
      attachmentsCount: serializer.fromJson<int>(json['attachmentsCount']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      txType: serializer.fromJson<int>(json['txType']),
      txStatus: serializer.fromJson<int>(json['txStatus']),
      postedBalanceBeforeMinor: serializer.fromJson<int>(
        json['postedBalanceBeforeMinor'],
      ),
      postedBalanceAfterMinor: serializer.fromJson<int>(
        json['postedBalanceAfterMinor'],
      ),
      cancelBalanceBeforeMinor: serializer.fromJson<int?>(
        json['cancelBalanceBeforeMinor'],
      ),
      cancelBalanceAfterMinor: serializer.fromJson<int?>(
        json['cancelBalanceAfterMinor'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      note: serializer.fromJson<String?>(json['note']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      fromCurrencyJson: serializer.fromJson<String?>(json['fromCurrencyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdBy': serializer.toJson<String>(createdBy),
      'channel': serializer.toJson<String>(channel),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'effectiveAt': serializer.toJson<DateTime?>(effectiveAt),
      'attachmentsCount': serializer.toJson<int>(attachmentsCount),
      'isSettled': serializer.toJson<bool>(isSettled),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'txType': serializer.toJson<int>(txType),
      'txStatus': serializer.toJson<int>(txStatus),
      'postedBalanceBeforeMinor': serializer.toJson<int>(
        postedBalanceBeforeMinor,
      ),
      'postedBalanceAfterMinor': serializer.toJson<int>(
        postedBalanceAfterMinor,
      ),
      'cancelBalanceBeforeMinor': serializer.toJson<int?>(
        cancelBalanceBeforeMinor,
      ),
      'cancelBalanceAfterMinor': serializer.toJson<int?>(
        cancelBalanceAfterMinor,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'note': serializer.toJson<String?>(note),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'fromCurrencyJson': serializer.toJson<String?>(fromCurrencyJson),
    };
  }

  LedgerTransaction copyWith({
    String? id,
    String? clientId,
    int? amountMinor,
    String? currencyCode,
    String? createdBy,
    String? channel,
    Value<String?> referenceNo = const Value.absent(),
    Value<DateTime?> effectiveAt = const Value.absent(),
    int? attachmentsCount,
    bool? isSettled,
    Value<DateTime?> settledAt = const Value.absent(),
    int? txType,
    int? txStatus,
    int? postedBalanceBeforeMinor,
    int? postedBalanceAfterMinor,
    Value<int?> cancelBalanceBeforeMinor = const Value.absent(),
    Value<int?> cancelBalanceAfterMinor = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<DateTime?> dueAt = const Value.absent(),
    Value<String?> fromCurrencyJson = const Value.absent(),
  }) => LedgerTransaction(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    createdBy: createdBy ?? this.createdBy,
    channel: channel ?? this.channel,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    effectiveAt: effectiveAt.present ? effectiveAt.value : this.effectiveAt,
    attachmentsCount: attachmentsCount ?? this.attachmentsCount,
    isSettled: isSettled ?? this.isSettled,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    txType: txType ?? this.txType,
    txStatus: txStatus ?? this.txStatus,
    postedBalanceBeforeMinor:
        postedBalanceBeforeMinor ?? this.postedBalanceBeforeMinor,
    postedBalanceAfterMinor:
        postedBalanceAfterMinor ?? this.postedBalanceAfterMinor,
    cancelBalanceBeforeMinor: cancelBalanceBeforeMinor.present
        ? cancelBalanceBeforeMinor.value
        : this.cancelBalanceBeforeMinor,
    cancelBalanceAfterMinor: cancelBalanceAfterMinor.present
        ? cancelBalanceAfterMinor.value
        : this.cancelBalanceAfterMinor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    note: note.present ? note.value : this.note,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    fromCurrencyJson: fromCurrencyJson.present
        ? fromCurrencyJson.value
        : this.fromCurrencyJson,
  );
  LedgerTransaction copyWithCompanion(LedgerTransactionsCompanion data) {
    return LedgerTransaction(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      channel: data.channel.present ? data.channel.value : this.channel,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      attachmentsCount: data.attachmentsCount.present
          ? data.attachmentsCount.value
          : this.attachmentsCount,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      txType: data.txType.present ? data.txType.value : this.txType,
      txStatus: data.txStatus.present ? data.txStatus.value : this.txStatus,
      postedBalanceBeforeMinor: data.postedBalanceBeforeMinor.present
          ? data.postedBalanceBeforeMinor.value
          : this.postedBalanceBeforeMinor,
      postedBalanceAfterMinor: data.postedBalanceAfterMinor.present
          ? data.postedBalanceAfterMinor.value
          : this.postedBalanceAfterMinor,
      cancelBalanceBeforeMinor: data.cancelBalanceBeforeMinor.present
          ? data.cancelBalanceBeforeMinor.value
          : this.cancelBalanceBeforeMinor,
      cancelBalanceAfterMinor: data.cancelBalanceAfterMinor.present
          ? data.cancelBalanceAfterMinor.value
          : this.cancelBalanceAfterMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      note: data.note.present ? data.note.value : this.note,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      fromCurrencyJson: data.fromCurrencyJson.present
          ? data.fromCurrencyJson.value
          : this.fromCurrencyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransaction(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdBy: $createdBy, ')
          ..write('channel: $channel, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('attachmentsCount: $attachmentsCount, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAt: $settledAt, ')
          ..write('txType: $txType, ')
          ..write('txStatus: $txStatus, ')
          ..write('postedBalanceBeforeMinor: $postedBalanceBeforeMinor, ')
          ..write('postedBalanceAfterMinor: $postedBalanceAfterMinor, ')
          ..write('cancelBalanceBeforeMinor: $cancelBalanceBeforeMinor, ')
          ..write('cancelBalanceAfterMinor: $cancelBalanceAfterMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('note: $note, ')
          ..write('dueAt: $dueAt, ')
          ..write('fromCurrencyJson: $fromCurrencyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientId,
    amountMinor,
    currencyCode,
    createdBy,
    channel,
    referenceNo,
    effectiveAt,
    attachmentsCount,
    isSettled,
    settledAt,
    txType,
    txStatus,
    postedBalanceBeforeMinor,
    postedBalanceAfterMinor,
    cancelBalanceBeforeMinor,
    cancelBalanceAfterMinor,
    createdAt,
    updatedAt,
    cancelledAt,
    note,
    dueAt,
    fromCurrencyJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerTransaction &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.createdBy == this.createdBy &&
          other.channel == this.channel &&
          other.referenceNo == this.referenceNo &&
          other.effectiveAt == this.effectiveAt &&
          other.attachmentsCount == this.attachmentsCount &&
          other.isSettled == this.isSettled &&
          other.settledAt == this.settledAt &&
          other.txType == this.txType &&
          other.txStatus == this.txStatus &&
          other.postedBalanceBeforeMinor == this.postedBalanceBeforeMinor &&
          other.postedBalanceAfterMinor == this.postedBalanceAfterMinor &&
          other.cancelBalanceBeforeMinor == this.cancelBalanceBeforeMinor &&
          other.cancelBalanceAfterMinor == this.cancelBalanceAfterMinor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.note == this.note &&
          other.dueAt == this.dueAt &&
          other.fromCurrencyJson == this.fromCurrencyJson);
}

class LedgerTransactionsCompanion extends UpdateCompanion<LedgerTransaction> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> createdBy;
  final Value<String> channel;
  final Value<String?> referenceNo;
  final Value<DateTime?> effectiveAt;
  final Value<int> attachmentsCount;
  final Value<bool> isSettled;
  final Value<DateTime?> settledAt;
  final Value<int> txType;
  final Value<int> txStatus;
  final Value<int> postedBalanceBeforeMinor;
  final Value<int> postedBalanceAfterMinor;
  final Value<int?> cancelBalanceBeforeMinor;
  final Value<int?> cancelBalanceAfterMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> cancelledAt;
  final Value<String?> note;
  final Value<DateTime?> dueAt;
  final Value<String?> fromCurrencyJson;
  final Value<int> rowid;
  const LedgerTransactionsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.channel = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.attachmentsCount = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.txType = const Value.absent(),
    this.txStatus = const Value.absent(),
    this.postedBalanceBeforeMinor = const Value.absent(),
    this.postedBalanceAfterMinor = const Value.absent(),
    this.cancelBalanceBeforeMinor = const Value.absent(),
    this.cancelBalanceAfterMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.note = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerTransactionsCompanion.insert({
    required String id,
    required String clientId,
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.channel = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.attachmentsCount = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAt = const Value.absent(),
    required int txType,
    required int txStatus,
    required int postedBalanceBeforeMinor,
    required int postedBalanceAfterMinor,
    this.cancelBalanceBeforeMinor = const Value.absent(),
    this.cancelBalanceAfterMinor = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.cancelledAt = const Value.absent(),
    this.note = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       amountMinor = Value(amountMinor),
       txType = Value(txType),
       txStatus = Value(txStatus),
       postedBalanceBeforeMinor = Value(postedBalanceBeforeMinor),
       postedBalanceAfterMinor = Value(postedBalanceAfterMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LedgerTransaction> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? createdBy,
    Expression<String>? channel,
    Expression<String>? referenceNo,
    Expression<DateTime>? effectiveAt,
    Expression<int>? attachmentsCount,
    Expression<bool>? isSettled,
    Expression<DateTime>? settledAt,
    Expression<int>? txType,
    Expression<int>? txStatus,
    Expression<int>? postedBalanceBeforeMinor,
    Expression<int>? postedBalanceAfterMinor,
    Expression<int>? cancelBalanceBeforeMinor,
    Expression<int>? cancelBalanceAfterMinor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cancelledAt,
    Expression<String>? note,
    Expression<DateTime>? dueAt,
    Expression<String>? fromCurrencyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdBy != null) 'created_by': createdBy,
      if (channel != null) 'channel': channel,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (attachmentsCount != null) 'attachments_count': attachmentsCount,
      if (isSettled != null) 'is_settled': isSettled,
      if (settledAt != null) 'settled_at': settledAt,
      if (txType != null) 'tx_type': txType,
      if (txStatus != null) 'tx_status': txStatus,
      if (postedBalanceBeforeMinor != null)
        'posted_balance_before_minor': postedBalanceBeforeMinor,
      if (postedBalanceAfterMinor != null)
        'posted_balance_after_minor': postedBalanceAfterMinor,
      if (cancelBalanceBeforeMinor != null)
        'cancel_balance_before_minor': cancelBalanceBeforeMinor,
      if (cancelBalanceAfterMinor != null)
        'cancel_balance_after_minor': cancelBalanceAfterMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (note != null) 'note': note,
      if (dueAt != null) 'due_at': dueAt,
      if (fromCurrencyJson != null) 'from_currency_json': fromCurrencyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? createdBy,
    Value<String>? channel,
    Value<String?>? referenceNo,
    Value<DateTime?>? effectiveAt,
    Value<int>? attachmentsCount,
    Value<bool>? isSettled,
    Value<DateTime?>? settledAt,
    Value<int>? txType,
    Value<int>? txStatus,
    Value<int>? postedBalanceBeforeMinor,
    Value<int>? postedBalanceAfterMinor,
    Value<int?>? cancelBalanceBeforeMinor,
    Value<int?>? cancelBalanceAfterMinor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? cancelledAt,
    Value<String?>? note,
    Value<DateTime?>? dueAt,
    Value<String?>? fromCurrencyJson,
    Value<int>? rowid,
  }) {
    return LedgerTransactionsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      createdBy: createdBy ?? this.createdBy,
      channel: channel ?? this.channel,
      referenceNo: referenceNo ?? this.referenceNo,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      attachmentsCount: attachmentsCount ?? this.attachmentsCount,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      txType: txType ?? this.txType,
      txStatus: txStatus ?? this.txStatus,
      postedBalanceBeforeMinor:
          postedBalanceBeforeMinor ?? this.postedBalanceBeforeMinor,
      postedBalanceAfterMinor:
          postedBalanceAfterMinor ?? this.postedBalanceAfterMinor,
      cancelBalanceBeforeMinor:
          cancelBalanceBeforeMinor ?? this.cancelBalanceBeforeMinor,
      cancelBalanceAfterMinor:
          cancelBalanceAfterMinor ?? this.cancelBalanceAfterMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      fromCurrencyJson: fromCurrencyJson ?? this.fromCurrencyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<DateTime>(effectiveAt.value);
    }
    if (attachmentsCount.present) {
      map['attachments_count'] = Variable<int>(attachmentsCount.value);
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<int>(txType.value);
    }
    if (txStatus.present) {
      map['tx_status'] = Variable<int>(txStatus.value);
    }
    if (postedBalanceBeforeMinor.present) {
      map['posted_balance_before_minor'] = Variable<int>(
        postedBalanceBeforeMinor.value,
      );
    }
    if (postedBalanceAfterMinor.present) {
      map['posted_balance_after_minor'] = Variable<int>(
        postedBalanceAfterMinor.value,
      );
    }
    if (cancelBalanceBeforeMinor.present) {
      map['cancel_balance_before_minor'] = Variable<int>(
        cancelBalanceBeforeMinor.value,
      );
    }
    if (cancelBalanceAfterMinor.present) {
      map['cancel_balance_after_minor'] = Variable<int>(
        cancelBalanceAfterMinor.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (fromCurrencyJson.present) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdBy: $createdBy, ')
          ..write('channel: $channel, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('attachmentsCount: $attachmentsCount, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAt: $settledAt, ')
          ..write('txType: $txType, ')
          ..write('txStatus: $txStatus, ')
          ..write('postedBalanceBeforeMinor: $postedBalanceBeforeMinor, ')
          ..write('postedBalanceAfterMinor: $postedBalanceAfterMinor, ')
          ..write('cancelBalanceBeforeMinor: $cancelBalanceBeforeMinor, ')
          ..write('cancelBalanceAfterMinor: $cancelBalanceAfterMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('note: $note, ')
          ..write('dueAt: $dueAt, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledger_transactions (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTag extends DataClass implements Insertable<TransactionTag> {
  final String id;
  final String transactionId;
  final String tagId;
  final DateTime createdAt;
  const TransactionTag({
    required this.id,
    required this.transactionId,
    required this.tagId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTag(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionTag copyWith({
    String? id,
    String? transactionId,
    String? tagId,
    DateTime? createdAt,
  }) => TransactionTag(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    tagId: tagId ?? this.tagId,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionTag copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTag(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTag(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTag &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTag> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> tagId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required String id,
    required String transactionId,
    required String tagId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       tagId = Value(tagId),
       createdAt = Value(createdAt);
  static Insertable<TransactionTag> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? tagId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? tagId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionTagsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickActionUsagesTable extends QuickActionUsages
    with TableInfo<$QuickActionUsagesTable, QuickActionUsage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickActionUsagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<int> txType = GeneratedColumn<int>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usesCountMeta = const VerificationMeta(
    'usesCount',
  );
  @override
  late final GeneratedColumn<int> usesCount = GeneratedColumn<int>(
    'uses_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    txType,
    amountMinor,
    usesCount,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_action_usages';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickActionUsage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('uses_count')) {
      context.handle(
        _usesCountMeta,
        usesCount.isAcceptableOrUnknown(data['uses_count']!, _usesCountMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickActionUsage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickActionUsage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      usesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uses_count'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $QuickActionUsagesTable createAlias(String alias) {
    return $QuickActionUsagesTable(attachedDatabase, alias);
  }
}

class QuickActionUsage extends DataClass
    implements Insertable<QuickActionUsage> {
  final String id;
  final int txType;
  final int amountMinor;
  final int usesCount;
  final DateTime lastUsedAt;
  const QuickActionUsage({
    required this.id,
    required this.txType,
    required this.amountMinor,
    required this.usesCount,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tx_type'] = Variable<int>(txType);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['uses_count'] = Variable<int>(usesCount);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  QuickActionUsagesCompanion toCompanion(bool nullToAbsent) {
    return QuickActionUsagesCompanion(
      id: Value(id),
      txType: Value(txType),
      amountMinor: Value(amountMinor),
      usesCount: Value(usesCount),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory QuickActionUsage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickActionUsage(
      id: serializer.fromJson<String>(json['id']),
      txType: serializer.fromJson<int>(json['txType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      usesCount: serializer.fromJson<int>(json['usesCount']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'txType': serializer.toJson<int>(txType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'usesCount': serializer.toJson<int>(usesCount),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  QuickActionUsage copyWith({
    String? id,
    int? txType,
    int? amountMinor,
    int? usesCount,
    DateTime? lastUsedAt,
  }) => QuickActionUsage(
    id: id ?? this.id,
    txType: txType ?? this.txType,
    amountMinor: amountMinor ?? this.amountMinor,
    usesCount: usesCount ?? this.usesCount,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  QuickActionUsage copyWithCompanion(QuickActionUsagesCompanion data) {
    return QuickActionUsage(
      id: data.id.present ? data.id.value : this.id,
      txType: data.txType.present ? data.txType.value : this.txType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      usesCount: data.usesCount.present ? data.usesCount.value : this.usesCount,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickActionUsage(')
          ..write('id: $id, ')
          ..write('txType: $txType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('usesCount: $usesCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, txType, amountMinor, usesCount, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickActionUsage &&
          other.id == this.id &&
          other.txType == this.txType &&
          other.amountMinor == this.amountMinor &&
          other.usesCount == this.usesCount &&
          other.lastUsedAt == this.lastUsedAt);
}

class QuickActionUsagesCompanion extends UpdateCompanion<QuickActionUsage> {
  final Value<String> id;
  final Value<int> txType;
  final Value<int> amountMinor;
  final Value<int> usesCount;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const QuickActionUsagesCompanion({
    this.id = const Value.absent(),
    this.txType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.usesCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuickActionUsagesCompanion.insert({
    required String id,
    required int txType,
    required int amountMinor,
    this.usesCount = const Value.absent(),
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       txType = Value(txType),
       amountMinor = Value(amountMinor),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<QuickActionUsage> custom({
    Expression<String>? id,
    Expression<int>? txType,
    Expression<int>? amountMinor,
    Expression<int>? usesCount,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (txType != null) 'tx_type': txType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (usesCount != null) 'uses_count': usesCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuickActionUsagesCompanion copyWith({
    Value<String>? id,
    Value<int>? txType,
    Value<int>? amountMinor,
    Value<int>? usesCount,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return QuickActionUsagesCompanion(
      id: id ?? this.id,
      txType: txType ?? this.txType,
      amountMinor: amountMinor ?? this.amountMinor,
      usesCount: usesCount ?? this.usesCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<int>(txType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (usesCount.present) {
      map['uses_count'] = Variable<int>(usesCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickActionUsagesCompanion(')
          ..write('id: $id, ')
          ..write('txType: $txType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('usesCount: $usesCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletAccountsTable extends WalletAccounts
    with TableInfo<$WalletAccountsTable, WalletAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('💵'),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    currencyCode,
    balanceMinor,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WalletAccountsTable createAlias(String alias) {
    return $WalletAccountsTable(attachedDatabase, alias);
  }
}

class WalletAccount extends DataClass implements Insertable<WalletAccount> {
  final String id;
  final String name;
  final String emoji;
  final String currencyCode;
  final int balanceMinor;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WalletAccount({
    required this.id,
    required this.name,
    required this.emoji,
    required this.currencyCode,
    required this.balanceMinor,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['currency_code'] = Variable<String>(currencyCode);
    map['balance_minor'] = Variable<int>(balanceMinor);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WalletAccountsCompanion toCompanion(bool nullToAbsent) {
    return WalletAccountsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      currencyCode: Value(currencyCode),
      balanceMinor: Value(balanceMinor),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WalletAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletAccount(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      balanceMinor: serializer.fromJson<int>(json['balanceMinor']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'balanceMinor': serializer.toJson<int>(balanceMinor),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WalletAccount copyWith({
    String? id,
    String? name,
    String? emoji,
    String? currencyCode,
    int? balanceMinor,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WalletAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    currencyCode: currencyCode ?? this.currencyCode,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WalletAccount copyWithCompanion(WalletAccountsCompanion data) {
    return WalletAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletAccount(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    currencyCode,
    balanceMinor,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletAccount &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.currencyCode == this.currencyCode &&
          other.balanceMinor == this.balanceMinor &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WalletAccountsCompanion extends UpdateCompanion<WalletAccount> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> currencyCode;
  final Value<int> balanceMinor;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WalletAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletAccountsCompanion.insert({
    required String id,
    required String name,
    this.emoji = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WalletAccount> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? currencyCode,
    Expression<int>? balanceMinor,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<String>? currencyCode,
    Value<int>? balanceMinor,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WalletAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalFinanceEntriesTable extends PersonalFinanceEntries
    with TableInfo<$PersonalFinanceEntriesTable, PersonalFinanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalFinanceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallet_accounts (id)',
    ),
  );
  static const VerificationMeta _fromCurrencyJsonMeta = const VerificationMeta(
    'fromCurrencyJson',
  );
  @override
  late final GeneratedColumn<String> fromCurrencyJson = GeneratedColumn<String>(
    'from_currency_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    amountMinor,
    currencyCode,
    note,
    categoryId,
    accountId,
    fromCurrencyJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_finance_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalFinanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('from_currency_json')) {
      context.handle(
        _fromCurrencyJsonMeta,
        fromCurrencyJson.isAcceptableOrUnknown(
          data['from_currency_json']!,
          _fromCurrencyJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalFinanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalFinanceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      fromCurrencyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_currency_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PersonalFinanceEntriesTable createAlias(String alias) {
    return $PersonalFinanceEntriesTable(attachedDatabase, alias);
  }
}

class PersonalFinanceEntry extends DataClass
    implements Insertable<PersonalFinanceEntry> {
  final String id;

  /// 0 = expense, 1 = gain
  final int kind;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String? note;

  /// FK to ExpenseCategories (nullable — pre-existing entries have no category)
  final String? categoryId;

  /// FK to WalletAccounts — null treated as Pocket (`wallet-cash`) in UI
  final String? accountId;
  final String? fromCurrencyJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonalFinanceEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    this.note,
    this.categoryId,
    this.accountId,
    this.fromCurrencyJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<int>(kind);
    map['title'] = Variable<String>(title);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || fromCurrencyJson != null) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonalFinanceEntriesCompanion toCompanion(bool nullToAbsent) {
    return PersonalFinanceEntriesCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      fromCurrencyJson: fromCurrencyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCurrencyJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonalFinanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalFinanceEntry(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<int>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      note: serializer.fromJson<String?>(json['note']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      fromCurrencyJson: serializer.fromJson<String?>(json['fromCurrencyJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<int>(kind),
      'title': serializer.toJson<String>(title),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'note': serializer.toJson<String?>(note),
      'categoryId': serializer.toJson<String?>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'fromCurrencyJson': serializer.toJson<String?>(fromCurrencyJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonalFinanceEntry copyWith({
    String? id,
    int? kind,
    String? title,
    int? amountMinor,
    String? currencyCode,
    Value<String?> note = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<String?> fromCurrencyJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonalFinanceEntry(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    note: note.present ? note.value : this.note,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    fromCurrencyJson: fromCurrencyJson.present
        ? fromCurrencyJson.value
        : this.fromCurrencyJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PersonalFinanceEntry copyWithCompanion(PersonalFinanceEntriesCompanion data) {
    return PersonalFinanceEntry(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      note: data.note.present ? data.note.value : this.note,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fromCurrencyJson: data.fromCurrencyJson.present
          ? data.fromCurrencyJson.value
          : this.fromCurrencyJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalFinanceEntry(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    amountMinor,
    currencyCode,
    note,
    categoryId,
    accountId,
    fromCurrencyJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalFinanceEntry &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.note == this.note &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.fromCurrencyJson == this.fromCurrencyJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonalFinanceEntriesCompanion
    extends UpdateCompanion<PersonalFinanceEntry> {
  final Value<String> id;
  final Value<int> kind;
  final Value<String> title;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> note;
  final Value<String?> categoryId;
  final Value<String?> accountId;
  final Value<String?> fromCurrencyJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonalFinanceEntriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalFinanceEntriesCompanion.insert({
    required String id,
    required int kind,
    required String title,
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       amountMinor = Value(amountMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonalFinanceEntry> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<String>? title,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? note,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? fromCurrencyJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (note != null) 'note': note,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (fromCurrencyJson != null) 'from_currency_json': fromCurrencyJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalFinanceEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? kind,
    Value<String>? title,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String?>? note,
    Value<String?>? categoryId,
    Value<String?>? accountId,
    Value<String?>? fromCurrencyJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PersonalFinanceEntriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      fromCurrencyJson: fromCurrencyJson ?? this.fromCurrencyJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (fromCurrencyJson.present) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalFinanceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalFinanceFavoritesTable extends PersonalFinanceFavorites
    with TableInfo<$PersonalFinanceFavoritesTable, PersonalFinanceFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalFinanceFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallet_accounts (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    label,
    amountMinor,
    categoryId,
    accountId,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_finance_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalFinanceFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalFinanceFavorite map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalFinanceFavorite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonalFinanceFavoritesTable createAlias(String alias) {
    return $PersonalFinanceFavoritesTable(attachedDatabase, alias);
  }
}

class PersonalFinanceFavorite extends DataClass
    implements Insertable<PersonalFinanceFavorite> {
  final String id;

  /// 0 = expense, 1 = gain
  final int kind;
  final String label;
  final int amountMinor;
  final String? categoryId;
  final String? accountId;
  final int sortOrder;
  final DateTime createdAt;
  const PersonalFinanceFavorite({
    required this.id,
    required this.kind,
    required this.label,
    required this.amountMinor,
    this.categoryId,
    this.accountId,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<int>(kind);
    map['label'] = Variable<String>(label);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonalFinanceFavoritesCompanion toCompanion(bool nullToAbsent) {
    return PersonalFinanceFavoritesCompanion(
      id: Value(id),
      kind: Value(kind),
      label: Value(label),
      amountMinor: Value(amountMinor),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory PersonalFinanceFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalFinanceFavorite(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<int>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<int>(kind),
      'label': serializer.toJson<String>(label),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'categoryId': serializer.toJson<String?>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonalFinanceFavorite copyWith({
    String? id,
    int? kind,
    String? label,
    int? amountMinor,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => PersonalFinanceFavorite(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    amountMinor: amountMinor ?? this.amountMinor,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonalFinanceFavorite copyWithCompanion(
    PersonalFinanceFavoritesCompanion data,
  ) {
    return PersonalFinanceFavorite(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalFinanceFavorite(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    label,
    amountMinor,
    categoryId,
    accountId,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalFinanceFavorite &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.amountMinor == this.amountMinor &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class PersonalFinanceFavoritesCompanion
    extends UpdateCompanion<PersonalFinanceFavorite> {
  final Value<String> id;
  final Value<int> kind;
  final Value<String> label;
  final Value<int> amountMinor;
  final Value<String?> categoryId;
  final Value<String?> accountId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PersonalFinanceFavoritesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalFinanceFavoritesCompanion.insert({
    required String id,
    required int kind,
    required String label,
    required int amountMinor,
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label),
       amountMinor = Value(amountMinor),
       createdAt = Value(createdAt);
  static Insertable<PersonalFinanceFavorite> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<String>? label,
    Expression<int>? amountMinor,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalFinanceFavoritesCompanion copyWith({
    Value<String>? id,
    Value<int>? kind,
    Value<String>? label,
    Value<int>? amountMinor,
    Value<String?>? categoryId,
    Value<String?>? accountId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PersonalFinanceFavoritesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalFinanceFavoritesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultCurrencyCodeMeta =
      const VerificationMeta('defaultCurrencyCode');
  @override
  late final GeneratedColumn<String> defaultCurrencyCode =
      GeneratedColumn<String>(
        'default_currency_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('DZD'),
      );
  static const VerificationMeta _contactsAutofillEnabledMeta =
      const VerificationMeta('contactsAutofillEnabled');
  @override
  late final GeneratedColumn<bool> contactsAutofillEnabled =
      GeneratedColumn<bool>(
        'contacts_autofill_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("contacts_autofill_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _overdueAlertDaysMeta = const VerificationMeta(
    'overdueAlertDays',
  );
  @override
  late final GeneratedColumn<int> overdueAlertDays = GeneratedColumn<int>(
    'overdue_alert_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _profileNameMeta = const VerificationMeta(
    'profileName',
  );
  @override
  late final GeneratedColumn<String> profileName = GeneratedColumn<String>(
    'profile_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncEnabledMeta = const VerificationMeta(
    'syncEnabled',
  );
  @override
  late final GeneratedColumn<bool> syncEnabled = GeneratedColumn<bool>(
    'sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncServerUrlMeta = const VerificationMeta(
    'syncServerUrl',
  );
  @override
  late final GeneratedColumn<String> syncServerUrl = GeneratedColumn<String>(
    'sync_server_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncUsernameMeta = const VerificationMeta(
    'syncUsername',
  );
  @override
  late final GeneratedColumn<String> syncUsername = GeneratedColumn<String>(
    'sync_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncPasswordMeta = const VerificationMeta(
    'syncPassword',
  );
  @override
  late final GeneratedColumn<String> syncPassword = GeneratedColumn<String>(
    'sync_password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncIntervalHoursMeta = const VerificationMeta(
    'syncIntervalHours',
  );
  @override
  late final GeneratedColumn<int> syncIntervalHours = GeneratedColumn<int>(
    'sync_interval_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(24),
  );
  static const VerificationMeta _syncPeriodicEnabledMeta =
      const VerificationMeta('syncPeriodicEnabled');
  @override
  late final GeneratedColumn<bool> syncPeriodicEnabled = GeneratedColumn<bool>(
    'sync_periodic_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_periodic_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUploadAtMeta = const VerificationMeta(
    'lastUploadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUploadAt = GeneratedColumn<DateTime>(
    'last_upload_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUploadSha256Meta = const VerificationMeta(
    'lastUploadSha256',
  );
  @override
  late final GeneratedColumn<String> lastUploadSha256 = GeneratedColumn<String>(
    'last_upload_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDownloadAtMeta = const VerificationMeta(
    'lastDownloadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDownloadAt =
      GeneratedColumn<DateTime>(
        'last_download_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastServerOkAtMeta = const VerificationMeta(
    'lastServerOkAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastServerOkAt =
      GeneratedColumn<DateTime>(
        'last_server_ok_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notifOverdueEnabledMeta =
      const VerificationMeta('notifOverdueEnabled');
  @override
  late final GeneratedColumn<bool> notifOverdueEnabled = GeneratedColumn<bool>(
    'notif_overdue_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notif_overdue_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notifOverdueHourMeta = const VerificationMeta(
    'notifOverdueHour',
  );
  @override
  late final GeneratedColumn<int> notifOverdueHour = GeneratedColumn<int>(
    'notif_overdue_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _notifBalanceMilestoneEnabledMeta =
      const VerificationMeta('notifBalanceMilestoneEnabled');
  @override
  late final GeneratedColumn<bool> notifBalanceMilestoneEnabled =
      GeneratedColumn<bool>(
        'notif_balance_milestone_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_balance_milestone_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notifBalanceMilestoneMinorMeta =
      const VerificationMeta('notifBalanceMilestoneMinor');
  @override
  late final GeneratedColumn<int> notifBalanceMilestoneMinor =
      GeneratedColumn<int>(
        'notif_balance_milestone_minor',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(100000),
      );
  static const VerificationMeta _notifInactivityEnabledMeta =
      const VerificationMeta('notifInactivityEnabled');
  @override
  late final GeneratedColumn<bool> notifInactivityEnabled =
      GeneratedColumn<bool>(
        'notif_inactivity_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_inactivity_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notifInactivityDaysMeta =
      const VerificationMeta('notifInactivityDays');
  @override
  late final GeneratedColumn<int> notifInactivityDays = GeneratedColumn<int>(
    'notif_inactivity_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _notifSyncEnabledMeta = const VerificationMeta(
    'notifSyncEnabled',
  );
  @override
  late final GeneratedColumn<bool> notifSyncEnabled = GeneratedColumn<bool>(
    'notif_sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notif_sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _clientSortFieldMeta = const VerificationMeta(
    'clientSortField',
  );
  @override
  late final GeneratedColumn<String> clientSortField = GeneratedColumn<String>(
    'client_sort_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('name'),
  );
  static const VerificationMeta _clientSortAscendingMeta =
      const VerificationMeta('clientSortAscending');
  @override
  late final GeneratedColumn<bool> clientSortAscending = GeneratedColumn<bool>(
    'client_sort_ascending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("client_sort_ascending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _clientListLayoutMeta = const VerificationMeta(
    'clientListLayout',
  );
  @override
  late final GeneratedColumn<String> clientListLayout = GeneratedColumn<String>(
    'client_list_layout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('detailed'),
  );
  static const VerificationMeta _chartCurveStyleMeta = const VerificationMeta(
    'chartCurveStyle',
  );
  @override
  late final GeneratedColumn<String> chartCurveStyle = GeneratedColumn<String>(
    'chart_curve_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monotone'),
  );
  static const VerificationMeta _notifBackupReminderEnabledMeta =
      const VerificationMeta('notifBackupReminderEnabled');
  @override
  late final GeneratedColumn<bool> notifBackupReminderEnabled =
      GeneratedColumn<bool>(
        'notif_backup_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_backup_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notifBackupReminderDaysMeta =
      const VerificationMeta('notifBackupReminderDays');
  @override
  late final GeneratedColumn<int> notifBackupReminderDays =
      GeneratedColumn<int>(
        'notif_backup_reminder_days',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(30),
      );
  static const VerificationMeta _lastJsonExportAtMeta = const VerificationMeta(
    'lastJsonExportAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastJsonExportAt =
      GeneratedColumn<DateTime>(
        'last_json_export_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _financeTrackingStartAtMeta =
      const VerificationMeta('financeTrackingStartAt');
  @override
  late final GeneratedColumn<DateTime> financeTrackingStartAt =
      GeneratedColumn<DateTime>(
        'finance_tracking_start_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notifFinanceDailyEnabledMeta =
      const VerificationMeta('notifFinanceDailyEnabled');
  @override
  late final GeneratedColumn<bool> notifFinanceDailyEnabled =
      GeneratedColumn<bool>(
        'notif_finance_daily_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_finance_daily_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notifFinanceDailyHourMeta =
      const VerificationMeta('notifFinanceDailyHour');
  @override
  late final GeneratedColumn<int> notifFinanceDailyHour = GeneratedColumn<int>(
    'notif_finance_daily_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(21),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultCurrencyCode,
    contactsAutofillEnabled,
    overdueAlertDays,
    profileName,
    syncEnabled,
    syncServerUrl,
    syncUsername,
    syncPassword,
    syncIntervalHours,
    syncPeriodicEnabled,
    lastUploadAt,
    lastUploadSha256,
    lastDownloadAt,
    lastServerOkAt,
    notifOverdueEnabled,
    notifOverdueHour,
    notifBalanceMilestoneEnabled,
    notifBalanceMilestoneMinor,
    notifInactivityEnabled,
    notifInactivityDays,
    notifSyncEnabled,
    clientSortField,
    clientSortAscending,
    clientListLayout,
    chartCurveStyle,
    notifBackupReminderEnabled,
    notifBackupReminderDays,
    lastJsonExportAt,
    financeTrackingStartAt,
    notifFinanceDailyEnabled,
    notifFinanceDailyHour,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_currency_code')) {
      context.handle(
        _defaultCurrencyCodeMeta,
        defaultCurrencyCode.isAcceptableOrUnknown(
          data['default_currency_code']!,
          _defaultCurrencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('contacts_autofill_enabled')) {
      context.handle(
        _contactsAutofillEnabledMeta,
        contactsAutofillEnabled.isAcceptableOrUnknown(
          data['contacts_autofill_enabled']!,
          _contactsAutofillEnabledMeta,
        ),
      );
    }
    if (data.containsKey('overdue_alert_days')) {
      context.handle(
        _overdueAlertDaysMeta,
        overdueAlertDays.isAcceptableOrUnknown(
          data['overdue_alert_days']!,
          _overdueAlertDaysMeta,
        ),
      );
    }
    if (data.containsKey('profile_name')) {
      context.handle(
        _profileNameMeta,
        profileName.isAcceptableOrUnknown(
          data['profile_name']!,
          _profileNameMeta,
        ),
      );
    }
    if (data.containsKey('sync_enabled')) {
      context.handle(
        _syncEnabledMeta,
        syncEnabled.isAcceptableOrUnknown(
          data['sync_enabled']!,
          _syncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sync_server_url')) {
      context.handle(
        _syncServerUrlMeta,
        syncServerUrl.isAcceptableOrUnknown(
          data['sync_server_url']!,
          _syncServerUrlMeta,
        ),
      );
    }
    if (data.containsKey('sync_username')) {
      context.handle(
        _syncUsernameMeta,
        syncUsername.isAcceptableOrUnknown(
          data['sync_username']!,
          _syncUsernameMeta,
        ),
      );
    }
    if (data.containsKey('sync_password')) {
      context.handle(
        _syncPasswordMeta,
        syncPassword.isAcceptableOrUnknown(
          data['sync_password']!,
          _syncPasswordMeta,
        ),
      );
    }
    if (data.containsKey('sync_interval_hours')) {
      context.handle(
        _syncIntervalHoursMeta,
        syncIntervalHours.isAcceptableOrUnknown(
          data['sync_interval_hours']!,
          _syncIntervalHoursMeta,
        ),
      );
    }
    if (data.containsKey('sync_periodic_enabled')) {
      context.handle(
        _syncPeriodicEnabledMeta,
        syncPeriodicEnabled.isAcceptableOrUnknown(
          data['sync_periodic_enabled']!,
          _syncPeriodicEnabledMeta,
        ),
      );
    }
    if (data.containsKey('last_upload_at')) {
      context.handle(
        _lastUploadAtMeta,
        lastUploadAt.isAcceptableOrUnknown(
          data['last_upload_at']!,
          _lastUploadAtMeta,
        ),
      );
    }
    if (data.containsKey('last_upload_sha256')) {
      context.handle(
        _lastUploadSha256Meta,
        lastUploadSha256.isAcceptableOrUnknown(
          data['last_upload_sha256']!,
          _lastUploadSha256Meta,
        ),
      );
    }
    if (data.containsKey('last_download_at')) {
      context.handle(
        _lastDownloadAtMeta,
        lastDownloadAt.isAcceptableOrUnknown(
          data['last_download_at']!,
          _lastDownloadAtMeta,
        ),
      );
    }
    if (data.containsKey('last_server_ok_at')) {
      context.handle(
        _lastServerOkAtMeta,
        lastServerOkAt.isAcceptableOrUnknown(
          data['last_server_ok_at']!,
          _lastServerOkAtMeta,
        ),
      );
    }
    if (data.containsKey('notif_overdue_enabled')) {
      context.handle(
        _notifOverdueEnabledMeta,
        notifOverdueEnabled.isAcceptableOrUnknown(
          data['notif_overdue_enabled']!,
          _notifOverdueEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notif_overdue_hour')) {
      context.handle(
        _notifOverdueHourMeta,
        notifOverdueHour.isAcceptableOrUnknown(
          data['notif_overdue_hour']!,
          _notifOverdueHourMeta,
        ),
      );
    }
    if (data.containsKey('notif_balance_milestone_enabled')) {
      context.handle(
        _notifBalanceMilestoneEnabledMeta,
        notifBalanceMilestoneEnabled.isAcceptableOrUnknown(
          data['notif_balance_milestone_enabled']!,
          _notifBalanceMilestoneEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notif_balance_milestone_minor')) {
      context.handle(
        _notifBalanceMilestoneMinorMeta,
        notifBalanceMilestoneMinor.isAcceptableOrUnknown(
          data['notif_balance_milestone_minor']!,
          _notifBalanceMilestoneMinorMeta,
        ),
      );
    }
    if (data.containsKey('notif_inactivity_enabled')) {
      context.handle(
        _notifInactivityEnabledMeta,
        notifInactivityEnabled.isAcceptableOrUnknown(
          data['notif_inactivity_enabled']!,
          _notifInactivityEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notif_inactivity_days')) {
      context.handle(
        _notifInactivityDaysMeta,
        notifInactivityDays.isAcceptableOrUnknown(
          data['notif_inactivity_days']!,
          _notifInactivityDaysMeta,
        ),
      );
    }
    if (data.containsKey('notif_sync_enabled')) {
      context.handle(
        _notifSyncEnabledMeta,
        notifSyncEnabled.isAcceptableOrUnknown(
          data['notif_sync_enabled']!,
          _notifSyncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('client_sort_field')) {
      context.handle(
        _clientSortFieldMeta,
        clientSortField.isAcceptableOrUnknown(
          data['client_sort_field']!,
          _clientSortFieldMeta,
        ),
      );
    }
    if (data.containsKey('client_sort_ascending')) {
      context.handle(
        _clientSortAscendingMeta,
        clientSortAscending.isAcceptableOrUnknown(
          data['client_sort_ascending']!,
          _clientSortAscendingMeta,
        ),
      );
    }
    if (data.containsKey('client_list_layout')) {
      context.handle(
        _clientListLayoutMeta,
        clientListLayout.isAcceptableOrUnknown(
          data['client_list_layout']!,
          _clientListLayoutMeta,
        ),
      );
    }
    if (data.containsKey('chart_curve_style')) {
      context.handle(
        _chartCurveStyleMeta,
        chartCurveStyle.isAcceptableOrUnknown(
          data['chart_curve_style']!,
          _chartCurveStyleMeta,
        ),
      );
    }
    if (data.containsKey('notif_backup_reminder_enabled')) {
      context.handle(
        _notifBackupReminderEnabledMeta,
        notifBackupReminderEnabled.isAcceptableOrUnknown(
          data['notif_backup_reminder_enabled']!,
          _notifBackupReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notif_backup_reminder_days')) {
      context.handle(
        _notifBackupReminderDaysMeta,
        notifBackupReminderDays.isAcceptableOrUnknown(
          data['notif_backup_reminder_days']!,
          _notifBackupReminderDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_json_export_at')) {
      context.handle(
        _lastJsonExportAtMeta,
        lastJsonExportAt.isAcceptableOrUnknown(
          data['last_json_export_at']!,
          _lastJsonExportAtMeta,
        ),
      );
    }
    if (data.containsKey('finance_tracking_start_at')) {
      context.handle(
        _financeTrackingStartAtMeta,
        financeTrackingStartAt.isAcceptableOrUnknown(
          data['finance_tracking_start_at']!,
          _financeTrackingStartAtMeta,
        ),
      );
    }
    if (data.containsKey('notif_finance_daily_enabled')) {
      context.handle(
        _notifFinanceDailyEnabledMeta,
        notifFinanceDailyEnabled.isAcceptableOrUnknown(
          data['notif_finance_daily_enabled']!,
          _notifFinanceDailyEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notif_finance_daily_hour')) {
      context.handle(
        _notifFinanceDailyHourMeta,
        notifFinanceDailyHour.isAcceptableOrUnknown(
          data['notif_finance_daily_hour']!,
          _notifFinanceDailyHourMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency_code'],
      )!,
      contactsAutofillEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}contacts_autofill_enabled'],
      )!,
      overdueAlertDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overdue_alert_days'],
      )!,
      profileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_name'],
      ),
      syncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_enabled'],
      )!,
      syncServerUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_server_url'],
      ),
      syncUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_username'],
      ),
      syncPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_password'],
      ),
      syncIntervalHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_interval_hours'],
      )!,
      syncPeriodicEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_periodic_enabled'],
      )!,
      lastUploadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_upload_at'],
      ),
      lastUploadSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_upload_sha256'],
      ),
      lastDownloadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_download_at'],
      ),
      lastServerOkAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_server_ok_at'],
      ),
      notifOverdueEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_overdue_enabled'],
      )!,
      notifOverdueHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_overdue_hour'],
      )!,
      notifBalanceMilestoneEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_balance_milestone_enabled'],
      )!,
      notifBalanceMilestoneMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_balance_milestone_minor'],
      )!,
      notifInactivityEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_inactivity_enabled'],
      )!,
      notifInactivityDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_inactivity_days'],
      )!,
      notifSyncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_sync_enabled'],
      )!,
      clientSortField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_sort_field'],
      )!,
      clientSortAscending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}client_sort_ascending'],
      )!,
      clientListLayout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_list_layout'],
      )!,
      chartCurveStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_curve_style'],
      )!,
      notifBackupReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_backup_reminder_enabled'],
      )!,
      notifBackupReminderDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_backup_reminder_days'],
      )!,
      lastJsonExportAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_json_export_at'],
      ),
      financeTrackingStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finance_tracking_start_at'],
      ),
      notifFinanceDailyEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_finance_daily_enabled'],
      )!,
      notifFinanceDailyHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_finance_daily_hour'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String defaultCurrencyCode;
  final bool contactsAutofillEnabled;
  final int overdueAlertDays;
  final String? profileName;
  final bool syncEnabled;
  final String? syncServerUrl;
  final String? syncUsername;
  final String? syncPassword;
  final int syncIntervalHours;
  final bool syncPeriodicEnabled;
  final DateTime? lastUploadAt;
  final String? lastUploadSha256;
  final DateTime? lastDownloadAt;
  final DateTime? lastServerOkAt;
  final bool notifOverdueEnabled;
  final int notifOverdueHour;
  final bool notifBalanceMilestoneEnabled;
  final int notifBalanceMilestoneMinor;
  final bool notifInactivityEnabled;
  final int notifInactivityDays;
  final bool notifSyncEnabled;
  final String clientSortField;
  final bool clientSortAscending;
  final String clientListLayout;
  final String chartCurveStyle;
  final bool notifBackupReminderEnabled;
  final int notifBackupReminderDays;
  final DateTime? lastJsonExportAt;
  final DateTime? financeTrackingStartAt;
  final bool notifFinanceDailyEnabled;
  final int notifFinanceDailyHour;
  const AppSetting({
    required this.id,
    required this.defaultCurrencyCode,
    required this.contactsAutofillEnabled,
    required this.overdueAlertDays,
    this.profileName,
    required this.syncEnabled,
    this.syncServerUrl,
    this.syncUsername,
    this.syncPassword,
    required this.syncIntervalHours,
    required this.syncPeriodicEnabled,
    this.lastUploadAt,
    this.lastUploadSha256,
    this.lastDownloadAt,
    this.lastServerOkAt,
    required this.notifOverdueEnabled,
    required this.notifOverdueHour,
    required this.notifBalanceMilestoneEnabled,
    required this.notifBalanceMilestoneMinor,
    required this.notifInactivityEnabled,
    required this.notifInactivityDays,
    required this.notifSyncEnabled,
    required this.clientSortField,
    required this.clientSortAscending,
    required this.clientListLayout,
    required this.chartCurveStyle,
    required this.notifBackupReminderEnabled,
    required this.notifBackupReminderDays,
    this.lastJsonExportAt,
    this.financeTrackingStartAt,
    required this.notifFinanceDailyEnabled,
    required this.notifFinanceDailyHour,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_currency_code'] = Variable<String>(defaultCurrencyCode);
    map['contacts_autofill_enabled'] = Variable<bool>(contactsAutofillEnabled);
    map['overdue_alert_days'] = Variable<int>(overdueAlertDays);
    if (!nullToAbsent || profileName != null) {
      map['profile_name'] = Variable<String>(profileName);
    }
    map['sync_enabled'] = Variable<bool>(syncEnabled);
    if (!nullToAbsent || syncServerUrl != null) {
      map['sync_server_url'] = Variable<String>(syncServerUrl);
    }
    if (!nullToAbsent || syncUsername != null) {
      map['sync_username'] = Variable<String>(syncUsername);
    }
    if (!nullToAbsent || syncPassword != null) {
      map['sync_password'] = Variable<String>(syncPassword);
    }
    map['sync_interval_hours'] = Variable<int>(syncIntervalHours);
    map['sync_periodic_enabled'] = Variable<bool>(syncPeriodicEnabled);
    if (!nullToAbsent || lastUploadAt != null) {
      map['last_upload_at'] = Variable<DateTime>(lastUploadAt);
    }
    if (!nullToAbsent || lastUploadSha256 != null) {
      map['last_upload_sha256'] = Variable<String>(lastUploadSha256);
    }
    if (!nullToAbsent || lastDownloadAt != null) {
      map['last_download_at'] = Variable<DateTime>(lastDownloadAt);
    }
    if (!nullToAbsent || lastServerOkAt != null) {
      map['last_server_ok_at'] = Variable<DateTime>(lastServerOkAt);
    }
    map['notif_overdue_enabled'] = Variable<bool>(notifOverdueEnabled);
    map['notif_overdue_hour'] = Variable<int>(notifOverdueHour);
    map['notif_balance_milestone_enabled'] = Variable<bool>(
      notifBalanceMilestoneEnabled,
    );
    map['notif_balance_milestone_minor'] = Variable<int>(
      notifBalanceMilestoneMinor,
    );
    map['notif_inactivity_enabled'] = Variable<bool>(notifInactivityEnabled);
    map['notif_inactivity_days'] = Variable<int>(notifInactivityDays);
    map['notif_sync_enabled'] = Variable<bool>(notifSyncEnabled);
    map['client_sort_field'] = Variable<String>(clientSortField);
    map['client_sort_ascending'] = Variable<bool>(clientSortAscending);
    map['client_list_layout'] = Variable<String>(clientListLayout);
    map['chart_curve_style'] = Variable<String>(chartCurveStyle);
    map['notif_backup_reminder_enabled'] = Variable<bool>(
      notifBackupReminderEnabled,
    );
    map['notif_backup_reminder_days'] = Variable<int>(notifBackupReminderDays);
    if (!nullToAbsent || lastJsonExportAt != null) {
      map['last_json_export_at'] = Variable<DateTime>(lastJsonExportAt);
    }
    if (!nullToAbsent || financeTrackingStartAt != null) {
      map['finance_tracking_start_at'] = Variable<DateTime>(
        financeTrackingStartAt,
      );
    }
    map['notif_finance_daily_enabled'] = Variable<bool>(
      notifFinanceDailyEnabled,
    );
    map['notif_finance_daily_hour'] = Variable<int>(notifFinanceDailyHour);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      defaultCurrencyCode: Value(defaultCurrencyCode),
      contactsAutofillEnabled: Value(contactsAutofillEnabled),
      overdueAlertDays: Value(overdueAlertDays),
      profileName: profileName == null && nullToAbsent
          ? const Value.absent()
          : Value(profileName),
      syncEnabled: Value(syncEnabled),
      syncServerUrl: syncServerUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(syncServerUrl),
      syncUsername: syncUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(syncUsername),
      syncPassword: syncPassword == null && nullToAbsent
          ? const Value.absent()
          : Value(syncPassword),
      syncIntervalHours: Value(syncIntervalHours),
      syncPeriodicEnabled: Value(syncPeriodicEnabled),
      lastUploadAt: lastUploadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUploadAt),
      lastUploadSha256: lastUploadSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUploadSha256),
      lastDownloadAt: lastDownloadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDownloadAt),
      lastServerOkAt: lastServerOkAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServerOkAt),
      notifOverdueEnabled: Value(notifOverdueEnabled),
      notifOverdueHour: Value(notifOverdueHour),
      notifBalanceMilestoneEnabled: Value(notifBalanceMilestoneEnabled),
      notifBalanceMilestoneMinor: Value(notifBalanceMilestoneMinor),
      notifInactivityEnabled: Value(notifInactivityEnabled),
      notifInactivityDays: Value(notifInactivityDays),
      notifSyncEnabled: Value(notifSyncEnabled),
      clientSortField: Value(clientSortField),
      clientSortAscending: Value(clientSortAscending),
      clientListLayout: Value(clientListLayout),
      chartCurveStyle: Value(chartCurveStyle),
      notifBackupReminderEnabled: Value(notifBackupReminderEnabled),
      notifBackupReminderDays: Value(notifBackupReminderDays),
      lastJsonExportAt: lastJsonExportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastJsonExportAt),
      financeTrackingStartAt: financeTrackingStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(financeTrackingStartAt),
      notifFinanceDailyEnabled: Value(notifFinanceDailyEnabled),
      notifFinanceDailyHour: Value(notifFinanceDailyHour),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      defaultCurrencyCode: serializer.fromJson<String>(
        json['defaultCurrencyCode'],
      ),
      contactsAutofillEnabled: serializer.fromJson<bool>(
        json['contactsAutofillEnabled'],
      ),
      overdueAlertDays: serializer.fromJson<int>(json['overdueAlertDays']),
      profileName: serializer.fromJson<String?>(json['profileName']),
      syncEnabled: serializer.fromJson<bool>(json['syncEnabled']),
      syncServerUrl: serializer.fromJson<String?>(json['syncServerUrl']),
      syncUsername: serializer.fromJson<String?>(json['syncUsername']),
      syncPassword: serializer.fromJson<String?>(json['syncPassword']),
      syncIntervalHours: serializer.fromJson<int>(json['syncIntervalHours']),
      syncPeriodicEnabled: serializer.fromJson<bool>(
        json['syncPeriodicEnabled'],
      ),
      lastUploadAt: serializer.fromJson<DateTime?>(json['lastUploadAt']),
      lastUploadSha256: serializer.fromJson<String?>(json['lastUploadSha256']),
      lastDownloadAt: serializer.fromJson<DateTime?>(json['lastDownloadAt']),
      lastServerOkAt: serializer.fromJson<DateTime?>(json['lastServerOkAt']),
      notifOverdueEnabled: serializer.fromJson<bool>(
        json['notifOverdueEnabled'],
      ),
      notifOverdueHour: serializer.fromJson<int>(json['notifOverdueHour']),
      notifBalanceMilestoneEnabled: serializer.fromJson<bool>(
        json['notifBalanceMilestoneEnabled'],
      ),
      notifBalanceMilestoneMinor: serializer.fromJson<int>(
        json['notifBalanceMilestoneMinor'],
      ),
      notifInactivityEnabled: serializer.fromJson<bool>(
        json['notifInactivityEnabled'],
      ),
      notifInactivityDays: serializer.fromJson<int>(
        json['notifInactivityDays'],
      ),
      notifSyncEnabled: serializer.fromJson<bool>(json['notifSyncEnabled']),
      clientSortField: serializer.fromJson<String>(json['clientSortField']),
      clientSortAscending: serializer.fromJson<bool>(
        json['clientSortAscending'],
      ),
      clientListLayout: serializer.fromJson<String>(json['clientListLayout']),
      chartCurveStyle: serializer.fromJson<String>(json['chartCurveStyle']),
      notifBackupReminderEnabled: serializer.fromJson<bool>(
        json['notifBackupReminderEnabled'],
      ),
      notifBackupReminderDays: serializer.fromJson<int>(
        json['notifBackupReminderDays'],
      ),
      lastJsonExportAt: serializer.fromJson<DateTime?>(
        json['lastJsonExportAt'],
      ),
      financeTrackingStartAt: serializer.fromJson<DateTime?>(
        json['financeTrackingStartAt'],
      ),
      notifFinanceDailyEnabled: serializer.fromJson<bool>(
        json['notifFinanceDailyEnabled'],
      ),
      notifFinanceDailyHour: serializer.fromJson<int>(
        json['notifFinanceDailyHour'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultCurrencyCode': serializer.toJson<String>(defaultCurrencyCode),
      'contactsAutofillEnabled': serializer.toJson<bool>(
        contactsAutofillEnabled,
      ),
      'overdueAlertDays': serializer.toJson<int>(overdueAlertDays),
      'profileName': serializer.toJson<String?>(profileName),
      'syncEnabled': serializer.toJson<bool>(syncEnabled),
      'syncServerUrl': serializer.toJson<String?>(syncServerUrl),
      'syncUsername': serializer.toJson<String?>(syncUsername),
      'syncPassword': serializer.toJson<String?>(syncPassword),
      'syncIntervalHours': serializer.toJson<int>(syncIntervalHours),
      'syncPeriodicEnabled': serializer.toJson<bool>(syncPeriodicEnabled),
      'lastUploadAt': serializer.toJson<DateTime?>(lastUploadAt),
      'lastUploadSha256': serializer.toJson<String?>(lastUploadSha256),
      'lastDownloadAt': serializer.toJson<DateTime?>(lastDownloadAt),
      'lastServerOkAt': serializer.toJson<DateTime?>(lastServerOkAt),
      'notifOverdueEnabled': serializer.toJson<bool>(notifOverdueEnabled),
      'notifOverdueHour': serializer.toJson<int>(notifOverdueHour),
      'notifBalanceMilestoneEnabled': serializer.toJson<bool>(
        notifBalanceMilestoneEnabled,
      ),
      'notifBalanceMilestoneMinor': serializer.toJson<int>(
        notifBalanceMilestoneMinor,
      ),
      'notifInactivityEnabled': serializer.toJson<bool>(notifInactivityEnabled),
      'notifInactivityDays': serializer.toJson<int>(notifInactivityDays),
      'notifSyncEnabled': serializer.toJson<bool>(notifSyncEnabled),
      'clientSortField': serializer.toJson<String>(clientSortField),
      'clientSortAscending': serializer.toJson<bool>(clientSortAscending),
      'clientListLayout': serializer.toJson<String>(clientListLayout),
      'chartCurveStyle': serializer.toJson<String>(chartCurveStyle),
      'notifBackupReminderEnabled': serializer.toJson<bool>(
        notifBackupReminderEnabled,
      ),
      'notifBackupReminderDays': serializer.toJson<int>(
        notifBackupReminderDays,
      ),
      'lastJsonExportAt': serializer.toJson<DateTime?>(lastJsonExportAt),
      'financeTrackingStartAt': serializer.toJson<DateTime?>(
        financeTrackingStartAt,
      ),
      'notifFinanceDailyEnabled': serializer.toJson<bool>(
        notifFinanceDailyEnabled,
      ),
      'notifFinanceDailyHour': serializer.toJson<int>(notifFinanceDailyHour),
    };
  }

  AppSetting copyWith({
    int? id,
    String? defaultCurrencyCode,
    bool? contactsAutofillEnabled,
    int? overdueAlertDays,
    Value<String?> profileName = const Value.absent(),
    bool? syncEnabled,
    Value<String?> syncServerUrl = const Value.absent(),
    Value<String?> syncUsername = const Value.absent(),
    Value<String?> syncPassword = const Value.absent(),
    int? syncIntervalHours,
    bool? syncPeriodicEnabled,
    Value<DateTime?> lastUploadAt = const Value.absent(),
    Value<String?> lastUploadSha256 = const Value.absent(),
    Value<DateTime?> lastDownloadAt = const Value.absent(),
    Value<DateTime?> lastServerOkAt = const Value.absent(),
    bool? notifOverdueEnabled,
    int? notifOverdueHour,
    bool? notifBalanceMilestoneEnabled,
    int? notifBalanceMilestoneMinor,
    bool? notifInactivityEnabled,
    int? notifInactivityDays,
    bool? notifSyncEnabled,
    String? clientSortField,
    bool? clientSortAscending,
    String? clientListLayout,
    String? chartCurveStyle,
    bool? notifBackupReminderEnabled,
    int? notifBackupReminderDays,
    Value<DateTime?> lastJsonExportAt = const Value.absent(),
    Value<DateTime?> financeTrackingStartAt = const Value.absent(),
    bool? notifFinanceDailyEnabled,
    int? notifFinanceDailyHour,
  }) => AppSetting(
    id: id ?? this.id,
    defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
    contactsAutofillEnabled:
        contactsAutofillEnabled ?? this.contactsAutofillEnabled,
    overdueAlertDays: overdueAlertDays ?? this.overdueAlertDays,
    profileName: profileName.present ? profileName.value : this.profileName,
    syncEnabled: syncEnabled ?? this.syncEnabled,
    syncServerUrl: syncServerUrl.present
        ? syncServerUrl.value
        : this.syncServerUrl,
    syncUsername: syncUsername.present ? syncUsername.value : this.syncUsername,
    syncPassword: syncPassword.present ? syncPassword.value : this.syncPassword,
    syncIntervalHours: syncIntervalHours ?? this.syncIntervalHours,
    syncPeriodicEnabled: syncPeriodicEnabled ?? this.syncPeriodicEnabled,
    lastUploadAt: lastUploadAt.present ? lastUploadAt.value : this.lastUploadAt,
    lastUploadSha256: lastUploadSha256.present
        ? lastUploadSha256.value
        : this.lastUploadSha256,
    lastDownloadAt: lastDownloadAt.present
        ? lastDownloadAt.value
        : this.lastDownloadAt,
    lastServerOkAt: lastServerOkAt.present
        ? lastServerOkAt.value
        : this.lastServerOkAt,
    notifOverdueEnabled: notifOverdueEnabled ?? this.notifOverdueEnabled,
    notifOverdueHour: notifOverdueHour ?? this.notifOverdueHour,
    notifBalanceMilestoneEnabled:
        notifBalanceMilestoneEnabled ?? this.notifBalanceMilestoneEnabled,
    notifBalanceMilestoneMinor:
        notifBalanceMilestoneMinor ?? this.notifBalanceMilestoneMinor,
    notifInactivityEnabled:
        notifInactivityEnabled ?? this.notifInactivityEnabled,
    notifInactivityDays: notifInactivityDays ?? this.notifInactivityDays,
    notifSyncEnabled: notifSyncEnabled ?? this.notifSyncEnabled,
    clientSortField: clientSortField ?? this.clientSortField,
    clientSortAscending: clientSortAscending ?? this.clientSortAscending,
    clientListLayout: clientListLayout ?? this.clientListLayout,
    chartCurveStyle: chartCurveStyle ?? this.chartCurveStyle,
    notifBackupReminderEnabled:
        notifBackupReminderEnabled ?? this.notifBackupReminderEnabled,
    notifBackupReminderDays:
        notifBackupReminderDays ?? this.notifBackupReminderDays,
    lastJsonExportAt: lastJsonExportAt.present
        ? lastJsonExportAt.value
        : this.lastJsonExportAt,
    financeTrackingStartAt: financeTrackingStartAt.present
        ? financeTrackingStartAt.value
        : this.financeTrackingStartAt,
    notifFinanceDailyEnabled:
        notifFinanceDailyEnabled ?? this.notifFinanceDailyEnabled,
    notifFinanceDailyHour: notifFinanceDailyHour ?? this.notifFinanceDailyHour,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      defaultCurrencyCode: data.defaultCurrencyCode.present
          ? data.defaultCurrencyCode.value
          : this.defaultCurrencyCode,
      contactsAutofillEnabled: data.contactsAutofillEnabled.present
          ? data.contactsAutofillEnabled.value
          : this.contactsAutofillEnabled,
      overdueAlertDays: data.overdueAlertDays.present
          ? data.overdueAlertDays.value
          : this.overdueAlertDays,
      profileName: data.profileName.present
          ? data.profileName.value
          : this.profileName,
      syncEnabled: data.syncEnabled.present
          ? data.syncEnabled.value
          : this.syncEnabled,
      syncServerUrl: data.syncServerUrl.present
          ? data.syncServerUrl.value
          : this.syncServerUrl,
      syncUsername: data.syncUsername.present
          ? data.syncUsername.value
          : this.syncUsername,
      syncPassword: data.syncPassword.present
          ? data.syncPassword.value
          : this.syncPassword,
      syncIntervalHours: data.syncIntervalHours.present
          ? data.syncIntervalHours.value
          : this.syncIntervalHours,
      syncPeriodicEnabled: data.syncPeriodicEnabled.present
          ? data.syncPeriodicEnabled.value
          : this.syncPeriodicEnabled,
      lastUploadAt: data.lastUploadAt.present
          ? data.lastUploadAt.value
          : this.lastUploadAt,
      lastUploadSha256: data.lastUploadSha256.present
          ? data.lastUploadSha256.value
          : this.lastUploadSha256,
      lastDownloadAt: data.lastDownloadAt.present
          ? data.lastDownloadAt.value
          : this.lastDownloadAt,
      lastServerOkAt: data.lastServerOkAt.present
          ? data.lastServerOkAt.value
          : this.lastServerOkAt,
      notifOverdueEnabled: data.notifOverdueEnabled.present
          ? data.notifOverdueEnabled.value
          : this.notifOverdueEnabled,
      notifOverdueHour: data.notifOverdueHour.present
          ? data.notifOverdueHour.value
          : this.notifOverdueHour,
      notifBalanceMilestoneEnabled: data.notifBalanceMilestoneEnabled.present
          ? data.notifBalanceMilestoneEnabled.value
          : this.notifBalanceMilestoneEnabled,
      notifBalanceMilestoneMinor: data.notifBalanceMilestoneMinor.present
          ? data.notifBalanceMilestoneMinor.value
          : this.notifBalanceMilestoneMinor,
      notifInactivityEnabled: data.notifInactivityEnabled.present
          ? data.notifInactivityEnabled.value
          : this.notifInactivityEnabled,
      notifInactivityDays: data.notifInactivityDays.present
          ? data.notifInactivityDays.value
          : this.notifInactivityDays,
      notifSyncEnabled: data.notifSyncEnabled.present
          ? data.notifSyncEnabled.value
          : this.notifSyncEnabled,
      clientSortField: data.clientSortField.present
          ? data.clientSortField.value
          : this.clientSortField,
      clientSortAscending: data.clientSortAscending.present
          ? data.clientSortAscending.value
          : this.clientSortAscending,
      clientListLayout: data.clientListLayout.present
          ? data.clientListLayout.value
          : this.clientListLayout,
      chartCurveStyle: data.chartCurveStyle.present
          ? data.chartCurveStyle.value
          : this.chartCurveStyle,
      notifBackupReminderEnabled: data.notifBackupReminderEnabled.present
          ? data.notifBackupReminderEnabled.value
          : this.notifBackupReminderEnabled,
      notifBackupReminderDays: data.notifBackupReminderDays.present
          ? data.notifBackupReminderDays.value
          : this.notifBackupReminderDays,
      lastJsonExportAt: data.lastJsonExportAt.present
          ? data.lastJsonExportAt.value
          : this.lastJsonExportAt,
      financeTrackingStartAt: data.financeTrackingStartAt.present
          ? data.financeTrackingStartAt.value
          : this.financeTrackingStartAt,
      notifFinanceDailyEnabled: data.notifFinanceDailyEnabled.present
          ? data.notifFinanceDailyEnabled.value
          : this.notifFinanceDailyEnabled,
      notifFinanceDailyHour: data.notifFinanceDailyHour.present
          ? data.notifFinanceDailyHour.value
          : this.notifFinanceDailyHour,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('defaultCurrencyCode: $defaultCurrencyCode, ')
          ..write('contactsAutofillEnabled: $contactsAutofillEnabled, ')
          ..write('overdueAlertDays: $overdueAlertDays, ')
          ..write('profileName: $profileName, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('syncServerUrl: $syncServerUrl, ')
          ..write('syncUsername: $syncUsername, ')
          ..write('syncPassword: $syncPassword, ')
          ..write('syncIntervalHours: $syncIntervalHours, ')
          ..write('syncPeriodicEnabled: $syncPeriodicEnabled, ')
          ..write('lastUploadAt: $lastUploadAt, ')
          ..write('lastUploadSha256: $lastUploadSha256, ')
          ..write('lastDownloadAt: $lastDownloadAt, ')
          ..write('lastServerOkAt: $lastServerOkAt, ')
          ..write('notifOverdueEnabled: $notifOverdueEnabled, ')
          ..write('notifOverdueHour: $notifOverdueHour, ')
          ..write(
            'notifBalanceMilestoneEnabled: $notifBalanceMilestoneEnabled, ',
          )
          ..write('notifBalanceMilestoneMinor: $notifBalanceMilestoneMinor, ')
          ..write('notifInactivityEnabled: $notifInactivityEnabled, ')
          ..write('notifInactivityDays: $notifInactivityDays, ')
          ..write('notifSyncEnabled: $notifSyncEnabled, ')
          ..write('clientSortField: $clientSortField, ')
          ..write('clientSortAscending: $clientSortAscending, ')
          ..write('clientListLayout: $clientListLayout, ')
          ..write('chartCurveStyle: $chartCurveStyle, ')
          ..write('notifBackupReminderEnabled: $notifBackupReminderEnabled, ')
          ..write('notifBackupReminderDays: $notifBackupReminderDays, ')
          ..write('lastJsonExportAt: $lastJsonExportAt, ')
          ..write('financeTrackingStartAt: $financeTrackingStartAt, ')
          ..write('notifFinanceDailyEnabled: $notifFinanceDailyEnabled, ')
          ..write('notifFinanceDailyHour: $notifFinanceDailyHour')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    defaultCurrencyCode,
    contactsAutofillEnabled,
    overdueAlertDays,
    profileName,
    syncEnabled,
    syncServerUrl,
    syncUsername,
    syncPassword,
    syncIntervalHours,
    syncPeriodicEnabled,
    lastUploadAt,
    lastUploadSha256,
    lastDownloadAt,
    lastServerOkAt,
    notifOverdueEnabled,
    notifOverdueHour,
    notifBalanceMilestoneEnabled,
    notifBalanceMilestoneMinor,
    notifInactivityEnabled,
    notifInactivityDays,
    notifSyncEnabled,
    clientSortField,
    clientSortAscending,
    clientListLayout,
    chartCurveStyle,
    notifBackupReminderEnabled,
    notifBackupReminderDays,
    lastJsonExportAt,
    financeTrackingStartAt,
    notifFinanceDailyEnabled,
    notifFinanceDailyHour,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.defaultCurrencyCode == this.defaultCurrencyCode &&
          other.contactsAutofillEnabled == this.contactsAutofillEnabled &&
          other.overdueAlertDays == this.overdueAlertDays &&
          other.profileName == this.profileName &&
          other.syncEnabled == this.syncEnabled &&
          other.syncServerUrl == this.syncServerUrl &&
          other.syncUsername == this.syncUsername &&
          other.syncPassword == this.syncPassword &&
          other.syncIntervalHours == this.syncIntervalHours &&
          other.syncPeriodicEnabled == this.syncPeriodicEnabled &&
          other.lastUploadAt == this.lastUploadAt &&
          other.lastUploadSha256 == this.lastUploadSha256 &&
          other.lastDownloadAt == this.lastDownloadAt &&
          other.lastServerOkAt == this.lastServerOkAt &&
          other.notifOverdueEnabled == this.notifOverdueEnabled &&
          other.notifOverdueHour == this.notifOverdueHour &&
          other.notifBalanceMilestoneEnabled ==
              this.notifBalanceMilestoneEnabled &&
          other.notifBalanceMilestoneMinor == this.notifBalanceMilestoneMinor &&
          other.notifInactivityEnabled == this.notifInactivityEnabled &&
          other.notifInactivityDays == this.notifInactivityDays &&
          other.notifSyncEnabled == this.notifSyncEnabled &&
          other.clientSortField == this.clientSortField &&
          other.clientSortAscending == this.clientSortAscending &&
          other.clientListLayout == this.clientListLayout &&
          other.chartCurveStyle == this.chartCurveStyle &&
          other.notifBackupReminderEnabled == this.notifBackupReminderEnabled &&
          other.notifBackupReminderDays == this.notifBackupReminderDays &&
          other.lastJsonExportAt == this.lastJsonExportAt &&
          other.financeTrackingStartAt == this.financeTrackingStartAt &&
          other.notifFinanceDailyEnabled == this.notifFinanceDailyEnabled &&
          other.notifFinanceDailyHour == this.notifFinanceDailyHour);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> defaultCurrencyCode;
  final Value<bool> contactsAutofillEnabled;
  final Value<int> overdueAlertDays;
  final Value<String?> profileName;
  final Value<bool> syncEnabled;
  final Value<String?> syncServerUrl;
  final Value<String?> syncUsername;
  final Value<String?> syncPassword;
  final Value<int> syncIntervalHours;
  final Value<bool> syncPeriodicEnabled;
  final Value<DateTime?> lastUploadAt;
  final Value<String?> lastUploadSha256;
  final Value<DateTime?> lastDownloadAt;
  final Value<DateTime?> lastServerOkAt;
  final Value<bool> notifOverdueEnabled;
  final Value<int> notifOverdueHour;
  final Value<bool> notifBalanceMilestoneEnabled;
  final Value<int> notifBalanceMilestoneMinor;
  final Value<bool> notifInactivityEnabled;
  final Value<int> notifInactivityDays;
  final Value<bool> notifSyncEnabled;
  final Value<String> clientSortField;
  final Value<bool> clientSortAscending;
  final Value<String> clientListLayout;
  final Value<String> chartCurveStyle;
  final Value<bool> notifBackupReminderEnabled;
  final Value<int> notifBackupReminderDays;
  final Value<DateTime?> lastJsonExportAt;
  final Value<DateTime?> financeTrackingStartAt;
  final Value<bool> notifFinanceDailyEnabled;
  final Value<int> notifFinanceDailyHour;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultCurrencyCode = const Value.absent(),
    this.contactsAutofillEnabled = const Value.absent(),
    this.overdueAlertDays = const Value.absent(),
    this.profileName = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.syncServerUrl = const Value.absent(),
    this.syncUsername = const Value.absent(),
    this.syncPassword = const Value.absent(),
    this.syncIntervalHours = const Value.absent(),
    this.syncPeriodicEnabled = const Value.absent(),
    this.lastUploadAt = const Value.absent(),
    this.lastUploadSha256 = const Value.absent(),
    this.lastDownloadAt = const Value.absent(),
    this.lastServerOkAt = const Value.absent(),
    this.notifOverdueEnabled = const Value.absent(),
    this.notifOverdueHour = const Value.absent(),
    this.notifBalanceMilestoneEnabled = const Value.absent(),
    this.notifBalanceMilestoneMinor = const Value.absent(),
    this.notifInactivityEnabled = const Value.absent(),
    this.notifInactivityDays = const Value.absent(),
    this.notifSyncEnabled = const Value.absent(),
    this.clientSortField = const Value.absent(),
    this.clientSortAscending = const Value.absent(),
    this.clientListLayout = const Value.absent(),
    this.chartCurveStyle = const Value.absent(),
    this.notifBackupReminderEnabled = const Value.absent(),
    this.notifBackupReminderDays = const Value.absent(),
    this.lastJsonExportAt = const Value.absent(),
    this.financeTrackingStartAt = const Value.absent(),
    this.notifFinanceDailyEnabled = const Value.absent(),
    this.notifFinanceDailyHour = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultCurrencyCode = const Value.absent(),
    this.contactsAutofillEnabled = const Value.absent(),
    this.overdueAlertDays = const Value.absent(),
    this.profileName = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.syncServerUrl = const Value.absent(),
    this.syncUsername = const Value.absent(),
    this.syncPassword = const Value.absent(),
    this.syncIntervalHours = const Value.absent(),
    this.syncPeriodicEnabled = const Value.absent(),
    this.lastUploadAt = const Value.absent(),
    this.lastUploadSha256 = const Value.absent(),
    this.lastDownloadAt = const Value.absent(),
    this.lastServerOkAt = const Value.absent(),
    this.notifOverdueEnabled = const Value.absent(),
    this.notifOverdueHour = const Value.absent(),
    this.notifBalanceMilestoneEnabled = const Value.absent(),
    this.notifBalanceMilestoneMinor = const Value.absent(),
    this.notifInactivityEnabled = const Value.absent(),
    this.notifInactivityDays = const Value.absent(),
    this.notifSyncEnabled = const Value.absent(),
    this.clientSortField = const Value.absent(),
    this.clientSortAscending = const Value.absent(),
    this.clientListLayout = const Value.absent(),
    this.chartCurveStyle = const Value.absent(),
    this.notifBackupReminderEnabled = const Value.absent(),
    this.notifBackupReminderDays = const Value.absent(),
    this.lastJsonExportAt = const Value.absent(),
    this.financeTrackingStartAt = const Value.absent(),
    this.notifFinanceDailyEnabled = const Value.absent(),
    this.notifFinanceDailyHour = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? defaultCurrencyCode,
    Expression<bool>? contactsAutofillEnabled,
    Expression<int>? overdueAlertDays,
    Expression<String>? profileName,
    Expression<bool>? syncEnabled,
    Expression<String>? syncServerUrl,
    Expression<String>? syncUsername,
    Expression<String>? syncPassword,
    Expression<int>? syncIntervalHours,
    Expression<bool>? syncPeriodicEnabled,
    Expression<DateTime>? lastUploadAt,
    Expression<String>? lastUploadSha256,
    Expression<DateTime>? lastDownloadAt,
    Expression<DateTime>? lastServerOkAt,
    Expression<bool>? notifOverdueEnabled,
    Expression<int>? notifOverdueHour,
    Expression<bool>? notifBalanceMilestoneEnabled,
    Expression<int>? notifBalanceMilestoneMinor,
    Expression<bool>? notifInactivityEnabled,
    Expression<int>? notifInactivityDays,
    Expression<bool>? notifSyncEnabled,
    Expression<String>? clientSortField,
    Expression<bool>? clientSortAscending,
    Expression<String>? clientListLayout,
    Expression<String>? chartCurveStyle,
    Expression<bool>? notifBackupReminderEnabled,
    Expression<int>? notifBackupReminderDays,
    Expression<DateTime>? lastJsonExportAt,
    Expression<DateTime>? financeTrackingStartAt,
    Expression<bool>? notifFinanceDailyEnabled,
    Expression<int>? notifFinanceDailyHour,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultCurrencyCode != null)
        'default_currency_code': defaultCurrencyCode,
      if (contactsAutofillEnabled != null)
        'contacts_autofill_enabled': contactsAutofillEnabled,
      if (overdueAlertDays != null) 'overdue_alert_days': overdueAlertDays,
      if (profileName != null) 'profile_name': profileName,
      if (syncEnabled != null) 'sync_enabled': syncEnabled,
      if (syncServerUrl != null) 'sync_server_url': syncServerUrl,
      if (syncUsername != null) 'sync_username': syncUsername,
      if (syncPassword != null) 'sync_password': syncPassword,
      if (syncIntervalHours != null) 'sync_interval_hours': syncIntervalHours,
      if (syncPeriodicEnabled != null)
        'sync_periodic_enabled': syncPeriodicEnabled,
      if (lastUploadAt != null) 'last_upload_at': lastUploadAt,
      if (lastUploadSha256 != null) 'last_upload_sha256': lastUploadSha256,
      if (lastDownloadAt != null) 'last_download_at': lastDownloadAt,
      if (lastServerOkAt != null) 'last_server_ok_at': lastServerOkAt,
      if (notifOverdueEnabled != null)
        'notif_overdue_enabled': notifOverdueEnabled,
      if (notifOverdueHour != null) 'notif_overdue_hour': notifOverdueHour,
      if (notifBalanceMilestoneEnabled != null)
        'notif_balance_milestone_enabled': notifBalanceMilestoneEnabled,
      if (notifBalanceMilestoneMinor != null)
        'notif_balance_milestone_minor': notifBalanceMilestoneMinor,
      if (notifInactivityEnabled != null)
        'notif_inactivity_enabled': notifInactivityEnabled,
      if (notifInactivityDays != null)
        'notif_inactivity_days': notifInactivityDays,
      if (notifSyncEnabled != null) 'notif_sync_enabled': notifSyncEnabled,
      if (clientSortField != null) 'client_sort_field': clientSortField,
      if (clientSortAscending != null)
        'client_sort_ascending': clientSortAscending,
      if (clientListLayout != null) 'client_list_layout': clientListLayout,
      if (chartCurveStyle != null) 'chart_curve_style': chartCurveStyle,
      if (notifBackupReminderEnabled != null)
        'notif_backup_reminder_enabled': notifBackupReminderEnabled,
      if (notifBackupReminderDays != null)
        'notif_backup_reminder_days': notifBackupReminderDays,
      if (lastJsonExportAt != null) 'last_json_export_at': lastJsonExportAt,
      if (financeTrackingStartAt != null)
        'finance_tracking_start_at': financeTrackingStartAt,
      if (notifFinanceDailyEnabled != null)
        'notif_finance_daily_enabled': notifFinanceDailyEnabled,
      if (notifFinanceDailyHour != null)
        'notif_finance_daily_hour': notifFinanceDailyHour,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? defaultCurrencyCode,
    Value<bool>? contactsAutofillEnabled,
    Value<int>? overdueAlertDays,
    Value<String?>? profileName,
    Value<bool>? syncEnabled,
    Value<String?>? syncServerUrl,
    Value<String?>? syncUsername,
    Value<String?>? syncPassword,
    Value<int>? syncIntervalHours,
    Value<bool>? syncPeriodicEnabled,
    Value<DateTime?>? lastUploadAt,
    Value<String?>? lastUploadSha256,
    Value<DateTime?>? lastDownloadAt,
    Value<DateTime?>? lastServerOkAt,
    Value<bool>? notifOverdueEnabled,
    Value<int>? notifOverdueHour,
    Value<bool>? notifBalanceMilestoneEnabled,
    Value<int>? notifBalanceMilestoneMinor,
    Value<bool>? notifInactivityEnabled,
    Value<int>? notifInactivityDays,
    Value<bool>? notifSyncEnabled,
    Value<String>? clientSortField,
    Value<bool>? clientSortAscending,
    Value<String>? clientListLayout,
    Value<String>? chartCurveStyle,
    Value<bool>? notifBackupReminderEnabled,
    Value<int>? notifBackupReminderDays,
    Value<DateTime?>? lastJsonExportAt,
    Value<DateTime?>? financeTrackingStartAt,
    Value<bool>? notifFinanceDailyEnabled,
    Value<int>? notifFinanceDailyHour,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      contactsAutofillEnabled:
          contactsAutofillEnabled ?? this.contactsAutofillEnabled,
      overdueAlertDays: overdueAlertDays ?? this.overdueAlertDays,
      profileName: profileName ?? this.profileName,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncServerUrl: syncServerUrl ?? this.syncServerUrl,
      syncUsername: syncUsername ?? this.syncUsername,
      syncPassword: syncPassword ?? this.syncPassword,
      syncIntervalHours: syncIntervalHours ?? this.syncIntervalHours,
      syncPeriodicEnabled: syncPeriodicEnabled ?? this.syncPeriodicEnabled,
      lastUploadAt: lastUploadAt ?? this.lastUploadAt,
      lastUploadSha256: lastUploadSha256 ?? this.lastUploadSha256,
      lastDownloadAt: lastDownloadAt ?? this.lastDownloadAt,
      lastServerOkAt: lastServerOkAt ?? this.lastServerOkAt,
      notifOverdueEnabled: notifOverdueEnabled ?? this.notifOverdueEnabled,
      notifOverdueHour: notifOverdueHour ?? this.notifOverdueHour,
      notifBalanceMilestoneEnabled:
          notifBalanceMilestoneEnabled ?? this.notifBalanceMilestoneEnabled,
      notifBalanceMilestoneMinor:
          notifBalanceMilestoneMinor ?? this.notifBalanceMilestoneMinor,
      notifInactivityEnabled:
          notifInactivityEnabled ?? this.notifInactivityEnabled,
      notifInactivityDays: notifInactivityDays ?? this.notifInactivityDays,
      notifSyncEnabled: notifSyncEnabled ?? this.notifSyncEnabled,
      clientSortField: clientSortField ?? this.clientSortField,
      clientSortAscending: clientSortAscending ?? this.clientSortAscending,
      clientListLayout: clientListLayout ?? this.clientListLayout,
      chartCurveStyle: chartCurveStyle ?? this.chartCurveStyle,
      notifBackupReminderEnabled:
          notifBackupReminderEnabled ?? this.notifBackupReminderEnabled,
      notifBackupReminderDays:
          notifBackupReminderDays ?? this.notifBackupReminderDays,
      lastJsonExportAt: lastJsonExportAt ?? this.lastJsonExportAt,
      financeTrackingStartAt:
          financeTrackingStartAt ?? this.financeTrackingStartAt,
      notifFinanceDailyEnabled:
          notifFinanceDailyEnabled ?? this.notifFinanceDailyEnabled,
      notifFinanceDailyHour:
          notifFinanceDailyHour ?? this.notifFinanceDailyHour,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultCurrencyCode.present) {
      map['default_currency_code'] = Variable<String>(
        defaultCurrencyCode.value,
      );
    }
    if (contactsAutofillEnabled.present) {
      map['contacts_autofill_enabled'] = Variable<bool>(
        contactsAutofillEnabled.value,
      );
    }
    if (overdueAlertDays.present) {
      map['overdue_alert_days'] = Variable<int>(overdueAlertDays.value);
    }
    if (profileName.present) {
      map['profile_name'] = Variable<String>(profileName.value);
    }
    if (syncEnabled.present) {
      map['sync_enabled'] = Variable<bool>(syncEnabled.value);
    }
    if (syncServerUrl.present) {
      map['sync_server_url'] = Variable<String>(syncServerUrl.value);
    }
    if (syncUsername.present) {
      map['sync_username'] = Variable<String>(syncUsername.value);
    }
    if (syncPassword.present) {
      map['sync_password'] = Variable<String>(syncPassword.value);
    }
    if (syncIntervalHours.present) {
      map['sync_interval_hours'] = Variable<int>(syncIntervalHours.value);
    }
    if (syncPeriodicEnabled.present) {
      map['sync_periodic_enabled'] = Variable<bool>(syncPeriodicEnabled.value);
    }
    if (lastUploadAt.present) {
      map['last_upload_at'] = Variable<DateTime>(lastUploadAt.value);
    }
    if (lastUploadSha256.present) {
      map['last_upload_sha256'] = Variable<String>(lastUploadSha256.value);
    }
    if (lastDownloadAt.present) {
      map['last_download_at'] = Variable<DateTime>(lastDownloadAt.value);
    }
    if (lastServerOkAt.present) {
      map['last_server_ok_at'] = Variable<DateTime>(lastServerOkAt.value);
    }
    if (notifOverdueEnabled.present) {
      map['notif_overdue_enabled'] = Variable<bool>(notifOverdueEnabled.value);
    }
    if (notifOverdueHour.present) {
      map['notif_overdue_hour'] = Variable<int>(notifOverdueHour.value);
    }
    if (notifBalanceMilestoneEnabled.present) {
      map['notif_balance_milestone_enabled'] = Variable<bool>(
        notifBalanceMilestoneEnabled.value,
      );
    }
    if (notifBalanceMilestoneMinor.present) {
      map['notif_balance_milestone_minor'] = Variable<int>(
        notifBalanceMilestoneMinor.value,
      );
    }
    if (notifInactivityEnabled.present) {
      map['notif_inactivity_enabled'] = Variable<bool>(
        notifInactivityEnabled.value,
      );
    }
    if (notifInactivityDays.present) {
      map['notif_inactivity_days'] = Variable<int>(notifInactivityDays.value);
    }
    if (notifSyncEnabled.present) {
      map['notif_sync_enabled'] = Variable<bool>(notifSyncEnabled.value);
    }
    if (clientSortField.present) {
      map['client_sort_field'] = Variable<String>(clientSortField.value);
    }
    if (clientSortAscending.present) {
      map['client_sort_ascending'] = Variable<bool>(clientSortAscending.value);
    }
    if (clientListLayout.present) {
      map['client_list_layout'] = Variable<String>(clientListLayout.value);
    }
    if (chartCurveStyle.present) {
      map['chart_curve_style'] = Variable<String>(chartCurveStyle.value);
    }
    if (notifBackupReminderEnabled.present) {
      map['notif_backup_reminder_enabled'] = Variable<bool>(
        notifBackupReminderEnabled.value,
      );
    }
    if (notifBackupReminderDays.present) {
      map['notif_backup_reminder_days'] = Variable<int>(
        notifBackupReminderDays.value,
      );
    }
    if (lastJsonExportAt.present) {
      map['last_json_export_at'] = Variable<DateTime>(lastJsonExportAt.value);
    }
    if (financeTrackingStartAt.present) {
      map['finance_tracking_start_at'] = Variable<DateTime>(
        financeTrackingStartAt.value,
      );
    }
    if (notifFinanceDailyEnabled.present) {
      map['notif_finance_daily_enabled'] = Variable<bool>(
        notifFinanceDailyEnabled.value,
      );
    }
    if (notifFinanceDailyHour.present) {
      map['notif_finance_daily_hour'] = Variable<int>(
        notifFinanceDailyHour.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultCurrencyCode: $defaultCurrencyCode, ')
          ..write('contactsAutofillEnabled: $contactsAutofillEnabled, ')
          ..write('overdueAlertDays: $overdueAlertDays, ')
          ..write('profileName: $profileName, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('syncServerUrl: $syncServerUrl, ')
          ..write('syncUsername: $syncUsername, ')
          ..write('syncPassword: $syncPassword, ')
          ..write('syncIntervalHours: $syncIntervalHours, ')
          ..write('syncPeriodicEnabled: $syncPeriodicEnabled, ')
          ..write('lastUploadAt: $lastUploadAt, ')
          ..write('lastUploadSha256: $lastUploadSha256, ')
          ..write('lastDownloadAt: $lastDownloadAt, ')
          ..write('lastServerOkAt: $lastServerOkAt, ')
          ..write('notifOverdueEnabled: $notifOverdueEnabled, ')
          ..write('notifOverdueHour: $notifOverdueHour, ')
          ..write(
            'notifBalanceMilestoneEnabled: $notifBalanceMilestoneEnabled, ',
          )
          ..write('notifBalanceMilestoneMinor: $notifBalanceMilestoneMinor, ')
          ..write('notifInactivityEnabled: $notifInactivityEnabled, ')
          ..write('notifInactivityDays: $notifInactivityDays, ')
          ..write('notifSyncEnabled: $notifSyncEnabled, ')
          ..write('clientSortField: $clientSortField, ')
          ..write('clientSortAscending: $clientSortAscending, ')
          ..write('clientListLayout: $clientListLayout, ')
          ..write('chartCurveStyle: $chartCurveStyle, ')
          ..write('notifBackupReminderEnabled: $notifBackupReminderEnabled, ')
          ..write('notifBackupReminderDays: $notifBackupReminderDays, ')
          ..write('lastJsonExportAt: $lastJsonExportAt, ')
          ..write('financeTrackingStartAt: $financeTrackingStartAt, ')
          ..write('notifFinanceDailyEnabled: $notifFinanceDailyEnabled, ')
          ..write('notifFinanceDailyHour: $notifFinanceDailyHour')
          ..write(')'))
        .toString();
  }
}

class $TransactionTemplatesTable extends TransactionTemplates
    with TableInfo<$TransactionTemplatesTable, TransactionTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<int> txType = GeneratedColumn<int>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    amountMinor,
    txType,
    currencyCode,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_type'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionTemplatesTable createAlias(String alias) {
    return $TransactionTemplatesTable(attachedDatabase, alias);
  }
}

class TransactionTemplate extends DataClass
    implements Insertable<TransactionTemplate> {
  final String id;
  final String label;
  final int amountMinor;
  final int txType;
  final String currencyCode;
  final String? note;
  final DateTime createdAt;
  const TransactionTemplate({
    required this.id,
    required this.label,
    required this.amountMinor,
    required this.txType,
    required this.currencyCode,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['tx_type'] = Variable<int>(txType);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionTemplatesCompanion toCompanion(bool nullToAbsent) {
    return TransactionTemplatesCompanion(
      id: Value(id),
      label: Value(label),
      amountMinor: Value(amountMinor),
      txType: Value(txType),
      currencyCode: Value(currencyCode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTemplate(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      txType: serializer.fromJson<int>(json['txType']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'txType': serializer.toJson<int>(txType),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionTemplate copyWith({
    String? id,
    String? label,
    int? amountMinor,
    int? txType,
    String? currencyCode,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionTemplate(
    id: id ?? this.id,
    label: label ?? this.label,
    amountMinor: amountMinor ?? this.amountMinor,
    txType: txType ?? this.txType,
    currencyCode: currencyCode ?? this.currencyCode,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionTemplate copyWithCompanion(TransactionTemplatesCompanion data) {
    return TransactionTemplate(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      txType: data.txType.present ? data.txType.value : this.txType,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTemplate(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('txType: $txType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    amountMinor,
    txType,
    currencyCode,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTemplate &&
          other.id == this.id &&
          other.label == this.label &&
          other.amountMinor == this.amountMinor &&
          other.txType == this.txType &&
          other.currencyCode == this.currencyCode &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class TransactionTemplatesCompanion
    extends UpdateCompanion<TransactionTemplate> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> amountMinor;
  final Value<int> txType;
  final Value<String> currencyCode;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionTemplatesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.txType = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTemplatesCompanion.insert({
    required String id,
    required String label,
    required int amountMinor,
    required int txType,
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       amountMinor = Value(amountMinor),
       txType = Value(txType),
       createdAt = Value(createdAt);
  static Insertable<TransactionTemplate> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? amountMinor,
    Expression<int>? txType,
    Expression<String>? currencyCode,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (txType != null) 'tx_type': txType,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<int>? amountMinor,
    Value<int>? txType,
    Value<String>? currencyCode,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionTemplatesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      amountMinor: amountMinor ?? this.amountMinor,
      txType: txType ?? this.txType,
      currencyCode: currencyCode ?? this.currencyCode,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<int>(txType.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('txType: $txType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    action,
    entityType,
    entityId,
    detail,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String? detail;
  final DateTime createdAt;
  const AuditLogData({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.detail,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<String>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      detail: serializer.fromJson<String?>(json['detail']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'detail': serializer.toJson<String?>(detail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLogData copyWith({
    String? id,
    String? action,
    String? entityType,
    String? entityId,
    Value<String?> detail = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLogData(
    id: id ?? this.id,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    detail: detail.present ? detail.value : this.detail,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      detail: data.detail.present ? data.detail.value : this.detail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, action, entityType, entityId, detail, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.detail == this.detail &&
          other.createdAt == this.createdAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<String> id;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> detail;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String action,
    required String entityType,
    required String entityId,
    this.detail = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       entityType = Value(entityType),
       entityId = Value(entityId),
       createdAt = Value(createdAt);
  static Insertable<AuditLogData> custom({
    Expression<String>? id,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? detail,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (detail != null) 'detail': detail,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? detail,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#22C55E'),
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetMinorPerMonthMeta =
      const VerificationMeta('budgetMinorPerMonth');
  @override
  late final GeneratedColumn<int> budgetMinorPerMonth = GeneratedColumn<int>(
    'budget_minor_per_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetPeriodMeta = const VerificationMeta(
    'budgetPeriod',
  );
  @override
  late final GeneratedColumn<String> budgetPeriod = GeneratedColumn<String>(
    'budget_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('month'),
  );
  static const VerificationMeta _budgetCustomDaysMeta = const VerificationMeta(
    'budgetCustomDays',
  );
  @override
  late final GeneratedColumn<int> budgetCustomDays = GeneratedColumn<int>(
    'budget_custom_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    iconCodePoint,
    budgetMinorPerMonth,
    scope,
    createdAt,
    budgetPeriod,
    budgetCustomDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('budget_minor_per_month')) {
      context.handle(
        _budgetMinorPerMonthMeta,
        budgetMinorPerMonth.isAcceptableOrUnknown(
          data['budget_minor_per_month']!,
          _budgetMinorPerMonthMeta,
        ),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('budget_period')) {
      context.handle(
        _budgetPeriodMeta,
        budgetPeriod.isAcceptableOrUnknown(
          data['budget_period']!,
          _budgetPeriodMeta,
        ),
      );
    }
    if (data.containsKey('budget_custom_days')) {
      context.handle(
        _budgetCustomDaysMeta,
        budgetCustomDays.isAcceptableOrUnknown(
          data['budget_custom_days']!,
          _budgetCustomDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      budgetMinorPerMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_minor_per_month'],
      ),
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      budgetPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_period'],
      )!,
      budgetCustomDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_custom_days'],
      ),
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final String id;
  final String name;
  final String colorHex;
  final int iconCodePoint;
  final int? budgetMinorPerMonth;

  /// 'expense' or 'gain'
  final String scope;
  final DateTime createdAt;

  /// 'week' | 'month' | 'custom' — period type for the budget window
  final String budgetPeriod;

  /// Used when budgetPeriod = 'custom': rolling window in days
  final int? budgetCustomDays;
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconCodePoint,
    this.budgetMinorPerMonth,
    required this.scope,
    required this.createdAt,
    required this.budgetPeriod,
    this.budgetCustomDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    if (!nullToAbsent || budgetMinorPerMonth != null) {
      map['budget_minor_per_month'] = Variable<int>(budgetMinorPerMonth);
    }
    map['scope'] = Variable<String>(scope);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['budget_period'] = Variable<String>(budgetPeriod);
    if (!nullToAbsent || budgetCustomDays != null) {
      map['budget_custom_days'] = Variable<int>(budgetCustomDays);
    }
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      iconCodePoint: Value(iconCodePoint),
      budgetMinorPerMonth: budgetMinorPerMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetMinorPerMonth),
      scope: Value(scope),
      createdAt: Value(createdAt),
      budgetPeriod: Value(budgetPeriod),
      budgetCustomDays: budgetCustomDays == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetCustomDays),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      budgetMinorPerMonth: serializer.fromJson<int?>(
        json['budgetMinorPerMonth'],
      ),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      budgetPeriod: serializer.fromJson<String>(json['budgetPeriod']),
      budgetCustomDays: serializer.fromJson<int?>(json['budgetCustomDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'budgetMinorPerMonth': serializer.toJson<int?>(budgetMinorPerMonth),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'budgetPeriod': serializer.toJson<String>(budgetPeriod),
      'budgetCustomDays': serializer.toJson<int?>(budgetCustomDays),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? iconCodePoint,
    Value<int?> budgetMinorPerMonth = const Value.absent(),
    String? scope,
    DateTime? createdAt,
    String? budgetPeriod,
    Value<int?> budgetCustomDays = const Value.absent(),
  }) => ExpenseCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    budgetMinorPerMonth: budgetMinorPerMonth.present
        ? budgetMinorPerMonth.value
        : this.budgetMinorPerMonth,
    scope: scope ?? this.scope,
    createdAt: createdAt ?? this.createdAt,
    budgetPeriod: budgetPeriod ?? this.budgetPeriod,
    budgetCustomDays: budgetCustomDays.present
        ? budgetCustomDays.value
        : this.budgetCustomDays,
  );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      budgetMinorPerMonth: data.budgetMinorPerMonth.present
          ? data.budgetMinorPerMonth.value
          : this.budgetMinorPerMonth,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      budgetPeriod: data.budgetPeriod.present
          ? data.budgetPeriod.value
          : this.budgetPeriod,
      budgetCustomDays: data.budgetCustomDays.present
          ? data.budgetCustomDays.value
          : this.budgetCustomDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('budgetMinorPerMonth: $budgetMinorPerMonth, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('budgetPeriod: $budgetPeriod, ')
          ..write('budgetCustomDays: $budgetCustomDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorHex,
    iconCodePoint,
    budgetMinorPerMonth,
    scope,
    createdAt,
    budgetPeriod,
    budgetCustomDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.iconCodePoint == this.iconCodePoint &&
          other.budgetMinorPerMonth == this.budgetMinorPerMonth &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt &&
          other.budgetPeriod == this.budgetPeriod &&
          other.budgetCustomDays == this.budgetCustomDays);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<int> iconCodePoint;
  final Value<int?> budgetMinorPerMonth;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  final Value<String> budgetPeriod;
  final Value<int?> budgetCustomDays;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.budgetMinorPerMonth = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.budgetPeriod = const Value.absent(),
    this.budgetCustomDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    required int iconCodePoint,
    this.budgetMinorPerMonth = const Value.absent(),
    required String scope,
    required DateTime createdAt,
    this.budgetPeriod = const Value.absent(),
    this.budgetCustomDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconCodePoint = Value(iconCodePoint),
       scope = Value(scope),
       createdAt = Value(createdAt);
  static Insertable<ExpenseCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? iconCodePoint,
    Expression<int>? budgetMinorPerMonth,
    Expression<String>? scope,
    Expression<DateTime>? createdAt,
    Expression<String>? budgetPeriod,
    Expression<int>? budgetCustomDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (budgetMinorPerMonth != null)
        'budget_minor_per_month': budgetMinorPerMonth,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
      if (budgetPeriod != null) 'budget_period': budgetPeriod,
      if (budgetCustomDays != null) 'budget_custom_days': budgetCustomDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<int>? iconCodePoint,
    Value<int?>? budgetMinorPerMonth,
    Value<String>? scope,
    Value<DateTime>? createdAt,
    Value<String>? budgetPeriod,
    Value<int?>? budgetCustomDays,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      budgetMinorPerMonth: budgetMinorPerMonth ?? this.budgetMinorPerMonth,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      budgetCustomDays: budgetCustomDays ?? this.budgetCustomDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (budgetMinorPerMonth.present) {
      map['budget_minor_per_month'] = Variable<int>(budgetMinorPerMonth.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (budgetPeriod.present) {
      map['budget_period'] = Variable<String>(budgetPeriod.value);
    }
    if (budgetCustomDays.present) {
      map['budget_custom_days'] = Variable<int>(budgetCustomDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('budgetMinorPerMonth: $budgetMinorPerMonth, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('budgetPeriod: $budgetPeriod, ')
          ..write('budgetCustomDays: $budgetCustomDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsTable extends WishlistItems
    with TableInfo<$WishlistItemsTable, WishlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPurchasedMeta = const VerificationMeta(
    'isPurchased',
  );
  @override
  late final GeneratedColumn<bool> isPurchased = GeneratedColumn<bool>(
    'is_purchased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_purchased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromCurrencyJsonMeta = const VerificationMeta(
    'fromCurrencyJson',
  );
  @override
  late final GeneratedColumn<String> fromCurrencyJson = GeneratedColumn<String>(
    'from_currency_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amountMinor,
    currencyCode,
    note,
    categoryId,
    isPurchased,
    createdAt,
    purchasedAt,
    fromCurrencyJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('is_purchased')) {
      context.handle(
        _isPurchasedMeta,
        isPurchased.isAcceptableOrUnknown(
          data['is_purchased']!,
          _isPurchasedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    }
    if (data.containsKey('from_currency_json')) {
      context.handle(
        _fromCurrencyJsonMeta,
        fromCurrencyJson.isAcceptableOrUnknown(
          data['from_currency_json']!,
          _fromCurrencyJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      isPurchased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_purchased'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      ),
      fromCurrencyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_currency_json'],
      ),
    );
  }

  @override
  $WishlistItemsTable createAlias(String alias) {
    return $WishlistItemsTable(attachedDatabase, alias);
  }
}

class WishlistItem extends DataClass implements Insertable<WishlistItem> {
  final String id;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String? note;
  final String? categoryId;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? purchasedAt;
  final String? fromCurrencyJson;
  const WishlistItem({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    this.note,
    this.categoryId,
    required this.isPurchased,
    required this.createdAt,
    this.purchasedAt,
    this.fromCurrencyJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['is_purchased'] = Variable<bool>(isPurchased);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || purchasedAt != null) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt);
    }
    if (!nullToAbsent || fromCurrencyJson != null) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson);
    }
    return map;
  }

  WishlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCompanion(
      id: Value(id),
      title: Value(title),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      isPurchased: Value(isPurchased),
      createdAt: Value(createdAt),
      purchasedAt: purchasedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasedAt),
      fromCurrencyJson: fromCurrencyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCurrencyJson),
    );
  }

  factory WishlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItem(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      note: serializer.fromJson<String?>(json['note']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      isPurchased: serializer.fromJson<bool>(json['isPurchased']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      purchasedAt: serializer.fromJson<DateTime?>(json['purchasedAt']),
      fromCurrencyJson: serializer.fromJson<String?>(json['fromCurrencyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'note': serializer.toJson<String?>(note),
      'categoryId': serializer.toJson<String?>(categoryId),
      'isPurchased': serializer.toJson<bool>(isPurchased),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'purchasedAt': serializer.toJson<DateTime?>(purchasedAt),
      'fromCurrencyJson': serializer.toJson<String?>(fromCurrencyJson),
    };
  }

  WishlistItem copyWith({
    String? id,
    String? title,
    int? amountMinor,
    String? currencyCode,
    Value<String?> note = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    bool? isPurchased,
    DateTime? createdAt,
    Value<DateTime?> purchasedAt = const Value.absent(),
    Value<String?> fromCurrencyJson = const Value.absent(),
  }) => WishlistItem(
    id: id ?? this.id,
    title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    note: note.present ? note.value : this.note,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    isPurchased: isPurchased ?? this.isPurchased,
    createdAt: createdAt ?? this.createdAt,
    purchasedAt: purchasedAt.present ? purchasedAt.value : this.purchasedAt,
    fromCurrencyJson: fromCurrencyJson.present
        ? fromCurrencyJson.value
        : this.fromCurrencyJson,
  );
  WishlistItem copyWithCompanion(WishlistItemsCompanion data) {
    return WishlistItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      note: data.note.present ? data.note.value : this.note,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      isPurchased: data.isPurchased.present
          ? data.isPurchased.value
          : this.isPurchased,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      fromCurrencyJson: data.fromCurrencyJson.present
          ? data.fromCurrencyJson.value
          : this.fromCurrencyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('createdAt: $createdAt, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('fromCurrencyJson: $fromCurrencyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amountMinor,
    currencyCode,
    note,
    categoryId,
    isPurchased,
    createdAt,
    purchasedAt,
    fromCurrencyJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.note == this.note &&
          other.categoryId == this.categoryId &&
          other.isPurchased == this.isPurchased &&
          other.createdAt == this.createdAt &&
          other.purchasedAt == this.purchasedAt &&
          other.fromCurrencyJson == this.fromCurrencyJson);
}

class WishlistItemsCompanion extends UpdateCompanion<WishlistItem> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> note;
  final Value<String?> categoryId;
  final Value<bool> isPurchased;
  final Value<DateTime> createdAt;
  final Value<DateTime?> purchasedAt;
  final Value<String?> fromCurrencyJson;
  final Value<int> rowid;
  const WishlistItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isPurchased = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistItemsCompanion.insert({
    required String id,
    required String title,
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isPurchased = const Value.absent(),
    required DateTime createdAt,
    this.purchasedAt = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amountMinor = Value(amountMinor),
       createdAt = Value(createdAt);
  static Insertable<WishlistItem> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? note,
    Expression<String>? categoryId,
    Expression<bool>? isPurchased,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? purchasedAt,
    Expression<String>? fromCurrencyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (note != null) 'note': note,
      if (categoryId != null) 'category_id': categoryId,
      if (isPurchased != null) 'is_purchased': isPurchased,
      if (createdAt != null) 'created_at': createdAt,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (fromCurrencyJson != null) 'from_currency_json': fromCurrencyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String?>? note,
    Value<String?>? categoryId,
    Value<bool>? isPurchased,
    Value<DateTime>? createdAt,
    Value<DateTime?>? purchasedAt,
    Value<String?>? fromCurrencyJson,
    Value<int>? rowid,
  }) {
    return WishlistItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      fromCurrencyJson: fromCurrencyJson ?? this.fromCurrencyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isPurchased.present) {
      map['is_purchased'] = Variable<bool>(isPurchased.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (fromCurrencyJson.present) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('createdAt: $createdAt, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionItemsTable extends SubscriptionItems
    with TableInfo<$SubscriptionItemsTable, SubscriptionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DZD'),
  );
  static const VerificationMeta _fromCurrencyJsonMeta = const VerificationMeta(
    'fromCurrencyJson',
  );
  @override
  late final GeneratedColumn<String> fromCurrencyJson = GeneratedColumn<String>(
    'from_currency_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billingDayOfMonthMeta = const VerificationMeta(
    'billingDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> billingDayOfMonth = GeneratedColumn<int>(
    'billing_day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rollingDaysMeta = const VerificationMeta(
    'rollingDays',
  );
  @override
  late final GeneratedColumn<int> rollingDays = GeneratedColumn<int>(
    'rolling_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastLoggedAtMeta = const VerificationMeta(
    'lastLoggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoggedAt = GeneratedColumn<DateTime>(
    'last_logged_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _warnBeforeDaysMeta = const VerificationMeta(
    'warnBeforeDays',
  );
  @override
  late final GeneratedColumn<int> warnBeforeDays = GeneratedColumn<int>(
    'warn_before_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amountMinor,
    currencyCode,
    fromCurrencyJson,
    note,
    categoryId,
    scheduleType,
    billingDayOfMonth,
    rollingDays,
    nextDueAt,
    lastLoggedAt,
    isActive,
    warnBeforeDays,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('from_currency_json')) {
      context.handle(
        _fromCurrencyJsonMeta,
        fromCurrencyJson.isAcceptableOrUnknown(
          data['from_currency_json']!,
          _fromCurrencyJsonMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('billing_day_of_month')) {
      context.handle(
        _billingDayOfMonthMeta,
        billingDayOfMonth.isAcceptableOrUnknown(
          data['billing_day_of_month']!,
          _billingDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('rolling_days')) {
      context.handle(
        _rollingDaysMeta,
        rollingDays.isAcceptableOrUnknown(
          data['rolling_days']!,
          _rollingDaysMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDueAtMeta);
    }
    if (data.containsKey('last_logged_at')) {
      context.handle(
        _lastLoggedAtMeta,
        lastLoggedAt.isAcceptableOrUnknown(
          data['last_logged_at']!,
          _lastLoggedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('warn_before_days')) {
      context.handle(
        _warnBeforeDaysMeta,
        warnBeforeDays.isAcceptableOrUnknown(
          data['warn_before_days']!,
          _warnBeforeDaysMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      fromCurrencyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_currency_json'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      billingDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_day_of_month'],
      ),
      rollingDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rolling_days'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      )!,
      lastLoggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_logged_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      warnBeforeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warn_before_days'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SubscriptionItemsTable createAlias(String alias) {
    return $SubscriptionItemsTable(attachedDatabase, alias);
  }
}

class SubscriptionItem extends DataClass
    implements Insertable<SubscriptionItem> {
  final String id;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String? fromCurrencyJson;
  final String? note;
  final String? categoryId;

  /// day_of_month | rolling_days
  final String scheduleType;
  final int? billingDayOfMonth;
  final int? rollingDays;
  final DateTime nextDueAt;
  final DateTime? lastLoggedAt;
  final bool isActive;

  /// Days before nextDueAt to fire a warning notification (null = disabled)
  final int? warnBeforeDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SubscriptionItem({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    this.fromCurrencyJson,
    this.note,
    this.categoryId,
    required this.scheduleType,
    this.billingDayOfMonth,
    this.rollingDays,
    required this.nextDueAt,
    this.lastLoggedAt,
    required this.isActive,
    this.warnBeforeDays,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || fromCurrencyJson != null) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || billingDayOfMonth != null) {
      map['billing_day_of_month'] = Variable<int>(billingDayOfMonth);
    }
    if (!nullToAbsent || rollingDays != null) {
      map['rolling_days'] = Variable<int>(rollingDays);
    }
    map['next_due_at'] = Variable<DateTime>(nextDueAt);
    if (!nullToAbsent || lastLoggedAt != null) {
      map['last_logged_at'] = Variable<DateTime>(lastLoggedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || warnBeforeDays != null) {
      map['warn_before_days'] = Variable<int>(warnBeforeDays);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SubscriptionItemsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionItemsCompanion(
      id: Value(id),
      title: Value(title),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      fromCurrencyJson: fromCurrencyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCurrencyJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      scheduleType: Value(scheduleType),
      billingDayOfMonth: billingDayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(billingDayOfMonth),
      rollingDays: rollingDays == null && nullToAbsent
          ? const Value.absent()
          : Value(rollingDays),
      nextDueAt: Value(nextDueAt),
      lastLoggedAt: lastLoggedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoggedAt),
      isActive: Value(isActive),
      warnBeforeDays: warnBeforeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(warnBeforeDays),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SubscriptionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionItem(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      fromCurrencyJson: serializer.fromJson<String?>(json['fromCurrencyJson']),
      note: serializer.fromJson<String?>(json['note']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      billingDayOfMonth: serializer.fromJson<int?>(json['billingDayOfMonth']),
      rollingDays: serializer.fromJson<int?>(json['rollingDays']),
      nextDueAt: serializer.fromJson<DateTime>(json['nextDueAt']),
      lastLoggedAt: serializer.fromJson<DateTime?>(json['lastLoggedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      warnBeforeDays: serializer.fromJson<int?>(json['warnBeforeDays']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'fromCurrencyJson': serializer.toJson<String?>(fromCurrencyJson),
      'note': serializer.toJson<String?>(note),
      'categoryId': serializer.toJson<String?>(categoryId),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'billingDayOfMonth': serializer.toJson<int?>(billingDayOfMonth),
      'rollingDays': serializer.toJson<int?>(rollingDays),
      'nextDueAt': serializer.toJson<DateTime>(nextDueAt),
      'lastLoggedAt': serializer.toJson<DateTime?>(lastLoggedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'warnBeforeDays': serializer.toJson<int?>(warnBeforeDays),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SubscriptionItem copyWith({
    String? id,
    String? title,
    int? amountMinor,
    String? currencyCode,
    Value<String?> fromCurrencyJson = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? scheduleType,
    Value<int?> billingDayOfMonth = const Value.absent(),
    Value<int?> rollingDays = const Value.absent(),
    DateTime? nextDueAt,
    Value<DateTime?> lastLoggedAt = const Value.absent(),
    bool? isActive,
    Value<int?> warnBeforeDays = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SubscriptionItem(
    id: id ?? this.id,
    title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    fromCurrencyJson: fromCurrencyJson.present
        ? fromCurrencyJson.value
        : this.fromCurrencyJson,
    note: note.present ? note.value : this.note,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    scheduleType: scheduleType ?? this.scheduleType,
    billingDayOfMonth: billingDayOfMonth.present
        ? billingDayOfMonth.value
        : this.billingDayOfMonth,
    rollingDays: rollingDays.present ? rollingDays.value : this.rollingDays,
    nextDueAt: nextDueAt ?? this.nextDueAt,
    lastLoggedAt: lastLoggedAt.present ? lastLoggedAt.value : this.lastLoggedAt,
    isActive: isActive ?? this.isActive,
    warnBeforeDays: warnBeforeDays.present
        ? warnBeforeDays.value
        : this.warnBeforeDays,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SubscriptionItem copyWithCompanion(SubscriptionItemsCompanion data) {
    return SubscriptionItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      fromCurrencyJson: data.fromCurrencyJson.present
          ? data.fromCurrencyJson.value
          : this.fromCurrencyJson,
      note: data.note.present ? data.note.value : this.note,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      billingDayOfMonth: data.billingDayOfMonth.present
          ? data.billingDayOfMonth.value
          : this.billingDayOfMonth,
      rollingDays: data.rollingDays.present
          ? data.rollingDays.value
          : this.rollingDays,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      lastLoggedAt: data.lastLoggedAt.present
          ? data.lastLoggedAt.value
          : this.lastLoggedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      warnBeforeDays: data.warnBeforeDays.present
          ? data.warnBeforeDays.value
          : this.warnBeforeDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('billingDayOfMonth: $billingDayOfMonth, ')
          ..write('rollingDays: $rollingDays, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('lastLoggedAt: $lastLoggedAt, ')
          ..write('isActive: $isActive, ')
          ..write('warnBeforeDays: $warnBeforeDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amountMinor,
    currencyCode,
    fromCurrencyJson,
    note,
    categoryId,
    scheduleType,
    billingDayOfMonth,
    rollingDays,
    nextDueAt,
    lastLoggedAt,
    isActive,
    warnBeforeDays,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.fromCurrencyJson == this.fromCurrencyJson &&
          other.note == this.note &&
          other.categoryId == this.categoryId &&
          other.scheduleType == this.scheduleType &&
          other.billingDayOfMonth == this.billingDayOfMonth &&
          other.rollingDays == this.rollingDays &&
          other.nextDueAt == this.nextDueAt &&
          other.lastLoggedAt == this.lastLoggedAt &&
          other.isActive == this.isActive &&
          other.warnBeforeDays == this.warnBeforeDays &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubscriptionItemsCompanion extends UpdateCompanion<SubscriptionItem> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> fromCurrencyJson;
  final Value<String?> note;
  final Value<String?> categoryId;
  final Value<String> scheduleType;
  final Value<int?> billingDayOfMonth;
  final Value<int?> rollingDays;
  final Value<DateTime> nextDueAt;
  final Value<DateTime?> lastLoggedAt;
  final Value<bool> isActive;
  final Value<int?> warnBeforeDays;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SubscriptionItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.billingDayOfMonth = const Value.absent(),
    this.rollingDays = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.lastLoggedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.warnBeforeDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionItemsCompanion.insert({
    required String id,
    required String title,
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String scheduleType,
    this.billingDayOfMonth = const Value.absent(),
    this.rollingDays = const Value.absent(),
    required DateTime nextDueAt,
    this.lastLoggedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.warnBeforeDays = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amountMinor = Value(amountMinor),
       scheduleType = Value(scheduleType),
       nextDueAt = Value(nextDueAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SubscriptionItem> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? fromCurrencyJson,
    Expression<String>? note,
    Expression<String>? categoryId,
    Expression<String>? scheduleType,
    Expression<int>? billingDayOfMonth,
    Expression<int>? rollingDays,
    Expression<DateTime>? nextDueAt,
    Expression<DateTime>? lastLoggedAt,
    Expression<bool>? isActive,
    Expression<int>? warnBeforeDays,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (fromCurrencyJson != null) 'from_currency_json': fromCurrencyJson,
      if (note != null) 'note': note,
      if (categoryId != null) 'category_id': categoryId,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (billingDayOfMonth != null) 'billing_day_of_month': billingDayOfMonth,
      if (rollingDays != null) 'rolling_days': rollingDays,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (lastLoggedAt != null) 'last_logged_at': lastLoggedAt,
      if (isActive != null) 'is_active': isActive,
      if (warnBeforeDays != null) 'warn_before_days': warnBeforeDays,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String?>? fromCurrencyJson,
    Value<String?>? note,
    Value<String?>? categoryId,
    Value<String>? scheduleType,
    Value<int?>? billingDayOfMonth,
    Value<int?>? rollingDays,
    Value<DateTime>? nextDueAt,
    Value<DateTime?>? lastLoggedAt,
    Value<bool>? isActive,
    Value<int?>? warnBeforeDays,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SubscriptionItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      fromCurrencyJson: fromCurrencyJson ?? this.fromCurrencyJson,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      scheduleType: scheduleType ?? this.scheduleType,
      billingDayOfMonth: billingDayOfMonth ?? this.billingDayOfMonth,
      rollingDays: rollingDays ?? this.rollingDays,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      lastLoggedAt: lastLoggedAt ?? this.lastLoggedAt,
      isActive: isActive ?? this.isActive,
      warnBeforeDays: warnBeforeDays ?? this.warnBeforeDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (fromCurrencyJson.present) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (billingDayOfMonth.present) {
      map['billing_day_of_month'] = Variable<int>(billingDayOfMonth.value);
    }
    if (rollingDays.present) {
      map['rolling_days'] = Variable<int>(rollingDays.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (lastLoggedAt.present) {
      map['last_logged_at'] = Variable<DateTime>(lastLoggedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (warnBeforeDays.present) {
      map['warn_before_days'] = Variable<int>(warnBeforeDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('billingDayOfMonth: $billingDayOfMonth, ')
          ..write('rollingDays: $rollingDays, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('lastLoggedAt: $lastLoggedAt, ')
          ..write('isActive: $isActive, ')
          ..write('warnBeforeDays: $warnBeforeDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🎯'),
  );
  static const VerificationMeta _targetMinorMeta = const VerificationMeta(
    'targetMinor',
  );
  @override
  late final GeneratedColumn<int> targetMinor = GeneratedColumn<int>(
    'target_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedMinorMeta = const VerificationMeta(
    'savedMinor',
  );
  @override
  late final GeneratedColumn<int> savedMinor = GeneratedColumn<int>(
    'saved_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    targetMinor,
    savedMinor,
    note,
    deadline,
    isCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('target_minor')) {
      context.handle(
        _targetMinorMeta,
        targetMinor.isAcceptableOrUnknown(
          data['target_minor']!,
          _targetMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMinorMeta);
    }
    if (data.containsKey('saved_minor')) {
      context.handle(
        _savedMinorMeta,
        savedMinor.isAcceptableOrUnknown(data['saved_minor']!, _savedMinorMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      targetMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minor'],
      )!,
      savedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_minor'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final String id;
  final String name;
  final String emoji;
  final int targetMinor;
  final int savedMinor;
  final String? note;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetMinor,
    required this.savedMinor,
    this.note,
    this.deadline,
    required this.isCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['target_minor'] = Variable<int>(targetMinor);
    map['saved_minor'] = Variable<int>(savedMinor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      targetMinor: Value(targetMinor),
      savedMinor: Value(savedMinor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      targetMinor: serializer.fromJson<int>(json['targetMinor']),
      savedMinor: serializer.fromJson<int>(json['savedMinor']),
      note: serializer.fromJson<String?>(json['note']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'targetMinor': serializer.toJson<int>(targetMinor),
      'savedMinor': serializer.toJson<int>(savedMinor),
      'note': serializer.toJson<String?>(note),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    String? emoji,
    int? targetMinor,
    int? savedMinor,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> deadline = const Value.absent(),
    bool? isCompleted,
    DateTime? createdAt,
  }) => SavingsGoal(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    targetMinor: targetMinor ?? this.targetMinor,
    savedMinor: savedMinor ?? this.savedMinor,
    note: note.present ? note.value : this.note,
    deadline: deadline.present ? deadline.value : this.deadline,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      targetMinor: data.targetMinor.present
          ? data.targetMinor.value
          : this.targetMinor,
      savedMinor: data.savedMinor.present
          ? data.savedMinor.value
          : this.savedMinor,
      note: data.note.present ? data.note.value : this.note,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('savedMinor: $savedMinor, ')
          ..write('note: $note, ')
          ..write('deadline: $deadline, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    targetMinor,
    savedMinor,
    note,
    deadline,
    isCompleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.targetMinor == this.targetMinor &&
          other.savedMinor == this.savedMinor &&
          other.note == this.note &&
          other.deadline == this.deadline &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> targetMinor;
  final Value<int> savedMinor;
  final Value<String?> note;
  final Value<DateTime?> deadline;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.targetMinor = const Value.absent(),
    this.savedMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String name,
    this.emoji = const Value.absent(),
    required int targetMinor,
    this.savedMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetMinor = Value(targetMinor),
       createdAt = Value(createdAt);
  static Insertable<SavingsGoal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? targetMinor,
    Expression<int>? savedMinor,
    Expression<String>? note,
    Expression<DateTime>? deadline,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (targetMinor != null) 'target_minor': targetMinor,
      if (savedMinor != null) 'saved_minor': savedMinor,
      if (note != null) 'note': note,
      if (deadline != null) 'deadline': deadline,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? targetMinor,
    Value<int>? savedMinor,
    Value<String?>? note,
    Value<DateTime?>? deadline,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetMinor: targetMinor ?? this.targetMinor,
      savedMinor: savedMinor ?? this.savedMinor,
      note: note ?? this.note,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (targetMinor.present) {
      map['target_minor'] = Variable<int>(targetMinor.value);
    }
    if (savedMinor.present) {
      map['saved_minor'] = Variable<int>(savedMinor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('savedMinor: $savedMinor, ')
          ..write('note: $note, ')
          ..write('deadline: $deadline, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletLedgerEntriesTable extends WalletLedgerEntries
    with TableInfo<$WalletLedgerEntriesTable, WalletLedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletLedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallet_accounts (id)',
    ),
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceBeforeMinorMeta =
      const VerificationMeta('balanceBeforeMinor');
  @override
  late final GeneratedColumn<int> balanceBeforeMinor = GeneratedColumn<int>(
    'balance_before_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceAfterMinorMeta = const VerificationMeta(
    'balanceAfterMinor',
  );
  @override
  late final GeneratedColumn<int> balanceAfterMinor = GeneratedColumn<int>(
    'balance_after_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromCurrencyJsonMeta = const VerificationMeta(
    'fromCurrencyJson',
  );
  @override
  late final GeneratedColumn<String> fromCurrencyJson = GeneratedColumn<String>(
    'from_currency_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    opType,
    amountMinor,
    balanceBeforeMinor,
    balanceAfterMinor,
    note,
    source,
    referenceId,
    fromCurrencyJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletLedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('balance_before_minor')) {
      context.handle(
        _balanceBeforeMinorMeta,
        balanceBeforeMinor.isAcceptableOrUnknown(
          data['balance_before_minor']!,
          _balanceBeforeMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceBeforeMinorMeta);
    }
    if (data.containsKey('balance_after_minor')) {
      context.handle(
        _balanceAfterMinorMeta,
        balanceAfterMinor.isAcceptableOrUnknown(
          data['balance_after_minor']!,
          _balanceAfterMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMinorMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('from_currency_json')) {
      context.handle(
        _fromCurrencyJsonMeta,
        fromCurrencyJson.isAcceptableOrUnknown(
          data['from_currency_json']!,
          _fromCurrencyJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletLedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletLedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      balanceBeforeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_before_minor'],
      )!,
      balanceAfterMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after_minor'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      fromCurrencyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_currency_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WalletLedgerEntriesTable createAlias(String alias) {
    return $WalletLedgerEntriesTable(attachedDatabase, alias);
  }
}

class WalletLedgerEntry extends DataClass
    implements Insertable<WalletLedgerEntry> {
  final String id;
  final String accountId;
  final String opType;
  final int amountMinor;
  final int balanceBeforeMinor;
  final int balanceAfterMinor;
  final String? note;
  final String source;
  final String? referenceId;
  final String? fromCurrencyJson;
  final DateTime createdAt;
  const WalletLedgerEntry({
    required this.id,
    required this.accountId,
    required this.opType,
    required this.amountMinor,
    required this.balanceBeforeMinor,
    required this.balanceAfterMinor,
    this.note,
    required this.source,
    this.referenceId,
    this.fromCurrencyJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['op_type'] = Variable<String>(opType);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['balance_before_minor'] = Variable<int>(balanceBeforeMinor);
    map['balance_after_minor'] = Variable<int>(balanceAfterMinor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || fromCurrencyJson != null) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WalletLedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return WalletLedgerEntriesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      opType: Value(opType),
      amountMinor: Value(amountMinor),
      balanceBeforeMinor: Value(balanceBeforeMinor),
      balanceAfterMinor: Value(balanceAfterMinor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      fromCurrencyJson: fromCurrencyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCurrencyJson),
      createdAt: Value(createdAt),
    );
  }

  factory WalletLedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletLedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      opType: serializer.fromJson<String>(json['opType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      balanceBeforeMinor: serializer.fromJson<int>(json['balanceBeforeMinor']),
      balanceAfterMinor: serializer.fromJson<int>(json['balanceAfterMinor']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      fromCurrencyJson: serializer.fromJson<String?>(json['fromCurrencyJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'opType': serializer.toJson<String>(opType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'balanceBeforeMinor': serializer.toJson<int>(balanceBeforeMinor),
      'balanceAfterMinor': serializer.toJson<int>(balanceAfterMinor),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'referenceId': serializer.toJson<String?>(referenceId),
      'fromCurrencyJson': serializer.toJson<String?>(fromCurrencyJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WalletLedgerEntry copyWith({
    String? id,
    String? accountId,
    String? opType,
    int? amountMinor,
    int? balanceBeforeMinor,
    int? balanceAfterMinor,
    Value<String?> note = const Value.absent(),
    String? source,
    Value<String?> referenceId = const Value.absent(),
    Value<String?> fromCurrencyJson = const Value.absent(),
    DateTime? createdAt,
  }) => WalletLedgerEntry(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    opType: opType ?? this.opType,
    amountMinor: amountMinor ?? this.amountMinor,
    balanceBeforeMinor: balanceBeforeMinor ?? this.balanceBeforeMinor,
    balanceAfterMinor: balanceAfterMinor ?? this.balanceAfterMinor,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    fromCurrencyJson: fromCurrencyJson.present
        ? fromCurrencyJson.value
        : this.fromCurrencyJson,
    createdAt: createdAt ?? this.createdAt,
  );
  WalletLedgerEntry copyWithCompanion(WalletLedgerEntriesCompanion data) {
    return WalletLedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      opType: data.opType.present ? data.opType.value : this.opType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      balanceBeforeMinor: data.balanceBeforeMinor.present
          ? data.balanceBeforeMinor.value
          : this.balanceBeforeMinor,
      balanceAfterMinor: data.balanceAfterMinor.present
          ? data.balanceAfterMinor.value
          : this.balanceAfterMinor,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      fromCurrencyJson: data.fromCurrencyJson.present
          ? data.fromCurrencyJson.value
          : this.fromCurrencyJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletLedgerEntry(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('opType: $opType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('balanceBeforeMinor: $balanceBeforeMinor, ')
          ..write('balanceAfterMinor: $balanceAfterMinor, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('referenceId: $referenceId, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    opType,
    amountMinor,
    balanceBeforeMinor,
    balanceAfterMinor,
    note,
    source,
    referenceId,
    fromCurrencyJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletLedgerEntry &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.opType == this.opType &&
          other.amountMinor == this.amountMinor &&
          other.balanceBeforeMinor == this.balanceBeforeMinor &&
          other.balanceAfterMinor == this.balanceAfterMinor &&
          other.note == this.note &&
          other.source == this.source &&
          other.referenceId == this.referenceId &&
          other.fromCurrencyJson == this.fromCurrencyJson &&
          other.createdAt == this.createdAt);
}

class WalletLedgerEntriesCompanion extends UpdateCompanion<WalletLedgerEntry> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> opType;
  final Value<int> amountMinor;
  final Value<int> balanceBeforeMinor;
  final Value<int> balanceAfterMinor;
  final Value<String?> note;
  final Value<String> source;
  final Value<String?> referenceId;
  final Value<String?> fromCurrencyJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WalletLedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.opType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.balanceBeforeMinor = const Value.absent(),
    this.balanceAfterMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletLedgerEntriesCompanion.insert({
    required String id,
    required String accountId,
    required String opType,
    required int amountMinor,
    required int balanceBeforeMinor,
    required int balanceAfterMinor,
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.fromCurrencyJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       opType = Value(opType),
       amountMinor = Value(amountMinor),
       balanceBeforeMinor = Value(balanceBeforeMinor),
       balanceAfterMinor = Value(balanceAfterMinor),
       createdAt = Value(createdAt);
  static Insertable<WalletLedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? opType,
    Expression<int>? amountMinor,
    Expression<int>? balanceBeforeMinor,
    Expression<int>? balanceAfterMinor,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? referenceId,
    Expression<String>? fromCurrencyJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (opType != null) 'op_type': opType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (balanceBeforeMinor != null)
        'balance_before_minor': balanceBeforeMinor,
      if (balanceAfterMinor != null) 'balance_after_minor': balanceAfterMinor,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (referenceId != null) 'reference_id': referenceId,
      if (fromCurrencyJson != null) 'from_currency_json': fromCurrencyJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletLedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? opType,
    Value<int>? amountMinor,
    Value<int>? balanceBeforeMinor,
    Value<int>? balanceAfterMinor,
    Value<String?>? note,
    Value<String>? source,
    Value<String?>? referenceId,
    Value<String?>? fromCurrencyJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WalletLedgerEntriesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      opType: opType ?? this.opType,
      amountMinor: amountMinor ?? this.amountMinor,
      balanceBeforeMinor: balanceBeforeMinor ?? this.balanceBeforeMinor,
      balanceAfterMinor: balanceAfterMinor ?? this.balanceAfterMinor,
      note: note ?? this.note,
      source: source ?? this.source,
      referenceId: referenceId ?? this.referenceId,
      fromCurrencyJson: fromCurrencyJson ?? this.fromCurrencyJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (balanceBeforeMinor.present) {
      map['balance_before_minor'] = Variable<int>(balanceBeforeMinor.value);
    }
    if (balanceAfterMinor.present) {
      map['balance_after_minor'] = Variable<int>(balanceAfterMinor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (fromCurrencyJson.present) {
      map['from_currency_json'] = Variable<String>(fromCurrencyJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletLedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('opType: $opType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('balanceBeforeMinor: $balanceBeforeMinor, ')
          ..write('balanceAfterMinor: $balanceAfterMinor, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('referenceId: $referenceId, ')
          ..write('fromCurrencyJson: $fromCurrencyJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManagedCurrenciesTable extends ManagedCurrencies
    with TableInfo<$ManagedCurrenciesTable, ManagedCurrency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagedCurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fractionDigitsMeta = const VerificationMeta(
    'fractionDigits',
  );
  @override
  late final GeneratedColumn<int> fractionDigits = GeneratedColumn<int>(
    'fraction_digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, fractionDigits, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'managed_currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagedCurrency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('fraction_digits')) {
      context.handle(
        _fractionDigitsMeta,
        fractionDigits.isAcceptableOrUnknown(
          data['fraction_digits']!,
          _fractionDigitsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ManagedCurrency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagedCurrency(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      fractionDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fraction_digits'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ManagedCurrenciesTable createAlias(String alias) {
    return $ManagedCurrenciesTable(attachedDatabase, alias);
  }
}

class ManagedCurrency extends DataClass implements Insertable<ManagedCurrency> {
  final String code;
  final int fractionDigits;
  final DateTime createdAt;
  const ManagedCurrency({
    required this.code,
    required this.fractionDigits,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['fraction_digits'] = Variable<int>(fractionDigits);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ManagedCurrenciesCompanion toCompanion(bool nullToAbsent) {
    return ManagedCurrenciesCompanion(
      code: Value(code),
      fractionDigits: Value(fractionDigits),
      createdAt: Value(createdAt),
    );
  }

  factory ManagedCurrency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagedCurrency(
      code: serializer.fromJson<String>(json['code']),
      fractionDigits: serializer.fromJson<int>(json['fractionDigits']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'fractionDigits': serializer.toJson<int>(fractionDigits),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ManagedCurrency copyWith({
    String? code,
    int? fractionDigits,
    DateTime? createdAt,
  }) => ManagedCurrency(
    code: code ?? this.code,
    fractionDigits: fractionDigits ?? this.fractionDigits,
    createdAt: createdAt ?? this.createdAt,
  );
  ManagedCurrency copyWithCompanion(ManagedCurrenciesCompanion data) {
    return ManagedCurrency(
      code: data.code.present ? data.code.value : this.code,
      fractionDigits: data.fractionDigits.present
          ? data.fractionDigits.value
          : this.fractionDigits,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagedCurrency(')
          ..write('code: $code, ')
          ..write('fractionDigits: $fractionDigits, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, fractionDigits, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagedCurrency &&
          other.code == this.code &&
          other.fractionDigits == this.fractionDigits &&
          other.createdAt == this.createdAt);
}

class ManagedCurrenciesCompanion extends UpdateCompanion<ManagedCurrency> {
  final Value<String> code;
  final Value<int> fractionDigits;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ManagedCurrenciesCompanion({
    this.code = const Value.absent(),
    this.fractionDigits = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManagedCurrenciesCompanion.insert({
    required String code,
    this.fractionDigits = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       createdAt = Value(createdAt);
  static Insertable<ManagedCurrency> custom({
    Expression<String>? code,
    Expression<int>? fractionDigits,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (fractionDigits != null) 'fraction_digits': fractionDigits,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManagedCurrenciesCompanion copyWith({
    Value<String>? code,
    Value<int>? fractionDigits,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ManagedCurrenciesCompanion(
      code: code ?? this.code,
      fractionDigits: fractionDigits ?? this.fractionDigits,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (fractionDigits.present) {
      map['fraction_digits'] = Variable<int>(fractionDigits.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManagedCurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('fractionDigits: $fractionDigits, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRateHistoryTable extends ExchangeRateHistory
    with TableInfo<$ExchangeRateHistoryTable, ExchangeRateHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRateHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES managed_currencies (code)',
    ),
  );
  static const VerificationMeta _rateToDefaultMeta = const VerificationMeta(
    'rateToDefault',
  );
  @override
  late final GeneratedColumn<int> rateToDefault = GeneratedColumn<int>(
    'rate_to_default',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateScaleMeta = const VerificationMeta(
    'rateScale',
  );
  @override
  late final GeneratedColumn<int> rateScale = GeneratedColumn<int>(
    'rate_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currencyCode,
    rateToDefault,
    rateScale,
    recordedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rate_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('rate_to_default')) {
      context.handle(
        _rateToDefaultMeta,
        rateToDefault.isAcceptableOrUnknown(
          data['rate_to_default']!,
          _rateToDefaultMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateToDefaultMeta);
    }
    if (data.containsKey('rate_scale')) {
      context.handle(
        _rateScaleMeta,
        rateScale.isAcceptableOrUnknown(data['rate_scale']!, _rateScaleMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRateHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      rateToDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_to_default'],
      )!,
      rateScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_scale'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ExchangeRateHistoryTable createAlias(String alias) {
    return $ExchangeRateHistoryTable(attachedDatabase, alias);
  }
}

class ExchangeRateHistoryData extends DataClass
    implements Insertable<ExchangeRateHistoryData> {
  final String id;
  final String currencyCode;
  final int rateToDefault;
  final int rateScale;
  final DateTime recordedAt;
  final String? note;
  const ExchangeRateHistoryData({
    required this.id,
    required this.currencyCode,
    required this.rateToDefault,
    required this.rateScale,
    required this.recordedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['currency_code'] = Variable<String>(currencyCode);
    map['rate_to_default'] = Variable<int>(rateToDefault);
    map['rate_scale'] = Variable<int>(rateScale);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ExchangeRateHistoryCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRateHistoryCompanion(
      id: Value(id),
      currencyCode: Value(currencyCode),
      rateToDefault: Value(rateToDefault),
      rateScale: Value(rateScale),
      recordedAt: Value(recordedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ExchangeRateHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateHistoryData(
      id: serializer.fromJson<String>(json['id']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      rateToDefault: serializer.fromJson<int>(json['rateToDefault']),
      rateScale: serializer.fromJson<int>(json['rateScale']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'rateToDefault': serializer.toJson<int>(rateToDefault),
      'rateScale': serializer.toJson<int>(rateScale),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  ExchangeRateHistoryData copyWith({
    String? id,
    String? currencyCode,
    int? rateToDefault,
    int? rateScale,
    DateTime? recordedAt,
    Value<String?> note = const Value.absent(),
  }) => ExchangeRateHistoryData(
    id: id ?? this.id,
    currencyCode: currencyCode ?? this.currencyCode,
    rateToDefault: rateToDefault ?? this.rateToDefault,
    rateScale: rateScale ?? this.rateScale,
    recordedAt: recordedAt ?? this.recordedAt,
    note: note.present ? note.value : this.note,
  );
  ExchangeRateHistoryData copyWithCompanion(ExchangeRateHistoryCompanion data) {
    return ExchangeRateHistoryData(
      id: data.id.present ? data.id.value : this.id,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      rateToDefault: data.rateToDefault.present
          ? data.rateToDefault.value
          : this.rateToDefault,
      rateScale: data.rateScale.present ? data.rateScale.value : this.rateScale,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateHistoryData(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToDefault: $rateToDefault, ')
          ..write('rateScale: $rateScale, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currencyCode, rateToDefault, rateScale, recordedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateHistoryData &&
          other.id == this.id &&
          other.currencyCode == this.currencyCode &&
          other.rateToDefault == this.rateToDefault &&
          other.rateScale == this.rateScale &&
          other.recordedAt == this.recordedAt &&
          other.note == this.note);
}

class ExchangeRateHistoryCompanion
    extends UpdateCompanion<ExchangeRateHistoryData> {
  final Value<String> id;
  final Value<String> currencyCode;
  final Value<int> rateToDefault;
  final Value<int> rateScale;
  final Value<DateTime> recordedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const ExchangeRateHistoryCompanion({
    this.id = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.rateToDefault = const Value.absent(),
    this.rateScale = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRateHistoryCompanion.insert({
    required String id,
    required String currencyCode,
    required int rateToDefault,
    this.rateScale = const Value.absent(),
    required DateTime recordedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       currencyCode = Value(currencyCode),
       rateToDefault = Value(rateToDefault),
       recordedAt = Value(recordedAt);
  static Insertable<ExchangeRateHistoryData> custom({
    Expression<String>? id,
    Expression<String>? currencyCode,
    Expression<int>? rateToDefault,
    Expression<int>? rateScale,
    Expression<DateTime>? recordedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (rateToDefault != null) 'rate_to_default': rateToDefault,
      if (rateScale != null) 'rate_scale': rateScale,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRateHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? currencyCode,
    Value<int>? rateToDefault,
    Value<int>? rateScale,
    Value<DateTime>? recordedAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ExchangeRateHistoryCompanion(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      rateToDefault: rateToDefault ?? this.rateToDefault,
      rateScale: rateScale ?? this.rateScale,
      recordedAt: recordedAt ?? this.recordedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (rateToDefault.present) {
      map['rate_to_default'] = Variable<int>(rateToDefault.value);
    }
    if (rateScale.present) {
      map['rate_scale'] = Variable<int>(rateScale.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateHistoryCompanion(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToDefault: $rateToDefault, ')
          ..write('rateScale: $rateScale, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ClientTagsTable clientTags = $ClientTagsTable(this);
  late final $LedgerTransactionsTable ledgerTransactions =
      $LedgerTransactionsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $QuickActionUsagesTable quickActionUsages =
      $QuickActionUsagesTable(this);
  late final $WalletAccountsTable walletAccounts = $WalletAccountsTable(this);
  late final $PersonalFinanceEntriesTable personalFinanceEntries =
      $PersonalFinanceEntriesTable(this);
  late final $PersonalFinanceFavoritesTable personalFinanceFavorites =
      $PersonalFinanceFavoritesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TransactionTemplatesTable transactionTemplates =
      $TransactionTemplatesTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $WishlistItemsTable wishlistItems = $WishlistItemsTable(this);
  late final $SubscriptionItemsTable subscriptionItems =
      $SubscriptionItemsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $WalletLedgerEntriesTable walletLedgerEntries =
      $WalletLedgerEntriesTable(this);
  late final $ManagedCurrenciesTable managedCurrencies =
      $ManagedCurrenciesTable(this);
  late final $ExchangeRateHistoryTable exchangeRateHistory =
      $ExchangeRateHistoryTable(this);
  late final Index idxClientsArchivedAt = Index(
    'idx_clients_archived_at',
    'CREATE INDEX idx_clients_archived_at ON clients (archived_at)',
  );
  late final Index idxClientTagsClient = Index(
    'idx_client_tags_client',
    'CREATE INDEX idx_client_tags_client ON client_tags (client_id)',
  );
  late final Index idxTransactionsClientCreated = Index(
    'idx_transactions_client_created',
    'CREATE INDEX idx_transactions_client_created ON ledger_transactions (client_id, created_at)',
  );
  late final Index idxTxTagsTx = Index(
    'idx_tx_tags_tx',
    'CREATE INDEX idx_tx_tags_tx ON transaction_tags (transaction_id)',
  );
  late final Index idxPersonalFinanceKindCreated = Index(
    'idx_personal_finance_kind_created',
    'CREATE INDEX idx_personal_finance_kind_created ON personal_finance_entries (kind, created_at)',
  );
  late final Index idxAuditLogCreated = Index(
    'idx_audit_log_created',
    'CREATE INDEX idx_audit_log_created ON audit_log (created_at)',
  );
  late final Index idxWalletLedgerAccountCreated = Index(
    'idx_wallet_ledger_account_created',
    'CREATE INDEX idx_wallet_ledger_account_created ON wallet_ledger_entries (account_id, created_at)',
  );
  late final Index idxExchangeRateCurrencyRecorded = Index(
    'idx_exchange_rate_currency_recorded',
    'CREATE INDEX idx_exchange_rate_currency_recorded ON exchange_rate_history (currency_code, recorded_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    tags,
    clientTags,
    ledgerTransactions,
    transactionTags,
    quickActionUsages,
    walletAccounts,
    personalFinanceEntries,
    personalFinanceFavorites,
    appSettings,
    transactionTemplates,
    auditLog,
    expenseCategories,
    wishlistItems,
    subscriptionItems,
    savingsGoals,
    walletLedgerEntries,
    managedCurrencies,
    exchangeRateHistory,
    idxClientsArchivedAt,
    idxClientTagsClient,
    idxTransactionsClientCreated,
    idxTxTagsTx,
    idxPersonalFinanceKindCreated,
    idxAuditLogCreated,
    idxWalletLedgerAccountCreated,
    idxExchangeRateCurrencyRecorded,
  ];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      required String id,
      required String fullName,
      Value<String?> phone,
      Value<String?> note,
      Value<String?> externalRef,
      Value<String?> tagsJson,
      Value<String> source,
      Value<DateTime?> lastInteractionAt,
      required int balanceMinor,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String?> phone,
      Value<String?> note,
      Value<String?> externalRef,
      Value<String?> tagsJson,
      Value<String> source,
      Value<DateTime?> lastInteractionAt,
      Value<int> balanceMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientTagsTable, List<ClientTag>>
  _clientTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientTags,
    aliasName: $_aliasNameGenerator(db.clients.id, db.clientTags.clientId),
  );

  $$ClientTagsTableProcessedTableManager get clientTagsRefs {
    final manager = $$ClientTagsTableTableManager(
      $_db,
      $_db.clientTags,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LedgerTransactionsTable, List<LedgerTransaction>>
  _ledgerTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ledgerTransactions,
        aliasName: $_aliasNameGenerator(
          db.clients.id,
          db.ledgerTransactions.clientId,
        ),
      );

  $$LedgerTransactionsTableProcessedTableManager get ledgerTransactionsRefs {
    final manager = $$LedgerTransactionsTableTableManager(
      $_db,
      $_db.ledgerTransactions,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ledgerTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientTagsRefs(
    Expression<bool> Function($$ClientTagsTableFilterComposer f) f,
  ) {
    final $$ClientTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableFilterComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ledgerTransactionsRefs(
    Expression<bool> Function($$LedgerTransactionsTableFilterComposer f) f,
  ) {
    final $$LedgerTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerTransactions,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.ledgerTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> clientTagsRefs<T extends Object>(
    Expression<T> Function($$ClientTagsTableAnnotationComposer a) f,
  ) {
    final $$ClientTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ledgerTransactionsRefs<T extends Object>(
    Expression<T> Function($$LedgerTransactionsTableAnnotationComposer a) f,
  ) {
    final $$LedgerTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ledgerTransactions,
          getReferencedColumn: (t) => t.clientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LedgerTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.ledgerTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({
            bool clientTagsRefs,
            bool ledgerTransactionsRefs,
          })
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime?> lastInteractionAt = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                fullName: fullName,
                phone: phone,
                note: note,
                externalRef: externalRef,
                tagsJson: tagsJson,
                source: source,
                lastInteractionAt: lastInteractionAt,
                balanceMinor: balanceMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                Value<String?> phone = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime?> lastInteractionAt = const Value.absent(),
                required int balanceMinor,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                fullName: fullName,
                phone: phone,
                note: note,
                externalRef: externalRef,
                tagsJson: tagsJson,
                source: source,
                lastInteractionAt: lastInteractionAt,
                balanceMinor: balanceMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({clientTagsRefs = false, ledgerTransactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clientTagsRefs) db.clientTags,
                    if (ledgerTransactionsRefs) db.ledgerTransactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clientTagsRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          ClientTag
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._clientTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clientTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ledgerTransactionsRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          LedgerTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._ledgerTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool clientTagsRefs, bool ledgerTransactionsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<String> colorHex,
      required String scope,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> colorHex,
      Value<String> scope,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientTagsTable, List<ClientTag>>
  _clientTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.clientTags.tagId),
  );

  $$ClientTagsTableProcessedTableManager get clientTagsRefs {
    final manager = $$ClientTagsTableTableManager(
      $_db,
      $_db.clientTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTag>>
  _transactionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.transactionTags.tagId),
  );

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager = $$TransactionTagsTableTableManager(
      $_db,
      $_db.transactionTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientTagsRefs(
    Expression<bool> Function($$ClientTagsTableFilterComposer f) f,
  ) {
    final $$ClientTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableFilterComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionTagsRefs(
    Expression<bool> Function($$TransactionTagsTableFilterComposer f) f,
  ) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableFilterComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> clientTagsRefs<T extends Object>(
    Expression<T> Function($$ClientTagsTableAnnotationComposer a) f,
  ) {
    final $$ClientTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionTagsRefs<T extends Object>(
    Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f,
  ) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({
            bool clientTagsRefs,
            bool transactionTagsRefs,
          })
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                scope: scope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> colorHex = const Value.absent(),
                required String scope,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                scope: scope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({clientTagsRefs = false, transactionTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clientTagsRefs) db.clientTags,
                    if (transactionTagsRefs) db.transactionTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clientTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, ClientTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._clientTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).clientTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionTagsRefs)
                        await $_getPrefetchedData<
                          Tag,
                          $TagsTable,
                          TransactionTag
                        >(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._transactionTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool clientTagsRefs, bool transactionTagsRefs})
    >;
typedef $$ClientTagsTableCreateCompanionBuilder =
    ClientTagsCompanion Function({
      required String id,
      required String clientId,
      required String tagId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ClientTagsTableUpdateCompanionBuilder =
    ClientTagsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> tagId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ClientTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientTagsTable, ClientTag> {
  $$ClientTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.clientTags.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.clientTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClientTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientTagsTable,
          ClientTag,
          $$ClientTagsTableFilterComposer,
          $$ClientTagsTableOrderingComposer,
          $$ClientTagsTableAnnotationComposer,
          $$ClientTagsTableCreateCompanionBuilder,
          $$ClientTagsTableUpdateCompanionBuilder,
          (ClientTag, $$ClientTagsTableReferences),
          ClientTag,
          PrefetchHooks Function({bool clientId, bool tagId})
        > {
  $$ClientTagsTableTableManager(_$AppDatabase db, $ClientTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientTagsCompanion(
                id: id,
                clientId: clientId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String tagId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ClientTagsCompanion.insert(
                id: id,
                clientId: clientId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clientId,
                                referencedTable: $$ClientTagsTableReferences
                                    ._clientIdTable(db),
                                referencedColumn: $$ClientTagsTableReferences
                                    ._clientIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$ClientTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$ClientTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClientTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientTagsTable,
      ClientTag,
      $$ClientTagsTableFilterComposer,
      $$ClientTagsTableOrderingComposer,
      $$ClientTagsTableAnnotationComposer,
      $$ClientTagsTableCreateCompanionBuilder,
      $$ClientTagsTableUpdateCompanionBuilder,
      (ClientTag, $$ClientTagsTableReferences),
      ClientTag,
      PrefetchHooks Function({bool clientId, bool tagId})
    >;
typedef $$LedgerTransactionsTableCreateCompanionBuilder =
    LedgerTransactionsCompanion Function({
      required String id,
      required String clientId,
      required int amountMinor,
      Value<String> currencyCode,
      Value<String> createdBy,
      Value<String> channel,
      Value<String?> referenceNo,
      Value<DateTime?> effectiveAt,
      Value<int> attachmentsCount,
      Value<bool> isSettled,
      Value<DateTime?> settledAt,
      required int txType,
      required int txStatus,
      required int postedBalanceBeforeMinor,
      required int postedBalanceAfterMinor,
      Value<int?> cancelBalanceBeforeMinor,
      Value<int?> cancelBalanceAfterMinor,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> cancelledAt,
      Value<String?> note,
      Value<DateTime?> dueAt,
      Value<String?> fromCurrencyJson,
      Value<int> rowid,
    });
typedef $$LedgerTransactionsTableUpdateCompanionBuilder =
    LedgerTransactionsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> createdBy,
      Value<String> channel,
      Value<String?> referenceNo,
      Value<DateTime?> effectiveAt,
      Value<int> attachmentsCount,
      Value<bool> isSettled,
      Value<DateTime?> settledAt,
      Value<int> txType,
      Value<int> txStatus,
      Value<int> postedBalanceBeforeMinor,
      Value<int> postedBalanceAfterMinor,
      Value<int?> cancelBalanceBeforeMinor,
      Value<int?> cancelBalanceAfterMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> cancelledAt,
      Value<String?> note,
      Value<DateTime?> dueAt,
      Value<String?> fromCurrencyJson,
      Value<int> rowid,
    });

final class $$LedgerTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LedgerTransactionsTable,
          LedgerTransaction
        > {
  $$LedgerTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias(
        $_aliasNameGenerator(db.ledgerTransactions.clientId, db.clients.id),
      );

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTag>>
  _transactionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTags,
    aliasName: $_aliasNameGenerator(
      db.ledgerTransactions.id,
      db.transactionTags.transactionId,
    ),
  );

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager = $$TransactionTagsTableTableManager(
      $_db,
      $_db.transactionTags,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LedgerTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attachmentsCount => $composableBuilder(
    column: $table.attachmentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txStatus => $composableBuilder(
    column: $table.txStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postedBalanceBeforeMinor => $composableBuilder(
    column: $table.postedBalanceBeforeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postedBalanceAfterMinor => $composableBuilder(
    column: $table.postedBalanceAfterMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelBalanceBeforeMinor => $composableBuilder(
    column: $table.cancelBalanceBeforeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelBalanceAfterMinor => $composableBuilder(
    column: $table.cancelBalanceAfterMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionTagsRefs(
    Expression<bool> Function($$TransactionTagsTableFilterComposer f) f,
  ) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableFilterComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attachmentsCount => $composableBuilder(
    column: $table.attachmentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txStatus => $composableBuilder(
    column: $table.txStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postedBalanceBeforeMinor => $composableBuilder(
    column: $table.postedBalanceBeforeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postedBalanceAfterMinor => $composableBuilder(
    column: $table.postedBalanceAfterMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelBalanceBeforeMinor => $composableBuilder(
    column: $table.cancelBalanceBeforeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelBalanceAfterMinor => $composableBuilder(
    column: $table.cancelBalanceAfterMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attachmentsCount => $composableBuilder(
    column: $table.attachmentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<int> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<int> get txStatus =>
      $composableBuilder(column: $table.txStatus, builder: (column) => column);

  GeneratedColumn<int> get postedBalanceBeforeMinor => $composableBuilder(
    column: $table.postedBalanceBeforeMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get postedBalanceAfterMinor => $composableBuilder(
    column: $table.postedBalanceAfterMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelBalanceBeforeMinor => $composableBuilder(
    column: $table.cancelBalanceBeforeMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelBalanceAfterMinor => $composableBuilder(
    column: $table.cancelBalanceAfterMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => column,
  );

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionTagsRefs<T extends Object>(
    Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f,
  ) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerTransactionsTable,
          LedgerTransaction,
          $$LedgerTransactionsTableFilterComposer,
          $$LedgerTransactionsTableOrderingComposer,
          $$LedgerTransactionsTableAnnotationComposer,
          $$LedgerTransactionsTableCreateCompanionBuilder,
          $$LedgerTransactionsTableUpdateCompanionBuilder,
          (LedgerTransaction, $$LedgerTransactionsTableReferences),
          LedgerTransaction,
          PrefetchHooks Function({bool clientId, bool transactionTagsRefs})
        > {
  $$LedgerTransactionsTableTableManager(
    _$AppDatabase db,
    $LedgerTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<DateTime?> effectiveAt = const Value.absent(),
                Value<int> attachmentsCount = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int> txType = const Value.absent(),
                Value<int> txStatus = const Value.absent(),
                Value<int> postedBalanceBeforeMinor = const Value.absent(),
                Value<int> postedBalanceAfterMinor = const Value.absent(),
                Value<int?> cancelBalanceBeforeMinor = const Value.absent(),
                Value<int?> cancelBalanceAfterMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerTransactionsCompanion(
                id: id,
                clientId: clientId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                createdBy: createdBy,
                channel: channel,
                referenceNo: referenceNo,
                effectiveAt: effectiveAt,
                attachmentsCount: attachmentsCount,
                isSettled: isSettled,
                settledAt: settledAt,
                txType: txType,
                txStatus: txStatus,
                postedBalanceBeforeMinor: postedBalanceBeforeMinor,
                postedBalanceAfterMinor: postedBalanceAfterMinor,
                cancelBalanceBeforeMinor: cancelBalanceBeforeMinor,
                cancelBalanceAfterMinor: cancelBalanceAfterMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cancelledAt: cancelledAt,
                note: note,
                dueAt: dueAt,
                fromCurrencyJson: fromCurrencyJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required int amountMinor,
                Value<String> currencyCode = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<DateTime?> effectiveAt = const Value.absent(),
                Value<int> attachmentsCount = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                required int txType,
                required int txStatus,
                required int postedBalanceBeforeMinor,
                required int postedBalanceAfterMinor,
                Value<int?> cancelBalanceBeforeMinor = const Value.absent(),
                Value<int?> cancelBalanceAfterMinor = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerTransactionsCompanion.insert(
                id: id,
                clientId: clientId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                createdBy: createdBy,
                channel: channel,
                referenceNo: referenceNo,
                effectiveAt: effectiveAt,
                attachmentsCount: attachmentsCount,
                isSettled: isSettled,
                settledAt: settledAt,
                txType: txType,
                txStatus: txStatus,
                postedBalanceBeforeMinor: postedBalanceBeforeMinor,
                postedBalanceAfterMinor: postedBalanceAfterMinor,
                cancelBalanceBeforeMinor: cancelBalanceBeforeMinor,
                cancelBalanceAfterMinor: cancelBalanceAfterMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cancelledAt: cancelledAt,
                note: note,
                dueAt: dueAt,
                fromCurrencyJson: fromCurrencyJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgerTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({clientId = false, transactionTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionTagsRefs) db.transactionTags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable:
                                        $$LedgerTransactionsTableReferences
                                            ._clientIdTable(db),
                                    referencedColumn:
                                        $$LedgerTransactionsTableReferences
                                            ._clientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionTagsRefs)
                        await $_getPrefetchedData<
                          LedgerTransaction,
                          $LedgerTransactionsTable,
                          TransactionTag
                        >(
                          currentTable: table,
                          referencedTable: $$LedgerTransactionsTableReferences
                              ._transactionTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgerTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LedgerTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerTransactionsTable,
      LedgerTransaction,
      $$LedgerTransactionsTableFilterComposer,
      $$LedgerTransactionsTableOrderingComposer,
      $$LedgerTransactionsTableAnnotationComposer,
      $$LedgerTransactionsTableCreateCompanionBuilder,
      $$LedgerTransactionsTableUpdateCompanionBuilder,
      (LedgerTransaction, $$LedgerTransactionsTableReferences),
      LedgerTransaction,
      PrefetchHooks Function({bool clientId, bool transactionTagsRefs})
    >;
typedef $$TransactionTagsTableCreateCompanionBuilder =
    TransactionTagsCompanion Function({
      required String id,
      required String transactionId,
      required String tagId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TransactionTagsTableUpdateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> tagId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TransactionTagsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TransactionTagsTable, TransactionTag> {
  $$TransactionTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LedgerTransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.ledgerTransactions.createAlias(
        $_aliasNameGenerator(
          db.transactionTags.transactionId,
          db.ledgerTransactions.id,
        ),
      );

  $$LedgerTransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$LedgerTransactionsTableTableManager(
      $_db,
      $_db.ledgerTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.transactionTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgerTransactionsTableFilterComposer get transactionId {
    final $$LedgerTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.ledgerTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.ledgerTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgerTransactionsTableOrderingComposer get transactionId {
    final $$LedgerTransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.ledgerTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerTransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.ledgerTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LedgerTransactionsTableAnnotationComposer get transactionId {
    final $$LedgerTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.ledgerTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LedgerTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.ledgerTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTagsTable,
          TransactionTag,
          $$TransactionTagsTableFilterComposer,
          $$TransactionTagsTableOrderingComposer,
          $$TransactionTagsTableAnnotationComposer,
          $$TransactionTagsTableCreateCompanionBuilder,
          $$TransactionTagsTableUpdateCompanionBuilder,
          (TransactionTag, $$TransactionTagsTableReferences),
          TransactionTag,
          PrefetchHooks Function({bool transactionId, bool tagId})
        > {
  $$TransactionTagsTableTableManager(
    _$AppDatabase db,
    $TransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion(
                id: id,
                transactionId: transactionId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String tagId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion.insert(
                id: id,
                transactionId: transactionId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionTagsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionTagsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$TransactionTagsTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$TransactionTagsTableReferences
                                        ._tagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTagsTable,
      TransactionTag,
      $$TransactionTagsTableFilterComposer,
      $$TransactionTagsTableOrderingComposer,
      $$TransactionTagsTableAnnotationComposer,
      $$TransactionTagsTableCreateCompanionBuilder,
      $$TransactionTagsTableUpdateCompanionBuilder,
      (TransactionTag, $$TransactionTagsTableReferences),
      TransactionTag,
      PrefetchHooks Function({bool transactionId, bool tagId})
    >;
typedef $$QuickActionUsagesTableCreateCompanionBuilder =
    QuickActionUsagesCompanion Function({
      required String id,
      required int txType,
      required int amountMinor,
      Value<int> usesCount,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$QuickActionUsagesTableUpdateCompanionBuilder =
    QuickActionUsagesCompanion Function({
      Value<String> id,
      Value<int> txType,
      Value<int> amountMinor,
      Value<int> usesCount,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

class $$QuickActionUsagesTableFilterComposer
    extends Composer<_$AppDatabase, $QuickActionUsagesTable> {
  $$QuickActionUsagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usesCount => $composableBuilder(
    column: $table.usesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuickActionUsagesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickActionUsagesTable> {
  $$QuickActionUsagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usesCount => $composableBuilder(
    column: $table.usesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuickActionUsagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickActionUsagesTable> {
  $$QuickActionUsagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usesCount =>
      $composableBuilder(column: $table.usesCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$QuickActionUsagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickActionUsagesTable,
          QuickActionUsage,
          $$QuickActionUsagesTableFilterComposer,
          $$QuickActionUsagesTableOrderingComposer,
          $$QuickActionUsagesTableAnnotationComposer,
          $$QuickActionUsagesTableCreateCompanionBuilder,
          $$QuickActionUsagesTableUpdateCompanionBuilder,
          (
            QuickActionUsage,
            BaseReferences<
              _$AppDatabase,
              $QuickActionUsagesTable,
              QuickActionUsage
            >,
          ),
          QuickActionUsage,
          PrefetchHooks Function()
        > {
  $$QuickActionUsagesTableTableManager(
    _$AppDatabase db,
    $QuickActionUsagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickActionUsagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickActionUsagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickActionUsagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> txType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> usesCount = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickActionUsagesCompanion(
                id: id,
                txType: txType,
                amountMinor: amountMinor,
                usesCount: usesCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int txType,
                required int amountMinor,
                Value<int> usesCount = const Value.absent(),
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuickActionUsagesCompanion.insert(
                id: id,
                txType: txType,
                amountMinor: amountMinor,
                usesCount: usesCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuickActionUsagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickActionUsagesTable,
      QuickActionUsage,
      $$QuickActionUsagesTableFilterComposer,
      $$QuickActionUsagesTableOrderingComposer,
      $$QuickActionUsagesTableAnnotationComposer,
      $$QuickActionUsagesTableCreateCompanionBuilder,
      $$QuickActionUsagesTableUpdateCompanionBuilder,
      (
        QuickActionUsage,
        BaseReferences<
          _$AppDatabase,
          $QuickActionUsagesTable,
          QuickActionUsage
        >,
      ),
      QuickActionUsage,
      PrefetchHooks Function()
    >;
typedef $$WalletAccountsTableCreateCompanionBuilder =
    WalletAccountsCompanion Function({
      required String id,
      required String name,
      Value<String> emoji,
      Value<String> currencyCode,
      Value<int> balanceMinor,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WalletAccountsTableUpdateCompanionBuilder =
    WalletAccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<String> currencyCode,
      Value<int> balanceMinor,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WalletAccountsTableReferences
    extends BaseReferences<_$AppDatabase, $WalletAccountsTable, WalletAccount> {
  $$WalletAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PersonalFinanceEntriesTable,
    List<PersonalFinanceEntry>
  >
  _personalFinanceEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personalFinanceEntries,
        aliasName: $_aliasNameGenerator(
          db.walletAccounts.id,
          db.personalFinanceEntries.accountId,
        ),
      );

  $$PersonalFinanceEntriesTableProcessedTableManager
  get personalFinanceEntriesRefs {
    final manager = $$PersonalFinanceEntriesTableTableManager(
      $_db,
      $_db.personalFinanceEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalFinanceEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PersonalFinanceFavoritesTable,
    List<PersonalFinanceFavorite>
  >
  _personalFinanceFavoritesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personalFinanceFavorites,
        aliasName: $_aliasNameGenerator(
          db.walletAccounts.id,
          db.personalFinanceFavorites.accountId,
        ),
      );

  $$PersonalFinanceFavoritesTableProcessedTableManager
  get personalFinanceFavoritesRefs {
    final manager = $$PersonalFinanceFavoritesTableTableManager(
      $_db,
      $_db.personalFinanceFavorites,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalFinanceFavoritesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WalletLedgerEntriesTable, List<WalletLedgerEntry>>
  _walletLedgerEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.walletLedgerEntries,
        aliasName: $_aliasNameGenerator(
          db.walletAccounts.id,
          db.walletLedgerEntries.accountId,
        ),
      );

  $$WalletLedgerEntriesTableProcessedTableManager get walletLedgerEntriesRefs {
    final manager = $$WalletLedgerEntriesTableTableManager(
      $_db,
      $_db.walletLedgerEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _walletLedgerEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WalletAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletAccountsTable> {
  $$WalletAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personalFinanceEntriesRefs(
    Expression<bool> Function($$PersonalFinanceEntriesTableFilterComposer f) f,
  ) {
    final $$PersonalFinanceEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalFinanceEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalFinanceEntriesTableFilterComposer(
                $db: $db,
                $table: $db.personalFinanceEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> personalFinanceFavoritesRefs(
    Expression<bool> Function($$PersonalFinanceFavoritesTableFilterComposer f)
    f,
  ) {
    final $$PersonalFinanceFavoritesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalFinanceFavorites,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalFinanceFavoritesTableFilterComposer(
                $db: $db,
                $table: $db.personalFinanceFavorites,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> walletLedgerEntriesRefs(
    Expression<bool> Function($$WalletLedgerEntriesTableFilterComposer f) f,
  ) {
    final $$WalletLedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.walletLedgerEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletLedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.walletLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WalletAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletAccountsTable> {
  $$WalletAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletAccountsTable> {
  $$WalletAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> personalFinanceEntriesRefs<T extends Object>(
    Expression<T> Function($$PersonalFinanceEntriesTableAnnotationComposer a) f,
  ) {
    final $$PersonalFinanceEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalFinanceEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalFinanceEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.personalFinanceEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalFinanceFavoritesRefs<T extends Object>(
    Expression<T> Function($$PersonalFinanceFavoritesTableAnnotationComposer a)
    f,
  ) {
    final $$PersonalFinanceFavoritesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalFinanceFavorites,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalFinanceFavoritesTableAnnotationComposer(
                $db: $db,
                $table: $db.personalFinanceFavorites,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> walletLedgerEntriesRefs<T extends Object>(
    Expression<T> Function($$WalletLedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$WalletLedgerEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.walletLedgerEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WalletLedgerEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.walletLedgerEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WalletAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletAccountsTable,
          WalletAccount,
          $$WalletAccountsTableFilterComposer,
          $$WalletAccountsTableOrderingComposer,
          $$WalletAccountsTableAnnotationComposer,
          $$WalletAccountsTableCreateCompanionBuilder,
          $$WalletAccountsTableUpdateCompanionBuilder,
          (WalletAccount, $$WalletAccountsTableReferences),
          WalletAccount,
          PrefetchHooks Function({
            bool personalFinanceEntriesRefs,
            bool personalFinanceFavoritesRefs,
            bool walletLedgerEntriesRefs,
          })
        > {
  $$WalletAccountsTableTableManager(
    _$AppDatabase db,
    $WalletAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletAccountsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                currencyCode: currencyCode,
                balanceMinor: balanceMinor,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> emoji = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WalletAccountsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                currencyCode: currencyCode,
                balanceMinor: balanceMinor,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personalFinanceEntriesRefs = false,
                personalFinanceFavoritesRefs = false,
                walletLedgerEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personalFinanceEntriesRefs) db.personalFinanceEntries,
                    if (personalFinanceFavoritesRefs)
                      db.personalFinanceFavorites,
                    if (walletLedgerEntriesRefs) db.walletLedgerEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personalFinanceEntriesRefs)
                        await $_getPrefetchedData<
                          WalletAccount,
                          $WalletAccountsTable,
                          PersonalFinanceEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WalletAccountsTableReferences
                              ._personalFinanceEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalFinanceEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalFinanceFavoritesRefs)
                        await $_getPrefetchedData<
                          WalletAccount,
                          $WalletAccountsTable,
                          PersonalFinanceFavorite
                        >(
                          currentTable: table,
                          referencedTable: $$WalletAccountsTableReferences
                              ._personalFinanceFavoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalFinanceFavoritesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (walletLedgerEntriesRefs)
                        await $_getPrefetchedData<
                          WalletAccount,
                          $WalletAccountsTable,
                          WalletLedgerEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WalletAccountsTableReferences
                              ._walletLedgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).walletLedgerEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WalletAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletAccountsTable,
      WalletAccount,
      $$WalletAccountsTableFilterComposer,
      $$WalletAccountsTableOrderingComposer,
      $$WalletAccountsTableAnnotationComposer,
      $$WalletAccountsTableCreateCompanionBuilder,
      $$WalletAccountsTableUpdateCompanionBuilder,
      (WalletAccount, $$WalletAccountsTableReferences),
      WalletAccount,
      PrefetchHooks Function({
        bool personalFinanceEntriesRefs,
        bool personalFinanceFavoritesRefs,
        bool walletLedgerEntriesRefs,
      })
    >;
typedef $$PersonalFinanceEntriesTableCreateCompanionBuilder =
    PersonalFinanceEntriesCompanion Function({
      required String id,
      required int kind,
      required String title,
      required int amountMinor,
      Value<String> currencyCode,
      Value<String?> note,
      Value<String?> categoryId,
      Value<String?> accountId,
      Value<String?> fromCurrencyJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PersonalFinanceEntriesTableUpdateCompanionBuilder =
    PersonalFinanceEntriesCompanion Function({
      Value<String> id,
      Value<int> kind,
      Value<String> title,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String?> note,
      Value<String?> categoryId,
      Value<String?> accountId,
      Value<String?> fromCurrencyJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PersonalFinanceEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalFinanceEntriesTable,
          PersonalFinanceEntry
        > {
  $$PersonalFinanceEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.walletAccounts.createAlias(
        $_aliasNameGenerator(
          db.personalFinanceEntries.accountId,
          db.walletAccounts.id,
        ),
      );

  $$WalletAccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$WalletAccountsTableTableManager(
      $_db,
      $_db.walletAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalFinanceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalFinanceEntriesTable> {
  $$PersonalFinanceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletAccountsTableFilterComposer get accountId {
    final $$WalletAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableFilterComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalFinanceEntriesTable> {
  $$PersonalFinanceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletAccountsTableOrderingComposer get accountId {
    final $$WalletAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalFinanceEntriesTable> {
  $$PersonalFinanceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WalletAccountsTableAnnotationComposer get accountId {
    final $$WalletAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalFinanceEntriesTable,
          PersonalFinanceEntry,
          $$PersonalFinanceEntriesTableFilterComposer,
          $$PersonalFinanceEntriesTableOrderingComposer,
          $$PersonalFinanceEntriesTableAnnotationComposer,
          $$PersonalFinanceEntriesTableCreateCompanionBuilder,
          $$PersonalFinanceEntriesTableUpdateCompanionBuilder,
          (PersonalFinanceEntry, $$PersonalFinanceEntriesTableReferences),
          PersonalFinanceEntry,
          PrefetchHooks Function({bool accountId})
        > {
  $$PersonalFinanceEntriesTableTableManager(
    _$AppDatabase db,
    $PersonalFinanceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalFinanceEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PersonalFinanceEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonalFinanceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalFinanceEntriesCompanion(
                id: id,
                kind: kind,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                note: note,
                categoryId: categoryId,
                accountId: accountId,
                fromCurrencyJson: fromCurrencyJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int kind,
                required String title,
                required int amountMinor,
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalFinanceEntriesCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                note: note,
                categoryId: categoryId,
                accountId: accountId,
                fromCurrencyJson: fromCurrencyJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalFinanceEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$PersonalFinanceEntriesTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$PersonalFinanceEntriesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalFinanceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalFinanceEntriesTable,
      PersonalFinanceEntry,
      $$PersonalFinanceEntriesTableFilterComposer,
      $$PersonalFinanceEntriesTableOrderingComposer,
      $$PersonalFinanceEntriesTableAnnotationComposer,
      $$PersonalFinanceEntriesTableCreateCompanionBuilder,
      $$PersonalFinanceEntriesTableUpdateCompanionBuilder,
      (PersonalFinanceEntry, $$PersonalFinanceEntriesTableReferences),
      PersonalFinanceEntry,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$PersonalFinanceFavoritesTableCreateCompanionBuilder =
    PersonalFinanceFavoritesCompanion Function({
      required String id,
      required int kind,
      required String label,
      required int amountMinor,
      Value<String?> categoryId,
      Value<String?> accountId,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PersonalFinanceFavoritesTableUpdateCompanionBuilder =
    PersonalFinanceFavoritesCompanion Function({
      Value<String> id,
      Value<int> kind,
      Value<String> label,
      Value<int> amountMinor,
      Value<String?> categoryId,
      Value<String?> accountId,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PersonalFinanceFavoritesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalFinanceFavoritesTable,
          PersonalFinanceFavorite
        > {
  $$PersonalFinanceFavoritesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.walletAccounts.createAlias(
        $_aliasNameGenerator(
          db.personalFinanceFavorites.accountId,
          db.walletAccounts.id,
        ),
      );

  $$WalletAccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$WalletAccountsTableTableManager(
      $_db,
      $_db.walletAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalFinanceFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalFinanceFavoritesTable> {
  $$PersonalFinanceFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletAccountsTableFilterComposer get accountId {
    final $$WalletAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableFilterComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalFinanceFavoritesTable> {
  $$PersonalFinanceFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletAccountsTableOrderingComposer get accountId {
    final $$WalletAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalFinanceFavoritesTable> {
  $$PersonalFinanceFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WalletAccountsTableAnnotationComposer get accountId {
    final $$WalletAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalFinanceFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalFinanceFavoritesTable,
          PersonalFinanceFavorite,
          $$PersonalFinanceFavoritesTableFilterComposer,
          $$PersonalFinanceFavoritesTableOrderingComposer,
          $$PersonalFinanceFavoritesTableAnnotationComposer,
          $$PersonalFinanceFavoritesTableCreateCompanionBuilder,
          $$PersonalFinanceFavoritesTableUpdateCompanionBuilder,
          (PersonalFinanceFavorite, $$PersonalFinanceFavoritesTableReferences),
          PersonalFinanceFavorite,
          PrefetchHooks Function({bool accountId})
        > {
  $$PersonalFinanceFavoritesTableTableManager(
    _$AppDatabase db,
    $PersonalFinanceFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalFinanceFavoritesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PersonalFinanceFavoritesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonalFinanceFavoritesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalFinanceFavoritesCompanion(
                id: id,
                kind: kind,
                label: label,
                amountMinor: amountMinor,
                categoryId: categoryId,
                accountId: accountId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int kind,
                required String label,
                required int amountMinor,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalFinanceFavoritesCompanion.insert(
                id: id,
                kind: kind,
                label: label,
                amountMinor: amountMinor,
                categoryId: categoryId,
                accountId: accountId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalFinanceFavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$PersonalFinanceFavoritesTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$PersonalFinanceFavoritesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalFinanceFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalFinanceFavoritesTable,
      PersonalFinanceFavorite,
      $$PersonalFinanceFavoritesTableFilterComposer,
      $$PersonalFinanceFavoritesTableOrderingComposer,
      $$PersonalFinanceFavoritesTableAnnotationComposer,
      $$PersonalFinanceFavoritesTableCreateCompanionBuilder,
      $$PersonalFinanceFavoritesTableUpdateCompanionBuilder,
      (PersonalFinanceFavorite, $$PersonalFinanceFavoritesTableReferences),
      PersonalFinanceFavorite,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> defaultCurrencyCode,
      Value<bool> contactsAutofillEnabled,
      Value<int> overdueAlertDays,
      Value<String?> profileName,
      Value<bool> syncEnabled,
      Value<String?> syncServerUrl,
      Value<String?> syncUsername,
      Value<String?> syncPassword,
      Value<int> syncIntervalHours,
      Value<bool> syncPeriodicEnabled,
      Value<DateTime?> lastUploadAt,
      Value<String?> lastUploadSha256,
      Value<DateTime?> lastDownloadAt,
      Value<DateTime?> lastServerOkAt,
      Value<bool> notifOverdueEnabled,
      Value<int> notifOverdueHour,
      Value<bool> notifBalanceMilestoneEnabled,
      Value<int> notifBalanceMilestoneMinor,
      Value<bool> notifInactivityEnabled,
      Value<int> notifInactivityDays,
      Value<bool> notifSyncEnabled,
      Value<String> clientSortField,
      Value<bool> clientSortAscending,
      Value<String> clientListLayout,
      Value<String> chartCurveStyle,
      Value<bool> notifBackupReminderEnabled,
      Value<int> notifBackupReminderDays,
      Value<DateTime?> lastJsonExportAt,
      Value<DateTime?> financeTrackingStartAt,
      Value<bool> notifFinanceDailyEnabled,
      Value<int> notifFinanceDailyHour,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> defaultCurrencyCode,
      Value<bool> contactsAutofillEnabled,
      Value<int> overdueAlertDays,
      Value<String?> profileName,
      Value<bool> syncEnabled,
      Value<String?> syncServerUrl,
      Value<String?> syncUsername,
      Value<String?> syncPassword,
      Value<int> syncIntervalHours,
      Value<bool> syncPeriodicEnabled,
      Value<DateTime?> lastUploadAt,
      Value<String?> lastUploadSha256,
      Value<DateTime?> lastDownloadAt,
      Value<DateTime?> lastServerOkAt,
      Value<bool> notifOverdueEnabled,
      Value<int> notifOverdueHour,
      Value<bool> notifBalanceMilestoneEnabled,
      Value<int> notifBalanceMilestoneMinor,
      Value<bool> notifInactivityEnabled,
      Value<int> notifInactivityDays,
      Value<bool> notifSyncEnabled,
      Value<String> clientSortField,
      Value<bool> clientSortAscending,
      Value<String> clientListLayout,
      Value<String> chartCurveStyle,
      Value<bool> notifBackupReminderEnabled,
      Value<int> notifBackupReminderDays,
      Value<DateTime?> lastJsonExportAt,
      Value<DateTime?> financeTrackingStartAt,
      Value<bool> notifFinanceDailyEnabled,
      Value<int> notifFinanceDailyHour,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrencyCode => $composableBuilder(
    column: $table.defaultCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get contactsAutofillEnabled => $composableBuilder(
    column: $table.contactsAutofillEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overdueAlertDays => $composableBuilder(
    column: $table.overdueAlertDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncServerUrl => $composableBuilder(
    column: $table.syncServerUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncUsername => $composableBuilder(
    column: $table.syncUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncPassword => $composableBuilder(
    column: $table.syncPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncIntervalHours => $composableBuilder(
    column: $table.syncIntervalHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPeriodicEnabled => $composableBuilder(
    column: $table.syncPeriodicEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUploadAt => $composableBuilder(
    column: $table.lastUploadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastUploadSha256 => $composableBuilder(
    column: $table.lastUploadSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDownloadAt => $composableBuilder(
    column: $table.lastDownloadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastServerOkAt => $composableBuilder(
    column: $table.lastServerOkAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifOverdueEnabled => $composableBuilder(
    column: $table.notifOverdueEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifOverdueHour => $composableBuilder(
    column: $table.notifOverdueHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifBalanceMilestoneEnabled => $composableBuilder(
    column: $table.notifBalanceMilestoneEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifBalanceMilestoneMinor => $composableBuilder(
    column: $table.notifBalanceMilestoneMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifInactivityEnabled => $composableBuilder(
    column: $table.notifInactivityEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifInactivityDays => $composableBuilder(
    column: $table.notifInactivityDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifSyncEnabled => $composableBuilder(
    column: $table.notifSyncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientSortField => $composableBuilder(
    column: $table.clientSortField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get clientSortAscending => $composableBuilder(
    column: $table.clientSortAscending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientListLayout => $composableBuilder(
    column: $table.clientListLayout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chartCurveStyle => $composableBuilder(
    column: $table.chartCurveStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifBackupReminderEnabled => $composableBuilder(
    column: $table.notifBackupReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifBackupReminderDays => $composableBuilder(
    column: $table.notifBackupReminderDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastJsonExportAt => $composableBuilder(
    column: $table.lastJsonExportAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get financeTrackingStartAt => $composableBuilder(
    column: $table.financeTrackingStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifFinanceDailyEnabled => $composableBuilder(
    column: $table.notifFinanceDailyEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifFinanceDailyHour => $composableBuilder(
    column: $table.notifFinanceDailyHour,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrencyCode => $composableBuilder(
    column: $table.defaultCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get contactsAutofillEnabled => $composableBuilder(
    column: $table.contactsAutofillEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overdueAlertDays => $composableBuilder(
    column: $table.overdueAlertDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncServerUrl => $composableBuilder(
    column: $table.syncServerUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncUsername => $composableBuilder(
    column: $table.syncUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncPassword => $composableBuilder(
    column: $table.syncPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncIntervalHours => $composableBuilder(
    column: $table.syncIntervalHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPeriodicEnabled => $composableBuilder(
    column: $table.syncPeriodicEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUploadAt => $composableBuilder(
    column: $table.lastUploadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastUploadSha256 => $composableBuilder(
    column: $table.lastUploadSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDownloadAt => $composableBuilder(
    column: $table.lastDownloadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastServerOkAt => $composableBuilder(
    column: $table.lastServerOkAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifOverdueEnabled => $composableBuilder(
    column: $table.notifOverdueEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifOverdueHour => $composableBuilder(
    column: $table.notifOverdueHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifBalanceMilestoneEnabled => $composableBuilder(
    column: $table.notifBalanceMilestoneEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifBalanceMilestoneMinor => $composableBuilder(
    column: $table.notifBalanceMilestoneMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifInactivityEnabled => $composableBuilder(
    column: $table.notifInactivityEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifInactivityDays => $composableBuilder(
    column: $table.notifInactivityDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifSyncEnabled => $composableBuilder(
    column: $table.notifSyncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientSortField => $composableBuilder(
    column: $table.clientSortField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get clientSortAscending => $composableBuilder(
    column: $table.clientSortAscending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientListLayout => $composableBuilder(
    column: $table.clientListLayout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chartCurveStyle => $composableBuilder(
    column: $table.chartCurveStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifBackupReminderEnabled => $composableBuilder(
    column: $table.notifBackupReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifBackupReminderDays => $composableBuilder(
    column: $table.notifBackupReminderDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastJsonExportAt => $composableBuilder(
    column: $table.lastJsonExportAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get financeTrackingStartAt => $composableBuilder(
    column: $table.financeTrackingStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifFinanceDailyEnabled => $composableBuilder(
    column: $table.notifFinanceDailyEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifFinanceDailyHour => $composableBuilder(
    column: $table.notifFinanceDailyHour,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get defaultCurrencyCode => $composableBuilder(
    column: $table.defaultCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get contactsAutofillEnabled => $composableBuilder(
    column: $table.contactsAutofillEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overdueAlertDays => $composableBuilder(
    column: $table.overdueAlertDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncServerUrl => $composableBuilder(
    column: $table.syncServerUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncUsername => $composableBuilder(
    column: $table.syncUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncPassword => $composableBuilder(
    column: $table.syncPassword,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncIntervalHours => $composableBuilder(
    column: $table.syncIntervalHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncPeriodicEnabled => $composableBuilder(
    column: $table.syncPeriodicEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUploadAt => $composableBuilder(
    column: $table.lastUploadAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastUploadSha256 => $composableBuilder(
    column: $table.lastUploadSha256,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDownloadAt => $composableBuilder(
    column: $table.lastDownloadAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastServerOkAt => $composableBuilder(
    column: $table.lastServerOkAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifOverdueEnabled => $composableBuilder(
    column: $table.notifOverdueEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifOverdueHour => $composableBuilder(
    column: $table.notifOverdueHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifBalanceMilestoneEnabled => $composableBuilder(
    column: $table.notifBalanceMilestoneEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifBalanceMilestoneMinor => $composableBuilder(
    column: $table.notifBalanceMilestoneMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifInactivityEnabled => $composableBuilder(
    column: $table.notifInactivityEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifInactivityDays => $composableBuilder(
    column: $table.notifInactivityDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifSyncEnabled => $composableBuilder(
    column: $table.notifSyncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientSortField => $composableBuilder(
    column: $table.clientSortField,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get clientSortAscending => $composableBuilder(
    column: $table.clientSortAscending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientListLayout => $composableBuilder(
    column: $table.clientListLayout,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chartCurveStyle => $composableBuilder(
    column: $table.chartCurveStyle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifBackupReminderEnabled => $composableBuilder(
    column: $table.notifBackupReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifBackupReminderDays => $composableBuilder(
    column: $table.notifBackupReminderDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastJsonExportAt => $composableBuilder(
    column: $table.lastJsonExportAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get financeTrackingStartAt => $composableBuilder(
    column: $table.financeTrackingStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifFinanceDailyEnabled => $composableBuilder(
    column: $table.notifFinanceDailyEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifFinanceDailyHour => $composableBuilder(
    column: $table.notifFinanceDailyHour,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> defaultCurrencyCode = const Value.absent(),
                Value<bool> contactsAutofillEnabled = const Value.absent(),
                Value<int> overdueAlertDays = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<String?> syncServerUrl = const Value.absent(),
                Value<String?> syncUsername = const Value.absent(),
                Value<String?> syncPassword = const Value.absent(),
                Value<int> syncIntervalHours = const Value.absent(),
                Value<bool> syncPeriodicEnabled = const Value.absent(),
                Value<DateTime?> lastUploadAt = const Value.absent(),
                Value<String?> lastUploadSha256 = const Value.absent(),
                Value<DateTime?> lastDownloadAt = const Value.absent(),
                Value<DateTime?> lastServerOkAt = const Value.absent(),
                Value<bool> notifOverdueEnabled = const Value.absent(),
                Value<int> notifOverdueHour = const Value.absent(),
                Value<bool> notifBalanceMilestoneEnabled = const Value.absent(),
                Value<int> notifBalanceMilestoneMinor = const Value.absent(),
                Value<bool> notifInactivityEnabled = const Value.absent(),
                Value<int> notifInactivityDays = const Value.absent(),
                Value<bool> notifSyncEnabled = const Value.absent(),
                Value<String> clientSortField = const Value.absent(),
                Value<bool> clientSortAscending = const Value.absent(),
                Value<String> clientListLayout = const Value.absent(),
                Value<String> chartCurveStyle = const Value.absent(),
                Value<bool> notifBackupReminderEnabled = const Value.absent(),
                Value<int> notifBackupReminderDays = const Value.absent(),
                Value<DateTime?> lastJsonExportAt = const Value.absent(),
                Value<DateTime?> financeTrackingStartAt = const Value.absent(),
                Value<bool> notifFinanceDailyEnabled = const Value.absent(),
                Value<int> notifFinanceDailyHour = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                defaultCurrencyCode: defaultCurrencyCode,
                contactsAutofillEnabled: contactsAutofillEnabled,
                overdueAlertDays: overdueAlertDays,
                profileName: profileName,
                syncEnabled: syncEnabled,
                syncServerUrl: syncServerUrl,
                syncUsername: syncUsername,
                syncPassword: syncPassword,
                syncIntervalHours: syncIntervalHours,
                syncPeriodicEnabled: syncPeriodicEnabled,
                lastUploadAt: lastUploadAt,
                lastUploadSha256: lastUploadSha256,
                lastDownloadAt: lastDownloadAt,
                lastServerOkAt: lastServerOkAt,
                notifOverdueEnabled: notifOverdueEnabled,
                notifOverdueHour: notifOverdueHour,
                notifBalanceMilestoneEnabled: notifBalanceMilestoneEnabled,
                notifBalanceMilestoneMinor: notifBalanceMilestoneMinor,
                notifInactivityEnabled: notifInactivityEnabled,
                notifInactivityDays: notifInactivityDays,
                notifSyncEnabled: notifSyncEnabled,
                clientSortField: clientSortField,
                clientSortAscending: clientSortAscending,
                clientListLayout: clientListLayout,
                chartCurveStyle: chartCurveStyle,
                notifBackupReminderEnabled: notifBackupReminderEnabled,
                notifBackupReminderDays: notifBackupReminderDays,
                lastJsonExportAt: lastJsonExportAt,
                financeTrackingStartAt: financeTrackingStartAt,
                notifFinanceDailyEnabled: notifFinanceDailyEnabled,
                notifFinanceDailyHour: notifFinanceDailyHour,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> defaultCurrencyCode = const Value.absent(),
                Value<bool> contactsAutofillEnabled = const Value.absent(),
                Value<int> overdueAlertDays = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<String?> syncServerUrl = const Value.absent(),
                Value<String?> syncUsername = const Value.absent(),
                Value<String?> syncPassword = const Value.absent(),
                Value<int> syncIntervalHours = const Value.absent(),
                Value<bool> syncPeriodicEnabled = const Value.absent(),
                Value<DateTime?> lastUploadAt = const Value.absent(),
                Value<String?> lastUploadSha256 = const Value.absent(),
                Value<DateTime?> lastDownloadAt = const Value.absent(),
                Value<DateTime?> lastServerOkAt = const Value.absent(),
                Value<bool> notifOverdueEnabled = const Value.absent(),
                Value<int> notifOverdueHour = const Value.absent(),
                Value<bool> notifBalanceMilestoneEnabled = const Value.absent(),
                Value<int> notifBalanceMilestoneMinor = const Value.absent(),
                Value<bool> notifInactivityEnabled = const Value.absent(),
                Value<int> notifInactivityDays = const Value.absent(),
                Value<bool> notifSyncEnabled = const Value.absent(),
                Value<String> clientSortField = const Value.absent(),
                Value<bool> clientSortAscending = const Value.absent(),
                Value<String> clientListLayout = const Value.absent(),
                Value<String> chartCurveStyle = const Value.absent(),
                Value<bool> notifBackupReminderEnabled = const Value.absent(),
                Value<int> notifBackupReminderDays = const Value.absent(),
                Value<DateTime?> lastJsonExportAt = const Value.absent(),
                Value<DateTime?> financeTrackingStartAt = const Value.absent(),
                Value<bool> notifFinanceDailyEnabled = const Value.absent(),
                Value<int> notifFinanceDailyHour = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                defaultCurrencyCode: defaultCurrencyCode,
                contactsAutofillEnabled: contactsAutofillEnabled,
                overdueAlertDays: overdueAlertDays,
                profileName: profileName,
                syncEnabled: syncEnabled,
                syncServerUrl: syncServerUrl,
                syncUsername: syncUsername,
                syncPassword: syncPassword,
                syncIntervalHours: syncIntervalHours,
                syncPeriodicEnabled: syncPeriodicEnabled,
                lastUploadAt: lastUploadAt,
                lastUploadSha256: lastUploadSha256,
                lastDownloadAt: lastDownloadAt,
                lastServerOkAt: lastServerOkAt,
                notifOverdueEnabled: notifOverdueEnabled,
                notifOverdueHour: notifOverdueHour,
                notifBalanceMilestoneEnabled: notifBalanceMilestoneEnabled,
                notifBalanceMilestoneMinor: notifBalanceMilestoneMinor,
                notifInactivityEnabled: notifInactivityEnabled,
                notifInactivityDays: notifInactivityDays,
                notifSyncEnabled: notifSyncEnabled,
                clientSortField: clientSortField,
                clientSortAscending: clientSortAscending,
                clientListLayout: clientListLayout,
                chartCurveStyle: chartCurveStyle,
                notifBackupReminderEnabled: notifBackupReminderEnabled,
                notifBackupReminderDays: notifBackupReminderDays,
                lastJsonExportAt: lastJsonExportAt,
                financeTrackingStartAt: financeTrackingStartAt,
                notifFinanceDailyEnabled: notifFinanceDailyEnabled,
                notifFinanceDailyHour: notifFinanceDailyHour,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$TransactionTemplatesTableCreateCompanionBuilder =
    TransactionTemplatesCompanion Function({
      required String id,
      required String label,
      required int amountMinor,
      required int txType,
      Value<String> currencyCode,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TransactionTemplatesTableUpdateCompanionBuilder =
    TransactionTemplatesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<int> amountMinor,
      Value<int> txType,
      Value<String> currencyCode,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TransactionTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTemplatesTable> {
  $$TransactionTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTemplatesTable> {
  $$TransactionTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTemplatesTable> {
  $$TransactionTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTemplatesTable,
          TransactionTemplate,
          $$TransactionTemplatesTableFilterComposer,
          $$TransactionTemplatesTableOrderingComposer,
          $$TransactionTemplatesTableAnnotationComposer,
          $$TransactionTemplatesTableCreateCompanionBuilder,
          $$TransactionTemplatesTableUpdateCompanionBuilder,
          (
            TransactionTemplate,
            BaseReferences<
              _$AppDatabase,
              $TransactionTemplatesTable,
              TransactionTemplate
            >,
          ),
          TransactionTemplate,
          PrefetchHooks Function()
        > {
  $$TransactionTemplatesTableTableManager(
    _$AppDatabase db,
    $TransactionTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> txType = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTemplatesCompanion(
                id: id,
                label: label,
                amountMinor: amountMinor,
                txType: txType,
                currencyCode: currencyCode,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required int amountMinor,
                required int txType,
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionTemplatesCompanion.insert(
                id: id,
                label: label,
                amountMinor: amountMinor,
                txType: txType,
                currencyCode: currencyCode,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTemplatesTable,
      TransactionTemplate,
      $$TransactionTemplatesTableFilterComposer,
      $$TransactionTemplatesTableOrderingComposer,
      $$TransactionTemplatesTableAnnotationComposer,
      $$TransactionTemplatesTableCreateCompanionBuilder,
      $$TransactionTemplatesTableUpdateCompanionBuilder,
      (
        TransactionTemplate,
        BaseReferences<
          _$AppDatabase,
          $TransactionTemplatesTable,
          TransactionTemplate
        >,
      ),
      TransactionTemplate,
      PrefetchHooks Function()
    >;
typedef $$AuditLogTableCreateCompanionBuilder =
    AuditLogCompanion Function({
      required String id,
      required String action,
      required String entityType,
      required String entityId,
      Value<String?> detail,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AuditLogTableUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<String> id,
      Value<String> action,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> detail,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogTable,
          AuditLogData,
          $$AuditLogTableFilterComposer,
          $$AuditLogTableOrderingComposer,
          $$AuditLogTableAnnotationComposer,
          $$AuditLogTableCreateCompanionBuilder,
          $$AuditLogTableUpdateCompanionBuilder,
          (
            AuditLogData,
            BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
          ),
          AuditLogData,
          PrefetchHooks Function()
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                action: action,
                entityType: entityType,
                entityId: entityId,
                detail: detail,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String action,
                required String entityType,
                required String entityId,
                Value<String?> detail = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                action: action,
                entityType: entityType,
                entityId: entityId,
                detail: detail,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogTable,
      AuditLogData,
      $$AuditLogTableFilterComposer,
      $$AuditLogTableOrderingComposer,
      $$AuditLogTableAnnotationComposer,
      $$AuditLogTableCreateCompanionBuilder,
      $$AuditLogTableUpdateCompanionBuilder,
      (
        AuditLogData,
        BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
      ),
      AuditLogData,
      PrefetchHooks Function()
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> colorHex,
      required int iconCodePoint,
      Value<int?> budgetMinorPerMonth,
      required String scope,
      required DateTime createdAt,
      Value<String> budgetPeriod,
      Value<int?> budgetCustomDays,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> colorHex,
      Value<int> iconCodePoint,
      Value<int?> budgetMinorPerMonth,
      Value<String> scope,
      Value<DateTime> createdAt,
      Value<String> budgetPeriod,
      Value<int?> budgetCustomDays,
      Value<int> rowid,
    });

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetMinorPerMonth => $composableBuilder(
    column: $table.budgetMinorPerMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetPeriod => $composableBuilder(
    column: $table.budgetPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetCustomDays => $composableBuilder(
    column: $table.budgetCustomDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetMinorPerMonth => $composableBuilder(
    column: $table.budgetMinorPerMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetPeriod => $composableBuilder(
    column: $table.budgetPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetCustomDays => $composableBuilder(
    column: $table.budgetCustomDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get budgetMinorPerMonth => $composableBuilder(
    column: $table.budgetMinorPerMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get budgetPeriod => $composableBuilder(
    column: $table.budgetPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get budgetCustomDays => $composableBuilder(
    column: $table.budgetCustomDays,
    builder: (column) => column,
  );
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (
            ExpenseCategory,
            BaseReferences<
              _$AppDatabase,
              $ExpenseCategoriesTable,
              ExpenseCategory
            >,
          ),
          ExpenseCategory,
          PrefetchHooks Function()
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<int?> budgetMinorPerMonth = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> budgetPeriod = const Value.absent(),
                Value<int?> budgetCustomDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                iconCodePoint: iconCodePoint,
                budgetMinorPerMonth: budgetMinorPerMonth,
                scope: scope,
                createdAt: createdAt,
                budgetPeriod: budgetPeriod,
                budgetCustomDays: budgetCustomDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> colorHex = const Value.absent(),
                required int iconCodePoint,
                Value<int?> budgetMinorPerMonth = const Value.absent(),
                required String scope,
                required DateTime createdAt,
                Value<String> budgetPeriod = const Value.absent(),
                Value<int?> budgetCustomDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                iconCodePoint: iconCodePoint,
                budgetMinorPerMonth: budgetMinorPerMonth,
                scope: scope,
                createdAt: createdAt,
                budgetPeriod: budgetPeriod,
                budgetCustomDays: budgetCustomDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategory,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (
        ExpenseCategory,
        BaseReferences<_$AppDatabase, $ExpenseCategoriesTable, ExpenseCategory>,
      ),
      ExpenseCategory,
      PrefetchHooks Function()
    >;
typedef $$WishlistItemsTableCreateCompanionBuilder =
    WishlistItemsCompanion Function({
      required String id,
      required String title,
      required int amountMinor,
      Value<String> currencyCode,
      Value<String?> note,
      Value<String?> categoryId,
      Value<bool> isPurchased,
      required DateTime createdAt,
      Value<DateTime?> purchasedAt,
      Value<String?> fromCurrencyJson,
      Value<int> rowid,
    });
typedef $$WishlistItemsTableUpdateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String?> note,
      Value<String?> categoryId,
      Value<bool> isPurchased,
      Value<DateTime> createdAt,
      Value<DateTime?> purchasedAt,
      Value<String?> fromCurrencyJson,
      Value<int> rowid,
    });

class $$WishlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WishlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WishlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => column,
  );
}

class $$WishlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistItemsTable,
          WishlistItem,
          $$WishlistItemsTableFilterComposer,
          $$WishlistItemsTableOrderingComposer,
          $$WishlistItemsTableAnnotationComposer,
          $$WishlistItemsTableCreateCompanionBuilder,
          $$WishlistItemsTableUpdateCompanionBuilder,
          (
            WishlistItem,
            BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
          ),
          WishlistItem,
          PrefetchHooks Function()
        > {
  $$WishlistItemsTableTableManager(_$AppDatabase db, $WishlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> purchasedAt = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion(
                id: id,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                note: note,
                categoryId: categoryId,
                isPurchased: isPurchased,
                createdAt: createdAt,
                purchasedAt: purchasedAt,
                fromCurrencyJson: fromCurrencyJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int amountMinor,
                Value<String> currencyCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> purchasedAt = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion.insert(
                id: id,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                note: note,
                categoryId: categoryId,
                isPurchased: isPurchased,
                createdAt: createdAt,
                purchasedAt: purchasedAt,
                fromCurrencyJson: fromCurrencyJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WishlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistItemsTable,
      WishlistItem,
      $$WishlistItemsTableFilterComposer,
      $$WishlistItemsTableOrderingComposer,
      $$WishlistItemsTableAnnotationComposer,
      $$WishlistItemsTableCreateCompanionBuilder,
      $$WishlistItemsTableUpdateCompanionBuilder,
      (
        WishlistItem,
        BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
      ),
      WishlistItem,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionItemsTableCreateCompanionBuilder =
    SubscriptionItemsCompanion Function({
      required String id,
      required String title,
      required int amountMinor,
      Value<String> currencyCode,
      Value<String?> fromCurrencyJson,
      Value<String?> note,
      Value<String?> categoryId,
      required String scheduleType,
      Value<int?> billingDayOfMonth,
      Value<int?> rollingDays,
      required DateTime nextDueAt,
      Value<DateTime?> lastLoggedAt,
      Value<bool> isActive,
      Value<int?> warnBeforeDays,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SubscriptionItemsTableUpdateCompanionBuilder =
    SubscriptionItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String?> fromCurrencyJson,
      Value<String?> note,
      Value<String?> categoryId,
      Value<String> scheduleType,
      Value<int?> billingDayOfMonth,
      Value<int?> rollingDays,
      Value<DateTime> nextDueAt,
      Value<DateTime?> lastLoggedAt,
      Value<bool> isActive,
      Value<int?> warnBeforeDays,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SubscriptionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingDayOfMonth => $composableBuilder(
    column: $table.billingDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rollingDays => $composableBuilder(
    column: $table.rollingDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoggedAt => $composableBuilder(
    column: $table.lastLoggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warnBeforeDays => $composableBuilder(
    column: $table.warnBeforeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingDayOfMonth => $composableBuilder(
    column: $table.billingDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rollingDays => $composableBuilder(
    column: $table.rollingDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoggedAt => $composableBuilder(
    column: $table.lastLoggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warnBeforeDays => $composableBuilder(
    column: $table.warnBeforeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingDayOfMonth => $composableBuilder(
    column: $table.billingDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rollingDays => $composableBuilder(
    column: $table.rollingDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoggedAt => $composableBuilder(
    column: $table.lastLoggedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get warnBeforeDays => $composableBuilder(
    column: $table.warnBeforeDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SubscriptionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionItemsTable,
          SubscriptionItem,
          $$SubscriptionItemsTableFilterComposer,
          $$SubscriptionItemsTableOrderingComposer,
          $$SubscriptionItemsTableAnnotationComposer,
          $$SubscriptionItemsTableCreateCompanionBuilder,
          $$SubscriptionItemsTableUpdateCompanionBuilder,
          (
            SubscriptionItem,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionItemsTable,
              SubscriptionItem
            >,
          ),
          SubscriptionItem,
          PrefetchHooks Function()
        > {
  $$SubscriptionItemsTableTableManager(
    _$AppDatabase db,
    $SubscriptionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<int?> billingDayOfMonth = const Value.absent(),
                Value<int?> rollingDays = const Value.absent(),
                Value<DateTime> nextDueAt = const Value.absent(),
                Value<DateTime?> lastLoggedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> warnBeforeDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionItemsCompanion(
                id: id,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                fromCurrencyJson: fromCurrencyJson,
                note: note,
                categoryId: categoryId,
                scheduleType: scheduleType,
                billingDayOfMonth: billingDayOfMonth,
                rollingDays: rollingDays,
                nextDueAt: nextDueAt,
                lastLoggedAt: lastLoggedAt,
                isActive: isActive,
                warnBeforeDays: warnBeforeDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int amountMinor,
                Value<String> currencyCode = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String scheduleType,
                Value<int?> billingDayOfMonth = const Value.absent(),
                Value<int?> rollingDays = const Value.absent(),
                required DateTime nextDueAt,
                Value<DateTime?> lastLoggedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> warnBeforeDays = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionItemsCompanion.insert(
                id: id,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                fromCurrencyJson: fromCurrencyJson,
                note: note,
                categoryId: categoryId,
                scheduleType: scheduleType,
                billingDayOfMonth: billingDayOfMonth,
                rollingDays: rollingDays,
                nextDueAt: nextDueAt,
                lastLoggedAt: lastLoggedAt,
                isActive: isActive,
                warnBeforeDays: warnBeforeDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionItemsTable,
      SubscriptionItem,
      $$SubscriptionItemsTableFilterComposer,
      $$SubscriptionItemsTableOrderingComposer,
      $$SubscriptionItemsTableAnnotationComposer,
      $$SubscriptionItemsTableCreateCompanionBuilder,
      $$SubscriptionItemsTableUpdateCompanionBuilder,
      (
        SubscriptionItem,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionItemsTable,
          SubscriptionItem
        >,
      ),
      SubscriptionItem,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      required String id,
      required String name,
      Value<String> emoji,
      required int targetMinor,
      Value<int> savedMinor,
      Value<String?> note,
      Value<DateTime?> deadline,
      Value<bool> isCompleted,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> targetMinor,
      Value<int> savedMinor,
      Value<String?> note,
      Value<DateTime?> deadline,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoal,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoal,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
          ),
          SavingsGoal,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> targetMinor = const Value.absent(),
                Value<int> savedMinor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                targetMinor: targetMinor,
                savedMinor: savedMinor,
                note: note,
                deadline: deadline,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> emoji = const Value.absent(),
                required int targetMinor,
                Value<int> savedMinor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                targetMinor: targetMinor,
                savedMinor: savedMinor,
                note: note,
                deadline: deadline,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoal,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoal,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
      ),
      SavingsGoal,
      PrefetchHooks Function()
    >;
typedef $$WalletLedgerEntriesTableCreateCompanionBuilder =
    WalletLedgerEntriesCompanion Function({
      required String id,
      required String accountId,
      required String opType,
      required int amountMinor,
      required int balanceBeforeMinor,
      required int balanceAfterMinor,
      Value<String?> note,
      Value<String> source,
      Value<String?> referenceId,
      Value<String?> fromCurrencyJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WalletLedgerEntriesTableUpdateCompanionBuilder =
    WalletLedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> opType,
      Value<int> amountMinor,
      Value<int> balanceBeforeMinor,
      Value<int> balanceAfterMinor,
      Value<String?> note,
      Value<String> source,
      Value<String?> referenceId,
      Value<String?> fromCurrencyJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$WalletLedgerEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WalletLedgerEntriesTable,
          WalletLedgerEntry
        > {
  $$WalletLedgerEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.walletAccounts.createAlias(
        $_aliasNameGenerator(
          db.walletLedgerEntries.accountId,
          db.walletAccounts.id,
        ),
      );

  $$WalletAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$WalletAccountsTableTableManager(
      $_db,
      $_db.walletAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WalletLedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WalletLedgerEntriesTable> {
  $$WalletLedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceBeforeMinor => $composableBuilder(
    column: $table.balanceBeforeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfterMinor => $composableBuilder(
    column: $table.balanceAfterMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletAccountsTableFilterComposer get accountId {
    final $$WalletAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableFilterComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletLedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletLedgerEntriesTable> {
  $$WalletLedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceBeforeMinor => $composableBuilder(
    column: $table.balanceBeforeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfterMinor => $composableBuilder(
    column: $table.balanceAfterMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletAccountsTableOrderingComposer get accountId {
    final $$WalletAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletLedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletLedgerEntriesTable> {
  $$WalletLedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceBeforeMinor => $composableBuilder(
    column: $table.balanceBeforeMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceAfterMinor => $composableBuilder(
    column: $table.balanceAfterMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromCurrencyJson => $composableBuilder(
    column: $table.fromCurrencyJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WalletAccountsTableAnnotationComposer get accountId {
    final $$WalletAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.walletAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.walletAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletLedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletLedgerEntriesTable,
          WalletLedgerEntry,
          $$WalletLedgerEntriesTableFilterComposer,
          $$WalletLedgerEntriesTableOrderingComposer,
          $$WalletLedgerEntriesTableAnnotationComposer,
          $$WalletLedgerEntriesTableCreateCompanionBuilder,
          $$WalletLedgerEntriesTableUpdateCompanionBuilder,
          (WalletLedgerEntry, $$WalletLedgerEntriesTableReferences),
          WalletLedgerEntry,
          PrefetchHooks Function({bool accountId})
        > {
  $$WalletLedgerEntriesTableTableManager(
    _$AppDatabase db,
    $WalletLedgerEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletLedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletLedgerEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WalletLedgerEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> balanceBeforeMinor = const Value.absent(),
                Value<int> balanceAfterMinor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletLedgerEntriesCompanion(
                id: id,
                accountId: accountId,
                opType: opType,
                amountMinor: amountMinor,
                balanceBeforeMinor: balanceBeforeMinor,
                balanceAfterMinor: balanceAfterMinor,
                note: note,
                source: source,
                referenceId: referenceId,
                fromCurrencyJson: fromCurrencyJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String opType,
                required int amountMinor,
                required int balanceBeforeMinor,
                required int balanceAfterMinor,
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> fromCurrencyJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WalletLedgerEntriesCompanion.insert(
                id: id,
                accountId: accountId,
                opType: opType,
                amountMinor: amountMinor,
                balanceBeforeMinor: balanceBeforeMinor,
                balanceAfterMinor: balanceAfterMinor,
                note: note,
                source: source,
                referenceId: referenceId,
                fromCurrencyJson: fromCurrencyJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletLedgerEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$WalletLedgerEntriesTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$WalletLedgerEntriesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WalletLedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletLedgerEntriesTable,
      WalletLedgerEntry,
      $$WalletLedgerEntriesTableFilterComposer,
      $$WalletLedgerEntriesTableOrderingComposer,
      $$WalletLedgerEntriesTableAnnotationComposer,
      $$WalletLedgerEntriesTableCreateCompanionBuilder,
      $$WalletLedgerEntriesTableUpdateCompanionBuilder,
      (WalletLedgerEntry, $$WalletLedgerEntriesTableReferences),
      WalletLedgerEntry,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$ManagedCurrenciesTableCreateCompanionBuilder =
    ManagedCurrenciesCompanion Function({
      required String code,
      Value<int> fractionDigits,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ManagedCurrenciesTableUpdateCompanionBuilder =
    ManagedCurrenciesCompanion Function({
      Value<String> code,
      Value<int> fractionDigits,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ManagedCurrenciesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ManagedCurrenciesTable,
          ManagedCurrency
        > {
  $$ManagedCurrenciesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ExchangeRateHistoryTable,
    List<ExchangeRateHistoryData>
  >
  _exchangeRateHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exchangeRateHistory,
        aliasName: $_aliasNameGenerator(
          db.managedCurrencies.code,
          db.exchangeRateHistory.currencyCode,
        ),
      );

  $$ExchangeRateHistoryTableProcessedTableManager get exchangeRateHistoryRefs {
    final manager =
        $$ExchangeRateHistoryTableTableManager(
          $_db,
          $_db.exchangeRateHistory,
        ).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _exchangeRateHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ManagedCurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $ManagedCurrenciesTable> {
  $$ManagedCurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exchangeRateHistoryRefs(
    Expression<bool> Function($$ExchangeRateHistoryTableFilterComposer f) f,
  ) {
    final $$ExchangeRateHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.exchangeRateHistory,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExchangeRateHistoryTableFilterComposer(
            $db: $db,
            $table: $db.exchangeRateHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ManagedCurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManagedCurrenciesTable> {
  $$ManagedCurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManagedCurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManagedCurrenciesTable> {
  $$ManagedCurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> exchangeRateHistoryRefs<T extends Object>(
    Expression<T> Function($$ExchangeRateHistoryTableAnnotationComposer a) f,
  ) {
    final $$ExchangeRateHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.exchangeRateHistory,
          getReferencedColumn: (t) => t.currencyCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExchangeRateHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.exchangeRateHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ManagedCurrenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManagedCurrenciesTable,
          ManagedCurrency,
          $$ManagedCurrenciesTableFilterComposer,
          $$ManagedCurrenciesTableOrderingComposer,
          $$ManagedCurrenciesTableAnnotationComposer,
          $$ManagedCurrenciesTableCreateCompanionBuilder,
          $$ManagedCurrenciesTableUpdateCompanionBuilder,
          (ManagedCurrency, $$ManagedCurrenciesTableReferences),
          ManagedCurrency,
          PrefetchHooks Function({bool exchangeRateHistoryRefs})
        > {
  $$ManagedCurrenciesTableTableManager(
    _$AppDatabase db,
    $ManagedCurrenciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManagedCurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManagedCurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManagedCurrenciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<int> fractionDigits = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagedCurrenciesCompanion(
                code: code,
                fractionDigits: fractionDigits,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                Value<int> fractionDigits = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ManagedCurrenciesCompanion.insert(
                code: code,
                fractionDigits: fractionDigits,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManagedCurrenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exchangeRateHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exchangeRateHistoryRefs) db.exchangeRateHistory,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exchangeRateHistoryRefs)
                    await $_getPrefetchedData<
                      ManagedCurrency,
                      $ManagedCurrenciesTable,
                      ExchangeRateHistoryData
                    >(
                      currentTable: table,
                      referencedTable: $$ManagedCurrenciesTableReferences
                          ._exchangeRateHistoryRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ManagedCurrenciesTableReferences(
                            db,
                            table,
                            p0,
                          ).exchangeRateHistoryRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.currencyCode == item.code,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ManagedCurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManagedCurrenciesTable,
      ManagedCurrency,
      $$ManagedCurrenciesTableFilterComposer,
      $$ManagedCurrenciesTableOrderingComposer,
      $$ManagedCurrenciesTableAnnotationComposer,
      $$ManagedCurrenciesTableCreateCompanionBuilder,
      $$ManagedCurrenciesTableUpdateCompanionBuilder,
      (ManagedCurrency, $$ManagedCurrenciesTableReferences),
      ManagedCurrency,
      PrefetchHooks Function({bool exchangeRateHistoryRefs})
    >;
typedef $$ExchangeRateHistoryTableCreateCompanionBuilder =
    ExchangeRateHistoryCompanion Function({
      required String id,
      required String currencyCode,
      required int rateToDefault,
      Value<int> rateScale,
      required DateTime recordedAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$ExchangeRateHistoryTableUpdateCompanionBuilder =
    ExchangeRateHistoryCompanion Function({
      Value<String> id,
      Value<String> currencyCode,
      Value<int> rateToDefault,
      Value<int> rateScale,
      Value<DateTime> recordedAt,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$ExchangeRateHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExchangeRateHistoryTable,
          ExchangeRateHistoryData
        > {
  $$ExchangeRateHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ManagedCurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.managedCurrencies.createAlias(
        $_aliasNameGenerator(
          db.exchangeRateHistory.currencyCode,
          db.managedCurrencies.code,
        ),
      );

  $$ManagedCurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$ManagedCurrenciesTableTableManager(
      $_db,
      $_db.managedCurrencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExchangeRateHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRateHistoryTable> {
  $$ExchangeRateHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateToDefault => $composableBuilder(
    column: $table.rateToDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateScale => $composableBuilder(
    column: $table.rateScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ManagedCurrenciesTableFilterComposer get currencyCode {
    final $$ManagedCurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.managedCurrencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManagedCurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.managedCurrencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRateHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRateHistoryTable> {
  $$ExchangeRateHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateToDefault => $composableBuilder(
    column: $table.rateToDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateScale => $composableBuilder(
    column: $table.rateScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ManagedCurrenciesTableOrderingComposer get currencyCode {
    final $$ManagedCurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.managedCurrencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManagedCurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.managedCurrencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRateHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRateHistoryTable> {
  $$ExchangeRateHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rateToDefault => $composableBuilder(
    column: $table.rateToDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateScale =>
      $composableBuilder(column: $table.rateScale, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ManagedCurrenciesTableAnnotationComposer get currencyCode {
    final $$ManagedCurrenciesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.currencyCode,
          referencedTable: $db.managedCurrencies,
          getReferencedColumn: (t) => t.code,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ManagedCurrenciesTableAnnotationComposer(
                $db: $db,
                $table: $db.managedCurrencies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExchangeRateHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRateHistoryTable,
          ExchangeRateHistoryData,
          $$ExchangeRateHistoryTableFilterComposer,
          $$ExchangeRateHistoryTableOrderingComposer,
          $$ExchangeRateHistoryTableAnnotationComposer,
          $$ExchangeRateHistoryTableCreateCompanionBuilder,
          $$ExchangeRateHistoryTableUpdateCompanionBuilder,
          (ExchangeRateHistoryData, $$ExchangeRateHistoryTableReferences),
          ExchangeRateHistoryData,
          PrefetchHooks Function({bool currencyCode})
        > {
  $$ExchangeRateHistoryTableTableManager(
    _$AppDatabase db,
    $ExchangeRateHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRateHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRateHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExchangeRateHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> rateToDefault = const Value.absent(),
                Value<int> rateScale = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateHistoryCompanion(
                id: id,
                currencyCode: currencyCode,
                rateToDefault: rateToDefault,
                rateScale: rateScale,
                recordedAt: recordedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String currencyCode,
                required int rateToDefault,
                Value<int> rateScale = const Value.absent(),
                required DateTime recordedAt,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateHistoryCompanion.insert(
                id: id,
                currencyCode: currencyCode,
                rateToDefault: rateToDefault,
                rateScale: rateScale,
                recordedAt: recordedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExchangeRateHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (currencyCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.currencyCode,
                                referencedTable:
                                    $$ExchangeRateHistoryTableReferences
                                        ._currencyCodeTable(db),
                                referencedColumn:
                                    $$ExchangeRateHistoryTableReferences
                                        ._currencyCodeTable(db)
                                        .code,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExchangeRateHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRateHistoryTable,
      ExchangeRateHistoryData,
      $$ExchangeRateHistoryTableFilterComposer,
      $$ExchangeRateHistoryTableOrderingComposer,
      $$ExchangeRateHistoryTableAnnotationComposer,
      $$ExchangeRateHistoryTableCreateCompanionBuilder,
      $$ExchangeRateHistoryTableUpdateCompanionBuilder,
      (ExchangeRateHistoryData, $$ExchangeRateHistoryTableReferences),
      ExchangeRateHistoryData,
      PrefetchHooks Function({bool currencyCode})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ClientTagsTableTableManager get clientTags =>
      $$ClientTagsTableTableManager(_db, _db.clientTags);
  $$LedgerTransactionsTableTableManager get ledgerTransactions =>
      $$LedgerTransactionsTableTableManager(_db, _db.ledgerTransactions);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$QuickActionUsagesTableTableManager get quickActionUsages =>
      $$QuickActionUsagesTableTableManager(_db, _db.quickActionUsages);
  $$WalletAccountsTableTableManager get walletAccounts =>
      $$WalletAccountsTableTableManager(_db, _db.walletAccounts);
  $$PersonalFinanceEntriesTableTableManager get personalFinanceEntries =>
      $$PersonalFinanceEntriesTableTableManager(
        _db,
        _db.personalFinanceEntries,
      );
  $$PersonalFinanceFavoritesTableTableManager get personalFinanceFavorites =>
      $$PersonalFinanceFavoritesTableTableManager(
        _db,
        _db.personalFinanceFavorites,
      );
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TransactionTemplatesTableTableManager get transactionTemplates =>
      $$TransactionTemplatesTableTableManager(_db, _db.transactionTemplates);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db, _db.wishlistItems);
  $$SubscriptionItemsTableTableManager get subscriptionItems =>
      $$SubscriptionItemsTableTableManager(_db, _db.subscriptionItems);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$WalletLedgerEntriesTableTableManager get walletLedgerEntries =>
      $$WalletLedgerEntriesTableTableManager(_db, _db.walletLedgerEntries);
  $$ManagedCurrenciesTableTableManager get managedCurrencies =>
      $$ManagedCurrenciesTableTableManager(_db, _db.managedCurrencies);
  $$ExchangeRateHistoryTableTableManager get exchangeRateHistory =>
      $$ExchangeRateHistoryTableTableManager(_db, _db.exchangeRateHistory);
}

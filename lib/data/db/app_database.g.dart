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
          ..write('note: $note')
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
          other.note == this.note);
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultCurrencyCode,
    contactsAutofillEnabled,
    overdueAlertDays,
    profileName,
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
  const AppSetting({
    required this.id,
    required this.defaultCurrencyCode,
    required this.contactsAutofillEnabled,
    required this.overdueAlertDays,
    this.profileName,
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
    };
  }

  AppSetting copyWith({
    int? id,
    String? defaultCurrencyCode,
    bool? contactsAutofillEnabled,
    int? overdueAlertDays,
    Value<String?> profileName = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
    contactsAutofillEnabled:
        contactsAutofillEnabled ?? this.contactsAutofillEnabled,
    overdueAlertDays: overdueAlertDays ?? this.overdueAlertDays,
    profileName: profileName.present ? profileName.value : this.profileName,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('defaultCurrencyCode: $defaultCurrencyCode, ')
          ..write('contactsAutofillEnabled: $contactsAutofillEnabled, ')
          ..write('overdueAlertDays: $overdueAlertDays, ')
          ..write('profileName: $profileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultCurrencyCode,
    contactsAutofillEnabled,
    overdueAlertDays,
    profileName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.defaultCurrencyCode == this.defaultCurrencyCode &&
          other.contactsAutofillEnabled == this.contactsAutofillEnabled &&
          other.overdueAlertDays == this.overdueAlertDays &&
          other.profileName == this.profileName);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> defaultCurrencyCode;
  final Value<bool> contactsAutofillEnabled;
  final Value<int> overdueAlertDays;
  final Value<String?> profileName;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultCurrencyCode = const Value.absent(),
    this.contactsAutofillEnabled = const Value.absent(),
    this.overdueAlertDays = const Value.absent(),
    this.profileName = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultCurrencyCode = const Value.absent(),
    this.contactsAutofillEnabled = const Value.absent(),
    this.overdueAlertDays = const Value.absent(),
    this.profileName = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? defaultCurrencyCode,
    Expression<bool>? contactsAutofillEnabled,
    Expression<int>? overdueAlertDays,
    Expression<String>? profileName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultCurrencyCode != null)
        'default_currency_code': defaultCurrencyCode,
      if (contactsAutofillEnabled != null)
        'contacts_autofill_enabled': contactsAutofillEnabled,
      if (overdueAlertDays != null) 'overdue_alert_days': overdueAlertDays,
      if (profileName != null) 'profile_name': profileName,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? defaultCurrencyCode,
    Value<bool>? contactsAutofillEnabled,
    Value<int>? overdueAlertDays,
    Value<String?>? profileName,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      contactsAutofillEnabled:
          contactsAutofillEnabled ?? this.contactsAutofillEnabled,
      overdueAlertDays: overdueAlertDays ?? this.overdueAlertDays,
      profileName: profileName ?? this.profileName,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultCurrencyCode: $defaultCurrencyCode, ')
          ..write('contactsAutofillEnabled: $contactsAutofillEnabled, ')
          ..write('overdueAlertDays: $overdueAlertDays, ')
          ..write('profileName: $profileName')
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
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
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
    appSettings,
    idxClientsArchivedAt,
    idxClientTagsClient,
    idxTransactionsClientCreated,
    idxTxTagsTx,
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
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> defaultCurrencyCode,
      Value<bool> contactsAutofillEnabled,
      Value<int> overdueAlertDays,
      Value<String?> profileName,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> defaultCurrencyCode,
      Value<bool> contactsAutofillEnabled,
      Value<int> overdueAlertDays,
      Value<String?> profileName,
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
              }) => AppSettingsCompanion(
                id: id,
                defaultCurrencyCode: defaultCurrencyCode,
                contactsAutofillEnabled: contactsAutofillEnabled,
                overdueAlertDays: overdueAlertDays,
                profileName: profileName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> defaultCurrencyCode = const Value.absent(),
                Value<bool> contactsAutofillEnabled = const Value.absent(),
                Value<int> overdueAlertDays = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                defaultCurrencyCode: defaultCurrencyCode,
                contactsAutofillEnabled: contactsAutofillEnabled,
                overdueAlertDays: overdueAlertDays,
                profileName: profileName,
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
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

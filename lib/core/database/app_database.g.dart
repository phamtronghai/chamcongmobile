// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoredNotificationsTable extends StoredNotifications
    with TableInfo<$StoredNotificationsTable, StoredNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredNotificationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeIndexMeta = const VerificationMeta(
    'typeIndex',
  );
  @override
  late final GeneratedColumn<int> typeIndex = GeneratedColumn<int>(
    'type_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawDataMeta = const VerificationMeta(
    'rawData',
  );
  @override
  late final GeneratedColumn<String> rawData = GeneratedColumn<String>(
    'raw_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    receivedAt,
    typeIndex,
    isRead,
    rawData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredNotification> instance, {
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
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('type_index')) {
      context.handle(
        _typeIndexMeta,
        typeIndex.isAcceptableOrUnknown(data['type_index']!, _typeIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIndexMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('raw_data')) {
      context.handle(
        _rawDataMeta,
        rawData.isAcceptableOrUnknown(data['raw_data']!, _rawDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      typeIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type_index'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      rawData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_data'],
      ),
    );
  }

  @override
  $StoredNotificationsTable createAlias(String alias) {
    return $StoredNotificationsTable(attachedDatabase, alias);
  }
}

class StoredNotification extends DataClass
    implements Insertable<StoredNotification> {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final int typeIndex;
  final bool isRead;
  final String? rawData;
  const StoredNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.typeIndex,
    required this.isRead,
    this.rawData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['type_index'] = Variable<int>(typeIndex);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || rawData != null) {
      map['raw_data'] = Variable<String>(rawData);
    }
    return map;
  }

  StoredNotificationsCompanion toCompanion(bool nullToAbsent) {
    return StoredNotificationsCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      receivedAt: Value(receivedAt),
      typeIndex: Value(typeIndex),
      isRead: Value(isRead),
      rawData: rawData == null && nullToAbsent
          ? const Value.absent()
          : Value(rawData),
    );
  }

  factory StoredNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredNotification(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      typeIndex: serializer.fromJson<int>(json['typeIndex']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      rawData: serializer.fromJson<String?>(json['rawData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'typeIndex': serializer.toJson<int>(typeIndex),
      'isRead': serializer.toJson<bool>(isRead),
      'rawData': serializer.toJson<String?>(rawData),
    };
  }

  StoredNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    int? typeIndex,
    bool? isRead,
    Value<String?> rawData = const Value.absent(),
  }) => StoredNotification(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    receivedAt: receivedAt ?? this.receivedAt,
    typeIndex: typeIndex ?? this.typeIndex,
    isRead: isRead ?? this.isRead,
    rawData: rawData.present ? rawData.value : this.rawData,
  );
  StoredNotification copyWithCompanion(StoredNotificationsCompanion data) {
    return StoredNotification(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      typeIndex: data.typeIndex.present ? data.typeIndex.value : this.typeIndex,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      rawData: data.rawData.present ? data.rawData.value : this.rawData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredNotification(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('typeIndex: $typeIndex, ')
          ..write('isRead: $isRead, ')
          ..write('rawData: $rawData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, receivedAt, typeIndex, isRead, rawData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredNotification &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.receivedAt == this.receivedAt &&
          other.typeIndex == this.typeIndex &&
          other.isRead == this.isRead &&
          other.rawData == this.rawData);
}

class StoredNotificationsCompanion extends UpdateCompanion<StoredNotification> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> receivedAt;
  final Value<int> typeIndex;
  final Value<bool> isRead;
  final Value<String?> rawData;
  final Value<int> rowid;
  const StoredNotificationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.typeIndex = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rawData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredNotificationsCompanion.insert({
    required String id,
    required String title,
    required String body,
    required DateTime receivedAt,
    required int typeIndex,
    this.isRead = const Value.absent(),
    this.rawData = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       body = Value(body),
       receivedAt = Value(receivedAt),
       typeIndex = Value(typeIndex);
  static Insertable<StoredNotification> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? receivedAt,
    Expression<int>? typeIndex,
    Expression<bool>? isRead,
    Expression<String>? rawData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (receivedAt != null) 'received_at': receivedAt,
      if (typeIndex != null) 'type_index': typeIndex,
      if (isRead != null) 'is_read': isRead,
      if (rawData != null) 'raw_data': rawData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredNotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? receivedAt,
    Value<int>? typeIndex,
    Value<bool>? isRead,
    Value<String?>? rawData,
    Value<int>? rowid,
  }) {
    return StoredNotificationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      typeIndex: typeIndex ?? this.typeIndex,
      isRead: isRead ?? this.isRead,
      rawData: rawData ?? this.rawData,
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
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (typeIndex.present) {
      map['type_index'] = Variable<int>(typeIndex.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rawData.present) {
      map['raw_data'] = Variable<String>(rawData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('typeIndex: $typeIndex, ')
          ..write('isRead: $isRead, ')
          ..write('rawData: $rawData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoredNotificationsTable storedNotifications =
      $StoredNotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [storedNotifications];
}

typedef $$StoredNotificationsTableCreateCompanionBuilder =
    StoredNotificationsCompanion Function({
      required String id,
      required String title,
      required String body,
      required DateTime receivedAt,
      required int typeIndex,
      Value<bool> isRead,
      Value<String?> rawData,
      Value<int> rowid,
    });
typedef $$StoredNotificationsTableUpdateCompanionBuilder =
    StoredNotificationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<DateTime> receivedAt,
      Value<int> typeIndex,
      Value<bool> isRead,
      Value<String?> rawData,
      Value<int> rowid,
    });

class $$StoredNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredNotificationsTable> {
  $$StoredNotificationsTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get typeIndex => $composableBuilder(
    column: $table.typeIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawData => $composableBuilder(
    column: $table.rawData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredNotificationsTable> {
  $$StoredNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get typeIndex => $composableBuilder(
    column: $table.typeIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawData => $composableBuilder(
    column: $table.rawData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredNotificationsTable> {
  $$StoredNotificationsTableAnnotationComposer({
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

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get typeIndex =>
      $composableBuilder(column: $table.typeIndex, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get rawData =>
      $composableBuilder(column: $table.rawData, builder: (column) => column);
}

class $$StoredNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredNotificationsTable,
          StoredNotification,
          $$StoredNotificationsTableFilterComposer,
          $$StoredNotificationsTableOrderingComposer,
          $$StoredNotificationsTableAnnotationComposer,
          $$StoredNotificationsTableCreateCompanionBuilder,
          $$StoredNotificationsTableUpdateCompanionBuilder,
          (
            StoredNotification,
            BaseReferences<
              _$AppDatabase,
              $StoredNotificationsTable,
              StoredNotification
            >,
          ),
          StoredNotification,
          PrefetchHooks Function()
        > {
  $$StoredNotificationsTableTableManager(
    _$AppDatabase db,
    $StoredNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> typeIndex = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> rawData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredNotificationsCompanion(
                id: id,
                title: title,
                body: body,
                receivedAt: receivedAt,
                typeIndex: typeIndex,
                isRead: isRead,
                rawData: rawData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String body,
                required DateTime receivedAt,
                required int typeIndex,
                Value<bool> isRead = const Value.absent(),
                Value<String?> rawData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredNotificationsCompanion.insert(
                id: id,
                title: title,
                body: body,
                receivedAt: receivedAt,
                typeIndex: typeIndex,
                isRead: isRead,
                rawData: rawData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredNotificationsTable,
      StoredNotification,
      $$StoredNotificationsTableFilterComposer,
      $$StoredNotificationsTableOrderingComposer,
      $$StoredNotificationsTableAnnotationComposer,
      $$StoredNotificationsTableCreateCompanionBuilder,
      $$StoredNotificationsTableUpdateCompanionBuilder,
      (
        StoredNotification,
        BaseReferences<
          _$AppDatabase,
          $StoredNotificationsTable,
          StoredNotification
        >,
      ),
      StoredNotification,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredNotificationsTableTableManager get storedNotifications =>
      $$StoredNotificationsTableTableManager(_db, _db.storedNotifications);
}

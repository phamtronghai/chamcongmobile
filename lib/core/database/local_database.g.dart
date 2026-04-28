// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $FaceRecordsTable extends FaceRecords
    with TableInfo<$FaceRecordsTable, FaceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIDMeta = const VerificationMeta('userID');
  @override
  late final GeneratedColumn<String> userID = GeneratedColumn<String>(
    'user_i_d',
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
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<String> embedding = GeneratedColumn<String>(
    'embedding',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userID, label, embedding];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'face_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FaceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_i_d')) {
      context.handle(
        _userIDMeta,
        userID.isAcceptableOrUnknown(data['user_i_d']!, _userIDMeta),
      );
    } else if (isInserting) {
      context.missing(_userIDMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userID};
  @override
  FaceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaceRecord(
      userID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_i_d'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding'],
      )!,
    );
  }

  @override
  $FaceRecordsTable createAlias(String alias) {
    return $FaceRecordsTable(attachedDatabase, alias);
  }
}

class FaceRecord extends DataClass implements Insertable<FaceRecord> {
  final String userID;
  final String label;
  final String embedding;
  const FaceRecord({
    required this.userID,
    required this.label,
    required this.embedding,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_i_d'] = Variable<String>(userID);
    map['label'] = Variable<String>(label);
    map['embedding'] = Variable<String>(embedding);
    return map;
  }

  FaceRecordsCompanion toCompanion(bool nullToAbsent) {
    return FaceRecordsCompanion(
      userID: Value(userID),
      label: Value(label),
      embedding: Value(embedding),
    );
  }

  factory FaceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaceRecord(
      userID: serializer.fromJson<String>(json['userID']),
      label: serializer.fromJson<String>(json['label']),
      embedding: serializer.fromJson<String>(json['embedding']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userID': serializer.toJson<String>(userID),
      'label': serializer.toJson<String>(label),
      'embedding': serializer.toJson<String>(embedding),
    };
  }

  FaceRecord copyWith({String? userID, String? label, String? embedding}) =>
      FaceRecord(
        userID: userID ?? this.userID,
        label: label ?? this.label,
        embedding: embedding ?? this.embedding,
      );
  FaceRecord copyWithCompanion(FaceRecordsCompanion data) {
    return FaceRecord(
      userID: data.userID.present ? data.userID.value : this.userID,
      label: data.label.present ? data.label.value : this.label,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaceRecord(')
          ..write('userID: $userID, ')
          ..write('label: $label, ')
          ..write('embedding: $embedding')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userID, label, embedding);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaceRecord &&
          other.userID == this.userID &&
          other.label == this.label &&
          other.embedding == this.embedding);
}

class FaceRecordsCompanion extends UpdateCompanion<FaceRecord> {
  final Value<String> userID;
  final Value<String> label;
  final Value<String> embedding;
  final Value<int> rowid;
  const FaceRecordsCompanion({
    this.userID = const Value.absent(),
    this.label = const Value.absent(),
    this.embedding = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FaceRecordsCompanion.insert({
    required String userID,
    required String label,
    required String embedding,
    this.rowid = const Value.absent(),
  }) : userID = Value(userID),
       label = Value(label),
       embedding = Value(embedding);
  static Insertable<FaceRecord> custom({
    Expression<String>? userID,
    Expression<String>? label,
    Expression<String>? embedding,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userID != null) 'user_i_d': userID,
      if (label != null) 'label': label,
      if (embedding != null) 'embedding': embedding,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FaceRecordsCompanion copyWith({
    Value<String>? userID,
    Value<String>? label,
    Value<String>? embedding,
    Value<int>? rowid,
  }) {
    return FaceRecordsCompanion(
      userID: userID ?? this.userID,
      label: label ?? this.label,
      embedding: embedding ?? this.embedding,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userID.present) {
      map['user_i_d'] = Variable<String>(userID.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<String>(embedding.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaceRecordsCompanion(')
          ..write('userID: $userID, ')
          ..write('label: $label, ')
          ..write('embedding: $embedding, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $FaceRecordsTable faceRecords = $FaceRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [faceRecords];
}

typedef $$FaceRecordsTableCreateCompanionBuilder =
    FaceRecordsCompanion Function({
      required String userID,
      required String label,
      required String embedding,
      Value<int> rowid,
    });
typedef $$FaceRecordsTableUpdateCompanionBuilder =
    FaceRecordsCompanion Function({
      Value<String> userID,
      Value<String> label,
      Value<String> embedding,
      Value<int> rowid,
    });

class $$FaceRecordsTableFilterComposer
    extends Composer<_$LocalDatabase, $FaceRecordsTable> {
  $$FaceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userID => $composableBuilder(
    column: $table.userID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FaceRecordsTableOrderingComposer
    extends Composer<_$LocalDatabase, $FaceRecordsTable> {
  $$FaceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userID => $composableBuilder(
    column: $table.userID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FaceRecordsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $FaceRecordsTable> {
  $$FaceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userID =>
      $composableBuilder(column: $table.userID, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);
}

class $$FaceRecordsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $FaceRecordsTable,
          FaceRecord,
          $$FaceRecordsTableFilterComposer,
          $$FaceRecordsTableOrderingComposer,
          $$FaceRecordsTableAnnotationComposer,
          $$FaceRecordsTableCreateCompanionBuilder,
          $$FaceRecordsTableUpdateCompanionBuilder,
          (
            FaceRecord,
            BaseReferences<_$LocalDatabase, $FaceRecordsTable, FaceRecord>,
          ),
          FaceRecord,
          PrefetchHooks Function()
        > {
  $$FaceRecordsTableTableManager(_$LocalDatabase db, $FaceRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaceRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userID = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> embedding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FaceRecordsCompanion(
                userID: userID,
                label: label,
                embedding: embedding,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userID,
                required String label,
                required String embedding,
                Value<int> rowid = const Value.absent(),
              }) => FaceRecordsCompanion.insert(
                userID: userID,
                label: label,
                embedding: embedding,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FaceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $FaceRecordsTable,
      FaceRecord,
      $$FaceRecordsTableFilterComposer,
      $$FaceRecordsTableOrderingComposer,
      $$FaceRecordsTableAnnotationComposer,
      $$FaceRecordsTableCreateCompanionBuilder,
      $$FaceRecordsTableUpdateCompanionBuilder,
      (
        FaceRecord,
        BaseReferences<_$LocalDatabase, $FaceRecordsTable, FaceRecord>,
      ),
      FaceRecord,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$FaceRecordsTableTableManager get faceRecords =>
      $$FaceRecordsTableTableManager(_db, _db.faceRecords);
}

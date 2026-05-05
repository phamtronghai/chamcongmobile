import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Thông báo đẩy đã lưu cục bộ (SQLite qua Drift).
class StoredNotifications extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  IntColumn get typeIndex => integer()();
  BoolColumn get isRead =>
      boolean().withDefault(const Constant(false))();
  TextColumn get rawData => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [StoredNotifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'app_notifications'));

  @override
  int get schemaVersion => 1;

  /// Cập nhật nội dung nếu trùng [id]; giữ nguyên [isRead] khi đã tồn tại.
  Future<void> upsertPushNotification({
    required String id,
    required String title,
    required String body,
    required int typeIndex,
    String? rawData,
  }) async {
    final existing = await (select(storedNotifications)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await into(storedNotifications).insert(
        StoredNotificationsCompanion.insert(
          id: id,
          title: title,
          body: body,
          receivedAt: DateTime.now(),
          typeIndex: typeIndex,
          rawData: Value(rawData),
        ),
      );
    } else {
      await (update(storedNotifications)..where((t) => t.id.equals(id)))
          .write(
        StoredNotificationsCompanion(
          title: Value(title),
          body: Value(body),
          receivedAt: Value(DateTime.now()),
          typeIndex: Value(typeIndex),
          rawData: Value(rawData),
        ),
      );
    }
  }

  Stream<List<StoredNotification>> watchNotificationsNewestFirst() {
    return (select(storedNotifications)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .watch();
  }

  /// Số thông báo chưa đọc (cập nhật theo stream khi DB thay đổi).
  Stream<int> watchUnreadNotificationCount() {
    return (select(storedNotifications)..where((t) => t.isRead.equals(false)))
        .watch()
        .map((list) => list.length);
  }

  Future<void> markNotificationRead(String id) {
    return (update(storedNotifications)..where((t) => t.id.equals(id)))
        .write(const StoredNotificationsCompanion(isRead: Value(true)));
  }

  /// Đánh dấu đã đọc toàn bộ thông báo chưa đọc.
  Future<void> markAllNotificationsRead() {
    return (update(storedNotifications)..where((t) => t.isRead.equals(false)))
        .write(const StoredNotificationsCompanion(isRead: Value(true)));
  }

  Future<void> deleteNotificationById(String id) {
    return (delete(storedNotifications)..where((t) => t.id.equals(id))).go();
  }

  /// Hai bản ghi cố định (1 chưa đọc, 1 đã đọc) để test giao diện. Ghi đè nếu đã tồn tại.
  static const String uiDemoUnreadId = '__ui_demo_unread__';
  static const String uiDemoReadId = '__ui_demo_read__';

  Future<void> seedUiDemoNotifications() async {
    final now = DateTime.now();
    await into(storedNotifications).insert(
      StoredNotificationsCompanion.insert(
        id: uiDemoUnreadId,
        title: 'Thông báo mẫu (chưa đọc)',
        body:
            'Nội dung demo: nhãn "Mới", badge app bar và icon launcher đếm mục chưa đọc.',
        receivedAt: now.subtract(const Duration(minutes: 3)),
        typeIndex: 3,
        isRead: const Value(false),
      ),
      mode: InsertMode.insertOrReplace,
    );
    await into(storedNotifications).insert(
      StoredNotificationsCompanion.insert(
        id: uiDemoReadId,
        title: 'Thông báo mẫu (đã đọc)',
        body:
            'Nội dung demo: không highlight; có thể vuốt để xóa hoặc mở chi tiết.',
        receivedAt: now.subtract(const Duration(hours: 1)),
        typeIndex: 0,
        isRead: const Value(true),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}

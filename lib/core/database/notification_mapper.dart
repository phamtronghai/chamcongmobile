import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/models/notification_item.dart';

NotificationItem notificationItemFromStored(StoredNotification row) {
  final i = row.typeIndex;
  final max = NotificationType.values.length;
  final safe = i >= 0 && i < max ? i : NotificationType.info.index;
  return NotificationItem(
    id: row.id,
    title: row.title,
    message: row.body,
    timestamp: row.receivedAt,
    type: NotificationType.values[safe],
    isRead: row.isRead,
  );
}

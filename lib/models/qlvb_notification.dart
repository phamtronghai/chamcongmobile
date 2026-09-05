/// Thông báo công việc từ API QLVB (`/api/qlvb/notifications`).
class QlvbNotification {
  final String id;
  final String notificationUid;
  final String? eventUid;
  final String? documentUid;
  final String? userAuth;
  final String? eventType;
  final String title;
  final String content;
  final String? actionUrl;
  final Map<String, dynamic>? metadataJson;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QlvbNotification({
    required this.id,
    required this.notificationUid,
    required this.title,
    required this.content,
    required this.isRead,
    this.eventUid,
    this.documentUid,
    this.userAuth,
    this.eventType,
    this.actionUrl,
    this.metadataJson,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory QlvbNotification.fromJson(Map<String, dynamic> json) {
    return QlvbNotification(
      id: '${json['id'] ?? ''}',
      notificationUid: '${json['notification_uid'] ?? ''}',
      eventUid: json['event_uid'] as String?,
      documentUid: json['document_uid'] as String?,
      userAuth: json['user_auth'] as String?,
      eventType: json['event_type'] as String?,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Thông báo công việc',
      content: (json['content'] as String?)?.trim() ?? '',
      actionUrl: json['action_url'] as String?,
      metadataJson: json['metadata_json'] is Map<String, dynamic>
          ? json['metadata_json'] as Map<String, dynamic>
          : null,
      isRead: json['is_read'] == true,
      readAt: parseQlvbDateTime(json['read_at'] as String?),
      createdAt: parseQlvbDateTime(json['created_at'] as String?),
      updatedAt: parseQlvbDateTime(json['updated_at'] as String?),
    );
  }

  QlvbNotification copyWith({bool? isRead, DateTime? readAt}) {
    return QlvbNotification(
      id: id,
      notificationUid: notificationUid,
      eventUid: eventUid,
      documentUid: documentUid,
      userAuth: userAuth,
      eventType: eventType,
      title: title,
      content: content,
      actionUrl: actionUrl,
      metadataJson: metadataJson,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DateTime get timestamp => createdAt ?? updatedAt ?? DateTime.now();
}

/// Parse timestamp dạng `2026-09-05 14:40:35.432506+07`.
DateTime? parseQlvbDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  var s = raw.trim();
  if (s.contains(' ') && !s.contains('T')) {
    s = s.replaceFirst(' ', 'T');
  }
  if (RegExp(r'[+-]\d{2}$').hasMatch(s)) {
    s = '$s:00';
  }
  return DateTime.tryParse(s);
}

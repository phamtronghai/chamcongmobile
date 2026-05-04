import 'package:flutter/material.dart';

enum NotificationType { success, warning, error, info }

extension NotificationTypeUi on NotificationType {
  IconData get iconData {
    return switch (this) {
      NotificationType.success => Icons.check_circle_outline,
      NotificationType.warning => Icons.warning_outlined,
      NotificationType.error => Icons.error_outline,
      NotificationType.info => Icons.info_outline,
    };
  }

  Color foregroundColor(ColorScheme colorScheme) {
    return switch (this) {
      NotificationType.success => colorScheme.secondary,
      NotificationType.warning => colorScheme.tertiary,
      NotificationType.error => colorScheme.error,
      NotificationType.info => colorScheme.primary,
    };
  }

  String get labelVi {
    return switch (this) {
      NotificationType.success => 'Thành công',
      NotificationType.warning => 'Cảnh báo',
      NotificationType.error => 'Lỗi',
      NotificationType.info => 'Thông tin',
    };
  }
}

/// Một mục trong danh sách thông báo (mock hoặc từ API sau này).
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

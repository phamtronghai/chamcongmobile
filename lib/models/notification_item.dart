import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

enum NotificationType { success, warning, error, info }

extension NotificationTypeUi on NotificationType {
  Color foregroundColor(ColorScheme colorScheme) {
    return switch (this) {
      NotificationType.success => ColorConstants.successColor,
      NotificationType.warning => ColorConstants.warningColor,
      NotificationType.error => ColorConstants.errorColor,
      NotificationType.info => ColorConstants.infoColor,
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/models/notification_item.dart';

/// Màn hiển thị đầy đủ một thông báo (mở từ [NotificationScreen]).
class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chi tiết thông báo',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    notification.type.iconData,
                    size: 18,
                    color: notification.type.foregroundColor(colorScheme),
                  ),
                  label: Text(notification.type.labelVi),
                  side: BorderSide(
                    color: notification.type.foregroundColor(colorScheme).withValues(alpha: 0.35),
                  ),
                ),
                if (!notification.isRead)
                  Chip(
                    label: const Text('Chưa đọc'),
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fmt.format(notification.timestamp.toLocal()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nội dung',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

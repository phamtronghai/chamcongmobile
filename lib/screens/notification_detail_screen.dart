import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/models/notification_item.dart';

/// Màn hiển thị đầy đủ một thông báo (mở từ [NotificationScreen]).
class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    // Đổi định dạng một chút: thêm dấu gạch ngang giữa ngày và giờ cho dễ nhìn
    final fmt = DateFormat('dd/MM/yyyy - HH:mm', 'vi_VN');

    final Color scaffoldBg = isLight
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : colorScheme.surfaceContainerLow;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: const CustomAppBar(title: 'Chi tiết thông báo'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PHẦN HEADER: TIÊU ĐỀ & THỜI GIAN ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(
                      alpha: isLight ? 0.07 : 0.35,
                    ),
                    blurRadius: isLight ? 12 : 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SamcomChip(
                        label: notification.type.labelVi,
                        leading: Icon(
                          notification.type.iconData,
                          size: 18,
                          color: Colors.white,
                        ),
                        variant: SamcomChipVariant.filled,
                        selected: true,
                        dense: true,
                        color: notification.type.foregroundColor(colorScheme),
                        onPressed: null,
                      ),
                      if (!notification.isRead)
                        SamcomChip(
                          label: 'Chưa đọc',
                          variant: SamcomChipVariant.filled,
                          selected: false,
                          dense: true,
                          color: colorScheme.primary,
                          onPressed: null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tiêu đề thông báo
                  Text(
                    notification.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, // In đậm hơn
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Thời gian có kèm icon đồng hồ
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fmt.format(notification.timestamp.toLocal()),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- PHẦN BODY: NỘI DUNG CHI TIẾT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: isLight
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(
                      alpha: isLight ? 0.45 : 0.4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SamcomChip(
                      label: 'Nội dung chi tiết',
                      leading: const Icon(
                        Icons.subject_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      variant: SamcomChipVariant.filled,
                      selected: true,
                      dense: true,
                      color: colorScheme.primary,
                      onPressed: null,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(height: 1), // Đường kẻ ngang phân cách
                    ),

                    // Văn bản nội dung
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurface.withValues(
                          alpha: isLight ? 0.92 : 0.94,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ), // Căn lề dưới cùng để khi cuộn không bị sát viền màn hình
          ],
        ),
      ),
    );
  }
}

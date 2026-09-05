import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Empty state thống nhất: icon + text trên 1 hàng ngang.
/// Luôn căn trên (không giữa theo chiều dọc) với khoảng cách dọc cố định 16.
class BaseEmptyState extends StatelessWidget {
  static const IconData defaultIcon = Icons.history;
  static const String defaultTitle = 'Chưa có dữ liệu';
  static const double verticalPadding = 16;

  final IconData icon;
  final String title;

  const BaseEmptyState({
    super.key,
    this.icon = defaultIcon,
    this.title = defaultTitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    // heightFactor: 1 → chỉ cao bằng nội dung khi parent lỏng (Column).
    // Trong Expanded (constraint chặt) vẫn căn trên, không giữa theo chiều dọc.
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextConstants.appTextBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

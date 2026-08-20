import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Empty state thống nhất: icon + text trên 1 hàng ngang.
class BaseEmptyState extends StatelessWidget {
  static const IconData defaultIcon = Icons.history;
  static const String defaultTitle = 'Chưa có dữ liệu';

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

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextConstants.appTextBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

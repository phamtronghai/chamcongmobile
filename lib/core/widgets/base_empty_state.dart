import 'package:flutter/material.dart';

/// Empty state thống nhất: icon lịch sử 32px + "Chưa có dữ liệu".
class BaseEmptyState extends StatelessWidget {
  static const IconData defaultIcon = Icons.history;
  static const String defaultTitle = 'Chưa có dữ liệu';

  final IconData icon;
  final String title;
  final TextAlign textAlign;

  const BaseEmptyState({
    super.key,
    this.icon = defaultIcon,
    this.title = defaultTitle,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:flutter/material.dart';

/// Empty state khi không kết nối / lỗi phía server — kéo để thử lại.
class ServerConnectionEmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Color? color;

  const ServerConnectionEmptyState({
    super.key,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final refreshColor = color ?? Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          BaseEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không kết nối được máy chủ',
          ),
        ],
      ),
    );
  }
}

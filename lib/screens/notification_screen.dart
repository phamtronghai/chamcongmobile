import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/database/notification_mapper.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/notification_item.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel user;

  const NotificationScreen({super.key, required this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home', extra: widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thông báo',
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Quay lại',
          onPressed: _onBack,
        ),
      ),
      body: StreamBuilder<List<StoredNotification>>(
        stream:
            GetIt.instance<AppDatabase>().watchNotificationsNewestFirst(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Lỗi tải thông báo: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final rows = snapshot.data ?? const <StoredNotification>[];
          final items = rows.map(notificationItemFromStored).toList();
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: _buildEmptyState(),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildNotificationListItem(items[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không có thông báo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Bạn sẽ nhận được thông báo khi có sự kiện mới',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationListItem(NotificationItem notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = notification.type.foregroundColor(colorScheme);

    return BaseInfoCard(
      title: notification.title,
      titleTrailing: Text(
        _formatTimestamp(notification.timestamp),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      badge: Icon(
        notification.type.iconData,
        size: 22,
        color: typeColor,
      ),
      highlightText: !notification.isRead ? 'Mới' : null,
      detailText: notification.message,
      detailMaxLines: 2,
      isActive: !notification.isRead,
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => _openNotificationDetail(notification),
    );
  }

  Future<void> _openNotificationDetail(NotificationItem notification) async {
    await GetIt.instance<AppDatabase>().markNotificationRead(notification.id);
    if (!mounted) return;
    context.pushNamed(
      'notification-detail',
      extra: NotificationItem(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        type: notification.type,
        isRead: true,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

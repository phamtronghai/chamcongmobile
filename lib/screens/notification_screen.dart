import 'dart:async';

import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/notification_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Danh sách thông báo mẫu (sau này sẽ lấy từ API)
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '2',
      title: 'Nhắc nhở chấm công',
      message: 'Đừng quên chấm công khi đến văn phòng',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.info,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Cập nhật hệ thống',
      message: 'Hệ thống chấm công đã được cập nhật phiên bản mới',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.warning,
      isRead: true,
    ),
  ];

  String? _fcmToken;
  String? _apnsToken;
  bool _tokensLoading = true;
  String? _tokenLoadError;
  StreamSubscription<String>? _fcmTokenRefreshSub;

  @override
  void initState() {
    super.initState();
    _loadTokens();
    _fcmTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      t,
    ) {
      if (mounted) setState(() => _fcmToken = t);
    });
  }

  @override
  void dispose() {
    _fcmTokenRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    setState(() {
      _tokensLoading = true;
      _tokenLoadError = null;
    });
    try {
      final fcm = await FirebaseMessaging.instance.getToken();
      String? apns;
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        apns = await FirebaseMessaging.instance.getAPNSToken();
      }
      if (!mounted) return;
      setState(() {
        _fcmToken = fcm;
        _apnsToken = apns;
        _tokensLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tokenLoadError = e.toString();
        _tokensLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadTokens();
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _copyToClipboard(String label, String? value) async {
    final text = value ?? '';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text.isEmpty
              ? 'Đã copy (rỗng) — $label'
              : 'Đã sao chép $label',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool get _isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Widget _buildPushTokensSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_tokenLoadError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(
          'Lỗi tải token: $_tokenLoadError',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
          ),
        ),
      );
    }

    final fcmDisplay = _tokensLoading
        ? 'Đang tải...'
        : (_fcmToken ?? 'Chưa có');
    final apnsDisplay = _tokensLoading
        ? 'Đang tải...'
        : (!_isApple
              ? 'Không áp dụng (chỉ iOS/macOS)'
              : (_apnsToken ?? 'Chưa có'));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Token push (chạm để sao chép)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildTokenCard(
            label: 'FCM token',
            display: fcmDisplay,
            copyValue: _fcmToken,
            enabled: !_tokensLoading,
          ),
          const SizedBox(height: 8),
          _buildTokenCard(
            label: 'APNs token',
            display: apnsDisplay,
            copyValue: _isApple ? _apnsToken : '',
            enabled: !_tokensLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard({
    required String label,
    required String display,
    required String? copyValue,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled
            ? () => _copyToClipboard(label, copyValue)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: enabled
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                display,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Mở bằng context.go('/notification', …) không có route để pop
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPushTokensSection(),
          Expanded(
            child: _notifications.isEmpty
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: Theme.of(context).colorScheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: _buildEmptyState(),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: Theme.of(context).colorScheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationListItem(notification);
                      },
                    ),
                  ),
          ),
        ],
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
      badge: Icon(
        notification.type.iconData,
        size: 22,
        color: typeColor,
      ),
      highlightText: !notification.isRead ? 'Mới' : null,
      subInfoWidget: Text(
        _formatTimestamp(notification.timestamp),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      detailText: notification.message,
      detailMaxLines: 2,
      isActive: !notification.isRead,
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => _openNotificationDetail(notification),
    );
  }

  void _openNotificationDetail(NotificationItem notification) {
    setState(() {
      try {
        _notifications.firstWhere((n) => n.id == notification.id).isRead = true;
      } catch (_) {}
    });
    context.pushNamed(
      'notification-detail',
      extra: notification,
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

import 'dart:async';

import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/database/notification_mapper.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/notification_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/repositories/device_repository.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel user;

  const NotificationScreen({super.key, required this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

/// Kết quả gọi API đăng ký thiết bị (FCM token lên server).
enum _ServerTokenUploadState {
  waitingFcm,
  uploading,
  uploaded,
  failedNoToken,
  failedApi,
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _fcmToken;
  bool _fcmLoading = true;
  StreamSubscription<String>? _fcmTokenRefreshSub;
  _ServerTokenUploadState _serverUploadState =
      _ServerTokenUploadState.waitingFcm;
  String? _serverUploadError;

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
    _fcmTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      t,
    ) async {
      if (!mounted) return;
      setState(() => _fcmToken = t);
      await _syncFcmTokenToServerAfterDeviceReady();
    });
  }

  @override
  void dispose() {
    _fcmTokenRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _loadFcmToken() async {
    setState(() {
      _fcmLoading = true;
      _serverUploadState = _ServerTokenUploadState.waitingFcm;
      _serverUploadError = null;
    });
    try {
      final t = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      setState(() {
        _fcmToken = t;
        _fcmLoading = false;
      });
      await _syncFcmTokenToServerAfterDeviceReady();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fcmToken = null;
        _fcmLoading = false;
        _serverUploadState = _ServerTokenUploadState.failedNoToken;
        _serverUploadError = null;
      });
    }
  }

  Future<void> _syncFcmTokenToServerAfterDeviceReady() async {
    if (!mounted || _fcmLoading) return;
    final token = _fcmToken?.trim();
    if (token == null || token.isEmpty) {
      setState(() {
        _serverUploadState = _ServerTokenUploadState.failedNoToken;
        _serverUploadError = null;
      });
      return;
    }
    setState(() {
      _serverUploadState = _ServerTokenUploadState.uploading;
      _serverUploadError = null;
    });
    try {
      await DeviceRepository().registerFcmToken(
        token: token,
        userId: widget.user.id,
      );
      if (!mounted) return;
      setState(() {
        _serverUploadState = _ServerTokenUploadState.uploaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverUploadState = _ServerTokenUploadState.failedApi;
        _serverUploadError = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadFcmToken();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  bool get _fcmRegistered =>
      _fcmToken != null && _fcmToken!.trim().isNotEmpty;

  Future<void> _onRegistrationBadgeTap() async {
    final token = _fcmToken?.trim() ?? '';
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    if (token.isEmpty) {
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Chưa có FCM token — đã copy chuỗi rỗng',
        type: CustomSnackbarType.warning,
      );
    } else {
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Đã sao chép FCM token',
        type: CustomSnackbarType.success,
      );
    }
  }

  Widget _buildFcmRegistrationBadge() {
    final theme = Theme.of(context);

    if (_fcmLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SamcomChip(
            label: 'Đang kiểm tra đăng ký thông báo…',
            dense: true,
            onPressed: null,
            variant: SamcomChipVariant.outlined,
            leading: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    final registered = _fcmRegistered;
    final String label = registered
        ? 'Đã đăng ký thông báo'
        : 'Chưa đăng ký thông báo';
    final Color accent =
        registered ? const Color(0xFF2E7D32) : const Color(0xFFE65100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: 'Chạm để sao chép FCM token',
          child: SamcomChip(
            label: label,
            onPressed: _onRegistrationBadgeTap,
            variant: SamcomChipVariant.filled,
            selected: true,
            color: accent,
            leading: Icon(
              registered
                  ? Icons.mark_email_read_outlined
                  : Icons.mail_outline,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerTokenUploadChip() {
    final theme = Theme.of(context);

    switch (_serverUploadState) {
      case _ServerTokenUploadState.waitingFcm:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SamcomChip(
              label: 'Đăng ký server: chờ FCM token…',
              dense: true,
              onPressed: null,
              variant: SamcomChipVariant.outlined,
              leading: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      case _ServerTokenUploadState.uploading:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SamcomChip(
              label: 'Đang gửi token lên server…',
              dense: true,
              onPressed: null,
              variant: SamcomChipVariant.outlined,
              leading: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      case _ServerTokenUploadState.uploaded:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: 'Chạm để gửi lại token lên server',
              child: SamcomChip(
                label: 'Đã gửi token lên server',
                onPressed: () => _syncFcmTokenToServerAfterDeviceReady(),
                variant: SamcomChipVariant.filled,
                selected: true,
                color: const Color(0xFF1565C0),
                leading: const Icon(
                  Icons.cloud_done_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      case _ServerTokenUploadState.failedNoToken:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SamcomChip(
              label: 'Chưa gửi token (thiếu FCM)',
              onPressed: null,
              variant: SamcomChipVariant.filled,
              selected: true,
              color: const Color(0xFFE65100),
              leading: const Icon(
                Icons.cloud_off_outlined,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      case _ServerTokenUploadState.failedApi:
        final err = _serverUploadError ?? 'Lỗi không xác định';
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: err,
              child: SamcomChip(
                label: 'Lỗi gửi token lên server',
                onPressed: () => _syncFcmTokenToServerAfterDeviceReady(),
                variant: SamcomChipVariant.filled,
                selected: true,
                color: const Color(0xFFC62828),
                leading: const Icon(
                  Icons.error_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
    }
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFcmRegistrationBadge(),
          _buildServerTokenUploadChip(),
          Expanded(
            child: StreamBuilder<List<StoredNotification>>(
              stream: GetIt.instance<AppDatabase>()
                  .watchNotificationsNewestFirst(),
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
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: _buildEmptyState(),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationListItem(items[index]);
                    },
                  ),
                );
              },
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

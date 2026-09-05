import 'dart:async';

import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/database/notification_mapper.dart';
import 'package:attendancebyface/core/repositories/device_repository.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/models/notification_item.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// Tab "Tất cả": thông báo local / FCM như trước.
class NotificationAllTab extends StatefulWidget {
  final UserModel user;

  const NotificationAllTab({super.key, required this.user});

  @override
  State<NotificationAllTab> createState() => _NotificationAllTabState();
}

class _NotificationAllTabState extends State<NotificationAllTab> {
  String? _fcmToken;
  bool _fcmLoading = true;
  StreamSubscription<String>? _fcmTokenRefreshSub;

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
    setState(() => _fcmLoading = true);
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
      });
    }
  }

  Future<void> _syncFcmTokenToServerAfterDeviceReady() async {
    if (!mounted || _fcmLoading) return;
    final token = _fcmToken?.trim();
    if (token == null || token.isEmpty) return;
    try {
      await locator<DeviceRepository>().registerFcmToken(
        token: token,
        userId: widget.user.id,
      );
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    await _loadFcmToken();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _markAllRead() async {
    await GetIt.instance<AppDatabase>().markAllNotificationsRead();
    if (!mounted) return;
    CustomSnackbar.showIfMounted(
      state: this,
      message: 'Đã đánh dấu tất cả là đã đọc',
      type: CustomSnackbarType.success,
    );
  }

  Future<void> _deleteAll() async {
    await GetIt.instance<AppDatabase>().deleteAllNotifications();
    if (!mounted) return;
    CustomSnackbar.showIfMounted(
      state: this,
      message: 'Đã xóa tất cả thông báo',
      type: CustomSnackbarType.success,
    );
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) return;
    await GetIt.instance<AppDatabase>().markNotificationRead(notification.id);
  }

  Future<void> _deleteNotification(String id) async {
    await GetIt.instance<AppDatabase>().deleteNotificationById(id);
    if (!mounted) return;
    CustomSnackbar.showIfMounted(
      state: this,
      message: 'Đã xóa thông báo',
      type: CustomSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StoredNotification>>(
      stream: GetIt.instance<AppDatabase>().watchNotificationsNewestFirst(),
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
        final allRead =
            items.isNotEmpty && items.every((item) => item.isRead);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CustomButton(
                    variant: CustomButtonVariant.textButton,
                    text: allRead
                        ? 'Xóa tất cả'
                        : 'Đánh dấu tất cả là đã đọc',
                    onPressed: allRead ? _deleteAll : _markAllRead,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: Theme.of(context).colorScheme.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [BaseEmptyState()],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: Theme.of(context).colorScheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationListItem(items[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationListItem(NotificationItem notification) {
    final colorScheme = Theme.of(context).colorScheme;

    return BaseInfoCard(
      title: notification.title,
      titleMaxLines: 1,
      headerWidget: Row(
        children: [
          Expanded(
            child: Text(
              _formatTimestamp(notification.timestamp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextConstants.appTextRegular.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: 8),
            SamcomChip(
              label: 'Mới',
              dense: true,
              fontSize: 12,
              variant: SamcomChipVariant.outlined,
              color: colorScheme.primary,
            ),
          ],
        ],
      ),
      badge: Image.asset(
        AppConfig.logoOrg,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
      detailText: notification.message,
      detailMaxLines: 1,
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showNotificationSheet(notification),
    );
  }

  void _showNotificationSheet(NotificationItem notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd/MM/yyyy - HH:mm', 'vi_VN');
    var current = notification;

    SamcomSheet.show<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> refreshSheetRead() async {
              await _markAsRead(current);
              if (!mounted) return;
              setState(() {});
              setSheetState(() {
                current = NotificationItem(
                  id: current.id,
                  title: current.title,
                  message: current.message,
                  timestamp: current.timestamp,
                  type: current.type,
                  isRead: true,
                );
              });
            }

            return SamcomSheet(
              title: current.title,
              subtitleWidget: _buildSheetSubtitle(current, fmt),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      current.message,
                      style: TextConstants.appTextRegular.copyWith(
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Đã đọc',
                            icon: Icons.done,
                            variant: CustomButtonVariant.normalButton,
                            onPressed: current.isRead
                                ? null
                                : () => refreshSheetRead(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Xóa',
                            icon: Icons.delete_outline,
                            variant: CustomButtonVariant.normalButton,
                            onPressed: () async {
                              Navigator.pop(sheetContext);
                              await _deleteNotification(current.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetSubtitle(NotificationItem notification, DateFormat fmt) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = notification.type.foregroundColor(colorScheme);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          fmt.format(notification.timestamp.toLocal()),
          style: TextConstants.appTextRegular.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        SamcomChip(
          label: notification.type.labelVi,
          dense: true,
          fontSize: 12,
          variant: SamcomChipVariant.outlined,
          color: typeColor,
        ),
        SamcomChip(
          label: notification.isRead ? 'Đã đọc' : 'Chưa đọc',
          dense: true,
          fontSize: 12,
          variant: SamcomChipVariant.outlined,
          color: notification.isRead
              ? ColorConstants.successColor
              : colorScheme.primary,
        ),
      ],
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

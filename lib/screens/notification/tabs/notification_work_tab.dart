import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/services/qlvb_notification_service.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/models/qlvb_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tab "Công việc": thông báo QLVB từ API.
class NotificationWorkTab extends StatefulWidget {
  final ValueChanged<int>? onUnreadCountChanged;

  const NotificationWorkTab({super.key, this.onUnreadCountChanged});

  @override
  State<NotificationWorkTab> createState() => _NotificationWorkTabState();
}

class _NotificationWorkTabState extends State<NotificationWorkTab> {
  final QlvbNotificationService _service = QlvbNotificationService();

  List<QlvbNotification> _items = const [];
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.fetchNotifications(),
        _service.fetchUnreadCount(),
      ]);
      if (!mounted) return;
      final list = results[0] as List<QlvbNotification>;
      final unread = results[1] as int;
      setState(() {
        _items = list;
        _unreadCount = unread;
        _loading = false;
      });
      widget.onUnreadCountChanged?.call(unread);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _refreshUnread() async {
    try {
      final unread = await _service.fetchUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = unread);
      widget.onUnreadCountChanged?.call(unread);
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((e) => e.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();
        _unreadCount = 0;
      });
      widget.onUnreadCountChanged?.call(0);
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Đã đánh dấu tất cả là đã đọc',
        type: CustomSnackbarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Không thể đánh dấu đã đọc: $e',
        type: CustomSnackbarType.error,
      );
    }
  }

  Future<void> _markAsRead(QlvbNotification item) async {
    if (item.isRead) return;
    try {
      await _service.markAsRead(item.notificationUid);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (e) => e.notificationUid == item.notificationUid
                  ? e.copyWith(isRead: true, readAt: DateTime.now())
                  : e,
            )
            .toList();
      });
      await _refreshUnread();
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Không thể đánh dấu đã đọc: $e',
        type: CustomSnackbarType.error,
      );
    }
  }

  Future<void> _deleteNotification(QlvbNotification item) async {
    try {
      await _service.deleteNotification(item.notificationUid);
      if (!mounted) return;
      setState(() {
        _items = _items
            .where((e) => e.notificationUid != item.notificationUid)
            .toList();
      });
      await _refreshUnread();
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Đã xóa thông báo',
        type: CustomSnackbarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showIfMounted(
        state: this,
        message: 'Không thể xóa thông báo: $e',
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allRead =
        _items.isNotEmpty && _items.every((item) => item.isRead);

    if (_loading && _items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_error != null && _items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: colorScheme.primary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_items.isNotEmpty && !allRead)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: CustomButton(
                variant: CustomButtonVariant.textButton,
                text: _unreadCount > 0
                    ? 'Đánh dấu tất cả là đã đọc ($_unreadCount)'
                    : 'Đánh dấu tất cả là đã đọc',
                onPressed: _markAllRead,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: _items.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  color: colorScheme.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [BaseEmptyState()],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: colorScheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(_items[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildListItem(QlvbNotification notification) {
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
      detailText: notification.content,
      detailMaxLines: 1,
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showSheet(notification),
    );
  }

  void _showSheet(QlvbNotification notification) {
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
              setSheetState(() {
                current = current.copyWith(
                  isRead: true,
                  readAt: DateTime.now(),
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
                      current.content,
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
                              await _deleteNotification(current);
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

  Widget _buildSheetSubtitle(QlvbNotification notification, DateFormat fmt) {
    final colorScheme = Theme.of(context).colorScheme;
    final eventLabel = _eventTypeLabel(notification.eventType);

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
        if (eventLabel != null)
          SamcomChip(
            label: eventLabel,
            dense: true,
            fontSize: 12,
            variant: SamcomChipVariant.outlined,
            color: ColorConstants.infoColor,
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

  String? _eventTypeLabel(String? eventType) {
    if (eventType == null || eventType.isEmpty) return null;
    return switch (eventType) {
      'document_assigned_to_staff' => 'Giao văn bản',
      _ => eventType,
    };
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

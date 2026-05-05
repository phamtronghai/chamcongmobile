import 'package:attendancebyface/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onTitleTap,
    this.onHistoryTap,
    this.onNotificationTap,
    this.tabs,
    this.tabController,
    this.onTabChanged,
    this.showTabs = false,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.actionsBeforeNotification,
  });

  final String title;
  final VoidCallback? onTitleTap; // Callback for hidden actions
  final VoidCallback? onHistoryTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? tabs;
  final TabController? tabController;
  final ValueChanged<int>? onTabChanged;
  final bool showTabs;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  /// Hiển thị trước nút thông báo (nếu có), ví dụ "đã đọc hết".
  final List<Widget>? actionsBeforeNotification;

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize {
    if (showTabs && tabs != null) {
      return const Size.fromHeight(104);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

class CustomAppBarState extends State<CustomAppBar> {
  Widget _buildNotificationAction() {
    final onTap = widget.onNotificationTap!;

    Widget bellIconButton({required int count}) {
      final label = count > 10 ? '10+' : '$count';
      return IconButton(
        tooltip: 'Thông báo',
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: onTap,
        icon: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            if (count > 0)
              Positioned(
                right: -4,
                top: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (!GetIt.instance.isRegistered<AppDatabase>()) {
      return bellIconButton(count: 0);
    }

    return StreamBuilder<int>(
      stream: GetIt.instance<AppDatabase>().watchUnreadNotificationCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return bellIconButton(count: count);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      leading: widget.leading,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Implement 5-tap logic internally or expose callback
          if (widget.onTitleTap != null) {
            widget.onTitleTap!();
          }
        },
        child: Text(
          widget.title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        ...?widget.actionsBeforeNotification,
        if (widget.onNotificationTap != null) _buildNotificationAction(),
      ],
      bottom: widget.showTabs && widget.tabs != null
          ? TabBar(
              controller: widget.tabController,
              onTap: widget.onTabChanged,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: widget.tabs!,
            )
          : null,
    );
  }
}

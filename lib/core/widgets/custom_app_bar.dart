import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title, this.onNotificationTap});

  final String title;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return AppBar(
      backgroundColor: scaffoldBg,
      foregroundColor: colorScheme.primary,
      elevation: 0,
      title: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextConstants.appTextBold.copyWith(color: colorScheme.primary),
      ),
      centerTitle: true,
      actions: [
        if (onNotificationTap != null)
          _NotificationAction(onTap: onNotificationTap!),
      ],
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget bellIconButton({required int count}) {
      final label = count > 10 ? '10+' : '$count';
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Thông báo',
            icon: Icon(Icons.notifications_outlined, color: primary),
            onPressed: onTap,
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: ColorConstants.errorColor,
                  borderRadius: BorderRadius.circular(
                    ColorConstants.defaultBorderRadius,
                  ),
                  border: Border.all(color: primary, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextConstants.appTextBold.copyWith(
                    color: ButtonConstants.ctaForegroundOn(primary),
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
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
}

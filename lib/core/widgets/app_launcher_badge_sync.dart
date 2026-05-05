import 'dart:async';
import 'dart:math' as math;

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:flutter/material.dart';

/// Đồng bộ số badge trên icon ứng dụng (launcher) với số thông báo chưa đọc trong DB.
class AppLauncherBadgeSync extends StatefulWidget {
  const AppLauncherBadgeSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppLauncherBadgeSync> createState() => _AppLauncherBadgeSyncState();
}

class _AppLauncherBadgeSyncState extends State<AppLauncherBadgeSync> {
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    if (!locator.isRegistered<AppDatabase>()) return;
    _sub = locator<AppDatabase>().watchUnreadNotificationCount().listen(
          _apply,
        );
  }

  Future<void> _apply(int count) async {
    if (!await AppBadgePlus.isSupported()) return;
    final n = math.max(0, count);
    try {
      await AppBadgePlus.updateBadge(n);
    } catch (_) {
      // Một số launcher/Android không hỗ trợ hoặc thiếu quyền.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:attendancebyface/core/services/qlvb_notification_service.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/screens/notification/tabs/notification_all_tab.dart';
import 'package:attendancebyface/screens/notification/tabs/notification_work_tab.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel user;

  const NotificationScreen({super.key, required this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final QlvbNotificationService _qlvbService = QlvbNotificationService();
  int _workUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _prefetchWorkUnread();
  }

  Future<void> _prefetchWorkUnread() async {
    try {
      final count = await _qlvbService.fetchUnreadCount();
      if (!mounted) return;
      setState(() => _workUnreadCount = count);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workTabLabel = _workUnreadCount > 0
        ? 'Công việc ($_workUnreadCount)'
        : 'Công việc';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Thông báo'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Center(
              child: SamcomTabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Tất cả'),
                  Tab(text: workTabLabel),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NotificationAllTab(user: widget.user),
                NotificationWorkTab(
                  onUnreadCountChanged: (count) {
                    if (!mounted) return;
                    setState(() => _workUnreadCount = count);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

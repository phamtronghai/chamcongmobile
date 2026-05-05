import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'leave_screen_register_tab.dart';
import 'leave_screen_approval_tab.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/widgets/base_screen.dart';

class LeaveScreen extends BaseScreen {
  const LeaveScreen({super.key});

  @override
  Widget buildContent(UserModel user) {
    return _LeaveScreenContent(user: user);
  }
}

class _LeaveScreenContent extends StatefulWidget {
  final UserModel user;

  const _LeaveScreenContent({required this.user});

  @override
  State<_LeaveScreenContent> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<_LeaveScreenContent>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Role detection dựa trên canApprove
  bool get _isManager {
    return widget.user.canApprove == 'tp';
  }

  bool get _isBod {
    return widget.user.canApprove == 'bgd';
  }

  @override
  void initState() {
    super.initState();

    // Xác định số tab cần thiết
    final tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  int _getTabCount() {
    if (_isBod) return 1; // Chỉ có tab phê duyệt
    if (_isManager) return 2; // Cả 2 tab
    return 1; // Chỉ có tab đăng ký
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = _getTabCount();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nghỉ phép',
        showTabs: tabCount > 1,
        tabs: tabCount > 1 ? _buildTabs() : null,
        tabController: tabCount > 1 ? _tabController : null,
        automaticallyImplyLeading: false,
        onNotificationTap: () {
          AppRouter.goToNotification(context, widget.user);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
    );
  }

  List<Widget>? _buildTabs() {
    if (_isBod) {
      return [_buildApprovalTab()];
    } else if (_isManager) {
      return [const Tab(text: 'Đăng ký'), _buildApprovalTab()];
    } else {
      return [const Tab(text: 'Đăng ký')];
    }
  }

  Widget _buildApprovalTab() {
    return const Tab(text: 'Phê duyệt');
  }

  Widget _buildBody() {
    if (_isBod) {
      // Ban giám đốc: chỉ có tab phê duyệt
      return const LeaveScreenApprovalTab();
    } else if (_isManager) {
      // Trưởng/Phó: có cả 2 tab
      return TabBarView(
        controller: _tabController,
        children: [
          const LeaveScreenRegisterTab(),
          const LeaveScreenApprovalTab(),
        ],
      );
    } else {
      // Nhân viên: chỉ có tab đăng ký
      return const LeaveScreenRegisterTab();
    }
  }
}

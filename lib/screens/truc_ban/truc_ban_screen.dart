import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/screens/truc_ban/tabs/danh_sach_truc_ban_tab.dart';
import 'package:attendancebyface/screens/truc_ban/tabs/dang_ky_tab.dart';
import 'package:attendancebyface/screens/truc_ban/tabs/khach_don_vi_tab.dart';
import 'package:attendancebyface/screens/truc_ban/tabs/duyet_ra_ngoai_tab.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';
import 'package:attendancebyface/screens/attendance/widgets/daily_info_section.dart';

enum _TrucBanTabKind { trucBan, dangKy, khachDonVi, duyet }

/// Màn hình chính của chức năng Trực ban
class TrucBanScreen extends StatefulWidget {
  final bool isActive;

  const TrucBanScreen({super.key, this.isActive = true});

  @override
  State<TrucBanScreen> createState() => _TrucBanScreenState();
}

class _TrucBanScreenState extends State<TrucBanScreen>
    with TickerProviderStateMixin {
  late TrucBanCubit _cubit;
  late TabController _tabController;
  bool _isProcessing = false;
  DateTime _selectedDate = DateTime.now();
  PhanQuyen? _phanQuyen;

  @override
  void initState() {
    super.initState();
    _cubit = TrucBanCubit();
    _tabController = TabController(
      length: _visibleTabKinds().length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);

    _cubit.layDanhSachTrucBan(_selectedDate);
    _cubit.layPhanQuyen(forceRefresh: true);
  }

  List<_TrucBanTabKind> _visibleTabKinds([PhanQuyen? phanQuyen]) {
    final pq = phanQuyen ?? _phanQuyen;
    final tabs = [_TrucBanTabKind.trucBan, _TrucBanTabKind.dangKy];
    if (pq?.canViewDonVi == true) {
      tabs.add(_TrucBanTabKind.khachDonVi);
    }
    if (pq?.canApproveRaNgoai == true) {
      tabs.add(_TrucBanTabKind.duyet);
    }
    return tabs;
  }

  void _syncTabController(PhanQuyen phanQuyen) {
    final tabs = _visibleTabKinds(phanQuyen);
    if (_tabController.length == tabs.length) return;

    final oldIndex = _tabController.index;
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: oldIndex.clamp(0, tabs.length - 1),
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _loadDataForTab(_visibleTabKinds()[_tabController.index]);
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadDataForTab(_visibleTabKinds()[_tabController.index], date: date);
  }

  void _loadDataForTab(_TrucBanTabKind kind, {DateTime? date}) {
    final d = date ?? _selectedDate;
    switch (kind) {
      case _TrucBanTabKind.trucBan:
        _cubit.layDanhSachTrucBan(d);
      case _TrucBanTabKind.dangKy:
        _cubit.layLichSuRaNgoaiCaNhan(d);
        _cubit.layLichSuKhachCaNhan(d);
      case _TrucBanTabKind.khachDonVi:
        _cubit.layDsKhachToanDonVi(d);
      case _TrucBanTabKind.duyet:
        _cubit.layDsYeuCauRaNgoai(
          ngay: d,
          trangThai: TrangThaiRaNgoai.choDuyet,
        );
    }
  }

  List<Tab> _buildTabs() {
    return _visibleTabKinds().map((kind) {
      return switch (kind) {
        _TrucBanTabKind.trucBan => const Tab(text: 'Trực ban'),
        _TrucBanTabKind.dangKy => const Tab(text: 'Đăng ký'),
        _TrucBanTabKind.khachDonVi => const Tab(text: 'Khách'),
        _TrucBanTabKind.duyet => const Tab(text: 'Duyệt'),
      };
    }).toList();
  }

  List<Widget> _buildTabViews() {
    return _visibleTabKinds().map((kind) {
      return switch (kind) {
        _TrucBanTabKind.trucBan => DanhSachTrucBanTab(
          selectedDate: _selectedDate,
        ),
        _TrucBanTabKind.dangKy => DangKyTab(selectedDate: _selectedDate),
        _TrucBanTabKind.khachDonVi => const KhachDonViTab(),
        _TrucBanTabKind.duyet => const DuyetRaNgoaiTab(),
      };
    }).toList();
  }

  @override
  void didUpdateWidget(covariant TrucBanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _cubit.layPhanQuyen(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final tabCount = _visibleTabKinds().length;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Trực ban',
              showAvatar: true,
              onNotificationTap: () {
                final user = context.read<UserCubit>().currentUser;
                if (user != null) {
                  AppRouter.goToNotification(context, user);
                }
              },
            ),
            body: BlocListener<TrucBanCubit, TrucBanState>(
              listener: _handleStateChange,
              child: LoadingOverlay(
                isLoading: _isProcessing,
                child: Column(
                  children: [
                    if (tabCount > 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: SamcomTabBar(
                          controller: _tabController,
                          physics: tabCount > 2
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          tabs: _buildTabs(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: CenteredDaySlotNavigator(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateChanged,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _buildTabViews(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleStateChange(BuildContext context, TrucBanState state) {
    if (state is TrucBanStateSuccess) {
      CustomSnackbar.show(
        context: context,
        message: state.message,
        type: CustomSnackbarType.success,
      );
      setState(() => _isProcessing = false);
    } else if (state is TrucBanStateError) {
      CustomSnackbar.show(
        context: context,
        message: state.message,
        type: CustomSnackbarType.error,
      );
      setState(() => _isProcessing = false);
    } else if (state is TrucBanStateLoading) {
      setState(() => _isProcessing = true);
    } else if (state is TrucBanStatePhanQuyenLoaded) {
      _phanQuyen = state.phanQuyen;
      _syncTabController(state.phanQuyen);
      setState(() => _isProcessing = false);
    } else {
      setState(() => _isProcessing = false);
    }
  }
}

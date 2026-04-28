import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';

import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/screens/trucBan/tabs/danh_sach_truc_ban_tab.dart';
import 'package:attendancebyface/screens/trucBan/tabs/dang_ky_tab.dart';

import 'package:attendancebyface/screens/trucBan/widgets/truc_ban_empty_state.dart';
import 'package:attendancebyface/screens/trucBan/widgets/truc_ban_dialogs.dart';
import 'package:attendancebyface/screens/trucBan/widgets/truc_ban_info_card.dart';
import 'package:attendancebyface/screens/trucBan/camera_rtsp_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Màn hình chính của chức năng Trực ban
/// Sử dụng CustomAppBar và design system của app
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

  // Lock State
  TrangThaiKhoa? _currentLockState;

  @override
  void initState() {
    super.initState();
    _cubit = TrucBanCubit();
    // TabController length = 2: Lịch trực, Đăng ký
    _tabController = TabController(length: 2, vsync: this);

    // Khởi tạo tab đầu tiên
    _cubit.layDanhSachTrucBan(_selectedDate);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Handle tab change if needed
        switch (_tabController.index) {
          case 0:
            _cubit.layDanhSachTrucBan(_selectedDate);
            break;
          // ... other cases
        }
      }
    });

    // Tải phân quyền (bắt buộc làm mới khi vào lại màn hình)
    _cubit.layPhanQuyen(forceRefresh: true);
  }

  @override
  void didUpdateWidget(covariant TrucBanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Khi tab TrucBan được focus trở lại
      _cubit.layPhanQuyen(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Trực ban',
              showTabs: true,
              tabs: const [
                Tab(text: 'Trực ban'),
                Tab(text: 'Đăng ký'),
              ],
              tabController: _tabController,
              automaticallyImplyLeading: false,
            ),
            body: BlocListener<TrucBanCubit, TrucBanState>(
              listener: _handleStateChange,
              child: LoadingOverlay(
                isLoading: _isProcessing,
                child: Column(
                  children: [
                    // Menu cho Trực ban/Lãnh đạo
                    _buildRoleBasedActions(),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          DanhSachTrucBanTab(
                            selectedDate: _selectedDate,
                            onDateChanged: (date) {
                              setState(() => _selectedDate = date);
                              _cubit.layDanhSachTrucBan(date);
                            },
                          ),
                          const DangKyTab(),
                          // Hiding TestTab but keeping controller length for now to avoid errors,
                          // or I should update TabController length.
                          // User wants to Hide it.
                          // Setting TabBar tabs to 2 and controller to 2 is cleaner.
                          // But I'll just keep it here for now and fix controller init.
                        ],
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

  /// Xử lý state changes
  void _handleStateChange(BuildContext context, TrucBanState state) {
    if (state is TrucBanStateSuccess) {
      CustomSnackbar.show(
        context: context,
        message: state.message,
        type: CustomSnackbarType.success,
      );
      setState(() => _isProcessing = false);

      // Reload lock state if success (likely a toggle action)
      if (state.message.contains('khóa hệ thống')) {
        _cubit.layTrangThaiKhoa();
      }
    } else if (state is TrucBanStateError) {
      CustomSnackbar.show(
        context: context,
        message: state.message,
        type: CustomSnackbarType.error,
      );
      setState(() => _isProcessing = false);
    } else if (state is TrucBanStateLoading) {
      // Don't show full screen overlay for lock check
      if (state.target != TrucBanLoadTarget.general) {
        setState(() => _isProcessing = true);
      }
    } else if (state is TrucBanStatePhanQuyenLoaded) {
      setState(() => _isProcessing = false);
      // Fetch lock state if allowed
      if (state.phanQuyen.canLockSystem) {
        _cubit.layTrangThaiKhoa();
      }
    } else if (state is TrucBanStateTrangThaiKhoaLoaded) {
      setState(() {
        _isProcessing = false;
        _currentLockState = state.trangThai;
      });
    } else {
      setState(() => _isProcessing = false);
    }
  }

  /// Actions dựa trên role
  Widget _buildRoleBasedActions() {
    return BlocBuilder<TrucBanCubit, TrucBanState>(
      buildWhen: (prev, curr) => curr is TrucBanStatePhanQuyenLoaded,
      builder: (context, state) {
        if (state is TrucBanStatePhanQuyenLoaded) {
          final phanQuyen = state.phanQuyen;
          final hasActions =
              phanQuyen.canViewDonVi ||
              phanQuyen.canApproveRaNgoai ||
              phanQuyen.canLockSystem ||
              phanQuyen.canViewCamera;

          if (!hasActions) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (phanQuyen.canViewCamera) ...[
                    _buildActionChip(
                      icon: Icons.videocam_outlined,
                      label: 'Camera',
                      onTap: _showCameraDialog,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (phanQuyen.canViewDonVi)
                    _buildActionChip(
                      icon: Icons.people_outline,
                      label: 'Khách đơn vị',
                      onTap: _showDsKhachDonViDialog,
                    ),
                  if (phanQuyen.canApproveRaNgoai) ...[
                    const SizedBox(width: 8),
                    _buildActionChip(
                      icon: Icons.approval,
                      label: 'Duyệt ra ngoài',
                      onTap: _showDuyetRaNgoaiBottomSheet,
                    ),
                  ],
                  if (phanQuyen.canLockSystem) ...[
                    const SizedBox(width: 8),
                    // Dynamic Lock Chip
                    _buildLockStatusChip(),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLockStatusChip() {
    final isLocked = _currentLockState == TrangThaiKhoa.khoa;
    // Default blue if state unknown, else Green (Open) or Red (Locked)
    final color = _currentLockState == null
        ? ColorConstants.primaryColor
        : (isLocked ? ColorConstants.errorColor : ColorConstants.successColor);

    final icon = isLocked ? Icons.lock : Icons.lock_open;
    final label = isLocked ? 'Đã khóa' : 'Đang mở';

    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: _toggleLockSystem,
      backgroundColor: color.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        side: BorderSide(color: color.withAlpha(50)),
      ),
    );
  }

  void _toggleLockSystem() {
    if (_currentLockState == null) return;

    if (_currentLockState == TrangThaiKhoa.khoa) {
      _cubit.moKhoaHeThong();
    } else {
      _cubit.khoaHeThong();
    }
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: ColorConstants.primaryColor),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onTap,
      backgroundColor: ColorConstants.primaryColor.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      ),
    );
  }

  // ======== DIALOGS ========

  void _showCameraDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CameraRTSPScreen()));
  }

  void _showDsKhachDonViDialog() {
    _cubit.layDsKhachToanDonVi(DateTime.now());
    TrucBanDialogs.showBottomSheet(
      context: context,
      title: 'Khách toàn đơn vị',
      subtitle: 'Danh sách khách đăng ký hôm nay',
      icon: Icons.people_outline,
      child: BlocBuilder<TrucBanCubit, TrucBanState>(
        bloc: _cubit,
        builder: (context, state) {
          // ... Logic build list view giữ nguyên
          if (state is TrucBanStateDanhSachKhachLoaded) {
            if (state.danhSach.isEmpty) {
              return const TrucBanEmptyState(
                icon: Icons.people_outline,
                message: 'Không có khách đăng ký',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.danhSach.length,
              itemBuilder: (context, index) {
                final khach = state.danhSach[index];
                return _buildKhachCard(khach);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showDuyetRaNgoaiBottomSheet() {
    _cubit.layDsYeuCauRaNgoai(
      ngay: DateTime.now(),
      trangThai: TrangThaiRaNgoai.choDuyet,
    );
    TrucBanDialogs.showBottomSheet(
      context: context,
      title: 'Duyệt ra ngoài',
      subtitle: 'Danh sách yêu cầu chờ duyệt',
      icon: Icons.approval,
      child: BlocBuilder<TrucBanCubit, TrucBanState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is TrucBanStateDanhSachRaNgoaiLoaded) {
            if (state.danhSach.isEmpty) {
              return const TrucBanEmptyState(
                icon: Icons.check_circle_outline,
                message: 'Không có yêu cầu cần duyệt',
              );
            }
            return ListView.builder(
              itemCount: state.danhSach.length,
              itemBuilder: (context, index) {
                final yeuCau = state.danhSach[index];
                return _buildDuyetCard(yeuCau);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDuyetCard(YeuCauRaNgoai yeuCau) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(yeuCau.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                if (yeuCau.id != null) {
                  await _cubit.tuChoiYeuCau(yeuCau.id!, yeuCau: yeuCau);
                  _cubit.layDsYeuCauRaNgoai(
                    ngay: DateTime.now(),
                    trangThai: TrangThaiRaNgoai.choDuyet,
                  );
                }
              },
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              icon: Icons.close,
              label: 'Từ chối',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(36),
              ),
            ),
            SlidableAction(
              onPressed: (_) async {
                if (yeuCau.id != null) {
                  await _cubit.duyetYeuCau(yeuCau.id!, yeuCau: yeuCau);
                  _cubit.layDsYeuCauRaNgoai(
                    ngay: DateTime.now(),
                    trangThai: TrangThaiRaNgoai.choDuyet,
                  );
                }
              },
              backgroundColor: ColorConstants.successColor.withAlpha(25),
              foregroundColor: ColorConstants.successColor,
              icon: Icons.check,
              label: 'Duyệt',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(36),
              ),
            ),
          ],
        ),
        child: TrucBanInfoCard(
          title: yeuCau.nhanVien?.hoTen ?? 'N/A',
          badge: const Icon(Icons.person, color: Colors.blue),
          highlightText: yeuCau.nhanVien?.donVi,
          detailText: yeuCau.lyDo,
          detailMaxLines: 2,
          margin: EdgeInsets.zero, // Remove built-in margin
          subInfoWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(yeuCau.thoiGianRa)} - ${DateFormat('HH:mm').format(yeuCau.thoiGianVao)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildKhachCard(Khach khach) {
    // Determine icon based on vehicle type if possible, or default to person
    IconData badgeIcon = Icons.person;
    if (khach.loaiPhuongTien == LoaiPhuongTien.oto) {
      badgeIcon = Icons.directions_car;
    }

    return TrucBanInfoCard(
      title: khach.hoTenKhach,
      badge: Icon(badgeIcon, size: 20, color: ColorConstants.primaryColor),
      highlightText: khach.bienSoXe,
      detailText: khach.nguoiDangKy != null
          ? '• Bởi: ${khach.nguoiDangKy!.hoTen}'
          : null,
      subInfoWidget: khach.soCanCuoc.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                khach.soCanCuoc,
                style: TextStyle(
                  fontSize: TextConstants.caption,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

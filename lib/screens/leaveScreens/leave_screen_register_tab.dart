import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/leave_repository.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/screens/leaveScreens/leave_create_screen.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/widgets/nav_bar_layout.dart';
import 'package:attendancebyface/screens/leaveScreens/widgets/leave_request_tile.dart';
import 'package:attendancebyface/screens/leaveScreens/widgets/leave_request_detail_sheet.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';

class LeaveScreenRegisterTab extends StatelessWidget {
  const LeaveScreenRegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (user) => _LeaveScreenRegisterTabContent(user: user),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi khi tải dữ liệu'),
                const SizedBox(height: 8),
                Text(message),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Thử lại',
                  width: 140,
                  onPressed: () => context.read<UserCubit>().refresh(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaveScreenRegisterTabContent extends StatefulWidget {
  final UserModel user;

  const _LeaveScreenRegisterTabContent({required this.user});

  @override
  State<_LeaveScreenRegisterTabContent> createState() =>
      _LeaveScreenRegisterTabState();
}

class _LeaveScreenRegisterTabState
    extends State<_LeaveScreenRegisterTabContent> {
  final _repo = LeaveRepository();
  bool _isLoading = true;
  List<LeaveRequest> _requests = [];
  ApproverGroups? _approverGroups;

  /// Mặc định: cả tháng hiện tại.
  late DateTimeRange _filterRange;

  static DateTimeRange _monthRange([DateTime? ref]) {
    final n = ref ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    final end = DateTime(n.year, n.month + 1, 0);
    return DateTimeRange(start: start, end: end);
  }

  @override
  void initState() {
    super.initState();
    _filterRange = _monthRange();
    _loadApprovers(); // Load approvers một lần
    _loadData(); // Load data theo khoảng ngày
  }

  /// Load danh sách người duyệt một lần duy nhất
  Future<void> _loadApprovers() async {
    try {
      _approverGroups = await _repo.getApproverGroups();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Load danh sách đơn xin nghỉ theo khoảng ngày đã chọn
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getLeaveRequestsInRange(
        _filterRange,
        widget.user.id,
      );

      // Gán trực tiếp từ API, không cần filter thêm
      _requests = list;

      // debugPrint(
      //   '[LeaveRegisterTab] Loaded ${_requests.length} requests from API',
      // );
      // debugPrint(
      //   '[LeaveRegisterTab] Selected time: $_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}',
      // );

      // Debug: In ra chi tiết từng request
      // for (int i = 0; i < _requests.length; i++) {
      //   final req = _requests[i];
      //   debugPrint(
      //     '[LeaveRegisterTab] Request $i: ${req.id} - ${req.startDate} - ${req.userName} - ${req.status}',
      //   );
      // }

      if (mounted) setState(() {});
    } catch (e) {
      // debugPrint('[LeaveRegisterTab] Lỗi khi tải dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToLeaveCreate() async {
    if (_approverGroups == null) {
      setState(() => _isLoading = true);
      await _loadApprovers();
      if (mounted) setState(() => _isLoading = false);

      if (_approverGroups == null) {
        return;
      }
    }

    if (!mounted) return;
    final req = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaveCreateScreen(approverGroups: _approverGroups!),
      ),
    );
    if (req is LeaveRequest && mounted) {
      await _loadData();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DatePickerField(
            mode: DatePickerFieldMode.range,
            selectedRange: _filterRange,
            label: 'Lọc theo khoảng ngày',
            dialogTitle: 'Chọn khoảng ngày',
            dialogSubtitle:
                'Hiển thị đơn có ngày bắt đầu nằm trong khoảng (theo ngày)',
            minDate: DateTime(DateTime.now().year - 3),
            maxDate: DateTime(DateTime.now().year + 2, 12, 31),
            onRangeChanged: (range) async {
              setState(() => _filterRange = range);
              await _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          fabStackBottomFromScreenBottom(context) + kFabFilledPillHeight,
        ),
        itemCount: _requests.length + 1,
        itemBuilder: (context, index) {
          // Header "Danh sách"
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Danh sách',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }

          final item = _requests[index - 1];
          return LeaveRequestTile(
            item: item,
            applicantName: item.userName.isNotEmpty
                ? item.userName
                : widget.user.name,
            applicantDepartment: item.userDepartment.isNotEmpty
                ? item.userDepartment
                : widget.user.department,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => LeaveRequestDetailSheet(
                  request: item,
                  onApprove: (req) {},
                  onReject: (req, reason) {},
                  onCancel: (updated) async {
                    // Reload data từ API để đảm bảo dữ liệu mới nhất
                    await _loadData();
                  },
                  showActions: false,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug build state
    // debugPrint(
    //   '[LeaveRegisterTab] Build: isLoading=$_isLoading, requests=${_requests.length}',
    // );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_requests.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  fabStackBottomFromScreenBottom(context) +
                                  kFabFilledPillHeight,
                            ),
                            child: const BaseEmptyState(),
                          )
                        : _buildList()),
            ),
          ],
        ),
        Positioned(
          right: kNavBarHorizontalPadding,
          bottom: fabStackBottomFromScreenBottom(context),
          child: CustomButton(
            text: 'Đăng ký nghỉ phép',
            tooltip: 'Đăng ký nghỉ phép',
            variant: CustomButtonVariant.filled,
            icon: Icons.add,
            shrinkWrapWidth: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: _isLoading ? null : _navigateToLeaveCreate,
          ),
        ),
      ],
    );
  }
}

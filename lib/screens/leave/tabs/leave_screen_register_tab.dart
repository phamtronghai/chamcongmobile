import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/leave_repository.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';
import 'package:attendancebyface/screens/leave/widgets/leave_request_tile.dart';
import 'package:attendancebyface/screens/leave/widgets/leave_request_detail_sheet.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';

class LeaveScreenRegisterTab extends StatelessWidget {
  const LeaveScreenRegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          ),
          loading: () => const LoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          ),
          loaded: (user) => _LeaveScreenRegisterTabContent(user: user),
          error: (message) => AppErrorWidget(
            message: message,
            onRetry: () => context.read<UserCubit>().refresh(),
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
  final _repo = locator<LeaveRepository>();
  bool _isLoading = true;
  List<LeaveRequest> _requests = [];
  ApproverGroups? _approverGroups;

  /// true = chế độ 1 ngày, false = khoảng ngày.
  bool _isSingleDay = false;

  /// Ngày đơn (dùng khi _isSingleDay = true).
  late DateTime _singleFilterDate;

  /// Khoảng ngày (dùng khi _isSingleDay = false).
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
    _singleFilterDate = DateTime.now();
    _loadApprovers();
    _loadData();
  }

  /// Range hiệu dụng để gọi API: single → range 1 ngày.
  DateTimeRange get _effectiveRange => _isSingleDay
      ? DateTimeRange(start: _singleFilterDate, end: _singleFilterDate)
      : _filterRange;

  /// Load danh sách người duyệt một lần duy nhất
  Future<void> _loadApprovers() async {
    try {
      _approverGroups = await _repo.getApproverGroups();
    } catch (e) {
      debugLog(e.toString());
    }
  }

  /// Load danh sách đơn xin nghỉ theo khoảng ngày đã chọn
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getLeaveRequestsInRange(
        _effectiveRange,
        widget.user.id,
      );

      // Gán trực tiếp từ API, không cần filter thêm
      _requests = list;

      // debugLog(
      //   '[LeaveRegisterTab] Loaded ${_requests.length} requests from API',
      // );
      // debugLog(
      //   '[LeaveRegisterTab] Selected time: $_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}',
      // );

      // Debug: In ra chi tiết từng request
      // for (int i = 0; i < _requests.length; i++) {
      //   final req = _requests[i];
      //   debugLog(
      //     '[LeaveRegisterTab] Request $i: ${req.id} - ${req.startDate} - ${req.userName} - ${req.status}',
      //   );
      // }

      if (mounted) setState(() {});
    } catch (e) {
      // debugLog('[LeaveRegisterTab] Lỗi khi tải dữ liệu: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi tải dữ liệu: ${e.toString()}',
          type: CustomSnackbarType.error,
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
    final req = await AppRouter.goToLeaveCreate(context, _approverGroups!);
    if (req is LeaveRequest && mounted) {
      await _loadData();
    }
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle 1 ngày / khoảng ngày
          Center(
            child: CustomSegmentedButton<bool>(
              options: const [
                CustomSegmentOption(value: true, label: '1 ngày'),
                CustomSegmentOption(value: false, label: 'Khoảng ngày'),
              ],
              selected: {_isSingleDay},
              onSelectionChanged: (selected) async {
                if (selected.isEmpty) return;
                final nextMode = selected.first;
                if (nextMode == _isSingleDay) return;
                setState(() => _isSingleDay = nextMode);
                await _loadData();
              },
            ),
          ),
          const SizedBox(height: 10),
          // Picker tương ứng
          if (_isSingleDay)
            CenteredDaySlotNavigator(
              selectedDate: _singleFilterDate,
              onDateSelected: (date) async {
                setState(() => _singleFilterDate = date);
                await _loadData();
              },
            )
          else
            _buildRangePicker(theme),
        ],
      ),
    );
  }

  Widget _buildRangePicker(ThemeData theme) {
    return DatePickerField(
      mode: DatePickerFieldMode.range,
      selectedRange: _filterRange,
      compact: true,
      dialogTitle: 'Chọn khoảng ngày',
      onRangeChanged: (range) async {
        setState(() => _filterRange = range);
        await _loadData();
      },
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
          MediaQuery.paddingOf(context).bottom + kFabFilledPillHeight,
        ),
        itemCount: _requests.length + 1,
        itemBuilder: (context, index) {
          // Header "Danh sách"
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Danh sách',
                style: TextConstants.appTextBold.copyWith(
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
              SamcomSheet.show(
                context: context,
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
    // debugLog(
    //   '[LeaveRegisterTab] Build: isLoading=$_isLoading, requests=${_requests.length}',
    // );

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _requests.isEmpty && !_isLoading
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom +
                              kFabFilledPillHeight,
                        ),
                        child: const BaseEmptyState(),
                      )
                    : _buildList(),
              ),
            ],
          ),
          Positioned(
            right: kNavBarHorizontalPadding,
            bottom: MediaQuery.paddingOf(context).bottom,
            child: IntrinsicWidth(
              child: CustomButton(
                text: 'Đăng ký nghỉ phép',
                tooltip: 'Đăng ký nghỉ phép',
                variant: CustomButtonVariant.ctaButton,
                icon: Icons.add,
                onPressed: _isLoading ? null : _navigateToLeaveCreate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

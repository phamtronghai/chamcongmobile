import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/leave_repository.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/screens/leave/widgets/leave_request_detail_sheet.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/screens/leave/widgets/leave_request_tile.dart';

class LeaveScreenBodListTab extends StatelessWidget {
  const LeaveScreenBodListTab({super.key});

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
          loaded: (user) => _LeaveScreenBodListTabContent(user: user),
          error: (message) => AppErrorWidget(
            message: message,
            onRetry: () => context.read<UserCubit>().refresh(),
          ),
        );
      },
    );
  }
}

class _LeaveScreenBodListTabContent extends StatefulWidget {
  final UserModel user;

  const _LeaveScreenBodListTabContent({required this.user});

  @override
  State<_LeaveScreenBodListTabContent> createState() =>
      _LeaveScreenBodListTabState();
}

class _LeaveScreenBodListTabState extends State<_LeaveScreenBodListTabContent> {
  final _repo = locator<LeaveRepository>();
  bool _isLoading = true;
  List<LeaveRequest> _requests = [];
  LeaveStatus? _selectedStatus;
  late DateTimeRange _filterRange;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _filterRange = DateTimeRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _requests = await _repo.getBoardLeaveHistory(
        startDate: _filterRange.start,
        endDate: _filterRange.end,
        status: _selectedStatus,
      );
    } catch (e) {
      debugLog('[LeaveBodListTab] Lỗi tải API: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Không thể tải danh sách nghỉ phép',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDetail(LeaveRequest item) {
    SamcomSheet.show(
      context: context,
      builder: (_) => LeaveRequestDetailSheet(
        request: item,
        onApprove: (_) {},
        onReject: (req, reason) {},
        showActions: false,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
          const SizedBox(height: 12),
          CustomDropdown<LeaveStatus?>(
            labelText: 'Trạng thái',
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả')),
              DropdownMenuItem(
                value: LeaveStatus.pending,
                child: Text('Đang chờ'),
              ),
              DropdownMenuItem(
                value: LeaveStatus.departmentApproved,
                child: Text('Đã duyệt phòng ban'),
              ),
              DropdownMenuItem(
                value: LeaveStatus.approved,
                child: Text('Đã duyệt'),
              ),
              DropdownMenuItem(
                value: LeaveStatus.rejected,
                child: Text('Không duyệt'),
              ),
              DropdownMenuItem(
                value: LeaveStatus.cancelled,
                child: Text('Đã hủy'),
              ),
            ],
            onChanged: (value) async {
              setState(() => _selectedStatus = value);
              await _loadData();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _requests.isEmpty && !_isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom),
                      children: [const BaseEmptyState()],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final item = _requests[index];
                        return LeaveRequestTile(
                          item: item,
                          applicantName: item.userName,
                          applicantDepartment: item.userDepartment,
                          onTap: () => _showDetail(item),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

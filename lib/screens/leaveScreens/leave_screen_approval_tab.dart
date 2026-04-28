import 'package:attendancebyface/models/leave_request.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/widgets/leave_request_tile.dart';
import 'package:attendancebyface/widgets/leave_request_detail_sheet.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';

class LeaveScreenApprovalTab extends StatelessWidget {
  const LeaveScreenApprovalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (user) => _LeaveScreenApprovalTabContent(user: user),
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
                ElevatedButton(
                  onPressed: () => context.read<UserCubit>().refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaveScreenApprovalTabContent extends StatefulWidget {
  final UserModel user;

  const _LeaveScreenApprovalTabContent({required this.user});

  @override
  State<_LeaveScreenApprovalTabContent> createState() =>
      _LeaveScreenApprovalTabState();
}

class _LeaveScreenApprovalTabState
    extends State<_LeaveScreenApprovalTabContent> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  LeaveStatus _selectedStatus = LeaveStatus.pending;

  List<LeaveRequest> _pendingRequests = [];
  List<LeaveRequest> _approvedRequests = [];
  List<LeaveRequest> _rejectedRequests = [];

  // Badge counters
  int _pendingCount = 0; // Số đơn pending (cho TP)
  int _departmentApprovedCount = 0; // Số đơn department_approved (cho BGĐ)

  @override
  void initState() {
    super.initState();
    // Set status mặc định dựa trên vai trò
    if (widget.user.canApprove == 'bgd') {
      _selectedStatus =
          LeaveStatus.departmentApproved; // BGĐ mặc định xem đã duyệt phòng ban
    } else {
      _selectedStatus = LeaveStatus.pending; // TP mặc định xem đang chờ
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Xác định API endpoint dựa trên vai trò user
      String endpoint;
      if (widget.user.canApprove == 'tp') {
        endpoint = '/leave/managerGetLeave';
      } else if (widget.user.canApprove == 'bgd') {
        endpoint = '/leave/boardGetLeave';
      } else {
        // Không có quyền duyệt → danh sách rỗng
        _pendingRequests = [];
        _approvedRequests = [];
        _rejectedRequests = [];
        _pendingCount = 0;
        _departmentApprovedCount = 0;
        return;
      }

      // Load data cho status hiện tại
      await _loadStatusData(endpoint, _selectedStatus);

      // Load badge counts
      await _loadBadgeCounts(endpoint);

      debugPrint(
        '[LeaveApprovalTab] API loaded counts -> pending: ${_pendingRequests.length}, approved: ${_approvedRequests.length}, rejected: ${_rejectedRequests.length}',
      );
      debugPrint(
        '[LeaveApprovalTab] Badge counts -> pending: $_pendingCount, departmentApproved: $_departmentApprovedCount',
      );
    } catch (e) {
      debugPrint('[LeaveApprovalTab] Lỗi tải API: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Không thể tải dữ liệu phê duyệt',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Load data cho một status cụ thể
  Future<void> _loadStatusData(String endpoint, LeaveStatus status) async {
    final response = await _apiClient.get(
      endpoint,
      queryParameters: {'status': _statusToString(status)},
    );

    if (response.data is List) {
      final List<dynamic> data = response.data as List<dynamic>;
      final List<LeaveRequest> allRequests = data
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();

      // API đã trả về theo status, chỉ cần gán trực tiếp
      switch (status) {
        case LeaveStatus.pending:
          _pendingRequests = allRequests;
          break;
        case LeaveStatus.departmentApproved:
          _pendingRequests = allRequests; // Hiển thị trong pending list
          break;
        case LeaveStatus.approved:
          _approvedRequests = allRequests;
          break;
        case LeaveStatus.rejected:
          _rejectedRequests = allRequests;
          break;
        case LeaveStatus.cancelled:
          // Status cancelled không hiển thị cho BGĐ
          _rejectedRequests = [];
          break;
      }
    }
  }

  /// Load badge counts cho tất cả status cần thiết
  Future<void> _loadBadgeCounts(String endpoint) async {
    if (widget.user.canApprove == 'tp') {
      // TP cần đếm pending
      final pendingResponse = await _apiClient.get(
        endpoint,
        queryParameters: {'status': 'pending'},
      );
      if (pendingResponse.data is List) {
        _pendingCount = (pendingResponse.data as List).length;
      }
    } else if (widget.user.canApprove == 'bgd') {
      // BGĐ cần đếm department_approved
      final deptApprovedResponse = await _apiClient.get(
        endpoint,
        queryParameters: {'status': 'department_approved'},
      );
      if (deptApprovedResponse.data is List) {
        _departmentApprovedCount = (deptApprovedResponse.data as List).length;
      }
    }
  }

  /// Refresh badge counts sau khi thực hiện action
  Future<void> _refreshBadgeCounts() async {
    try {
      String endpoint;
      if (widget.user.canApprove == 'tp') {
        endpoint = '/leave/managerGetLeave';
      } else if (widget.user.canApprove == 'bgd') {
        endpoint = '/leave/boardGetLeave';
      } else {
        return;
      }

      await _loadBadgeCounts(endpoint);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[LeaveApprovalTab] Lỗi làm mới số lượng badge: $e');
    }
  }

  Future<void> _approveRequest(LeaveRequest request) async {
    try {
      // Xác định API endpoint dựa trên vai trò user
      String endpoint;
      String workflow;

      if (widget.user.canApprove == 'tp') {
        endpoint = '/leave/manager_approve';
        workflow = request.workflow == ApprovalWorkflow.bothLevels
            ? 'both_levels'
            : 'department_only';
      } else if (widget.user.canApprove == 'bgd') {
        endpoint = '/leave/board_approve';
        workflow = request.workflow == ApprovalWorkflow.boardOnly
            ? 'board_only'
            : 'both_levels';
      } else {
        throw Exception('Không có quyền phê duyệt');
      }

      // Xác định status gửi lên backend theo workflow và vai trò
      String statusToSend;
      if (widget.user.canApprove == 'tp') {
        statusToSend = request.workflow == ApprovalWorkflow.bothLevels
            ? 'department_approved'
            : 'approved';
      } else {
        // BGĐ phê duyệt luôn hoàn tất
        statusToSend = 'approved';
      }

      // Gọi API phê duyệt với status phù hợp
      await _apiClient.post(
        endpoint,
        data: {
          'id': request.id,
          'status': statusToSend,
          'workflow': workflow,
          'rejectionReason': '', // Thêm trường rejectionReason cho API
        },
      );

      // Cập nhật UI
      if (widget.user.canApprove == 'tp' &&
          request.workflow == ApprovalWorkflow.bothLevels) {
        // TP duyệt bước 1 → chuyển sang chờ BGĐ
        final deptApproved = request.copyWith(
          status: LeaveStatus.departmentApproved,
          departmentApprovedAt: DateTime.now(),
          departmentApprovedId: widget.user.id,
        );
        setState(() {
          _pendingRequests.remove(request);
          _pendingRequests.add(deptApproved);
        });
        // Gửi thông báo cho user: đã được phòng ban duyệt, chờ BGĐ
        await _sendNotification(
          userId: request.userId ?? '',
          title: 'Đơn nghỉ phép',
          message: 'Đơn của bạn đã được phòng ban duyệt, chờ BGĐ.',
        );
        // Gửi thông báo cho BGĐ: có đơn đã duyệt cấp phòng
        final boardApproverId = request.boardApprovedId;
        if (boardApproverId != null && boardApproverId.isNotEmpty) {
          await _sendNotification(
            userId: boardApproverId,
            title: 'Xin nghỉ phép',
            message:
                'Đồng chí ${request.userName.isNotEmpty ? request.userName : 'nhân viên'} xin nghỉ phép. Đã duyệt cấp phòng.',
          );
        }
      } else {
        // Hoàn tất duyệt
        final approved = request.copyWith(
          status: LeaveStatus.approved,
          approvedAt: DateTime.now(),
          boardApprovedAt: widget.user.canApprove == 'bgd'
              ? DateTime.now()
              : request.boardApprovedAt,
        );
        setState(() {
          _pendingRequests.remove(request);
          _approvedRequests.add(approved);
        });
        // Gửi thông báo cho user: đã được duyệt
        await _sendNotification(
          userId: request.userId ?? '',
          title: 'Đơn nghỉ phép',
          message: 'Đơn nghỉ phép của bạn đã được duyệt.',
        );
      }

      // Refresh badge counts sau khi approve
      await _refreshBadgeCounts();

      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Đã phê duyệt đơn nghỉ phép',
          type: CustomSnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint('[LeaveApprovalTab] Lỗi phê duyệt: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi phê duyệt đơn nghỉ phép: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  Future<void> _rejectRequest(LeaveRequest request, String reason) async {
    try {
      // Xác định API endpoint dựa trên vai trò user
      String endpoint;
      String workflow;

      if (widget.user.canApprove == 'tp') {
        endpoint = '/leave/manager_approve';
        workflow = request.workflow == ApprovalWorkflow.bothLevels
            ? 'both_levels'
            : 'department_only';
      } else if (widget.user.canApprove == 'bgd') {
        endpoint = '/leave/board_approve';
        workflow = request.workflow == ApprovalWorkflow.boardOnly
            ? 'board_only'
            : 'both_levels';
      } else {
        throw Exception('Không có quyền từ chối');
      }

      // Gọi API từ chối
      await _apiClient.post(
        endpoint,
        data: {
          'id': request.id,
          'status': 'rejected',
          'workflow': workflow,
          'rejectionReason': reason, // Sử dụng lý do từ chối thực tế
        },
      );

      // Cập nhật UI
      final rejected = request.copyWith(
        status: LeaveStatus.rejected,
        rejectionReason: reason.isEmpty ? null : reason,
      );
      setState(() {
        _pendingRequests.remove(request);
        _rejectedRequests.add(rejected);
      });

      // Gửi thông báo cho user
      await _sendNotification(
        userId: request.userId ?? '',
        title: 'Đơn nghỉ phép',
        message:
            'Đơn nghỉ phép của bạn đã bị từ chối.${reason.isNotEmpty ? ' Lý do: $reason' : ''}',
      );

      // Refresh badge counts sau khi reject
      await _refreshBadgeCounts();

      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Đã từ chối đơn nghỉ phép',
          type: CustomSnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint('[LeaveApprovalTab] Lỗi từ chối: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi từ chối đơn nghỉ phép: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  // Xem xét lại: đã tạm thời gỡ vì chưa có API phía server

  // ===== Helper gửi thông báo qua API =====
  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    if (userId.isEmpty) return;
    try {
      await _apiClient.post(
        '/send-notification',
        data: {'userId': userId, 'title': title, 'message': message},
      );
    } catch (_) {}
  }

  // _notifyFirstApprover: tạm thời không dùng khi đã gỡ tính năng xem xét lại

  void _showDetailBottomSheet(LeaveRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => LeaveRequestDetailSheet(
        request: request,
        onApprove: (req) => _approveRequest(req),
        onReject: (req, reason) => _rejectRequest(req, reason),
      ),
    );
  }

  /// Convert LeaveStatus enum to API string value
  String _statusToString(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'pending';
      case LeaveStatus.departmentApproved:
        return 'department_approved';
      case LeaveStatus.approved:
        return 'approved';
      case LeaveStatus.rejected:
        return 'rejected';
      case LeaveStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Lấy danh sách dropdown items dựa trên vai trò user
  List<DropdownMenuItem<LeaveStatus>> _getStatusDropdownItems() {
    if (widget.user.canApprove == 'bgd') {
      // BGĐ chỉ có: departmentApproved, approved, rejected
      return [
        DropdownMenuItem(
          value: LeaveStatus.departmentApproved,
          child: _buildDropdownItemWithBadge(
            'Đã duyệt phòng ban',
            _departmentApprovedCount,
          ),
        ),
        const DropdownMenuItem(
          value: LeaveStatus.approved,
          child: Text('Đã duyệt'),
        ),
        const DropdownMenuItem(
          value: LeaveStatus.rejected,
          child: Text('Không duyệt'),
        ),
      ];
    } else {
      // TP có đầy đủ: pending, departmentApproved, approved, rejected
      return [
        DropdownMenuItem(
          value: LeaveStatus.pending,
          child: _buildDropdownItemWithBadge('Đang chờ', _pendingCount),
        ),
        const DropdownMenuItem(
          value: LeaveStatus.departmentApproved,
          child: Text('Đã duyệt phòng ban'),
        ),
        const DropdownMenuItem(
          value: LeaveStatus.approved,
          child: Text('Đã duyệt'),
        ),
        const DropdownMenuItem(
          value: LeaveStatus.rejected,
          child: Text('Không duyệt'),
        ),
      ];
    }
  }

  /// Tạo dropdown item với badge
  Widget _buildDropdownItemWithBadge(String text, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ColorConstants.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<LeaveRequest> list;
    IconData emptyIcon;
    String emptyMsg;
    switch (_selectedStatus) {
      case LeaveStatus.pending:
        list = _pendingRequests;
        emptyIcon = Icons.approval_outlined;
        emptyMsg = 'Không có đơn nào chờ duyệt';
        break;
      case LeaveStatus.departmentApproved:
        list = _pendingRequests;
        emptyIcon = Icons.business_center_outlined;
        emptyMsg = 'Không có đơn nào đã duyệt phòng ban';
        break;
      case LeaveStatus.approved:
        list = _approvedRequests;
        emptyIcon = Icons.check_circle_outline;
        emptyMsg = 'Không có đơn nào đã duyệt';
        break;
      case LeaveStatus.rejected:
        list = _rejectedRequests;
        emptyIcon = Icons.cancel_outlined;
        emptyMsg = 'Không có đơn nào bị từ chối';
        break;
      case LeaveStatus.cancelled:
        // Status cancelled không hiển thị cho BGĐ
        list = [];
        emptyIcon = Icons.cancel_outlined;
        emptyMsg = 'Không có đơn nào bị hủy';
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomDropdown<LeaveStatus>(
            labelText: 'Trạng thái',
            value: _selectedStatus,
            items: _getStatusDropdownItems(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedStatus = value);
              _loadData(); // Reload data khi đổi status
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: list.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 16),
                      _buildEmptyState(emptyMsg, emptyIcon),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return LeaveRequestTile(
                        item: item,
                        applicantName: item.userName,
                        applicantDepartment: item.userDepartment,
                        onTap: () => _showDetailBottomSheet(item),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

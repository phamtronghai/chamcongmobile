import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/base_screen.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';

class LeaveCreateScreen extends BaseScreen {
  final ApproverGroups approverGroups;

  const LeaveCreateScreen({super.key, required this.approverGroups});

  @override
  Widget buildContent(UserModel user) {
    return _LeaveCreateScreenContent(
            approverGroups: approverGroups,
            user: user,
    );
  }
}

class _LeaveCreateScreenContent extends StatefulWidget {
  final ApproverGroups approverGroups;
  final UserModel user;

  const _LeaveCreateScreenContent({
    required this.approverGroups,
    required this.user,
  });

  @override
  State<_LeaveCreateScreenContent> createState() => _LeaveCreateScreenState();
}

class _LeaveCreateScreenState extends State<_LeaveCreateScreenContent> {
  final ApiClient _apiClient = ApiClient();
  bool _isSubmitting = false;
  bool _isMultiDay = false;
  DateTime? _singleDate;
  DateTimeRange? _range;
  LeaveType _leaveType = LeaveType.fullDay;
  Approver? _singleApprover;
  Approver? _deptApprover;
  Approver? _bodApprover;
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController();

  // Role detection dựa trên canApprove (nhất quán với các màn hình khác)
  bool get _isManager {
    return widget.user.canApprove == 'tp';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Đăng ký nghỉ phép'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SamcomChip(
                    label: '1 ngày',
                    variant: SamcomChipVariant.filled,
                    selected: !_isMultiDay,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => setState(() => _isMultiDay = false),
                  ),
                  const SizedBox(width: 8),
                  SamcomChip(
                    label: 'Nhiều ngày',
                    variant: SamcomChipVariant.filled,
                    selected: _isMultiDay,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => setState(() {
                      _isMultiDay = true;
                      _leaveType = LeaveType.fullDay; // ép cả ngày cho nhiều ngày
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (!_isMultiDay) ...[
                DatePickerField(
                  mode: DatePickerFieldMode.single,
                  selectedDate: _singleDate,
                  dialogTitle: 'Chọn ngày',
                  dialogSubtitle: 'Ngày bắt đầu xin nghỉ (một ngày)',
                  minDate: DateTime(DateTime.now().year - 1),
                  maxDate: DateTime.now().add(const Duration(days: 366)),
                  onDateChanged: (d) => setState(() => _singleDate = d),
                ),
                const SizedBox(height: 8),
                // Trưởng/Phó: vẫn giữ lựa chọn Sáng/Chiều/Cả ngày theo yêu cầu
                _buildSingleDayType(),
                const SizedBox(height: 8),
                // Approver theo vai trò
                if (_isManager) _buildBodApprover() else _buildSingleApprover(),
              ] else ...[
                DatePickerField(
                  mode: DatePickerFieldMode.range,
                  selectedRange: _range,
                  dialogTitle: 'Chọn khoảng ngày',
                  dialogSubtitle: 'Từ ngày đến ngày xin nghỉ',
                  minDate: DateTime(DateTime.now().year - 1),
                  maxDate: DateTime.now().add(const Duration(days: 366)),
                  onRangeChanged: (r) => setState(() => _range = r),
                ),
                const SizedBox(height: 8),
                // Nhiều ngày: nhân viên cần 2 cấp; Trưởng/Phó chỉ BGĐ
                if (_isManager) ...[
                  _buildBodApprover(),
                ] else ...[
                  _buildDeptApprover(),
                  const SizedBox(height: 8),
                  _buildBodApprover(),
                ],
              ],

              const SizedBox(height: 8),
              CustomTextField(
                label: 'Lý do nghỉ',
                controller: _reasonController,
                maxLength: 200,
                maxLines: 1,
                minLines: 1,
              ),

              const SizedBox(height: 8),
              CustomTextField(
                label: 'Địa điểm nghỉ phép',
                controller: _locationController,
                maxLength: 100,
                maxLines: 1,
                minLines: 1,
                hint: 'Ví dụ: Nhà riêng, Bệnh viện, Quê nhà...',
              ),

              const SizedBox(height: 12),
              // Nút gửi đơn
              CustomButton(
                text: 'Gửi đơn',
                onPressed: _isSubmitting ? null : _submit,
                backgroundColor: _isSubmitting
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleDayType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SamcomChip(
          label: 'Sáng',
          variant: SamcomChipVariant.filled,
          selected: _leaveType == LeaveType.morning,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => setState(() => _leaveType = LeaveType.morning),
        ),
        const SizedBox(width: 8),
        SamcomChip(
          label: 'Chiều',
          variant: SamcomChipVariant.filled,
          selected: _leaveType == LeaveType.afternoon,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => setState(() => _leaveType = LeaveType.afternoon),
        ),
        const SizedBox(width: 8),
        SamcomChip(
          label: 'Cả ngày',
          variant: SamcomChipVariant.filled,
          selected: _leaveType == LeaveType.fullDay,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => setState(() => _leaveType = LeaveType.fullDay),
        ),
      ],
    );
  }

  Widget _buildSingleApprover() {
    final items = widget.approverGroups.departmentManagers;
    return CustomDropdown<Approver>(
      labelText: 'Người duyệt',
      value: _singleApprover,
      items: items
          .map(
            (a) => DropdownMenuItem(
              value: a,
              child: Text('${a.name} (${a.position})'),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _singleApprover = v),
    );
  }

  Widget _buildDeptApprover() {
    final items = widget.approverGroups.departmentManagers;
    return CustomDropdown<Approver>(
      labelText: 'Người duyệt cấp phòng',
      value: _deptApprover,
      items: items
          .map(
            (a) => DropdownMenuItem(
              value: a,
              child: Text('${a.name} (${a.position})'),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _deptApprover = v),
    );
  }

  Widget _buildBodApprover() {
    final items = widget.approverGroups.boardOfDirectors;
    return CustomDropdown<Approver>(
      labelText: 'Người duyệt cấp Ban Giám đốc',
      value: _bodApprover,
      items: items
          .map(
            (a) => DropdownMenuItem(
              value: a,
              child: Text('${a.name} (${a.position})'),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _bodApprover = v),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    // Validate tất cả trường bắt buộc trước khi gửi
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      // Xác định workflow dựa trên canApprove và số ngày
      // Lưu ý: Server sẽ tự set status ban đầu:
      // - TP (canApprove='tp'): departmentApproved (đã duyệt phòng ban, chờ BGĐ)
      // - NV: pending (chờ duyệt phòng ban)
      String workflow;
      if (_isManager) {
        // Trưởng/phó phòng: luôn cần duyệt BGĐ
        workflow = 'board_only';
      } else {
        // Nhân viên thường: dựa trên số ngày
        if (_isMultiDay) {
          workflow = 'both_levels'; // Nhiều ngày cần 2 cấp
        } else {
          workflow = 'department_only'; // 1 ngày chỉ cần phòng ban
        }
      }

      if (!_isMultiDay) {
        // 1 ngày
        if (_singleDate == null) return;

        // Gọi API tạo đơn nghỉ phép 1 ngày
        final payload = {
          'startDate': _singleDate!.toIso8601String().split('T').first,
          'endDate': _singleDate!.toIso8601String().split('T').first,
          'leaveType': _leaveTypeToApi(_leaveType),
          'reason': _reasonController.text.trim(),
          'location': _locationController.text.trim(),
          'manager_id': (_deptApprover ?? _singleApprover)?.id ?? '',
          'board_approved_id': _bodApprover?.id ?? '',
          'workflow': workflow,
        };

        final resp = await _apiClient.post('/leave/request', data: payload);
        if (!mounted) return;

        if (resp.data is Map<String, dynamic>) {
          final req = LeaveRequest.fromJson(resp.data as Map<String, dynamic>);

          // Gửi thông báo cho người duyệt
          await _sendNotificationToApprovers(req);

          if (mounted) {
            CustomSnackbar.show(
              context: context,
              message: 'Đăng ký nghỉ phép thành công!',
              type: CustomSnackbarType.success,
            );
            Navigator.pop(context, req);
          }
        } else {
          if (mounted) Navigator.pop(context);
        }
        return;
      }

      // Nhiều ngày: ép Cả ngày
      if (_range == null) return;

      // Gọi API tạo đơn nghỉ phép nhiều ngày
      final payload = {
        'startDate': _range!.start.toIso8601String().split('T').first,
        'endDate': _range!.end.toIso8601String().split('T').first,
        'leaveType': _leaveTypeToApi(LeaveType.fullDay),
        'reason': _reasonController.text.trim(),
        'location': _locationController.text.trim(),
        'manager_id': _deptApprover?.id ?? '',
        'board_approved_id': _bodApprover?.id ?? '',
        'workflow': workflow,
      };

      final resp = await _apiClient.post('/leave/request', data: payload);
      if (!mounted) return;

      if (resp.data is Map<String, dynamic>) {
        final req = LeaveRequest.fromJson(resp.data as Map<String, dynamic>);

        // Gửi thông báo cho người duyệt
        await _sendNotificationToApprovers(req);

        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'Đăng ký nghỉ phép thành công!',
            type: CustomSnackbarType.success,
          );
          Navigator.pop(context, req);
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi gửi đơn nghỉ phép: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi đăng ký nghỉ phép: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Gửi thông báo cho người duyệt
  Future<void> _sendNotificationToApprovers(LeaveRequest request) async {
    try {
      // Server tự set status ban đầu:
      // - TP (canApprove='tp'): departmentApproved (chờ BGĐ)
      // - NV: pending (chờ phòng ban) hoặc departmentApproved (chờ BGĐ)

      String? targetApproverId;
      String notificationMessage = '';

      if (_isManager) {
        // TP tạo đơn → status = departmentApproved → gửi thông báo cho BGĐ
        targetApproverId = _bodApprover?.id ?? request.boardApprovedId;
        notificationMessage =
            'Đồng chí ${widget.user.name} (Trưởng/Phó phòng) xin nghỉ phép.';
      } else {
        // NV tạo đơn → dựa trên status thực tế từ server
        if (request.status == LeaveStatus.pending) {
          // Status = pending → gửi thông báo cho trưởng phòng
          targetApproverId =
              (_deptApprover ?? _singleApprover)?.id ??
              request.departmentApprovedId;
          notificationMessage = 'Đồng chí ${widget.user.name} xin nghỉ phép.';
        } else if (request.status == LeaveStatus.departmentApproved) {
          // Status = departmentApproved → gửi thông báo cho BGĐ
          targetApproverId = _bodApprover?.id ?? request.boardApprovedId;
          notificationMessage =
              'Đồng chí ${widget.user.name} xin nghỉ phép. Đã duyệt cấp phòng, chờ BGĐ.';
        }
      }

      if (targetApproverId == null || targetApproverId.isEmpty) return;

      await _sendNotification(
        userId: targetApproverId,
        title: 'Xin nghỉ phép',
        message: notificationMessage,
      );
    } catch (e) {
      debugPrint('Lỗi khi gửi thông báo cho người phê duyệt: $e');
      // Không throw error để không ảnh hưởng đến việc tạo đơn
    }
  }

  /// Gửi thông báo qua API
  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      await _apiClient.post(
        '/send-notification',
        data: {'userId': userId, 'title': title, 'message': message},
      );
      debugPrint('✅ Thông báo đã gửi đến người dùng: $userId');
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi thông báo: $e');
      rethrow;
    }
  }

  String _leaveTypeToApi(LeaveType t) {
    switch (t) {
      case LeaveType.morning:
        return 'morning';
      case LeaveType.afternoon:
        return 'afternoon';
      case LeaveType.fullDay:
        return 'full_day';
    }
  }

  /// Validate tất cả trường bắt buộc trước khi gửi đơn
  bool _validateForm() {
    // Validate ngày nghỉ
    if (!_isMultiDay && _singleDate == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn ngày nghỉ',
        type: CustomSnackbarType.warning,
      );
      return false;
    }

    if (_isMultiDay && _range == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn khoảng ngày nghỉ',
        type: CustomSnackbarType.warning,
      );
      return false;
    }

    // Validate lý do nghỉ
    if (_reasonController.text.trim().isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng nhập lý do nghỉ',
        type: CustomSnackbarType.warning,
      );
      return false;
    }

    // Validate địa điểm nghỉ
    if (_locationController.text.trim().isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng nhập địa điểm nghỉ phép',
        type: CustomSnackbarType.warning,
      );
      return false;
    }

    // Validate người duyệt
    if (!_isMultiDay) {
      // 1 ngày
      if (_isManager) {
        if (_bodApprover == null) {
          CustomSnackbar.show(
            context: context,
            message: 'Vui lòng chọn người duyệt Ban giám đốc',
            type: CustomSnackbarType.warning,
          );
          return false;
        }
      } else {
        if (_singleApprover == null) {
          CustomSnackbar.show(
            context: context,
            message: 'Vui lòng chọn người duyệt',
            type: CustomSnackbarType.warning,
          );
          return false;
        }
      }
    } else {
      // Nhiều ngày
      if (_isManager) {
        if (_bodApprover == null) {
          CustomSnackbar.show(
            context: context,
            message: 'Vui lòng chọn người duyệt Ban giám đốc',
            type: CustomSnackbarType.warning,
          );
          return false;
        }
      } else {
        if (_deptApprover == null || _bodApprover == null) {
          CustomSnackbar.show(
            context: context,
            message: 'Vui lòng chọn đầy đủ người duyệt cho nhiều ngày',
            type: CustomSnackbarType.warning,
          );
          return false;
        }
      }
    }

    return true;
  }
}

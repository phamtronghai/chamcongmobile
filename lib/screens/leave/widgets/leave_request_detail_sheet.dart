import 'package:attendancebyface/models/leave_request.dart';
import 'package:flutter/material.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/leave_status_helper.dart';

class LeaveRequestDetailSheet extends StatefulWidget {
  final LeaveRequest request;
  final void Function(LeaveRequest) onApprove;
  final void Function(LeaveRequest, String reason) onReject;
  final void Function(LeaveRequest)? onCancel; // Nút hủy đơn của người tạo
  final bool showActions; // chỉ bật trong tab Phê duyệt

  const LeaveRequestDetailSheet({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
    this.onCancel,
    this.showActions = true,
  });

  @override
  State<LeaveRequestDetailSheet> createState() =>
      _LeaveRequestDetailSheetState();
}

class _LeaveRequestDetailSheetState extends State<LeaveRequestDetailSheet> {
  // --- Các hàm helper không đổi ---
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _leaveTypeLabel() {
    switch (widget.request.leaveType) {
      case LeaveType.morning:
        return 'Nghỉ buổi sáng';
      case LeaveType.afternoon:
        return 'Nghỉ buổi chiều';
      case LeaveType.fullDay:
        return 'Nghỉ cả ngày';
    }
  }

  // Sử dụng helper chung để đồng bộ giao diện
  String _getApplicantInfo() {
    final r = widget.request;
    // Sử dụng getter userName đã được tối ưu
    final name = r.userName;

    if (name.isNotEmpty) {
      // Sử dụng thông tin từ model mới
      final dept = r.userDepartment;
      final pos = ''; // Position không còn có trong model mới

      if (dept.isNotEmpty && pos.isNotEmpty) {
        return '$name • $pos, $dept';
      } else if (dept.isNotEmpty) {
        return '$name • $dept';
      } else if (pos.isNotEmpty) {
        return '$name • $pos';
      }
      return name;
    }
    return 'Không có thông tin';
  }

  String _formatApproverLine(String name, DateTime? at) {
    if (at != null) return '$name • ${_fmt(at)}';
    return name;
  }

  bool _hasApproverName(String? name) => name != null && name.trim().isNotEmpty;

  /// Kiểm tra xem có thể hiển thị nút action không
  bool _canShowActions() {
    final status = widget.request.status;
    return status == LeaveStatus.pending ||
        status == LeaveStatus.departmentApproved;
  }

  /// Trưởng phòng duyệt bước 1: hiển thị BGĐ được chỉ định từ API (chưa duyệt).
  bool _shouldShowPendingBoardApprover(LeaveRequest r) {
    if (!widget.showActions || r.status != LeaveStatus.pending) {
      return false;
    }
    if (r.workflow != ApprovalWorkflow.bothLevels) return false;
    final name = r.boardApprovedName?.trim();
    return name != null && name.isNotEmpty;
  }

  String _formatLeaveDateRange() {
    final r = widget.request;
    if (r.startDate != r.endDate) {
      return DatePickerField.formatRange(r.startDate, r.endDate);
    }
    return _fmt(r.startDate);
  }

  Widget _buildHeaderSubtitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _formatLeaveDateRange(),
            style: TextConstants.appTextRegular.copyWith(
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.75 : 0.68,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        LeaveStatusHelper.buildStatusChip(context, widget.request.status),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return SamcomSheet(
      title: widget.showActions ? _getApplicantInfo() : 'Chi tiết nghỉ phép',
      subtitleWidget: _buildHeaderSubtitle(context),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.timelapse_rounded,
                    title: 'Loại nghỉ',
                    content: _leaveTypeLabel(),
                  ),
                  const SizedBox(height: 20),
                  if (r.reason.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.subject_rounded,
                      title: 'Lý do',
                      content: r.reason,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (r.location != null && r.location!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      title: 'Địa điểm',
                      content: r.location!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_shouldShowPendingBoardApprover(r)) ...[
                    _buildInfoRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Người phê duyệt Ban giám đốc',
                      content: r.boardApprovedName!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_hasApproverName(r.departmentApprovedName)) ...[
                    _buildInfoRow(
                      icon: Icons.business_center_outlined,
                      title: 'Phê duyệt phòng ban',
                      content: _formatApproverLine(
                        r.departmentApprovedName!,
                        r.departmentApprovedAt,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_hasApproverName(r.boardApprovedName) &&
                      !_shouldShowPendingBoardApprover(r)) ...[
                    _buildInfoRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Phê duyệt Ban giám đốc',
                      content: _formatApproverLine(
                        r.boardApprovedName!,
                        r.boardApprovedAt,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (r.rejectionReason != null &&
                      r.rejectionReason!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.gpp_bad_rounded,
                      title: 'Lý do từ chối',
                      content: r.rejectionReason!,
                      accentColor: ColorConstants.errorColor,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (widget.showActions && _canShowActions())
                    _buildActionSection(),
                  if (!widget.showActions && r.status == LeaveStatus.pending)
                    _buildCancelSection(r),
                ],
              ),
            ),

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  // Widget builder cho các hành động Phê duyệt/Từ chối
  Widget _buildActionSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Từ chối',
                icon: Icons.close,
                variant: CustomButtonVariant.normalButton,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onReject(widget.request, ''); // Không cần lý do
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Phê duyệt',
                icon: Icons.check,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApprove(widget.request);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Khu vực hành động dành cho tab Đăng ký: Hủy đơn khi đang chờ
  Widget _buildCancelSection(LeaveRequest r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        CustomButton(
          text: 'Hủy đơn',
          variant: CustomButtonVariant.textButton,
          onPressed: () async {
            try {
              final api = ApiClient();
              final resp = await api.post(
                '/leave/cancel_request',
                data: {'id': r.id},
              );
              if (!mounted) return;

              LeaveRequest updated = r;
              if (resp.data is Map<String, dynamic>) {
                updated = LeaveRequest.fromJson(
                  resp.data as Map<String, dynamic>,
                );
              }

              Navigator.pop(context);
              CustomSnackbar.show(
                context: context,
                message: 'Đã hủy đơn nghỉ phép',
                type: CustomSnackbarType.success,
              );
              widget.onCancel?.call(updated);
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(context);
              CustomSnackbar.show(
                context: context,
                message: 'Lỗi khi hủy đơn: ${e.toString()}',
                type: CustomSnackbarType.error,
              );
            }
          },
        ),
      ],
    );
  }

  /// Widget hiển thị thông tin phụ, thiết kế tinh gọn
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor =
        accentColor ?? colorScheme.onSurface.withValues(alpha: 0.55);
    final titleColor =
        accentColor ?? colorScheme.onSurface.withValues(alpha: 0.55);
    final contentColor = accentColor ?? colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextConstants.appTextRegular.copyWith(
                  color: titleColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextConstants.appTextRegular.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

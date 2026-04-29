import 'package:attendancebyface/models/leave_request.dart';
import 'package:flutter/material.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
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
  Color _getStatusColor() =>
      LeaveStatusHelper.getStatusColor(widget.request.status);
  String _getStatusLabel() =>
      LeaveStatusHelper.getStatusLabel(widget.request.status);
  IconData _getStatusIcon() =>
      LeaveStatusHelper.getStatusIcon(widget.request.status);

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

  /// Kiểm tra xem có thể hiển thị nút action không
  bool _canShowActions() {
    final status = widget.request.status;
    return status == LeaveStatus.pending ||
        status == LeaveStatus.departmentApproved;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isRange = r.startDate != r.endDate;
    final statusColor = _getStatusColor();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: statusColor.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getStatusIcon(), color: statusColor, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _getStatusLabel(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showActions) ...[
                    _buildHighlightedInfo(
                      icon: Icons.person_4_rounded,
                      title: 'Người xin nghỉ',
                      content: _getApplicantInfo(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildHighlightedInfo(
                    icon: Icons.calendar_month_rounded,
                    title: 'Thời gian nghỉ',
                    content: isRange
                        ? '${_fmt(r.startDate)}  →  ${_fmt(r.endDate)}'
                        : _fmt(r.startDate),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.grey[700] : const Color(0xFFEEEEEE),
                  ),
                  const SizedBox(height: 24),

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

                  if (r.departmentApprovedId != null &&
                      r.departmentApprovedAt != null) ...[
                    _buildInfoRow(
                      icon: Icons.business_center_outlined,
                      title: 'Phê duyệt phòng ban',
                      content:
                          '${_getApproverName(r.departmentApprovedId!, 'department_manager')} • ${_fmt(r.departmentApprovedAt!)}',
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (r.boardApprovedId != null &&
                      r.boardApprovedAt != null) ...[
                    _buildInfoRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Phê duyệt Ban giám đốc',
                      content:
                          '${_getApproverName(r.boardApprovedId!, 'board_director')} • ${_fmt(r.boardApprovedAt!)}',
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (r.rejectionReason != null &&
                      r.rejectionReason!.isNotEmpty) ...[
                    // Làm nổi bật lý do từ chối
                    _buildHighlightedInfo(
                      icon: Icons.gpp_bad_rounded,
                      title: 'Lý do từ chối',
                      content: r.rejectionReason!,
                      color: ColorConstants.errorColor,
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
                backgroundColor: ColorConstants.errorColor,
                textColor: Colors.white,
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
                backgroundColor: ColorConstants.successColor,
                textColor: Colors.white,
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
        const SizedBox(height: 12),
        CustomButton(
          text: 'Hủy đơn',
          backgroundColor: Colors.grey,
          textColor: Colors.white,
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
              widget.onCancel?.call(updated);
            } catch (e) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  /// Widget được thiết kế để làm nổi bật thông tin quan trọng
  Widget _buildHighlightedInfo({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: isDark ? 0.9 : 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị thông tin phụ, thiết kế tinh gọn
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: textTheme.bodyLarge?.copyWith(
                  color: isDark ? colorScheme.onSurface : Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getApproverName(String approverId, String type) {
    // Sử dụng ApproverGroups từ context hoặc trả về tên từ model
    if (type == 'department_manager') {
      return widget.request.departmentApprovedName ?? 'Unknown';
    } else if (type == 'board_director') {
      return widget.request.boardApprovedName ?? 'Unknown';
    }
    return 'Unknown';
  }
}

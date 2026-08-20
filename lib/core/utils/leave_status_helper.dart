import 'package:flutter/material.dart';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';

/// Helper class để quản lý màu sắc và label của trạng thái đơn nghỉ phép
class LeaveStatusHelper {
  /// Lấy màu sắc tương ứng với trạng thái
  static Color getStatusColor(LeaveStatus status, ColorScheme colorScheme) {
    switch (status) {
      case LeaveStatus.pending:
        return ColorConstants.warningColor;
      case LeaveStatus.departmentApproved:
        return ColorConstants.infoColor;
      case LeaveStatus.approved:
        return ColorConstants.successColor;
      case LeaveStatus.rejected:
        return ColorConstants.errorColor;
      case LeaveStatus.cancelled:
        return colorScheme.onSurface.withValues(alpha: 0.45);
    }
  }

  /// Lấy label hiển thị tương ứng với trạng thái
  static String getStatusLabel(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'Đang chờ duyệt';
      case LeaveStatus.departmentApproved:
        return 'Đã duyệt cấp phòng';
      case LeaveStatus.approved:
        return 'Đã duyệt';
      case LeaveStatus.rejected:
        return 'Bị từ chối';
      case LeaveStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Lấy icon tương ứng với trạng thái
  static IconData getStatusIcon(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Icons.hourglass_top_rounded;
      case LeaveStatus.departmentApproved:
        return Icons.business_center_rounded;
      case LeaveStatus.approved:
        return Icons.check_circle_rounded;
      case LeaveStatus.rejected:
        return Icons.cancel_rounded;
      case LeaveStatus.cancelled:
        return Icons.do_not_disturb_on_rounded;
    }
  }

  /// Chip trạng thái outlined — dùng chung tile / detail sheet.
  static Widget buildStatusChip(BuildContext context, LeaveStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = getStatusColor(status, colorScheme);
    return SamcomChip(
      label: getStatusLabel(status),
      variant: SamcomChipVariant.outlined,
      color: color,
      dense: true,
      fontSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

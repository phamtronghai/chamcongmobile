import 'package:flutter/material.dart';
import 'package:attendancebyface/models/leave_request.dart';

/// Helper class để quản lý màu sắc và label của trạng thái đơn nghỉ phép
class LeaveStatusHelper {
  /// Lấy màu sắc tương ứng với trạng thái
  static Color getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.departmentApproved:
        return const Color(0xFF6B8E23); // primaryColor
      case LeaveStatus.approved:
        return const Color(0xFF4CAF50); // successColor
      case LeaveStatus.rejected:
        return const Color(0xFFF44336); // errorColor
      case LeaveStatus.cancelled:
        return Colors.grey;
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/utils/leave_status_helper.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest item;
  final VoidCallback? onTap;
  final String? applicantName;
  final String? applicantDepartment;
  final Color? statusColor; // Làm optional để có thể tính toán tự động

  const LeaveRequestTile({
    super.key,
    required this.item,
    this.statusColor,
    this.onTap,
    this.applicantName,
    this.applicantDepartment,
  });

  /// Định dạng khoảng thời gian.
  /// Ví dụ: "20/09/2025" hoặc "20/09/2025 - 22/09/2025"
  String _formatDateRange(DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final startFormatted = dateFormat.format(startDate);

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return startFormatted;
    }

    final endFormatted = dateFormat.format(endDate);
    return '$startFormatted - $endFormatted';
  }

  /// Định dạng tổng số ngày nghỉ, bỏ ".0" nếu là số nguyên.
  /// Ví dụ: 1.0 -> "1 ngày", 1.5 -> "1.5 ngày"
  String _formatTotalDays(double totalDays) {
    if (totalDays.truncate() == totalDays) {
      return '${totalDays.toInt()} ngày';
    }
    return '$totalDays ngày';
  }

  /// Tạo status chip từ helper chung
  Widget _buildStatusChip(BuildContext context) {
    final effectiveStatusColor =
        statusColor ?? LeaveStatusHelper.getStatusColor(item.status);
    final statusLabel = LeaveStatusHelper.getStatusLabel(item.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveStatusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveStatusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          color: effectiveStatusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Sử dụng helper chung để lấy màu sắc trạng thái
    final effectiveStatusColor =
        statusColor ?? LeaveStatusHelper.getStatusColor(item.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias, // Cần thiết để dải màu bên trái được bo góc
      child: InkWell(
        onTap: onTap,
        splashColor: effectiveStatusColor.withValues(alpha: 0.1),
        highlightColor: effectiveStatusColor.withValues(alpha: 0.05),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dải màu trạng thái
              Container(width: 10, color: effectiveStatusColor),

              // Nội dung chính
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tên người nộp đơn
                            Text(
                              applicantName ?? 'Không rõ tên',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Phòng ban
                            Text(
                              applicantDepartment ?? 'Chưa có phòng ban',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Thông tin chi tiết về ngày nghỉ và lý do
                            _buildInfoRow(
                              context,
                              icon: Icons.calendar_today_outlined,
                              text:
                                  '${_formatTotalDays(item.totalDays)} (${_formatDateRange(item.startDate, item.endDate)})',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Cột trạng thái và icon điều hướng
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusChip(context),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper để tạo một hàng thông tin gồm icon và text
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Extension để có thể thay đổi giá trị alpha của màu một cách tiện lợi.
extension ColorAlpha on Color {
  Color withValues({double? alpha}) {
    return withAlpha(((alpha ?? 1.0) * 255).round());
  }
}

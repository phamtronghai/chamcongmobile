import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/utils/leave_status_helper.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest item;
  final VoidCallback? onTap;
  final String? applicantName;
  final String? applicantDepartment;
  final Color? statusColor;

  const LeaveRequestTile({
    super.key,
    required this.item,
    this.statusColor,
    this.onTap,
    this.applicantName,
    this.applicantDepartment,
  });

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

  String _formatTotalDays(double totalDays) {
    if (totalDays.truncate() == totalDays) {
      return '${totalDays.toInt()} ngày';
    }
    return '$totalDays ngày';
  }

  Widget _totalDaysChip(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatTotalDays(item.totalDays),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: cs.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatusColor =
        statusColor ?? LeaveStatusHelper.getStatusColor(item.status);
    final title = applicantName ?? 'Không rõ tên';
    final statusLabel = LeaveStatusHelper.getStatusLabel(item.status);

    Widget card = BaseInfoCard(
      title: title,
      badge: Icon(
        Icons.event_note_outlined,
        size: 22,
        color: effectiveStatusColor,
      ),
      highlightText: statusLabel,
      subInfoWidget: _totalDaysChip(context),
      detailText: _formatDateRange(item.startDate, item.endDate),
      detailMaxLines: 2,
      onTap: onTap,
    );

    final dept = applicantDepartment;
    if (dept != null && dept.isNotEmpty) {
      card = Tooltip(message: dept, child: card);
    }

    return card;
  }
}

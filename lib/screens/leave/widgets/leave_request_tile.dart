import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/core/utils/leave_status_helper.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/app_theme.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest item;
  final VoidCallback? onTap;
  final String? applicantName;
  final String? applicantDepartment;

  const LeaveRequestTile({
    super.key,
    required this.item,
    this.onTap,
    this.applicantName,
    this.applicantDepartment,
  });

  String _formatDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return DateFormat('dd/MM/yyyy').format(startDate);
    }
    return DatePickerField.formatRange(startDate, endDate);
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
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      ),
      child: Text(
        _formatTotalDays(item.totalDays),
        style: TextConstants.appTextBold.copyWith(
          color: cs.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = applicantName ?? 'Không rõ tên';

    Widget card = BaseInfoCard(
      title: title,
      titleTrailing: LeaveStatusHelper.buildStatusChip(context, item.status),
      badge: Icon(
        Icons.event_note_outlined,
        size: 22,
        color: cs.primary,
      ),
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

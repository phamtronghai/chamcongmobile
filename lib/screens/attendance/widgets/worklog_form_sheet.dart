import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/screens/attendance/widgets/worklog_form_body.dart';
import 'package:flutter/material.dart';

/// Sheet nhập công việc nhanh từ timeline (1 buổi, 1 ngày).
class WorklogFormSheet extends StatelessWidget {
  final String userId;
  final DateTime selectedDate;
  final int? lockedSessionId;
  final String? lockedSessionLabel;
  final Future<void> Function()? onSuccess;

  const WorklogFormSheet({
    super.key,
    required this.userId,
    required this.selectedDate,
    this.lockedSessionId,
    this.lockedSessionLabel,
    this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required String userId,
    required DateTime selectedDate,
    int? lockedSessionId,
    String? lockedSessionLabel,
    Future<void> Function()? onSuccess,
  }) {
    return SamcomSheet.show<void>(
      context: context,
      builder: (ctx) => WorklogFormSheet(
        userId: userId,
        selectedDate: selectedDate,
        lockedSessionId: lockedSessionId,
        lockedSessionLabel: lockedSessionLabel,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = lockedSessionLabel;

    return SamcomSheet(
      title: 'Nhập công việc',
      primaryColor: colorScheme.primary,
      subtitleWidget: subtitle == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
              child: Text(
                subtitle,
                style: TextConstants.appTextRegular.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
      child: WorklogFormBody(
        userId: userId,
        selectedDate: selectedDate,
        lockedSessionId: lockedSessionId,
        lockedSessionLabel: lockedSessionLabel,
        onSuccess: onSuccess,
      ),
    );
  }
}

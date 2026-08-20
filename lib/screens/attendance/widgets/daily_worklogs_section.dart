import 'package:attendancebyface/models/worklog_model.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_timeline.dart';
import 'package:attendancebyface/screens/attendance/widgets/worklog_form_sheet.dart';

/// Timeline công việc: Sáng / Chiều / Ngoài giờ.
class DailyWorklogsSection extends StatelessWidget {
  final bool isLoadingWorklogs;
  final List<WorklogModel> worklogs;
  final String userId;
  final DateTime selectedDate;
  final Future<void> Function()? onWorklogAdded;

  const DailyWorklogsSection({
    super.key,
    required this.isLoadingWorklogs,
    required this.worklogs,
    required this.userId,
    required this.selectedDate,
    this.onWorklogAdded,
  });

  static const _sessions = <({int id, String label, IconData icon})>[
    (id: 1, label: 'Sáng', icon: Icons.wb_sunny_outlined),
    (id: 2, label: 'Chiều', icon: Icons.wb_twilight),
    (id: 3, label: 'Ngoài giờ', icon: Icons.nights_stay),
  ];

  void _openWorklogPopup({
    required BuildContext context,
    required int sessionId,
    required String sessionLabel,
  }) {
    WorklogFormSheet.show(
      context: context,
      userId: userId,
      selectedDate: selectedDate,
      lockedSessionId: sessionId,
      lockedSessionLabel: sessionLabel,
      onSuccess: onWorklogAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoadingWorklogs) {
      return const Center(
        child: SizedBox(
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Công việc trong ngày',
            style: TextConstants.appTextBold.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              final items =
                  worklogs.where((w) => w.sessionId == session.id).toList()
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
              final isLast = index == _sessions.length - 1;
              final isEmpty = items.isEmpty;

              return AttendanceTimelineTile(
                isLast: isLast,
                leading: Icon(
                  session.icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                title: session.label,
                onTap: isEmpty
                    ? () => _openWorklogPopup(
                        context: context,
                        sessionId: session.id,
                        sessionLabel: session.label,
                      )
                    : null,
                child: Text(
                  isEmpty
                      ? 'Chạm để nhập'
                      : items.map((e) => e.workName).join('\n'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: timelineContentStyle(theme, muted: isEmpty),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

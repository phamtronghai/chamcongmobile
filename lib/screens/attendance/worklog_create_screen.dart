import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/screens/attendance/widgets/worklog_form_body.dart';
import 'package:flutter/material.dart';

/// Màn nhập công việc đầy đủ (FAB To NCPT): nhiều buổi + nhiều ngày.
class WorklogCreateScreen extends StatelessWidget {
  final String userId;
  final DateTime selectedDate;
  final Future<void> Function()? onSuccess;

  const WorklogCreateScreen({
    super.key,
    required this.userId,
    required this.selectedDate,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nhập công việc'),
      body: SafeArea(
        child: WorklogFormBody(
          userId: userId,
          selectedDate: selectedDate,
          onSuccess: onSuccess,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        ),
      ),
    );
  }
}

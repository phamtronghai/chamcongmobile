import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_datepicker.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Form nhập công việc.
///
/// - Timeline: [lockedSessionId] ≠ null → 1 buổi, 1 ngày [selectedDate].
/// - FAB To NCPT: [lockedSessionId] = null → nhiều buổi + nhiều ngày.
class WorklogFormSheet extends StatefulWidget {
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
  State<WorklogFormSheet> createState() => _WorklogFormSheetState();
}

class _WorklogFormSheetState extends State<WorklogFormSheet> {
  final WorklogRepository _repository = locator<WorklogRepository>();
  final TextEditingController _controller = TextEditingController();
  late final Set<int> _selectedSessionIds;
  late Set<DateTime> _selectedDates;
  bool _isSubmitting = false;

  bool get _isLocked => widget.lockedSessionId != null;

  @override
  void initState() {
    super.initState();
    final day = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    _selectedDates = {day};
    _selectedSessionIds = widget.lockedSessionId != null
        ? {widget.lockedSessionId!}
        : <int>{1, 2};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _sessionColor(ThemeData theme, int sessionId) {
    switch (sessionId) {
      case 1:
        return theme.colorScheme.primary;
      case 2:
        return ColorConstants.warningColor;
      case 3:
        return ColorConstants.infoColor;
      default:
        return theme.dividerColor;
    }
  }

  Future<void> _onSubmit() async {
    final workName = _controller.text.trim();
    if (workName.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng nhập nội dung công việc',
        type: CustomSnackbarType.error,
      );
      return;
    }
    if (_selectedSessionIds.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn khung giờ (Sáng/Chiều/Ngoài giờ)',
        type: CustomSnackbarType.error,
      );
      return;
    }

    final dates = _selectedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();
    if (dates.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn ngày báo cáo',
        type: CustomSnackbarType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repository.init();
      final dateFormat = DateFormat('yyyy-MM-dd');
      for (final sessionId in _selectedSessionIds) {
        for (final date in dates) {
          final result = await _repository.createWorklog(
            userId: widget.userId,
            workName: workName,
            sessionId: sessionId,
            date: dateFormat.format(date),
          );
          if (result['success'] != true) {
            throw Exception(
              result['message'] ?? 'Nhập công việc không thành công!',
            );
          }
        }
      }
      if (!mounted) return;
      await widget.onSuccess?.call();
      if (!mounted) return;
      Navigator.of(context).pop();
      CustomSnackbar.show(
        context: context,
        message: dates.length > 1
            ? 'Nhập công việc thành công cho ${dates.length} ngày'
            : 'Nhập công việc thành công',
        type: CustomSnackbarType.success,
      );
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Nhập công việc không thành công!',
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = _isLocked ? widget.lockedSessionLabel : null;

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _controller,
              fieldType: CustomTextFieldType.multiline,
              label: 'Nội dung',
              hint: 'Nhập công việc…',
              autofocus: true,
              textStyle: TextConstants.appTextBold.copyWith(
                color: colorScheme.onSurface,
              ),
              labelStyle: TextConstants.appTextRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (!_isLocked) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSessionChip(theme, 'Sáng', 1),
                  _buildSessionChip(theme, 'Chiều', 2),
                  _buildSessionChip(theme, 'Ngoài giờ', 3),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Chọn ngày',
                style: TextConstants.appTextBold.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              CustomDatePicker(
                selectedDates: _selectedDates,
                mode: CustomDatePickerMode.multi,
                showModeToggle: false,
                onChanged: (dates) => setState(() => _selectedDates = dates),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(
              text: 'Xác nhận',
              icon: Icons.check,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionChip(ThemeData theme, String label, int sessionId) {
    final isSelected = _selectedSessionIds.contains(sessionId);
    final color = _sessionColor(theme, sessionId);
    return SamcomChip(
      label: label,
      onPressed: () {
        setState(() {
          if (isSelected) {
            _selectedSessionIds.remove(sessionId);
          } else {
            _selectedSessionIds.add(sessionId);
          }
        });
      },
      variant: isSelected
          ? SamcomChipVariant.filled
          : SamcomChipVariant.outlined,
      color: color,
      selected: isSelected,
      dense: true,
    );
  }
}

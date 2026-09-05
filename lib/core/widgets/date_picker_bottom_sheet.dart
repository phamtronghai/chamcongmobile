import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_datepicker.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';

/// Bottom sheet chọn ngày / khoảng ngày — API duy nhất cho date picker sheet.
///
/// Calendar gốc: [CustomDatePicker]. Form field: [DatePickerField].
class AppDatePickerBottomSheet {
  // ── single ────────────────────────────────────────────────────────────

  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? initialDisplayDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn ngày',
    String? subtitle,
    required void Function(DateTime) onDateSelected,
  }) {
    final init = initialDate ?? DateTime.now();
    return _present(
      context,
      title: title,
      subtitle: subtitle,
      initialDates: {init},
      initialDisplayDate: initialDisplayDate,
      initialMode: CustomDatePickerMode.single,
      minDate: minDate,
      maxDate: maxDate,
      onConfirm: (dates) {
        if (dates.isNotEmpty) onDateSelected(dates.first);
      },
    );
  }

  // ── range ─────────────────────────────────────────────────────────────

  static Future<void> showRange(
    BuildContext context, {
    required DateTimeRange initialRange,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn khoảng ngày',
    String? subtitle,
    required void Function(DateTimeRange) onRangeSelected,
  }) {
    return _present(
      context,
      title: title,
      subtitle: subtitle,
      initialDates: {initialRange.start, initialRange.end},
      initialMode: CustomDatePickerMode.range,
      minDate: minDate,
      maxDate: maxDate,
      onConfirm: (dates) {
        if (dates.isEmpty) return;
        final sorted = dates.toList()..sort();
        onRangeSelected(DateTimeRange(start: sorted.first, end: sorted.last));
      },
    );
  }

  // ── private helper ─────────────────────────────────────────────────────

  static Future<void> _present(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Set<DateTime> initialDates,
    DateTime? initialDisplayDate,
    required CustomDatePickerMode initialMode,
    DateTime? minDate,
    DateTime? maxDate,
    required void Function(Set<DateTime>) onConfirm,
  }) {
    // minDate/maxDate giữ trên API public (DatePickerField) — CustomDatePicker
    // hiện chưa enforce; truyền sẵn để mở rộng sau.
    return SamcomSheet.show<void>(
      context: context,
      builder: (ctx) => _DatePickerSheet(
        title: title,
        subtitle: subtitle,
        initialDates: initialDates,
        initialDisplayDate: initialDisplayDate,
        initialMode: initialMode,
        onConfirm: onConfirm,
      ),
    );
  }
}

// ── sheet widget ───────────────────────────────────────────────────────────

class _DatePickerSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Set<DateTime> initialDates;
  final DateTime? initialDisplayDate;
  final CustomDatePickerMode initialMode;
  final void Function(Set<DateTime>) onConfirm;

  const _DatePickerSheet({
    required this.title,
    this.subtitle,
    required this.initialDates,
    this.initialDisplayDate,
    required this.initialMode,
    required this.onConfirm,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late Set<DateTime> _dates;
  late CustomDatePickerMode _mode;

  @override
  void initState() {
    super.initState();
    _dates = {...widget.initialDates};
    _mode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return SamcomSheet(
      icon: Icons.calendar_today_outlined,
      title: widget.title,
      subtitle: widget.subtitle,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDatePicker(
              selectedDates: _dates,
              mode: _mode,
              initialDisplayDate: widget.initialDisplayDate,
              showModeToggle: false,
              onModeChanged: (m) => setState(() => _mode = m),
              onChanged: (dates) => setState(() => _dates = dates),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Hủy',
                    icon: Icons.close,
                    variant: CustomButtonVariant.normalButton,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Chọn',
                    icon: Icons.check,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onConfirm(_dates);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

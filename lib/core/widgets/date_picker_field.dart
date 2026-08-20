import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/date_picker_bottom_sheet.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';

/// Hiển thị một ngày hoặc khoảng ngày, chạm mở bottom sheet picker.
///
/// Format range thông minh:
/// - cùng tháng+năm → `01–05/08/2026`
/// - cùng năm, khác tháng → `01/07–01/08/2026`
/// - khác năm → `01/07/2025–01/08/2026`
enum DatePickerFieldMode { single, range }

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.mode,
    this.selectedDate,
    this.selectedRange,
    this.onDateChanged,
    this.onRangeChanged,
    this.label,
    this.minDate,
    this.maxDate,
    this.dialogTitle,
    this.dialogSubtitle,
    this.enabled = true,
    this.hintSingle,
    this.hintRange,
    this.compact = false,
    this.fitContent = true,
  })  : assert(
          mode != DatePickerFieldMode.single || (onDateChanged != null),
          'onDateChanged is required for single mode',
        ),
        assert(
          mode != DatePickerFieldMode.range || (onRangeChanged != null),
          'onRangeChanged is required for range mode',
        );

  final DatePickerFieldMode mode;
  final DateTime? selectedDate;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<DateTimeRange>? onRangeChanged;
  final String? label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? dialogTitle;
  final String? dialogSubtitle;
  final bool enabled;
  final String? hintSingle;
  final String? hintRange;

  /// Compact: nút nhỏ hơn — dùng trong header cạnh chip khác.
  final bool compact;

  /// Nút chọn ngày co theo nội dung thay vì full width.
  final bool fitContent;

  static final _dd = DateFormat('dd');
  static final _ddMM = DateFormat('dd/MM');
  static final _ddMMYYYY = DateFormat('dd/MM/yyyy');

  /// Format range gọn theo quy tắc:
  /// - cùng tháng & năm → `01–05/08/2026`
  /// - cùng năm → `01/07–01/08/2026`
  /// - khác năm → `01/07/2025–01/08/2026`
  static String formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${_dd.format(start)}–${_ddMMYYYY.format(end)}';
    }
    if (start.year == end.year) {
      return '${_ddMM.format(start)}–${_ddMMYYYY.format(end)}';
    }
    return '${_ddMMYYYY.format(start)}–${_ddMMYYYY.format(end)}';
  }

  String _displayText() {
    switch (mode) {
      case DatePickerFieldMode.single:
        if (selectedDate == null) return hintSingle ?? 'Chọn ngày';
        return _ddMMYYYY.format(selectedDate!);
      case DatePickerFieldMode.range:
        if (selectedRange == null) return hintRange ?? 'Chọn khoảng ngày';
        return formatRange(selectedRange!.start, selectedRange!.end);
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;
    switch (mode) {
      case DatePickerFieldMode.single:
        await AppDatePickerBottomSheet.show(
          context,
          initialDate: selectedDate ?? DateTime.now(),
          minDate: minDate,
          maxDate: maxDate,
          title: dialogTitle ?? 'Chọn ngày',
          subtitle: dialogSubtitle,
          onDateSelected: onDateChanged!,
        );
      case DatePickerFieldMode.range:
        final now = DateTime.now();
        final initial = selectedRange ??
            DateTimeRange(start: now, end: now.add(const Duration(days: 1)));
        await AppDatePickerBottomSheet.showRange(
          context,
          initialRange: initial,
          minDate: minDate,
          maxDate: maxDate,
          title: dialogTitle ?? 'Chọn khoảng ngày',
          subtitle: dialogSubtitle,
          onRangeSelected: onRangeChanged!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _displayText();
    final icon = mode == DatePickerFieldMode.single
        ? Icons.calendar_today_outlined
        : Icons.date_range_outlined;
    final isPlaceholder = (mode == DatePickerFieldMode.single &&
            selectedDate == null) ||
        (mode == DatePickerFieldMode.range && selectedRange == null);

    Widget btn = CustomButton(
      text: text,
      icon: icon,
      variant: CustomButtonVariant.normalButton,
      onPressed: enabled ? () => _openPicker(context) : null,
    );

    if (isPlaceholder) btn = Opacity(opacity: 0.55, child: btn);

    if (fitContent) {
      btn = Align(alignment: Alignment.center, child: btn);
    }

    return Column(
      crossAxisAlignment:
          fitContent ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
        ],
        btn,
      ],
    );
  }
}

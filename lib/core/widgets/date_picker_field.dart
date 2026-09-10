import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/date_picker_bottom_sheet.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';

/// Hiển thị một ngày, nhiều ngày rời, hoặc khoảng ngày; chạm mở bottom sheet.
///
/// Format range thông minh:
/// - cùng tháng+năm → `01–05/08/2026`
/// - cùng năm, khác tháng → `01/07–01/08/2026`
/// - khác năm → `01/07/2025–01/08/2026`
enum DatePickerFieldMode { single, multi, range }

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.mode,
    this.selectedDate,
    this.selectedDates,
    this.selectedRange,
    this.onDateChanged,
    this.onDatesChanged,
    this.onRangeChanged,
    this.label,
    this.minDate,
    this.maxDate,
    this.dialogTitle,
    this.dialogSubtitle,
    this.enabled = true,
    this.hintSingle,
    this.hintMulti,
    this.hintRange,
    this.compact = false,
    this.fitContent = true,
  })  : assert(
          mode != DatePickerFieldMode.single || (onDateChanged != null),
          'onDateChanged is required for single mode',
        ),
        assert(
          mode != DatePickerFieldMode.multi || (onDatesChanged != null),
          'onDatesChanged is required for multi mode',
        ),
        assert(
          mode != DatePickerFieldMode.range || (onRangeChanged != null),
          'onRangeChanged is required for range mode',
        );

  final DatePickerFieldMode mode;
  final DateTime? selectedDate;
  final Set<DateTime>? selectedDates;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<Set<DateTime>>? onDatesChanged;
  final ValueChanged<DateTimeRange>? onRangeChanged;
  final String? label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? dialogTitle;
  final String? dialogSubtitle;
  final bool enabled;
  final String? hintSingle;
  final String? hintMulti;
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

  static String formatMulti(Set<DateTime> dates) {
    final sorted = dates.toList()..sort();
    if (sorted.isEmpty) return '';
    if (sorted.length == 1) return _ddMMYYYY.format(sorted.first);
    if (sorted.length <= 3) {
      return sorted.map(_ddMM.format).join(', ');
    }
    return '${sorted.length} ngày đã chọn';
  }

  String _displayText() {
    switch (mode) {
      case DatePickerFieldMode.single:
        if (selectedDate == null) return hintSingle ?? 'Chọn ngày';
        return _ddMMYYYY.format(selectedDate!);
      case DatePickerFieldMode.multi:
        final dates = selectedDates ?? const <DateTime>{};
        if (dates.isEmpty) return hintMulti ?? 'Chọn các ngày';
        return formatMulti(dates);
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
      case DatePickerFieldMode.multi:
        await AppDatePickerBottomSheet.showMulti(
          context,
          initialDates: selectedDates ?? const {},
          minDate: minDate,
          maxDate: maxDate,
          title: dialogTitle ?? 'Chọn ngày',
          subtitle: dialogSubtitle,
          onDatesSelected: onDatesChanged!,
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
    final icon = switch (mode) {
      DatePickerFieldMode.single => Icons.calendar_today_outlined,
      DatePickerFieldMode.multi => Icons.event_available_outlined,
      DatePickerFieldMode.range => Icons.date_range_outlined,
    };
    final isPlaceholder = switch (mode) {
      DatePickerFieldMode.single => selectedDate == null,
      DatePickerFieldMode.multi =>
        selectedDates == null || selectedDates!.isEmpty,
      DatePickerFieldMode.range => selectedRange == null,
    };

    Widget btn = CustomButton(
      text: text,
      icon: icon,
      variant: CustomButtonVariant.normalButton,
      onPressed: enabled ? () => _openPicker(context) : null,
    );

    // Không làm mờ khi còn bấm được (placeholder ≠ disabled).
    if (isPlaceholder && !enabled) {
      btn = Opacity(opacity: 0.55, child: btn);
    }

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
